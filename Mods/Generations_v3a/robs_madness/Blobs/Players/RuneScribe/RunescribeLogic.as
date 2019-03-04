/*
Do you really have to read this file?

That's kinda boring :/






















































*/


#include "Hitters.as";
#include "Knocked.as";
#include "RunescribeCommon.as";
#include "ThrowCommon.as";
#include "RunnerCommon.as";
#include "Help.as";
#include "Requirements.as"
#include "PlacementCommon.as";
#include "RunesCommon.as";
#include "EnergyCommon.as";

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
	
	if(this.isKeyPressed(key_action1))
	{
		if(getGameTime() % (4) == 0)ParticleAnimated("EnergyParticle.png", this.getPosition()+Vec2f(XORRandom(11)-5,XORRandom(11)-5), this.getVelocity()/10+Vec2f(XORRandom(3)-1,XORRandom(3)-1)*0.2, XORRandom(360), 1.0f, 3, -0.01, true);
		if(getGameTime() % (30*2) == 0){
			if(getEnergy(this) < this.get_u8("MaxEnergy"))
				addEnergy(this, 1);
			else
				setEnergy(this, this.get_u8("MaxEnergy"));
		}
	}
}

void onCreateInventoryMenu(CBlob@ this, CBlob@ forBlob, CGridMenu @gridmenu)
{
	getRuneIcons();
	this.ClearGridMenusExceptInventory();
	Vec2f pos(gridmenu.getUpperLeftPosition().x + 0.5f * (gridmenu.getLowerRightPosition().x - gridmenu.getUpperLeftPosition().x),
	          gridmenu.getUpperLeftPosition().y - 128 * 1 - 2 * 24);
	CGridMenu@ menu = CreateGridMenu(pos, this, Vec2f(4, 5), "Runes");
	
	this.set_Vec2f("InventoryPos",pos);
	
	AddIconToken("$makescroll$", "RuneSymbols.png", Vec2f(32, 16), 0);
	AddIconToken("$deletesymbol$", "RuneSymbols.png", Vec2f(32, 16), 1);
	
	if (menu !is null)
	{
		menu.deleteAfterClick = false;

		for (uint i = 4; i < 20; i++)
		{
			CGridButton @button = menu.AddButton("$"+getRuneCodeName(i)+"rune$", getRuneFriendlyName(i)+" rune", this.getCommandID("wrote " + getRuneCodeName(i)));

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
			if(this.get_string("scroll").length() < 8)
			this.set_string("scroll",this.get_string("scroll")+getRuneLetter(i));
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
			
			blob.set_u8("primary_ability",getPrimaryAbilityID(blob.get_string("scroll")));
			blob.set_u8("secondary_ability",getSecondaryAbilityID(blob.get_string("scroll")));
			blob.Sync("primary_ability",true);
			blob.Sync("secondary_ability",true);
			
			int HeatBarAmount = getRunesHeat(blob.get_string("scroll"));
			int FlowBarAmount = getRunesFlow(blob.get_string("scroll"));
			int ComplexityBarAmount = getRunesComplexity(blob.get_string("scroll"));
			int HolyBarAmount = 5+getRunesHoliness(blob.get_string("scroll"));
			
			int PowerBarAmount = HeatBarAmount;
			int CostBarAmount = HeatBarAmount-FlowBarAmount;
			
			CostBarAmount += ComplexityBarAmount;
			if(ComplexityBarAmount >= 6)PowerBarAmount += ComplexityBarAmount-5;
			
			if(CostBarAmount < 1)CostBarAmount = 1;
			CostBarAmount += secondaryCosts(getSecondaryAbilityID(blob.get_string("scroll")));
			if(CostBarAmount < 1)CostBarAmount = 1;
			
			blob.set_f32("power",(Maths::Clamp(PowerBarAmount, 0, 10)/10.0f));
			blob.set_u8("cost",Maths::Clamp(CostBarAmount, 1, 10));
			blob.Sync("power",true);
			blob.Sync("cost",true);
			
			
			blob.set_u8("heat",Maths::Clamp(HeatBarAmount, 0, 11));
			blob.set_u8("flow",Maths::Clamp(FlowBarAmount, 0, 10));
			blob.set_u8("holy",Maths::Clamp(HolyBarAmount, 0, 10));
			blob.set_u8("complexity",Maths::Clamp(ComplexityBarAmount, 0, 11));
			
			blob.Sync("heat",true);
			blob.Sync("flow",true);
			blob.Sync("holy",true);
			blob.Sync("complexity",true);
			
			
		}
		this.set_string("scroll","");
	}
}