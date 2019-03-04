// thanks to Splittingred
// run on server now to prevent memleaks from not removing messages

#include "HoverMessage.as";

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	HoverMessage[]@ messages;
	if (blob.get("messages", @messages))
	{
		for (uint i = 0; i < messages.length; i++)
		{
			HoverMessage @message = messages[i];
			if (message.isExpired())
			{
				messages.removeAt(i);
			}
		}
	}
}

void onRender(CSprite@ this)
{
	if (!getNet().isClient())
		return;
	if (getRules().get_s16("in menu") > 0)
		return;

	GUI::SetFont("irrlicht");

	CBlob@ blob = this.getBlob();
	HoverMessage[]@ messages;
	if (blob.get("messages", @messages))
	{
		for (uint i = 0; i < messages.length; i++)
		{
			HoverMessage @message = messages[i];
			message.Draw(blob);
		}
	}
}
