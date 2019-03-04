// Archer logic

#include "ArcherCommon.as"
#include "ThrowCommon.as"
#include "Knocked.as"
#include "Hitters.as"
#include "RunnerCommon.as"
#include "ShieldCommon.as";
#include "Help.as";
#include "BombCommon.as";

const int FLETCH_COOLDOWN = 45;
const int PICKUP_COOLDOWN = 15;
const int fletch_num_arrows = 1;
const int STAB_DELAY = 10;
const int STAB_TIME = 22;

void onInit(CBlob@ this)
{
	ArcherInfo archer;
	this.set("archerInfo", @archer);
	this.set_u32("overheat", 0);
	this.set_u32("lasthit", 0);
	this.set_u32("lastfire", 0);
	this.set_u32("max overheat", 100);
	this.set_bool("overheated", false);
	this.set_s8("charge_time", 0);
	//this.set_u8("charge_state", ArcherParams::not_aiming);
	this.set_bool("has_arrow", false);
	this.set_f32("gib health", -3.0f);
	this.set_f32("accuracy", 3.0f);
	this.Tag("player");
	this.Tag("flesh");

	//centered on arrows
	//this.set_Vec2f("inventory offset", Vec2f(0.0f, 122.0f));
	//centered on items
	this.set_Vec2f("inventory offset", Vec2f(0.0f, 0.0f));

	//no spinning
	this.getShape().SetRotationsAllowed(false);
	this.getSprite().SetEmitSound("Entities/Characters/Archer/BowPull.ogg");


	this.addCommandID("swingsound");
	this.addCommandID("hitsound");
	this.addCommandID("shoot arrow");
	this.addCommandID("pickup arrow");
	this.addCommandID("force jump");

	this.getShape().getConsts().net_threshold_multiplier = 0.5f;

	SetHelp(this, "help self hide", "archer", "Hide    $KEY_S$", "", 1);
	SetHelp(this, "help self action2", "archer", "$Grapple$ Grappling hook    $RMB$", "", 3);

	for (uint i = 0; i < arrowTypeNames.length; i++)
	{
		this.addCommandID("pick " + arrowTypeNames[i]);
	}

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if (player !is null)
	{
		player.SetScoreboardVars("ScoreboardIcons.png", 2, Vec2f(16, 16));
	}
}


void ManageBow(CBlob@ this, ArcherInfo@ archer, RunnerMoveVars@ moveVars)
{
	CSprite@ sprite = this.getSprite();
	bool ismyplayer = this.isMyPlayer();
	bool hasarrow = archer.has_arrow;
	s8 charge_time = archer.charge_time;
	u8 charge_state = archer.charge_state;
	const bool pressed = this.isKeyPressed(key_action1);
	bool justpressed = this.isKeyJustPressed(key_action1);
	const bool pressed2 = this.isKeyPressed(key_action2);
	Vec2f pos = this.getPosition();
	u32 overheat = this.get_u32("overheat");
	u32 lastfire = this.get_u32("lastfire");
	bool canshoot = (!this.get_bool("overheated"));

	if (ismyplayer)
	{
		//fire gun
		if (justpressed)
		{
			if(overheat < 100 && canshoot)
			{
				{
					CBitStream params;
					Vec2f vel = Vec2f(100, 0);
					params.write_Vec2f(vel);
					this.SendCommand(this.getCommandID("force jump"), params);
					this.set_u32("lastfire", (lastfire+9));
					this.set_u32("overheat", 150);
				}
			}
		}

		if (!getHUD().hasButtons())
		{
			int frame = overheat/5;
			if(!canshoot)
			{
				frame = 20;
			}

			getHUD().SetCursorFrame(frame);
		}

	}
}

void onTick(CBlob@ this)
{
	CPlayer@ player = this.getPlayer();
	if (this.getTickSinceCreated() > 30 && player is null)
	{
 		this.getBrain().server_SetActive(true);
	}

	ArcherInfo@ archer;
	if (!this.get("archerInfo", @archer))
	{
		return;
	}

	if (getKnocked(this) > 0)
	{
		archer.charge_state = 0;
		archer.charge_time = 0;
		return;
	}

	bool canshoot = (!this.get_bool("overheated"));
	u32 overheat = this.get_u32("overheat");
	u32 lastfire = this.get_u32("lastfire");
	u32 lasthit = this.get_u32("lasthit");
	bool overheated = this.get_bool("overheated");
	if(overheat > 100 && !overheated)
	{
		lastfire = 0;
		this.set_u32("lastfire", lastfire);
		//printf("overheated!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
		overheated = true;
		this.set_bool("overheated", true);
	}	

	if(overheat < 60 && overheated)
	{
		overheated = false;
		this.set_bool("overheated", false);
	}
	if(overheat > 0)
	{
		overheat--;
		this.set_u32("overheat", overheat);
	}
	if(lastfire > 0)
	{
		lastfire--;
		this.set_u32("lastfire", lastfire);
	}


	if(lasthit > 0)
	{
		lasthit--;
		this.set_u32("lasthit", lasthit);
	}

	// vvvvvvvvvvvvvv CLIENT-SIDE ONLY vvvvvvvvvvvvvvvvvvv

	if (!getNet().isClient()) return;

	if (this.isInInventory()) return;

	RunnerMoveVars@ moveVars;
	if (!this.get("moveVars", @moveVars))
	{
		return;
	}


	ManageBow(this, archer, moveVars);
}



void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{		
	if (cmd == this.getCommandID("force jump"))
	{
		if (getNet().isServer())
		{
			Vec2f pos = this.getPosition();
			Vec2f aimpos = this.getAimPos();
			Vec2f dir = aimpos-pos;
			dir.Normalize();
			pos = pos+(dir*100);
			//print("shot position: "+ pos.x + ", " + pos.y);		
			//this.getSprite().PlaySound("BlasterFire.ogg");
			this.AddForce(dir*600);
		}

	}	
	if (cmd == this.getCommandID("swingsound"))
	{
		CSprite@ sprite = this.getSprite();
		if (sprite is null) return;
		string hitsound = ("Saber"+XORRandom(3)+".ogg");
		sprite.PlaySound(hitsound);
	}	
	if (cmd == this.getCommandID("hitsound"))
	{
		CSprite@ sprite = this.getSprite();
		if (sprite is null) return;
		string hitsound2 = ("SaberHit"+XORRandom(2)+".ogg");
		sprite.PlaySound(hitsound2);
	}	
}

// arrow pick menu
void onCreateInventoryMenu(CBlob@ this, CBlob@ forBlob, CGridMenu @gridmenu)
{
	if (arrowTypeNames.length == 0)
	{
		return;
	}

	this.ClearGridMenusExceptInventory();
	Vec2f pos(gridmenu.getUpperLeftPosition().x + 0.5f * (gridmenu.getLowerRightPosition().x - gridmenu.getUpperLeftPosition().x),
	          gridmenu.getUpperLeftPosition().y - 32 * 1 - 2 * 24);
	CGridMenu@ menu = CreateGridMenu(pos, this, Vec2f(arrowTypeNames.length, 2), "Current arrow");

	ArcherInfo@ archer;
	if (!this.get("archerInfo", @archer))
	{
		return;
	}
	const u8 arrowSel = archer.arrow_type;

}

// auto-switch to appropriate arrow when picked up
void onAddToInventory(CBlob@ this, CBlob@ blob)
{
	string itemname = blob.getName();
	if (this.isMyPlayer())
	{
		for (uint j = 0; j < arrowTypeNames.length; j++)
		{
			if (itemname == arrowTypeNames[j])
			{
				SetHelp(this, "help self action", "archer", "$arrow$Fire arrow   $KEY_HOLD$$LMB$", "", 3);
				if (j > 0 && this.getInventory().getItemsCount() > 1)
				{
					SetHelp(this, "help inventory", "archer", "$Help_Arrow1$$Swap$$Help_Arrow2$         $KEY_TAP$$KEY_F$", "", 2);
				}
				break;
			}
		}
	}

	CInventory@ inv = this.getInventory();
	if (inv.getItemsCount() == 0)
	{
		ArcherInfo@ archer;
		if (!this.get("archerInfo", @archer))
		{
			return;
		}

		for (uint i = 0; i < arrowTypeNames.length; i++)
		{
			if (itemname == arrowTypeNames[i])
			{
				archer.arrow_type = i;
			}
		}
	}
}

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	if (customData == Hitters::stab)
	{
		if (damage > 0.0f)
		{

			// fletch arrow
			if (hitBlob.hasTag("tree"))	// make arrow from tree
			{
				if (getNet().isServer())
				{
					CBlob@ mat_arrows = server_CreateBlob("mat_arrows", this.getTeamNum(), this.getPosition());
					if (mat_arrows !is null)
					{
						mat_arrows.server_SetQuantity(fletch_num_arrows);
						mat_arrows.Tag("do not set materials");
						this.server_PutInInventory(mat_arrows);
					}
				}
				this.getSprite().PlaySound("Entities/Items/Projectiles/Sounds/ArrowHitGround.ogg");
			}
			else
				this.getSprite().PlaySound("KnifeStab.ogg");
		}

		if (blockAttack(hitBlob, velocity, 0.0f))
		{
			this.getSprite().PlaySound("/Stun", 1.0f, this.getSexNum() == 0 ? 1.0f : 2.0f);
			SetKnocked(this, 30);
		}
	}
}

