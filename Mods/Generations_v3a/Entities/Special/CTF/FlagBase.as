// Flag base logic

#include "CTF_FlagCommon.as"

#include "GameplayEvents.as";

const string flag_caps = "flag_caps";
const string flag_return = "flag return";
const string flag_name = "ctf_flag";

void onInit(CBlob@ this)
{
	this.set_u8(flag_caps, 0);
	this.Sync(flag_caps, true);

	if (getNet().isServer())
	{
		CBlob@ flag = server_CreateBlob(flag_name, this.getTeamNum(), Vec2f(Maths::Round(this.getPosition().x/8)*8-2,Maths::Round(this.getPosition().y/8)*8));
		if (flag !is null)
		{
			//this.server_AttachTo(flag, "FLAG");
			flag.Tag("return");
			this.set_u16("flag id", flag.getNetworkID());
			flag.set_u16("base_id", this.getNetworkID());

			this.Sync("flag_id", true);
		}

	}

	//cannot fall out of map
	this.SetMapEdgeFlags(u8(CBlob::map_collide_up) |
	                     u8(CBlob::map_collide_down) |
	                     u8(CBlob::map_collide_sides));

	//we actually have our own way of ignoring damage
	//but this is important for a lot of other scripts
	this.Tag("invincible");

	this.addCommandID(flag_return);
	
	this.set_u8("race",0);
}

void onTick(CBlob@ this)
{
	if (getNet().isServer())
	{

		if (!this.hasAttached())
		{
			this.Tag("flag missing");
			u16 id = this.get_u16("flag id");
			CBlob@ b = getBlobByNetworkID(id);
			if (b !is null)
			{
				if (!b.isAttached() && !b.isAttached() && b.hasTag("return"))
				{
					//sync tag, flag can play sounds
					this.SendCommand(this.getCommandID(flag_return));
					b.Untag("return"); //local

					this.server_AttachTo(b, "FLAG");
					b.SetFacingLeft(this.isFacingLeft());
				}
			}
			else
			{
				this.Tag("flag captured");
				Vec2f pos = this.getPosition();
				this.getMap().RemoveSectorsAtPosition(pos, "no build", this.getNetworkID());
				//this.getMap().server_AddSector(pos + Vec2f(-12, -8), pos + Vec2f(12, 16), "no build", "", this.getNetworkID());
                int StillFlags = 0;
				{
					CBlob@[] fg;
					getBlobsByName("flag_base", @fg);
					for(uint i = 0; i < fg.length; i++)
					{
						if(fg[i].getTeamNum() == this.getTeamNum())
						{
							StillFlags++;
						}
					}
				}
				if(StillFlags < 2)//if this is the last flag base, then kill everyone
				{
					for(u8 i = 0; i < getPlayerCount(); i++)
					{
						CPlayer@ p = getPlayer(i);
						if(p !is null && p.getTeamNum() == this.getTeamNum())
						{
							p.server_setTeamNum(XORRandom(100)+100);
							CBlob@ b = p.getBlob();
							if(b !is null)
							{
								b.server_Die();
							}
						}
					}
					
					CBlob@[] teamBlobs;	   
					getBlobsByName("stone_door", @teamBlobs);
					getBlobsByName("wooden_door", @teamBlobs);
					getBlobsByName("storage", @teamBlobs);
					getBlobsByName("quarry", @teamBlobs);
					for (uint i = 0; i < teamBlobs.length; i++)
					{
						CBlob@ b = teamBlobs[i];
						if(b.getTeamNum() == this.getTeamNum())
						{
							b.server_setTeamNum(-1);
						}
					}
				}
				this.server_Die();
			}
		}
		else
		{
			this.Untag("flag missing");
			
			u16 id = this.get_u16("flag id");
			CBlob@ b = getBlobByNetworkID(id);
			if (b !is null)
			{
				b.set_u8("race",this.get_u8("race"));
				b.Sync("race",true);
			}
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID(flag_return))
	{
		u16 id = this.get_u16("flag id");
		CBlob@ b = getBlobByNetworkID(id);
		if (b !is null)
		{
			if (getNet().isServer())
			{
				b.SendCommand(b.getCommandID("return"));
			}

			b.Untag("return");
		}

	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	//ignore all damage
	return 0.0f;
}

//sprite

void onInit(CSprite@ this)
{
	this.SetZ(-10.0f);
}

void onTick(CSprite@ this)
{
	this.SetFrameIndex(this.getBlob().get_u8("race"));
}

//release held flag when touched
void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null || !getNet().isServer()) return;

	CPlayer@ p = blob.getPlayer();
	if(p is null)return;
	
	if (!blob.hasTag("player") ||  blob.hasTag("ignore_flags")) return;	//early out for non-player collision
	
	int team = this.getTeamNum();

	if (blob.getTeamNum() >= 20 && p.getTeamNum() >= 20)
	{
		if (getNet().isServer())
		{	
			p.server_setTeamNum(team);
			blob.server_setTeamNum(team);
		}
		return;
	}
	
	if (!this.hasAttached()) return;		//early out if we dont have a flag attached

	if (blob.getTeamNum() != this.getTeamNum() && !blob.hasTag("key"+this.getTeamNum()))
	{
		if (canPickupFlag(blob))
		{
			this.server_DetachAll();

			u16 id = this.get_u16("flag id");
			CBlob@ b = getBlobByNetworkID(id);
			if (b !is null)
			{
				blob.server_AttachTo(b, "PICKUP"); //attach to player

				CPlayer@ player = blob.getPlayer();

				string name = "someone";
				if (player !is null)
				{
					name = player.getUsername();
				}

				CBitStream params;
				params.write_string(name);

				b.SendCommand(b.getCommandID("pickup"), params);
			}
		}
	}
	else //our team
	{
		CBlob@ b = blob.getCarriedBlob();
		//carrying enemy flag
		if (b !is null && b.getName() == flag_name && b.getTeamNum() != this.getTeamNum())
		{
			SendGameplayEvent(createFlagCaptureEvent(blob.getPlayer()));
			
			if(getNet().isServer())
			{
				this.set_u8(flag_caps, this.get_u8(flag_caps) + 1);
				this.Sync(flag_caps, true);

				u8 caps = 0;

				CBlob@[] fg;
				getBlobsByName("flag_base", @fg);
				for(uint i = 0; i < fg.length; i++)
				{
					if(fg[i].getTeamNum() == this.getTeamNum())
					{
						u8 x = fg[i].get_u8(flag_caps);
						if(x > caps)
							caps = x;
					}
				}

				for(uint i = 0; i < fg.length; i++)
				{
					if(fg[i].getTeamNum() == this.getTeamNum())
					{
						fg[i].set_u8(flag_caps, caps);
						fg[i].Sync(flag_caps, true);
					}
				}
			}
			//smash the flag
			this.server_Hit(b, b.getPosition(), Vec2f(), 5.0f, 0xfa, true);

			CPlayer@ player = blob.getPlayer();

			string name = "someone";
			if (player !is null)
			{
				name = player.getUsername();
			}

			CBitStream params;
			params.write_string(name);
			b.SendCommand(b.getCommandID("capture"), params);
		}
	}

}