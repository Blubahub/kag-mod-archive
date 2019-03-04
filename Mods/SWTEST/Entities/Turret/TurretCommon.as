#include "Hitters.as";
#include "FireCommon.as";

void onInit(CBlob@ this)
{
    this.getShape().SetOffset(Vec2f(0.0, 2.75));
	this.getSprite().getConsts().accurateLighting = true;
	this.getSprite().SetRelativeZ(-10.0f);
	this.getShape().getConsts().waterPasses = true;

	this.Tag("place norotate");
	this.addCommandID("detach module");
	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);

	this.server_setTeamNum(-1); //allow anyone to break them
	this.set_s16(burn_duration , 300);
	//transfer fire to underlying tiles
	this.Tag(spread_fire_tag);
	this.set_f32("aimangle", 0);
	this.set_f32("originalx", this.getPosition().x);
	this.set_string("state", "wait");
}

void onTick(CBlob@ this)
{
	CBlob@ module = this.getAttachments().getAttachedBlob("MODULE");

	if (module !is null)
	{
		string state = this.get_string("state");
		if (state == "wait")
		{
			CBlob@[] blobsInRadius;
			if (this.getMap().getBlobsInRadius(this.getPosition(), 50.0f, @blobsInRadius))
			{
				for (uint i = 0; i < blobsInRadius.length; i++)
				{
					CBlob@ blob = blobsInRadius[i];
					if (blob is null) return;
					if (blob.hasTag("player"))
					{
						Vec2f targpos = Vec2f(blob.getPosition());
						this.set_Vec2f("targetpos", targpos);
						print("target position set to: "+ targpos.x + targpos.y );
						this.set_string("state", "attack");
						CBlob@ indicate = server_CreateBlob("satchel", this.getTeamNum(), targpos);
					}

				}
			}
			
		}
		
	}

	Vec2f blobPos = this.getPosition();
	//CBlob@ targetti = this.get_u16("targetblob");
	Vec2f aimPos = this.get_Vec2f("targetpos");

	Vec2f aimDir = aimPos - blobPos;
	f32 aimangle = aimDir.Angle();

	f32 originalx = this.get_f32("originalx");

	if (module !is null)
 	{
 		f32 angle = module.getAngleDegrees();
 		f32 diff = (aimangle-angle)/50;
 		//module.setAngleDegrees(angle+diff);
 		module.setAngleDegrees(aimangle);
 	}

 	if (this.getPosition().x != originalx)
 	{
 		this.setPosition(Vec2f(originalx, this.getPosition().y));
 	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CBlob@ module = this.getAttachments().getAttachedBlob("MODULE");
	if(!this.isOverlapping(caller) || module is null) return;

	CButton@ button = caller.CreateGenericButton(
	"$pushbutton_1$",                           // icon token
	Vec2f_zero,                                 // button offset
	this,                                       // button attachment
	this.getCommandID("detach module"),              // command id
	"Detach module");                                // description

	button.radius = 16.0f;
	button.enableRadius = 32.0f;
}

void onSetStatic(CBlob@ this, const bool isStatic)
{
	if (!isStatic) return;

	this.getSprite().PlaySound("/Respawn.ogg");
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	//this.server_Die();
	if (blob !is null && blob.hasTag("module") && !blob.isAttached())
	{			
		print("collided");
		this.server_AttachTo(blob, "MODULE");
		this.getSprite().PlaySound("/AttachModule.ogg");
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	CBlob@ module = this.getAttachments().getAttachedBlob("MODULE");

	if (cmd == this.getCommandID("detach module") && module !is null)
	{
		module.server_DetachFrom(this);
		this.getSprite().PlaySound("/DetachModule.ogg");
	}
}