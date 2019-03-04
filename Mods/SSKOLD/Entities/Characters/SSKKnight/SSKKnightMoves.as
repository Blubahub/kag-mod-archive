
#include "SSKKnightCommon.as"
#include "SSKMovesetCommon.as"
#include "ThrowCommon.as"

// SSKKnight attack logic

void onInit(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();

	this.addCommandID("start move");

	CSpriteLayer@ specialAura = sprite.addSpriteLayer("special aura", "aura5-orange.png" , 48, 48, 0, 0);
	if (specialAura !is null)
	{
		Animation@ anim = specialAura.addAnimation("default", 3, true);

		int[] frames = {0, 1, 2, 3};
		anim.AddFrames(frames);

		specialAura.SetVisible(false);
		specialAura.SetOffset(Vec2f(0,8));
		specialAura.SetRelativeZ(2.0f);
	}
}

void onTick(CBlob@ this)
{
	SSKStatusVars@ statusVars;
	if (!this.get("statusVars", @statusVars))
	{
		return;
	}

	bool isHitstunned = statusVars.isHitstunned;
	if (!isHitstunned)
	{
		resetLayerBools(this);	// reset variables that control effect layers
	}

	updateMoveAnimLogic(this, statusVars);

	renderEffects(this);
}

void updateMoveAnimLogic(CBlob@ this, SSKStatusVars@ statusVars)
{
	bool isHitstunned = statusVars.isHitstunned;
	u16 tumbleTime = statusVars.tumbleTime;
	if (isHitstunned || tumbleTime > 0)
	{
		return;
	}

	bool inMoveAnimation = statusVars.inMoveAnimation;

	CSprite@ sprite = this.getSprite();

	MoveAnimation@ moveAnim = statusVars.currMoveAnimation;
	if (inMoveAnimation)
	{
		if (moveAnim != null)
		{
			updateSpecialMoves(this, statusVars, moveAnim);
			updateCommonMoves(this, statusVars, moveAnim);
		}
	}
	else
	{
		// drop / pickup / throw
		if (this.isKeyJustPressed(key_pickup))
		{
			CBlob @carryBlob = this.getCarriedBlob();

			if (this.isAttached()) // default drop from attachment
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
			else if (carryBlob !is null && !carryBlob.hasTag("custom drop") && (!carryBlob.hasTag("temp this") || carryBlob.getName() == "ladder"))
			{
				this.clear("pickup thiss");
				client_SendThrowCommand(this);

				this.set_bool("release click", false);

				startMove(this, statusVars, MoveTypes::THROW);
			}
			else
			{
				this.set_bool("release click", true);

				startMove(this, statusVars, MoveTypes::GRAB);
			}
		}
		if (this.isKeyPressed(key_up) && this.isKeyJustPressed(key_action2))
		{
			// carrying heavy
			bool carryingHeavy = false;
			CBlob@ carryBlob = this.getCarriedBlob();
			if (carryBlob !is null)
			{
				if (carryBlob.hasTag("heavy weight"))
				{
					carryingHeavy = true;
				}
			}

			if (!statusVars.fallSpecial && !carryingHeavy)
			{
				startMove(this, statusVars, MoveTypes::UP_SPECIAL);
			}
		}
	}
}

void updateSpecialMoves(CBlob@ this, SSKStatusVars@ statusVars, MoveAnimation@ moveAnim)
{
	CSprite@ sprite = this.getSprite();
	Animation@ anim = sprite.getAnimation(moveAnim.name);

	// do grab sound effect at correct time
	if (moveAnim.moveType == MoveTypes::GRAB)
	{
		if (moveAnim.tick == 7)
		{
			sprite.PlaySound("grab1.ogg", 3.0f, 1.0f);
		}
	}
	else if (moveAnim.moveType == MoveTypes::UP_SPECIAL)
	{
		if (moveAnim.currFrameIndex == 0)
		{
			f32 aimAngle = -(this.getAimPos() - this.getPosition()).Angle();
			this.set_f32("move angle", aimAngle);	

			this.setVelocity( Vec2f(0, 0) );

			// effects
			if (moveAnim.tick % 7 == 0)
			{
				/*
				CParticle@ p = ParticleAnimated( "aura2.png", this.getPosition() + Vec2f(0,-16), Vec2f(0,0), 0.0f, 1.0f, 2, 0.0f, false );
				if ( p !is null)
				{
					p.Z = 300.0f;
				}
				*/
				CParticle@ p = ParticleAnimated( "sparkle2-small-yellow.png", this.getPosition(), Vec2f(0,0), float(XORRandom(360)), 1.0f, 2, 0.0f, false );
				if ( p !is null)
				{
					p.Z = 100.0f;
				}				
			}

			if (moveAnim.tick == 0)
			{
				sprite.PlaySound("charge1.ogg", 1.5f);
				statusVars.fallSpecial = true;
			}
		}
		else if (moveAnim.currFrameIndex < 7)
		{
			if (getNet().isServer() && moveAnim.currFrameIndex == 1)
			{
				this.Sync("move angle", true);
			}

			f32 moveAngle = this.get_f32("move angle");

			f32 vel = 6.0f;
			Vec2f moveVec = Vec2f(1,0).RotateBy(moveAngle);
			this.setVelocity( moveVec*vel );

			this.setAngleDegrees(moveAngle + 90.0f);

			if (!statusVars.hitThisFrame)
			{
				CustomHitData customHitData(2, 2.0f, 0.06f);
				arcAttack(this, false, 4.0f, moveAngle, 140.0f, 20.0f, Hitters::sword, customHitData);
			}

			// effects
			if( getNet().isClient() ) 
			{
				MoveFrame@ currMoveFrame = moveAnim.moveFrames[moveAnim.currFrameIndex];
				if (moveAnim.currFrameIndex == 1 && moveAnim.tick == currMoveFrame.endTick)
				{
					sprite.PlaySound("specialattack1.ogg", 1.5f, 1.0f);
				}	

				this.set_bool("effect specialattack1", true);
			}
		}
		else
		{
			this.setVelocity( Vec2f(0, 0) );
			statusVars.fastFalling = false;
		}
	}
}

void resetLayerBools(CBlob@ this)
{
	this.set_bool("effect specialattack1", false);
}

void renderEffects(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();

	CSpriteLayer@ specialAura = sprite.getSpriteLayer("special aura");
	if (this.get_bool("effect specialattack1"))
	{
		if (getGameTime() % 4 == 0)
		{
			f32 moveAngle = this.get_f32("move angle");
			Vec2f moveVec = Vec2f(1,0).RotateBy(moveAngle);
			CParticle@ rocketP = ParticleAnimated( "ring4-black.png", this.getPosition() + -moveVec*20.0f, moveVec*1.0f, moveAngle, 1.0f, 10, 0.0f, false );
			if ( rocketP !is null)
			{
				rocketP.Z = 100.0f;
			}	
		}
		
		/*
		if (getGameTime() % 2 == 0)
		{
			f32 moveAngle = this.get_f32("move angle");
			Vec2f moveVec = Vec2f(1,0).RotateBy(moveAngle);

			const f32 rad = 4.0f;
			Vec2f random1 = Vec2f( XORRandom(128)-64, XORRandom(128)-64 ) * 0.015625f * rad;
			CParticle@ rocketP = ParticleAnimated( "rocketfire1.png", this.getPosition() + moveVec*18.0f + random1, Vec2f(0,0), float(XORRandom(360)), 1.0f, 2 + XORRandom(3), 0.0f, false );
			if ( rocketP !is null)
			{
				if (XORRandom(2) == 0)
				{
					rocketP.Z = 100.0f;
				}
				else
				{
					rocketP.Z = -100.0f;
				}
			}
		}
		*/

		/*
		if (getGameTime() % 3 == 0)
		{
			const f32 rad = 4.0f;
			Vec2f random1 = Vec2f( XORRandom(128)-64, XORRandom(128)-64 ) * 0.015625f * rad;
			CParticle@ rocketP = ParticleAnimated( "energybeam2.png", this.getPosition() + aimVec*4.0f + random1, aimVec*0.4f, aimAngle, 1.0f, 6 + XORRandom(3), 0.0f, false );
			if ( rocketP !is null)
			{
				rocketP.Z = 100.0f;
			}
		}
		*/

		specialAura.SetVisible(true);
	}
	else
	{
		specialAura.SetVisible(false);
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("start move"))
	{
		if (!canSendMove(this))
		{
			u8 moveType = params.read_u8();
			int moveIndex = getMoveIndexByType(SSKKnightParams::moveset, moveType);
			if (moveIndex >= 0)
			{
				MoveAnimation@ moveAnim = SSKKnightParams::moveset[moveIndex];
				handleStartMove(this, moveAnim);
			}
		}
	}
}

void startMove(CBlob@ this, SSKStatusVars@ statusVars, u8 moveType)
{
	if (canSendMove(this))	//getNet().isServer()
	{
		int moveIndex = getMoveIndexByType(SSKKnightParams::moveset, moveType);
		if (moveIndex >= 0)
		{
			MoveAnimation@ moveAnim = SSKKnightParams::moveset[moveIndex];
			handleStartMove(this, moveAnim);
		}

		CBitStream bt;
		bt.write_u8( moveType );
		this.SendCommand(this.getCommandID("start move"), bt);
	}
}

bool canSendMove(CBlob@ this)
{
	return (this.isMyPlayer() || this.getPlayer() is null || this.getPlayer().isBot());
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (damage > 0)
	{
		resetLayerBools(this);
	}

	return damage;
}