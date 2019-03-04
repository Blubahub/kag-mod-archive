
#include "HumanoidCommon.as"
#include "SurgeryCommon.as"
#include "EquipCommon.as";

void onInit(CBlob @ this)
{
	this.addCommandID("surgery");
	
	this.addCommandID("operate_main_arm");
	this.addCommandID("operate_sub_arm");
	this.addCommandID("operate_front_leg");
	this.addCommandID("operate_back_leg");
}


void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("surgery"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null && caller.getPlayer() is getLocalPlayer())
		{
				
				if(this.isAttachedToPoint("BED")){
					CAttachment@ attach = this.getAttachments();
					CBlob@ patient = attach.getAttachedBlob("BED");
					if(patient !is null){
					
						CGridMenu@ menu = CreateGridMenu(getDriver().getScreenCenterPos() + Vec2f(0.0f, 0.0f), this, Vec2f(3, 3), "Surgery");
						if (menu !is null)
						{
							CBitStream params;
							params.write_u16(caller.getNetworkID());
							
							int MArm = patient.get_s8("main_arm_type")+1;
							int SArm = patient.get_s8("sub_arm_type")+1;
							int FLeg = patient.get_s8("front_leg_type")+1;
							int BLeg = patient.get_s8("back_leg_type")+1;

							int MArmHP = patient.get_f32("main_arm_hp");
							int SArmHP = patient.get_f32("sub_arm_hp");
							int FLegHP = patient.get_f32("front_leg_hp");
							int BLegHP = patient.get_f32("back_leg_hp");
							
							if(MArm == 2){MArm = 0;MArmHP = 0;}
							if(SArm == 2){SArm = 0;SArmHP = 0;}
							if(FLeg == 2){FLeg = 0;FLegHP = 0;}
							if(BLeg == 2){BLeg = 0;BLegHP = 0;}
							
							menu.AddButton("EquipmentGUI.png", 10, "", this.getCommandID("surgery"),params).SetEnabled(false); //Blank
							
							CGridButton@ head = menu.AddButton("HeadHUD.png", 0, Vec2f(13,14), "Head", this.getCommandID("surgery"), Vec2f(1,1), params); //Head
							if(head !is null){
								head.SetEnabled(false);
							}
							
							menu.AddButton("EquipmentGUI.png", 10, "", this.getCommandID("surgery"),params).SetEnabled(false); //Blank
							
							menu.AddButton("MainArmHUD.png", MArm, Vec2f(7,15), "Main Arm\nHealth:"+MArmHP, this.getCommandID("operate_main_arm"), Vec2f(1,1), params); //Main arm
							
							CGridButton@ torso = menu.AddButton("TorsoHUD.png", 0, Vec2f(13,14), "Torso", this.getCommandID("surgery"), Vec2f(1,1), params); //Torso
							if(torso !is null){
								torso.SetEnabled(false);
							}
							
							menu.AddButton("SubArmHUD.png", SArm, Vec2f(7,15), "Sub Arm\nHealth:"+SArmHP, this.getCommandID("operate_sub_arm"), Vec2f(1,1), params); //Sub arm
							
							menu.AddButton("FrontLegHUD.png", FLeg, Vec2f(8,12), "Front Leg\nHealth:"+FLegHP, this.getCommandID("operate_front_leg"), Vec2f(1,1), params); //Front leg
							
							menu.AddButton("EquipmentGUI.png", 10, "", this.getCommandID("surgery"),params).SetEnabled(false); //Blank
							
							menu.AddButton("BackLegHUD.png", BLeg, Vec2f(8,12), "Back Leg\nHealth:"+BLegHP, this.getCommandID("operate_back_leg"), Vec2f(1,1), params); //Back leg
						}
				
					}
				} 
		}
	}
	
	for(int i = 0; i < 4; i+= 1){
	
		string limb_str = "main_arm";
		if(i == 1)limb_str = "sub_arm";
		if(i == 2)limb_str = "front_leg";
		if(i == 3)limb_str = "back_leg";
		
		if (cmd == this.getCommandID("operate_"+limb_str))
		{
			CBlob@ caller = getBlobByNetworkID(params.read_u16());
			if    (caller !is null)
			{
				if(this.isAttachedToPoint("BED")){
					CAttachment@ attach = this.getAttachments();
					CBlob@ patient = attach.getAttachedBlob("BED");
					if(patient !is null && patient.getName() == "humanoid"){
						if(getNet().isServer()){
							if(bodyPartExists(patient,limb_str) && canDelimb(patient,limb_str)){
								if(hasSharpTool(caller))severLimb(patient,limb_str);
							} else {
								CBlob @limb = caller.getCarriedBlob();
								
								if(limb !is null){
									if(BlobNameToBodyType(limb.getName(),limb_str) != -1){
									
										f32 Health_perc = limb.getHealth()/limb.getInitialHealth();
										
										f32 Health = Health_perc*bodyPartMaxHealth(BlobNameToBodyType(limb.getName(),limb_str),limb_str);
									
										attachLimb(patient,limb_str,BlobNameToBodyType(limb.getName(),limb_str),Health);
										if(getNet().isServer())limb.server_Die();
									}
								}
							}
						}
						massSync(patient);
					}
				}
			}
		}
	}
}