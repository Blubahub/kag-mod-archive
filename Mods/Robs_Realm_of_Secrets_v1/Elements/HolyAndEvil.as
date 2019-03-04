
#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.set_string("boss","");
	
	this.set_s16("power",100);
	this.set_s16("corruption",0);
	this.set_s16("kills",0);
	
	//this.Tag("evil");
	//this.Tag("holy");
	
	this.addCommandID("makeshadow");
}


void onTick(CBlob @ this)
{

	int corruption = this.get_s16("corruption");

	CPlayer@ player = this.getPlayer();
	if(player !is null)
	if(this.get_string("boss") != player.getUsername()){
		CPlayer@ PlayerBoss = getPlayerByUsername(this.get_string("boss"));
		if(PlayerBoss !is null){
			CBlob@ Boss = PlayerBoss.getBlob();
			if (Boss !is null)
			if(!Boss.hasTag("ghost"))
			{
				if(corruption > 0)
				if(!Boss.hasTag("holy")){
					Boss.set_s16("corruption",Boss.get_s16("corruption")+1);
					corruption -= 1;
				}
				
				this.set_s16("power",Boss.get_s16("power"));
			}
		}
	}
	
	if(this.hasTag("evil")){
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), 32.0f, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(b.hasTag("gold") || b.getName() == "mat_gold")
				{
					if(this.getName() == "darkbeing")this.set_s16("power",this.get_s16("power")-1);
					else {
						this.server_Hit(this, this.getPosition(), Vec2f(), 0.25f, Hitters::suddengib);
					}
				}
			}
		}
		this.Untag("holy");
	}
	
	this.set_s16("corruption",corruption);

}


void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData){

	if(hitBlob.getHealth() <= 0)
	if(hitBlob.get_s16("corruption") <= this.get_s16("corruption"))
	if(!hitBlob.hasTag("evil"))
	if(hitBlob.hasTag("flesh") && !hitBlob.hasTag("lifeless"))
	if(hitBlob.getTeamNum() == this.getTeamNum() || hitBlob.getTeamNum() > 20 || hitBlob.hasTag("holy") || this.hasTag("evil"))
	if(hitBlob.getHealth()+damage > 0){
		this.set_s16("corruption",this.get_s16("corruption")+10);
		this.set_s16("kills",this.get_s16("kills")+1);
		if(getNet().isServer())this.Sync("corruption",true);
	}

}





void onCreateInventoryMenu(CBlob@ this, CBlob@ forBlob, CGridMenu @gridmenu)
{
	if(this.get_s16("corruption") > 0 && (this.hasTag("evil") || this.hasTag("evil_potential"))){
		Vec2f pos(gridmenu.getUpperLeftPosition().x + 0.5f * (gridmenu.getLowerRightPosition().x - gridmenu.getUpperLeftPosition().x),
				  gridmenu.getUpperLeftPosition().y + 32 * 6 - 16);
		CGridMenu@ menu = CreateGridMenu(pos, this, Vec2f(2,2), "Dark Abilities");

		AddIconToken("$shadowblade$", "ShadowBlade.png", Vec2f(16, 16), 0);
		
		if (menu !is null)
		{
			menu.deleteAfterClick = false;
			
			{
				CGridButton@ b = menu.AddButton("$shadowblade$", "Conjure a sword of corruption, whoever uses it shall be bound to you.", this.getCommandID("makeshadow"));
				if(this.get_s16("corruption") <= 50)b.SetEnabled(false);
			}
			
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	
	if (cmd == this.getCommandID("makeshadow")){
		if(this.get_s16("corruption") > 50)
		{
			if (getNet().isServer())
			{
				CBlob @blob = server_CreateBlob("shadowblade", -1, this.getPosition());
				blob.set_string("boss",this.getPlayer().getUsername());
				this.set_s16("corruption",this.get_s16("corruption")-50);
				this.Tag("evil");
				this.Sync("corruption",true);
				this.Sync("evil",true);
			}
		}
	}
}