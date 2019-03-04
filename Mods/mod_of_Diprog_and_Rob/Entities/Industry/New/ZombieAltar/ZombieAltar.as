// Vehicle Workshop

#include "Requirements.as"
#include "Requirements_Tech.as"
#include "ShopCommon.as";
#include "Descriptions.as";
#include "WARCosts.as";
#include "CheckSpam.as";

const s32 cost_catapult = 80;
const s32 cost_ballista = 150;
const s32 cost_ballista_ammo = 30;
const s32 cost_longboat = 75;
const s32 cost_warboat = 130;

const s32 cost_ballista_ammo_upgrade_gold = 60;

void onInit( CBlob@ this )
{	 
	this.set_TileType("background tile", CMap::tile_wood_back);
	//this.getSprite().getConsts().accurateLighting = true;
	

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;
	
	AddIconToken( "$Zombie$", "ZombieAltarIcons.png", Vec2f(15,15), 0 );
	AddIconToken( "$Skeleton$", "ZombieAltarIcons.png", Vec2f(15,15), 1 );
	AddIconToken( "$knight$", "ZombieAltarIcons.png", Vec2f(15,15), 2 );
	AddIconToken( "$archer$", "ZombieAltarIcons.png", Vec2f(15,15), 3 );
	
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(1,2));	
	this.set_string("shop description", "Construct");
	this.set_u8("shop icon", 12);
	
	this.set_Vec2f("class offset", Vec2f(-6, 0));
	this.set_string("required class", "ghoul");
	
	{
		ShopItem@ s = addShopItem( this, "Zombie", "$Zombie$", "summonZombie", "Summon your own zombie. Can be picked up.", false);
		AddRequirement( s.requirements, "coin", "", "Coins", 40 );
		AddRequirement( s.requirements, "blob", "knight", "Dead Knight", 1 );
	}
	{
		ShopItem@ s = addShopItem( this, "Skeleton", "$Skeleton$", "summonSkeleton", "Summon your own skeleton. Can be picked up.", false);
		AddRequirement( s.requirements, "coin", "", "Coins", 20 );
		AddRequirement( s.requirements, "blob", "archer", "Dead Archer", 1 );
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if(caller.getConfig() == this.get_string("required class"))
	{
		this.set_Vec2f("shop offset", Vec2f_zero);
	}
	else
	{
		this.set_Vec2f("shop offset", Vec2f(6, 0));
	}
	this.set_bool("shop available", this.isOverlapping(caller));
}
								   
void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound( "/ChaChing.ogg" );
		
		bool isServer = (getNet().isServer());
			
		u16 caller, item;
		
		if(!params.saferead_netid(caller) || !params.saferead_netid(item))
			return;
		
		CBlob@ blob = getBlobByNetworkID( caller );
		CBlob@ zombie;
		CBlob@ corpse;
		
		string name = params.read_string();
		
		{
			if(name == "summonZombie")
			{
				if (isServer)
				{
					if (blob !is null)  
					{
						@corpse = server_CreateBlob( "knight", blob.getTeamNum(), this.getPosition()); 
						@zombie = server_CreateBlob( "zombie", blob.getTeamNum(), this.getPosition());
					}
				}
				if (corpse !is null) 
				{
					corpse.getSprite().Gib();
					corpse.server_Die();
				}
				if (zombie !is null) ParticleZombieLightning(zombie.getPosition());				
			}
			
			if(name == "summonSkeleton")
			{
				if (isServer)
				{
					if (blob !is null)  
					{
						@corpse = server_CreateBlob( "archer", blob.getTeamNum(), this.getPosition()); 
						@zombie = server_CreateBlob( "skeleton", blob.getTeamNum(), this.getPosition());
					}
				}
				if (corpse !is null) 
				{
					corpse.getSprite().Gib();
					corpse.server_Die();
				}
				if (zombie !is null) ParticleZombieLightning(zombie.getPosition());
			}
		}
	}
}
