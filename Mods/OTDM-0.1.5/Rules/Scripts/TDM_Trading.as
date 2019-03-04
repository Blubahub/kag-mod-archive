#include "TradingCommon.as";
#include "Descriptions.as"

#define SERVER_ONLY

int coinsOnDamageAdd = 2;
int coinsOnKillAdd = 10;
int coinsOnDeathLose = 10;
int min_coins = 50;

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

void MakeTradeMenu(CBlob@ trader)
{
	//load config

	if (getRules().exists("tdm_costs_config"))
		cost_config_file = getRules().get_string("tdm_costs_config");

	ConfigFile cfg = ConfigFile();
	cfg.loadFile(cost_config_file);

	s32 cost_bombs = cfg.read_s32("cost_bombs", 20);
	s32 cost_waterbombs = cfg.read_s32("cost_waterbombs", 40);
	s32 cost_keg = cfg.read_s32("cost_keg", 80);
	s32 cost_mine = cfg.read_s32("cost_mine", 50);

	s32 cost_arrows = cfg.read_s32("cost_arrows", 10);
	s32 cost_waterarrows = cfg.read_s32("cost_waterarrows", 40);
	s32 cost_firearrows = cfg.read_s32("cost_firearrows", 30);
	s32 cost_bombarrows = cfg.read_s32("cost_bombarrows", 50);

	s32 cost_mountedbow = cfg.read_s32("cost_mountedbow", 100);
	s32 cost_drill = cfg.read_s32("cost_drill", 0);
	s32 cost_boulder = cfg.read_s32("cost_boulder", 50);
	s32 cost_burger = cfg.read_s32("cost_burger", 40);

	s32 cost_catapult = cfg.read_s32("cost_catapult", -1);
	s32 cost_ballista = cfg.read_s32("cost_ballista", -1);

	s32 menu_width = cfg.read_s32("trade_menu_width", 3);
	s32 menu_height = cfg.read_s32("trade_menu_height", 5);

	// build menu
	CreateTradeMenu(trader, Vec2f(10, 10), "Buy weapons");

	//
	addTradeSeparatorItem(trader, "$MENU_GENERIC$", Vec2f(3, 1));

   	AddIconToken("$ak$", "AK.png", Vec2f(32, 32), 0);
   	AddIconToken("$pg$", "PortalGun.png", Vec2f(32, 32), 0);
   	AddIconToken("$airstrike$", "Airstrike.png", Vec2f(32, 32), 0);
   	AddIconToken("$detonator$", "Detonator.png", Vec2f(16, 16), 0);
   	AddIconToken("$bumper$", "Bumper.png", Vec2f(32, 32), 0);
   	AddIconToken("$jetpack$", "JumpPack.png", Vec2f(32, 32), 0);
   	AddIconToken("$rl$", "RocketLauncher.png", Vec2f(32, 32), 0);
   	AddIconToken("$plane$", "Plane.png", Vec2f(32, 32), 0);
   	AddIconToken("$revolver$", "Revolver.png", Vec2f(32, 32), 0);
   	AddIconToken("$mg$", "Minigun.png", Vec2f(32, 32), 0);
   	AddIconToken("$rifle$", "Rifle.png", Vec2f(32, 32), 0);
   	AddIconToken("$healer$", "Rifle.png", Vec2f(16, 16), 0);

	if (cost_bombs > 0)
		addItemForCoin(trader, "Bomb", cost_bombs, true, "$mat_bombs$", "mat_bombs", descriptions[1]);
		addItemForCoin(trader, "Assault Rifle", 70, true, "$ak$", "ak", "Assault rifle\n100 ammo");
		addItemForCoin(trader, "Revolver", 15, true, "$revolver$", "revolver", "Revolver\nSingle firing, 6 shots per clip\n 42 ammo");
		addItemForCoin(trader, "Portal Gun", 50, true, "$pg$", "pg", "Shoots two portals");
		addItemForCoin(trader, "Airstrike", 150, true, "$airstrike$", "airstrike", "Airstrike\nSpace to use at mouse position\nNeeds open sky");
		addItemForCoin(trader, "Detonator", 10, true, "$detonator$", "detonator", "Detonator\nSpace to use\n Detonates all friendly mines");
		addItemForCoin(trader, "Jetpack", 50, true, "$jetpack$", "jp", "Jump Pack\nSpace to use near ground (buggy)");
		addItemForCoin(trader, "Bumper", 30, true, "$bumper$", "bumper", "Bumper");
		addItemForCoin(trader, "Plane", 200, true, "$plane$", "plane", "Plane");
		addItemForCoin(trader, "Rocket Launcher", 140, true, "$rl$", "rl", "Rocket Launcher\n One use");
		addItemForCoin(trader, "Minigun", 140, true, "$mg$", "mg", "Minigun\n 150 ammo");
		addItemForCoin(trader, "Rifle", 70, true, "$rifle$", "rifle", "Rifle\n Single firing\nKnockback\n50 ammo)");
		addItemForCoin(trader, "Burger", 700, true, "$food$", "food", "");
		addItemForCoin(trader, "Healer", 700, true, "$healer$", "healer", "Healer");

	if (cost_keg > 0)
		addItemForCoin(trader, "Keg", cost_keg, true, "$keg$", "keg", descriptions[19]);

	if (cost_mine > 0)
		addItemForCoin(trader, "Mine", 20, true, "$mine$", "mine", descriptions[20]);


	if (cost_mountedbow > 0)
		addItemForCoin(trader, "Mounted Bow", cost_mountedbow, true, "$mounted_bow$", "mounted_bow", descriptions[31]);


	if (cost_boulder > 0)
		addItemForCoin(trader, "Boulder", cost_boulder, true, "$boulder$", "boulder", descriptions[17]);

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

	//at least 50 coins to play with each round
	for (int i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		if (player is null) continue;

		player.server_setCoins(Maths::Max(player.getCoins(), min_coins));
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

// give coins for killing

void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ killer, u8 customData)
{
	if (victim !is null)
	{
		if (killer !is null)
		{
			if (killer !is victim && killer.getTeamNum() != victim.getTeamNum())
			{
				killer.server_setCoins(killer.getCoins() + coinsOnKillAdd);
			}
		}

		victim.server_setCoins(victim.getCoins() - coinsOnDeathLose);
	}
}

// give coins for damage

f32 onPlayerTakeDamage(CRules@ this, CPlayer@ victim, CPlayer@ attacker, f32 DamageScale)
{
	if (attacker !is null && attacker !is victim)
	{
		attacker.server_setCoins(attacker.getCoins() + DamageScale * coinsOnDamageAdd / this.attackdamage_modifier);
	}

	return DamageScale;
}
