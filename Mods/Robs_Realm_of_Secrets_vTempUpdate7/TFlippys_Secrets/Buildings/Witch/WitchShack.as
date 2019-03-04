// ArcherShop.as

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "CTFShopCommon.as";
#include "MakeMat.as";

Random traderRandom(Time());

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	getMap().server_SetTile(this.getPosition(), CMap::tile_wood_back);

	AddIconToken("$landfishicon$", "Landfish.png", Vec2f(16, 16), 0);
	
	// SHOP
	this.set_Vec2f("shop offset", Vec2f(2,0));
	this.set_Vec2f("shop menu size", Vec2f(2, 3));
	this.set_string("shop description", "Witch Shack");
	this.set_u8("shop icon", 25);
	
	{
		ShopItem@ s = addShopItem(this, "Sell Wisp(60)", "$COIN$", "gold-200+cage", "M're fuel f'r mine pot!", true);
		AddRequirement(s.requirements, "blob", "caged_wisp", "Caged Wisp", 1);
		s.spawnNothing = true;
	}
	
	{
		ShopItem@ s = addShopItem(this, "Sell Slime(40)", "$COIN$", "gold-40+cage", "Ooze f'r brew thicken'ring!", true);
		AddRequirement(s.requirements, "blob", "caged_slime", "Caged Slime", 1);
		s.spawnNothing = true;
	}
	
	{
		ShopItem@ s = addShopItem(this, "Sell Chicken(30)", "$COIN$", "gold-20+cage", "Chicken talons art useful f'r scratching!", true);
		AddRequirement(s.requirements, "blob", "caged_chicken", "Caged Chicken", 1);
		s.spawnNothing = true;
	}
	
	{
		ShopItem@ s = addShopItem(this, "Sell Fishy(20)", "$COIN$", "gold-10", "Fishy!", true);
		AddRequirement(s.requirements, "blob", "fishy", "Fish", 1);
		s.spawnNothing = true;
	}
	
	{
		ShopItem@ s = addShopItem(this, "Wooden Cage", "$cage$", "cage", "Goeth fetcheth me some critt'rs!", true);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 10);
	}
	
	{
		ShopItem@ s = addShopItem(this, "Landfish", "$landfishicon$", "landfish+cage", "I'll enchant them altogeth'r.", true);
		AddRequirement(s.requirements, "blob", "caged_chicken", "Caged Chicken", 1);
		AddRequirement(s.requirements, "blob", "fishy", "Fish", 1);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 200);
		s.spawnNothing = true;
	}
	
	CSprite@ sprite = this.getSprite();

	if (sprite !is null)
	{
		string sex = "Witch.png";
		CSpriteLayer@ trader = sprite.addSpriteLayer("trader", sex, 16, 24, 0, 0);
		trader.SetRelativeZ(20);
		Animation@ stop = trader.addAnimation("stop", 1, false);
		stop.AddFrame(0);
		Animation@ walk = trader.addAnimation("walk", 1, false);
		walk.AddFrame(0); walk.AddFrame(1); walk.AddFrame(2); walk.AddFrame(3);
		walk.time = 10;
		walk.loop = true;
		trader.SetOffset(Vec2f(0, 0));
		trader.SetFrame(0);
		trader.SetAnimation(stop);
		trader.SetIgnoreParentFacing(true);
		this.set_bool("trader moving", false);
		this.set_bool("moving left", false);
		this.set_u32("move timer", getGameTime() + (traderRandom.NextRanged(5) + 5)*getTicksASecond());
		this.set_u32("next offset", traderRandom.NextRanged(16));

	}
}

void onTick(CSprite@ this)
{
	//TODO: empty? show it.
	CBlob@ blob = this.getBlob();
	CSpriteLayer@ trader = this.getSpriteLayer("trader");
	bool trader_moving = blob.get_bool("trader moving");
	bool moving_left = blob.get_bool("moving left");
	u32 move_timer = blob.get_u32("move timer");
	u32 next_offset = blob.get_u32("next offset");
	if (!trader_moving)
	{
		if (move_timer <= getGameTime())
		{
			blob.set_bool("trader moving", true);
			trader.SetAnimation("walk");
			trader.SetFacingLeft(!moving_left);
			Vec2f offset = trader.getOffset();
			offset.x *= -1.0f;
			trader.SetOffset(offset);

		}

	}
	else
	{
		//had to do some weird shit here because offset is based on facing
		Vec2f offset = trader.getOffset();
		if (moving_left && offset.x > -next_offset)
		{
			offset.x -= 0.5f;
			trader.SetOffset(offset);

		}
		else if (moving_left && offset.x <= -next_offset)
		{
			blob.set_bool("trader moving", false);
			blob.set_bool("moving left", false);
			blob.set_u32("move timer", getGameTime() + (traderRandom.NextRanged(5) + 5)*getTicksASecond());
			blob.set_u32("next offset", traderRandom.NextRanged(16));
			trader.SetAnimation("stop");

		}
		else if (!moving_left && offset.x > -next_offset)
		{
			offset.x -= 0.5f;
			trader.SetOffset(offset);

		}
		else if (!moving_left && offset.x <= -next_offset)
		{
			blob.set_bool("trader moving", false);
			blob.set_bool("moving left", true);
			blob.set_u32("move timer", getGameTime() + (traderRandom.NextRanged(5) + 5)*getTicksASecond());
			blob.set_u32("next offset", traderRandom.NextRanged(16));
			trader.SetAnimation("stop");

		}

	}

}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{

	this.set_Vec2f("shop offset", Vec2f(2,0));

	this.set_bool("shop available", this.isOverlapping(caller));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if(cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");
		
		u16 caller, item;
		
		if(!params.saferead_netid(caller) || !params.saferead_netid(item))
			return;
		
		string name = params.read_string();
		{
		    if(name.findFirst("coins-") != -1)
			{
			    CBlob@ callerBlob = getBlobByNetworkID(caller);
				
				if (getNet().isServer() && callerBlob !is null)
				{
			        CPlayer@ callerPlayer = callerBlob.getPlayer();
					
					if(callerPlayer !is null)
					{
						callerPlayer.server_setCoins( callerPlayer.getCoins() + parseInt(name.split("-")[1]));
					}
				}
			}
			
			 if(name.findFirst("landfish") != -1)
			{
			    CBlob@ callerBlob = getBlobByNetworkID(caller);
				
				if (getNet().isServer() && callerBlob !is null)
				{
					CBlob@ blob = server_CreateBlob("landfish", callerBlob.getTeamNum(), this.getPosition() + Vec2f(0, 8));
				}
				
				if (getNet().isClient())
				{
					this.getSprite().PlaySound("MagicWand", 1.00f, 0.90f);
				}
			}
			
			if(name.findLast("+cage") != -1)
			{
				CBlob@ callerBlob = getBlobByNetworkID(caller);
				
				if (getNet().isServer() && callerBlob !is null)
				{
			        CPlayer@ callerPlayer = callerBlob.getPlayer();
					
					if(callerPlayer !is null)
					{
						CBlob@ blob = server_CreateBlob("cage", callerBlob.getTeamNum(), this.getPosition() + Vec2f(0, 8));
					   
						if (!blob.canBePutInInventory(callerBlob))
						{
							callerBlob.server_Pickup(blob);
						}
						else if (!callerBlob.getInventory().isFull())
						{
							callerBlob.server_PutInInventory(blob);
						}
					}
				}
			}
			
			if(name.findFirst("gold-") != -1)
			{
			    CBlob@ callerBlob = getBlobByNetworkID(caller);
				
				if (getNet().isServer() && callerBlob !is null)
				{
			        CPlayer@ callerPlayer = callerBlob.getPlayer();
					
					if(callerPlayer !is null)
					MakeMat(this, callerBlob.getPosition(), "mat_gold", parseInt(name.split("-")[1]));
				}
			}
		}
	}
}

void onHealthChange(CBlob@ this, f32 oldHealth)
{
	CSprite@ sprite = this.getSprite();
	if (sprite !is null)
	{
		Animation@ destruction = sprite.getAnimation("destruction");
		if (destruction !is null)
		{
			f32 frame = Maths::Floor((this.getInitialHealth() - this.getHealth()) / (this.getInitialHealth() / sprite.animation.getFramesCount()));
			sprite.animation.frame = frame;
		}
	}
}