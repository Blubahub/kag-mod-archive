
void onInit(CBlob@ this)
{
	this.server_setTeamNum(-1);
	
	this.addCommandID("use");
	this.addCommandID("weave");
	
	this.set_u8("hemp",0);
	
	this.getSprite().animation.frame = 0;
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(caller.getCarriedBlob() !is this){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		
		CButton@ button = caller.CreateGenericButton(15, Vec2f(0,0), this, this.getCommandID("use"), "Use", params);
	}
}

void onTick(CBlob @this){

	if(this.getSprite() !is null){
		this.getSprite().animation.frame = this.get_u8("hemp");
	}

}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("use"))
	{	
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null)
		{
			if(this.get_u8("hemp") < 3){
				CBlob@ hold = caller.getCarriedBlob();
				if(hold !is null){
					if(getNet().isServer()){
						if(hold.getName() == "mat_hemp"){
							if(caller.hasBlob("mat_hemp", 10)){
								this.set_u8("hemp",this.get_u8("hemp")+1);
								this.Sync("hemp",true);
								caller.TakeBlob("mat_hemp", 10);
							}
						}
					}
				}
			} else {
				if(caller.getPlayer() is getLocalPlayer()){
					CGridMenu@ menu = CreateGridMenu(getDriver().getScreenCenterPos() + Vec2f(0.0f, 0.0f), this, Vec2f(2, 1), "Weave");
					if (menu !is null)
					{
						CAttachment@ attach = this.getAttachments();
						{
							CBitStream params;
							params.write_u8(0);
							AddIconToken("$flax_icon$", "Flax.png", Vec2f(11, 6), 0);
							CGridButton @but = menu.AddButton("$flax_icon$", "Flax", this.getCommandID("weave"),params);
						}
						{
							CBitStream params;
							params.write_u8(1);
							AddIconToken("$rope_icon$", "Rope.png", Vec2f(16, 16), 0);
							CGridButton @but = menu.AddButton("$rope_icon$", "Rope", this.getCommandID("weave"),params);
						}
					}
				}
			}
		}
	}
	if (cmd == this.getCommandID("weave"))
	{
		int ID = params.read_u8();
		if(!this.hasTag("weaved"))
		if(getNet().isServer()){
			if(ID == 0)server_CreateBlob("flax",-1,this.getPosition());
			if(ID == 1)server_CreateBlob("rope",-1,this.getPosition());
			server_CreateBlob("stick",-1,this.getPosition());
			this.server_Die();
			
			this.Tag("weaved");
		}
	}
}