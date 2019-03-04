// A script by TFlippy, and used by Char. thanks TFlippy!

const string[] musicNames =
{
	"Disc_TakeOnMe.ogg",
	"Disc_WelcomeToTheClub.ogg",
	"Disc_RickAstley.ogg",
	"Disc_GhostBusters.ogg",
 	"Disc_SassyGirl.ogg",
	"Disc_TheZing.ogg",
	"Disc_NeverGetNaked.ogg",
	"Disc_VivaLa.ogg",
	"Disc_SpiderRiders",
 	"Disc_KillLa.ogg",
	"Disc_TheSweetEscape.ogg",
	"Disc_Clarity.ogg",
	"Disc_EveryAnime.ogg",
	"Disk_blank.ogg",
};

// 255 = no disc

const int DiscNum = 12;

void onInit(CBlob@ this)
{
	this.set_u8("trackID", 255);
	this.set_bool("isPlaying", false);
	
	this.addCommandID("sv_insert");
	this.addCommandID("sv_eject");
	this.addCommandID("cl_play");
	this.addCommandID("cl_stop");
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (getNet().isServer())
	{
		// print("server");
		if (cmd == this.getCommandID("sv_insert"))
		{
			CBlob@ caller = getBlobByNetworkID(params.read_u16());
			CBlob@ carried = caller.getCarriedBlob();
			
			if (this.get_bool("isPlaying") || this.getMap().rayCastSolid(caller.getPosition(), this.getPosition())) return;
	
			bool isTrackValid = carried !is null && carried.getName() == "musicdisc" && carried.get_u8("trackID") >= 0 && carried.get_u8("trackID") < DiscNum + 1;
			
			if (isTrackValid)
			{
				u8 trackID = carried.get_u8("trackID");
				
				// print("insert " + musicNames[trackID]);
				
				this.set_u8("trackID", trackID);
				this.set_bool("isPlaying", true);
				
				CBitStream stream;
				stream.write_u8(trackID);

				carried.server_Die();
				this.SendCommand(this.getCommandID("cl_play"), stream);
			}
		}
		else if (cmd == this.getCommandID("sv_eject"))
		{
			CBlob@ caller = getBlobByNetworkID(params.read_u16());
			
			if (this.getMap().rayCastSolid(caller.getPosition(), this.getPosition())) return;
			
			this.set_bool("isPlaying", false);
			
			CBlob@ disc = server_CreateBlob("musicdisc", 0, this.getPosition() + Vec2f(0, -4));
			disc.set_u8("trackID", this.get_u8("trackID"));
			disc.setVelocity(Vec2f(0, -8));
			
			CBitStream discStream;
			discStream.write_u8(this.get_u8("trackID"));
			disc.SendCommand(disc.getCommandID("set"), discStream);
			
			CBitStream stream;
			this.SendCommand(this.getCommandID("cl_stop"), stream);	
		}
	}
	
	if (getNet().isClient())
	{
		if (cmd == this.getCommandID("cl_play"))
		{
			u8 trackID = params.read_u8();
			bool isTrackValid = trackID >= 0 && trackID < DiscNum + 1;
			
			// print("play " + musicNames[trackID]);
			
			if (isTrackValid)
			{
				this.set_bool("isPlaying", true);
				this.set_u8("trackID", trackID);
			
				CSprite@ sprite = this.getSprite();
				sprite.RewindEmitSound();
				sprite.SetEmitSound(musicNames[trackID]);
				sprite.SetEmitSoundPaused(false);
				sprite.SetAnimation("track" + trackID);
			}
		}
		else if (cmd == this.getCommandID("cl_stop"))
		{
			// print("stop");
		
			this.set_u8("trackID", 255); // Empty
			this.set_bool("isPlaying", false);
		
			CSprite@ sprite = this.getSprite();
			sprite.SetEmitSoundPaused(true);
			sprite.SetAnimation("empty");
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (this.getMap().rayCastSolid(caller.getPosition(), this.getPosition())) return;

	CBlob@ carried = caller.getCarriedBlob();
	
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	
	f32 flip = this.isFacingLeft() ? -1.00f : 1.00f;
	
	CButton@ buttonEject = caller.CreateGenericButton(9, Vec2f(-4 * flip, 8), this, this.getCommandID("sv_eject"), "Eject", params);
	CButton@ buttonInsert = caller.CreateGenericButton(17, Vec2f(4 * flip, 8), this, this.getCommandID("sv_insert"), "Insert", params);

	bool isTrackValid = carried !is null && carried.getName() == "musicdisc" && carried.get_u8("trackID") >= 0 && carried.get_u8("trackID") < DiscNum + 1;
	
	buttonInsert.SetEnabled(isTrackValid && !this.get_bool("isPlaying"));
	buttonEject.SetEnabled(this.get_bool("isPlaying"));
}

void onThisAddToInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	if (inventoryBlob is null) return;

	CInventory@ inv = inventoryBlob.getInventory();

	if (inv is null) return;

	this.doTickScripts = true;
	inv.doTickScripts = true;
}

void onDie(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	sprite.SetEmitSoundPaused(true);
}