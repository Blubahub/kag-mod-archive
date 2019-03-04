#include "GetAttached.as"
#include "Hitters.as"

#include "BomberCommon.as"

void onTick( CBlob@ this )
{
	BomberInfo@ bomber;
	if (!this.get( "bomberInfo", @bomber )) {
		return;
	}
	
	CBlob@ flyer = getAttached( this, "FLYER" );
			
	CAttachment@ attachment = this.getAttachments();
	AttachmentPoint@ point = attachment.getAttachmentPointByName("FLYER");
	
		if (point !is null && point.isKeyJustPressed(key_action3) && getNet().isServer())
		{
			const u16 coal = this.getBlobCount("mat_coal");
			for (uint i = 0; i < bombTypeNames.length; i++)
			{	
				if (i == bomber.bomb_type && coal >= fireBombPrice)
				{
					const u16 ammo = this.getBlobCount(bombTypeNames[i]);
					if (ammo > 0)
					{
						this.TakeBlob(bombTypeNames[i], 1);
						this.TakeBlob("mat_coal", fireBombPrice);
						CBlob@ bomb = server_CreateBlob( bombBlob[i], this.getTeamNum(), this.getPosition() + Vec2f(0, 16));
						if (bomb !is null)
						{
							if (bomb.getConfig() == "waterbomb")
							{
								bomb.set_f32("map_damage_ratio", 0.0f);
								bomb.set_f32("explosive_damage", 0.0f);
								bomb.set_f32("explosive_radius", 92.0f);
								bomb.set_bool("map_damage_raycast", false);
								bomb.set_string("custom_explosion_sound", "/GlassBreak");
								bomb.set_u8("custom_hitter", Hitters::water);
							}
							bomb.AddForce(Vec2f(0, 50));
						}	
					}
				}	
			}
		}
	}