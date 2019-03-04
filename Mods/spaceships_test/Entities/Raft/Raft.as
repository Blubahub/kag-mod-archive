// Boat logic

const f32 SPEED = 30.0f;

void onInit(CBlob@ this)
{
	this.getShape().SetOffset(Vec2f(0, 7));
	this.getShape().SetCenterOfMassOffset(Vec2f(0.0f, 0));
	this.getShape().getConsts().transports = true;
	// override icon
	AddIconToken("$" + this.getName() + "$", "VehicleIcons.png", Vec2f(16, 16), 6);
	this.Tag("heavy weight");
	this.addCommandID("attach");
	this.addCommandID("build");
}
/*
void onTick(CBlob@ this)
{
	// just drift in the general direction
	if (this.isInWater())
	{
		this.AddForce(Vec2f(this.isFacingLeft() ? -SPEED : SPEED, 0.0f));
	}
}*/

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return (!this.isInWater() || this.isOnGround() || this.isOnWall());
}

void onTick(CBlob@ this)
{
	//print("yes");
	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("DRIVER");
	CBlob@ driver = point.getOccupied();

	if (driver !is null)
	{
		f32 angle = this.getAngleDegrees();
		if(point.isKeyPressed(key_left))
		{
			//print("left");
			//this.server_Die();
			this.setAngleDegrees(angle-3);
			this.AddTorque(-30);
			//this.AddForce(Vec2f(-10, 0));
		}		
		if(point.isKeyPressed(key_right))
		{
			//print("right");
			//this.server_Die();
			this.setAngleDegrees(angle+3);
			this.AddTorque(30);
			//this.AddForce(Vec2f(-10, 0));
		}		

		if(point.isKeyPressed(key_up))
		{
			//print("up");
			//this.server_Die();
			Vec2f dir = Vec2f(0, -200);
			dir.RotateBy(angle);
			this.AddForce(Vec2f(dir));
		}
		if(point.isKeyPressed(key_down))
		{
			//print("down");
			//this.server_Die();
			Vec2f dir = Vec2f(0, 150);
			dir.RotateBy(angle);
			this.AddForce(Vec2f(dir));
		}
	}


//	if (blob.isMyPlayer() && ap.isKeyJustPressed(key_up))
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{

	if (cmd == this.getCommandID("build") && !this.hasTag("parent"))
	{
		CBlob@[] blobsInRadius;	   
			if (this.getMap().getBlobsInRadius(this.getPosition(), 200.0f, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ block = blobsInRadius[i];
				if (block !is null)
				{
					if (block.getName() == "metal2" && block.hasTag("ready"))
					{

						block.getShape().SetStatic(false);
						//this.Chat("Good job sir. Take this " + give + ".");
						block.Tag("slave");
						this.Tag("parent");
						Vec2f blockpos = block.getPosition();
						Vec2f pos = this.getPosition();
						Vec2f diff = blockpos-pos;
						Vec2f pos_off = Vec2f(18, -2);
						Vec2f[] shape = { Vec2f( diff.x,  diff.y ) +pos_off,
										  Vec2f( diff.x+8,  diff.y ) +pos_off,
										  Vec2f( diff.x+8,  diff.y+8 ) +pos_off,
										  Vec2f( diff.x,  diff.y+8 ) +pos_off };
						this.getShape().AddShape( shape );
						
						block.set_u16("parentID", this.getNetworkID());
						block.set_Vec2f("block_offset", diff);
						print("block diff"+ diff.x + " " + diff.y);
						//return;
					}
				}
			}
		}
		this.Chat("yeyee");
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if(this.hasTag("parent")) return;

	CButton@ button = caller.CreateGenericButton(
	"$pushbutton_1$",                           // icon token
	Vec2f_zero,                                 // button offset
	this,                                       // button attachment
	this.getCommandID("build"),              // command id
	"Build");                                // description

	button.radius = 16.0f;
	button.enableRadius = 32.0f;
}
