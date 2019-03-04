#include "SoldierCommon.as"

void onInit( CSprite@ this )
{
	this.ReloadSprite( "actor_medic.png" );
	this.ReloadSprite( "actor_medic.png", 24, 24, Soldier::getTeamColorForSprite(this.getBlob()), 0 );

	//normal
	{
		Animation@ anim = this.addAnimation( "stand", 0, false );
		anim.AddFrame(0);
	}
	{
		Animation@ anim = this.addAnimation( "run", 3, true );
		int[] frames = {2,3,4,7,8,9};
		anim.AddFrames( frames );
	}

	//shielded
	{
		Animation@ anim = this.addAnimation( "shield", 0, false );
		anim.AddFrame(1);
	}
	{
		Animation@ anim = this.addAnimation( "shield run", 3, true );
		int[] frames = {12,13,14,17,18,19};
		anim.AddFrames( frames );
	}

	{
		Animation@ anim = this.addAnimation( "jump up", 3, false );
		int[] frames = {25,26,27};
		anim.AddFrames(frames);
	}
	{
		Animation@ anim = this.addAnimation( "jump down", 3, false );
		int[] frames = {27,28,29};
		anim.AddFrames(frames);
	}

	{
		Animation@ anim = this.addAnimation( "crouch", 2, false );
		int[] frames = {20,21,22};
		anim.AddFrames( frames );
	}
	{
		Animation@ anim = this.addAnimation( "stand up", 1, false );
		int[] frames = {22,23,0};
		anim.AddFrames( frames );
	}

	{
		Animation@ anim = this.addAnimation( "slide start", 3, false );
		int[] frames = {15,16};
		anim.AddFrames( frames );
	}
	{
		Animation@ anim = this.addAnimation( "slide", 3, true );
		int[] frames = {15,16};
		anim.AddFrames( frames );
	}
	{
		Animation@ anim = this.addAnimation( "die", 2, false );
		int[] frames = {15};
		anim.AddFrames( frames );
	}
	{
		Animation@ anim = this.addAnimation( "ground", 0, false );
		anim.AddFrame(6);
	}
	{
		Animation@ anim = this.addAnimation( "fall up", 0, false );
		anim.AddFrame(5);
	}
	{
		Animation@ anim = this.addAnimation( "fall down", 0, false );
		anim.AddFrame(10);
	}
	{
		Animation@ anim = this.addAnimation( "crawl", 3, true );
		int[] frames = {5,5,6,10,10,6};
		anim.AddFrames( frames );
	}
	{
		Animation@ anim = this.addAnimation( "bite", 3, false );
		int[] frames = {10,10,6};
		anim.AddFrames( frames );
	}
	{
		Animation@ anim = this.addAnimation( "agony", 5, false );
		int[] frames = {6,6,5,6,5};
		anim.AddFrames( frames );
	}
	{
		Animation@ anim = this.addAnimation( "flip", 4, false );
		int[] frames = {11};
		anim.AddFrames( frames );
	}
	{
		Animation@ anim = this.addAnimation( "ladder", 0, false );
		int[] frames = {30,31};
		anim.AddFrames( frames );
	}

}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	Soldier::Data@ data = Soldier::getData( blob );

	if (data.dead || data.stunned)
	{
		return;
	}

	data.specialAnim = data.shield;

	if (data.specialAnim)
	{
		const bool runleft = data.left && !data.right && !data.onWall;
		const bool runright = data.right && !data.left && !data.onWall;
		const bool run = runleft || runright;

		if(run)
		{
			this.SetAnimation("shield run");
		}
		else if (data.crouch)
		{
			this.SetAnimation("crouch");
		}
		else
		{
			this.SetAnimation("crouch");
		}
	}
}
