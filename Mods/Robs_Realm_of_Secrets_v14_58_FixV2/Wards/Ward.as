#include "Requirements.as"
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "Hitters.as";
#include "Health.as";
#include "FireParticle.as";

//are builders the only ones that can finish construction?
const bool builder_only = false;

void onInit(CBlob@ this)
{

	this.Tag("builder always hit");
	
	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(2, 2));
	this.set_string("shop description", "Construct");
	this.set_u8("shop icon", 12);
	this.set_u8("shop button radius", 32);
	this.Tag(SHOP_AUTOCLOSE);
	
	AddIconToken("$fireward$", "Runes.png", Vec2f(8, 8), 4);
	AddIconToken("$waterward$", "Runes.png", Vec2f(8, 8), 5);
	AddIconToken("$rockward$", "Runes.png", Vec2f(8, 8), 6);
	AddIconToken("$airward$", "Runes.png", Vec2f(8, 8), 7);
	
	{
		ShopItem@ s = addShopItem(this, "Fire Rune", "$fireward$", "fire", "Carve a fire rune.");
		AddRequirement(s.requirements, "blob", "lantern", "Lantern", 1);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Water Rune", "$waterward$", "water", "Carve a water rune.");
		AddRequirement(s.requirements, "water", "water", "Water", 0);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Earth Rune", "$rockward$", "rock", "Carve an earth rune.");
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 10);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Air Rune", "$airward$", "air", "Carve an air rune.");
		AddRequirement(s.requirements, "air", "air", "Air", 0);
		s.spawnNothing = true;
	}
	
	this.set_s16("type",0);
	this.set_s16("subtype",0);
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if(caller.getCarriedBlob() is this)
		this.set_bool("shop available", true);
	else
		this.set_bool("shop available", false);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	bool isServer = getNet().isServer();
	if (cmd == this.getCommandID("shop made item"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_netid());
		
		u16 item;
		if(!params.saferead_netid(item))return;
		
		string name = params.read_string();
		if (caller !is null)
		{
			if(!this.hasTag("SetType")){
				if(name == "air")this.set_s16("type",0);
				if(name == "rock")this.set_s16("type",1);
				if(name == "water")this.set_s16("type",2);
				if(name == "fire")this.set_s16("type",3);
				this.Tag("SetType");
			} else {
				if(name == "air")this.set_s16("subtype",1);
				if(name == "rock")this.set_s16("subtype",2);
				if(name == "water")this.set_s16("subtype",3);
				if(name == "fire")this.set_s16("subtype",4);
				this.Tag("shop disabled");
			}
			
		}
	}
}

void onTick(CBlob@ this){
	UpdateFrame(this.getSprite());
	
	bool aura = true;
	
	if(this.isInInventory()){
		aura = false;
		if(this.getInventoryBlob() !is null){
			if(this.getInventoryBlob().getName() != "ctf_flag"){
				aura = true;
			}
		}
	}
	
	if(aura)
	if(this.get_s16("subtype") != 0){
		Aura(this,this.get_s16("type"),this.get_s16("subtype")-1);
	}
	
	if(aura)
	if((this.get_s16("type") == 2 && this.get_s16("subtype") == 4) || (this.get_s16("type") == 3 && this.get_s16("subtype") == 3))
	ParticleAnimated(CFileMatcher("SmallSteam").getFirst(), this.getPosition() + Vec2f(XORRandom(6) - 3, XORRandom(16)-8), Vec2f(0,-0.01), float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
	
	if(!this.hasTag("lightchecked")){
		if(this.get_s16("type") == 3 || this.get_s16("subtype") == 4){
			this.SetLight(true);
			this.SetLightRadius(64.0f);
			this.SetLightColor(SColor(255, 255, 220, 151));
			this.Tag("lightchecked");
		}
	}
	
	this.set_s16("timer",this.get_s16("timer")+1);
	if(this.get_s16("timer") > 30)this.set_s16("timer",0);
}

void UpdateFrame(CSprite@ this)
{
	// set the frame according to the material quantity

	if(this.getBlob().get_s16("type") == 0)this.SetAnimation("air");
	if(this.getBlob().get_s16("type") == 1)this.SetAnimation("rock");
	if(this.getBlob().get_s16("type") == 2)this.SetAnimation("water");
	if(this.getBlob().get_s16("type") == 3)this.SetAnimation("fire");
	
	if(!this.getBlob().hasTag("SetType"))this.SetAnimation("default");
	
	Animation@ air = this.getAnimation("air");
	if (air !is null)air.SetFrameIndex(this.getBlob().get_s16("subtype"));
	
	Animation@ rock = this.getAnimation("rock");
	if (rock !is null)rock.SetFrameIndex(this.getBlob().get_s16("subtype"));
	
	Animation@ water = this.getAnimation("water");
	if (water !is null)water.SetFrameIndex(this.getBlob().get_s16("subtype"));
	
	Animation@ fire = this.getAnimation("fire");
	if (fire !is null)fire.SetFrameIndex(this.getBlob().get_s16("subtype"));
	
	if(!this.getBlob().hasTag("SetType"))this.getBlob().inventoryIconFrame = 20;
	else this.getBlob().inventoryIconFrame = this.getBlob().get_s16("type")*5+this.getBlob().get_s16("subtype");
}

void Aura(CBlob@ this, int type, int subtype){

	bool air = (type == 0 || subtype == 0);
	bool rock = (type == 1 || subtype == 1);
	bool water = (type == 2 || subtype == 2);
	bool fire = (type == 3 || subtype == 3);

	int power = 1;
	if(this.isInInventory() || this.isAttached())power += 1;

	CBlob@[] blobsInRadius;	   
	if (this.getMap().getBlobsInRadius(this.getPosition(), 24.0f, @blobsInRadius)) 
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];
			if(b.getName() == "ward"){
				power += 1;
			}
		}
	}
	
	if(water && fire){
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), 40.0f, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(b.hasTag("player") && !b.hasTag("dead"))if(b.getTeamNum() != this.getTeamNum())
				{
					b.set_s16("weakend",60);
				}
			}
		}
	} else
	if(water && rock){
		CBlob@[] blobsInRadius;	   
		if(!this.isInInventory())
		if (this.getMap().getBlobsInRadius(this.getPosition(), 64.0f-power*8, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(b.getName() != "ward" && b.getName() != "log" && b.getName() != "stone_door" && b.getName() != "trap_block")
				{
					if(b.hasTag("status_effects"))b.set_s16("se_invincible",60);
					else {
						if(b.get_u32("wardstatistime") >= getGameTime()-5){
							if(b.get_f32("wardstatis") > b.getHealth()){
								b.server_SetHealth(b.get_f32("wardstatis"));
							}
						}
						b.set_u32("wardstatistime",getGameTime());
						b.set_f32("wardstatis",b.getHealth());
					}
				}
			}
		}
	} else
	if(water && air){
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), 40.0f-power*8, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(b.hasTag("player") && !b.hasTag("dead"))if(b.getTeamNum() == this.getTeamNum())
				{
					b.set_s8("air_count", 100);
				}
			}
		}
	} else
	if(water){
		if(getNet().isServer() && this.get_s16("timer") == 0){
			CBlob@[] blobsInRadius;	   
			if (this.getMap().getBlobsInRadius(this.getPosition(), 40.0f, @blobsInRadius)) 
			{
				for (uint i = 0; i < blobsInRadius.length; i++)
				{
					CBlob@ b = blobsInRadius[i];
					if(b.hasTag("flesh") && !b.hasTag("dead"))
					{
						if(XORRandom(power) == 0)Heal(b,0.25);
					}
				}
			}
		}
	}
	
	if(!water && this.get_s16("timer") == 0){

		if(fire && !air && !rock){
			if(getNet().isServer()){
				CBlob@[] blobsInRadius;	   
				if (this.getMap().getBlobsInRadius(this.getPosition(), 16.0f, @blobsInRadius)) 
				{
					for (uint i = 0; i < blobsInRadius.length; i++)
					{
						CBlob@ b = blobsInRadius[i];
						if(b.hasTag("player"))if(b.getTeamNum() != this.getTeamNum())
						{
							if(XORRandom(power) == 0){
								this.server_Hit(b, b.getPosition(), Vec2f(), 1.0f, Hitters::fire);
								this.server_Hit(this, b.getPosition(), Vec2f(), 0.5f, Hitters::fire);
							}
						}
					}
				}
			}
		}
		
		if(fire && rock){
			if(getNet().isServer()){
				CBlob@[] blobsInRadius;	   
				if (this.getMap().getBlobsInRadius(this.getPosition(), 48.0f, @blobsInRadius)) 
				{
					for (uint i = 0; i < blobsInRadius.length; i++)
					{
						CBlob@ b = blobsInRadius[i];
						if(b.hasTag("player") && !b.hasTag("dead") && b.hasTag("flesh"))if(b.getTeamNum() != this.getTeamNum())
						{
							if(XORRandom(power) == 0){
								CBlob @blob = server_CreateBlob("fireball", this.getTeamNum(), this.getPosition());
								if (blob !is null)
								{
									Vec2f shootVel = b.getPosition()-this.getPosition();
									shootVel.Normalize();
									blob.setVelocity(shootVel*8);
								}
							}
						}
					}
				}
			}
		}

	}
	
	if(!water && !fire && this.get_s16("timer") == 0){
	
		if(air && rock){
			if(getNet().isServer()){
				CBlob@[] blobsInRadius;	   
				if (this.getMap().getBlobsInRadius(this.getPosition(), 48.0f, @blobsInRadius)) 
				{
					for (uint i = 0; i < blobsInRadius.length; i++)
					{
						CBlob@ b = blobsInRadius[i];
						if(b.hasTag("player") && !b.hasTag("dead") && b.hasTag("flesh"))if(b.getTeamNum() != this.getTeamNum())
						{
							if(XORRandom(power*2) == 0){
								CBlob @blob = server_CreateBlob("rockball", this.getTeamNum(), this.getPosition());
								if (blob !is null)
								{
									Vec2f shootVel = b.getPosition()-this.getPosition();
									shootVel.Normalize();
									blob.setVelocity(shootVel*8);
								}
							}
						}
					}
				}
			}
		}
		
		if(!air && rock){
			if(getNet().isServer()){
				CMap@ map = this.getMap();
				if(map is null)return;
				Vec2f pos = this.getPosition();
				int size = 20;
				for (int x_step = -size; x_step < size; ++x_step)
				{
					for (int y_step = -size; y_step < size; ++y_step)
					if(XORRandom(power) == 0)
					{
						Vec2f off(x_step * map.tilesize, y_step * map.tilesize);
						
						Vec2f tpos = pos + off;
						
						TileType t = map.getTile(tpos).type;
						if(t > 57 && t < 64)
						{
							
							//if(t-1 == 57)
							map.server_SetTile(tpos, CMap::tile_castle);
							//else map.server_SetTile(tpos, t-1);
						}
					}
				}
				CBlob@[] blobsInRadius;	   
				if (this.getMap().getBlobsInRadius(this.getPosition(), 40.0f, @blobsInRadius)) 
				{
					for (uint i = 0; i < blobsInRadius.length; i++)
					{
						CBlob@ b = blobsInRadius[i];
						if(b.hasTag("stone"))
						{
							if(XORRandom(power) == 0)Heal(b,0.25);
						}
					}
				}
			}
		}
	}
	
	
	if(air && !fire && !rock && !water){
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), 24.0f, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if((b.hasTag("flesh") || b.hasTag("plant") || b.hasTag("element") || b.hasTag("ghost") || b.hasTag("player")) && !b.hasTag("dead"))if(b.getTeamNum() != this.getTeamNum() || b.hasTag("element"))
				{
					Vec2f dir = b.getPosition()-this.getPosition();
					dir.Normalize();
					if(!b.hasTag("element"))b.setVelocity(dir*(2.0/power)+b.getVelocity());
					else {
						b.setVelocity(dir*(2.0/power)+b.getVelocity()/2);
						b.set_u8("moldable", 2);
					}
				}
			}
		}
	}
	
	if(air && fire && !rock && !water){
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), 24.0f, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if((b.hasTag("flesh") || b.hasTag("plant") || b.hasTag("element") || b.hasTag("ghost") || b.hasTag("player")) && !b.hasTag("dead"))if(b.getTeamNum() != this.getTeamNum() || b.hasTag("element"))
				{
					Vec2f dir = this.getPosition()-b.getPosition();
					dir.Normalize();
					if(!b.hasTag("element"))b.setVelocity(dir*(3.0/power)+b.getVelocity());
					else {
						b.setVelocity(dir*(3.0/power)+(b.getVelocity()/10*9));
						b.set_u8("moldable", 2);
					}
				}
			}
		}
	}

}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	bool thrown = false;
	CPlayer @p = this.getDamageOwnerPlayer();
	CPlayer @bp = blob.getPlayer();
	if (p !is null && bp !is null && p.getTeamNum() != bp.getTeamNum())
	{
		thrown = true;
	}
	return (blob.getShape().isStatic() || (blob.isInWater() && blob.hasTag("vehicle"))); // boat
}

bool canBePickedUp(CBlob@ this, CBlob@ blob)
{
	return this.getTeamNum() == blob.getTeamNum();
}

void onThisAddToInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	if (inventoryBlob is null) return;

	CInventory@ inv = inventoryBlob.getInventory();

	if (inv is null) return;

	this.doTickScripts = true;
	
	inv.doTickScripts = true;
}