// ArcherShop.as

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "CTFShopCommon.as";

void onInit(CBlob@ this)
{

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	//load config
	if (getRules().exists("ctf_costs_config"))
	{
		cost_config_file = getRules().get_string("ctf_costs_config");
	}

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(2, 2));
	this.set_string("shop description", "Clean Altar");
	this.set_u8("shop icon", 12);
	
	{
		ShopItem@ s = addShopItem(this, "Sacrifice", "$GOLD$", "becomebeing", "Sacrifice yourself for the greater good.", true);
		s.spawnNothing = true;
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 2;
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 1000);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_bool("shop available", this.isOverlapping(caller));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if(cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");

		bool isServer = (getNet().isServer());
		u16 callerint, item;
		if (!params.saferead_netid(callerint) || !params.saferead_netid(item))
		{
			return;
		}
		CBlob @caller = getBlobByNetworkID(callerint);
		CBlob @newBlob = server_CreateBlob("goldenbeing", 8, this.getPosition());
		
		CBlob @Altar = server_CreateBlob("altar", caller.getTeamNum(), this.getPosition());
		if (Altar !is null)Altar.set_string("owner",caller.getPlayer().getUsername());
		
		if (newBlob !is null)
		{
			// plug the soul
			newBlob.server_SetPlayer(caller.getPlayer());
			newBlob.setPosition(caller.getPosition());

			// no extra immunity after class change
			if (caller.exists("spawn immunity time"))
			{
				newBlob.set_u32("spawn immunity time", caller.get_u32("spawn immunity time"));
				newBlob.Sync("spawn immunity time", true);
			}

			if (caller.exists("knocked"))
			{
				newBlob.set_u8("knocked", caller.get_u8("knocked"));
				newBlob.Sync("knocked", true);
			}

			caller.Tag("switch class");
			caller.server_SetPlayer(null);
			caller.server_Die();
		}
		this.server_Die();
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

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1){
	if (blob is null)
	{
		return;
	}
	if(blob.getName() == "goldenbeing"){
		CBlob @Altar = server_CreateBlob("altar", this.getTeamNum(), this.getPosition());
		if (Altar !is null){
			CPlayer@ p = blob.getPlayer();
			if (p !is null)Altar.set_string("owner",p.getUsername());
		}
		this.server_Die();
	}
}