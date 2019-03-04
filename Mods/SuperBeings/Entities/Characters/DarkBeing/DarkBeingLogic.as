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
	
	this.set_s16("power",10);
	this.set_s16("timer",0);
	
	this.set_s16("smitetimer",0);
	
	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
	shape.getConsts().net_threshold_multiplier = 0.5f;

	this.set_Vec2f("inventory offset", Vec2f(0.0f, 160.0f));

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
	
	
	this.addCommandID("makenecro");
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
	if(this.get_s16("smitetimer") > 3){
		if(this.isKeyPressed(key_action1))
		{
			CBlob @blob = server_CreateBlob("darkmissile", -1, this.getPosition()+Vec2f(XORRandom(32)-16,XORRandom(32)-16));
			if (blob !is null)
			{
			
				Vec2f smiteVel = this.getAimPos()-this.getPosition();
				smiteVel.Normalize();
				blob.setVelocity(smiteVel*8);
				this.set_s16("power",this.get_s16("power")-1);
			}
			this.set_s16("smitetimer",0);
		}
	} else this.set_s16("smitetimer",this.get_s16("smitetimer")+1);
	
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return false;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{

	if(Hitters::suddengib != customData)return 0;
	
	return damage; //no block, damage goes through
}

void onCreateInventoryMenu(CBlob@ this, CBlob@ forBlob, CGridMenu @gridmenu)
{
	this.ClearGridMenusExceptInventory();
	Vec2f pos(gridmenu.getUpperLeftPosition().x + 0.5f * (gridmenu.getLowerRightPosition().x - gridmenu.getUpperLeftPosition().x),
	          gridmenu.getUpperLeftPosition().y - 128 * 1 - 2 * 24);
	CGridMenu@ menu = CreateGridMenu(pos, this, Vec2f(4, 1), "Abilities");
	
	AddIconToken("$necrobook$", "NecroBook.png", Vec2f(16, 16), 0);
	
	if (menu !is null)
	{
		menu.deleteAfterClick = true;
		
		menu.AddButton("$necrobook$", "Give a mortal control over life and death. Costs 50 death.", this.getCommandID("makenecro"));
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	
	if (cmd == this.getCommandID("makenecro")){
		if(this.get_s16("power") > 50)
		{
			bool haveNecro = false;
			CBlob@[] fg;
			getBlobsByName("necrobook", @fg);
			getBlobsByName("necro", @fg);
			for(uint i = 0; i < fg.length; i++)
			{
				if(this.getPlayer().getUsername() == fg[i].get_string("owner")){
					haveNecro = true;
				}
			}
			
			if(!haveNecro){
				if (getNet().isServer())
				{
					CBlob @blob = server_CreateBlob("necrobook", -1, this.getPosition());
					blob.set_string("owner",this.getPlayer().getUsername());
				}
				this.set_s16("power",this.get_s16("power")-50);
			}
		}
	}
}

