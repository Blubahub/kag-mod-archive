
void onInit(CBlob@ this)
{
	this.set_u8("meat",0);
	this.set_u8("plant",0);
	this.set_u8("starch",0);
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("drink"))
	{	
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if(caller !is null && !this.hasTag("drank"))
		{
			if(caller.hasTag("researched_blood") || caller.get_s16("blood_amount") <= 90 || caller.get_u8("blood_addiction") >= 5){
			
				if(getNet().isClient())this.getSprite().PlaySound("wetfall2.ogg");
			
				caller.set_s16("blood_amount", caller.get_s16("blood_amount")+10);
				
				caller.set_u8("blood_addiction", caller.get_u8("blood_addiction")+1);
				
				caller.Tag("blood_knowledge");
				
				this.Tag("drank");
				
				if(caller.hasTag("blood_addict"))caller.set_u8("food_blood",caller.get_u8("food_blood")+5);
				
				if(getNet().isServer()){
					caller.Sync("blood_amount",true);
					caller.Sync("blood_addiction",true);
					caller.Sync("blood_knowledge",true);
					if(caller.hasTag("blood_addict"))caller.Sync("food_blood",true);
					
					this.server_Die();
					caller.server_Pickup(server_CreateBlob("jar",0,this.getPosition()));
				}
			} else {
				caller.Chat("Ew, I shouldn't drink this blood.");
			}
			
		}
	}
}