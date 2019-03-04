#include "TradingCommon.as";
#include "Descriptions.as"
#include "GameplayEvents.as"

#define SERVER_ONLY

int coinsOnDamageAdd = 0;
int coinsOnKillAdd = 0;
int coinsOnDeathLose = 0;
int min_coins = 0;

const int coinsOnDeathLosePercent = 100;
const int coinsOnTKLose = 0;

const int coinsOnRestartAdd = 0;
const bool keepCoinsOnRestart = false;

const int coinsOnHitSiege = 0;
const int coinsOnKillSiege = 0;

const int coinsOnCapFlag = 0;

const int coinsOnBuild = 0;
const int coinsOnBuildWood = 0;
const int coinsOnBuildWorkshop = 0;

const int warmupFactor = 0;

//
string cost_config_file = "tdm_vars.cfg";
bool kill_traders_and_shops = false;

void onBlobCreated(CRules@ this, CBlob@ blob)
{
	if (blob.getName() == "tradingpost")
	{
		if (kill_traders_and_shops)
		{
			blob.server_Die();
			KillTradingPosts();
		}
		else
		{
			MakeTradeMenu(blob);
		}
	}
}

TradeItem@ addItemForCoin(CBlob@ this, const string &in name, int cost, const bool instantShipping, const string &in iconName, const string &in configFilename, const string &in description)
{
	TradeItem@ item = addTradeItem(this, name, 0, instantShipping, iconName, configFilename, description);
	if (item !is null && cost > 0)
	{
		AddRequirement(item.reqs, "coin", "", "Coins", cost);
		item.buyIntoInventory = true;
	}
	return item;
}

TradeItem@ addItemForGold(CBlob@ this, const string &in name, int cost, const bool instantShipping, const string &in iconName, const string &in configFilename, const string &in description)
{
	TradeItem@ item = addTradeItem(this, name, 0, instantShipping, iconName, configFilename, description);
	if (item !is null && cost > 0)
	{
		AddRequirement(item.reqs, "blob", "mat_gold", "Gold", cost);
		item.buyIntoInventory = true;
	}
	return item;
}

void MakeTradeMenu(CBlob@ trader)
{
	//load config

	s32 menu_width = 3;
	s32 menu_height = 5;

	// build menu
	CreateTradeMenu(trader, Vec2f(menu_width, menu_height), "Buy goods");

	//
	addTradeSeparatorItem(trader, "$MENU_GENERIC$", Vec2f(3, 1));

	addItemForGold(trader, "Bomb", 30, true, "$mat_bombs$", "mat_bombs", descriptions[1]);
	addItemForGold(trader, "Working Mine", 20, true, "$mine$", "faultymine", "A completely unsafe and working mine.");
	addItemForGold(trader, "Arrows", 5, true, "$mat_arrows$", "mat_arrows", descriptions[2]);

	addItemForGold(trader, "Drill", 100, true, "$drill$", "drill", descriptions[43]);
	addItemForGold(trader, "Bucket", 5, true, "$bucket$", "bucket", "A bucket for storing water.");
	addItemForGold(trader, "Lantern", 5, true, "$lantern$", "lantern", "A lantern for lighting up the dark");
	
	addItemForGold(trader, "Wood", 50, true, "$mat_wood$", "mat_wood", "Woody timber.");
	addItemForGold(trader, "Stone", 100, true, "$mat_stone$", "mat_stone", "Rocky stone.");
	
	AddIconToken("$bread$", "Bread.png", Vec2f(16, 16), 0);
	AddIconToken("$egg$", "Egg.png", Vec2f(8, 8), 0);
	
	addItemForGold(trader, "Bread", 50, true, "$bread$", "bread", "In case you get a little peckish.");
	addItemForGold(trader, "Egg", 100, true, "$egg$", "egg", "Who came first, the griffors or the aboosers?");

}

// load coins amount

void Reset(CRules@ this)
{
	//load the coins vars now, good a time as any
	if (this.exists("tdm_costs_config"))
		cost_config_file = this.get_string("tdm_costs_config");

	ConfigFile cfg = ConfigFile();
	cfg.loadFile(cost_config_file);

	coinsOnDamageAdd = cfg.read_s32("coinsOnDamageAdd", coinsOnDamageAdd);
	coinsOnKillAdd = cfg.read_s32("coinsOnKillAdd", coinsOnKillAdd);
	coinsOnDeathLose = cfg.read_s32("coinsOnDeathLose", coinsOnDeathLose);
	min_coins = cfg.read_s32("minCoinsOnRestart", min_coins);

	kill_traders_and_shops = !(cfg.read_bool("spawn_traders_ever", true));

	if (kill_traders_and_shops)
	{
		KillTradingPosts();
	}

}

void onRestart(CRules@ this)
{
	Reset(this);
}

void onInit(CRules@ this)
{
	Reset(this);
}


void KillTradingPosts()
{
	CBlob@[] tradingposts;
	bool found = false;
	if (getBlobsByName("tradingpost", @tradingposts))
	{
		for (uint i = 0; i < tradingposts.length; i++)
		{
			CBlob @b = tradingposts[i];
			b.server_Die();
		}
	}
}