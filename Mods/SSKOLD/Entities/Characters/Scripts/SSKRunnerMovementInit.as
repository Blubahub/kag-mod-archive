// Runner Movement

#include "SSKRunnerCommon.as"

void onInit(CMovement@ this)
{
	SSKRunnerMoveVars moveVars;

	//walking vars
	moveVars.walkSpeed = 3.0f;
	moveVars.dashSpeed = 6.0f;
	moveVars.walkSpeedInAir = 2.5f;
	moveVars.walkFactor = 1.0f;
	moveVars.dashing = false;
	moveVars.walkLadderSpeed.Set(0.15f, 0.6f);

	//jumping vars
	moveVars.jumpMaxVel = 3.0f;
	moveVars.jumpStart = 1.0f;
	moveVars.jumpMid = 0.55f;
	moveVars.jumpEnd = 0.4f;
	moveVars.jumpFactor = 1.0f;
	moveVars.jumpMaxCount = 8;
	moveVars.jumpCount = 0;
	moveVars.numJumps = 0;
	moveVars.canVault = true;
	//swimming
	moveVars.swimspeed = 4.0;
	moveVars.swimforce = 30;
	moveVars.swimEdgeScale = 2.0f;
	//the overall scale of movement
	moveVars.overallScale = 1.0f;
	//stopping forces
	moveVars.stoppingForce = 0.50f; //function of mass
	moveVars.stoppingForceAir = 0.10f; //function of mass
	moveVars.stoppingFactor = 1.0f;
	//
	moveVars.walljumped = false;
	moveVars.walljumped_side = Walljump::NONE;
	moveVars.wallrun_length = 2;
	moveVars.wallrun_start = -1.0f;
	moveVars.wallrun_current = -1.0f;
	moveVars.wallclimbing = false;
	moveVars.wallsliding = false;
	//
	this.getBlob().set("moveVars", moveVars);
	this.getBlob().getShape().getVars().waterDragScale = 30.0f;
	this.getBlob().getShape().getConsts().collideWhenAttached = true;
}
