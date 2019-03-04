
#include "Hitters.as";
#include "li.as";

void onInit(CBlob @ this)
{
	this.set_TileType("background tile", CMap::tile_empty);
	if(getNet().isServer()){
		for(int i=-1;i <2;i++)
		getMap().server_SetTile(this.getPosition()+Vec2f(i*8,8), CMap::tile_castle_back);
	}

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.addCommandID("place_item");
	
	this.addCommandID("convert_gold");
	this.addCommandID("convert_dark");
	
	this.addCommandID("convert_soul");
	
	this.addCommandID("convert_nature");
	this.addCommandID("convert_blood");
	
	this.addCommandID("convert_fire");
	this.addCommandID("convert_air");
	
	this.addCommandID("sacrifice");
	
	this.set_u8("type",0);

	AddIconToken("$gold_bar_icon$", "GoldBar.png", Vec2f(13, 6), 0);
	
	this.getCurrentScript().tickFrequency = 30;
}

void onTick(CBlob@ this)
{
	this.getSprite().SetFrame(this.get_u8("type"));
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	
	int type = this.get_u8("type");
	
	if(caller.getCarriedBlob() !is null){
		
		if(type == 0){
			if(caller.getCarriedBlob().getName() == "gold_bar")
			if(caller.getCarriedBlob().hasTag("light_infused")){
				caller.CreateGenericButton("$gold_bar_icon$", Vec2f(0,4), this, this.getCommandID("convert_gold"), "Infuse gold", params);
			}
		}
		
		//if(this.isAttachedToPoint("OFFER")){caller.CreateGenericButton(15, Vec2f(0,0), this, this.getCommandID("open_menu"), "Smith", params);}
		
		if(!this.isAttachedToPoint("OFFER")){
			caller.CreateGenericButton(19, Vec2f(0,-4), this, this.getCommandID("place_item"), "Place Offering", params);
		}
	} else {
		if(this.isAttachedToPoint("OFFER")){
			caller.CreateGenericButton(16, Vec2f(0,-4), this, this.getCommandID("place_item"), "Remove Offering", params);
		}
		
		CAttachment @attaches = this.getAttachments();
		CBlob @offering = attaches.getAttachedBlob("OFFER");
		
		if(type == 1){
			if(!caller.hasTag("light_ability"))caller.CreateGenericButton(16, Vec2f(0,4), this, this.getCommandID("sacrifice"), "Repent your evil", params);
			else{
				if(offering !is null)
				if(offering.getName() == "gold_bar"){
					caller.CreateGenericButton(16, Vec2f(0,4), this, this.getCommandID("sacrifice"), "Sacrifice gold", params);
				}
			}
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	
	if (cmd == this.getCommandID("place_item"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null)
		{
			if(getNet().isServer()){
				
				if(this.isAttachedToPoint("OFFER")){
					CAttachment@ attach = this.getAttachments();
					if(attach.getAttachedBlob("OFFER") !is null){
						CBlob @attachedBlob = attach.getAttachedBlob("OFFER");
						if(getNet().isServer()){
							this.server_DetachFrom(attachedBlob);
						}
					}
				} else {
				
					CBlob@ hold = caller.getCarriedBlob();
					if(hold !is null){
						caller.DropCarried();
						if(getNet().isServer()){
							this.server_AttachTo(hold, "OFFER");
						}
					}
				
				}
			}
		}
	}
	
	if (cmd == this.getCommandID("convert_gold"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null)
		{
			if(getNet().isServer()){
				
				if(caller.getCarriedBlob() !is null)caller.getCarriedBlob().server_Die();
				
			}
			
			this.set_u8("type",1);
		}
	}
	
	if (cmd == this.getCommandID("sacrifice"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null)
		{
			int type = this.get_u8("type");
		
			CAttachment @attaches = this.getAttachments();
			CBlob @offering = attaches.getAttachedBlob("OFFER");
		
			if(type == 1){
				if(!caller.hasTag("light_ability")){
					if(getNet().isServer()){
						caller.Tag("light_ability");
						
						restore(this, caller, 100.0f); //This almost gibs evil users
						
						caller.Sync("light_ability",true);
					}
				} else {
					if(getNet().isServer()){
						if(offering !is null)
						if(offering.getName() == "gold_bar"){
							
							offering.server_Die();
							
							bool gave = false;
							
							CBlob@[] blobs;	   
							getBlobsByName("gorb", @blobs);
							for (uint i = 0; i < blobs.length; i++)
							{
								CBlob@ b = blobs[i];
								if(b !is null){
									if(this.getDistanceTo(b) < 128){
										gave = true;
										if(b.get_u16("gold_amount") < 1000)b.add_u16("gold_amount",10);
										b.Sync("gold_amount",true);
										break;
									}
								}
							}
							
							if(!gave){
								server_CreateBlob("gorb",-1,this.getPosition());
							}
						}
					}
				}
			}
		}
	}
}