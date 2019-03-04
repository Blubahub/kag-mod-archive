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
	this.set_u32("blocks", 0);
	//this.getShape().SetRotationsAllowed(false);
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
	u32 boost = this.get_u32("boost timer");
	bool canBoost = (boost < 1);
	if(boost > 0)
	{
		boost--;
	}
	if (driver !is null)
	{
		f32 angle = this.getAngleDegrees();
		if(point.isKeyPressed(key_left))
		{
			//print("left");
			//this.server_Die();
			//this.setAngleDegrees(angle-1);
			this.AddTorque(-30);
			//this.AddForce(Vec2f(-10, 0));
		}		
		if(point.isKeyPressed(key_right))
		{
			//print("right");
			//this.server_Die();
			//this.setAngleDegrees(angle+10);
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

		if(point.isKeyPressed(key_action3) && canBoost)
		{
			//print("down");
			//this.server_Die();
			Vec2f dir = Vec2f(0, -3000);
			dir.RotateBy(angle);
			this.AddForce(Vec2f(dir));
			boost = 100;
			this.getSprite().PlaySound("Respawn.ogg");
		}

		this.set_u32("boost timer", boost);
	}


//	if (blob.isMyPlayer() && ap.isKeyJustPressed(key_up))
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{

	if (cmd == this.getCommandID("build") && !this.hasTag("parent"))
	{
		CBlob@[] blobsInRadius;	   
			if (this.getMap().getBlobsInRadius(this.getPosition(), 100.0f, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ block = blobsInRadius[i];
				if (block !is null)
				{
					if (block.getName() == "metal2" && !block.hasTag("slave") && block.hasTag("ready") && block.getTeamNum() == this.getTeamNum())
					{
						
						u32 blocks = this.get_u32("blocks") + 1;
						string pointname = ("A" + blocks);
						//print("A"+pointname);
						this.server_AttachTo(block, pointname);
						AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName(pointname);

						//lazer.SetOffset(Vec2f(-6, -6));
						block.getShape().SetStatic(false);
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
						if(point !is null)
						{
							point.offset = diff;

						}
						//block.set_u16("parentID", this.getNetworkID());
						//block.set_Vec2f("block_offset", diff);
						//print("block diff"+ diff.x + " " + diff.y);
						//return;
						this.set_u32("blocks", blocks);
						this.SetMass(this.getMass() + (blocks));
						//print(""+this.getMass());
					}
				}
			}
		}
		this.Chat("SHIP CONSTRUCTED");

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
