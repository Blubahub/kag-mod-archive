// Juggernaut logic

#include "ThrowCommon.as"
#include "JuggernautCommon.as";
#include "KnightCommon.as";
#include "RunnerCommon.as";
#include "HittersNew.as";
#include "ShieldCommon.as";
#include "Help.as";
#include "Requirements.as";
#include "SplashWater.as"



//attacks limited to the one time per-actor before reset.

void juggernaut_actorlimit_setup(CBlob@ this)
{
	u16[] networkIDs;
	this.set("LimitedActors",networkIDs);
}

bool juggernaut_has_hit_actor(CBlob@ this,CBlob@ actor)
{
	u16[]@ networkIDs;
	this.get("LimitedActors",@networkIDs);
	return networkIDs.find(actor.getNetworkID()) >= 0;
}

u32 juggernaut_hit_actor_count(CBlob@ this)
{
	u16[]@ networkIDs;
	this.get("LimitedActors",@networkIDs);
	return networkIDs.length;
}

void juggernaut_add_actor_limit(CBlob@ this,CBlob@ actor)
{
	this.push("LimitedActors",actor.getNetworkID());
}

void juggernaut_clear_actor_limits(CBlob@ this)
{
	this.clear("LimitedActors");
}

void onInit(CBlob@ this)
{
	JuggernautInfo juggernaut;

	juggernaut.state=		JuggernautStates::normal;
	juggernaut.prevState=	JuggernautStates::normal;
	juggernaut.actionTimer=	0;
	juggernaut.actionTimer=	0;
	juggernaut.normalSprite=true;
	juggernaut.tileDestructionLimiter=0;
	juggernaut.dontHitMore=false;

	this.set("JuggernautInfo",@juggernaut);

	this.set_f32("gib health",-3.0f);
	addShieldVars(this,SHIELD_BLOCK_ANGLE,2.0f,5.0f);
	juggernaut_actorlimit_setup(this);
	this.getShape().SetRotationsAllowed(false);
	this.getShape().getConsts().net_threshold_multiplier=	0.5f;
	this.Tag("player");
	this.Tag("flesh");

	this.addCommandID("get bomb");

	this.push("names to activate","keg");

	this.set_u8("bomb type",255);
	for(uint i=0; i < bombTypeNames.length; i++)
	{
		this.addCommandID("pick " + bombTypeNames[i]);
	}

	this.set_Vec2f("inventory offset",Vec2f(0.0f,0.0f));

	SetHelp(this,"help self action","juggernaut","$Slash$ Slash!    $KEY_HOLD$$LMB$","",13);
	SetHelp(this,"help self action2","juggernaut","$Shield$Shield    $KEY_HOLD$$RMB$","",13);

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag=	"dead";
	
	/*this.addCommandID("tryFatality");
	this.addCommandID("fatality");
		this.set_f32("fatalityTime",-1);
		this.set_f32("fatalityTimeMax",0);
		this.set_bool("wasFacingLeft",false);*/
		
	this.addCommandID("grabbedSomeone");
	this.addCommandID("throw");
		
	this.set_string("grabbedEnemy","knight");
	
	//CSprite@ sprite=this.getSprite();
	/*CSpriteLayer@ tracer=sprite.addSpriteLayer("tracer","Tracer.png",32,1,this.getTeamNum(),0);
	if(tracer !is null) {
		Animation@ anim = tracer.addAnimation("default",0,false);
		anim.AddFrame(0);
		tracer.SetRelativeZ(-1.0f);
		tracer.SetVisible(false);
		tracer.setRenderStyle(RenderStyle::additive);
	}*/
}

void onSetPlayer(CBlob@ this,CPlayer@ player)
{
	if(player !is null)
	{
		player.SetScoreboardVars("ScoreboardIcons.png",3,Vec2f(16,16));
	}
}


void onTick(CBlob@ this)
{
	if(this.isInInventory()){
		return;
	}
	RunnerMoveVars@ moveVars;
	if(!this.get("moveVars",@moveVars)) {
		return;
	}
	JuggernautInfo@ juggernaut;
	if(!this.get("JuggernautInfo",@juggernaut)) {
		return;
	}
	
	juggernaut.prevState=	juggernaut.state;
	
	Vec2f vec;
	Vec2f aimPos=		this.getAimPos();
	const int direction=this.getAimDirection(vec);
	const f32 side=		(this.isFacingLeft() ? 1.0f : -1.0f);
	
	Vec2f pos=			this.getPosition();
	Vec2f vel=			this.getVelocity();
	bool isInAir=		(!this.isOnGround() && !this.isOnLadder());
	const bool isMyPlayer=	this.isMyPlayer();
	
	bool pressed_lmb=	this.isKeyPressed(key_action1);
	bool pressed_rmb=	this.isKeyPressed(key_action2);
	
	if(juggernaut.state==JuggernautStates::stun){
		moveVars.jumpFactor=	0.0f;
		moveVars.walkFactor=	0.0f;
		juggernaut.actionTimer=	0;
		juggernaut.actionTimer=	0;
		juggernaut.dontHitMore=false;
		juggernaut.stun--;
		if(juggernaut.stun<=0){
			juggernaut.state=JuggernautStates::normal;
		}
	}else if(juggernaut.state==JuggernautStates::normal){
		//Normal
		if(juggernaut.attackDelay>0){
			juggernaut.attackDelay--;
		}else if(pressed_lmb){
			juggernaut.state=	JuggernautStates::charging;
			juggernaut.actionTimer=	0;
			juggernaut.dontHitMore=false;
		}
		if(pressed_rmb){
			juggernaut.state=	JuggernautStates::grabbing;
			juggernaut.actionTimer=	0;
			juggernaut.dontHitMore=false;
			if(getNet().isClient()){
				Sound::Play("/ArgLong",this.getPosition());
			}
		}
	}else if(juggernaut.state==JuggernautStates::charging){
		//Charging hammer attack
		moveVars.jumpFactor*=	0.3f;
		moveVars.walkFactor*=	0.55f;
		juggernaut.actionTimer+=1;
		if(juggernaut.actionTimer>=JuggernautVars::chargeLimit){
			//Overcharge, Stun
			juggernaut.state=	JuggernautStates::stun;
			juggernaut.stun=	15;
			if(getNet().isClient()){
				Sound::Play("/Stun",pos,1.0f,this.getSexNum()==0 ? 1.0f : 2.0f);
			}
		}else if(!pressed_lmb){
			if(juggernaut.actionTimer>=JuggernautVars::chargeTime){
				//Charged Attack
				juggernaut.state=	JuggernautStates::chargedAttack;
				juggernaut.actionTimer=	0;
				juggernaut.dontHitMore=false;
				if(getNet().isClient()){
					Sound::Play("/ArgLong",this.getPosition());
					PlaySoundRanged(this,"SwingHeavy",4,1.0f,1.0f);
				}
			}
		}
	}else if(juggernaut.state==JuggernautStates::chargedAttack){
		//Attacking with the hammer
		moveVars.jumpFactor*=	0.3f;
		moveVars.walkFactor*=	0.55f;
		if(juggernaut.actionTimer>=JuggernautVars::attackTime){
			juggernaut.state=JuggernautStates::normal;
			juggernaut.actionTimer=	0;
			juggernaut.dontHitMore=false;
			juggernaut.attackDelay=JuggernautVars::attackDelay;
		}else{
			DoAttack(this,2.0f,-(vec.Angle()),120.0f,HittersNew::hammer,juggernaut.actionTimer,juggernaut);
		}
		juggernaut.actionTimer+=1;
	}else if(juggernaut.state==JuggernautStates::grabbing){
		//Trying to grab a stunned enemy
		moveVars.jumpFactor*=	0.3f;
		moveVars.walkFactor*=	0.55f;
		if(juggernaut.actionTimer>=JuggernautVars::grabTime){
			juggernaut.state=		JuggernautStates::normal;
			juggernaut.actionTimer=	0;
			juggernaut.dontHitMore=false;
			juggernaut.attackDelay=	JuggernautVars::attackDelay;
		}else{
			if(getNet().isServer() && juggernaut.dontHitMore==false){
				//Grab
				const float range=	32.0f;
				f32 angle=	-((this.getAimPos()-pos).getAngleDegrees());
				if(angle<0.0f){
					angle+=360.0f;
				}
				Vec2f dir=Vec2f(1.0f,0.0f).RotateBy(angle);
				
				Vec2f startPos=	this.getPosition();
				Vec2f endPos=	startPos+(dir*range);
			
				HitInfo@[] hitInfos;
				Vec2f hitPos;
				bool mapHit=getMap().rayCastSolid(startPos,endPos,hitPos);
				f32 length=	(hitPos-startPos).Length();
				
				bool blobHit=	getMap().getHitInfosFromRay(startPos,angle,length,this,@hitInfos);
				
				if(blobHit) {
					for(u32 i=0;i<hitInfos.length;i++) {
						if(hitInfos[i].blob !is null) {	
							CBlob@ blob=	hitInfos[i].blob;
							if((blob.getConfig()=="knight" || blob.getConfig()=="archer") && !blob.hasTag("dead")) {
								if(blob.getConfig()=="knight"){
									KnightInfo@ knight;
									if(this.get("knightInfo",@knight)) {
										if(knight.state>=1 && knight.state<=3){
											print("blocked grab!");
											continue;
										}
									}
								}
								if(blob.getHealth()<=1.0f){
									blob.server_Die();
									CBitStream stream;
									stream.write_string(blob.getConfig());
									this.SendCommand(this.getCommandID("grabbedSomeone"),stream);
									juggernaut.state=JuggernautStates::grabbed;
								}else{
									this.server_Hit(blob,this.getPosition(),dir,1.0f,HittersNew::flying,false);
								}
								juggernaut.dontHitMore=true;
								break;
							}
						}
					}
				}
			}
		}
		juggernaut.actionTimer+=1;
	}else if(juggernaut.state==JuggernautStates::grabbed){
		//Holding someone by the neck
		if(juggernaut.attackDelay>0){
			juggernaut.attackDelay--;
		}else if(pressed_lmb){
			juggernaut.state=	JuggernautStates::throwing;
			juggernaut.actionTimer=	0;
			juggernaut.dontHitMore=false;
			
			if(getNet().isClient()){
				Sound::Play("/ArgLong",this.getPosition());
			}
			
			if(getNet().isServer()){
				f32 angle=	-((this.getAimPos()-pos).getAngleDegrees());
				if(angle<0.0f){
					angle+=360.0f;
				}
				Vec2f dir=Vec2f(1.0f,0.0f).RotateBy(angle);
				CBlob@ blob=server_CreateBlob("corpse",this.getTeamNum(),pos);
				blob.setVelocity(dir*12.0f);
			}
		}else if(pressed_rmb && this.isKeyJustPressed(key_action2)){
			this.set_bool("wasFacingLeft",this.isFacingLeft());
			juggernaut.state=	JuggernautStates::fatality;
			juggernaut.actionTimer=	0;
		}
	}else if(juggernaut.state==JuggernautStates::throwing){
		//Trying to grab a stunned enemy
		if(juggernaut.actionTimer>=JuggernautVars::throwTime){
			juggernaut.state=		JuggernautStates::normal;
			juggernaut.actionTimer=	0;
			juggernaut.dontHitMore=false;
			juggernaut.attackDelay=	JuggernautVars::attackDelay;
		}
		juggernaut.actionTimer+=1;
	}else if(juggernaut.state==JuggernautStates::fatality){
		if(!this.hasTag("invincible")){
			this.Tag("invincible");
		}
		if(getNet().isClient()) {
			if(juggernaut.actionTimer==4){
				Sound::Play("ArgShort.ogg",pos,1.0f);
			}else if(juggernaut.actionTimer==27){
				Sound::Play("ArgLong.ogg",pos,1.0f);
			}else if(juggernaut.actionTimer==39){
				Sound::Play("FallOnGround.ogg",pos,0.4f);
			}else if(juggernaut.actionTimer==64){
				Sound::Play("Gore.ogg",pos,1.0f);
				Vec2f offset=Vec2f(0,0);
				ParticleBlood(pos+Vec2f(this.isFacingLeft()?offset.x:-offset.x,offset.y),Vec2f(0,10),SColor(255,126,0,0));
			}
		}
		if(juggernaut.actionTimer>=JuggernautVars::fatalityTime){
			this.server_Heal(5.0f);
			juggernaut.state=	JuggernautStates::normal;
			juggernaut.actionTimer=	0;
			this.Untag("invincible");
			this.DisableKeys(0);
			this.DisableMouse(false);
		}else{
			u16 takenKeys=	key_left|key_right|key_up|key_down|key_action1|key_action2|key_action3|KEY_LSHIFT;
			this.DisableKeys(takenKeys);
			this.DisableMouse(true);
		}
		this.SetFacingLeft(this.get_bool("wasFacingLeft"));
		
		juggernaut.actionTimer+=1;
	}

	if(juggernaut.state!=JuggernautStates::charging && juggernaut.state!=JuggernautStates::chargedAttack && getNet().isServer()) {
		juggernaut_clear_actor_limits(this);
	}
}
bool IsKnocked(CBlob@ blob)
{
	if(!blob.exists("knocked")){
		return false;
	}
	return blob.get_u8("knocked")>0;
}
/*void DrawLine(CSprite@ this, u8 index, Vec2f startPos, f32 length, f32 angleOffset, bool flip)
{
	CSpriteLayer@ tracer=this.getSpriteLayer("tracer");
	
	tracer.SetVisible(true);
	
	tracer.ResetTransform();
	tracer.ScaleBy(Vec2f(length,1.0f));
	tracer.TranslateBy(Vec2f(length*16.0f,0.0f));
	tracer.RotateBy(angleOffset + (flip ? 180 : 0),Vec2f());
}*/
void PlaySoundRanged(CBlob@ this,string sound,int range,float volume,float pitch)
{
	this.getSprite().PlaySound(sound+(range>1 ? formatInt(XORRandom(range-1)+1,"")+".ogg" : ".ogg"),volume,pitch);
}
void onCommand(CBlob@ this,u8 cmd,CBitStream @stream)
{
	if(cmd==this.getCommandID("grabbedSomeone")){
		JuggernautInfo@ juggernaut;
		if(!this.get("JuggernautInfo",@juggernaut)) {
			return;
		}
		this.set_string("grabbedEnemy",stream.read_string());
		juggernaut.state=JuggernautStates::grabbed;
		juggernaut.attackDelay=15;
		if(getNet().isClient()){
			CSpriteLayer@ victim=this.getSprite().getSpriteLayer("victim");
			if(victim !is null){
				if(this.get_string("grabbedEnemy")=="knight"){
					victim.ReloadSprite("KnightVictim.png",64,64,0,0);
				}else{
					victim.ReloadSprite("ArcherVictim.png",64,64,0,0);
				}
			}
		}
	}else if(cmd == this.getCommandID("get bomb"))
	{
		const u8 bombType=	stream.read_u8();
		if(bombType >= bombTypeNames.length)
			return;

		const string bombTypeName=	bombTypeNames[bombType];
		this.Tag(bombTypeName + " done activate");
		if(hasItem(this,bombTypeName))
		{
			if(bombType == 0)
			{
				if(getNet().isServer())
				{
					CBlob @blob=	server_CreateBlob("bomb",this.getTeamNum(),this.getPosition());
					if(blob !is null)
					{
						TakeItem(this,bombTypeName);
						this.server_Pickup(blob);
					}
				}
			}
			else if(bombType == 1)
			{
				if(getNet().isServer())
				{
					CBlob @blob=	server_CreateBlob("waterbomb",this.getTeamNum(),this.getPosition());
					if(blob !is null)
					{
						TakeItem(this,bombTypeName);
						this.server_Pickup(blob);
						blob.set_f32("map_damage_ratio",0.0f);
						blob.set_f32("explosive_damage",0.0f);
						blob.set_f32("explosive_radius",92.0f);
						blob.set_bool("map_damage_raycast",false);
						blob.set_string("custom_explosion_sound","/GlassBreak");
						blob.set_u8("custom_hitter",HittersNew::water);
                        blob.Tag("splash ray cast");

					}
				}
			}
			else
			{
			}

			SetFirstAvailableBomb(this);
		}
	}
	else if(cmd == this.getCommandID("cycle"))  //from standardcontrols
	{
		// cycle arrows
		u8 type=	this.get_u8("bomb type");
		int count=	0;
		while(count < bombTypeNames.length)
		{
			type++;
			count++;
			if(type >= bombTypeNames.length)
				type=	0;
			if(this.getBlobCount(bombTypeNames[type]) > 0)
			{
				this.set_u8("bomb type",type);
				if(this.isMyPlayer())
				{
					Sound::Play("/CycleInventory.ogg");
				}
				break;
			}
		}
	}
	else if(cmd == this.getCommandID("activate/throw"))
	{
		SetFirstAvailableBomb(this);
	}/*else if(cmd==this.getCommandID("tryFatality")) {
		if(!getNet().isServer()){
			return;
		}
		JuggernautInfo@ juggernaut;
		if(!this.get("JuggernautInfo",@juggernaut)) {
			return;
		}
		this.set_bool("wasFacingLeft",stream.read_bool());
		Vec2f vec;
		const int direction=	this.getAimDirection(vec); //weird
		DoGrab(this,-(vec.Angle()),120.0f,juggernaut);
	}
	else if(cmd==this.getCommandID("fatality")) {
		print("got fatality message from the server");
		u16 blobId=			stream.read_u16();
		u8 fatalityId=		stream.read_u8();
		bool wasFacingLeft=	stream.read_bool();
		CBlob@ blob=getBlobByNetworkID(blobId);
		if(blob is null){
			print("command: fatality: victim's blob is null");
			return;
		}
		JuggernautInfo@ juggernaut;
		if(!this.get("JuggernautInfo",@juggernaut)) {
			return;
		}
		CShape@ shape=	this.getShape();
			Vec2f pos=	shape.getPosition();
		CShape@ victimShape=blob.getShape();
			victimShape.SetPosition(pos);
			victimShape.SetStatic(true);
		blob.set_u16("fatalityBy",this.getNetworkID());
		blob.Tag("fatality1");
		juggernaut.state=JuggernautStates::fatality1;
		this.set_bool("wasFacingLeft",wasFacingLeft);
		this.set_f32("fatalityTimeMax",100);
		this.set_f32("fatalityTime",0);
		print("success!!!");
	}*/
	else
	{
		for(uint i=	0; i < bombTypeNames.length; i++)
		{
			if(cmd == this.getCommandID("pick " + bombTypeNames[i]))
			{
				this.set_u8("bomb type",i);
				break;
			}
		}
	}
}


f32 onHit(CBlob@ this,Vec2f worldPoint,Vec2f velocity,f32 damage,CBlob@ hitterBlob,u8 customData)
{
	return damage;
}

/////////////////////////////////////////////////

void DoAttack(CBlob@ this,f32 damage,f32 aimangle,f32 arcDegrees,u8 type,int deltaInt,JuggernautInfo@ info)
{
	if(!getNet().isServer()) {
		return;
	}
	if(aimangle<0.0f) {
		aimangle+=360.0f;
	}

	Vec2f blobPos=	this.getPosition();
	Vec2f vel=	this.getVelocity();
	Vec2f thinghy(1,0);
	thinghy.RotateBy(aimangle);
	Vec2f pos=	blobPos - thinghy * 6.0f + vel + Vec2f(0,-2);
	vel.Normalize();

	f32 attack_distance=	Maths::Min(DEFAULT_ATTACK_DISTANCE + Maths::Max(0.0f,1.75f * this.getShape().vellen *(vel * thinghy)),MAX_ATTACK_DISTANCE);

	f32 radius=	this.getRadius();
	CMap@ map=	this.getMap();
	bool dontHitMore=	false;
	bool dontHitMoreMap=false;

	//get the actual aim angle
	f32 exact_aimangle=	(this.getAimPos() - blobPos).Angle();

	// this gathers HitInfo objects which contain blob or tile hit information
	HitInfo@[] hitInfos;
	if(map.getHitInfosFromArc(pos,aimangle,arcDegrees,radius + attack_distance,this,@hitInfos))
	{
		//HitInfo objects are sorted,first come closest hits
		for(uint i=	0; i < hitInfos.length; i++) {
			HitInfo@ hi=hitInfos[i];
			CBlob@ b=	hi.blob;
			if(b !is null && !dontHitMore && deltaInt<=JuggernautVars::attackTime-9) // blob
			{
				//big things block attacks
				const bool large=	b.hasTag("blocks sword") && !b.isAttached() && b.isCollidable();

				if(!canHit(this,b)) {
					// no TK
					if(large){
						dontHitMore=	true;
					}
					continue;
				}

				if(juggernaut_has_hit_actor(this,b))
				{
					if(large){
						dontHitMore=	true;
					}
					continue;
				}

				juggernaut_add_actor_limit(this,b);
				if(!dontHitMore)
				{
					Vec2f velocity=	b.getPosition() - pos;
					this.server_Hit(b,hi.hitpos,velocity,damage,type,true);  // server_Hit() is server-side only

					// end hitting if we hit something solid,don't if its flesh
					if(large)
					{
						dontHitMore=	true;
					}
				}
			}else if(!dontHitMoreMap &&(deltaInt == DELTA_BEGIN_ATTACK + 1)) { // hitmap
				Vec2f tpos=	map.getTileWorldPosition(hi.tileOffset) + Vec2f(4,4);
				Vec2f offset=	(tpos - blobPos);
				f32 tileangle=	offset.Angle();
				f32 dif=	Maths::Abs(exact_aimangle - tileangle);
				if(dif > 180){
					dif -= 360;
				}
				if(dif < -180){
					dif += 360;
				}

				dif=	Maths::Abs(dif);
				//print("dif: "+dif);

				if(dif < 30.0f){
					if(map.getSectorAtPosition(tpos,"no build") !is null){
						continue;
					}
					map.server_DestroyTile(hi.hitpos,1.0f,this); //copypasted so it doesn't damage bedrock
					map.server_DestroyTile(hi.hitpos,1.0f,this);
					map.server_DestroyTile(hi.hitpos,1.0f,this);
					map.server_DestroyTile(hi.hitpos,1.0f,this);
					map.server_DestroyTile(hi.hitpos,1.0f,this);
					//this.server_HitMap(hi.hitpos,offset,1.0f,HittersNew::builder);
				}
			}
		}
	}

	// destroy grass

	if(((aimangle >= 0.0f && aimangle <= 180.0f) || damage > 1.0f) &&    // aiming down or slash
	(deltaInt == DELTA_BEGIN_ATTACK + 1)) // hit only once
	{
		f32 tilesize=	map.tilesize;
		int steps=	Maths::Ceil(2 * radius / tilesize);
		int sign=	this.isFacingLeft() ? -1 : 1;

		for(int y=	0; y < steps; y++)
			for(int x=	0; x < steps; x++)
			{
				Vec2f tilepos=	blobPos + Vec2f(x * tilesize * sign,y * tilesize);
				TileType tile=	map.getTile(tilepos).type;

				if(map.isTileGrass(tile))
				{
					map.server_DestroyTile(tilepos,damage,this);

					if(damage <= 1.0f)
					{
						return;
					}
				}
			}
	}
}

void DoGrab(CBlob@ this,f32 aimangle,f32 arcDegrees,JuggernautInfo@ info)
{
	if(!getNet().isServer()) {
		return;
	}
	print("grab called on a server");
	if(aimangle<0.0f) {
		aimangle+=360.0f;
	}
	Vec2f blobPos=	this.getPosition();
	Vec2f vel=		this.getVelocity();
	Vec2f thinghy(1,0);
	thinghy.RotateBy(aimangle);
	Vec2f pos=	blobPos-thinghy*6.0f+vel+Vec2f(0,-2);
	vel.Normalize();

	f32 attack_distance=Maths::Min(DEFAULT_ATTACK_DISTANCE+Maths::Max(0.0f,1.75f*this.getShape().vellen*(vel*thinghy)),MAX_ATTACK_DISTANCE);

	f32 radius=			this.getRadius();
	CMap@ map=			this.getMap();

	f32 exact_aimangle=	(this.getAimPos()-blobPos).Angle(); //get the actual aim angle

	HitInfo@[] hitInfos; // this gathers HitInfo objects which contain blob or tile hit information
	if(map.getHitInfosFromArc(pos,aimangle,arcDegrees,radius+attack_distance,this,@hitInfos))
	{
		for(uint i=0;i<hitInfos.length;i++) { //HitInfo objects are sorted,first come closest hits
			HitInfo@ hi=	hitInfos[i];
			CBlob@ b=	hi.blob;
			if(b !is null) { //blob 
				print("trying to grab an enemy named "+b.getName());
				if(b.getName()!="knight" || b.hasTag("ignore sword") || !canHit(this,b) || juggernaut_has_hit_actor(this,b)){
					continue;
				}
				juggernaut_add_actor_limit(this,b);
				Vec2f velocity=	b.getPosition()-pos;
				//this.server_Hit(b,hi.hitpos,velocity,damage,type,true);  // server_Hit() is server-side only
				CBitStream stream;
				stream.write_u16(b.getNetworkID()); //victim's blob id
				stream.write_u8(0); //fatality id
				stream.write_bool(this.isFacingLeft());
				//stream.write_f32(100.0f); fatality length
				uint8 commandId=this.getCommandID("fatality");
				/*int playerCount=getPlayerCount();
				for(uint j=0;j<playerCount;j++){
					CPlayer@ player=getPlayer(j);
					this.server_SendCommandToPlayer(commandId,stream,player);
				}*/
				this.SendCommand(commandId,stream);
				//b.Damage(b.getInitialHealth()*2,this);
				this.server_Hit(b,hi.hitpos,velocity,b.getInitialHealth()*2,HittersNew::suicide,false);
				break;
			}
		}
	}
}

//a little push forward

void pushForward(CBlob@ this,f32 normalForce,f32 pushingForce,f32 verticalForce)
{
	f32 facing_sign=	this.isFacingLeft() ? -1.0f : 1.0f ;
	bool pushing_in_facing_direction =
	(facing_sign < 0.0f && this.isKeyPressed(key_left)) ||
	(facing_sign > 0.0f && this.isKeyPressed(key_right));
	f32 force=	normalForce;

	if(pushing_in_facing_direction)
	{
		force=	pushingForce;
	}

	this.AddForce(Vec2f(force * facing_sign ,verticalForce));
}

//bomb management

bool hasItem(CBlob@ this,const string &in name)
{
	CBitStream reqs,missing;
	AddRequirement(reqs,"blob",name,"Bombs",1);
	CInventory@ inv=	this.getInventory();

	if(inv !is null)
	{
		return hasRequirements(inv,reqs,missing);
	}
	else
	{
		warn("our inventory was null! JuggernautLogic.as");
	}

	return false;
}

void TakeItem(CBlob@ this,const string &in name)
{
	CBlob@ carried=	this.getCarriedBlob();
	if(carried !is null)
	{
		if(carried.getName() == name)
		{
			carried.server_Die();
			return;
		}
	}

	CBitStream reqs,missing;
	AddRequirement(reqs,"blob",name,"Bombs",1);
	CInventory@ inv=	this.getInventory();

	if(inv !is null)
	{
		if(hasRequirements(inv,reqs,missing))
		{
			server_TakeRequirements(inv,reqs);
		}
		else
		{
			warn("took a bomb even though we dont have one! JuggernautLogic.as");
		}
	}
	else
	{
		warn("our inventory was null! JuggernautLogic.as");
	}
}

void onHitBlob(CBlob@ this,Vec2f worldPoint,Vec2f velocity,f32 damage,CBlob@ hitBlob,u8 customData)
{
	
}



// bomb pick menu

void onCreateInventoryMenu(CBlob@ this,CBlob@ forBlob,CGridMenu @gridmenu)
{
	if(bombTypeNames.length == 0)
	{
		return;
	}

	this.ClearGridMenusExceptInventory();
	Vec2f pos(gridmenu.getUpperLeftPosition().x + 0.5f *(gridmenu.getLowerRightPosition().x - gridmenu.getUpperLeftPosition().x),
	          gridmenu.getUpperLeftPosition().y - 32 * 1 - 2 * 24);
	CGridMenu@ menu=	CreateGridMenu(pos,this,Vec2f(bombTypeNames.length,2),"Current bomb");
	u8 weaponSel=	this.get_u8("bomb type");

	if(menu !is null)
	{
		menu.deleteAfterClick=	false;

		for(uint i=	0; i < bombTypeNames.length; i++)
		{
			string matname=	bombTypeNames[i];
			CGridButton @button=	menu.AddButton(bombIcons[i],bombNames[i],this.getCommandID("pick " + matname));

			if(button !is null)
			{
				bool enabled=	this.getBlobCount(bombTypeNames[i]) > 0;
				button.SetEnabled(enabled);
				button.selectOneOnClick=	true;
				if(weaponSel == i)
				{
					button.SetSelected(1);
				}
			}
		}
	}
}


void onAttach(CBlob@ this,CBlob@ attached,AttachmentPoint @attachedPoint)
{
	for(uint i=	0; i < bombTypeNames.length; i++)
	{
		if(attached.getName() == bombTypeNames[i])
		{
			this.set_u8("bomb type",i);
			break;
		}
	}
}

void onAddToInventory(CBlob@ this,CBlob@ blob)
{
	const string itemname=	blob.getName();
	if(this.isMyPlayer() && this.getInventory().getItemsCount() > 1)
	{
		for(uint j=	1; j < bombTypeNames.length; j++)
		{
			if(itemname == bombTypeNames[j])
			{
				SetHelp(this,"help inventory","juggernaut","$Help_Bomb1$$Swap$$Help_Bomb2$         $KEY_TAP$$KEY_F$","",2);
				break;
			}
		}
	}

	if(this.getInventory().getItemsCount() == 0 || itemname == "mat_bombs")
	{
		for(uint j=	0; j < bombTypeNames.length; j++)
		{
			if(itemname == bombTypeNames[j])
			{
				this.set_u8("bomb type",j);
				return;
			}
		}
	}
}

void SetFirstAvailableBomb(CBlob@ this)
{
	u8 type=	255;
	if(this.exists("bomb type"))
		type=	this.get_u8("bomb type");

	CInventory@ inv=	this.getInventory();
	if(inv is null){
		return;
	}

	bool typeReal=	(uint(type) < bombTypeNames.length);
	if(typeReal && inv.getItem(bombTypeNames[type]) !is null)
		return;

	for(int i=	0; i < inv.getItemsCount(); i++)
	{
		const string itemname=	inv.getItem(i).getName();
		for(uint j=	0; j < bombTypeNames.length; j++)
		{
			if(itemname == bombTypeNames[j])
			{
				type=	j;
				break;
			}
		}

		if(type != 255)
			break;
	}

	this.set_u8("bomb type",type);
}

// Blame Fuzzle.
bool canHit(CBlob@ this,CBlob@ b)
{
	if(b.hasTag("invincible")){
		return false;
	}

	// Don't hit temp blobs and items carried by teammates.
	if(b.isAttached())
	{
		CBlob@ carrier=	b.getCarriedBlob();

		if(carrier !is null){
			if(carrier.hasTag("player") && (this.getTeamNum()==carrier.getTeamNum() || b.hasTag("temp blob"))) {
				return false;
			}
		}
	}

	if(b.hasTag("dead"))
		return true;

	return b.getTeamNum() != this.getTeamNum();

}
