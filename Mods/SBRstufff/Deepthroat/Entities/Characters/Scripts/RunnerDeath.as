#include "Hitters.as"

const u32 VANISH_BODY_SECS = 45;
const string defaultpath = "../Mods/Deepthroat/Aaaaa/";

void onInit(CBlob@ this)
{
	this.set_f32("hit dmg modifier", 0.0f);
	this.set_f32("hit dmg modifier", 0.0f);
	this.getCurrentScript().tickFrequency = 0; // make it not run ticks until dead
}

//---------BEGIN: Deepthroat modifications (0/2)
void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if (this !is null && player !is null)
	{
		string sound_name = "";
		sound_name = player.getUsername();
		string sound_path = defaultpath + sound_name + ".ogg";
		string sound_path2 = defaultpath + "taunts/" + sound_name + "_taunt.ogg";
		string file = CFileMatcher(sound_path).getFirst();
		if (file != sound_path)
		{
			this.set_bool("deepthroat", false);
		}
		else
		{
			this.set_bool("deepthroat", true);
			this.set_string("deepthroatpath", file);
		}
		string file2 = CFileMatcher(sound_path2).getFirst();
		if (file2 == sound_path2)
		{
			this.set_string("deepthroatpath2", file2);
			this.AddScript("../Mods/Deepthroat/taunt.as");
		}
	}
}

//-----------END: Deepthroat modifications (0/2)

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	//---------BEGIN: Deepthroat modifications (1/2)
	//lookup username before player death logic kicks in
	CPlayer@ player = this.getPlayer();
	//---------END: Deepthroat modifications (1/2)
	
	// make dead state
	// make sure this script is at the end of onHit scripts for it gets the final health
	if (this.getHealth() <= 0.0f && !this.hasTag("dead"))
	{
		this.Tag("dead");
		this.set_u32("death time", getGameTime());

		this.UnsetMinimapVars(); //remove minimap icon

		this.set_f32("hit dmg modifier", 0.1f);
		this.set_f32("hit dmg modifier", 0.1f);

		// we want the corpse to stay but player to respawn so we force a die event in rules

		if (getNet().isServer())
		{
			if (this.getPlayer() !is null)
			{
				getRules().server_PlayerDie(this.getPlayer());
				this.server_SetPlayer(null);
			}
			else
			{
				getRules().server_BlobDie(this);
			}
		}

		// add pickup attachment so we can pickup body
		CAttachment@ a = this.getAttachments();

		if (a !is null)
		{
			AttachmentPoint@ ap = a.AddAttachmentPoint("PICKUP", false);
		}

		// sound

		if (this.getSprite() !is null) //moved here to prevent other logic potentially not getting run
		{
			f32 gibHealth = this.get_f32("gib health");

			if (this !is hitterBlob || customData == Hitters::fall)
			{
				if (this.isInWater())
				{
					if (this.getHealth() > gibHealth)
					{
						this.getSprite().PlaySound("Gurgle");
					}
				}
				//---------BEGIN: Deepthroat modifications (2/2)
				else if (this.getHealth() > gibHealth)
				{
					if (this.get_bool("deepthroat") && player !is null)
					{
						this.getSprite().PlaySound(this.get_string("deepthroatpath"));
					}
					else if (this.getHealth() > gibHealth / 2.0f)
					{
						this.getSprite().PlaySound("Wilhelm.ogg", 1.0f, this.getSexNum() == 0 ? 1.0f : 2.0f);
					}
					else
					{
						this.getSprite().PlaySound("WilhelmShort.ogg", this.getSexNum() == 0 ? 1.0f : 2.0f);
					}
				}
				//---------END: Deepthroat modifications (2/2)
			}

			// turn off bow sound (emit sound)
			this.getSprite().SetEmitSoundPaused(true);
		}

		this.getCurrentScript().tickFrequency = 30;

		this.set_f32("hit dmg modifier", 0.5f);

		// new physics vars so bodies don't slide
		this.getShape().setFriction(0.75f);
		this.getShape().setElasticity(0.2f);

		// disable tags
		this.Untag("shielding");
		this.Untag("player");
		this.getShape().getVars().isladder = false;
		this.getShape().getVars().onladder = false;
		this.getShape().checkCollisionsAgain = true;
		this.getShape().SetGravityScale(1.0f);
		// fall out of attachments/seats // drop all held things
		this.server_DetachAll();

		StuffFallsOut(this);
	}
	else
		this.set_u32("death time", getGameTime());

	return damage;
}


// erase all items before vanishing

void onTick(CBlob@ this)
{
	if (this.get_u32("death time") + VANISH_BODY_SECS * getTicksASecond() < getGameTime())
	{
		// destroy what was in inv

		CInventory@ inv = this.getInventory();
		if (inv !is null)
		{
			for (int i = 0; i < inv.getItemsCount(); i++)
			{
				CBlob @blob = inv.getItem(i);
				blob.server_Die();
			}
		}

		// vanish ourselves

		this.server_Die();
	}
}

// reset vanish counter on pickup

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	this.set_u32("death time", getGameTime());
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return (this.hasTag("dead") && this.getInventory().getItemsCount() > 0);
}

void StuffFallsOut(CBlob@ this)
{
	if (!getNet().isServer())
		return;

	int counter = 0;
	CInventory@ inv = this.getInventory();
	while (inv !is null && inv.getItemsCount() > 0)
	{
		CBlob @blob = inv.getItem(0);
		this.server_PutOutInventory(blob);
		blob.setVelocity(getRandomVelocity(90, 4.0f, 40));
		counter++;
		if (counter == 2) // optimization - just 2 stuff falls out
		{
			return;
		}
	}
}
