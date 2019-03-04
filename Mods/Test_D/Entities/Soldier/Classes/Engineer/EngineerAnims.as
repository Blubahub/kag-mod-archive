#include "SoldierCommon.as"
#include "GameColours.as"

void onInit( CSprite@ this )
{
	this.ReloadSprite( "actor_engineer.png" ); // fixes engine bug (consts.filename = filename not set in ReloadSprite overload)
	this.ReloadSprite( "actor_engineer.png", 24, 24, Soldier::getTeamColorForSprite(this.getBlob()), 0 );

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
		int[] frames = {5};
		anim.AddFrames( frames );
	}
	{
		Animation@ anim = this.addAnimation( "ladder", 0, false );
		int[] frames = {27,28};
		anim.AddFrames( frames );
	}
	{
		Animation@ anim = this.addAnimation( "rocket", 2, false );
		int[] frames = {10,11,14};
		anim.AddFrames( frames );
	}
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	Soldier::Data@ data = Soldier::getData( blob );

	if (data.dead)
		return;

	data.specialAnim = data.crosshair;

	if (data.specialAnim)
	{
		this.SetAnimation("rocket");
	}
}

