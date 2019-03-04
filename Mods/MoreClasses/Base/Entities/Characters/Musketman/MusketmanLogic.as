// Archer logic

#include "MusketmanCommon.as";
#include "ThrowCommon.as";
#include "Knocked.as";
#include "Hitters.as";
#include "RunnerCommon.as";
#include "ShieldCommon.as";
#include "Help.as";
//#include "BombCommon.as";

const int FLETCH_COOLDOWN = 45;
const int PICKUP_COOLDOWN = 15;
const int fletch_num_bullets = 1;
const int STAB_DELAY = 10;
const int STAB_TIME = 22;

void onInit(CBlob@ this)
{
	MusketmanInfo musketman;
	this.set("musketmanInfo", @musketman);

	this.set_s8("charge_time", 0);
	this.set_u8("charge_state", MusketmanParams::not_aiming);
	this.set_bool("has_bullet", false);
	this.set_f32("gib health", -3.0f);
	this.Tag("player");
	this.Tag("flesh");

	//centered on arrows
	//this.set_Vec2f("inventory offset", Vec2f(0.0f, 122.0f));
	//centered on items
	this.set_Vec2f("inventory offset", Vec2f(0.0f, 0.0f));

	//no spinning
	this.getShape().SetRotationsAllowed(false);
	this.getSprite().SetEmitSound("Entities/Characters/Archer/BowPull.ogg");
	this.addCommandID("shoot bullet");
	this.addCommandID("pickup bullet");
	this.getShape().getConsts().net_threshold_multiplier = 0.5f;

	//this.addCommandID(grapple_sync_cmd);

	//SetHelp(this, "help self hide", "archer", "Hide    $KEY_S$", "", 1);
	//SetHelp(this, "help self action2", "archer", "$Grapple$ Grappling hook    $RMB$", "", 3);

	//add a command ID for each arrow type
	for (uint i = 0; i < bulletTypeNames.length; i++)
	{
		this.addCommandID("pick " + bulletTypeNames[i]);
	}

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if (player !is null)
	{
		player.SetScoreboardVars("ScoreboardIcons.png", 5, Vec2f(16, 16));
	}
}

void ManageMusket(CBlob@ this, MusketmanInfo@ musketman, RunnerMoveVars@ moveVars)
{
	CSprite@ sprite = this.getSprite();
	bool ismyplayer = this.isMyPlayer();
	bool hasbullet = musketman.has_bullet;
	s8 charge_time = musketman.charge_time;
	u8 charge_state = musketman.charge_state;
	const bool pressed_action2 = this.isKeyPressed(key_action2);
	Vec2f pos = this.getPosition();

	if (ismyplayer)
	{
		if ((getGameTime() + this.getNetworkID()) % 10 == 0)
		{
			hasbullet = hasBullets(this);

			if (!hasbullet)
			{
				// set back to default
				for (uint i = 0; i < BulletType::count; i++)
				{
					hasbullet = hasBullets(this, i);
					if (hasbullet)
					{
						musketman.bullet_type = i;
						break;
					}
				}
			}
		}

		this.set_bool("has_bullet", hasbullet);
		this.Sync("has_bullet", false);

		musketman.stab_delay = 0;
	}

	//charged - no else (we want to check the very same tick)


    if (this.isKeyPressed(key_action1))
	{
		moveVars.walkFactor *= 0.75f;
		moveVars.canVault = false;

		const bool just_action1 = this.isKeyJustPressed(key_action1);

		//	printf("charge_state " + charge_state );

		if ((just_action1 || this.wasKeyPressed(key_action2) && !pressed_action2) &&
		        (charge_state == MusketmanParams::not_aiming || charge_state == MusketmanParams::fired))
		{
			charge_state = MusketmanParams::readying;
			hasbullet = hasBullets(this);

			if (!hasbullet)
			{
				musketman.bullet_type = BulletType::normal;
				hasbullet = hasBullets(this);

			}

			if (ismyplayer)
			{
				this.set_bool("has_bullet", hasbullet);
				this.Sync("has_bullet", false);
			}

			charge_time = 0;

			if (!hasbullet)
			{
				charge_state = MusketmanParams::no_bullets;

				if (ismyplayer && !this.wasKeyPressed(key_action1))   // playing annoying no ammo sound
				{
					Sound::Play("Entities/Characters/Sounds/NoAmmo.ogg");
				}

			}
			else
			{
				if (ismyplayer)
				{
					if (just_action1)
					{
						const u8 type = musketman.bullet_type;
						/*
						if (type == BulletType::water)
						{
							sprite.PlayRandomSound("/WaterBubble");
						}
						else if (type == BulletType::fire)
						{
							sprite.PlaySound("SparkleShort.ogg");
						}
						*/

					}
				}

				sprite.RewindEmitSound();
				sprite.SetEmitSoundPaused(false);

				if (!ismyplayer)   // lower the volume of other players charging  - ooo good idea
				{
					sprite.SetEmitSoundVolume(0.5f);
				}
			}
		}
		else if (charge_state == MusketmanParams::readying)
		{
			charge_time++;

			if (charge_time > MusketmanParams::ready_time)
			{
				charge_time = 1;
				charge_state = MusketmanParams::charging;
			}
		}
		else if (charge_state == MusketmanParams::charging)
		{
			charge_time++;

			if (charge_time >= MusketmanParams::shoot_period)
				sprite.SetEmitSoundPaused(true);
		}
		else if (charge_state == MusketmanParams::no_bullets)
		{
			if (charge_time < MusketmanParams::ready_time)
			{
				charge_time++;
			}
		}
	}
	else
	{
		if (charge_state > MusketmanParams::readying)
		{
			if (charge_state < MusketmanParams::fired)
			{
				ClientFire(this, charge_time, hasbullet, musketman.bullet_type);

				charge_time = MusketmanParams::fired_time;
				charge_state = MusketmanParams::fired;
			}
			else //fired..
			{
				charge_time--;

				if (charge_time <= 0)
				{
					charge_state = MusketmanParams::not_aiming;
					charge_time = 0;
				}
			}
		}
		else
		{
			charge_state = MusketmanParams::not_aiming;    //set to not aiming either way
			charge_time = 0;
		}

		sprite.SetEmitSoundPaused(true);
	}

	// safe disable bomb light
	/*
	if (this.wasKeyPressed(key_action1) && !this.isKeyPressed(key_action1))
	{
		const u8 type = musketman.bullet_type;
		if (type == MusketmanType::bomb)
		{
			BombFuseOff(this);
		}
	}
	*/

	// my player!

	if (ismyplayer)
	{
		// set cursor

		if (!getHUD().hasButtons())
		{
			int frame = 0;
			//	print("archer.charge_time " + archer.charge_time + " / " + ArcherParams::shoot_period );
			if (musketman.charge_state == MusketmanParams::readying)
			{
				frame = 1 + float(musketman.charge_time) / float(MusketmanParams::shoot_period + MusketmanParams::ready_time) * 7;
			}
			else if (musketman.charge_state == MusketmanParams::charging)
			{
				if (musketman.charge_time <= MusketmanParams::shoot_period)
				{
					frame = float(MusketmanParams::ready_time + musketman.charge_time) / float(MusketmanParams::shoot_period) * 7;
				}
				else
					frame = 9;
			}
			getHUD().SetCursorFrame(frame);
		}

		// activate/throw

		if (this.isKeyJustPressed(key_action3))
		{
			client_SendThrowOrActivateCommand(this);
		}

		// pick up bullet

		if (musketman.fletch_cooldown > 0)
		{
			musketman.fletch_cooldown--;
		}

		// pickup from ground
		if (musketman.fletch_cooldown == 0 && this.isKeyPressed(key_action2))
		{
			if (getPickupBullet(this) !is null)   // pickup bullet from ground
			{
				this.SendCommand(this.getCommandID("pickup bullet"));
				musketman.fletch_cooldown = PICKUP_COOLDOWN;
			}
		}
	}

	musketman.charge_time = charge_time;
	musketman.charge_state = charge_state;
	musketman.has_bullet = hasbullet;

}

void onTick(CBlob@ this)
{
	MusketmanInfo@ musketman;
	if (!this.get("musketmanInfo", @musketman))
	{
		return;
	}

	if (getKnocked(this) > 0)
	{
		musketman.charge_state = 0;
		musketman.charge_time = 0;
		return;
	}

	// vvvvvvvvvvvvvv CLIENT-SIDE ONLY vvvvvvvvvvvvvvvvvvv

	if (!getNet().isClient()) return;

	if (this.isInInventory()) return;

	RunnerMoveVars@ moveVars;
	if (!this.get("moveVars", @moveVars))
	{
		return;
	}

	ManageMusket(this, musketman, moveVars);
}

bool canSend(CBlob@ this)
{
	return (this.isMyPlayer() || this.getPlayer() is null || this.getPlayer().isBot());
}

void ClientFire(CBlob@ this, const s8 charge_time, const bool hasbullet, const u8 bullet_type)
{
	//time to fire!
	if (hasbullet && canSend(this))  // client-logic
	{
		f32 bulletspeed;

		if (charge_time < MusketmanParams::ready_time / 2 + MusketmanParams::shoot_period_1)
		{
			bulletspeed = MusketmanParams::shoot_max_vel * (13.0f / 15.0f);
		}
		else if (charge_time < MusketmanParams::ready_time / 2 + MusketmanParams::shoot_period_2)
		{
			bulletspeed = MusketmanParams::shoot_max_vel * (14.0f / 15.0f);
		}
		else
		{
			bulletspeed = MusketmanParams::shoot_max_vel;
		}

		ShootBullet(this, this.getPosition() + Vec2f(-2.0f, -2.0f), this.getAimPos() + Vec2f(0.0f, -2.0f),
					bulletspeed, bullet_type);
	}
}

void ShootBullet(CBlob @this, Vec2f bulletPos, Vec2f aimpos, f32 bulletspeed, const u8 bullet_type)
{
	if (canSend(this))
	{
		// player or bot
		Vec2f bulletVel = (aimpos - bulletPos);
		bulletVel.Normalize();
		bulletVel *= bulletspeed;
		//print("bulletspeed " + bulletspeed);
		CBitStream params;
		params.write_Vec2f(bulletPos);
		params.write_Vec2f(bulletVel);
		params.write_u8(bullet_type);

		this.SendCommand(this.getCommandID("shoot bullet"), params);
	}
}

CBlob@ getPickupBullet(CBlob@ this)
{
	CBlob@[] blobsInRadius;
	if (this.getMap().getBlobsInRadius(this.getPosition(), this.getRadius() * 1.5f, @blobsInRadius))
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob @b = blobsInRadius[i];
			if (b.getName() == "bullet")
			{
				return b;
			}
		}
	}
	return null;
}

bool canPickSpriteBullet(CBlob@ this, bool takeout)
{
	CBlob@[] blobsInRadius;
	if (this.getMap().getBlobsInRadius(this.getPosition(), this.getRadius() * 1.5f, @blobsInRadius))
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob @b = blobsInRadius[i];
			{
				CSprite@ sprite = b.getSprite();
				if (sprite.getSpriteLayer("bullet") !is null)
				{
					if (takeout)
						sprite.RemoveSpriteLayer("bullet");
					return true;
				}
			}
		}
	}
	return false;
}

CBlob@ CreateBullet(CBlob@ this, Vec2f bulletPos, Vec2f bulletVel, u8 bulletType)
{
	CBlob@ bullet = server_CreateBlobNoInit("bullet");
	if (bullet !is null)
	{
		// fire bullet?
		bullet.set_u8("bullet type", bulletType);
		bullet.Init();

		bullet.IgnoreCollisionWhileOverlapped(this);
		bullet.SetDamageOwnerPlayer(this.getPlayer());
		bullet.server_setTeamNum(this.getTeamNum());
		bullet.setPosition(bulletPos);
		bullet.setVelocity(bulletVel);
	}
	return bullet;
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shoot bullet"))
	{
		Vec2f bulletPos = params.read_Vec2f();
		Vec2f bulletVel = params.read_Vec2f();
		u8 bulletType = params.read_u8();
		MusketmanInfo@ musketman;
		if (!this.get("musketmanInfo", @musketman))
		{
			return;
		}

		musketman.bullet_type = bulletType;

		// return to normal bullet - server didnt have this synced
		if (!hasBullets(this, bulletType))
		{
			return;
		}

		{
			if (getNet().isServer())
			{
				CreateBullet(this, bulletPos, bulletVel, bulletType);
			}

			this.getSprite().PlaySound("Entities/Characters/Archer/BowFire.ogg");
			this.TakeBlob(bulletTypeNames[ bulletType ], 1);
		}

		musketman.fletch_cooldown = FLETCH_COOLDOWN; // just don't allow shoot + make bullet
	}
	else if (cmd == this.getCommandID("pickup bullet"))
	{
		CBlob@ bullet = getPickupBullet(this);
		bool spriteBullet = canPickSpriteBullet(this, false);
		if (bullet !is null || spriteBullet)
		{
			if (bullet !is null)
			{
				MusketmanInfo@ musketman;
				if (!this.get("musketmanInfo", @musketman))
				{
					return;
				}
				const u8 bulletType = musketman.bullet_type;
				/*
				if (bulletType == BulletType::bomb)
				{
					bullet.set_u16("follow", 0); //this is already synced, its in command.
					bullet.setPosition(this.getPosition());
					return;
				}
				*/
			}

			CBlob@ mat_bullets = server_CreateBlob("mat_bullets", this.getTeamNum(), this.getPosition());
			if (mat_bullets !is null)
			{
				mat_bullets.server_SetQuantity(fletch_num_bullets);
				mat_bullets.Tag("do not set materials");
				this.server_PutInInventory(mat_bullets);

				if (bullet !is null)
				{
					bullet.server_Die();
				}
				else
				{
					canPickSpriteBullet(this, true);
				}
			}
			this.getSprite().PlaySound("Entities/Items/Projectiles/Sounds/ArrowHitGround.ogg");
		}
	}
	else if (cmd == this.getCommandID("cycle"))  //from standardcontrols
	{
		// cycle arrows
		MusketmanInfo@ musketman;
		if (!this.get("musketmanInfo", @musketman))
		{
			return;
		}
		u8 type = musketman.bullet_type;

		int count = 0;
		while (count < bulletTypeNames.length)
		{
			type++;
			count++;
			if (type >= bulletTypeNames.length)
			{
				type = 0;
			}
			if (this.getBlobCount(bulletTypeNames[type]) > 0)
			{
				musketman.bullet_type = type;
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
		MusketmanInfo@ musketman;
		if (!this.get("musketmanInfo", @musketman))
		{
			return;
		}
		for (uint i = 0; i < bulletTypeNames.length; i++)
		{
			if (cmd == this.getCommandID("pick " + bulletTypeNames[i]))
			{
				musketman.bullet_type = i;
				break;
			}
		}
	}
}

// arrow pick menu
void onCreateInventoryMenu(CBlob@ this, CBlob@ forBlob, CGridMenu @gridmenu)
{
	if (bulletTypeNames.length == 0)
	{
		return;
	}

	this.ClearGridMenusExceptInventory();
	Vec2f pos(gridmenu.getUpperLeftPosition().x + 0.5f * (gridmenu.getLowerRightPosition().x - gridmenu.getUpperLeftPosition().x),
	          gridmenu.getUpperLeftPosition().y - 32 * 1 - 2 * 24);
	CGridMenu@ menu = CreateGridMenu(pos, this, Vec2f(bulletTypeNames.length, 2), "Current bullet");

	MusketmanInfo@ musketman;
	if (!this.get("musketmanInfo", @musketman))
	{
		return;
	}

	const u8 bulletSel = musketman.bullet_type;

	if (menu !is null)
	{
		menu.deleteAfterClick = false;

		for (uint i = 0; i < bulletTypeNames.length; i++)
		{
			string matname = bulletTypeNames[i];
			CGridButton @button = menu.AddButton(bulletIcons[i], bulletNames[i], this.getCommandID("pick " + matname));

			if (button !is null)
			{
				bool enabled = this.getBlobCount(bulletTypeNames[i]) > 0;
				button.SetEnabled(enabled);
				button.selectOneOnClick = true;

				//if (enabled && i == ArrowType::fire && !hasReqs(this, i))
				//{
				//	button.hoverText = "Requires a fire source $lantern$";
				//	//button.SetEnabled( false );
				//}

				if (bulletSel == i)
				{
					button.SetSelected(1);
				}
			}
		}
	}
}

// auto-switch to appropriate arrow when picked up
void onAddToInventory(CBlob@ this, CBlob@ blob)
{
	string itemname = blob.getName();
	if (this.isMyPlayer())
	{
		for (uint j = 0; j < bulletTypeNames.length; j++)
		{
			if (itemname == bulletTypeNames[j])
			{
				/*SetHelp(this, "help self action", "archer", "$arrow$Fire arrow   $KEY_HOLD$$LMB$", "", 3);
				if (j > 0 && this.getInventory().getItemsCount() > 1)
				{
					SetHelp(this, "help inventory", "archer", "$Help_Arrow1$$Swap$$Help_Arrow2$         $KEY_TAP$$KEY_F$", "", 2);
				}*/
				break;
			}
		}
	}

	CInventory@ inv = this.getInventory();
	if (inv.getItemsCount() == 0)
	{
		MusketmanInfo@ musketman;
		if (!this.get("musketmanInfo", @musketman))
		{
			return;
		}

		for (uint i = 0; i < bulletTypeNames.length; i++)
		{
			if (itemname == bulletTypeNames[i])
			{
				musketman.bullet_type = i;
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
			/*
			if (hitBlob.hasTag("tree"))	// make arrow from tree
			{
				if (getNet().isServer())
				{
					CBlob@ mat_bullets = server_CreateBlob("mat_bullets", this.getTeamNum(), this.getPosition());
					if (mat_bullets !is null)
					{
						mat_bullets.server_SetQuantity(fletch_num_bullets);
						mat_bullets.Tag("do not set materials");
						this.server_PutInInventory(mat_bullets);
					}
				}
				this.getSprite().PlaySound("Entities/Items/Projectiles/Sounds/ArrowHitGround.ogg");
			}

			else*/
				this.getSprite().PlaySound("KnifeStab.ogg");
		}

		if (blockAttack(hitBlob, velocity, 0.0f))
		{
			this.getSprite().PlaySound("/Stun", 1.0f, this.getSexNum() == 0 ? 1.0f : 2.0f);
			SetKnocked(this, 30);
		}
	}
}
