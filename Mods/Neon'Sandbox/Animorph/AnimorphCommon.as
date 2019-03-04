//AnimorphCommon.as
//@author: Verrazano
//@description: Turns player blobs into other blobs and gives them camera, emotes, and movement.
//@usage: Include this in a script then use the helper functions to morph/unmorph player blobs.
//see AdminAnimorph.as or ScrollAnimorph.as for a code example.

#include "/Entities/Common/Includes/Timer.as"

void setupMorphTimer(CRules@ this, f32 morphTime, bool killMorphedBlob = false)
{
	this.set_bool("morphTimerEnabled", true);
	this.set_f32("morphTime", morphTime);
	this.set_bool("killMorphedBlob", killMorphedBlob);

	CBitStream bitStream;
	bitStream.write_bool(true);
	bitStream.write_f32(morphTime);
	bitStream.write_bool(killMorphedBlob);

	this.SendCommand(this.getCommandID("setup_animorph_timer"), bitStream);

}

void disableMorphTimer(CRules@ this)
{
	this.set_bool("morphTimerEnabled", false);

	CBitStream bitStream;
	bitStream.write_bool(false);

	this.SendCommand(this.getCommandID("setup_animorph_timer"), bitStream);

}

void checkMorphTimer(CRules@ this)
{
	uint count = getPlayerCount();
	for(uint i = 0; i < count; i++)
	{
		CBlob@ blob = getPlayer(i).getBlob();
		if(blob is null || !blob.hasTag("morphed") || !blob.hasTag("hasMorphTimer"))
			continue;

		s32 ticksNeeded = blob.get_f32("morphTime")*getTicksASecond();
		if(timer_is_past_ticks(blob, "morphTimer", ticksNeeded))
		{
			if(this.get_bool("killMorphedBlob"))
			{
				blob.getSprite().Gib();
				blob.server_Die();

			}
			else
			{
				unmorph(this, blob);

			}

		}

	}

}

void morph(CRules@ this, CBlob@ blob, string morphBlob)
{
	CPlayer@ player = blob.getPlayer();
	if(player is null)
		return;

	if(morphBlob == "chicken" || morphBlob == "bison" || morphBlob == "fishy" || morphBlob == "shark")
	{
		CBitStream bitStream;
		bitStream.write_u16(blob.getNetworkID());
		bitStream.write_string(morphBlob);
		this.SendCommand(this.getCommandID("animorph"), bitStream);
		return;

	}
	else
	{
		CBitStream bitStream;
		bitStream.write_u16(blob.getNetworkID());
		bitStream.write_string(morphBlob);
		this.SendCommand(this.getCommandID("morph"), bitStream);
		return;

	}

}

void unmorph(CRules@ this, CBlob@ blob)
{
	CPlayer@ player = blob.getPlayer();
	if(player is null || !blob.hasTag("morphed"))
		return;

	CBitStream bitStream;
	bitStream.write_u16(blob.getNetworkID());
	this.SendCommand(this.getCommandID("unmorph"), bitStream);

}