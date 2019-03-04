
#include "RuneNames.as";
#include "FireCommon.as";
#include "Hitters.as";
#include "Health.as";

void onInit(CBlob@ this)
{
	this.set_u8("rune",24);
	
	this.set_u8("nextchaosrune",XORRandom(24));
	
	this.getSprite().SetZ(-49); //background
	
	this.addCommandID("scribe");
	
	this.addCommandID("use");
	
	this.set_string("target","");
	
	for(uint i = 0; i < 24; i += 1)this.addCommandID("runecmd"+i);
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(this.get_u8("rune") == 24)
	if(!this.isAttached()){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		
		string text = "Requires a heart";
		if(caller.getCarriedBlob() !is null)
			if(caller.getCarriedBlob().getName() == "heart")
				text = "Scribe rune";
		
		CButton@ button = caller.CreateGenericButton(11, Vec2f(0,4), this, this.getCommandID("scribe"), text, params);
		button.SetEnabled(text == "Scribe rune");
	}
	if(this.get_u8("rune") != 24)
	if(caller.getCarriedBlob() is this){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		CButton@ button = caller.CreateGenericButton(11, Vec2f(0,4), this, this.getCommandID("use"), "Use parchment", params);
	}
}

void onTick(CBlob@ this){
	UpdateFrame(this.getSprite());
}

void UpdateFrame(CSprite@ this)
{
	this.SetFrame(this.getBlob().get_u8("rune"));
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	u16 callerID = params.read_u16();
	CBlob@ caller = getBlobByNetworkID(callerID);
	if(caller !is null)
	{
		if (cmd == this.getCommandID("scribe"))
		{
			CBlob@ hold = caller.getCarriedBlob();
			if(hold !is null)if(getNet().isServer()){
				this.set_string("target",hold.get_string("username"));
				if(getPlayerByUsername(this.get_string("target")) is null){
					if(caller.getPlayer() !is null)this.set_string("target",caller.getPlayer().getUsername());
				}
				hold.server_Die();
			}
			if(caller.isMyPlayer()){
				CGridMenu@ menu = CreateGridMenu(getDriver().getScreenCenterPos() + Vec2f(0.0f, 0.0f), this, Vec2f(4, 5), "Scribe a rune");
				if (menu !is null)
				{
					for(uint i = 4; i < 24; i += 1)
					{
						AddIconToken("$rune"+i+"$", "Runes.png", Vec2f(8, 8), i);
						menu.AddButton("$rune"+i+"$", "Scribe "+getRuneFriendlyName(i)+" rune", this.getCommandID("runecmd"+i));
					}
				}
			}
		}
	}
	for(uint i = 0; i < 24; i += 1)
	if (cmd == this.getCommandID("runecmd"+i))
	{
		if(getNet().isServer()){
			this.set_u8("rune",i);
			this.Sync("rune",true);
		}
	}
	
	if (cmd == this.getCommandID("use"))
	{
		int rune = this.get_u8("rune");
		if(rune == 15){
			rune = this.get_u8("nextchaosrune");
			this.set_u8("nextchaosrune",XORRandom(24));
			if(getNet().isServer())this.Sync("nextchaosrune",true);
		}
		
		if(getPlayerByUsername(this.get_string("target")) is null)return;
		
		CBlob @blob = getPlayerByUsername(this.get_string("target")).getBlob();
		
		if(blob is null)return;
		
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		CBlob@ holder = point.getOccupied();
		
		if(rune == 4){
			blob.server_Hit(blob, blob.getPosition(), Vec2f(0,0), 1.0f, Hitters::fire, false);
		}
		
		if(rune == 5)if(getNet().isServer()){
			CBlob @bomb = server_CreateBlob("waterbomb", -1, blob.getPosition());
			if (bomb !is null)
			{
				bomb.set_f32("map_damage_ratio", 0.0f);
				bomb.set_f32("explosive_damage", 0.0f);
				bomb.set_f32("explosive_radius", 32.0f);
				bomb.set_bool("map_damage_raycast", false);
				bomb.set_string("custom_explosion_sound", "/GlassBreak");
				bomb.set_u8("custom_hitter", Hitters::water);
				bomb.Tag("splash ray cast");
			}
		}
		
		if(rune == 6)if(getNet().isServer()){
			CBlob @boulder = server_CreateBlob("boulder", -1, Vec2f(blob.getPosition().x,0));
			if (boulder !is null)
			{
				boulder.setVelocity(Vec2f(0,10));
				boulder.set_u8("launch team", -1);
			}
		}
		
		if(rune == 7)if(getNet().isServer()){
			blob.Tag("wind");
			blob.Sync("wind",true);
		}
		
		if(rune == 8)if(getNet().isServer()){
			Heal(blob,1.5);
		}
		
		if(rune == 9)if(getNet().isServer()){
			blob.set_s16("poison",12);
			blob.Sync("poison",true);
		}
		
		if(holder !is null)
		if(rune == 10)if(getNet().isServer()){
			if(holder !is this){
				Heal(holder,1.0);
				OverHeal(blob,-1.0);
			}
		}
		
		if(rune == 11)if(getNet().isServer()){
			blob.set_s16("nature_regen",12);
			blob.Sync("nature_regen",true);
		}
		
		if(rune == 12)if(getNet().isServer()){
			blob.set_u8("race",XORRandom(3));
			if(XORRandom(2) == 0)blob.set_u8("race",4);
			blob.Sync("race",true);
		}
		
		if(holder !is null)
		if(rune == 13){
			if(blob.getTeamNum() == holder.getTeamNum()){
				blob.setPosition(holder.getPosition());
			} else {
				holder.setPosition(blob.getPosition());
				holder.DropCarried();
			}
		}
		
		if(rune == 16)if(getNet().isServer()){
			blob.set_s16("golden_shield",300);
			blob.Sync("golden_shield",true);
		}
		
		if(holder !is null)
		if(rune == 17)if(blob.get_s16("life") > 0){
			int Amount = Maths::Min(blob.get_s16("life"),5);
			holder.set_s16("life",holder.get_s16("life")+Amount);
			holder.set_s16("death",holder.get_s16("death")-Amount);
			if(holder.get_s16("death") < 0)holder.set_s16("death",0);
			blob.set_s16("death",blob.get_s16("death")+Amount);
			blob.set_s16("life",blob.get_s16("life")-Amount);
			holder.server_Hit(blob, blob.getPosition(), Vec2f(0,0), 0.5f, Hitters::suddengib, false);
		}
		
		if(holder !is null)
		if(rune == 18)if(getNet().isServer()){
			holder.set_s16("haste",150);
			holder.Sync("haste",true);
			blob.set_s16("slow",150);
			blob.Sync("slow",true);
		}
		
		if(rune == 19)if(getNet().isServer()){
			blob.Tag("cleanse");
			blob.Sync("cleanse",true);
		}
		
		if(rune == 20)if(getNet().isServer()){
			blob.set_u8("race",1);
			blob.Sync("race",true);
		}
		
		if(rune == 21)if(blob.get_s16("life") > 0){
			int Amount = Maths::Min(blob.get_s16("life"),10);
			blob.set_s16("death",blob.get_s16("death")+Amount);
			blob.set_s16("life",blob.get_s16("life")-Amount);
		}
		
		if(rune == 22)if(getNet().isServer()){
			blob.set_s16("slow",300);
			blob.Sync("slow",true);
		}
		
		if(rune == 23)if(getNet().isServer()){
			blob.set_s16("poison_plague",30*60);
			blob.Sync("poison_plague",true);
		}
		
		if(XORRandom(2) == 0){
			this.server_Die();
		}
	}
}