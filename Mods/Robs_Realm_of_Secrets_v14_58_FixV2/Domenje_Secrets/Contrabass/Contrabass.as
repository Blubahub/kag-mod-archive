
#include "Hitters.as";
#include "SplashWater.as";
#include "Instrument.as";

//logic
void onInit(CBlob@ this)
{
	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (ap !is null)
	{
		ap.SetKeysToTake(key_action1 | key_action2 | key_action3);
	}
	
	this.addCommandID("_note");
	this.set_u8("timer",0);
	
	this.set_u8("instrument",0);
}

void onTick(CBlob@ this)
{
	if (this.isAttached()){
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		CBlob@ holder = point.getOccupied();
		
		if(this.get_u8("timer") > 0)this.set_u8("timer",this.get_u8("timer")-1);
		
		if(point.isKeyJustPressed(key_action2)){
			this.set_u8("instrument",this.get_u8("instrument")+1);
			if(this.get_u8("instrument") > 2)this.set_u8("instrument",0);
		}
		
		if(holder !is null)
		if(this.get_u8("timer") == 0 || point.isKeyJustPressed(key_action1))
		if(point.isKeyPressed(key_action1)){
			
			u8 note = 0;
			
			f32 distance = Maths::Sqrt((Maths::Pow(holder.getAimPos().x-holder.getPosition().x,2))+(Maths::Pow(holder.getAimPos().y-holder.getPosition().y,2)));
			
			if(distance > 37*6)distance = 37*6;
			
			//print("distance: "+Maths::Round(distance/6));
			
			note = Maths::Round(distance/6);
				
			sendNote(this, note, this.get_u8("instrument"));
			playNote(this, note, this.get_u8("instrument"), 1.0f);
			
			this.set_u8("timer",15);
		}
	}
}