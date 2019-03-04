
void onInit(CBlob@ this)
{
	this.server_setTeamNum(-1);
	
	this.addCommandID("use");
	
	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(caller.getCarriedBlob() !is this){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		
		CButton@ button = caller.CreateGenericButton(15, Vec2f(0,0), this, this.getCommandID("use"), "Requires 50 Hemp", params);
	}
}

void onInit(CSprite @this){
	this.RemoveSpriteLayer("wheel");
	CSpriteLayer@ backarm = this.addSpriteLayer("wheel", "Loom.png" , 21, 21, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (backarm !is null)
	{
		Animation@ anim = backarm.addAnimation("default", 0, false);
		anim.AddFrame(0);
		backarm.SetRelativeZ(-0.1);
	}
}


void onTick(CSprite @this){

	if(this.getSpriteLayer("wheel") !is null){
		this.getSpriteLayer("wheel").RotateBy(10,Vec2f(0,0));
	}

}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("use"))
	{	
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null)
		{
			CBlob@ hold = caller.getCarriedBlob();
			if(hold !is null){
				if(getNet().isServer()){
					if(hold.getName() == "mat_hemp"){
						caller.TakeBlob("mat_hemp", 50);
						server_CreateBlob("cloth",-1,this.getPosition());
					}
				}
			}
		}
	}
}