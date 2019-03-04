
#include "Hitters.as";
#include "Knocked.as";
#include "ThrowCommon.as";
#include "RunnerCommon.as";
#include "GrappleCommon.as";
#include "HumanoidCommon.as";
#include "HumanoidFistCommon.as";
#include "HumanoidPoleCommon.as";
#include "BowCommon.as";

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
	
	//Types:
	//0 - none/fist
	//1 - stick
	//2 - pick
	//3 - sword
	//4 - bow
	//5 - shield
	//6 - grapple
	
	
	
	
	///////Equipment
	
	this.addCommandID("equip_head");
	this.addCommandID("equip_torso");
	this.addCommandID("equip_legs");
	this.addCommandID("equip_main_arm");
	this.addCommandID("equip_sub_arm");
	
	//Fist
	this.set_s16("main_fist_drawback",0);
	this.set_s16("sub_fist_drawback",0);
	
	//Stick
	this.set_s16("main_pole_drawback",0);
	this.set_s16("sub_pole_drawback",0);
	
	//Grapple
	this.set_Vec2f("grapple_offset",Vec2f(0,0));
	this.addCommandID(grapple_sync_cmd);
	GrappleInfo grapple;
	this.set("GrappleInfo", @grapple);
	
	//Bow
	this.set_u16("bowcharge",0);
	this.getSprite().SetEmitSound("Entities/Characters/Archer/BowPull.ogg");
	
	
	
	
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
	if(ismyplayer && getHUD().hasMenus())return;

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
	
	
	
	if (getKnocked(this) > 0)
	{
		grapple.grappling = false;
		return;
	}
	
	bool Action1 = this.isKeyPressed(key_action1) && bodyPartFunctioning(this,"main_arm");
	bool Action2Seperate = this.isKeyPressed(key_action2) && bodyPartFunctioning(this,"sub_arm");
	bool Action2 = Action2Seperate && !Action1;
	
	int MainHandType = getEquipedHandType(this, this.get_string("equipment_main_arm_name"));
	int SubHandType = getEquipedHandType(this, this.get_string("equipment_sub_arm_name"));
	
	if(this.getCarriedBlob() is null){
		if(MainHandType == 0)ManageFist(this,Action1,"main");
		if(SubHandType == 0)ManageFist(this,Action2Seperate,"sub");
	}
	
	if(MainHandType == 1)ManagePole(this,Action1,"main");
	if(SubHandType == 1)ManagePole(this,Action2Seperate,"sub");
	
	if(MainHandType == 6)ManageGrapple(this, grapple,Action1,this.isKeyJustPressed(key_action1));
	if(SubHandType == 6)ManageGrapple(this, grapple,Action2Seperate,this.isKeyJustPressed(key_action2));
	
	
	if((MainHandType == 4 && Action1) || (SubHandType == 4 && Action2))ManageBow(this,true);
	else ManageBow(this,false);
	
	
	f32 angle = getAimAngle(this);
	
	if((MainHandType == 5 && Action1) || (SubHandType == 5 && Action2)){
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

	if(this.hasTag("shielding")){
		Vec2f pos = this.getPosition();
		f32 aimangle = getAimAngle(this);

		Vec2f vec = worldPoint - pos;
		f32 angle = vec.Angle();
		
		if((aimangle+45 > angle && aimangle-45 < angle) || aimangle-45+360 < angle || aimangle+45-360 < angle)return 0;
	}

	return damage;
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



void onCreateInventoryMenu(CBlob@ this, CBlob@ forBlob, CGridMenu @gridmenu)
{

	this.ClearGridMenusExceptInventory();
	Vec2f pos(gridmenu.getUpperLeftPosition().x + 0.5f * (gridmenu.getLowerRightPosition().x - gridmenu.getUpperLeftPosition().x),
	          gridmenu.getUpperLeftPosition().y - 32 * 1 - 3 * 24);
	CGridMenu@ menu = CreateGridMenu(pos, this, Vec2f(3, 3), "Equipment");
	
	string HeadImage = "EquipmentGUI.png";
	string TorsoImage = "EquipmentGUI.png";
	string LegsImage = "EquipmentGUI.png";
	string MainArmImage = "EquipmentGUI.png";
	string SubArmImage = "EquipmentGUI.png";
	int HeadFrame = 0;
	int TorsoFrame = 1;
	int LegsFrame = 2;
	int MainArmFrame = 3;
	int SubArmFrame = 4;
	
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
	
	if (menu !is null)
	{
		menu.deleteAfterClick = false;

		menu.AddButton("EquipmentGUI.png", 5, "", this.getCommandID("equip_head")).SetEnabled(false);
		
		menu.AddButton(HeadImage, HeadFrame, "Equip on Head", this.getCommandID("equip_head"));
		
		menu.AddButton("EquipmentGUI.png", 5, "", this.getCommandID("equip_head")).SetEnabled(false);
		
		menu.AddButton(MainArmImage, MainArmFrame, "Equip in main Hand", this.getCommandID("equip_main_arm"));
		menu.AddButton(TorsoImage, TorsoFrame, "Equip on Body", this.getCommandID("equip_torso"));
		menu.AddButton(SubArmImage, SubArmFrame, "Equip in sub Hand", this.getCommandID("equip_sub_arm"));
		
		menu.AddButton("EquipmentGUI.png", 5, "", this.getCommandID("equip_head")).SetEnabled(false);
		
		menu.AddButton(LegsImage, LegsFrame, "Equip on Legs", this.getCommandID("equip_legs"));
		
		menu.AddButton("EquipmentGUI.png", 5, "", this.getCommandID("equip_head")).SetEnabled(false);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("equip_head"))
	{
		if(this.get_string("equipment_head_name") != ""){
			if(getNet().isServer()){
				CBlob @item = server_CreateBlob(this.get_string("equipment_head_name"),-1,this.getPosition());
				this.server_Pickup(item);
			}
			this.set_string("equipment_head_name","");
		} else {
			if(this.getCarriedBlob() !is null){
				CBlob @carry = this.getCarriedBlob();
				if(getEquipedType(carry.getName()) == 0){
					this.set_string("equipment_head_name",carry.getName());
					if(getNet().isServer()){
						carry.server_Die();
					}
				}
			}
		}
	}
	if (cmd == this.getCommandID("equip_torso"))
	{
		if(this.get_string("equipment_torso_name") != ""){
			if(getNet().isServer()){
				CBlob @item = server_CreateBlob(this.get_string("equipment_torso_name"),-1,this.getPosition());
				this.server_Pickup(item);
			}
			this.set_string("equipment_torso_name","");
		} else {
			if(this.getCarriedBlob() !is null){
				CBlob @carry = this.getCarriedBlob();
				if(getEquipedType(carry.getName()) == 1){
					this.set_string("equipment_torso_name",carry.getName());
					if(getNet().isServer()){
						carry.server_Die();
					}
				}
			}
		}
	}
	if (cmd == this.getCommandID("equip_legs"))
	{
		if(this.get_string("equipment_legs_name") != ""){
			if(getNet().isServer()){
				CBlob @item = server_CreateBlob(this.get_string("equipment_legs_name"),-1,this.getPosition());
				this.server_Pickup(item);
			}
			this.set_string("equipment_legs_name","");
		} else {
			if(this.getCarriedBlob() !is null){
				CBlob @carry = this.getCarriedBlob();
				if(getEquipedType(carry.getName()) == 2){
					this.set_string("equipment_legs_name",carry.getName());
					if(getNet().isServer()){
						carry.server_Die();
					}
				}
			}
		}
	}
	if (cmd == this.getCommandID("equip_main_arm"))
	{
		if(this.get_string("equipment_main_arm_name") != ""){
			if(getNet().isServer()){
				CBlob @item = server_CreateBlob(this.get_string("equipment_main_arm_name"),-1,this.getPosition());
				this.server_Pickup(item);
			}
			this.set_string("equipment_main_arm_name","");
		} else {
			if(this.getCarriedBlob() !is null){
				CBlob @carry = this.getCarriedBlob();
				if(getEquipedType(carry.getName()) == 3){
					this.set_string("equipment_main_arm_name",carry.getName());
					if(getNet().isServer()){
						carry.server_Die();
					}
				}
			}
		}
	}
	if (cmd == this.getCommandID("equip_sub_arm"))
	{
		if(this.get_string("equipment_sub_arm_name") != ""){
			if(getNet().isServer()){
				CBlob @item = server_CreateBlob(this.get_string("equipment_sub_arm_name"),-1,this.getPosition());
				this.server_Pickup(item);
			}
			this.set_string("equipment_sub_arm_name","");
		} else {
			if(this.getCarriedBlob() !is null){
				CBlob @carry = this.getCarriedBlob();
				if(getEquipedType(carry.getName()) == 3){
					this.set_string("equipment_sub_arm_name",carry.getName());
					if(getNet().isServer()){
						carry.server_Die();
					}
				}
			}
		}
	}
}

f32 getAimAngle(CBlob @this){

	Vec2f pos = this.getPosition();
	Vec2f aimpos = this.getAimPos();
	Vec2f vec = aimpos - pos;
	return vec.Angle();

}

int getEquipedHandType(CBlob @this, string name){
	//Types:
	//0 - none/fist
	//1 - stick
	//2 - pick
	//3 - sword
	//4 - bow
	//5 - shield
	//6 - grapple
	
	if(name == "shield")return 5;
	
	if(name == "grapple")return 6;
	
	if(name == "bow")return 4;
	
	if(name == "stick")return 1;
	
	return 0;
}

int getEquipedType(string name){
	//-1 - none
	//0 - head
	//1 - torso
	//2 - legs
	//3 - arms

	if(name == "shield")return 3;
	
	if(name == "grapple")return 3;
	
	if(name == "bow")return 3;
	
	if(name == "stick")return 3;
	
	return -1;
}