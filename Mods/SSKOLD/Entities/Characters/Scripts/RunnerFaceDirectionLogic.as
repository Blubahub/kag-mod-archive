#include "SSKKnightCommon.as";
#include "SSKArcherCommon.as";
#include "SSKStatusCommon.as"

//set facing direction to aiming direction

void onInit(CMovement@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
	this.getCurrentScript().tickFrequency = 3;
}

void onTick(CMovement@ this)
{
	CBlob@ blob = this.getBlob();

	SSKStatusVars@ statusVars;
	if (!blob.get("statusVars", @statusVars))
	{
		return;
	}

	// face direction of attack
	if (statusVars.inMoveAnimation)
	{
		blob.SetFacingLeft(statusVars.isAttackingLeft);
		return;
	}

	bool isHitstunned = statusVars.isHitstunned;
	u16 tumbleTime = statusVars.tumbleTime;
	u16 dazeTime = statusVars.dazeTime;

	// stop the logic if hitstunned
	if (isHitstunned || tumbleTime > 0 || dazeTime > 0)
	{
		return;
	}

	bool isFacingLeft = blob.isFacingLeft();

	bool doFaceLeft = false;

	const bool left		= blob.isKeyPressed(key_left);
	const bool right	= blob.isKeyPressed(key_right);	
	if (!left && !right)
		doFaceLeft = (blob.getAimPos().x <= blob.getPosition().x);
	else if (left && !right)
		doFaceLeft = true;
	else if (right && !left)
		doFaceLeft = false;

	// face attack direction
	SSKKnightInfo@ ssk_knight;
	if (blob.get("ssk_knightInfo", @ssk_knight))
	{
		 if (ssk_knight.state != SSKKnightStates::normal)
		 	doFaceLeft = (blob.getAimPos().x <= blob.getPosition().x);
	}

	SSKArcherInfo@ ssk_archer;
	if (blob.get("ssk_archerInfo", @ssk_archer))
	{
		 if (ssk_archer.charge_state != 0)
		 	doFaceLeft = (blob.getAimPos().x <= blob.getPosition().x);
	}

	blob.SetFacingLeft(doFaceLeft);

	// face for all attachments

	if (blob.hasAttached())
	{
		AttachmentPoint@[] aps;
		if (blob.getAttachmentPoints(@aps))
		{
			for (uint i = 0; i < aps.length; i++)
			{
				AttachmentPoint@ ap = aps[i];
				if (ap.socket && ap.getOccupied() !is null)
				{
					ap.getOccupied().SetFacingLeft(doFaceLeft);
				}
			}
		}
	}
}
