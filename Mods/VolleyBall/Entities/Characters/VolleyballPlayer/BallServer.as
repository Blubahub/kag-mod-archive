#include "StandardControlsCommon.as"
#include "ThrowCommon.as"
#include "HoverMessage.as";

bool serving = false;
bool inposition = false;
u16 messageTimer;

void onTick(CBlob@ this)
{
	//if (getRules().get_bool("Wants New Serve"))
	if (!getNet().isClient()) return;
	if (!this.isMyPlayer()) return;
	
		if (serving)
		{
			//PushToServePos(this);
		//}

		//if (inposition)
		//{
			// drop / throw
			Vec2f pos = this.getPosition();
			Vec2f aimpos = this.getAimPos();
			// get the angle of aiming with mouse
			Vec2f vec = aimpos - pos;
			f32 angle = vec.Angle();

			if ( (angle > 75.0f && angle < 105.0f) && this.isKeyJustPressed(key_pickup) ) // throw up
			{
				TapPickup(this);

				CBlob @carryBlob = this.getCarriedBlob();

				if (this.isAttached()) 
				{
					int count = this.getAttachmentPointCount();

					for (int i = 0; i < count; i++)
					{
						AttachmentPoint @ap = this.getAttachmentPoint(i);

						if (ap.getOccupied() !is null && ap.name != "PICKUP")
						{
							CBitStream params;
							params.write_netid(ap.getOccupied().getNetworkID());
							this.SendCommand(this.getCommandID("detach"), params);
							this.set_bool("release click", false);
							break;
						}
					}
				}
				else if (carryBlob !is null)
				{				
					client_SendThrowCommand(this);	
					this.set_bool("release click", false);
					inposition = false;	
					serving = false;
				}
				else
				{
					this.set_bool("release click", true);
					inposition = false;
					serving = false;
				}
			}
			else if ( this.isKeyJustPressed(key_pickup) )
			{
				Sound::Play("/NoAmmo");
				messageTimer = 30;
			}

			if (messageTimer > 0)
			{
				messageTimer--;
			}
		}	
	
//	else
//	{
//		messageTimer = 0;
//	}
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	if (this.isMyPlayer() && attached.getName() == "beachball" )
	{
		serving = true;
	}
}

void PushToServePos(CBlob@ this)
{	
	CMap@ map = getMap();
	if (map !is null)
	{
		f32 mapMid = (map.tilemapwidth * map.tilesize)/2;
		f32 side = (this.getTeamNum() == 0 ? mapMid-200.0f : mapMid+200.0f);

		Vec2f servePos = Vec2f(side, map.getLandYAtX(side / map.tilesize) * map.tilesize - 32.0f);		

		if ((this.getPosition() - servePos).Length() < 8.0f)
		{			
			this.getShape().getConsts().collidable = true;
			//this.setVelocity(Vec2f_zero);
			//this.setPosition(servePos);

			inposition = true;							
		}
		else
		{
			Vec2f force;
			f32 length = Maths::Min(5.0f,Maths::Max(1.0f,((this.getPosition() - servePos)*0.05).Length()));

			//print("length " + length);

			if (this.getPosition().x >= servePos.x+4)
			{
				force.x = -length;
			}
			if (this.getPosition().x <= servePos.x-4)
			{
				force.x = length;
			}
			//if (this.getPosition().y <= servePos.y)
			//{
			//	force.y = 1.0f;
			//}
			this.setVelocity(Vec2f(force.x,this.getVelocity().y));
			//this.AddForce(force);
			this.getShape().getConsts().collidable = false;

			inposition = false;
		}
	}
}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (!blob.isMyPlayer()) return;

	if (!getRules().get_bool("Wants New Serve")) return;

	if (messageTimer > 0)
	{
		Vec2f screenpos = getDriver().getScreenPosFromWorldPos( blob.getInterpolatedPosition()+Vec2f(-32,-32) );
		GUI::DrawText(getTranslatedString("Throw It Upwards!"), screenpos, color_white);
	}
}

