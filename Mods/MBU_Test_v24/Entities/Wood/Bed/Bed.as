// Bed

#include "Help.as"
#include "HumanoidCommon.as"

void onInit( CBlob@ this )
{		 	
	this.Tag("medium weight");
	
	this.addCommandID("lie");
	
	this.addCommandID("woohoo");
	
	this.Tag("can_dye");
	
	this.Untag("sexing");
	
	this.set_u16("sex_start_time",getGameTime());
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(caller.getCarriedBlob() !is this && !this.hasTag("sexing")){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		
		CButton@ button = caller.CreateGenericButton(29, Vec2f(-4,0), this, this.getCommandID("lie"), "Lie Down", params);
	}

	if(this.isAttachedToPoint("BED") && !this.hasTag("sexing")){
		CAttachment@ attach = this.getAttachments();
		if(attach.getAttachedBlob("BED") !is null){
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			
			CButton@ button = caller.CreateGenericButton(10, Vec2f(4,0), this, this.getCommandID("surgery"), "Perform Surgery", params);
			
			if(attach.getAttachedBlob("BED") !is caller){
				
				CBlob @other = attach.getAttachedBlob("BED");
				
				if(other !is null)
				if(canResist(other)){
					string Text = "";
					
					if(!other.hasTag("pregnant") && !caller.hasTag("pregnant")){
						if(other.getSexNum() != caller.getSexNum()){ //Watch gays get triggered cause they can't bang
							if(other.get_string("partner") == caller.get_string("player_name") && caller.get_string("partner") == other.get_string("player_name")){
								Text = "Woohoo~";
							} else 
							if(other.get_string("partner") == "" && caller.get_string("partner") == ""){
								Text = "Woohoo~";
							} else {
								if(caller.get_string("partner") != ""){
									Text = "This is not your partner.";
								} else 
								if(other.get_string("partner") != ""){
									Text = "This someone else's partner.";
								}
							}
						} else {
							Text = "You can't be partners with someone of the same sex.";
						}
					} else {
						Text = "Women cannot have sex while pregnant.";
					}
					
					if(Text != ""){
						CButton@ button = caller.CreateGenericButton(11, Vec2f(0,-8), this, this.getCommandID("woohoo"), Text, params);
						button.SetEnabled(Text == "Woohoo~");
					}
				}
			}
		}
	}
}

void onTick( CBlob@ this )
{
	bool empty = true;
	if(getNet().isClient()){
		if(this.isAttachedToPoint("BED")){
			CAttachment@ attach = this.getAttachments();
			if(attach.getAttachedBlob("BED") !is null){
				if(XORRandom(1000) == 0) {
					this.getSprite().PlaySound("/MigrantSleep");
				}
				this.getSprite().SetAnimation("full");
				empty = false;
				attach.getAttachmentPointByName("BED").offsetZ = 0.1;
			}
		}
	}
	
	if(this.hasTag("sexing")){
		if(getNet().isClient()){
			if(this.getSprite().animation.name != "sex"){
				this.getSprite().SetAnimation("sex");
			}
			empty = false;
			if(XORRandom(10) == 0)this.getSprite().animation.backward = (XORRandom(2) == 0);
		}
		
		if(this.get_u16("sex_start_time")+300 < getGameTime()){
			this.Untag("sexing");
			
			if(this.isAttachedToPoint("SEX_A")){
				CAttachment@ attach = this.getAttachments();
				CBlob @sex_a = attach.getAttachedBlob("SEX_A");
				CBlob @sex_b = attach.getAttachedBlob("SEX_B");
				if(sex_a !is null && sex_b !is null){
					CBlob @male = null;
					CBlob @female = null;
					if(sex_a.getSexNum() == 0){
						@male = sex_a;
						@female = sex_b;
					} else {
						@male = sex_b;
						@female = sex_a;
					}
					
					female.set_s8("sperm_head_type",		male.get_s8("sperm_head_type"));
					female.set_s8("sperm_torso_type",	male.get_s8("sperm_torso_type"));
					female.set_s8("sperm_main_arm_type",	male.get_s8("sperm_main_arm_type"));
					female.set_s8("sperm_sub_arm_type",	male.get_s8("sperm_sub_arm_type"));
					female.set_s8("sperm_front_leg_type",male.get_s8("sperm_front_leg_type"));
					female.set_s8("sperm_back_leg_type",	male.get_s8("sperm_back_leg_type"));
					
					female.Tag("pregnant");
					female.set_u16("arrival_date",getGameTime()+30*60*5);
				
					if(getNet().isServer()){
						this.server_DetachAll();
						this.Sync("sexing",true);
						female.Sync("pregnant",true);
						female.Sync("arrival_date",true);
					}
				}
			}
			if(getNet().isServer()){
				this.server_DetachAll();
			}
		}
	}
	
	if(getNet().isClient())if(empty)this.getSprite().SetAnimation("empty");
	
}

void onInit(CSprite@ this)
{
	this.SetZ(-50); //background
	this.SetAnimation("empty");
}
void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("woohoo"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if(caller !is null)
		{
			if(this.isAttachedToPoint("BED")){
				CAttachment@ attach = this.getAttachments();
				CBlob @other = attach.getAttachedBlob("BED");
				if(other !is null){
					other.set_string("partner",caller.get_string("player_name"));
					caller.set_string("partner",other.get_string("player_name"));
					this.Tag("sexing");
					this.set_u16("sex_start_time",getGameTime());
					if(getNet().isServer()){
						other.Sync("partner",true);
						caller.Sync("partner",true);
						this.Sync("sexing",true);
						this.Sync("sex_start_time",true);
						
						other.server_setTeamNum(caller.getTeamNum());
						this.server_DetachFrom(other);
						
						this.server_AttachTo(other, "SEX_A");
						this.server_AttachTo(caller, "SEX_B");
					}
					
					
					print("Set "+caller.get_string("player_name")+" and "+other.get_string("player_name")+" as partners!");
				}
			}
		}
	}
	
	
	
	if (cmd == this.getCommandID("lie"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null)
		{
			if(getNet().isServer() && !this.hasTag("sexing")){
				
				if(this.isAttachedToPoint("BED")){
					CAttachment@ attach = this.getAttachments();
					if(attach.getAttachedBlob("BED") !is null){
						CBlob @attachedBlob = attach.getAttachedBlob("BED");
						if(attachedBlob.getName() == "humanoid")massSync(attachedBlob);
						this.server_DetachFrom(attachedBlob);
					}
				} else {
				
					CBlob@ hold = caller.getCarriedBlob();
					if(hold is null){
					
						if(!this.isAttachedTo(caller)){
							this.server_AttachTo(caller, "BED");
							if(caller.getName() == "humanoid")massSync(caller);
						} else {
							this.server_DetachFrom(caller);
							if(caller.getName() == "humanoid")massSync(caller);
						}
					
					} else {
						if(hold.getName() == "humanoid"){
							caller.DropCarried();
							this.server_AttachTo(hold, "BED");
							if(hold.getName() == "humanoid")massSync(hold);
						}
					}
				
				}
			}
		}
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob){
	return true;
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return !this.isAttachedToPoint("BED");
}