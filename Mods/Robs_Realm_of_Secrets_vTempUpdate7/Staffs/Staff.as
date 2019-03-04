#include "ElementalControl.as";

void onInit(CBlob@ this)
{
	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (ap !is null)
	{
		ap.SetKeysToTake(key_action1 | key_action2 | key_action3);
	}
	this.addCommandID("mod");
	
	this.set_u16("timer",0);
	this.set_u16("super_timer",300);
}

void onTick(CBlob@ this)
{

	if (this.isAttached())
	{
		this.getCurrentScript().runFlags &= ~(Script::tick_not_sleeping);
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		CBlob@ holder = point.getOccupied();

		if (holder is null){
			@point = this.getAttachments().getAttachmentPointByName("STAFF");
			@holder = point.getOccupied();
			AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("STAFF");
			if (ap !is null)
			{
				ap.SetKeysToTake(key_action1 | key_action3);
			}
		}
		
		if (holder is null) return;

		this.getSprite().SetOffset(Vec2f(7,1));
		
		this.getShape().SetRotationsAllowed(false);


		if (holder.get_u8("knocked") <= 0)
		{
			if(point.isKeyPressed(key_action1)){
				CBlob@[] blobsInRadius;
				if (this.getMap().getBlobsInRadius(holder.getAimPos(), 16.0f, @blobsInRadius)) 
				{
					for (uint i = 0; i < blobsInRadius.length; i++)
					{
						CBlob@ b = blobsInRadius[i];
						if(b !is null){
							if(b !is this && b !is holder && !b.hasTag("element")){
								Vec2f dir = holder.getAimPos()-b.getPosition();
								dir.Normalize();
								b.setVelocity(dir*0.50+b.getVelocity());
							}
						}
					}
				}
			}
			
			if(point.isKeyPressed(key_action2)){
				ControlElements(this.get_f32("power"),holder.getAimPos(),false,false,false,false,false,false,false,false,true,false,false);
			}
			
			if(this.get_u16("super_timer") < 300)this.set_u16("super_timer",this.get_u16("super_timer")+1);
			else
			if(point.isKeyPressed(key_action3)){
				CBlob@[] blobsInRadius;
				if (this.getMap().getBlobsInRadius(holder.getPosition(), 64.0f, @blobsInRadius)) 
				{
					for (uint i = 0; i < blobsInRadius.length; i++)
					{
						CBlob@ b = blobsInRadius[i];
						if(b !is null){
							if(b !is this){
								Vec2f dir = holder.getPosition()-b.getPosition();
								dir.Normalize();
								b.setVelocity(dir*-10+b.getVelocity());
							}
						}
					}
				}
				this.set_u16("super_timer",0);
			}
		}
	}
	else
	{
		this.getSprite().SetOffset(Vec2f(0,0));
		this.getShape().SetRotationsAllowed(true);
	}
}


void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	this.getCurrentScript().runFlags &= ~Script::tick_not_sleeping;
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(!this.isAttached()){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		
		CButton@ button = caller.CreateGenericButton(11, Vec2f(0,0), this, this.getCommandID("mod"), "Enchant staff", params);
		button.SetEnabled(caller.getCarriedBlob() !is null);
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	CBlob@ caller = getBlobByNetworkID(params.read_u16());
	if    (caller !is null)
	{
		if (cmd == this.getCommandID("mod"))
		{
			CBlob@ hold = caller.getCarriedBlob();
			if(hold !is null)if(getNet().isServer()){
				if(hold.getName() == "lantern"){
					CBlob@ staff = server_CreateBlob("fire_staff", 0, this.getPosition());
					staff.set_u8("staffbase",this.get_u8("staffbase"));
					caller.server_Pickup(staff);
					hold.server_Die();
					this.server_Die();
				}
				if(hold.getName() == "seed"){
					CBlob@ staff = server_CreateBlob("plant_staff", 0, this.getPosition());
					staff.set_u8("staffbase",this.get_u8("staffbase"));
					caller.server_Pickup(staff);
					hold.server_Die();
					this.server_Die();
				}
				if(hold.getName() == "heart"){
					CBlob@ staff = server_CreateBlob("blood_staff", 0, this.getPosition());
					staff.set_u8("staffbase",this.get_u8("staffbase"));
					caller.server_Pickup(staff);
					hold.server_Die();
					this.server_Die();
				}
				if(hold.getName() == "bucket"){
					CBlob@ staff = server_CreateBlob("water_staff", 0, this.getPosition());
					staff.set_u8("staffbase",this.get_u8("staffbase"));
					caller.server_Pickup(staff);
					hold.server_Die();
					this.server_Die();
				}
				if(hold.getName() == "corruption_orb"){
					CBlob@ staff = server_CreateBlob("evil_staff", 0, this.getPosition());
					staff.set_u8("staffbase",this.get_u8("staffbase"));
					caller.server_Pickup(staff);
					hold.server_Die();
					this.server_Die();
				}
				if(hold.getName() == "gold_core"){
					CBlob@ staff = server_CreateBlob("goldlife_staff", 0, this.getPosition());
					staff.set_u8("staffbase",this.get_u8("staffbase"));
					caller.server_Pickup(staff);
					hold.server_Die();
					this.server_Die();
				}
				if(hold.getName() == "mat_gold"){
					CBlob@ staff = server_CreateBlob("gold_staff", 0, this.getPosition());
					staff.set_u8("staffbase",this.get_u8("staffbase"));
					caller.server_Pickup(staff);
					hold.server_Die();
					this.server_Die();
				}
				if(hold.getName() == "mat_stone"){
					CBlob@ staff = server_CreateBlob("stone_staff", 0, this.getPosition());
					staff.set_u8("staffbase",this.get_u8("staffbase"));
					caller.server_Pickup(staff);
					hold.server_Die();
					this.server_Die();
				}
				
				if(hold.getName() == "ghost_shard"){
					string name = "death_staff";
					if(hold.get_s16("corruption") > 250)name = "evildeath_staff";
					
					CBlob@ staff = server_CreateBlob(name, 0, this.getPosition());
					staff.set_u8("staffbase",this.get_u8("staffbase"));
					caller.server_Pickup(staff);
					
					CBlob @newBlob = server_CreateBlob("ghost", this.getTeamNum(), this.getPosition());
					if (newBlob !is null)
					{
						if(hold.getPlayer() !is null){
							staff.set_string("ghost",hold.getPlayer().getUsername());
							newBlob.server_SetPlayer(hold.getPlayer());
							hold.Tag("switch class");
							hold.server_SetPlayer(null);
						}
					}
					
					hold.server_Die();
					this.server_Die();
				}
			}
		}
	}
}