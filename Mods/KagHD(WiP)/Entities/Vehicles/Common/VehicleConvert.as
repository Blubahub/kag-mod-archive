/*
 * convertible if enemy alone with it
 * or in 
 */

const string raid_tag = "under raid";
const int capture_ticks = 4;
 
void onInit(CBlob@ this)
{
	this.addCommandID("convert");
	this.getCurrentScript().tickFrequency = 30;
	this.set_s32("capture ticks", capture_ticks );
}

//add 
void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
	if(!this.hasTag("convert on sit"))
		return;
	
	if (attachedPoint.socket &&
		attached.getTeamNum() != this.getTeamNum() &&
		attached.hasTag("player") )
	{
        this.server_setTeamNum(attached.getTeamNum());
    }
}

void onTick( CBlob@ this )
{
	CBlob@[] blobsInRadius;
	if (this.getMap().getBlobsInRadius( this.getPosition(), this.getRadius()*2.5f, @blobsInRadius ))
	{
		// first check if enemies nearby
		int attackersCount = 0;
		int friendlyCount = 0;
		int attackerTeam;
		Vec2f pos = this.getPosition();
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob @b = blobsInRadius[i];
			if (b !is this && b.hasTag("player") && !b.hasTag("dead")) 
			{
				if (b.getTeamNum() != this.getTeamNum())
				{
					Vec2f bpos = b.getPosition();
					if (bpos.x > pos.x - this.getWidth()/1.0f && bpos.x < pos.x + this.getWidth()/1.0f &&
						bpos.y < pos.y + this.getHeight()/1.0f && bpos.y > pos.y - this.getHeight()/1.0f)
					{
						attackersCount++;	
						attackerTeam = b.getTeamNum();	  
					}
				}
				else
				{
					friendlyCount++;
				}
			}
		}

		//printf("attackersCount " + attackersCount + " friendlyCount " + friendlyCount);
		if (attackersCount > 0)
		{	  			
			if (friendlyCount == 0)
			{
				int ticks = capture_ticks;
				if (this.hasTag(raid_tag)) {
					ticks = this.get_s32("capture ticks" );				
				}
				ticks--;
				this.set_s32("capture ticks", ticks );
				if (ticks <= 0)	{
					this.server_setTeamNum( attackerTeam );
				}
			}		
			else {
				this.set_s32("capture ticks", capture_ticks );
			}
			this.Tag(raid_tag);	
			return;
			// NOTHING BEYOND THIS POINT
		}
		else
		{
			this.Untag(raid_tag);
		}
	}	
	else
	{
		this.Untag(raid_tag);
	}
}

void onChangeTeam( CBlob@ this, const int oldTeam )
{
	if (this.getTeamNum() >= 0 && this.getTeamNum() < 10)
	{
		CSprite@ sprite = this.getSprite();
		if (sprite !is null)
		{
			sprite.PlaySound("/VehicleCapture");
		}

		ConvertPoint( this, "VEHICLE");
		ConvertPoint( this, "DOOR");
	}
}		 

void ConvertPoint( CBlob@ this, const string pointName )
{
	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName( pointName );
	if (point !is null)
	{
		CBlob@ blob = point.getOccupied();
		if (blob !is null)
		{
			blob.server_setTeamNum( this.getTeamNum() );
		}
	}
}


// alert and capture progress bar

void onRender(CSprite@ this)
{
	if (g_videorecording)
		return;

	CBlob@ blob = this.getBlob();
	if (blob.hasTag(raid_tag) )
	{
		Vec2f pos2d = getDriver().getScreenPosFromWorldPos( blob.getPosition() + Vec2f(0.0f, -blob.getHeight()) );

		if (getGameTime() % 20 > 4)
		{
			s32 captureTime = blob.get_s32("capture ticks" );		
			if (captureTime < capture_ticks) {
				GUI::DrawProgressBar( Vec2f(pos2d.x - 30.0f, pos2d.y + 45.0f), Vec2f(pos2d.x + 30.0f, pos2d.y + 60.0f), 1.0f - float(captureTime)/float(capture_ticks) );
			}
		}

		if (getGameTime() % 15 > 10)
		{
			GUI::DrawIconByName( "$ALERT$", Vec2f(pos2d.x-32.0f, pos2d.y-30.0f) );
		}
	}
}
