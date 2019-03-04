// Runescribe logic

#include "Hitters.as";
#include "Knocked.as";
#include "RunescribeCommon.as";
#include "ThrowCommon.as";
#include "RunnerCommon.as";
#include "Help.as";
#include "Requirements.as"
#include "PlacementCommon.as";
#include "RuneIcons.as";
#include "RuneNames.as";

//can't be <2 - needs one frame less for gathering infos
const s32 hit_frame = 2;
const f32 hit_damage = 0.5f;

void onInit(CBlob@ this)
{
	this.set_f32("gib health", -3.0f);

	this.Tag("player");
	this.Tag("flesh");
	
	this.set_string("scroll","");

	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
	shape.getConsts().net_threshold_multiplier = 0.5f;

	this.set_Vec2f("inventory offset", Vec2f(0.0f, 160.0f));

	for (uint i = 4; i < 24; i++)
	{
		this.addCommandID("wrote " + getRuneCodeName(i));
	}
	this.addCommandID("makescroll");
	this.addCommandID("backspace");
	
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if(player !is null)
	{
		player.SetScoreboardVars("ScoreboardIconsMod.png", 11, Vec2f(16, 16));
	}
}

void onTick(CBlob@ this)
{
	if(this.isInInventory())
		return;

	const bool ismyplayer = this.isMyPlayer();

	if(ismyplayer && getHUD().hasMenus())
	{
		return;
	}

	// activate/throw
	if(ismyplayer)
	{

		if(this.isKeyJustPressed(key_action3))
		{
			CBlob@ carried = this.getCarriedBlob();
			if(carried is null || !carried.hasTag("temp blob"))
			{
				client_SendThrowOrActivateCommand(this);
			}
		}
	}

	// slow down walking
	if(this.isKeyPressed(key_inventory))
	{
		RunnerMoveVars@ moveVars;
		if(this.get("moveVars", @moveVars))
		{
			moveVars.walkFactor = 0.2f;
			moveVars.jumpFactor = 0.0f;
		}
	}
}

void onCreateInventoryMenu(CBlob@ this, CBlob@ forBlob, CGridMenu @gridmenu)
{
	getScrollRuneIcons();
	this.ClearGridMenusExceptInventory();
	Vec2f pos(gridmenu.getUpperLeftPosition().x + 0.5f * (gridmenu.getLowerRightPosition().x - gridmenu.getUpperLeftPosition().x),
	          gridmenu.getUpperLeftPosition().y - 128 * 1 - 2 * 24);
	CGridMenu@ menu = CreateGridMenu(pos, this, Vec2f(4, 6), "Runes");
	
	AddIconToken("$makescroll$", "RuneSymbols.png", Vec2f(32, 16), 3);
	AddIconToken("$deletesymbol$", "RuneSymbols.png", Vec2f(32, 16), 4);
	
	if (menu !is null)
	{
		menu.deleteAfterClick = false;

		for (uint i = 4; i < 24; i++)
		{
			CGridButton @button = menu.AddButton("$"+getRuneCodeName(i)+"runescroll$", getRuneFriendlyName(i)+" rune", this.getCommandID("wrote " + getRuneCodeName(i)));

			if (button !is null)
			{
				button.SetEnabled(true);
				button.selectOneOnClick = true;

			}
		}
		
		menu.AddButton("$makescroll$", "Create scroll", this.getCommandID("makescroll"));
		menu.AddButton("$deletesymbol$", "Erase symbol", this.getCommandID("backspace"));
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{

	for (uint i = 4; i < 24; i++)
	{
		if (cmd == this.getCommandID("wrote " + getRuneCodeName(i)))
		{
			this.set_string("scroll",this.get_string("scroll")+getRuneLetter(i));
			break;
		}
	}
	
	if (cmd == this.getCommandID("backspace")){
		if(this.get_string("scroll").length() > 0)this.set_string("scroll",this.get_string("scroll").substr(0,this.get_string("scroll").length()-1));
	}
	
	if (cmd == this.getCommandID("makescroll"))if(this.get_string("scroll").length() > 0){
		if (getNet().isServer())
		{
			CBlob @blob = server_CreateBlob("scribesscroll", -1, this.getPosition());
			blob.set_string("scroll",this.get_string("scroll"));
		}
		this.set_string("scroll","");
	}
	
	//print("Current: " + this.get_string("scroll"));
}