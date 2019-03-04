
#include "Hitters.as";
#include "Knocked.as";
#include "ThrowCommon.as";
#include "RunnerCommon.as";
#include "GrappleCommon.as";
#include "HumanoidCommon.as";
#include "HumanoidFistCommon.as";
#include "PoleCommon.as";
#include "PickCommon.as";
#include "AxeCommon.as";
#include "BowCommon.as";
#include "EquipCommon.as";
#include "HumanoidAnimCommon.as";
#include "FireCommon.as";

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
	
	//Fist
	this.set_s16("main_fist_drawback",0);
	this.set_s16("sub_fist_drawback",0);
	
	//Stick
	this.set_s16("main_pole_drawback",0);
	this.set_s16("sub_pole_drawback",0);
	
	//Axe
	this.set_s16("main_axe_drawback",0);
	this.set_s16("sub_axe_drawback",0);
	
	//Grapple
	this.set_Vec2f("grapple_offset",Vec2f(0,0));
	this.addCommandID(grapple_sync_cmd);
	GrappleInfo grapple;
	this.set("GrappleInfo", @grapple);
	
	//Bow
	this.set_u16("bowcharge",0);
	this.getSprite().SetEmitSound("Entities/Characters/Archer/BowPull.ogg");
	
	this.Tag("soul");
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

	if(this.getPlayer() !is null){
		this.set_string("player_name",this.getPlayer().getUsername());
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
	
	if(getNet().isServer())
	if(this.getPlayer() is null && this.hasTag("ghost"))this.server_Die();
	
	if(isConscious(this))this.getShape().setFriction(0.07f);
	else this.getShape().setFriction(1.0f);
	
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
	
	if(Maths::FMod(getGameTime(),302) == 0)massSync(this);

	//////////////////////////////////Movement
	RunnerMoveVars@ moveVars;
	if (!this.get("moveVars", @moveVars))
	{
		return;
	}
	
	moveVars.jumpFactor *= getJumpMulti(this);
	moveVars.walkFactor *= getWalkSpeed(this);
	
	if(this.get_s8("front_leg_type") != 1 || this.get_s8("back_leg_type") != 1)this.Untag("flying");
	else this.Tag("flying");
	
	//////////////////////////////////Get controls
	
	bool Action1 = this.isKeyPressed(key_action1) && bodyPartFunctioning(this,"main_arm");
	bool Action2 = this.isKeyPressed(key_action2) && bodyPartFunctioning(this,"sub_arm") && (!Action1 || !isTwoHanded(this.get_string("equipment_main_arm_name")));
	bool Action2TwoHands = Action2 && !Action1;
	
	f32 angle = getAimAngle(this);
	
	if((ismyplayer && getHUD().hasMenus()) || getKnocked(this) > 0){
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
	
	int MainHandType = getEquipedHandType(this, this.get_string("equipment_main_arm_name"));
	int SubHandType = getEquipedHandType(this, this.get_string("equipment_sub_arm_name"));
	
	ManageFist(this,Action1 && MainHandType == 0,"main");
	ManageFist(this,Action2 && SubHandType == 0,"sub");
	
	ManagePole(this,Action1 && MainHandType == 1,"main");
	ManagePole(this,Action2 && SubHandType == 1,"sub");
	
	ManageAxe(this,Action1 && MainHandType == 7,"main");
	ManageAxe(this,Action2 && SubHandType == 7,"sub");
	
	ManagePick(this,Action1 && MainHandType == 2,"main");
	ManagePick(this,Action2 && SubHandType == 2,"sub");
	
	ManageGrapple(this, grapple,Action1 && MainHandType == 6,this.isKeyJustPressed(key_action1));
	ManageGrapple(this, grapple,Action2 && SubHandType == 6,this.isKeyJustPressed(key_action2));
	
	
	if((MainHandType == 4 && Action1) || (SubHandType == 4 && Action2TwoHands))ManageBow(this,true);
	else ManageBow(this,false);
	
	
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

	damage = customData == Hitters::suddengib ? 0 : damage;
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
			
		} 
		else this.getSprite().PlaySound("punch"+XORRandom(3));
	}
	
	
	
	
	
	/////////////////////////Hitting
	
	bool TopHit = (angle > 90-30) && (angle < 90+30);
	bool BotHit = (angle > 225) && (angle < 315);
	bool MidHit = !TopHit && !BotHit;
	bool FallDamage = false;
	bool Explosion = false;
	bool Fire = false;
	
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
		
		damage = 2.0f;
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
		
		if(Torso)hitBodyPart(this, "torso", damage*4.0f, customData);
		if(Main_arm)hitBodyPart(this, "main_arm", damage*4.0f, customData);
		if(Sub_arm)hitBodyPart(this, "sub_arm", damage*4.0f, customData);
		if(Front_leg)hitBodyPart(this, "front_leg", damage*4.0f, customData);
		if(Back_leg)hitBodyPart(this, "back_leg", damage*4.0f, customData);
		
		if(!Torso && !Main_arm && !Sub_arm && !Front_leg && !Back_leg)
		damage = 0;
	}
	
	string BodyPartHit = "torso";
	
	if(TopHit){ //Headshot basically, no insta kills, but double damage and only defended by helmet.
		CBlob @item = getEquippedBlob(this,"head");
		if(item !is null){
			damage -= item.get_u8("defense");
		}
		
		damage *= 2.0f;
		
		hitBodyPart(this, BodyPartHit, damage, customData);
	}
	
	if(MidHit){ //The default hit, can hit arms+torso, get's defense from chest armour.
		
		CBlob @item = getEquippedBlob(this,"torso");
		if(item !is null){
			damage -= item.get_u8("defense");
		}
		
		int block = XORRandom(100); //The higher the block the better
		
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
			damage -= item.get_u8("defense");
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
		else
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
	
	Vec2f pos(gridmenu.getUpperLeftPosition().x + 0.5f * (gridmenu.getLowerRightPosition().x - gridmenu.getUpperLeftPosition().x),
	          gridmenu.getUpperLeftPosition().y - 32 * 1 - 3 * 24);
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
	
	if (cmd == this.getCommandID("force_reload"))
	{
		reloadSpriteBody(this.getSprite(),this);
		ReloadEquipment(this.getSprite(),this);
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
	if(this.hasTag("soul")){
		seperateSoul(this,Vec2f(0,0));
	}
}

