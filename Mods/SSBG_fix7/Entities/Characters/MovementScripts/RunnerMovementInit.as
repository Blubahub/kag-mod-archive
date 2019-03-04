// Runner Movement

#include "RunnerCommon.as"

void onInit( CMovement@ this )
{
    RunnerMoveVars moveVars;
    //walking vars
    moveVars.walkSpeed = 5.6f;
    moveVars.walkSpeedInAir = 4.5f;
    moveVars.walkFactor = 1.0f;
    moveVars.walkLadderSpeed.Set( 0.15f, 0.6f );
    //jumping vars
    moveVars.jumpMaxVel = 4.0f;
    moveVars.jumpStart = 2.00f;
    moveVars.jumpMid = 1.75f;
    moveVars.jumpEnd = 1.50f;
    moveVars.jumpFactor = 1.0f;
    moveVars.jumpCount = 0;
    moveVars.canVault = true;
    //swimming
    moveVars.swimspeed = 20.0;
    moveVars.swimforce = 30;
    moveVars.swimEdgeScale = 6.0f;
    //the overall scale of movement
    moveVars.overallScale = 1.0f;
    //stopping forces
    moveVars.stoppingForce = 0.70f; //function of mass
    moveVars.stoppingForceAir = 0.50f; //function of mass
    moveVars.stoppingFactor = 1.0f;
	//
	moveVars.walljumped = false;
	moveVars.walljumped_side = Walljump::NONE;
	moveVars.wallrun_length = 3;
	moveVars.wallrun_start = -1.0f;
	moveVars.wallrun_current = -1.0f;
	moveVars.wallclimbing = false;
	moveVars.wallsliding = false;
	//
    this.getBlob().set( "moveVars", moveVars );
    this.getBlob().getShape().getVars().waterDragScale = 10.0f;
	this.getBlob().getShape().getConsts().collideWhenAttached = true;
}
