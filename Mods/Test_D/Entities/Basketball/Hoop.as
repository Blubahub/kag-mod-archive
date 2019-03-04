#include "HoverMessage.as"
#include "Leaderboard.as"
#include "BackendCommon.as"

void onInit(CBlob@ this)
{
	CShape@ shape = this.getShape();
	shape.SetStatic(true);
	ShapeConsts@ consts = shape.getConsts();
	consts.mapCollisions = false;
	shape.SetOffset(Vec2f(0, -48));

	CSprite@ sprite = this.getSprite();
	sprite.SetZ(15);

	// add hoop shape
	{
		Vec2f[] hoop = {  Vec2f(2.0f, -4.0f),
		                  Vec2f(14.0f,  -4.0f),
		                  Vec2f(14.0f,  -3.0f),
		                  Vec2f(2.0f,  -3.0f)
		               };
		shape.AddShape(hoop);
	}

	this.addCommandID("score");
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.getName() == "ball";
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null && doesCollideWithBlob(this, blob))
	{
		Vec2f pos = this.getPosition();
		Vec2f ballpos = blob.getPosition();
		Vec2f ballvel = blob.getVelocity();
		const f32 sign = (this.isFacingLeft() ? -1.0f : 1.0f);
		if (
		    (
		        (this.isFacingLeft() && (ballpos.x < pos.x - 5.5f) && (ballpos.x > pos.x - 13.0f))
		        ||
		        (!this.isFacingLeft() && (ballpos.x > pos.x + 5.5f) && (ballpos.x < pos.x + 13.0f))
		    )
		    && (ballpos.y > (pos.y - 50.0f))  && (ballpos.y < (pos.y - 40.0f))
		)
		{
			//printf("SCORE!");
			ballpos.x = pos.x + sign * 9.0f;
			ballpos.y = pos.y - 38.0f;
			ballvel.x /= 2.0f;
			ballvel.y = 0.0f;
			blob.setPosition(ballpos);
			blob.setVelocity(ballvel);

			CPlayer@ p = blob.getDamageOwnerPlayer();
			if (getNet().isServer() && p !is null)
			{
				Leaderboard::AddScore("basketball leaderboard", p.getCharacterName(), 1);
				Backend::PlayerMetric(p, "basketball");

				CBitStream params;
				this.SendCommand(this.getCommandID("score"), params);
			}

			if (blob.hasTag("croc bounce"))
			{
				AddMessage(this, "CROC SHOT!!!");
			}

		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("score"))
	{
		this.getSprite().PlaySound("NetScore");
		AddMessage(this, "+1");
	}
}
