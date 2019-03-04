
#include "HumanoidCommon.as"
#include "SurgeryCommon.as"

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
							
							menu.AddButton("EquipmentGUI.png", 8, "", this.getCommandID("surgery"),params).SetEnabled(false); //Blank
							
							CGridButton@ head = menu.AddButton("EquipmentGUI.png", 0, "Head", this.getCommandID("surgery"),params); //Head
							if(head !is null){
								head.SetEnabled(false);
							}
							
							menu.AddButton("EquipmentGUI.png", 8, "", this.getCommandID("surgery"),params).SetEnabled(false); //Blank
							
							CGridButton@ main_arm = menu.AddButton("Surgery_Main_Arm.png", MArm, "Main Arm\nHealth:"+MArmHP, this.getCommandID("operate_main_arm"),params); //Main arm
							
							CGridButton@ torso = menu.AddButton("EquipmentGUI.png", 1, "Torso", this.getCommandID("surgery"),params); //Torso
							if(torso !is null){
								torso.SetEnabled(false);
							}
							
							CGridButton@ sub_arm = menu.AddButton("Surgery_Sub_Arm.png", SArm, "Sub Arm\nHealth:"+SArmHP, this.getCommandID("operate_sub_arm"),params); //Sub arm
							
							CGridButton@ front_leg = menu.AddButton("Surgery_Front_Leg.png", FLeg, "Front Leg\nHealth:"+FLegHP, this.getCommandID("operate_front_leg"),params); //Front leg
							
							menu.AddButton("EquipmentGUI.png", 8, "", this.getCommandID("surgery"),params).SetEnabled(false); //Blank
							
							CGridButton@ back_leg = menu.AddButton("Surgery_Back_Leg.png", BLeg, "Back Leg\nHealth:"+BLegHP, this.getCommandID("operate_back_leg"),params); //Back Leg
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
						CBlob @limb = caller.getCarriedBlob();
						if(limb !is null){
							if(getNet().isServer()){
								if(bodyPartExists(patient,limb_str)){
									if(limb.hasTag("sharp"))severLimb(patient,limb_str);
								} else {
									if(BlobNameToBodyType(limb.getName(),limb_str) != -1){
										attachLimb(patient,limb_str,BlobNameToBodyType(limb.getName(),limb_str),limb.getHealth());
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