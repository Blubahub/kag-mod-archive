
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
							
							menu.AddButton("EquipmentGUI.png", 8, "", this.getCommandID("surgery"),params).SetEnabled(false); //Blank
							
							CGridButton@ head = menu.AddButton("EquipmentGUI.png", 0, "Head", this.getCommandID("surgery"),params); //Head
							if(head !is null){
								head.SetEnabled(false);
							}
							
							menu.AddButton("EquipmentGUI.png", 8, "", this.getCommandID("surgery"),params).SetEnabled(false); //Blank
							
							CGridButton@ main_arm = menu.AddButton("EquipmentGUI.png", 3, "Main Arm", this.getCommandID("operate_main_arm"),params); //Main arm
							
							CGridButton@ torso = menu.AddButton("EquipmentGUI.png", 1, "Torso", this.getCommandID("surgery"),params); //Torso
							if(torso !is null){
								torso.SetEnabled(false);
							}
							
							CGridButton@ sub_arm = menu.AddButton("EquipmentGUI.png", 4, "Sub Arm", this.getCommandID("operate_sub_arm"),params); //Sub arm
							
							CGridButton@ front_leg = menu.AddButton("EquipmentGUI.png", 6, "Front Leg", this.getCommandID("operate_front_leg"),params); //Front leg
							
							menu.AddButton("EquipmentGUI.png", 8, "", this.getCommandID("surgery"),params).SetEnabled(false); //Blank
							
							CGridButton@ back_leg = menu.AddButton("EquipmentGUI.png", 7, "Back Leg", this.getCommandID("operate_back_leg"),params); //Back Leg
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
				if(getNet().isServer()){
					if(this.isAttachedToPoint("BED")){
						CAttachment@ attach = this.getAttachments();
						CBlob@ patient = attach.getAttachedBlob("BED");
						if(patient !is null && patient.getName() == "humanoid"){
							if(bodyPartExists(patient,limb_str)){
								severLimb(patient,limb_str);
							} else {
								CBlob @limb = caller.getCarriedBlob();
								if(limb !is null && (limb.getName() == limb_str || BlobNameToBodyType(limb.getName()) != -1)){
									if(limb.getName() == limb_str)
										attachLimb(patient,limb_str,limb.get_s8("type"),limb.getHealth());
									else 
										attachLimb(patient,limb_str,BlobNameToBodyType(limb.getName()),limb.getHealth());
									limb.server_Die();
								}
							}
						}
					}
				}
			}
		}
	}
}