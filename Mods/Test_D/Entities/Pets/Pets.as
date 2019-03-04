#include "ParachuteCommon.as"

enum PetType
{
	FERN = 0,
	CACTUS,
	CHICKEN,
	DOG,
	CAT,
	CROC,
	BUNNY,
	PARROT
};

int[] _petCosts =
{
	3,
	3,
	8,
	40,
	40,
	100, //maximum coins for now is 200, so you have to save everything for this
	15,
	40
};

u32 getPetCost(int index)
{
	if (index < _petCosts.length)
	{
		return _petCosts[index];
	}
	return 0;
}

enum ToyType
{
	TOY_FRISBEE = 0,
	TOY_WOOLBALL,
	TOY_MASCOT,
	TOY_HAMBURGER,
	TOY_NEST,
	TOY_CARROT,
	TOY_FERTILIZER

};

int[] _toyCosts =
{
	3,
	3,
	3,
	2,
	2,
	1,
	1
};

u32 getToyCost(int index)
{
	if (index < _toyCosts.length)
	{
		return _toyCosts[index];
	}
	return 0;
}

void SpawnPet(CBlob@ owner, u32 type, Vec2f pos, bool parachute)
{
	//only server sends any more cmds
	if (!getNet().isServer() || owner is null) return;

	string blobName = type == CROC ? "croc" : "pet";

	CBlob @cuteLittlePet = server_CreateBlobNoInit(blobName);
	if (cuteLittlePet !is null)
	{
		cuteLittlePet.set_u8("type", type);
		cuteLittlePet.server_setTeamNum(owner.getTeamNum());
		cuteLittlePet.set_netid("owner", owner.getNetworkID());
		cuteLittlePet.setPosition(pos);
		cuteLittlePet.Init();

		// after init
		if (parachute)
		{
			Random _petrandom(Time());

			f32 offsetrange = 20;
			f32 halfoffsetrange = offsetrange / 2;

			//randomly offset left or right and parachute in
			f32 offset = _petrandom.NextRanged(offsetrange);
			if (offset < halfoffsetrange)
				offset += halfoffsetrange;
			else
				offset = -halfoffsetrange - (offset - halfoffsetrange);

			cuteLittlePet.setPosition(Vec2f(pos.x + offset, 0));

			AddParachute(cuteLittlePet);
		}
		else
		{
			owner.server_AttachTo(cuteLittlePet, 0);
		}
	}
}

CBlob@ findPet(CBlob@ owner)
{
	CBlob@[] pets;
	getBlobsByName( "pet", @pets );
	getBlobsByName( "croc", @pets );

	for(u32 i = 0; i < pets.length; i++)
	{
		if(pets[i].get_netid("owner") == owner.getNetworkID())
		{
			return pets[i];
		}
	}

	return null;
}

bool hasPet(CBlob@ owner)
{
	return findPet(owner) !is null;
}

u8 getPetType(CBlob@ this)
{
	return this.get_u8("type");
}

u8 getToyType(CBlob@ this)
{
	return this.get_u8("type");
}

CBlob@ getPetOwner( CBlob@ this )
{
	return getBlobByNetworkID(this.get_netid("owner"));	
}

bool PlayPetSound(CBlob@ this, const string &in name)
{
	if (getGameTime() - this.get_u32("last sound time") > 150)
	{
		this.getSprite().PlaySound(this.get_string(name));
		this.set_u32("last sound time", getGameTime());
		return true;
	}
	return false;
}

void SpawnToy(CBlob@ owner, u32 type, Vec2f pos)
{
	//only server sends any more cmds
	if (!getNet().isServer() || owner is null) return;

	string blobName = "toy";

	CBlob @toy = server_CreateBlobNoInit(blobName);
	if (toy !is null)
	{
		toy.set_u8("type", type);
		toy.server_setTeamNum(owner.getTeamNum());
		toy.set_netid("owner", owner.getNetworkID());
		toy.setPosition(pos);
		toy.Init();

		if (owner !is null){
			owner.server_AttachTo(toy, 0);
		}
	}
}