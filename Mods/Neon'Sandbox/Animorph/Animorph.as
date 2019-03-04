//Animorph.as
//@author: Verrazano
//@description: Turns player blobs into other blobs and gives them camera, emotes, and movement.
//@usage: add this file to gamemode.cfg.

#include "/Entities/Common/Includes/Timer.as"

void onInit(CRules@ this)
{
	this.addCommandID("morph");
	this.addCommandID("animorph");
	this.addCommandID("unmorph");
	this.addCommandID("setup_animorph_timer");
	this.set_bool("morphTimerEnabled", false);

}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if(cmd == this.getCommandID("morph"))
	{
		u16 blobID = params.read_u16();
		string morphName = params.read_string();

		CBlob@ blob = getBlobByNetworkID(blobID);
		if(blob is null || blob.hasTag("morphed"))
			return;

		if(getNet().isServer())
		{
			CPlayer@ player = blob.getPlayer();
			if(player is null)
				return;

			string lastBlobConfig = player.lastBlobConfig;
			string lastBlobName = player.lastBlobName;

			CBlob@ morphedBlob = server_CreateBlobNoInit(morphName);
			if(morphedBlob is null)
				return;

			blob.server_Die();

			morphedBlob.setPosition(blob.getPosition());

			morphedBlob.AddScript("StandardControls.as");
			morphedBlob.AddScript("EmoteHotkeys.as");
			morphedBlob.AddScript("EmoteBubble.as");

			morphedBlob.Init();

			CMovement@ movement = morphedBlob.getMovement();
			if(movement !is null)
			{
				movement.AddScript("RunnerMovementInit.as");
				movement.AddScript("RunnerMovement.as");
				morphedBlob.AddScript("RunnerMovement.as");
				morphedBlob.AddScript("RunnerMovementInit.as");

			}

			CBrain@ brain = morphedBlob.getBrain();
			if(brain !is null)
				brain.server_SetActive(false);

			morphedBlob.server_setTeamNum(blob.getTeamNum());
			morphedBlob.server_SetPlayer(player);
			morphedBlob.Tag("player");
			morphedBlob.Tag("morphed");

			if(this.get_bool("morphTimerEnabled"))
			{
				morphedBlob.Tag("hasMorphTimer");
				timer_reset(morphedBlob, "morphTimer");
				morphedBlob.set_f32("morphTime", this.get_f32("morphTime"));
				morphedBlob.set_bool("killMorphedBlob", this.get_bool("killMorphedBlob"));

			}

			player.lastBlobConfig = lastBlobConfig;
	    	player.lastBlobName = lastBlobName;

		}
		else
		{
			Sound::Play("/Sounds/Thunder2.ogg");
			ParticleZombieLightning(blob.getPosition());

		}

	}
	else if(cmd == this.getCommandID("animorph"))
	{
		u16 blobID = params.read_u16();
		string animorphName = params.read_string();

		if(!(animorphName == "chicken" || animorphName == "bison" || animorphName == "fishy" || animorphName == "shark"))
			return;

		CBlob@ blob = getBlobByNetworkID(blobID);
		if(blob is null || blob.hasTag("morphed"))
			return;

		if(getNet().isServer())
		{
			CPlayer@ player = blob.getPlayer();
			if(player is null)
				return;

			string lastBlobConfig = player.lastBlobConfig;
			string lastBlobName = player.lastBlobName;

			CBlob@ animorphedBlob = server_CreateBlobNoInit(animorphName);
			if(animorphedBlob is null)
				return;

			blob.server_Die();

			animorphedBlob.setPosition(blob.getPosition());

			animorphedBlob.AddScript("StandardControls.as");
			animorphedBlob.AddScript("EmoteHotkeys.as");
			animorphedBlob.AddScript("EmoteBubble.as");
			animorphedBlob.AddScript("RunnerMovement.as");

			animorphedBlob.Init();

			CMovement@ movement = animorphedBlob.getMovement();
			if(movement !is null)
			{
				movement.RemoveScript("LandAnimal.as");
				movement.RemoveScript("AquaticAnimal.as");

				movement.AddScript("RunnerMovementInit.as");
				movement.AddScript("RunnerMovement.as");
				animorphedBlob.AddScript("RunnerMovementInit.as");

			}

			CBrain@ brain = animorphedBlob.getBrain();
			if(brain !is null)
				brain.server_SetActive(false);

			animorphedBlob.server_setTeamNum(blob.getTeamNum());
			animorphedBlob.server_SetPlayer(player);
			animorphedBlob.Tag("player");
			animorphedBlob.Tag("morphed");

			if(this.get_bool("morphTimerEnabled"))
			{
				print("adding morph timer");
				animorphedBlob.Tag("hasMorphTimer");
				timer_reset(animorphedBlob, "morphTimer");
				animorphedBlob.set_f32("morphTime", this.get_f32("morphTime"));
				animorphedBlob.set_bool("killMorphedBlob", this.get_bool("killMorphedBlob"));

			}
			else
			{
				print("no morphtimer");

			}

			player.lastBlobConfig = lastBlobConfig;
	    	player.lastBlobName = lastBlobName;

		}
		else
		{
			Sound::Play("/Sounds/Thunder2.ogg");
			ParticleZombieLightning(blob.getPosition());
			
		}

	}
	else if(cmd == this.getCommandID("unmorph"))
	{
		u16 blobID = params.read_u16();

		CBlob@ blob = getBlobByNetworkID(blobID);
		if(blob is null || !blob.hasTag("morphed"))
			return;

		if(getNet().isServer())
		{
			CPlayer@ player = blob.getPlayer();
			if(player is null)
				return;

			blob.server_Die();

			string lastBlobConfig = player.lastBlobConfig;
			string lastBlobName = player.lastBlobName;

			CBlob@ oldBlob = server_CreateBlob(lastBlobName, blob.getTeamNum(), blob.getPosition());
			if(oldBlob is null)
				return;

			oldBlob.server_SetPlayer(player);
			oldBlob.Tag("player");

			player.lastBlobName = lastBlobName;
			player.lastBlobConfig = lastBlobConfig;

		}
		else
		{
			Sound::Play("/Sounds/Thunder1.ogg");
			ParticleZombieLightning(blob.getPosition());
			
		}

	}
	else if(cmd == this.getCommandID("setup_animorph_timer"))
	{
		bool morphTimerEnabled = params.read_bool();
		if(!morphTimerEnabled)
		{
			this.set_bool("morphTimerEnabled", false);
			return;

		}

		f32 morphTime = params.read_f32();
		bool killMorphedBlob = params.read_bool();

		this.set_bool("morphTimerEnabled", true);
		this.set_f32("morphTime", morphTime);
		this.set_bool("killMorphedBlob", killMorphedBlob);

	}

}