
#include "Hitters.as";
#include "Knocked.as";
#include "ThrowCommon.as";
#include "RunnerCommon.as";
#include "GrappleCommon.as";
#include "HumanoidCommon.as";
#include "HumanoidFistCommon.as";
#include "EquipCommon.as";
#include "EquipAnim.as";
#include "HumanoidAnimCommon.as";
#include "FireCommon.as";
#include "Ally.as";
#include "AbilityCommon.as"
#include "Abilities.as"

///Tools and weapons
#include "PoleCommon.as";
#include "PickCommon.as";
#include "AxeCommon.as";
#include "PickAxeCommon.as";
#include "BowCommon.as";
#include "StabberCommon.as";
#include "SwordCommon.as";
#include "GunCommon.as";
#include "ShieldingCommon.as";
#include "SelfHandleToolCommon.as";

void onInit(CBlob@ this)
{
	this.set_f32("gib health", -3.0f);
	
	this.Tag("player");
	this.Tag("soul");
	
	this.push("names to activate", "keg");
	this.push("names to activate", "bomb");
	
	this.set_string("last_hurter","");

	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
	shape.getConsts().net_threshold_multiplier = 0.5f;
	
	///Force reload
	this.addCommandID("force_reload");
	this.addCommandID("manual_sync");

	///////Equipment
	this.addCommandID("equip_head");
	this.addCommandID("equip_torso");
	this.addCommandID("equip_legs");
	this.addCommandID("equip_main_arm");
	this.addCommandID("equip_sub_arm");
	
	this.addCommandID("equip_back");
	this.addCommandID("equip_belt");

	//Equipment drawback
	this.set_s16("main_drawback",0);
	this.set_s16("sub_drawback",0);
	
	//Grapple
	this.set_Vec2f("grapple_offset",Vec2f(0,0));
	this.addCommandID(grapple_sync_cmd);
	GrappleInfo grapple;
	this.set("GrappleInfo", @grapple);
	
	//Bow
	this.set_u16("bowcharge",0);
	this.getSprite().SetEmitSound("Entities/Characters/Archer/BowPull.ogg");
	
	///Food
	this.addCommandID("eat_held");
	this.set_u8("food_starch",50);
	this.set_u8("food_meat",50);
	this.set_u8("food_plant",50);
	
	//Unique stuff
	this.set_bool("male",true);
	this.set_u16("head",30);
	this.set_u16("create_time",getGameTime());
	
	this.set_string("player_name","Henry"+XORRandom(10000));
	
	//Pregnancy
	//this.Tag("pregnant");
	this.set_u16("arrival_date",getGameTime());
	this.set_string("partner",""); //Watch people get triggered cause they can't be sluts
	
	///Clothes
	this.set_u8("cloth_colour",XORRandom(8));
	this.addCommandID("set_ally");
	this.addCommandID("set_enemy");
	this.addCommandID("set_neutral");
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if(player !is null)
	{
		player.SetScoreboardVars("ScoreboardIcons.png", 1, Vec2f(16, 16));
	}
}

void onTick(CBlob@ this)
{

	this.set_u8("main_implement", 0);
	this.set_u8("sub_implement", 0);

	this.Untag("draw_cursor");
	this.set_u16("picking_target",0);
	
	int gameTime = getGameTime();
	int TimeSinceCreate = gameTime-this.get_u16("create_time");
	bool serverSide = getNet().isServer();
	bool clientSide = getNet().isClient();

	if(this.isInInventory())return;
	const bool ismyplayer = this.isMyPlayer();

	CPlayer @player = this.getPlayer();
	
	if(player !is null){
		this.set_string("player_name",player.getUsername());
		
		/*
		if(serverSide){
			this.set_bool("male",player.getSex() == 0);
			this.set_u16("head",player.getHead());
			
			if(TimeSinceCreate == 60){
				this.Sync("male",true);
				this.Sync("head",true);
			}
		}
		if(clientSide){
			if(TimeSinceCreate < 120){
				this.setHeadNum(this.get_u16("head"));
				if(this.get_bool("male"))this.setSexNum(0);
				else this.setSexNum(1);
			}
		}*/
		
		if(getGameTime() % 180 == 59)this.setSexNum(player.getSex());
	}
	
	
	if(getGameTime() % 61 == 0){
		if(serverSide){
			if(this.getBrain() !is null){
				if(this.get_s16("life_amount") <= 0 && this.get_s16("death_amount") <= 0)this.getBrain().server_SetActive(false);
				else if(this.getBrain().isActive() != (player is null))this.getBrain().server_SetActive(player is null);
			}
		}
	}
	
	
	GrappleInfo@ grapple;
	if (!this.get("GrappleInfo", @grapple))
	{
		return;
	}
	
	if(this.hasTag("soul"))handleDeath(this);
	
	///////////////Ghostssssssss
	
	this.getShape().SetGravityScale(1.0f);
	if(this.isOnLadder())this.getShape().SetGravityScale(0.0f);
	
	if(this.get_s8("torso_type") == BodyType::Wraith)this.getShape().SetGravityScale(this.getShape().getGravityScale()*0.5f);
	if(this.get_s8("torso_type") == BodyType::Ghost){
	
		this.getShape().getConsts().mapCollisions = false;
	
		this.getShape().SetGravityScale(this.getShape().getGravityScale()*0.0f);
	
		if(this.getPosition().y > getMap().tilemapheight*8-32)this.setVelocity(Vec2f(this.getVelocity().x,-2));
		
		CInventory @inv = this.getInventory();
		for(int i = 0; i < inv.getItemsCount();i++)
		{
			CBlob @item = inv.getItem(i);
			if(item !is null){
				if(!item.hasTag("death_infused"))this.server_PutOutInventory(item);
			}
		}
	} else this.getShape().getConsts().mapCollisions = true;
	
	////////////
	
	if(isConscious(this))this.getShape().setFriction(0.07f);
	else this.getShape().setFriction(1.0f);
	
	//////////////////////////////////Pregnancy code
	//This is gonna take a lot of willpower to write
	
	if(this.hasTag("pregnant")){
		if(this.get_u16("arrival_date") < gameTime){
			this.Untag("pregnant");
			this.DropCarried();
			if(serverSide){
				SetKnocked(this,300,true);
				
				CBlob @baby = server_CreateBlob("baby",this.getTeamNum(),this.getPosition());
				this.server_Pickup(baby);

				int Head = this.get_s8("egg_head_type");
				int Torso = this.get_s8("egg_torso_type");
				int MArm = this.get_s8("egg_main_arm_type");
				int SArm = this.get_s8("egg_sub_arm_type");
				int FLeg = this.get_s8("egg_front_leg_type");
				int BLeg = this.get_s8("egg_back_leg_type");
				
				if(XORRandom(2) == 0)Head = this.get_s8("sperm_head_type");
				if(XORRandom(2) == 0)Torso = this.get_s8("sperm_torso_type");
				if(XORRandom(2) == 0)MArm = this.get_s8("sperm_main_arm_type");
				if(XORRandom(2) == 0)SArm = this.get_s8("sperm_sub_arm_type");
				if(XORRandom(2) == 0)FLeg = this.get_s8("sperm_front_leg_type");
				if(XORRandom(2) == 0)BLeg = this.get_s8("sperm_back_leg_type");
				
				baby.set_s8("head_type",Head);
				baby.set_s8("torso_type",Torso);
				baby.set_s8("main_arm_type",MArm);
				baby.set_s8("sub_arm_type",SArm);
				baby.set_s8("front_leg_type",FLeg);
				baby.set_s8("back_leg_type",BLeg);
				
				baby.Sync("head_type",true);
				baby.Sync("torso_type",true);
				baby.Sync("main_arm_type",true);
				baby.Sync("sub_arm_type",true);
				baby.Sync("front_leg_type",true);
				baby.Sync("back_leg_type",true);
			}
		}
	}
	
	
	//////////////////////////////////Clientstuff
	
	if(clientSide){
		if(this.hasTag("reload sprites")){
			ReloadEquipment(this.getSprite(),this);
			this.Untag("reload sprites");
		}
		
		if(ismyplayer){
		
			f32 torsoHurt = this.get_f32("torso_hit");
			f32 mainArmHurt = this.get_f32("main_arm_hit");
			f32 subArmHurt = this.get_f32("sub_arm_hit");
			f32 frontLegHurt = this.get_f32("front_leg_hit");
			f32 backLegHurt = this.get_f32("back_leg_hit");
			
			if(torsoHurt > 0){
				torsoHurt -= 0.02;
				if(torsoHurt < 0.1)torsoHurt = 0;
				this.set_f32("torso_hit",torsoHurt);
			}
			if(mainArmHurt > 0){
				mainArmHurt -= 0.02;
				if(mainArmHurt < 0.1)mainArmHurt = 0;
				this.set_f32("main_arm_hit",mainArmHurt);
			}
			if(subArmHurt > 0){
				subArmHurt -= 0.02;
				if(subArmHurt < 0.1)subArmHurt = 0;
				this.set_f32("sub_arm_hit",subArmHurt);
			}
			if(frontLegHurt > 0){
				frontLegHurt -= 0.02;
				if(frontLegHurt < 0.1)frontLegHurt = 0;
				this.set_f32("front_leg_hit",frontLegHurt);
			}
			if(backLegHurt > 0){
				backLegHurt -= 0.02;
				if(backLegHurt < 0.1)backLegHurt = 0;
				this.set_f32("back_leg_hit",backLegHurt);
			}

			if(this.isKeyJustPressed(key_action3))
			{
				if(this.getCarriedBlob() !is null){
					if(!this.getCarriedBlob().hasTag("temp blob"))client_SendThrowOrActivateCommand(this);
				}
			}
		}
	}
	
	
	///Sanity checks cause the client is an idiot and somehow can't keep track of data properly
	if(serverSide){
		
		CBlob@[] blobs;
		getBlobsByName("humanoid", blobs);
		
		int seperation = 11*blobs.length;
		
		int checker = (gameTime+(this.getNetworkID()*71))%(seperation*6);

		if(checker == seperation * 0)server_ManualSync(this,"main_arm");
		if(checker == seperation * 2)server_ManualSync(this,"sub_arm");
		if(checker == seperation * 3)server_ManualSync(this,"front_leg");
		if(checker == seperation * 4)server_ManualSync(this,"back_leg");
		if(checker == seperation * 5)server_ManualSync(this,"torso");
	}

	
	//////////////////////////////Load items
	
	CBlob @MainItem = getEquippedBlob(this,"main_arm");
	CBlob @SubItem = getEquippedBlob(this,"sub_arm");
	CBlob @LegsItem = getEquippedBlob(this,"legs");
	CBlob @TorsoItem = getEquippedBlob(this,"torso");
	CBlob @HeadItem = getEquippedBlob(this,"head");

	//////////////////////////////////Movement
	RunnerMoveVars@ moveVars;
	if (!this.get("moveVars", @moveVars))
	{
		return;
	}
	
	if(TimeSinceCreate % 30 == 0){
	
		if(!this.hasTag("does_not_eat")){
		
			u16 Meat = this.get_u8("food_meat");
			u16 Plant = this.get_u8("food_plant");
			u16 food_level = Maths::Min(Meat,Plant);
		
			if(food_level >= 60 && food_level <= 80){
				moveVars.walkFactor *= 1.5; //Major Food speed benefit
			}
			
			if(food_level >= 40){
				moveVars.walkFactor *= 1.2; //Food speed benefit
			}
			
			if(food_level < 20){
				moveVars.walkFactor *= 0.7; //Food speed Slow
			}
		
		} else {
			moveVars.walkFactor *= 1.0;
		}
		
		if(this.hasTag("pregnant"))moveVars.walkFactor *= 0.5; //Sigh
		
		moveVars.jumpFactor *= getJumpMulti(this);
		moveVars.walkFactor *= getWalkSpeed(this);
		
		moveVars.swimforce = 40.0f;
		moveVars.swimforce *= getWalkSpeed(this);
		
		if(MainItem !is null){
			f32 speed = MainItem.get_f32("speed_modifier");
			if(speed > 0){
				moveVars.walkFactor *= speed;
				moveVars.swimforce *= speed;
			}
		}
		if(SubItem !is null){
			f32 speed = SubItem.get_f32("speed_modifier");
			if(speed > 0){
				moveVars.walkFactor *= speed;
				moveVars.swimforce *= speed;
			}
		}
		if(LegsItem !is null){
			f32 speed = LegsItem.get_f32("speed_modifier");
			if(speed > 0){
				moveVars.walkFactor *= speed;
				moveVars.swimforce -= (2.0f-speed)*14.0f;
			}
		}
		if(TorsoItem !is null){
			f32 speed = TorsoItem.get_f32("speed_modifier");
			if(speed > 0){
				moveVars.walkFactor *= speed;
				moveVars.swimforce -= (2.0f-speed)*14.0f;
			}
		}
		if(HeadItem !is null){
			f32 speed = HeadItem.get_f32("speed_modifier");
			if(speed > 0){
				moveVars.walkFactor *= speed;
				moveVars.swimforce *= speed;
			}
		}

		moveVars.swimspeed = 2.0f*(moveVars.swimforce/40.0f);
		
		CBlob @BackItem = getEquippedBlob(this,"back");
		bool wings = false;
		if(BackItem !is null && BackItem.hasTag("wings"))wings = true;
		
		if((this.get_s8("front_leg_type") == 1 && this.get_s8("back_leg_type") == 1 && this.hasTag("ghost")) || wings)this.Tag("flying");
		else this.Untag("flying");
		
		this.set_f32("move_speed_cache",moveVars.walkFactor);
		this.set_f32("jump_cache",moveVars.jumpFactor);
		this.set_f32("swim_speed_cache",moveVars.swimforce);
		this.set_f32("swim_force_cache",moveVars.swimspeed);

	} else {
		moveVars.walkFactor = this.get_f32("move_speed_cache");
		moveVars.jumpFactor = this.get_f32("jump_cache");
		
		if(this.isInWater()){
			moveVars.swimforce = this.get_f32("swim_speed_cache");
			moveVars.swimspeed = this.get_f32("swim_force_cache");
		}
	}

	//////////////////////////////////Get controls
	bool Action1 = this.isKeyPressed(key_action1) && bodyPartFunctioning(this,"main_arm");
	bool Action2 = this.isKeyPressed(key_action2) && bodyPartFunctioning(this,"sub_arm") && (!Action1 || !isTwoHanded(MainItem));
	if(isTwoHanded(SubItem))Action2 = Action2 && !Action1;

	bool LyingDown = !isConscious(this) || this.isAttachedToPoint("BED");
	
	if((ismyplayer && getHUD().hasMenus()) || LyingDown || getKnocked(this) > 0){
		Action1 = false;
		Action2 = false;
		grapple.grappling = false;
	}
	
	if(this.getCarriedBlob() !is null){
		if(this.getCarriedBlob().hasTag("temp blob")){
			Action1 = false;
		}
	}
	
	if(this.get_TileType("buildtile") != 0){
		Action1 = false;
	}
	
	if(armCanGrapple(this,"main_arm") || armCanGrapple(this,"sub_arm"))this.Untag("no hands");
	else {
		this.Tag("no hands");
		if(this.getAttachments().getAttachmentPoint("PICKUP", true).getOccupied() !is null){
			if(serverSide)this.server_DetachFrom(this.getAttachments().getAttachmentPoint("PICKUP", true).getOccupied());
		}
	}
	
	
	
	//////////////////////////Manage equipment
	int MainHandType = 0;
	int SubHandType = 0;
	
	if(MainItem !is null){
		MainHandType = MainItem.get_u8("equip_type");
	}
	if(SubItem !is null){
		SubHandType = SubItem.get_u8("equip_type");
	}
	
	switch(MainHandType){
		case 0: ManageFist(this,Action1,"main"); break;
		case 1: ManagePole(this, MainItem, Action1,"main"); break;
		case 2: ManagePick(this, MainItem, Action1,"main"); break;
		case 3: ManageSword(this, MainItem, Action1,"main"); break;
		case 4: ManageBow(this,Action1); break;
		case 5: ManageShield(this, MainItem, Action1,"main"); break;
		case 6: ManageGrapple(this, grapple,this.isKeyPressed(key_action1),this.isKeyJustPressed(key_action1)); break;
		case 7: ManageAxe(this, MainItem, Action1,"main"); break;
		case 8: ManageStabber(this, MainItem, Action1,"main"); break;
		case 9: ManagePickAxe(this, MainItem, Action1,"main"); break;
		case 10: ManageGun(this, MainItem, Action1,"main"); break;
		case 11: ManageTool(this, MainItem, Action1,"main"); break;
	}
	
	switch(SubHandType){
		case 0: ManageFist(this,Action2,"sub"); break;
		case 1: ManagePole(this, SubItem, Action2,"sub"); break;
		case 2: ManagePick(this, SubItem, Action2,"sub"); break;
		case 3: ManageSword(this, SubItem, Action2,"sub"); break;
		case 4: ManageBow(this,Action2); break;
		case 5: ManageShield(this, SubItem, Action2,"sub"); break;
		case 6: ManageGrapple(this, grapple,this.isKeyPressed(key_action2),this.isKeyJustPressed(key_action2)); break;
		case 7: ManageAxe(this, SubItem, Action2,"sub"); break;
		case 8: ManageStabber(this, SubItem, Action2,"sub"); break;
		case 9: ManagePickAxe(this, SubItem, Action2,"sub"); break;
		case 10: ManageGun(this, SubItem, Action2,"sub"); break;
		case 11: ManageTool(this, SubItem, Action2,"sub"); break;
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{

	bool HitEffects = true;
	SColor ScreenFlash = SColor(90, 120, 0, 0);

	//////////////////////////Special case for light heal, restores body. Todo: damages evil
	if(customData == Hitters::heal_light){
		bool heals = true;
		
		if(this.get_s16("dark_amount") > 0){
			if(this.hasTag("dark_ability"))heals = false;
			
			damage = Maths::Min(damage,this.get_s16("dark_amount"));
			
			this.sub_s16("dark_amount",Maths::Min(damage*10,this.get_s16("dark_amount")));
		}
		
		if(this.get_s16("blood_amount") > 100){
			heals = false;
			
			damage = Maths::Min(damage,(this.get_s16("blood_amount")-100));
			
			this.sub_s16("blood_amount",Maths::Min(damage*10,this.get_s16("blood_amount")-100));
		}
		
		int life = this.get_s16("life_amount");
		int death = this.get_s16("death_amount");
		int life_damage = 0;
		for(int i = 0; i < damage*10;i++){
			if(death > 0){
				if(life < 100 && life < death)life++;
				death--;
				life_damage += 1;
			}
		}
		this.set_s16("death_amount", death);
		this.set_s16("life_amount", life);
		
		if(!this.exists("light_damage"))this.set_f32("light_damage",0.01f*damage);
		else {
			this.add_f32("light_damage",0.01f*damage);
		}
		
		if(this.get_f32("light_damage") >= 10.0f){
			if(this.get_u8("eyes") > 0){
				this.sub_u8("eyes",1);
				this.add_u8("light_eyes",1);
			}
		}
		
		if(heals){
			f32 MaxHeal = BodyMaxHp(this)-BodyCurrentHp(this)-this.get_f32("light_damage");
			HealBody(this,Maths::Max(Maths::Min(MaxHeal,damage),0),true);
			damage *= 0.01f;
		} else {
			damage *= 0.9f;
		}
		
		if(life_damage > 0){
			damage = life_damage*0.1f;
			customData = Hitters::life_flame;
		} else
			HitEffects = false;
		
		ScreenFlash = SColor(90,255,255,200);
	}


	//////////////////////////Special case for ethereal echo, reduces ectoplasma rather than dealing damage.

	if(customData == Hitters::ethereal_echo){
		if(this.get_s16("death_amount")-damage > 0)this.sub_s16("death_amount",damage);
		else this.set_s16("death_amount", 0);
		
		return 0;
	}

	//////////////////////////Our torso doesn't 'exist' which means we're either uninitialised, bugged or a ghost.

	if(!bodyPartExists(this,"torso"))damage = 0;

	//////////////////////////Get our killer
	
	if(this !is hitterBlob){
		if(hitterBlob.getDamageOwnerPlayer() !is null){
			this.set_string("last_hurter",hitterBlob.getDamageOwnerPlayer().getUsername());
		} else {
			if(hitterBlob.getPlayer() !is null)this.set_string("last_hurter",hitterBlob.getPlayer().getUsername());
		}
	}
	//////////////////////////Shield

	Vec2f vec = worldPoint - this.getPosition();
	f32 angle = vec.Angle();
	
	f32 aimangle = getAimAngle(this);
	
	if((this.hasTag("main_shielding") || this.hasTag("sub_shielding")) && this.get_u8("knocked") <= 0){
		if((aimangle+45 > angle && aimangle-45 < angle) || aimangle-45+360 < angle || aimangle+45-360 < angle){
			if(damage >= 5.0f)SetKnocked(this,20,true);
			
			damage = 0;
			Vec2f velr = -velocity;
			velr += Vec2f(XORRandom(3)-1,XORRandom(3)-1);
			ParticlePixel(worldPoint, velr, SColor(255, 255, 255, 0), true);
			this.getSprite().PlayRandomSound("ShieldHit.ogg");
		}
	}
	
	///////////////////////////Fire users are immune to fire, ye
	
	if(this.hasTag("fire_ability") && !this.hasTag("pyromaniac") && (customData == Hitters::burn || customData == Hitters::fire))return 0;

	//////////////////////////Hitting
	
	bool TopHit = (angle > 90-30) && (angle < 90+30);
	bool BotHit = (angle > 225) && (angle < 315);
	bool MidHit = !TopHit && !BotHit;
	bool FallDamage = false;
	bool Explosion = false;
	bool Fire = false;
	bool RandomLimb = false;
	bool SpreadLimb = false;
	
	if(customData == Hitters::fall){
		TopHit = false;
		BotHit = false;
		MidHit = false;
		FallDamage = true;
	}
	
	if (customData == Hitters::burn || customData == Hitters::self_burn)
	{
		TopHit = false;
		BotHit = false;
		MidHit = false;
		Fire = true;
		
		this.Tag("fire_knowledge");
		
		damage = 0.25f;
	}
	
	if (customData == Hitters::keg || customData == Hitters::bomb || customData == Hitters::mine)
	{
		TopHit = false;
		BotHit = false;
		MidHit = false;
		Explosion = true;
	}
	
	if (customData == Hitters::drown)
	{
		TopHit = false;
		BotHit = false;
		MidHit = false;
		
		bool Torso = bodyPartNeedsBreath(this,"torso") && bodyPartFunctioning(this, "torso");
		bool Main_arm = bodyPartNeedsBreath(this,"main_arm") && bodyPartFunctioning(this, "main_arm");
		bool Sub_arm = bodyPartNeedsBreath(this,"sub_arm") && bodyPartFunctioning(this, "sub_arm");
		bool Front_leg = bodyPartNeedsBreath(this,"front_leg") && bodyPartFunctioning(this, "front_leg");
		bool Back_leg = bodyPartNeedsBreath(this,"back_leg") && bodyPartFunctioning(this, "back_leg");
		
		if(Torso)hitBodyPart(this, "torso", damage, customData);
		if(Main_arm)hitBodyPart(this, "main_arm", damage, customData);
		if(Sub_arm)hitBodyPart(this, "sub_arm", damage, customData);
		if(Front_leg)hitBodyPart(this, "front_leg", damage, customData);
		if(Back_leg)hitBodyPart(this, "back_leg", damage, customData);
		
		if(!Torso && !Main_arm && !Sub_arm && !Front_leg && !Back_leg)
		damage = 0;
	}
	
	if (customData == Hitters::suddengib || customData == Hitters::bullet)
	{
		TopHit = false;
		BotHit = false;
		MidHit = false;
		
		RandomLimb = true;
	}
	
	if (customData == Hitters::life_flame || customData == Hitters::heal_light)
	{
		TopHit = false;
		BotHit = false;
		MidHit = false;
		
		SpreadLimb = true;
	}
	
	string BodyPartHit = "torso";
	
	if(TopHit){ //Headshot basically, no insta kills, but double damage and only defended by helmet.
		CBlob @item = getEquippedBlob(this,"head");
		if(item !is null){
			damage = calculateDamage(damage,item.get_u8("defense"),customData);
		} else {
			damage = calculateDamage(damage,0,customData);
		}
		
		damage *= 2.0f;
		
		hitBodyPart(this, BodyPartHit, damage, customData);
	}
	
	if(MidHit){ //The default hit, can hit arms+torso, get's defense from chest armour.
		
		CBlob @item = getEquippedBlob(this,"torso");
		if(item !is null){
			damage = calculateDamage(damage,item.get_u8("defense"),customData);
		} else {
			damage = calculateDamage(damage,0,customData);
		}
		
		int block = XORRandom(100); //The higher the block the better
		
		if(customData == Hitters::arrow)block = 0; //One does not simply 'block' arrows.
		
		if(block > 75){ //A good block means you block with your sub arm
			
			if(canHitLimb(this,"sub_arm"))BodyPartHit = "sub_arm"; //If we have a sub arm, block
			else if(canHitLimb(this,"main_arm"))BodyPartHit = "main_arm"; //Else try blocking with main
		
		} else
		if(block > 50){ //A bad block means you block with your main arm
			if(canHitLimb(this,"main_arm"))BodyPartHit = "main_arm";
		}
		
		hitBodyPart(this, BodyPartHit, damage, customData);
	}
	
	if(BotHit){ //A low blow, hits legs unless they no longer exist, get's defense from leg wear. Idea: Add gelding blows
		
		CBlob @item = getEquippedBlob(this,"legs");
		if(item !is null){
			damage = calculateDamage(damage,item.get_u8("defense"),customData);
		} else {
			damage = calculateDamage(damage,0,customData);
		}
		
		int block = XORRandom(100);
		
		if(block > 50){ //Try hit front leg
			if(canHitLimb(this,"front_leg"))BodyPartHit = "front_leg";
			else if(canHitLimb(this,"back_leg"))BodyPartHit = "back_leg";
		} else { //Try hit back leg
			if(canHitLimb(this,"back_leg"))BodyPartHit = "back_leg";
			else if(canHitLimb(this,"front_leg"))BodyPartHit = "front_leg";
		}
		
		hitBodyPart(this, BodyPartHit, damage, customData);
	}
	
	if(FallDamage){ //Crack those suckers
		if(canHitLimb(this,"front_leg"))BodyPartHit = "front_leg";
		hitBodyPart(this, BodyPartHit, damage, customData);
		if(canHitLimb(this,"back_leg"))BodyPartHit = "back_leg";
		hitBodyPart(this, BodyPartHit, damage, customData);
		
		if(!canHitLimb(this,"back_leg") && !canHitLimb(this,"front_leg")){
			BodyPartHit = "torso";
			hitBodyPart(this, BodyPartHit, damage, customData);
		}
	}
	
	if(Explosion){ //Hit every body part
		
		
		f32 MArmDamage = damage;
		f32 SArmDamage = damage;
		f32 FLegDamage = damage;
		f32 BLegDamage = damage;
		
		{
			CBlob @item = getEquippedBlob(this,"head");
			if(item !is null){
				damage = calculateDamage(damage,item.get_u8("defense"),customData);
			} else {
				damage = calculateDamage(damage,0,customData);
			}
		}
		
		{
			CBlob @item = getEquippedBlob(this,"torso");
			if(item !is null){
				MArmDamage = calculateDamage(MArmDamage,item.get_u8("defense"),customData);
				SArmDamage = calculateDamage(SArmDamage,item.get_u8("defense"),customData);
				damage = calculateDamage(damage,item.get_u8("defense"),customData);
			} else {
				MArmDamage = calculateDamage(MArmDamage,0,customData);
				SArmDamage = calculateDamage(SArmDamage,0,customData);
				damage = calculateDamage(damage,0,customData);
			}
		}
		{
			CBlob @item = getEquippedBlob(this,"legs");
			if(item !is null){
				FLegDamage = calculateDamage(FLegDamage,item.get_u8("defense"),customData);
				BLegDamage = calculateDamage(BLegDamage,item.get_u8("defense"),customData);
			} else {
				FLegDamage = calculateDamage(FLegDamage,0,customData);
				BLegDamage = calculateDamage(BLegDamage,0,customData);
			}
		}
		
		
		int Hit = XORRandom(4);
		if(Hit == 0)MArmDamage *= 2;
		else if(Hit == 1)SArmDamage *= 2;
		else if(Hit == 2)FLegDamage *= 2;
		else if(Hit == 3)BLegDamage *= 2;

		if(canHitLimb(this,"main_arm"))hitBodyPart(this, "main_arm", MArmDamage, customData);
		if(canHitLimb(this,"sub_arm"))hitBodyPart(this, "sub_arm", SArmDamage, customData);
		if(canHitLimb(this,"front_leg"))hitBodyPart(this, "front_leg", FLegDamage, customData);
		if(canHitLimb(this,"back_leg"))hitBodyPart(this, "back_leg", BLegDamage, customData);
		if(canHitLimb(this,"torso"))hitBodyPart(this, "torso", damage, customData);
	}
	
	if(Fire){ //Hit every body part
		if(canHitLimb(this,"torso"))hitBodyPart(this, "torso", damage, customData);
		if(canHitLimb(this,"main_arm"))hitBodyPart(this, "main_arm", damage, customData);
		if(canHitLimb(this,"sub_arm"))hitBodyPart(this, "sub_arm", damage, customData);
		if(canHitLimb(this,"front_leg"))hitBodyPart(this, "front_leg", damage, customData);
		if(canHitLimb(this,"back_leg"))hitBodyPart(this, "back_leg", damage, customData);
	}
	
	if(RandomLimb){ //Hit every body part
		switch(XORRandom(5)){
			case 0: {if(canHitLimb(this,"torso"))hitBodyPart(this, "torso", damage, customData);break;}
			case 1: {if(canHitLimb(this,"main_arm"))hitBodyPart(this, "main_arm", damage, customData);break;}
			case 2: {if(canHitLimb(this,"sub_arm"))hitBodyPart(this, "sub_arm", damage, customData);break;}
			case 3: {if(canHitLimb(this,"front_leg"))hitBodyPart(this, "front_leg", damage, customData);break;}
			case 4: {if(canHitLimb(this,"back_leg"))hitBodyPart(this, "back_leg", damage, customData);break;}
		}
	}

	if(SpreadLimb){
		f32 body_parts = 0;
		if(canHitLimb(this,"torso"))body_parts += 1;
		if(canHitLimb(this,"main_arm"))body_parts += 1;
		if(canHitLimb(this,"sub_arm"))body_parts += 1;
		if(canHitLimb(this,"front_leg"))body_parts += 1;
		if(canHitLimb(this,"back_leg"))body_parts += 1;
		
		if(body_parts < 1)body_parts = 1.0f;
		
		f32 percent = damage/BodyCurrentHp(this);
		
		if(canHitLimb(this,"torso"))hitBodyPart(this, "torso", this.get_f32("torso_hp")*percent, customData);
		if(canHitLimb(this,"main_arm"))hitBodyPart(this, "main_arm", this.get_f32("main_arm_hp")*percent, customData);
		if(canHitLimb(this,"sub_arm"))hitBodyPart(this, "sub_arm", this.get_f32("sub_arm_hp")*percent, customData);
		if(canHitLimb(this,"front_leg"))hitBodyPart(this, "front_leg", this.get_f32("front_leg_hp")*percent, customData);
		if(canHitLimb(this,"back_leg"))hitBodyPart(this, "back_leg", this.get_f32("back_leg_hp")*percent, customData);
	}
	
	////////////////////////////Knockback
	f32 scale = 1.0f;

	//scale per hitter
	switch (customData)
	{
		case Hitters::fall:
		case Hitters::drown:
		case Hitters::burn:
		case Hitters::crush:
		case Hitters::spikes:
		case Hitters::arrow:
			scale = 0.0f; break;
			
		case Hitters::bomb:{
			if(damage <= 0)scale = 2.0f; 
			break;
		}

		default: break;
	}

	this.AddForce(velocity * 40.0f * scale * Maths::Log(40.0f));

	
	//////////////////////////Sounds

	if(HitEffects)
	if(customData != Hitters::drown && damage > 0){
		if(isSharp(customData)){
			
			this.getSprite().PlaySound("sharp_hit"+XORRandom(4));
			
		} else
		if(customData == Hitters::suddengib){
			
			this.getSprite().PlaySound("lightup.ogg");
			
		} else 
		if(customData == Hitters::life_flame || customData == Hitters::self_burn){
			
			this.getSprite().PlaySound("fire_burn.ogg");
			
		} else 
		this.getSprite().PlaySound("punch"+XORRandom(3));
	}
	
	///////////////Flesh hit effects
	
	if(HitEffects)
	if (damage > 0.1f && (hitterBlob !is this || customData == Hitters::crush))
	{
		f32 capped_damage = Maths::Min(damage, 6.0f);

		//set this false if we whouldn't show blood effects for this hit
		bool showblood = true;

		//read customdata for hitter
		switch (customData)
		{
			case Hitters::drown:
			case Hitters::burn:
			case Hitters::fire:
			case Hitters::life_flame:
				showblood = false;
				break;

			case Hitters::sword:
			case Hitters::stab:
				Sound::Play("SwordKill", this.getPosition());
				break;

			default:
				if (customData != Hitters::bite)
					Sound::Play("FleshHit.ogg", this.getPosition());
				break;
		}

		worldPoint.y -= this.getRadius() * 0.5f;

		if (showblood)
		{
			if (capped_damage >= 2.0f)
			{
				ParticleBloodSplat(worldPoint, true);
			}

			if (capped_damage > 0.25f)
			{
				for (f32 count = 0.0f ; count < capped_damage; count += 1.5f)
				{
					ParticleBloodSplat(worldPoint + getRandomVelocity(0, 0.75f + capped_damage * 2.0f * XORRandom(2), 360.0f), false);
				}
			}

			if (capped_damage > 0.01f)
			{
				f32 angle = (velocity).Angle();

				for (f32 count = 0.0f ; count < capped_damage + 1.8f; count += 0.3f)
				{
					Vec2f vel = getRandomVelocity(angle, 1.0f + 0.3f * (capped_damage/3.0f) * 0.1f * XORRandom(40), 60.0f);
					vel.y -= 1.5f * capped_damage;
					ParticleBlood(worldPoint, vel * -1.0f, SColor(255, 126, 0, 0));
					ParticleBlood(worldPoint, vel * 1.7f, SColor(255, 126, 0, 0));
				}
			}
		} else {
		
			if(customData == Hitters::life_flame){
				for (f32 count = 0.0f ; count < capped_damage + 0.6f; count += 0.3f){
					CParticle @p = ParticleAnimated("lp.png", this.getPosition()+Vec2f(XORRandom(13)-6,XORRandom(13)-6), this.getVelocity()/10+Vec2f(XORRandom(801)-400,-XORRandom(100))/400, 90.0f, 1.0f, 6, -0.1f, true);
					if(p !is null){
						p.Z = 50.0f;
					}
				}
			}
		
		
		
		}
	}
	
	
	
	
	if (this.isMyPlayer() && damage > 0)
    {
        
		SetScreenFlash(ScreenFlash.getAlpha(),ScreenFlash.getRed(),ScreenFlash.getGreen(),ScreenFlash.getBlue());
        ShakeScreen( 9, 2, this.getPosition() );
    }
	
	return 0;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point)
{
	if(solid && point.y > this.getPosition().y)
	if(this.hasTag("main_shielding") || this.hasTag("sub_shielding")){
		if(this.isKeyPressed(key_up))
		if(getAimAngle(this) > 270-45 && getAimAngle(this) < 270+45){
			
			float UpMulti = getJumpMulti(this);
			float SpeedMulti = getWalkSpeed(this);
			
			if(this.isKeyPressed(key_right) && this.isKeyPressed(key_left))this.setVelocity(Vec2f(0,-3*UpMulti));
			else if(this.isKeyPressed(key_left))this.setVelocity(Vec2f(-5*SpeedMulti,-3*UpMulti));
			else if(this.isKeyPressed(key_right)) this.setVelocity(Vec2f(5*SpeedMulti,-3*UpMulti));
			else this.setVelocity(Vec2f(0,-3));
			
			Vec2f velr = getRandomVelocity(!this.isFacingLeft() ? 70 : 110, 4.3f, 40.0f);
			velr.y = -Maths::Abs(velr.y) + Maths::Abs(velr.x) / 3.0f - 2.0f - float(XORRandom(100)) / 100.0f;
			ParticlePixel(point, velr, SColor(255, 255, 255, 0), true);
			this.getSprite().PlayRandomSound("/Scrape");
		}
	}
}

void onAddToInventory( CBlob@ this, CBlob@ blob ){ //Reject all blobs that aren't equips, we should put them in a bag if we have one
	if(!blob.hasTag("equiptag")){
		if(getNet().isServer()){
			this.server_PutOutInventory(blob);

			putInInventory(this,blob);
		}
		
	}else {
		blob.Untag("equiptag");
		blob.SetDamageOwnerPlayer(this.getPlayer());
	}
}

void onRemoveFromInventory( CBlob@ this, CBlob@ blob ){
	if(blob !is null)
	if(getNet().isServer()){
		this.Tag("reload sprites");
		this.Sync("reload sprites",true);
		
		if(blob.hasTag("head")){
			blob.Untag("head");
			blob.Sync("head",true);
			return;
		}
		if(blob.hasTag("torso")){
			blob.Untag("torso");
			blob.Sync("torso",true);
			return;
		}
		if(blob.hasTag("legs")){
			blob.Untag("legs");
			blob.Sync("legs",true);
			return;
		}
		if(blob.hasTag("main_arm")){
			blob.Untag("main_arm");
			blob.Sync("main_arm",true);
			return;
		}
		if(blob.hasTag("sub_arm")){
			blob.Untag("sub_arm");
			blob.Sync("sub_arm",true);
			return;
		}
		if(blob.hasTag("back")){
			blob.Untag("back");
			blob.Sync("back",true);
			return;
		}
		if(blob.hasTag("belt")){
			blob.Untag("belt");
			blob.Sync("belt",true);
			return;
		}
	}
}

void onCreateInventoryMenu(CBlob@ this, CBlob@ forBlob, CGridMenu @gridmenu)
{
	if(this.getPlayer() !is getLocalPlayer())return;
	
	this.ClearGridMenus();
	
	if(!armCanGrapple(this,"main_arm") && !armCanGrapple(this,"sub_arm"))return;
	
	int BagX = 0;
	
	CInventory @inv = this.getInventory();

	if(inv !is null){
	
		for(int i = 0;i < inv.getItemsCount();i++){
			CBlob @bag = inv.getItem(i);
			if(bag !is null){
				if(bag.getInventory() !is null){
					BagX -= bag.getInventory().getInventorySlots().x*24;
				}
			}
		}
	
		for(int i = 0;i < inv.getItemsCount();i++){
			CBlob @bag = inv.getItem(i);
			if(bag !is null){
				if(bag.getInventory() !is null){
					
					BagX += bag.getInventory().getInventorySlots().x*24;
					
					int Y = bag.getInventory().getInventorySlots().y*24;
					
					bag.CreateInventoryMenu(Vec2f(gridmenu.getUpperLeftPosition().x + 0.5f * (gridmenu.getLowerRightPosition().x - gridmenu.getUpperLeftPosition().x)+BagX,gridmenu.getUpperLeftPosition().y+8+Y));
				
					CGridMenu @ inv = bag.getInventory().getGridMenu();
					inv.deleteAfterClick = true;
					
					BagX += bag.getInventory().getInventorySlots().x*24;
				}
			}
		}
	}
	
	Vec2f pos(gridmenu.getUpperLeftPosition().x + 0.5f * (gridmenu.getLowerRightPosition().x - gridmenu.getUpperLeftPosition().x) - 156.0f,
	          gridmenu.getUpperLeftPosition().y - 32 * 1 - 3 * 24 - 4);
	CGridMenu@ menu = CreateGridMenu(pos, this, Vec2f(3, 3), "Equipment");
	
	this.set_Vec2f("equip_pos",pos);
	
	string HeadImage = "EquipmentGUI.png";
	string TorsoImage = "EquipmentGUI.png";
	string LegsImage = "EquipmentGUI.png";
	string MainArmImage = "EquipmentGUI.png";
	string SubArmImage = "EquipmentGUI.png";
	string BackImage = "EquipmentGUI.png";
	string BeltImage = "EquipmentGUI.png";
	int HeadFrame = 0;
	int TorsoFrame = 1;
	int LegsFrame = 2;
	int MainArmFrame = 3;
	int SubArmFrame = 4;
	int BackFrame = 5;
	int BeltFrame = 8;
	string HeadName = "Equip on Head";
	string TorsoName = "Equip on Body";
	string LegsName = "Equip on Legs";
	string MainArmName = "Equip in Main Hand";
	string SubArmName = "Equip in Sub Hand";
	string BackName = "Equip on Back";
	string BeltName = "Equip on Waist";
	
	if(getEquippedBlob(this,"head") !is null){
		HeadImage = getEquippedBlob(this,"head").getName()+"_icon.png";
		HeadFrame = 0;
		HeadName = getEquippedBlob(this,"head").getInventoryName();
	}
	if(getEquippedBlob(this,"torso") !is null){
		TorsoImage = getEquippedBlob(this,"torso").getName()+"_icon.png";
		TorsoFrame = 0;
		TorsoName = getEquippedBlob(this,"torso").getInventoryName();
	}
	if(getEquippedBlob(this,"legs") !is null){
		LegsImage = getEquippedBlob(this,"legs").getName()+"_icon.png";
		LegsFrame = 0;
		LegsName = getEquippedBlob(this,"legs").getInventoryName();
	}
	if(getEquippedBlob(this,"main_arm") !is null){
		MainArmImage = getEquippedBlob(this,"main_arm").getName()+"_icon.png";
		MainArmFrame = 0;
		MainArmName = getEquippedBlob(this,"main_arm").getInventoryName();
	}
	if(getEquippedBlob(this,"sub_arm") !is null){
		SubArmImage = getEquippedBlob(this,"sub_arm").getName()+"_icon.png";
		SubArmFrame = 0;
		SubArmName = getEquippedBlob(this,"sub_arm").getInventoryName();
	}
	
	if(getEquippedBlob(this,"back") !is null){
		BackImage = getEquippedBlob(this,"back").getName()+"_icon.png";
		BackFrame = 0;
		BackName = getEquippedBlob(this,"back").getInventoryName();
	}

	if(getEquippedBlob(this,"belt") !is null){
		BeltImage = getEquippedBlob(this,"belt").getName()+"_icon.png";
		BeltFrame = 0;
		BeltName = getEquippedBlob(this,"belt").getInventoryName();
	}
	
	if (menu !is null)
	{
		CBitStream params;
		
		int carry_id = 0;
		
		if(this.getCarriedBlob() !is null)carry_id = this.getCarriedBlob().getNetworkID();
		
		params.write_u16(carry_id);
		
		menu.deleteAfterClick = false;

		menu.AddButton(BackImage, BackFrame, BackName, this.getCommandID("equip_back"),params);
		
		menu.AddButton(HeadImage, HeadFrame, HeadName, this.getCommandID("equip_head"),params);
		
		menu.AddButton("EquipmentGUI.png", 9, "", this.getCommandID("equip_head")).SetEnabled(false);
		
		if(!armCanGrapple(this, "main_arm"))MainArmName = "Cannot Equip";
		CGridButton @mainarm = menu.AddButton(MainArmImage, MainArmFrame, MainArmName, this.getCommandID("equip_main_arm"),params);
		if(!armCanGrapple(this, "main_arm")){
			mainarm.SetEnabled(false);
			mainarm.SetHoverText("Your main arm is either injured or incapable of equipping items.");
		}
		
		menu.AddButton(TorsoImage, TorsoFrame, TorsoName, this.getCommandID("equip_torso"),params);
		
		if(!armCanGrapple(this, "sub_arm"))SubArmName = "Cannot Equip";
		CGridButton @subarm = menu.AddButton(SubArmImage, SubArmFrame, SubArmName, this.getCommandID("equip_sub_arm"),params);
		if(!armCanGrapple(this, "sub_arm")){
			subarm.SetEnabled(false);
			mainarm.SetHoverText("Your sub arm is either injured or incapable of equipping items.");
		}
		
		menu.AddButton(BeltImage, BeltFrame, BeltName, this.getCommandID("equip_belt"),params);
		
		menu.AddButton(LegsImage, LegsFrame, LegsName, this.getCommandID("equip_legs"),params);
		
		menu.AddButton("EquipmentGUI.png", 9, "", this.getCommandID("equip_head")).SetEnabled(false);
	}
	
	CGridMenu@ eat = CreateGridMenu(pos+Vec2f(0,-96), this, Vec2f(1, 1), "");
	if(eat !is null)
	{
		eat.SetCaptionEnabled(false);

		string tex = "EatIcon.png";
		string text = "Eat held item";
		
		if(this.getCarriedBlob() !is null)if(this.getCarriedBlob().hasTag("jar")){
			tex = "DrinkIcon.png";
			text = "Drink from jar";
		}
		
		CGridButton @eatbut = eat.AddButton(tex, 0, text, this.getCommandID("eat_held"));
		if(eatbut !is null){
			if(this.getCarriedBlob() is null)eatbut.SetEnabled(false);
			eatbut.SetHoverText("Eat or drinks currently held item\n");
		}
	}
	
	int Players = getPlayersCount();
	
	if(Players > 1){
		CGridMenu@ ally = CreateGridMenu(pos+Vec2f(-200,0), this, Vec2f(5, Players-1), "Alliances");
		
		for(int i = 0;i < Players; i++){
			CPlayer @p = getPlayer(i);
			
			if(p !is null)if(p !is this.getPlayer()){
				
				int enemystatus = checkAlly(this.getTeamNum(),p.getTeamNum());
				
				string statusstring = "Enemies";
				if(enemystatus == 1)statusstring = "Neutral";
				if(enemystatus == 2)statusstring = "Allies";
				
				ally.AddTextButton(p.getUsername()+"\n\n"+statusstring, Vec2f(2,1));
				
				CBitStream params;
				params.write_u8(p.getTeamNum());
				
				CGridButton @but1 = ally.AddButton("AllyFace.png", 0, Vec2f(14,14), "Ally", this.getCommandID("set_ally"), Vec2f(1,1), params);
				CGridButton @but2 = ally.AddButton("AllyFace.png", 1, Vec2f(14,14), "Neutral", this.getCommandID("set_neutral"), Vec2f(1,1), params);
				CGridButton @but3 = ally.AddButton("AllyFace.png", 2, Vec2f(14,14), "Enemy", this.getCommandID("set_enemy"), Vec2f(1,1), params);
				
				int status = checkAllyOneWay(this.getTeamNum(),p.getTeamNum());
				
				if(status == 2)but1.SetSelected(1);
				if(status == 1)but2.SetSelected(1);
				if(status == 0)but3.SetSelected(1);
			}
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("equip_head"))
	{
		CBlob @item = getEquippedBlob(this,"head");
		CBlob @carry = getBlobByNetworkID(params.read_u16());
		
		if(item !is null && getNet().isServer()){
			
			if(item.hasTag("cursed"))return;
			
			this.server_PutOutInventory(item);
			if(this.getCarriedBlob() is null)this.server_Pickup(item);
			item.Untag("head");
			item.Sync("head",true);
			
			this.Tag("reload sprites");
			this.Sync("reload sprites",true);
		}

		if(carry !is null){
			if(carry.getName() == "dye_jar"){
				if(item is null){
					this.set_u8("hair_colour",6+carry.get_s8("contents"));
					if(this.getSprite() !is null)this.getSprite().RemoveSpriteLayer("head");
					if(getNet().isServer()){
						this.Sync("hair_colour",true);
						carry.server_Die();
						this.server_Pickup(server_CreateBlob("jar",0,carry.getPosition()));
					}
				}
			} else
			if(carry.get_u8("equip_slot") == 5){
				if(getNet().isServer()){
					carry.Tag("head");
					carry.Tag("equiptag");
					carry.Sync("head",true);
					
					this.Tag("reload sprites");
					this.Sync("reload sprites",true);
					
					this.server_PutInInventory(carry);
					
					if(item !is null){
						this.server_Pickup(item);
					}
				}
			}
		}
	}
	if (cmd == this.getCommandID("equip_torso"))
	{
		CBlob @item = getEquippedBlob(this,"torso");
		CBlob @carry = getBlobByNetworkID(params.read_u16());
		
		if(item !is null && getNet().isServer()){
			
			if(item.hasTag("cursed"))return;
			
			this.server_PutOutInventory(item);
			if(this.getCarriedBlob() is null)this.server_Pickup(item);
			item.Untag("torso");
			item.Sync("torso",true);
			
			this.Tag("reload sprites");
			this.Sync("reload sprites",true);
		}
		
		if(carry !is null){
			if(carry.get_u8("equip_slot") == 1){
				if(getNet().isServer()){
					carry.Tag("torso");
					carry.Tag("equiptag");
					carry.Sync("torso",true);
					
					this.Tag("reload sprites");
					this.Sync("reload sprites",true);
					
					this.server_PutInInventory(carry);
					
					if(item !is null){
						this.server_Pickup(item);
					}
				}
			}
		}
	}
	if (cmd == this.getCommandID("equip_legs"))
	{
		CBlob @item = getEquippedBlob(this,"legs");
		CBlob @carry = getBlobByNetworkID(params.read_u16());
		
		if(item !is null && getNet().isServer()){
			
			if(item.hasTag("cursed"))return;
			
			this.server_PutOutInventory(item);
			if(this.getCarriedBlob() is null)this.server_Pickup(item);
			item.Untag("legs");
			item.Sync("legs",true);
			
			this.Tag("reload sprites");
			this.Sync("reload sprites",true);
		}
		
		if(carry !is null){
			if(carry.get_u8("equip_slot") == 2){
				if(getNet().isServer()){
					carry.Tag("legs");
					carry.Tag("equiptag");
					carry.Sync("legs",true);
					
					this.Tag("reload sprites");
					this.Sync("reload sprites",true);
					
					this.server_PutInInventory(carry);
					
					if(item !is null){
						this.server_Pickup(item);
					}
				}
			}
		}
	}
	if (cmd == this.getCommandID("equip_main_arm"))
	{
		CBlob @item = getEquippedBlob(this,"main_arm");
		CBlob @carry = getBlobByNetworkID(params.read_u16());
		
		if(item !is null && getNet().isServer()){
			
			if(item.hasTag("cursed"))return;
			
			this.server_PutOutInventory(item);
			if(this.getCarriedBlob() is null)this.server_Pickup(item);
			item.Untag("main_arm");
			item.Sync("main_arm",true);
			
			this.Tag("reload sprites");
			this.Sync("reload sprites",true);
		}
		
		if(carry !is null){
			if(carry.get_u8("equip_slot") == 3){
				if(getNet().isServer()){
					carry.Tag("main_arm");
					carry.Tag("equiptag");
					carry.Sync("main_arm",true);
					
					this.Tag("reload sprites");
					this.Sync("reload sprites",true);
					
					this.server_PutInInventory(carry);
					
					if(item !is null){
						this.server_Pickup(item);
					}
				}
			}
		}
	}
	if (cmd == this.getCommandID("equip_sub_arm"))
	{
		CBlob @item = getEquippedBlob(this,"sub_arm");
		CBlob @carry = getBlobByNetworkID(params.read_u16());
		
		if(item !is null && getNet().isServer()){
			
			if(item.hasTag("cursed"))return;
			
			this.server_PutOutInventory(item);
			if(this.getCarriedBlob() is null)this.server_Pickup(item);
			item.Untag("sub_arm");
			item.Sync("sub_arm",true);
			
			this.Tag("reload sprites");
			this.Sync("reload sprites",true);
		}
		
		if(carry !is null){
			if(carry.get_u8("equip_slot") == 3){
				if(getNet().isServer()){
					carry.Tag("sub_arm");
					carry.Tag("equiptag");
					carry.Sync("sub_arm",true);
					
					this.Tag("reload sprites");
					this.Sync("reload sprites",true);
					
					this.server_PutInInventory(carry);
					
					if(item !is null){
						this.server_Pickup(item);
					}
				}
			}
		}
	}
	if (cmd == this.getCommandID("equip_back"))
	{
		CBlob @item = getEquippedBlob(this,"back");
		CBlob @carry = getBlobByNetworkID(params.read_u16());
		
		if(item !is null && getNet().isServer()){
			
			if(item.hasTag("cursed"))return;
			
			this.server_PutOutInventory(item);
			if(this.getCarriedBlob() is null)this.server_Pickup(item);
			item.Untag("back");
			item.Sync("back",true);
			
			this.Tag("reload sprites");
			this.Sync("reload sprites",true);
		}
		
		if(carry !is null){
			if(carry.get_u8("equip_slot") == 4){
				if(getNet().isServer()){
					carry.Tag("back");
					carry.Tag("equiptag");
					carry.Sync("back",true);
					
					this.Tag("reload sprites");
					this.Sync("reload sprites",true);
					
					this.server_PutInInventory(carry);
					
					if(item !is null){
						this.server_Pickup(item);
					}
				}
			}
		}
	}
	if (cmd == this.getCommandID("equip_belt"))
	{
		CBlob @item = getEquippedBlob(this,"belt");
		CBlob @carry = getBlobByNetworkID(params.read_u16());
		
		if(item !is null && getNet().isServer()){
			
			if(item.hasTag("cursed"))return;
			
			this.server_PutOutInventory(item);
			if(this.getCarriedBlob() is null)this.server_Pickup(item);
			item.Untag("belt");
			item.Sync("belt",true);
			
			this.Tag("reload sprites");
			this.Sync("reload sprites",true);
		}
		
		if(carry !is null){
			if(carry.get_u8("equip_slot") == 6){
				if(getNet().isServer()){
					carry.Tag("belt");
					carry.Tag("equiptag");
					carry.Sync("belt",true);
					
					this.Tag("reload sprites");
					this.Sync("reload sprites",true);
					
					this.server_PutInInventory(carry);
					
					if(item !is null){
						this.server_Pickup(item);
					}
				}
			}
		}
	}
	
	if (cmd == this.getCommandID("eat_held"))
	{
		if(this.getCarriedBlob() !is null){
			CBlob @carry = this.getCarriedBlob();
			if(carry.hasTag("edible")){
				u16 Starch = this.get_u8("food_starch");
				u16 Meat = this.get_u8("food_meat");
				u16 Plant = this.get_u8("food_plant");
				
				Starch += carry.get_u8("starch");
				Meat += carry.get_u8("meat");
				Plant += carry.get_u8("plant");

				if(Starch > 100)Starch = 100;
				if(Meat > 100)Meat = 100;
				if(Plant > 100)Plant = 100;
				
				this.set_u8("food_starch",Starch);
				this.set_u8("food_meat",Meat);
				this.set_u8("food_plant",Plant);
				
				this.getSprite().PlaySound("/Eat.ogg");
				if(getNet().isServer()){
					carry.set_netid("eater",this.getNetworkID());
					carry.server_Die();
				}
			} else 
			if(carry.hasTag("jar") && carry.getName() != "jar"){
				u16 Starch = this.get_u8("food_starch");
				u16 Meat = this.get_u8("food_meat");
				u16 Plant = this.get_u8("food_plant");
				
				Starch += carry.get_u8("starch");
				Meat += carry.get_u8("meat");
				Plant += carry.get_u8("plant");

				if(Starch > 100)Starch = 100;
				if(Meat > 100)Meat = 100;
				if(Plant > 100)Plant = 100;
				
				this.set_u8("food_starch",Starch);
				this.set_u8("food_meat",Meat);
				this.set_u8("food_plant",Plant);
				
				if(getNet().isServer()){
					CBitStream params;
					params.write_u16(this.getNetworkID());
					carry.SendCommand(carry.getCommandID("drink"), params);
				}
			}
		}
	}
	
	if (cmd == this.getCommandID("force_reload"))
	{
		reloadSpriteBody(this.getSprite(),this);
		ReloadEquipment(this.getSprite(),this);
	}
	
	if (cmd == this.getCommandID("set_ally")){
		int team = params.read_u8();
		setAlly(this.getTeamNum(),team,2);
	}
	if (cmd == this.getCommandID("set_neutral")){
		int team = params.read_u8();
		setAlly(this.getTeamNum(),team,1);
	}
	if (cmd == this.getCommandID("set_enemy")){
		int team = params.read_u8();
		setAlly(this.getTeamNum(),team,0);
	}
	
	if (cmd == this.getCommandID("manual_sync"))
	{
		int limb = params.read_u8(); //Limb
		int type = params.read_s8(); //Type
		float hp = params.read_f32(); //Health
		
		if(getNet().isClient()){
			switch(limb){
		
				case 1:{
					this.set_s8("main_arm_type",type); //Type
					this.set_f32("main_arm_hp",hp); //Health
					if(this.get_f32("main_arm_hp") > hp)this.set_f32("main_arm_hit",1);
					//print("Manual synced "+this.get_string("player_name")+"'s main arm, hp:"+hp+" type:"+type);
				break;}
				
				case 2:{
					this.set_s8("sub_arm_type",type); //Type
					this.set_f32("sub_arm_hp",hp); //Health
					if(this.get_f32("sub_arm_hp") > hp)this.set_f32("sub_arm_hit",1);
					//print("Manual synced "+this.get_string("player_name")+"'s sub arm, hp:"+hp+" type:"+type);
				break;}
				
				case 3:{
					this.set_s8("front_leg_type",type); //Type
					this.set_f32("front_leg_hp",hp); //Health
					if(this.get_f32("front_leg_hp") > hp)this.set_f32("front_leg_hit",1);
					//print("Manual synced "+this.get_string("player_name")+"'s main leg, hp:"+hp+" type:"+type);
				break;}
				
				case 4:{
					this.set_s8("back_leg_type",type); //Type
					this.set_f32("back_leg_hp",hp); //Health
					if(this.get_f32("back_leg_hp") > hp)this.set_f32("back_leg_hit",1);
					//print("Manual synced "+this.get_string("player_name")+"'s sub leg, hp:"+hp+" type:"+type);
				break;}
				
				case 5:{
					this.set_s8("torso_type",type); //Type
					this.set_f32("torso_hp",hp); //Health
					if(this.get_f32("torso_hp") > hp)this.set_f32("torso_hit",1);
					//print("Manual synced "+this.get_string("player_name")+"'s torso, hp:"+hp+" type:"+type);
				break;}
			
			}
			
			
			
			reloadSpriteBody(this.getSprite(),this);
			ReloadEquipment(this.getSprite(),this);
		}
	}
	
}



bool canBePickedUp( CBlob@ this, CBlob@ byBlob ){

	if(this is byBlob)return false;

	if(this.get_s8("torso_type") == 1 || byBlob.get_s8("torso_type") == 1)return false;
	
	return (!canResist(this) || this.isKeyPressed(key_down) || !canStand(this));

}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	if(this.get_s8("torso_type") == 1)return false;
	return (!canResist(this)) || this is forBlob;
}

void onDie(CBlob@ this){
	if(this.hasTag("soul") && !this.hasTag("ghost")){
		seperateSoul(this,true,this.getPosition()+Vec2f(0,-32));
		
		if(this.hasTag("alive")){
			CPlayer @hurter = getPlayerByUsername(this.get_string("last_hurter"));
				
			if(hurter !is null)if(hurter.getBlob() !is null){
				CBlob @hurterblob = hurter.getBlob();
				if(this.get_s16("dark_amount") <= hurterblob.get_s16("dark_amount"))hurterblob.set_s16("dark_amount", hurterblob.get_s16("dark_amount")+90+XORRandom(20));
			}
		}
	}
}