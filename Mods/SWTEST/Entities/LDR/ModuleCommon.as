
void Module_Setup( CBlob@ this, string projectile, u32 interval)
{
	this.set_string("projectile", projectile);
	this.set_u32("interval", interval);
    this.addCommandID("detach barrel");
    this.set_u32("delay", 0);
    //this.getShape().getConsts().collideWhenAttached = false;
}

void onTick(CBlob@ this)
{

	CBlob@ barrel = this.getAttachments().getAttachedBlob("BARREL");
	if(barrel !is null)
	{

		barrel.setAngleDegrees(this.getAngleDegrees());
	}
	if (!this.isAttached()) return;
	CBlob@ holder = this.getAttachments().getAttachedBlob("PICKUP", 0);
	if (holder !is null && holder.getName()=="builder") return;
	u32 delay = this.get_u32("delay");
	u32 interval = this.get_u32("interval");
	if (delay > 0)
	{
		delay--;

	}

	this.set_u32("delay", delay);

	if (delay == 0)
	{
		this.Untag("fired");
		if (barrel !is null)
		{
		barrel.Untag("fired");

		}
		CBitStream params;
		string projectile = this.get_string("projectile");
		params.write_string(projectile);
		if (barrel !is null && !this.hasTag("fired"))
		{
			barrel.SendCommand(barrel.getCommandID("fire barrel"), params);

		}
		this.Tag("fired");
		delay = interval;
	}
	this.set_u32("delay", delay);
	if (this.getAngleDegrees()<270 && this.getAngleDegrees()>90)
	{
		this.SetFacingLeft(true);
	}
	else
	{
		this.SetFacingLeft(false);
	}

}
void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CBlob@ barrel = this.getAttachments().getAttachedBlob("BARREL");
	if(this.isAttached() || barrel is null) return;

	CButton@ button = caller.CreateGenericButton(
	"$pushbutton_1$",                           // icon token
	Vec2f_zero,                                 // button offset
	this,                                       // button attachment
	this.getCommandID("detach barrel"),              // command id
	"Detach barrel");                                // description

	button.radius = 16.0f;
	button.enableRadius = 32.0f;
}


void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	//this.server_Die();
	if (blob !is null && blob.hasTag("barrel") && !blob.isAttached())
	{			
		print("collided");
		this.server_AttachTo(blob, "BARREL");
		this.getSprite().PlaySound("/AttachModule.ogg");
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	CBlob@ barrel = this.getAttachments().getAttachedBlob("BARREL");

	if (cmd == this.getCommandID("detach barrel") && barrel !is null)
	{
		barrel.server_DetachFrom(this);
		this.getSprite().PlaySound("/DetachModule.ogg");
	}
}