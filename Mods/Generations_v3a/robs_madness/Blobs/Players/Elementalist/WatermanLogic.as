// Waterman logic

#include "WatermanCommon.as"
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
	WatermanInfo waterman;
	this.set("watermanInfo", @waterman);

	this.set_s8("charge_time", 0);
	this.set_bool("playedfire",false);
	this.set_u8("charge_state", WatermanParams::not_aiming);
	this.set_bool("has_arrow", false);
	this.set_f32("gib health", -3.0f);
	this.Tag("player");
	this.Tag("flesh");
	this.Tag("no_breathe");
	this.Tag("unflammable");

	//centered on arrows
	//this.set_Vec2f("inventory offset", Vec2f(0.0f, 122.0f));
	//centered on items
	this.set_Vec2f("inventory offset", Vec2f(0.0f, 0.0f));

	//no spinning
	this.getShape().SetRotationsAllowed(false);
	this.getSprite().SetEmitSound("Entities/Characters/Archer/BowPull.ogg");
	this.addCommandID("shoot arrow");
	this.addCommandID("pickup arrow");
	this.getShape().getConsts().net_threshold_multiplier = 0.5f;

	//add a command ID for each arrow type
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
		player.SetScoreboardVars("ScoreboardIconsMod.png", 1, Vec2f(16, 16));
	}
}

void ManageBow(CBlob@ this, WatermanInfo@ waterman, RunnerMoveVars@ moveVars)
{
	CSprite@ sprite = this.getSprite();
	bool ismyplayer = this.isMyPlayer();
	bool hasarrow = true;
	s8 charge_time = waterman.charge_time;
	u8 charge_state = waterman.charge_state;
	const bool pressed_action2 = this.isKeyPressed(key_action2);
	Vec2f pos = this.getPosition();

	if (charge_state == WatermanParams::legolas_charging) // fast arrows
	{
		charge_state = WatermanParams::legolas_ready;
	}
	//charged - no else (we want to check the very same tick)
	if (charge_state == WatermanParams::legolas_ready) // fast arrows
	{
		moveVars.walkFactor *= 0.75f;

		waterman.legolas_time--;
		if (waterman.legolas_time == 0)
		{
			bool pressed = this.isKeyPressed(key_action1);
			charge_state = pressed ? WatermanParams::readying : WatermanParams::not_aiming;
			charge_time = 0;
			//didn't fire
			if (waterman.legolas_arrows == WatermanParams::legolas_arrows_count)
			{
				Sound::Play("/Stun", pos, 1.0f, this.getSexNum() == 0 ? 1.0f : 2.0f);
				SetKnocked(this, 15);
			}
			else if (pressed)
			{
				sprite.RewindEmitSound();
				sprite.SetEmitSoundPaused(false);
			}
		}
		else if (this.isKeyJustPressed(key_action1) ||
		         (waterman.legolas_arrows == WatermanParams::legolas_arrows_count &&
		          !this.isKeyPressed(key_action1) &&
		          this.wasKeyPressed(key_action1)))
		{
			ClientFire(this, charge_time, hasarrow, waterman.arrow_type, true);
			charge_state = WatermanParams::legolas_charging;
			charge_time = WatermanParams::shoot_period - WatermanParams::legolas_charge_time;
			Sound::Play("FastBowPull.ogg", pos);
			waterman.legolas_arrows--;

			if (waterman.legolas_arrows == 0)
			{
				charge_state = WatermanParams::readying;
				charge_time = 5;

				sprite.RewindEmitSound();
				sprite.SetEmitSoundPaused(false);
			}
		}

	}
	else if (this.isKeyPressed(key_action1))
	{

		const bool just_action1 = this.isKeyJustPressed(key_action1);

		//	printf("charge_state " + charge_state );

		if ((just_action1 || this.wasKeyPressed(key_action2) && !pressed_action2) &&
		        (charge_state == WatermanParams::not_aiming || charge_state == WatermanParams::fired))
		{
			charge_state = WatermanParams::readying;
			waterman.arrow_type = ArrowType::normal;

			charge_time = 0;

			sprite.PlayRandomSound("/WaterBubble");

			sprite.RewindEmitSound();
			sprite.SetEmitSoundPaused(false);

			if (!ismyplayer)   // lower the volume of other players charging  - ooo good idea
			{
				sprite.SetEmitSoundVolume(0.5f);
			}
		}
		else if (charge_state == WatermanParams::readying)
		{
			charge_time++;

			if (charge_time > WatermanParams::ready_time)
			{
				charge_time = 1;
				charge_state = WatermanParams::charging;
			}
		}
		else if (charge_state == WatermanParams::charging)
		{
			charge_time++;

			if (charge_time >= WatermanParams::legolas_period)
			{
				// Legolas state
				charge_state = WatermanParams::legolas_charging;
				charge_time = WatermanParams::shoot_period - WatermanParams::legolas_charge_time;

				waterman.legolas_arrows = WatermanParams::legolas_arrows_count;
				waterman.legolas_time = WatermanParams::legolas_time;
			}

			if (charge_time >= WatermanParams::shoot_period)
				sprite.SetEmitSoundPaused(true);
		}
		else if (charge_state == WatermanParams::no_arrows)
		{
			if (charge_time < WatermanParams::ready_time)
			{
				charge_time++;
			}
		}
	}
	else
	{
		if (charge_state > WatermanParams::readying)
		{
			if (charge_state < WatermanParams::fired)
			{
				if (waterman.charge_time >= WatermanParams::shoot_period-10)ClientFire(this, charge_time, hasarrow, waterman.arrow_type, false);

				charge_time = WatermanParams::fired_time;
				charge_state = WatermanParams::fired;
			}
			else //fired..
			{
				charge_time--;

				if (charge_time <= 0)
				{
					charge_state = WatermanParams::not_aiming;
					charge_time = 0;
				}
			}
		}
		else
		{
			charge_state = WatermanParams::not_aiming;    //set to not aiming either way
			charge_time = 0;
		}

		sprite.SetEmitSoundPaused(true);
	}

	// my player!

	if (ismyplayer)
	{
		// set cursor

		if (!getHUD().hasButtons())
		{
			int frame = 0;
			//	print("waterman.charge_time " + waterman.charge_time + " / " + WatermanParams::shoot_period );
			if (waterman.charge_state == WatermanParams::readying)
			{
				frame = 1 + float(waterman.charge_time) / float(WatermanParams::shoot_period + WatermanParams::ready_time) * 7;
			}
			else if (waterman.charge_state == WatermanParams::charging)
			{
				if (waterman.charge_time <= WatermanParams::shoot_period)
				{
					frame = float(WatermanParams::ready_time + waterman.charge_time) / float(WatermanParams::shoot_period) * 7;
				}
				else
					frame = 9;
			}
			else if (waterman.charge_state == WatermanParams::legolas_ready)
			{
				frame = 10;
			}
			else if (waterman.charge_state == WatermanParams::legolas_charging)
			{
				frame = 9;
			}
			getHUD().SetCursorFrame(frame);
		}

		// activate/throw

		if (this.isKeyJustPressed(key_action3))
		{
			client_SendThrowOrActivateCommand(this);
		}

		// pick up arrow

		if (waterman.fletch_cooldown > 0)
		{
			waterman.fletch_cooldown--;
		}

		// pickup from ground

		if (waterman.fletch_cooldown == 0 && this.isKeyPressed(key_action2))
		{
			if (getPickupArrow(this) !is null)   // pickup arrow from ground
			{
				this.SendCommand(this.getCommandID("pickup arrow"));
				waterman.fletch_cooldown = PICKUP_COOLDOWN;
			}
		}
	}

	waterman.charge_time = charge_time;
	waterman.charge_state = charge_state;
	waterman.has_arrow = hasarrow;

}

void onTick(CBlob@ this)
{
	this.Tag("unflammable");
	
	WatermanInfo@ waterman;
	if (!this.get("watermanInfo", @waterman))
	{
		return;
	}

	if (getKnocked(this) > 0)
	{
		waterman.charge_state = 0;
		waterman.charge_time = 0;
		return;
	}
	
	if (getKnocked(this) <= 0)
	if (this.isKeyPressed(key_action2) && !this.isKeyPressed(key_action1)){
		
		if(this.isKeyJustPressed(key_action2)){
			Sound::Play("firewoosh.ogg", this.getPosition());
		}
		
		this.Tag("flaming");
		
		RunnerMoveVars@ moveVars;
		if (this.get("moveVars", @moveVars))
		{
			moveVars.walkFactor *= 0.4f;
		}
	
		int neg = 1;
		if(this.isFacingLeft())neg = -1;
		
		Vec2f arrowVel = (this.getAimPos()+Vec2f(float(XORRandom(65)-32),float(XORRandom(65)-32)))-(this.getPosition());
		arrowVel.Normalize();
		arrowVel *= 5.0f;
		
		if(getNet().isServer()){
			CBlob @fire = server_CreateBlob("firebolt",this.getTeamNum(),this.getPosition()+Vec2f(8*neg,0));
			fire.setVelocity(arrowVel);
			fire.SetDamageOwnerPlayer(this.getPlayer());
		}
	}
	else
	{
		this.Untag("flaming");
	}
	
	// vvvvvvvvvvvvvv CLIENT-SIDE ONLY vvvvvvvvvvvvvvvvvvv

	if (!getNet().isClient()) return;

	if (this.isInInventory()) return;

	RunnerMoveVars@ moveVars;
	if (!this.get("moveVars", @moveVars))
	{
		return;
	}

	ManageBow(this, waterman, moveVars);
}

bool canSend(CBlob@ this)
{
	return (this.isMyPlayer() || this.getPlayer() is null || this.getPlayer().isBot());
}

void ClientFire(CBlob@ this, const s8 charge_time, const bool hasarrow, const u8 arrow_type, const bool legolas)
{
	//time to fire!
	if (canSend(this))  // client-logic
	{
		f32 arrowspeed;

		if (charge_time < WatermanParams::ready_time / 2 + WatermanParams::shoot_period_1)
		{
			arrowspeed = WatermanParams::shoot_max_vel * (1.0f / 3.0f);
		}
		else if (charge_time < WatermanParams::ready_time / 2 + WatermanParams::shoot_period_2)
		{
			arrowspeed = WatermanParams::shoot_max_vel * (4.0f / 5.0f);
		}
		else
		{
			arrowspeed = WatermanParams::shoot_max_vel;
		}

		ShootArrow(this, this.getPosition() + Vec2f(0.0f, -2.0f), this.getAimPos() + Vec2f(0.0f, -2.0f), arrowspeed, arrow_type, legolas);
	}
}

void ShootArrow(CBlob @this, Vec2f arrowPos, Vec2f aimpos, f32 arrowspeed, const u8 arrow_type, const bool legolas = true)
{
	if (canSend(this))
	{
		// player or bot
		Vec2f arrowVel = (aimpos - arrowPos);
		arrowVel.Normalize();
		arrowVel *= arrowspeed;
		//print("arrowspeed " + arrowspeed);
		CBitStream params;
		params.write_Vec2f(arrowPos);
		params.write_Vec2f(arrowVel);
		params.write_u8(arrow_type);
		params.write_bool(legolas);

		this.SendCommand(this.getCommandID("shoot arrow"), params);
	}
}

CBlob@ getPickupArrow(CBlob@ this)
{
	CBlob@[] blobsInRadius;
	if (this.getMap().getBlobsInRadius(this.getPosition(), this.getRadius() * 1.5f, @blobsInRadius))
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob @b = blobsInRadius[i];
			if (b.getName() == "arrow")
			{
				return b;
			}
		}
	}
	return null;
}

bool canPickSpriteArrow(CBlob@ this, bool takeout)
{
	CBlob@[] blobsInRadius;
	if (this.getMap().getBlobsInRadius(this.getPosition(), this.getRadius() * 1.5f, @blobsInRadius))
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob @b = blobsInRadius[i];
			{
				CSprite@ sprite = b.getSprite();
				if (sprite.getSpriteLayer("arrow") !is null)
				{
					if (takeout)
						sprite.RemoveSpriteLayer("arrow");
					return true;
				}
			}
		}
	}
	return false;
}

CBlob@ CreateWaterBolt(CBlob@ this, Vec2f arrowPos, Vec2f arrowVel, u8 arrowType)
{
	
	CBlob @blob = server_CreateBlob("waterbolt", this.getTeamNum(), this.getPosition());
	if (blob !is null)
	{
		blob.set_f32("map_damage_ratio", 0.0f);
		blob.set_f32("explosive_damage", 0.0f);
		blob.set_f32("explosive_radius", 46.0f);
		blob.set_bool("map_damage_raycast", false);
		blob.set_string("custom_explosion_sound", "/GlassBreak");
		blob.set_u8("custom_hitter", Hitters::water);
		blob.setVelocity(arrowVel);
	}
	return blob;
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shoot arrow"))
	{
		Vec2f arrowPos = params.read_Vec2f();
		Vec2f arrowVel = params.read_Vec2f();
		u8 arrowType = params.read_u8();
		bool legolas = params.read_bool();

		WatermanInfo@ waterman;
		if (!this.get("watermanInfo", @waterman))
		{
			return;
		}

		waterman.arrow_type = arrowType;

		if (getNet().isServer())
		{
			CreateWaterBolt(this, arrowPos, arrowVel, arrowType);
		}

		this.getSprite().PlaySound("Entities/Characters/Waterman/BowFire.ogg");
		this.TakeBlob(arrowTypeNames[ arrowType ], 1);

		waterman.fletch_cooldown = FLETCH_COOLDOWN; // just don't allow shoot + make arrow
	}
	else if (cmd == this.getCommandID("pickup arrow"))
	{
		CBlob@ arrow = getPickupArrow(this);
		bool spriteArrow = canPickSpriteArrow(this, false);
		if (arrow !is null || spriteArrow)
		{
			if (arrow !is null)
			{
				WatermanInfo@ waterman;
				if (!this.get("watermanInfo", @waterman))
				{
					return;
				}
				const u8 arrowType = waterman.arrow_type;
				if (arrowType == ArrowType::bomb)
				{
					arrow.set_u16("follow", 0); //this is already synced, its in command.
					arrow.setPosition(this.getPosition());
					return;
				}
			}

			CBlob@ mat_arrows = server_CreateBlob("mat_arrows", this.getTeamNum(), this.getPosition());
			if (mat_arrows !is null)
			{
				mat_arrows.server_SetQuantity(fletch_num_arrows);
				mat_arrows.Tag("do not set materials");
				this.server_PutInInventory(mat_arrows);

				if (arrow !is null)
				{
					arrow.server_Die();
				}
				else
				{
					canPickSpriteArrow(this, true);
				}
			}
			this.getSprite().PlaySound("Entities/Items/Projectiles/Sounds/ArrowHitGround.ogg");
		}
	}
	else if (cmd == this.getCommandID("cycle"))  //from standardcontrols
	{
		// cycle arrows
		WatermanInfo@ waterman;
		if (!this.get("watermanInfo", @waterman))
		{
			return;
		}
		u8 type = waterman.arrow_type;

		int count = 0;
		while (count < arrowTypeNames.length)
		{
			type++;
			count++;
			if (type >= arrowTypeNames.length)
			{
				type = 0;
			}
			if (this.getBlobCount(arrowTypeNames[type]) > 0)
			{
				waterman.arrow_type = type;
				if (this.isMyPlayer())
				{
					Sound::Play("/CycleInventory.ogg");
				}
				break;
			}
		}
	}
	else
	{
		WatermanInfo@ waterman;
		if (!this.get("watermanInfo", @waterman))
		{
			return;
		}
		for (uint i = 0; i < arrowTypeNames.length; i++)
		{
			if (cmd == this.getCommandID("pick " + arrowTypeNames[i]))
			{
				waterman.arrow_type = i;
				break;
			}
		}
	}
}

void onCreateInventoryMenu(CBlob@ this, CBlob@ forBlob, CGridMenu @gridmenu)
{
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
				SetHelp(this, "help self action", "waterman", "$arrow$Fire arrow   $KEY_HOLD$$LMB$", "", 3);
				if (j > 0 && this.getInventory().getItemsCount() > 1)
				{
					SetHelp(this, "help inventory", "waterman", "$Help_Arrow1$$Swap$$Help_Arrow2$         $KEY_TAP$$KEY_F$", "", 2);
				}
				break;
			}
		}
	}

	CInventory@ inv = this.getInventory();
	if (inv.getItemsCount() == 0)
	{
		WatermanInfo@ waterman;
		if (!this.get("watermanInfo", @waterman))
		{
			return;
		}

		for (uint i = 0; i < arrowTypeNames.length; i++)
		{
			if (itemname == arrowTypeNames[i])
			{
				waterman.arrow_type = i;
			}
		}
	}
}