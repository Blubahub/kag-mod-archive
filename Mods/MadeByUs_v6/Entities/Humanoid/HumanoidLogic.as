
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

void onInit(CBlob@ this)
{
	this.set_f32("gib health", -3.0f);

	this.set_s8("torso_type",0);
	this.set_s8("main_arm_type",0);
	this.set_s8("sub_arm_type",0);
	this.set_s8("front_leg_type",0);
	this.set_s8("back_leg_type",0);
	
	this.set_f32("torso_hp",25.0);
	this.set_f32("main_arm_hp",15.0);
	this.set_f32("sub_arm_hp",15.0);
	this.set_f32("front_leg_hp",20.0);
	this.set_f32("back_leg_hp",20.0);
	
	this.Tag("player");
	this.Tag("flesh");

	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
	shape.getConsts().net_threshold_multiplier = 0.5f;

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
	
	this.set_string("equipment_head_name","");
	this.set_string("equipment_torso_name","");
	this.set_string("equipment_legs_name","");
	this.set_string("equipment_main_arm_name","");
	this.set_string("equipment_sub_arm_name","");
	
	this.set_string("equipment_back_name","");
	
	
	///////Equipment
	
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
	
	//Pick
	HitData hitdata;
	this.set("hitdata", hitdata);
	this.set_s16("pick_counter",0);
	this.addCommandID("pickaxe");
	this.set_f32("pickaxe_distance", 10.0f);
	
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
	if(this.isInInventory())return;
	const bool ismyplayer = this.isMyPlayer();

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
	
	f32 angle = getAimAngle(this);
	
	int MainHandType = getEquipedHandType(this, this.get_string("equipment_main_arm_name"));
	int SubHandType = getEquipedHandType(this, this.get_string("equipment_sub_arm_name"));
	
	
	
	//////////////////////////////////Get controls
	
	bool Action1 = this.isKeyPressed(key_action1) && bodyPartFunctioning(this,"main_arm");
	bool Action2 = this.isKeyPressed(key_action2) && bodyPartFunctioning(this,"sub_arm") && (!Action1 || !isTwoHanded(this.get_string("equipment_main_arm_name")));
	bool Action2TwoHands = Action2 && !Action1;
	
	if((ismyplayer && getHUD().hasMenus()) || getKnocked(this) > 0){
		Action1 = false;
		Action2TwoHands = false;
		Action2 = false;
		grapple.grappling = false;
	}
	
	
	
	
	//////////////////////////Manage equipment
	
	ManageFist(this,Action1 && MainHandType == 0,"main");
	ManageFist(this,Action2 && SubHandType == 0,"sub");
	
	ManagePole(this,Action1 && MainHandType == 1,"main");
	ManagePole(this,Action2 && SubHandType == 1,"sub");
	
	ManageAxe(this,Action1 && MainHandType == 7,"main");
	ManageAxe(this,Action2 && SubHandType == 7,"sub");
	
	this.Untag("pickaxing");
	if(MainHandType == 2)if(Action1)Pickaxe(this);
	if(SubHandType == 2)if(Action2)Pickaxe(this);
	
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

	Vec2f vec = hitterBlob.getPosition() - this.getPosition();
	f32 angle = vec.Angle();
	
	f32 aimangle = getAimAngle(this);
	
	if(this.hasTag("shielding")){
		if((aimangle+45 > angle && aimangle-45 < angle) || aimangle-45+360 < angle || aimangle+45-360 < angle)damage = 0;
	}

	bool TopHit = (angle > 90-30) && (angle < 90+30);
	bool BotHit = (angle > 225) && (angle < 315);
	bool MidHit = !TopHit && !BotHit;
	
	string BodyPartHit = "torso";
	
	if(TopHit){ //Headshot basically, no insta kills, but double damage and only defended by helmet.
		damage *= 2.0f;
		hitBodyPart(this, BodyPartHit, damage);
	}
	
	if(MidHit){ //The default hit, can hit arms+torso, get's defense from chest armour.
		
		int block = XORRandom(100); //The higher the block the better
		
		if(block > 75){ //A good block means you block with your sub arm
			
			if(this.get_s8("sub_arm_type") > -1)BodyPartHit = "sub_arm"; //If we have a sub arm, block
			else if(this.get_s8("main_arm_type") > -1)BodyPartHit = "main_arm"; //Else try blocking with main
		
		} else
		if(block > 50){ //A bad block means you block with your main arm
			if(this.get_s8("main_arm_type") > -1)BodyPartHit = "main_arm";
		}
		
		hitBodyPart(this, BodyPartHit, damage);
	}
	
	if(BotHit){ //A low blow, hits legs unless they no longer exist, get's defense from leg wear. Idea: Add gelding blows
		
		int block = XORRandom(100);
		
		if(block > 50){ //Try hit front leg
			if(this.get_s8("front_leg_type") > -1)BodyPartHit = "front_leg";
			else if(this.get_s8("back_leg_type") > -1)BodyPartHit = "back_leg";
		} else { //Try hit back leg
			if(this.get_s8("back_leg_type") > -1)BodyPartHit = "back_leg";
			else if(this.get_s8("front_leg_type") > -1)BodyPartHit = "front_leg";
		}
		
		hitBodyPart(this, BodyPartHit, damage);
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
			if(this.isKeyPressed(key_right) && this.isKeyPressed(key_left))this.setVelocity(Vec2f(0,-3));
			else if(this.isKeyPressed(key_left))this.setVelocity(Vec2f(-5,-3));
			else if(this.isKeyPressed(key_right)) this.setVelocity(Vec2f(5,-3));
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

void onCreateInventoryMenu(CBlob@ this, CBlob@ forBlob, CGridMenu @gridmenu)
{

	//this.ClearGridMenusExceptInventory();
	this.ClearGridMenus();
	
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
		
		menu.AddButton("EquipmentGUI.png", 6, "", this.getCommandID("equip_head")).SetEnabled(false);
		
		string main = "Equip in main Hand";
		if(!bodyPartFunctioning(this, "main_arm"))main = "Cannot Equip";
		CGridButton @mainarm = menu.AddButton(MainArmImage, MainArmFrame, main, this.getCommandID("equip_main_arm"));
		if(!bodyPartFunctioning(this, "main_arm")){
			mainarm.SetEnabled(false);
			mainarm.SetHoverText("Your main arm is either injured or incable of equipping items.");
		}
		
		menu.AddButton(TorsoImage, TorsoFrame, "Equip on Body", this.getCommandID("equip_torso"));
		
		string sub = "Equip in sub Hand";
		if(!bodyPartFunctioning(this, "sub_arm"))sub = "Cannot Equip";
		CGridButton @subarm = menu.AddButton(SubArmImage, SubArmFrame, sub, this.getCommandID("equip_sub_arm"));
		if(!bodyPartFunctioning(this, "sub_arm")){
			subarm.SetEnabled(false);
			mainarm.SetHoverText("Your sub arm is either injured or incable of equipping items.");
		}
		
		menu.AddButton("EquipmentGUI.png", 6, "", this.getCommandID("equip_head")).SetEnabled(false);
		
		menu.AddButton(LegsImage, LegsFrame, "Equip on Legs", this.getCommandID("equip_legs"));
		
		menu.AddButton("EquipmentGUI.png", 6, "", this.getCommandID("equip_head")).SetEnabled(false);
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
			}
		} else {
			if(this.getCarriedBlob() !is null){
				CBlob @carry = this.getCarriedBlob();
				if(getEquipedType(carry.getName()) == 0){
					if(getNet().isServer()){
						this.set_string("equipment_head_name",carry.getName());
						carry.Tag("head");
						carry.Tag("equiptag");
						
						this.Sync("equipment_head_name",true);
						carry.Sync("head",true);
						
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
			}
		} else {
			if(this.getCarriedBlob() !is null){
				CBlob @carry = this.getCarriedBlob();
				if(getEquipedType(carry.getName()) == 1){
					this.set_string("equipment_torso_name",carry.getName());
					if(getNet().isServer()){
						carry.Tag("torso");
						carry.Tag("equiptag");
						
						carry.Sync("torso",true);
						this.Sync("equipment_torso_name",true);
						
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
			}
		} else {
			if(this.getCarriedBlob() !is null){
				CBlob @carry = this.getCarriedBlob();
				if(getEquipedType(carry.getName()) == 2){
					if(getNet().isServer()){
						this.set_string("equipment_legs_name",carry.getName());
						carry.Tag("legs");
						carry.Tag("equiptag");
						
						carry.Sync("legs",true);
						this.Sync("equipment_legs_name",true);
						
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
			}
		} else {
			if(this.getCarriedBlob() !is null){
				CBlob @carry = this.getCarriedBlob();
				if(getEquipedType(carry.getName()) == 3){
					if(getNet().isServer()){
						this.set_string("equipment_main_arm_name",carry.getName());
						carry.Tag("main_arm");
						carry.Tag("equiptag");
						
						carry.Sync("main_arm",true);
						this.Sync("equipment_main_arm_name",true);
						
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
			}
		} else {
			if(this.getCarriedBlob() !is null){
				CBlob @carry = this.getCarriedBlob();
				if(getEquipedType(carry.getName()) == 3){
					if(getNet().isServer()){
						this.set_string("equipment_sub_arm_name",carry.getName());
						carry.Tag("sub_arm");
						carry.Tag("equiptag");
						
						carry.Sync("sub_arm",true);
						this.Sync("equipment_sub_arm_name",true);
						
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
			}
		} else {
			if(this.getCarriedBlob() !is null){
				CBlob @carry = this.getCarriedBlob();
				if(getEquipedType(carry.getName()) == 4){
					if(getNet().isServer()){
						this.set_string("equipment_back_name",carry.getName());
						carry.Tag("back");
						carry.Tag("equiptag");
						
						carry.Sync("back",true);
						this.Sync("equipment_back_name",true);
						
						this.server_PutInInventory(carry);
					}
				}
			}
		}
	}
	if(cmd == this.getCommandID("pickaxe"))
	{
		if(!RecdHitCommand(this, params))
			warn("error when recieving pickaxe command");
	}
	
	ReloadEquipment(this.getSprite(),this);
}

f32 getAimAngle(CBlob @this){

	Vec2f pos = this.getPosition();
	Vec2f aimpos = this.getAimPos();
	Vec2f vec = aimpos - pos;
	return vec.Angle();

}
