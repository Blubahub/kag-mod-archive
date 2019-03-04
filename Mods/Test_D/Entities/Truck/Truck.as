#include "GameColours.as"
//so we can hide when rendering menus..
#include "UI.as"
#include "ClassPickCommon.as"
#include "ExplosionParticles.as"

const f32 ACCEL = 1.0f;

Vec2f TRAY_OFFSET(14, 4);
Vec2f CAB_OFFSET(-20, 0);
Vec2f DRIVER_OFFSET(-10, -1);
f32 z_width = 10.0f;

f32 getZ(CBlob@ this)
{
	return -550.0f - (Maths::Abs(this.getTeamNum() % 3) * 1.5f * z_width);
}

bool nearTarget(CBlob@ this)
{
	Vec2f target = this.get_Vec2f("target");
	Vec2f thispos = this.getPosition();
	return (Maths::Abs(target.x - thispos.x) < 20);
}

void onInit(CBlob@ this)
{
	this.set_u32("leave_time", 0);
	this.set_u8("leave_secs", 255);
	if (!this.exists("in_cap"))
		this.set_u8("in_cap", 5);

	CShape@ shape = this.getShape();
	ShapeConsts@ consts = shape.getConsts();
	consts.mapCollisions = false;
	shape.SetGravityScale(0.0f);
	shape.SetRotationsAllowed(false);
	this.SetMapEdgeFlags(u8(CBlob::map_collide_none | CBlob::map_collide_nodeath));

	this.chatBubbleOffset.x = 0.0f;
	this.chatBubbleOffset.y = 80.0f;

	CSprite@ sprite = this.getSprite();
	if (sprite !is null)
	{
		sprite.SetZ(getZ(this));

		u32 cabframe = 6;
		u32 trayframe = 4;
		if (this.getTeamNum() < 2)
		{
			if (this.getTeamNum() == 0)
			{
				cabframe = 5;
				trayframe = 15;
			}
			if (this.getTeamNum() == 1)
			{
				cabframe = 4;
				trayframe = 13;
			}
		}

		CSpriteLayer@ cab = sprite.addSpriteLayer("cab", "truck.png", 32, 32, 0, 0);
		if (cab !is null)
		{
			cab.SetFrameIndex(cabframe);
			cab.SetOffset(CAB_OFFSET);
			cab.SetRelativeZ(z_width * 0.1f);
		}

		CSpriteLayer@ tray = sprite.addSpriteLayer("tray", "truck.png", 32, 16, 0, 0);
		if (tray !is null)
		{
			tray.SetFrameIndex(trayframe);
			tray.SetOffset(TRAY_OFFSET);
			tray.SetRelativeZ(z_width * 0.9f);
		}

		CSpriteLayer@ driver = sprite.addSpriteLayer("driver", "truck.png", 8, 8, 0, 0);
		if (driver !is null)
		{
			{
				int[] frames = {7, 7};
				Animation@ anim = driver.addAnimation("stay_in", 23, true);
				anim.AddFrames(frames);
			}

			{
				int[] frames = {15, 23, 23, 23,
				                23, 23, 31, 39,
				                47, 47, 55, 63,
				                23, 15, 7, 7
				               };
				Animation@ anim = driver.addAnimation("poke_head", 6, true);
				anim.AddFrames(frames);
			}

			driver.SetOffset(DRIVER_OFFSET);
			driver.SetRelativeZ(z_width * 0.2f);
		}
	}

	this.addCommandID("use");
	this.addCommandID("ride away");
	this.addCommandID("all occupied");
	this.addCommandID("bad coins");
	this.addCommandID("no game");

	int count = this.getAttachmentPointCount();
	for (int i = 0; i < count; i++)
	{
		AttachmentPoint @ap = this.getAttachmentPoint(i);
		// all except key_action2
		ap.SetKeysToTake(key_left | key_right | key_up | key_down | key_action1 | key_action3);
	}
}

void onTick(CBlob@ this)
{
	Vec2f pos = this.getPosition();
	Vec2f vel = this.getVelocity();
	Vec2f target = this.get_Vec2f("target");
	const bool toLeft = this.get_bool("to left");
	target.x += toLeft ? -18.0f : 18.0f;
	f32 distanceToTarget = Maths::Abs(target.x - pos.x);
	f32 z = getZ(this);
	const f32 velx = Maths::Abs(vel.x);

	f32 y = velx > 0.01f ? (s32(getGameTime() / 5 + distanceToTarget / 10 + pos.x / 7) % 2) : 0;
	CSprite@ sprite = this.getSprite();
	if (sprite !is null)
	{
		sprite.SetZ(z);
		sprite.SetOffset(Vec2f(0, y));

		CSpriteLayer@ cab = sprite.getSpriteLayer("cab");
		if (cab !is null)
		{
			cab.SetOffset(CAB_OFFSET + Vec2f(0, y));
		}

		CSpriteLayer@ tray = sprite.getSpriteLayer("tray");
		if (tray !is null)
		{
			tray.SetOffset(TRAY_OFFSET + Vec2f(0, y));
		}

		CSpriteLayer@ driver = sprite.getSpriteLayer("driver");
		if (driver !is null)
		{
			driver.SetOffset(DRIVER_OFFSET + Vec2f(0, y));
			if (driver.isAnimationEnded())
			{
				u32 poke_chance = 5;
				driver.SetAnimation(Random(getGameTime() + ((100 + this.getNetworkID()) * 993)).NextRanged(poke_chance) == 0 ? "poke_head" : "stay_in");
			}
		}
	}

	if (velx > 0.0f)
	{
		f32 dir = toLeft ? 1 : -1;
		Particles::MicroDusts(pos + Vec2f(dir * 24.0f, 10), 1, vel + Vec2f(dir * 2.0f, 0), 1.0f, z * 0.5f);

		f32 dustlim = 1.5f;
		f32 dustspeed = -vel.x;
		//when braking, spray dust forward :)
		if (Maths::Abs(dustspeed) < dustlim && Maths::Abs(dustspeed) > dustlim * 0.5f)
		{
			dustspeed *= -4.0f;
		}

		if (Maths::Abs(dustspeed) > dustlim)
		{
			f32 speedvar = 1.0f + Maths::Abs(dustspeed * 0.25f);
			f32 dustz = z * 0.49f;
			f32 vert = 1.5f + Random(getGameTime()).NextFloat() * 1.5f;
			Particles::TinySmokes(pos + Vec2f(dir *  16.0f, 16), 1, vel + Vec2f(dustspeed, vert), speedvar, dustz);
			Particles::TinySmokes(pos + Vec2f(dir * -16.0f, 16), 1, vel + Vec2f(dustspeed, vert), speedvar, dustz);
		}

		this.SetFacingLeft(this.getVelocity().x < 0.0f);
	}

	//set z on all blobs
	// pick random free passenger seat
	int count = this.getAttachmentPointCount();
	for (int i = 0; i < count; i++)
	{
		AttachmentPoint @ap = this.getAttachmentPoint(i);
		CBlob@ occ = ap.getOccupied();
		if (occ !is null && ap.name == "PASSENGER" && occ.getSprite() !is null)
		{
			occ.getSprite().SetZ(z + z_width * 0.5f);
		}

		s32 teamoffset = this.getTeamNum() < 2 ? (1 - this.getTeamNum()) * -2 : 0;
		ap.offset.y = 1 + y + teamoffset;
	}


	// move
	if (distanceToTarget > 5.0f)
	{
		this.setVelocity(Vec2f(0.25f * (target.x > pos.x ? ACCEL : -ACCEL) * Maths::Sqrt(Maths::Min(distanceToTarget, 150.0f)), 0.0f));
	}
	else
	{
		this.setVelocity(Vec2f_zero);
	}

	// sync leave time

	if (getNet().isServer())
	{
		u32 leave_time = this.get_u32("leave_time");
		if (leave_time > 0 && leave_time >= Time())
		{
			u32 leave_dif = leave_time - Time();
			this.set_u8("leave_secs", leave_dif);
		}
		else
		{
			if (this.hasTag("waiting_server"))
				this.set_u8("leave_secs", 250); // waiting for free server
			else
				this.set_u8("leave_secs", 255);
		}

		this.Sync("leave_secs", true);
		this.Sync("waiting_server", true);
		this.Sync("ready", true);
	}

}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("use"))
	{
		//do all reading before returning
		CBlob@ blob = getBlobByNetworkID(params.read_netid());

		if (!getNet().isServer())
			return;

		if (blob !is null && !blob.isAttached())
		{
			CPlayer@ player = blob.getPlayer();

			//needs to be near the meeting point to get in
			if (!nearTarget(this) && !sv_test)
			{
				return;
			}
			//needs to have a free seat
			if (this.get_u8("in_cap") <= this.getAttachments().getOccupiedCount())
			{
				this.server_SendCommandToPlayer(this.getCommandID("all occupied"), player);
				return;
			}
			//needs to have the right amount of money
			CRules@ rules = getRules();
			const int cost = rules.get_u32("game_entry_cost");
			const int max_coins = rules.get_u32("max_coins");
			bool broke = true; bool toorich = true;
			if (player !is null)
			{
				u32 coins = player.getCoins();
				broke = coins < cost;
				toorich = coins > max_coins;
			}
			if ((broke || toorich) && player !is null)
			{
				CBitStream pars;
				pars.write_bool(broke);
				pars.write_u16(broke ? cost : max_coins);
				this.server_SendCommandToPlayer(this.getCommandID("bad coins"), pars, player);
				return;
			}

			// pick random free passenger seat
			int count = this.getAttachmentPointCount();
			u32 slot = Random(Time() + blob.getNetworkID()).NextRanged(count);
			for (int i = 0; i < count; i++)
			{
				slot = ((slot + 1) % count);
				AttachmentPoint @ap = this.getAttachmentPoint(slot);

				// gather empty controllers attachments/seats
				if (ap.getOccupied() is null && ap.name == "PASSENGER")
				{
					this.server_AttachTo(blob, ap);
					blob.server_setTeamNum(this.getTeamNum());
					if (player !is null){
						player.server_setTeamNum(this.getTeamNum());
					}
					break;
				}
			}
		}
	}
	else if (cmd == this.getCommandID("ride away"))
	{
		Vec2f target = this.get_Vec2f("target");
		CMap@ map = getMap();
		if (this.get_bool("to left"))
		{
			target.x = -50.0f;
		}
		else
		{
			target.x = map.tilesize * map.tilemapwidth + 50.0f;
		}
		this.set_Vec2f("target", target);
		this.SetMapEdgeFlags(u8(CBlob::map_collide_none)); // die on edge
		this.Tag("riding away");
	}
	else if (cmd == this.getCommandID("all occupied"))
	{
		Sound::Play("NoAmmo");
		this.Chat(Random(Time()).NextRanged(2) == 0 ? "We're full buddy!" : "Wait for the next truck!");
		this.getSprite().getSpriteLayer("driver").SetAnimation("poke_head");
	}
	else if (cmd == this.getCommandID("bad coins"))
	{
		Sound::Play("NoAmmo");
		const bool broke = params.read_bool();
		const u16 num = params.read_u16();
		string warning = broke ?
		                 ("Entry is " + (num == 0 ? "free" : (num + " coin" + (num == 1 ? "" : "s")))) :
		                 ("Limit is " + (num + " coin" + (num == 1 ? "" : "s")));
		//TODO; gendered salutations, or gender neutral
		this.Chat(broke ?
		          ("You're broke man. " + warning) :
		          ("You're too rich fella. " + warning));
		this.getSprite().getSpriteLayer("driver").SetAnimation("poke_head");
	}
	else if (cmd == this.getCommandID("no game"))
	{
		this.Untag("ready");
		if (params.read_bool())
		{
			this.Chat(Random(Time()).NextRanged(2) == 0 ? "Sorry, we have to wait for a free game." : "Nowhere to go. Waiting for free game.");
			this.getSprite().getSpriteLayer("driver").SetAnimation("poke_head");
		}
	}
}

// SPRITE

void onInit(CSprite@ this)
{
	// emit sound fix
	Sound::SetScale(1.0f);

	// engine sound
	CBlob@ blob = this.getBlob();
	int i = blob.getNetworkID() % 3;
	this.SetEmitSound("/EngineIdle.ogg");
	this.SetEmitSoundPaused(false);
	this.SetEmitSoundPlayPosition(i * 1000);
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	Vec2f oldvel = blob.get_Vec2f("oldvel");
	Vec2f vel = blob.getVelocity();

	f32 accel = Maths::Abs(vel.x - oldvel.x);
	if (accel < 1.0f)
	{
		this.SetEmitSoundSpeed(1.0f + accel * 5.0f);
	}

	f32 velx = Maths::Abs(vel.x);
	f32 oldvelx = Maths::Abs(oldvel.x);
	if (velx < 0.01f && oldvelx > 0.01f)
	{
		this.PlaySound("/EngineStop.ogg");
	}
	if (velx > 0.01f && oldvelx < 0.01f)
	{
		this.PlaySound("/EngineStart.ogg");
	}

	this.SetEmitSoundVolume(Maths::Min(1.0f, velx * 3.0f));

	blob.set_Vec2f("oldvel", vel);
}

//render countdown and amount inside
void onRender(CSprite@ this)
{
	if (UI::hasAnyContent())
		return;

	if (getRules().get_s16("in menu") > 0)
		return;

	CBlob@ blob = this.getBlob();
	if (blob is null)
		return;

	if (blob.hasTag("riding away") || blob.isChatBubbleVisible() || blob.getVelocity().getLengthSquared() > 1.0f)
		return;

	CBlob@ playerblob = getLocalPlayerBlob();

	Vec2f screenPos = blob.getScreenPos() + Vec2f(0, -64);

	GUI::SetFont("gui");

	Vec2f leaving_offset(0, 24);
	Vec2f help_offset(0.0f, 148);

	//hack: we adjust the position for one truck and ignore it for the other
	//for the campaign trucks so we dont have 2 timers
	if (blob.getTeamNum() == 1)
	{
		leaving_offset.x -= 44.0f;
		help_offset.x -= 24.0f;
	}

	u8 leave_secs = blob.get_u8("leave_secs");
	const u32 allowed = blob.get_u8("in_cap");
	const u32 currently = blob.getAttachments().getOccupiedCount();

	if (blob.getTeamNum() != 0)
	{
		if (leave_secs < 200)
		{
			string text = "leaving in" + (leave_secs >= 10 ? " " : "") + formatInt(leave_secs, "", 2);
			Vec2f dim;
			GUI::GetTextDimensions(text, dim);
			DrawTRGuiFrame(screenPos + leaving_offset - dim * 0.5f - Vec2f(8, 0), screenPos + leaving_offset + dim * 0.5f + Vec2f(8, 8));
			GUI::DrawTextCentered(text, screenPos + leaving_offset, (leave_secs < 10 && getGameTime() % 30 < 15) ? Colours::RED : Colours::WHITE);
		}
		else if (playerblob !is null && playerblob.isAttached())
		{
			string text = "Waiting for players";
			if (blob.hasTag("waiting_server"))
			{
				text = "Waiting for free game";
			}

			Vec2f dim;
			GUI::GetTextDimensions(text, dim);
			DrawTRGuiFrame(screenPos + leaving_offset - dim * 0.5f - Vec2f(8, 0), screenPos + leaving_offset + dim * 0.5f + Vec2f(8, 8));
			GUI::DrawTextCentered(text, screenPos + leaving_offset, Colours::WHITE);
		}
	}

	// draw free space arrows

	if (Maths::Abs(blob.getVelocity().x) < 0.5f)
	{
		int drawn = 0;
		for (int i = 0; i < blob.getAttachmentPointCount(); i++)
		{
			AttachmentPoint @ap = blob.getAttachmentPoint(i);
			if (ap.getOccupied() is null && ap.name == "PASSENGER")
			{
				GUI::DrawIcon("Sprites/HoverIcons.png", 8, Vec2f(16, 16),
				              getDriver().getScreenPosFromWorldPos(ap.getPosition()) + Vec2f(-8, -20 + Maths::Sin(0.4f * getGameTime()) * 4.0f), getCamera().targetDistance,
				              color_white);
				drawn++;
			}
			if (drawn >= allowed - currently)
				break;
		}

		// help msg

		if (playerblob !is null && Maths::Abs(playerblob.getPosition().x - blob.getPosition().x) < 25)
		{
			string text;
			if (!playerblob.isAttached())
			{
				text = "[" + getControls().getActionKeyKeyName(AK_ACTION1) + "] to get in";
			}
			else if (drawn > 0)
			{
				if (blob.get_u8("leave_secs") > 3)
					text = "[" + getControls().getActionKeyKeyName(AK_ACTION2) + "] to exit";
				else
					text = "(get ready...)";
			}

			if (text != "")
			{
				Vec2f screenpos(blob.getScreenPos().x + help_offset.x, help_offset.y);
				Vec2f dim;
				GUI::GetTextDimensions(text, dim);
				DrawTRGuiFrame(screenpos - dim * 0.5f - Vec2f(8, 0), screenpos + dim * 0.5f + Vec2f(8, 8));
				GUI::DrawTextCentered(text, screenpos, Colours::WHITE);
			}
		}
	}
}
