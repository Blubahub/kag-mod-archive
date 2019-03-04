
#include "Hitters.as";
#include "Knocked.as";
#include "ThrowCommon.as";
#include "RunnerCommon.as";
#include "GrappleCommon.as";
#include "HumanoidCommon.as";
#include "HumanoidFistCommon.as";
#include "EquipCommon.as";
#include "HumanoidAnimCommon.as";
#include "FireCommon.as";
#include "Ally.as";

///Tools and weapons
#include "PoleCommon.as";
#include "PickCommon.as";
#include "AxeCommon.as";
#include "PickAxeCommon.as";
#include "BowCommon.as";
#include "StabberCommon.as";
#include "SwordCommon.as";

void onInit(CBlob@ this)
{
	this.set_f32("gib health", -3.0f);

	setupBody(this,0,0,0,0,0,0);
	
	this.Tag("player");
	this.Tag("flesh");

	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
	shape.getConsts().net_threshold_multiplier = 0.5f;

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
	
	///Force reload
	this.addCommandID("force_reload");
	this.addCommandID("manual_sync");

	///////Equipment
	
	this.set_string("equipment_head_name","");
	this.set_string("equipment_torso_name","");
	this.set_string("equipment_legs_name","");
	this.set_string("equipment_main_arm_name","");
	this.set_string("equipment_sub_arm_name","");
	
	this.set_string("equipment_back_name","");
	
	this.addCommandID("equip_head");
	this.addCommandID("equip_torso");
	this.addCommandID("equip_legs");
	this.addCommandID("equip_main_arm");
	this.addCommandID("equip_sub_arm");
	
	this.addCommandID("equip_back");
	
	this.addCommandID("eat_held");
	this.set_u8("food_starch",50);
	this.set_u8("food_meat",50);
	this.set_u8("food_plant",50);
	
	//Fist
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
	
	this.Tag("soul");
	
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

	this.Untag("draw_cursor");

	if(this.isInInventory())return;
	const bool ismyplayer = this.isMyPlayer();

	CPlayer @player = this.getPlayer();
	
	if(player !is null){
		this.set_string("player_name",player.getUsername());
		
		if(getNet().isServer()){
			this.set_bool("male",player.getSex() == 0);
			this.set_u16("head",player.getHead());
		}
		
		this.setHeadNum(this.get_u16("head"));
		if(this.get_bool("male"))this.setSexNum(0);
		else this.setSexNum(1);
		
		if(getGameTime()-this.get_u16("create_time") == 60){
			if(getNet().isServer()){
				this.Sync("male",true);
				this.Sync("head",true);
			}
		}
	}
	
	if(ismyplayer)
	if(this.isKeyJustPressed(key_action3))
	{
		CBlob@ carried = this.getCarriedBlob();
		if(carried is null)client_SendThrowOrActivateCommand(this);
	}
	
	
	GrappleInfo@ grapple;
	if (!this.get("GrappleInfo", @grapple))
	{
		return;
	}
	
	if(this.hasTag("soul"))handleDeath(this);
	
	//Ghostssssssss
	
	if(getNet().isServer())
	if(this.getPlayer() is null && this.hasTag("ghost"))this.server_Die();
	
	this.getShape().getConsts().mapCollisions = !this.hasTag("ghost");
	
	if(this.hasTag("ghost"))if(this.getPosition().y > getMap().tilemapheight*8-32)this.setVelocity(Vec2f(this.getVelocity().x,-2));
	
	////////////
	
	if(isConscious(this))this.getShape().setFriction(0.07f);
	else this.getShape().setFriction(1.0f);
	
	//////////////////////////////////Pregnancy code
	//This is gonna take a lot of willpower to write
	
	if(this.hasTag("pregnant")){
		if(this.get_u16("arrival_date") < getGameTime()){
			this.Untag("pregnant");
			SetKnocked(this,300,true);
			this.DropCarried();
			if(getNet().isServer()){
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
	
	
	////////////////////////////////// Manage sprite
	
	if(getNet().isClient())
	if(this.hasTag("reload sprites") || Maths::FMod(getGameTime(),30) == 0){
		ReloadEquipment(this.getSprite(),this);
		this.Untag("reload sprites");
	}
	
	//Gui
	
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
	
	}
	
	///Sanity checks cause the client is an idiot and somehow can't keep track of data properly
	if(getNet().isServer()){
		
		CBlob@[] blobs;
		getBlobsByName("humanoid", blobs);
		
		int seperation = 11*blobs.length;
		
		int checker = (getGameTime()+(this.getNetworkID()*71))%(seperation*6);

		if(checker == seperation * 0)server_ManualSync(this,"main_arm");
		if(checker == seperation * 2)server_ManualSync(this,"sub_arm");
		if(checker == seperation * 3)server_ManualSync(this,"front_leg");
		if(checker == seperation * 4)server_ManualSync(this,"back_leg");
		if(checker == seperation * 5)server_ManualSync(this,"torso");
	}

	//////////////////////////////////Movement
	RunnerMoveVars@ moveVars;
	if (!this.get("moveVars", @moveVars))
	{
		return;
	}
	
	u16 Meat = this.get_u8("food_meat");
	u16 Plant = this.get_u8("food_plant");
	u16 food_level = Maths::Min(Meat,Plant);
	
	if(food_level >= 60 && food_level <= 80){
		moveVars.walkFactor *= 1.5; //Major Food speed benefit
	}
	
	if(food_level >= 60){
		moveVars.walkFactor *= 1.4; //Food speed benefit
	}
	
	if(food_level < 20){
		moveVars.walkFactor *= 0.7; //Food speed Slow
	}
	
	if(this.hasTag("pregnant"))moveVars.walkFactor *= 0.5; //Sigh
	
	moveVars.jumpFactor *= getJumpMulti(this);
	moveVars.walkFactor *= getWalkSpeed(this);
	
	if(getEquippedBlob(this,"main_arm") !is null)if(getEquippedBlob(this,"main_arm").get_f32("speed_modifier") > 0)moveVars.walkFactor *= getEquippedBlob(this,"main_arm").get_f32("speed_modifier");
	if(getEquippedBlob(this,"sub_arm") !is null)if(getEquippedBlob(this,"sub_arm").get_f32("speed_modifier") > 0)moveVars.walkFactor *= getEquippedBlob(this,"sub_arm").get_f32("speed_modifier");
	if(getEquippedBlob(this,"legs") !is null)if(getEquippedBlob(this,"legs").get_f32("speed_modifier") > 0)moveVars.walkFactor *= getEquippedBlob(this,"legs").get_f32("speed_modifier");
	if(getEquippedBlob(this,"torso") !is null)if(getEquippedBlob(this,"torso").get_f32("speed_modifier") > 0)moveVars.walkFactor *= getEquippedBlob(this,"torso").get_f32("speed_modifier");
	if(getEquippedBlob(this,"head") !is null)if(getEquippedBlob(this,"head").get_f32("speed_modifier") > 0)moveVars.walkFactor *= getEquippedBlob(this,"head").get_f32("speed_modifier");
	
	if(this.get_s8("front_leg_type") != 1 || this.get_s8("back_leg_type") != 1)this.Untag("flying");
	else this.Tag("flying");
	
	//////////////////////////////////Get controls
	
	bool Action1 = this.isKeyPressed(key_action1) && bodyPartFunctioning(this,"main_arm");
	bool Action2 = this.isKeyPressed(key_action2) && bodyPartFunctioning(this,"sub_arm") && (!Action1 || !isTwoHanded(getEquippedBlob(this,"main_arm")));
	bool Action2TwoHands = Action2 && !Action1;
	
	f32 angle = getAimAngle(this);
	
	if((ismyplayer && getHUD().hasMenus()) || !isConscious(this)){
		Action1 = false;
		Action2TwoHands = false;
		Action2 = false;
		grapple.grappling = false;
	}
	
	if(this.getCarriedBlob() !is null){
		Action1 = false;
		Action2TwoHands = false;
		Action2 = false;
	}
	
	if(armCanGrapple(this,"main_arm") || armCanGrapple(this,"sub_arm"))this.Untag("no hands");
	else this.Tag("no hands");
	
	
	//////////////////////////Manage equipment
	
	int MainHandType = 0;
	int SubHandType = 0;
	
	CBlob @MainItem = getEquippedBlob(this,"main_arm");
	CBlob @SubItem = getEquippedBlob(this,"sub_arm");
	
	if(MainItem !is null){
		MainHandType = MainItem.get_u8("equip_type");
	}
	if(SubItem !is null){
		SubHandType = SubItem.get_u8("equip_type");
	}
	
	if(MainHandType == 0)ManageFist(this,Action1,"main");
	if(SubHandType == 0)ManageFist(this,Action2,"sub");
	
	if(MainHandType == 1)ManagePole(this,Action1,"main");
	if(SubHandType == 1)ManagePole(this,Action2TwoHands,"sub");
	
	if(MainHandType == 2)ManagePick(this,Action1,"main");
	if(SubHandType == 2)ManagePick(this,Action2,"sub");
	
	if(MainHandType == 3)ManageSword(this,Action1,"main");
	if(SubHandType == 3)ManageSword(this,Action2,"sub");
	
	if((MainHandType == 4 && Action1) || (SubHandType == 4 && Action2TwoHands))ManageBow(this,true);
	else ManageBow(this,false);
	
	if(MainHandType == 6)ManageGrapple(this, grapple,this.isKeyPressed(key_action1),this.isKeyJustPressed(key_action1));
	if(SubHandType == 6)ManageGrapple(this, grapple,this.isKeyPressed(key_action2),this.isKeyJustPressed(key_action2));
	
	if(MainHandType == 7)ManageAxe(this,Action1,"main");
	if(SubHandType == 7)ManageAxe(this,Action2,"sub");
	
	if(MainHandType == 8)ManageStabber(this,Action1,"main");
	if(SubHandType == 8)ManageStabber(this,Action2,"sub");
	
	if(MainHandType == 9)ManagePickAxe(this,Action1,"main");
	if(SubHandType == 9)ManagePickAxe(this,Action2,"sub");

	///Woah shields are messy, should probably clean this up.
	
	if((MainHandType == 5 && Action1) || (SubHandType == 5 && Action2TwoHands)){ //Shield
		if(angle > 45 && angle < 135){
			if(this.getVelocity().y > 0)this.getShape().SetGravityScale(0.2);
		} else {
			this.getShape().SetGravityScale(1);
		}
		
		RunnerMoveVars@ moveVars;
		if (this.get("moveVars", @moveVars))
		{
			if(angle > 270-45 && angle < 270+45)moveVars.jumpFactor *= 0.0f;
			else moveVars.jumpFactor *= 0.5f;
			//moveVars.walkFactor *= 0.8f;
		}
		this.Tag("shielding");
	} else {
		this.Untag("shielding");
	}
	
	
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{

	if(!bodyPartExists(this,"torso"))damage = 0;

	//////////////////////////Shield

	Vec2f vec = hitterBlob.getPosition() - this.getPosition();
	f32 angle = vec.Angle();
	
	f32 aimangle = getAimAngle(this);
	
	if(this.hasTag("shielding")){
		if((aimangle+45 > angle && aimangle-45 < angle) || aimangle-45+360 < angle || aimangle+45-360 < angle)damage = 0;
	}

	//////////////////////////Sounds
	
	
	
	if(customData != Hitters::drown && damage > 0){
		if(isSharp(customData)){
			
			this.getSprite().PlaySound("sharp_hit"+XORRandom(4));
			
		} else
		if(customData == Hitters::suddengib){
			
			this.getSprite().PlaySound("lightup.ogg");
			
		} else 
		this.getSprite().PlaySound("punch"+XORRandom(3));
	}
	
	
	
	
	
	/////////////////////////Hitting
	
	bool TopHit = (angle > 90-30) && (angle < 90+30);
	bool BotHit = (angle > 225) && (angle < 315);
	bool MidHit = !TopHit && !BotHit;
	bool FallDamage = false;
	bool Explosion = false;
	bool Fire = false;
	bool RandomLimb = false;
	
	if(customData == Hitters::fall){
		TopHit = false;
		BotHit = false;
		MidHit = false;
		FallDamage = true;
	}
	
	if (customData == Hitters::burn)
	{
		TopHit = false;
		BotHit = false;
		MidHit = false;
		Fire = true;
		
		damage = 0.5f;
	}
	
	if (isExplosionHitter(customData))
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
	
	if (customData == Hitters::suddengib)
	{
		TopHit = false;
		BotHit = false;
		MidHit = false;
		
		RandomLimb = true;
	}
	
	string BodyPartHit = "torso";
	
	if(TopHit){ //Headshot basically, no insta kills, but double damage and only defended by helmet.
		CBlob @item = getEquippedBlob(this,"head");
		
		if(item !is null){
			if(customData != Hitters::stab || damage < item.get_u8("defense")){ //Knives fully penetrate anything with an equal or lower defense than thier damage
				damage -= item.get_u8("defense");
			}
		}
		
		damage *= 2.0f;
		
		hitBodyPart(this, BodyPartHit, damage, customData);
	}
	
	if(MidHit){ //The default hit, can hit arms+torso, get's defense from chest armour.
		
		CBlob @item = getEquippedBlob(this,"torso");
		if(item !is null){
			if(customData != Hitters::stab || damage < item.get_u8("defense")){ //Knives fully penetrate anything with an equal or lower defense than thier damage
				damage -= item.get_u8("defense");
			}
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
			if(customData != Hitters::stab || damage < item.get_u8("defense")){ //Knives fully penetrate anything with an equal or lower defense than thier damage
				damage -= item.get_u8("defense");
			}
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
		
		{CBlob @item = getEquippedBlob(this,"head");
		if(item !is null){
			damage -= item.get_u8("defense");
		}}
		
		{CBlob @item = getEquippedBlob(this,"torso");
		if(item !is null){
			MArmDamage -= item.get_u8("defense");
			SArmDamage -= item.get_u8("defense");
			damage -= item.get_u8("defense");
		}}
		{CBlob @item = getEquippedBlob(this,"legs");
		if(item !is null){
			FLegDamage -= item.get_u8("defense");
			BLegDamage -= item.get_u8("defense");
		}}
		
		
		int Hit = XORRandom(4);
		if(Hit == 0)MArmDamage *= 2;
		if(Hit == 1)SArmDamage *= 2;
		if(Hit == 2)FLegDamage *= 2;
		if(Hit == 3)BLegDamage *= 2;
		
		if(canHitLimb(this,"torso"))hitBodyPart(this, "torso", damage, customData);
		if(canHitLimb(this,"main_arm"))hitBodyPart(this, "main_arm", MArmDamage, customData);
		if(canHitLimb(this,"sub_arm"))hitBodyPart(this, "sub_arm", SArmDamage, customData);
		if(canHitLimb(this,"front_leg"))hitBodyPart(this, "front_leg", FLegDamage, customData);
		if(canHitLimb(this,"back_leg"))hitBodyPart(this, "back_leg", BLegDamage, customData);
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

	////////////////////////////Knockback
	f32 x_side = 0.0f;
	f32 y_side = 0.0f;
	{
		if (velocity.x > 0.7)
		{
			x_side = 1.0f;
		}
		else if (velocity.x < -0.7)
		{
			x_side = -1.0f;
		}

		if (velocity.y > 0.5)
		{
			y_side = 1.0f;
		}
		if (velocity.y < -0.5)
		{
			y_side = -1.0f;
		}
	}
	f32 scale = 1.0f;

	//scale per hitter
	switch (customData)
	{
		case Hitters::fall:
		case Hitters::drown:
		case Hitters::burn:
		case Hitters::crush:
		case Hitters::spikes:
			scale = 0.0f; break;

		case Hitters::arrow:
			scale = 0.0f; break;

		default: break;
	}

	Vec2f f(x_side, y_side);

	if (damage > 0.125f)
	{
		this.AddForce(f * 40.0f * scale * Maths::Log(2.0f * (10.0f + (damage * 2.0f))));
	}

	if (this.isMyPlayer() && damage > 0)
    {
        SetScreenFlash( 90, 120, 0, 0 );
        ShakeScreen( 9, 2, this.getPosition() );
    }
	
	return 0;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point)
{
	if(solid && point.y > this.getPosition().y)
	if(this.hasTag("shielding")){
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

void onAddToInventory( CBlob@ this, CBlob@ blob ){ //Reject all blobs that are equips, we should put them in a bag if we have one
	if(!blob.hasTag("equiptag")){
		if(getNet().isServer()){
			this.server_PutOutInventory(blob);
			
			CBlob @bag = getEquippedBlob(this,"back");
			if(bag !is null)
			if(bag.getInventory() !is null && bag.hasTag("inventory")){
				bag.server_PutInInventory(blob);
			}
		}
		
	}else blob.Untag("equiptag");
}

void onRemoveFromInventory( CBlob@ this, CBlob@ blob ){
	if(blob !is null)
	if(getNet().isServer()){
		if(blob.hasTag("head")){
			blob.Untag("head");
			blob.Sync("head",true);
			this.set_string("equipment_head_name","");
			this.Sync("equipment_head_name",true);
		}
		if(blob.hasTag("torso")){
			blob.Untag("torso");
			blob.Sync("torso",true);
			this.set_string("equipment_torso_name","");
			this.Sync("equipment_torso_name",true);
		}
		if(blob.hasTag("legs")){
			blob.Untag("legs");
			blob.Sync("legs",true);
			this.set_string("equipment_legs_name","");
			this.Sync("equipment_legs_name",true);
		}
		if(blob.hasTag("main_arm")){
			blob.Untag("main_arm");
			blob.Sync("main_arm",true);
			this.set_string("equipment_main_arm_name","");
			this.Sync("equipment_main_arm_name",true);
		}
		if(blob.hasTag("sub_arm")){
			blob.Untag("sub_arm");
			blob.Sync("sub_arm",true);
			this.set_string("equipment_sub_arm_name","");
			this.Sync("equipment_sub_arm_name",true);
		}
		if(blob.hasTag("back")){
			blob.Untag("back");
			blob.Sync("back",true);
			this.set_string("equipment_back_name","");
			this.Sync("equipment_back_name",true);
		}
		
		this.Tag("reload sprites");
		this.Sync("reload sprites",true);
	}
}

void onCreateInventoryMenu(CBlob@ this, CBlob@ forBlob, CGridMenu @gridmenu)
{
	this.ClearGridMenus();
	
	if(!armCanGrapple(this,"main_arm") && !armCanGrapple(this,"sub_arm"))return;
	
	CBlob @bag = getEquippedBlob(this,"back");
	if(bag !is null){
		if(bag.getInventory() !is null){
			
			int Y = bag.getInventory().getInventorySlots().y;
			
			bag.CreateInventoryMenu(Vec2f(gridmenu.getUpperLeftPosition().x + 0.5f * (gridmenu.getLowerRightPosition().x - gridmenu.getUpperLeftPosition().x),gridmenu.getUpperLeftPosition().y+8+Y*24));
		
			CGridMenu @ inv = bag.getInventory().getGridMenu();
			inv.deleteAfterClick = true;
		}
	}
	
	Vec2f pos(gridmenu.getUpperLeftPosition().x + 0.5f * (gridmenu.getLowerRightPosition().x - gridmenu.getUpperLeftPosition().x) - 156.0f,
	          gridmenu.getUpperLeftPosition().y - 32 * 1 - 3 * 24 - 4);
	CGridMenu@ menu = CreateGridMenu(pos, this, Vec2f(3, 3), "Equipment");
	
	string HeadImage = "EquipmentGUI.png";
	string TorsoImage = "EquipmentGUI.png";
	string LegsImage = "EquipmentGUI.png";
	string MainArmImage = "EquipmentGUI.png";
	string SubArmImage = "EquipmentGUI.png";
	string BackImage = "EquipmentGUI.png";
	int HeadFrame = 0;
	int TorsoFrame = 1;
	int LegsFrame = 2;
	int MainArmFrame = 3;
	int SubArmFrame = 4;
	int BackFrame = 5;
	
	if(this.get_string("equipment_head_name") != ""){
		HeadImage = this.get_string("equipment_head_name")+"_icon.png";
		HeadFrame = 0;
	}
	if(this.get_string("equipment_torso_name") != ""){
		TorsoImage = this.get_string("equipment_torso_name")+"_icon.png";
		TorsoFrame = 0;
	}
	if(this.get_string("equipment_legs_name") != ""){
		LegsImage = this.get_string("equipment_legs_name")+"_icon.png";
		LegsFrame = 0;
	}
	if(this.get_string("equipment_main_arm_name") != ""){
		MainArmImage = this.get_string("equipment_main_arm_name")+"_icon.png";
		MainArmFrame = 0;
	}
	if(this.get_string("equipment_sub_arm_name") != ""){
		SubArmImage = this.get_string("equipment_sub_arm_name")+"_icon.png";
		SubArmFrame = 0;
	}
	
	if(this.get_string("equipment_back_name") != ""){
		BackImage = this.get_string("equipment_back_name")+"_icon.png";
		BackFrame = 0;
	}

	
	if (menu !is null)
	{
		menu.deleteAfterClick = false;

		menu.AddButton(BackImage, BackFrame, "Equip on Back", this.getCommandID("equip_back"));
		
		menu.AddButton(HeadImage, HeadFrame, "Equip on Head", this.getCommandID("equip_head"));
		
		menu.AddButton("EquipmentGUI.png", 8, "", this.getCommandID("equip_head")).SetEnabled(false);
		
		string main = "Equip in main Hand";
		if(!armCanGrapple(this, "main_arm"))main = "Cannot Equip";
		CGridButton @mainarm = menu.AddButton(MainArmImage, MainArmFrame, main, this.getCommandID("equip_main_arm"));
		if(!armCanGrapple(this, "main_arm")){
			mainarm.SetEnabled(false);
			mainarm.SetHoverText("Your main arm is either injured or incapable of equipping items.");
		}
		
		menu.AddButton(TorsoImage, TorsoFrame, "Equip on Body", this.getCommandID("equip_torso"));
		
		string sub = "Equip in sub Hand";
		if(!armCanGrapple(this, "sub_arm"))sub = "Cannot Equip";
		CGridButton @subarm = menu.AddButton(SubArmImage, SubArmFrame, sub, this.getCommandID("equip_sub_arm"));
		if(!armCanGrapple(this, "sub_arm")){
			subarm.SetEnabled(false);
			mainarm.SetHoverText("Your sub arm is either injured or incapable of equipping items.");
		}
		
		menu.AddButton("EquipmentGUI.png", 8, "", this.getCommandID("equip_head")).SetEnabled(false);
		
		menu.AddButton(LegsImage, LegsFrame, "Equip on Legs", this.getCommandID("equip_legs"));
		
		menu.AddButton("EquipmentGUI.png", 8, "", this.getCommandID("equip_head")).SetEnabled(false);
	}
	
	CGridMenu@ eat = CreateGridMenu(pos+Vec2f(0,-96), this, Vec2f(1, 1), "");
	if(eat !is null)
	{
		eat.SetCaptionEnabled(false);

		CGridButton @eatbut = eat.AddButton("EatIcon.png", 0, "Eat held item", this.getCommandID("eat_held"));
		if(eatbut !is null){
			if(this.getCarriedBlob() is null)eatbut.SetEnabled(false);
			eatbut.SetHoverText("Eat currently held item\n");
		}
	}
	
	int Players = getPlayersCount();
	
	if(Players > 1){
		CGridMenu@ ally = CreateGridMenu(pos+Vec2f(-200,0), this, Vec2f(5, Players-1), "Alliances");
		
		for(int i = 0;i < Players; i++){
			CPlayer @p = getPlayer(i);
			
			if(p !is null)if(p !is this.getPlayer()){
				ally.AddTextButton(p.getUsername(), Vec2f(2,1));
				
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
		if(this.get_string("equipment_head_name") != ""){
			CBlob @item = getEquippedBlob(this,"head");
			if(item !is null && getNet().isServer()){
				this.server_PutOutInventory(item);
				this.server_Pickup(item);
				item.Untag("head");
				this.set_string("equipment_head_name","");
				item.Sync("head",true);
				this.Sync("equipment_head_name",true);
				
				this.Tag("reload sprites");
				this.Sync("reload sprites",true);
			}
		} else {
			if(this.getCarriedBlob() !is null){
				CBlob @carry = this.getCarriedBlob();
				if(carry.get_u8("equip_slot") == 5){
					if(getNet().isServer()){
						this.set_string("equipment_head_name",carry.getName());
						carry.Tag("head");
						carry.Tag("equiptag");
						
						this.Sync("equipment_head_name",true);
						carry.Sync("head",true);
						
						this.Tag("reload sprites");
						this.Sync("reload sprites",true);
						
						this.server_PutInInventory(carry);
					}
				}
			}
		}
	}
	if (cmd == this.getCommandID("equip_torso"))
	{
		if(this.get_string("equipment_torso_name") != ""){
			CBlob @item = getEquippedBlob(this,"torso");
			if(item !is null && getNet().isServer()){
				this.server_PutOutInventory(item);
				this.server_Pickup(item);
				item.Untag("torso");
				this.set_string("equipment_torso_name","");
				
				item.Sync("torso",true);
				this.Sync("equipment_torso_name",true);
				
				this.Tag("reload sprites");
				this.Sync("reload sprites",true);
			}
		} else {
			if(this.getCarriedBlob() !is null){
				CBlob @carry = this.getCarriedBlob();
				if(carry.get_u8("equip_slot") == 1){
					this.set_string("equipment_torso_name",carry.getName());
					if(getNet().isServer()){
						carry.Tag("torso");
						carry.Tag("equiptag");
						
						carry.Sync("torso",true);
						this.Sync("equipment_torso_name",true);
						
						this.Tag("reload sprites");
						this.Sync("reload sprites",true);
						
						this.server_PutInInventory(carry);
					}
				}
			}
		}
	}
	if (cmd == this.getCommandID("equip_legs"))
	{
		if(this.get_string("equipment_legs_name") != ""){
			CBlob @item = getEquippedBlob(this,"legs");
			if(item !is null && getNet().isServer()){
				this.server_PutOutInventory(item);
				this.server_Pickup(item);
				item.Untag("legs");
				this.set_string("equipment_legs_name","");
				
				item.Sync("legs",true);
				this.Sync("equipment_legs_name",true);
				
				this.Tag("reload sprites");
				this.Sync("reload sprites",true);
			}
		} else {
			if(this.getCarriedBlob() !is null){
				CBlob @carry = this.getCarriedBlob();
				if(carry.get_u8("equip_slot") == 2){
					if(getNet().isServer()){
						this.set_string("equipment_legs_name",carry.getName());
						carry.Tag("legs");
						carry.Tag("equiptag");
						
						carry.Sync("legs",true);
						this.Sync("equipment_legs_name",true);
						
						this.Tag("reload sprites");
						this.Sync("reload sprites",true);
						
						this.server_PutInInventory(carry);
					}
				}
			}
		}
	}
	if (cmd == this.getCommandID("equip_main_arm"))
	{
		if(this.get_string("equipment_main_arm_name") != ""){
			CBlob @item = getEquippedBlob(this,"main_arm");
			if(item !is null && getNet().isServer()){
				this.server_PutOutInventory(item);
				this.server_Pickup(item);
				item.Untag("main_arm");
				this.set_string("equipment_main_arm_name","");
				
				item.Sync("main_arm",true);
				this.Sync("equipment_main_arm_name",true);
				
				this.Tag("reload sprites");
				this.Sync("reload sprites",true);
			}
		} else {
			if(this.getCarriedBlob() !is null){
				CBlob @carry = this.getCarriedBlob();
				if(carry.get_u8("equip_slot") == 3){
					if(getNet().isServer()){
						this.set_string("equipment_main_arm_name",carry.getName());
						carry.Tag("main_arm");
						carry.Tag("equiptag");
						
						carry.Sync("main_arm",true);
						this.Sync("equipment_main_arm_name",true);
						
						this.Tag("reload sprites");
						this.Sync("reload sprites",true);
						
						this.server_PutInInventory(carry);
					}
				}
			}
		}
	}
	if (cmd == this.getCommandID("equip_sub_arm"))
	{
		if(this.get_string("equipment_sub_arm_name") != ""){
			CBlob @item = getEquippedBlob(this,"sub_arm");
			if(item !is null && getNet().isServer()){
				this.server_PutOutInventory(item);
				this.server_Pickup(item);
				item.Untag("sub_arm");
				this.set_string("equipment_sub_arm_name","");
				
				item.Sync("sub_arm",true);
				this.Sync("equipment_sub_arm_name",true);
				
				this.Tag("reload sprites");
				this.Sync("reload sprites",true);
			}
		} else {
			if(this.getCarriedBlob() !is null){
				CBlob @carry = this.getCarriedBlob();
				if(carry.get_u8("equip_slot") == 3){
					if(getNet().isServer()){
						this.set_string("equipment_sub_arm_name",carry.getName());
						carry.Tag("sub_arm");
						carry.Tag("equiptag");
						
						carry.Sync("sub_arm",true);
						this.Sync("equipment_sub_arm_name",true);
						
						this.Tag("reload sprites");
						this.Sync("reload sprites",true);
						
						this.server_PutInInventory(carry);
					}
				}
			}
		}
	}
	if (cmd == this.getCommandID("equip_back"))
	{
		if(this.get_string("equipment_back_name") != ""){
			CBlob @item = getEquippedBlob(this,"back");
			if(item !is null && getNet().isServer()){
				this.server_PutOutInventory(item);
				this.server_Pickup(item);
				item.Untag("back");
				this.set_string("equipment_back_name","");
				
				item.Sync("back",true);
				this.Sync("equipment_back_name",true);
				
				this.Tag("reload sprites");
				this.Sync("reload sprites",true);
			}
		} else {
			if(this.getCarriedBlob() !is null){
				CBlob @carry = this.getCarriedBlob();
				if(carry.get_u8("equip_slot") == 4){
					if(getNet().isServer()){
						this.set_string("equipment_back_name",carry.getName());
						carry.Tag("back");
						carry.Tag("equiptag");
						
						carry.Sync("back",true);
						this.Sync("equipment_back_name",true);
						
						this.Tag("reload sprites");
						this.Sync("reload sprites",true);
						
						this.server_PutInInventory(carry);
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
					carry.server_Die();
					this.Sync("food_starch",true);
					this.Sync("food_meat",true);
					this.Sync("food_plant",true);
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
	
	///Sanity check for equipment cause apparently both client, server and rob are all too stupid to remove equips when they're stolen
	if(getNet().isServer()){
		if(getEquippedBlob(this,"head") is null){
			this.set_string("equipment_head_name","");
			this.Sync("equipment_head_name",true);
		}
		if(getEquippedBlob(this,"torso") is null){
			this.set_string("equipment_torso_name","");
			this.Sync("equipment_torso_name",true);
		}
		if(getEquippedBlob(this,"legs") is null){
			this.set_string("equipment_legs_name","");
			this.Sync("equipment_legs_name",true);
		}
		if(getEquippedBlob(this,"main_arm") is null){
			this.set_string("equipment_main_arm_name","");
			this.Sync("equipment_main_arm_name",true);
		}
		if(getEquippedBlob(this,"sub_arm") is null){
			this.set_string("equipment_sub_arm_name","");
			this.Sync("equipment_sub_arm_name",true);
		}
		if(getEquippedBlob(this,"back") is null){
			this.set_string("equipment_back_name","");
			this.Sync("equipment_back_name",true);
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
		seperateSoul(this,this.getPosition()+Vec2f(0,-32));
	}
}

