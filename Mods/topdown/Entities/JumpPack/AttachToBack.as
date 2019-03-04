
void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
}
void onTick(CBlob@ this)
{	
	this.getCurrentScript().runFlags |= Script::tick_attached;
	CBlob@ holder = this.getAttachments().getAttachedBlob("PICKUP", 0);

	if(holder !is null)
	{/*
		//AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("BACK");
		if(point is null)
		{
			print("point null");
			//return;
	}*/
		CControls@ controls = holder.getControls();
		if(controls is null) return;
		bool pressed = controls.isKeyJustPressed(KEY_KEY_X);
		if(pressed)
		{
			holder.server_AttachTo(this, "BACK");
			AttachmentPoint@ point = holder.getAttachments().getAttachmentPointByName("BACK");
			if(point is null)
			{
				print("point is null");
				return;
			}
			point.SetKeysToTake( key_action1 | key_action2 | key_action3 | key_down );
			return;
		}
		print("fuck up");

	}	

}
