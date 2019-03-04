// Runner Movement Walking

#include "RunnerCommon.as"
#include "MakeDustParticle.as";

void onInit(CMovement@ this)
{
	this.getCurrentScript().removeIfTag = "dead";
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	CBlob@ blob = this.getBlob();
	blob.set_f32("horiz", 0.0f);
}

const f32 groundadd = 0.1f;
const f32 airadd = 3.2f;
const f32 maxair = 12.0f;
const f32 maxground = 2.0f;

void onTick(CMovement@ this)
{
	CBlob@ blob = this.getBlob();
	CPlayer@ player = blob.getPlayer();
	if(player !is null) 
		if(!player.isMyPlayer())
			return;
	f32 horiz = blob.get_f32("horiz");

	const bool left		= blob.isKeyPressed(key_left);
	const bool right	= blob.isKeyPressed(key_right);
	const bool up		= blob.isKeyPressed(key_up);
	const bool down		= blob.isKeyPressed(key_down);

	const bool is_client = getNet().isClient();

	CMap@ map = blob.getMap();
	Vec2f vel = blob.getVelocity();
	Vec2f pos = blob.getPosition();
	CShape@ shape = blob.getShape();
	const bool onground = blob.isOnGround();

	shape.SetGravityScale(0.5f);
	//shape.getVars().onladder = false;
	
	bool blizzardslowdown = false;
	
	CBlob@[] blizzards;
	getBlobsByName("blizzard", @blizzards);
	if (blizzards.length != 0)
	{
		Vec2f hit;
		getMap().rayCastSolidNoBlobs(Vec2f(pos.x, 0), pos, hit);
		f32 depth = pos.y - hit.y;
		if(depth <= 7)
			blizzardslowdown = true;
	}

	if (up && !down)
	{
		blob.AddForce(Vec2f(0.0,blizzardslowdown ? -5.5f : -6.2f));
		if (onground && is_client && vel.y < 0)
		{
			TileType tile = blob.getMap().getTile(blob.getPosition() + Vec2f(0.0f, blob.getRadius() + 4.0f)).type;
			if (blob.getMap().isTileGroundStuff(tile))
			{
				blob.getSprite().PlayRandomSound("/EarthJump");
			}
			else
			{
				blob.getSprite().PlayRandomSound("/StoneJump");
			}
		}
	}
	if (!up && !onground)
	{
		if(down)
			blob.AddForce(Vec2f(0.0,4.2f));
		else
			blob.setVelocity(Vec2f(vel.x, blizzardslowdown ? Maths::Clamp(vel.y, -1000.0f, Lerp(vel.y, 2.2f, 0.2f)) : Maths::Clamp(vel.y, -1000.0f, Lerp(vel.y, -1.2f, 0.1f))));
	}
		
	if(onground)
	{
		if(left || right)
		{
			if(left && !right && horiz >= -maxground)
				horiz -= groundadd;
			if(right && !left && horiz <= maxground)
				horiz += groundadd;
		}
		if(!(left || right))
			horiz = 0;
		horiz = Maths::Clamp(horiz, -maxground, maxground);
		blob.setVelocity(Vec2f(horiz, up ? -2.0f : 0.0f));
	}
	else
	{
		f32 horizadd = 0.08f;

		if(!(left || right))
		{
			if(horiz > 0.1f)
				horiz -= (horizadd > horiz ? horiz : horizadd);
			else if(horiz < -0.1f)
				horiz += (horizadd < horiz ? horiz : horizadd);
			else if(horiz == 0.0f)
				horiz == 0.0f;
		}

		else if(left || right)
		{
			if(left && !right && horiz >= -maxair)
				horiz -= 3.2;
			if(right && !left && horiz <= maxair)
				horiz += 3.2;
		}
	
		if(horiz <= maxair)
			horiz == maxair;
		if(horiz >= -maxair)
			horiz == -maxair;
		
		blob.AddForce(Vec2f(((blizzardslowdown ? horiz/ 3.3 : horiz/ 2.3) - vel.x),0.0f));
	}
	
	bool facing = blob.isFacingLeft();

	if (blob.hasAttached())
	{
		AttachmentPoint@[] aps;
		if (blob.getAttachmentPoints(@aps))
		{
			for (uint i = 0; i < aps.length; i++)
			{
				AttachmentPoint@ ap = aps[i];
				if (ap.socket && ap.getOccupied() !is null)
				{
					ap.getOccupied().SetFacingLeft(facing);
				}
			}
		}
	}
	blob.set_f32("horiz", horiz);
}

f32 Lerp(f32 v0, f32 v1, f32 t) 
{
	return v0 + t * (v1 - v0);
}