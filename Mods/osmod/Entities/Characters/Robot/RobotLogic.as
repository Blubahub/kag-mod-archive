// Robot logic

#include "MarkerBlock.as";

void onInit(CBlob@ this)
{	
	this.getSprite().SetZ(600.0f);
  	ShapeConsts@ consts = this.getShape().getConsts();
 	consts.mapCollisions = false;
	this.set_f32("gib health", -3.0f);
	this.getShape().SetGravityScale(0.0f);
	//this.Tag("player");


	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(true);
	//shape.getConsts().net_threshold_multiplier = 0.5f;


	this.set_string("robotstate", "idle");
}

void onTick(CBlob@ this)
{
	if(this.get_string("robotstate") == "idle")
	{	
		searchMarker(this);
	}  	

	if(this.get_string("robotstate") == "go")
	{	
		Vec2f pos = this.getPosition();
		u16 targetID = this.get_u16("targetID");
		CBlob@ target = getBlobByNetworkID(targetID);
		if(target !is null)
		{
			Vec2f targetpos = target.getPosition();
			Vec2f diff = targetpos - pos;
			Vec2f diff2 = diff;
			diff2.Normalize();
			//this.setAngleDegrees(diff2.Angle()-90);
			Vec2f force = diff2*10;
			this.AddForce(force);

			Detect(this, diff);
		}


	}  	
}

void searchMarker(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 30+XORRandom(30);

	CBlob@[] blobsInRadius;
   	if (this.getMap().getBlobsInRadius(this.getPosition(), 1080.0f, @blobsInRadius))
 	{
 		//print("searching...");
 		for (uint i = 0; i < blobsInRadius.length; i++)
 		{
 			CBlob@ blob = blobsInRadius[i];
 			if(blob !is null && blob.hasTag("marker"))// && blob.getTeamNum() == this.getTeamNum())
 			{
 				if(XORRandom(64) > 48) return;
 				this.set_string("robotstate", "go");
 				u16 targetID = blob.getNetworkID();
 				this.set_u16("targetID", targetID);
 				//print("target found!");
 				return;
 			}
 		}
 	}
}
void Detect(CBlob@ this, Vec2f diff)
{
	this.getCurrentScript().tickFrequency = 10;
	f32 distance = diff.Length();
	if(distance < 30.0f)
	{
		u16 targetID = this.get_u16("targetID");
		CBlob@ target = getBlobByNetworkID(targetID);
		if(target !is null && target.hasTag("marker"))
		{
			Construct(target);
			this.set_string("robotstate", "idle");
		}

		else
		{
			this.set_string("robotstate", "idle");

		}



	}
}