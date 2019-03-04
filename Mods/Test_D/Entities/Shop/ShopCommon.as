#include "Skins.as"
#include "Pets.as"
#include "Leaderboard.as"
#include "GameColours.as"

const string SHOP_MENU = "shop menu";
string _score_spritesheet = "Sprites/UI/hud_scores.png";
const int SAY_TIME = 180;
const int LEADERBOARD_TIME = 180;

enum ShopType
{
	BAR = 0,
	BAR_VIP = 1,
	SKIN_SHOP = 2,
	PET_SHOP = 3,
	COFFEE_SHOP = 4
};

enum BuyCommands
{
	BUYTYPE_BEER = 0,
	BUYTYPE_WINE = 1,
	BUYTYPE_CIG = 2,
	BUYTYPE_COFFEE = 3,

	BUYTYPE_PET = 4,

	BUYTYPE_TOY = 20,

	BUYTYPE_COSTUME = 40
};

u8 getShopType(CBlob@ this){
	return this.get_u8("shop type");
}

s32 getPrice(CBlob@ this, u8 type)
{
	if (type <= BUYTYPE_COFFEE)
	{
		const bool vip = getShopType(this) == BAR_VIP;
		return vip ? 2 : 1; // its how it works irl
	}
	else if (type >= BUYTYPE_PET && type < BUYTYPE_TOY)
	{
		return getPetCost(type - BUYTYPE_PET);
	}
	else if (type >= BUYTYPE_TOY && type < BUYTYPE_COSTUME)
	{
		return getToyCost(type - BUYTYPE_TOY);
	}
	else if (type >= BUYTYPE_COSTUME)
	{
		return getSkinCost(type - BUYTYPE_COSTUME);
	}
	return 0;
}
