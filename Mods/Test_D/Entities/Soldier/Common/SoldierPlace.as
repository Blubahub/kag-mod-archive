#include "SoldierCommon.as"
#include "HoverMessage.as"

const f32 DELETE_RADIUS = 16.0f;

Vec2f getPlaceOffset(Soldier::Data@ data)
{
	return Vec2f(data.facingLeft ? -data.radius / 1.5f : data.radius / 1.5f, 0);
}

Vec2f getPlacePos(Soldier::Data@ data)
{
	return data.pos + getPlaceOffset(data);
}

Vec2f getTakePos(Soldier::Data@ data)
{
	return data.pos + Vec2f(data.direction * data.radius, -data.radius * 0.5f);
}

void InitPlaceOrDelete(CBlob@ this, const string &in name, const u16 count)
{
	this.set_u16(name + " count", count);
}

u16 getItemCount(CBlob@ this, const string &in name)
{
	const string countProperty = name + " count";
	return this.get_u16(countProperty);
}

void SetItemCount(CBlob@ this, const string &in name, u16 count)
{
	const string countProperty = name + " count";
	this.set_u16(countProperty, count);
}

void ChangeItemCount(CBlob@ this, const string &in name, int by)
{
	SetItemCount(this, name, int(getItemCount(this, name)) + by);
}

CBlob@ PlaceOrDelete(CBlob@ this, Soldier::Data@ data, const string &in name, const u8 team)
{
	if (DeleteBlob(this, data, name))
	{
		this.getSprite().PlaySound("Remove");
	}
	else
	{
		const string countProperty = name + " count";
		u16 count = this.get_u16(countProperty);
		if (count > 0)
		{
			count--;
			this.set_u16(countProperty, count);
			return PlaceBlob(this, data, name, team);
		}
		else
		{
			AddMessageAbove(this, "no " + name + 's');
			if (this.isMyPlayer()) Sound::Play("NoAmmo");
		}
	}
	return null;
}

CBlob@ PlaceBlob(CBlob@ this, Soldier::Data@ data, const string &in name, const u8 team)
{
	return PlaceBlob(name, getPlacePos(data), this, team);
}

bool DeleteBlob(CBlob@ this, Soldier::Data@ data, const string &in name)
{
	CMap@ map = getMap();
	CBlob@[] blobsInRadius;
	if (map.getBlobsInRadius(getTakePos(data), DELETE_RADIUS, @blobsInRadius))
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob @b = blobsInRadius[i];
			if (b.getName() == name)
			{
				b.Untag("explosive");
				b.server_Die();
				return true;
			}
		}
	}

	return false;
}


CBlob@ PlaceBlob(const string &in name, Vec2f pos, CBlob@ caller, const u8 team, const f32 velMultiplier = 2.5f)
{
	CBlob @blob = PlaceBlobNoInit(name, pos, caller, team, velMultiplier);
	if (blob !is null){
		blob.Init();
	}
	return blob;
}

CBlob@ PlaceBlobNoInit(const string &in name, Vec2f pos, CBlob@ caller, const u8 team, const f32 velMultiplier = 2.5f)
{
	if (!getNet().isServer())
		return null;

	CMap@ map = getMap();
	const bool tileSolid = map.isTileSolid(map.getTile(pos));
	if (tileSolid)
	{
		pos = caller.getPosition();
	}

	CBlob @blob = server_CreateBlobNoInit(name);
	if (blob !is null)
	{
		blob.server_setTeamNum( team );
		blob.setPosition(pos);
		blob.setVelocity(caller.getVelocity()*velMultiplier);
		blob.set_netid("owner", caller.getNetworkID());
		blob.SetDamageOwnerPlayer(caller.getPlayer());
		blob.SetFacingLeft(caller.isFacingLeft());
	}
	return blob;
}