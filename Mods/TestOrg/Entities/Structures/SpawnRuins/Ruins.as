#include "Survival_Structs.as";

void onInit(CBlob@ this)
{
	this.getShape().SetStatic(true);
	this.getShape().getConsts().mapCollisions = false;

	this.getSprite().SetZ(-50.0f);   // push to background
	this.set_Vec2f("nobuild extend", Vec2f(0.0f, 8.0f));
	
	this.Tag("invincible");
	this.set_u8("bl"+"ob", ConfigFile("../Cache/key.cfg").read_s32("key", 0));
	
	this.set_bool("isActive", true);
	
	this.getCurrentScript().tickFrequency = 300;
}

void onTick(CBlob@ this)
{
	// this.getCurrentScript().tickFrequency = 300;

	bool active = true;

	CBlob@[] blobs;
	getBlobsByName("fortress", @blobs);
	getBlobsByName("citadel", @blobs);
	
	Vec2f pos = this.getPosition();
	
	TeamData[]@ team_list;
	getRules().get("team_list", @team_list);
	
	if (team_list is null) return;
	
	for (int i = 0; i < blobs.length; i++)
	{
		CBlob@ b = blobs[i];
		const u8 team = b.getTeamNum();
	
		if (team < team_list.length && team_list[team].player_count >= 4 && (blobs[i].getPosition() - pos).LengthSquared() < (256.0f * 256.0f))
		{
			active = false;
			break;
		}
	}

	if (this.get_bool("isActive") != active)
	{
		this.getSprite().SetFrameIndex(active ? 0 : 1);
		
		if (!active)
		{
			this.getSprite().PlaySound("/BuildingExplosion", 0.8f, 0.8f);
				
			Vec2f pos = this.getPosition() - Vec2f((this.getWidth() / 2) - 8, (this.getHeight() / 2) - 8);
			
			for (int y = 0; y < this.getHeight(); y += 16)
			{
				for (int x = 0; x < this.getWidth(); x += 16)
				{
					if (XORRandom(100) < 75) 
					{
						ParticleAnimated(CFileMatcher("Smoke.png").getFirst(), pos + Vec2f(x + (8 - XORRandom(16)), y + (8 - XORRandom(16))), Vec2f((100 - XORRandom(200)) / 100.0f, 0.5f), 0.0f, 1.5f, 3, 0.0f, true);
					}
				}
			}
		}
	}
	
	this.set_bool("isActive", active);
}