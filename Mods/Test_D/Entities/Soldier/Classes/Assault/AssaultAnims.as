#include "SoldierCommon.as"

void onInit( CSprite@ this )
{
	this.ReloadSprite( "actor_assault.png" ); // fixes engine bug (consts.filename = filename not set in ReloadSprite overload)
	this.ReloadSprite( "actor_assault.png", 24, 24, Soldier::getTeamColorForSprite(this.getBlob()), 0 );

	{
		Animation@ anim = this.addAnimation( "stand", 0, false );
		anim.AddFrame(0);
	}
	{
		Animation@ anim = this.addAnimation( "run", 3, true );
		int[] frames = {2,3,4,7,8,9};
		anim.AddFrames( frames );
	}
	{
		Animation@ anim = this.addAnimation( "jump up", 3, false );
		int[] frames = {15,16,17};
		anim.AddFrames(frames);
	}
	{
		Animation@ anim = this.addAnimation( "jump down", 3, false );
		int[] frames = {17,18,19};
		anim.AddFrames(frames);
	}

	{
		Animation@ anim = this.addAnimation( "fire", 2, false );
		int[] frames = {6, 5};
		anim.AddFrames( frames );
	}
	{
		Animation@ anim = this.addAnimation( "fire ready", 5, false );
		anim.AddFrame(1);
	}

	{
		Animation@ anim = this.addAnimation( "fire running", 2, true );
		int[] frames = {27,28,29,32,33,34};
		anim.AddFrames( frames );
	}
	{
		Animation@ anim = this.addAnimation( "fire jumping", 2, true );
		int[] frames = {30, 31};
		anim.AddFrames( frames );
	}
	{
		Animation@ anim = this.addAnimation( "fire crouching", 2, false );
		int[] frames = {35,36};
		anim.AddFrames( frames );
	}


	{
		Animation@ anim = this.addAnimation( "crouch", 2, false );
		int[] frames = {10,11,12};
		anim.AddFrames( frames );
	}
	{
		Animation@ anim = this.addAnimation( "stand up", 1, false );
		int[] frames = {12,13,10};
		anim.AddFrames( frames );
	}

	{
		Animation@ anim = this.addAnimation( "slide start", 3, false );
		int[] frames = {13,25,26};
		anim.AddFrames( frames );
	}
	{
		Animation@ anim = this.addAnimation( "slide", 3, true );
		int[] frames = {25,26};
		anim.AddFrames( frames );
	}
	{
		Animation@ anim = this.addAnimation( "die", 2, false );
		int[] frames = {20,21,22,23};
		anim.AddFrames( frames );
	}
	{
		Animation@ anim = this.addAnimation( "ground", 0, false );
		anim.AddFrame(23);
	}
	{
		Animation@ anim = this.addAnimation( "fall up", 0, false );
		anim.AddFrame(22);
	}
	{
		Animation@ anim = this.addAnimation( "fall down", 0, false );
		anim.AddFrame(24);
	}
	{
		Animation@ anim = this.addAnimation( "crawl", 3, true );
		int[] frames = {22,22,23,24,24,23};
		anim.AddFrames( frames );
	}
	{
		Animation@ anim = this.addAnimation( "bite", 3, false );
		int[] frames = {24,24,23};
		anim.AddFrames( frames );
	}
	{
		Animation@ anim = this.addAnimation( "agony", 5, false );
		int[] frames = {23,23,22,23,22};
		anim.AddFrames( frames );
	}
	{
		Animation@ anim = this.addAnimation( "flip", 4, false );
		int[] frames = {14};
		anim.AddFrames( frames );
	}
	{
		Animation@ anim = this.addAnimation( "ladder", 0, false );
		int[] frames = {37,38};
		anim.AddFrames( frames );
	}
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	Soldier::Data@ data = Soldier::getData( blob );

	if (data.dead)
		return;

	const bool shot = data.shotTime >= data.gametime-4;
	data.specialAnim = shot;

	if (data.specialAnim)
	{
		//set anim on actual shot
		const bool runleft = data.left && !data.right && !data.onWall;
		const bool runright = data.right && !data.left && !data.onWall;
		const bool run = runleft || runright;

		if (data.shotTime <= data.gametime-1)
		{
			if (data.crouching){
				this.SetAnimation("fire crouching");
				this.SetFrameIndex(0);
			}
			else
			{
				if(data.ledgeClimb || !data.onGround)
				{
					this.SetAnimation("fire jumping");
					this.SetFrameIndex(0);
				}
				else if(run)
				{
					s32 frame = -1;
					if(this.isAnimation("running"))
						frame = this.getFrameIndex();

					this.SetAnimation("fire running");
					if(frame > 0)
						this.SetFrameIndex(frame);
				}
				else //on ground
				{
					this.SetAnimation("fire");
					this.SetFrameIndex(0);
				}
				//this.SetAnimation("fire ready");
			}
		}
	}
}
