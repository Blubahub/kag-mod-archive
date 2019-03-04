//Archer Include
/*
/rcon CPlayer@ player=getPlayerByUsername('cirpons');CBlob@ blob=player.getBlob();CBlob@ test = server_CreateBlobNoInit('musketman');test.setPosition(blob.getPosition());blob.server_Die();test.Init();test.server_SetPlayer(player);test.server_setTeamNum(player.getTeamNum());
*/
namespace MusketmanParams
{
	enum Aim
	{
		not_aiming = 0,
		readying,
		charging,
		fired,
		no_bullets,
		stabbing,
	}

	const ::s32 ready_time = 49;

	const ::s32 shoot_period = 30;
	const ::s32 shoot_period_1 = MusketmanParams::shoot_period / 3;
	const ::s32 shoot_period_2 = 2 * MusketmanParams::shoot_period / 3;

	const ::s32 fired_time = 11;
	const ::f32 shoot_max_vel = 30.0f;
}

namespace BulletType
{
	enum type
	{
		normal = 0,
		count
	};
}

shared class MusketmanInfo
{
	s8 charge_time;
	u8 charge_state;
	bool has_bullet;
	u8 stab_delay;
	u8 fletch_cooldown;
	u8 bullet_type;

	MusketmanInfo()
	{
		charge_time = 0;
		charge_state = 0;
		has_bullet = false;
		stab_delay = 0;
		fletch_cooldown = 0;
		bullet_type = BulletType::normal;
	}
};

const string[] bulletTypeNames = { "mat_bullets"
                                };

const string[] bulletNames = { "Bullets"
                            };

const string[] bulletIcons = { "$Bullet$"
                            };


bool hasBullets(CBlob@ this)
{
	MusketmanInfo@ musketman;
	if (!this.get("musketmanInfo", @musketman))
	{
		return false;
	}
	if (musketman.bullet_type >= 0 && musketman.bullet_type < bulletTypeNames.length)
	{
		return this.getBlobCount(bulletTypeNames[musketman.bullet_type]) > 0;
	}

	return false;
}

bool hasBullets (CBlob@ this, u8 bulletType)
{
	if (bulletType >= 0 && bulletType < bulletTypeNames.length)
	{
		return this.getBlobCount(bulletTypeNames[bulletType]) > 0;
	}
	return false;
}

void SetBulletType(CBlob@ this, const u8 type)
{
	MusketmanInfo@ musketman;
	if (!this.get("musketmanInfo", @musketman))
	{
		return;
	}
	musketman.bullet_type = type;
}

u8 getBulletType(CBlob@ this)
{
	MusketmanInfo@ musketman;
	if (!this.get("musketmanInfo", @musketman))
	{
		return 0;
	}
	return musketman.bullet_type;
}
