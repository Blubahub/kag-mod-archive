#include "Hitters.as";
#include "Knocked.as";
#include "ThrowCommon.as";
#include "RunnerCommon.as";
#include "Help.as";
#include "Requirements.as"

//can't be <2 - needs one frame less for gathering infos
const s32 hit_frame = 2;
const f32 hit_damage = 0.5f;

void onInit(CBlob@ this)
{
	this.set_f32("gib health", -3.0f);

	this.Tag("player");
	
	this.set_s16("power",50);
	this.set_s16("timer",0);
	
	this.set_s16("smitetimer",0);
	
	this.SetLight(true);
	this.SetLightRadius(128.0f);
	this.SetLightColor(SColor(255, 255, 240, 171));
	
	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
	shape.getConsts().net_threshold_multiplier = 0.5f;

	this.set_Vec2f("inventory offset", Vec2f(0.0f, 160.0f));

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
	
	
	this.addCommandID("makesword");
	this.addCommandID("makeorb");
	this.addCommandID("makegoods");
	this.addCommandID("makefish");
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if(player !is null)
	{
		player.SetScoreboardVars("GoldenBeingIcon.png", 10, Vec2f(16, 16));
	}
}

void onTick(CBlob@ this)
{
	if(this.isInInventory())
		return;

	const bool ismyplayer = this.isMyPlayer();
	
	if(this.get_s16("timer") < 5*30)this.set_s16("timer",this.get_s16("timer")+1);
	else {
		this.set_s16("power",this.get_s16("power")-1);
		this.set_s16("timer",0);
	}
	
	
	if(this.get_s16("power") <= 0)this.server_Die();
	
	
	
	if(ismyplayer && getHUD().hasMenus())
	{
		return;
	}
	
	if (getNet().isServer())
	if(this.get_s16("smitetimer") > 60){
		if(this.isKeyPressed(key_action1))
		if(this.get_s16("power") > 20)
		{
			CBlob @blob = server_CreateBlob("hugesmite", -1, this.getPosition());
			if (blob !is null)
			{
			
				Vec2f smiteVel = this.getAimPos()-this.getPosition();
				smiteVel.Normalize();
				blob.setVelocity(smiteVel*16);
			}
			this.set_s16("smitetimer",0);
			this.set_s16("power",this.get_s16("power")-10);
		}
	} else this.set_s16("smitetimer",this.get_s16("smitetimer")+1);
	
	if (getNet().isServer())
	if(this.isKeyPressed(key_action2))
	{
		CBlob @blob = server_CreateBlob("goldendrop", -1, this.getPosition()+Vec2f(XORRandom(64)-32,0));
		if (blob !is null)
		{
			Vec2f smiteVel = Vec2f(0,1);
			smiteVel.Normalize();
			blob.setVelocity(smiteVel*1);
		}
		this.set_s16("timer",this.get_s16("timer")+1);
	}
	
	if(getNet().isServer())this.Sync("power", true);
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return false;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	
	return 0; //no block, damage goes through
}

void onCreateInventoryMenu(CBlob@ this, CBlob@ forBlob, CGridMenu @gridmenu)
{
	this.ClearGridMenusExceptInventory();
	Vec2f pos(gridmenu.getUpperLeftPosition().x + 0.5f * (gridmenu.getLowerRightPosition().x - gridmenu.getUpperLeftPosition().x),
	          gridmenu.getUpperLeftPosition().y - 128 * 1 - 2 * 24);
	CGridMenu@ menu = CreateGridMenu(pos, this, Vec2f(4, 1), "Abilities");
	
	AddIconToken("$herosword$", "HeroSword.png", Vec2f(16, 16), 0);
	AddIconToken("$goldenorb$", "GoldenOrb.png", Vec2f(16, 16), 0);
	AddIconToken("$goldenfish$", "GoldenFish.png", Vec2f(16, 16), 0);
	
	if (menu !is null)
	{
		menu.deleteAfterClick = true;
		{
			CGridButton@ b = menu.AddButton("$herosword$", "Create a sword which a human can use to become a hero! Costs 500 golden essence.", this.getCommandID("makesword"));
			if(this.get_s16("power") <= 500)b.SetEnabled(false);
		}
		
		{
			CGridButton@ b = menu.AddButton("$goldenorb$", "Create a shiney golden orb to light up dark places. Costs 10 golden essence.", this.getCommandID("makeorb"));
			if(this.get_s16("power") <= 10)b.SetEnabled(false);
		}
		
		{
			CGridButton@ b = menu.AddButton("$mat_stone$", "A blessing of goods for the mortals! Costs 10 golden essence.", this.getCommandID("makegoods"));
			if(this.get_s16("power") <= 10)b.SetEnabled(false);
		}
		
		{
			CGridButton@ b = menu.AddButton("$goldenfish$", "Create an item to immortalize your favourite follower! Costs 30 golden essence.", this.getCommandID("makefish"));
			if(this.get_s16("power") <= 30)b.SetEnabled(false);
		}
		
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	
	if (cmd == this.getCommandID("makesword"))if(this.get_s16("power") > 500){
		if (getNet().isServer())
		{
			CBlob @blob = server_CreateBlob("herosword", -1, this.getPosition());
			blob.set_string("owner",this.getPlayer().getUsername());
		}
		this.set_s16("power",this.get_s16("power")-500);
	}
	
	if (cmd == this.getCommandID("makeorb")){
		if (getNet().isServer())
		{
			CBlob @blob = server_CreateBlob("goldenorb", -1, this.getPosition());
			blob.set_string("owner",this.getPlayer().getUsername());
		}
		this.set_s16("power",this.get_s16("power")-10);
	}
	
	if (cmd == this.getCommandID("makegoods")){
		string goods = "log";
		if(XORRandom(4) == 0)goods = "mat_stone";
		if(XORRandom(3) == 0)goods = "mat_wood";
		if (getNet().isServer())
		{
			CBlob @blob = server_CreateBlob(goods, -1, this.getPosition());
		}
		this.set_s16("power",this.get_s16("power")-10);
	}
	
	if (cmd == this.getCommandID("makefish")){
		if (getNet().isServer())
		{
			CBlob @blob = server_CreateBlob("goldenfish", -1, this.getPosition());
		}
		this.set_s16("power",this.get_s16("power")-30);
	}
}

