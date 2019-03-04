
void onTick(CBlob@ this){

	const f32 angle = this.getAngleDegrees();

	CShape@ shape = this.getShape();
	
	float vel = shape.getAngularVelocity();
	
	float Amount = 0.05;
	
	if(this.getName() == "longboat")Amount = 0.2;
	if(this.getName() == "warboat")Amount = 0.3;
	if(this.getName() == "raft")Amount = 0.5;
	
	if (angle < 180 && angle > 2)
	{
		shape.SetAngularVelocity(vel-Amount);	
	}
	else
	if (angle > 180 && angle < 358)
	{
		shape.SetAngularVelocity(vel+Amount);		
	}
	else
	shape.SetAngularVelocity(0);
	
}