// Trampoline logic

namespace Trampoline
{
	enum State
	{
		folded = 0,
		idle,
		bounce
	}

	enum msg
	{
		msg_pack = 0
	}
}

const f32 trampoline_speed = 6.0f;

void onInit(CBlob@ this)
{
	this.set_u8("trampolineState", Trampoline::folded);
	this.set_u32("trampolineBounceTime", 0);
	this.getShape().SetOffset(Vec2f(0.0f, 4.0f));
	this.Tag("no falldamage");
	this.Tag("getthis");

	if (this.hasTag("start unpacked"))
	{
		this.set_u8("trampolineState", Trampoline::idle);
	}

	this.getCurrentScript().tickFrequency = 2;
}

void onTick(CBlob@ this)
{
	if (this.get_u8("trampolineState") == Trampoline::bounce)
	{
		u32 bouncetime = getGameTime() - this.get_u32("trampolineBounceTime");

		if (bouncetime > 3) //10 ticks after bouncing
		{
			this.set_u8("trampolineState", Trampoline::idle);
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (caller.getDistanceTo(this) > 32.0f)
		return;

	u8 state = this.get_u8("trampolineState");

	if (state == Trampoline::folded)
	{
		caller.CreateGenericButton(6, Vec2f(0, -2), this, Trampoline::msg_pack, "Unpack Trampoline");
	}
	else
	{
		if (!this.hasTag("static"))
		{
			caller.CreateGenericButton(4, Vec2f(0, -2), this, Trampoline::msg_pack, "Pack up to move");
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	string dbg = "TrampolineLogic.as: Unknown command ";
	u8 state = this.get_u8("trampolineState");

	switch (cmd)
	{
		case Trampoline::msg_pack:
			if (state != Trampoline::folded)
			{
				this.set_u8("trampolineState", Trampoline::folded);
			}
			else
			{
				this.set_u8("trampolineState", Trampoline::idle); //logic for completion of this this is in anim script
			}

			break;

		default:
			dbg += cmd;
			print(dbg);
			warn(dbg);
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	u8 state = this.get_u8("trampolineState");
	return (state == Trampoline::folded);
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if (blob is null)   // map collision?
	{
		return;
	}

	Vec2f pos = this.getPosition();

	Vec2f blobpos;
	if (blob.getShape() is null)
		blobpos = blob.getPosition();
	else
		blobpos = blob.getShape().getVars().oldpos;

	f32 horizDist = Maths::Abs((blobpos.x -  pos.x));

	Vec2f up(0.0f, -1.0f);
	up.RotateBy(this.getAngleDegrees());

	Vec2f vel = blob.getOldVelocity();
	f32 vellen = vel.Length();
	f32 vel_angle = up.AngleWith(vel);

	if (vellen > 1.0f)   //dont bounce still stuff
	{
		u8 state = this.get_u8("trampolineState");
		if (state == Trampoline::idle || state == Trampoline::bounce)
		{
			this.set_u8("trampolineState", Trampoline::bounce);
			this.set_u32("trampolineBounceTime", getGameTime());

			string bname = blob.getName();
			bool low_bounce = (!blob.hasTag("player") || blob.hasTag("dead")) &&
			                  bname != "spikes" &&
			                  bname != "boulder" &&
			                  bname != "mine" &&
			                  bname != "keg" &&
			                  bname != "lantern";
			//different force if buttons pressed
			f32 bounceForce = (blob.isKeyPressed(key_down) || low_bounce) ? 0.8f :
			                  blob.isKeyPressed(key_up) ? 1.175f : 1.0f;

			//reflect vel off the trampoline if we're jumping in
			if (Maths::Abs(vel_angle) > 90)
			{
				f32 reflected_angle = ((vel_angle > 0) ? 90 - vel_angle : -90 - vel_angle);

				vel.RotateBy(reflected_angle * 2.0f, Vec2f());
			}

			//add bounce and "drag"
			vel = ((vel * 0.5f) + up * trampoline_speed) * bounceForce;

			blob.setVelocity(vel);
			//this.AddForce(-vel * blob.getMass() * 0.1f );

			f32 baseSound = 3.0f;
			this.getSprite().PlaySound(CFileMatcher("/TrampolineJump").getRandom(),
			                           Maths::Min(Maths::Max(0.4f, vellen * 0.5f - baseSound), 1.0f),
			                           Maths::Min(Maths::Max(0.5f, 1.0f - (baseSound - vellen * 0.5f)), 1.0f));
		}
	}
}

