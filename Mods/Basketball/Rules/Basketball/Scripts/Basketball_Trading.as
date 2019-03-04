//not server only so the client also gets the game event setup stuff
#include "TradingCommon.as"
#include "GameplayEvents.as"
#include "Descriptions.as"
#include "Modname.as"
#include "Logging.as"

const int coinsOnDamageAdd = 5;
const int coinsOnKillAdd = 10;

const int coinsOnDeathLosePercent = 20;
const int coinsOnTKLose = 50;

const int coinsOnRestartAdd = 0;
const bool keepCoinsOnRestart = false;

const int coinsOnHitSiege = 5;
const int coinsOnKillSiege = 20;

const int coinsOnCapFlag = 100;

const int coinsOnBuild = 4;
const int coinsOnBuildWood = 1;
const int coinsOnBuildWorkshop = 10;

const int coinsOnScorePoint = 50; // 100 for regular basket

const int warmupFactor = 3;

string cost_config_file = "../Mods/" + getModname() + "/Rules/Basketball/basketball_vars.cfg";

void onBlobCreated(CRules@ this, CBlob@ blob) {
    if (blob.getName() == "tradingpost") {
        MakeTradeMenu(blob);
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

	s32 cost_boulder = cfg.read_s32("cost_boulder", 50);
	s32 cost_burger = cfg.read_s32("cost_burger", 40);
	s32 cost_sponge = cfg.read_s32("cost_sponge", 20);

	s32 cost_mountedbow = cfg.read_s32("cost_mountedbow", -1);
	s32 cost_drill = cfg.read_s32("cost_drill", -1);
	s32 cost_catapult = cfg.read_s32("cost_catapult", -1);
	s32 cost_ballista = cfg.read_s32("cost_ballista", -1);

    s32 cost_trampoline = cfg.read_s32("cost_trampoline", -1);

	s32 menu_width = cfg.read_s32("trade_menu_width", 3);
	s32 menu_height = cfg.read_s32("trade_menu_height", 5);

	// build menu
	CreateTradeMenu(trader, Vec2f(menu_width, menu_height), "Buy weapons");

	//
	addTradeSeparatorItem(trader, "$MENU_GENERIC$", Vec2f(3, 1));

	if (cost_bombs > 0)
		addItemForCoin(trader, "Bomb", cost_bombs, true, "$mat_bombs$", "mat_bombs", descriptions[1]);

	if (cost_waterbombs > 0)
		addItemForCoin(trader, "Water Bomb", cost_waterbombs, true, "$mat_waterbombs$", "mat_waterbombs", descriptions[52]);

	if (cost_keg > 0)
		addItemForCoin(trader, "Keg", cost_keg, true, "$keg$", "keg", descriptions[4]);

	if (cost_mine > 0)
		addItemForCoin(trader, "Mine", cost_mine, true, "$mine$", "mine", descriptions[20]);


	if (cost_arrows > 0)
		addItemForCoin(trader, "Arrows", cost_arrows, true, "$mat_arrows$", "mat_arrows", descriptions[2]);

	if (cost_waterarrows > 0)
		addItemForCoin(trader, "Water Arrows", cost_waterarrows, true, "$mat_waterarrows$", "mat_waterarrows", descriptions[50]);

	if (cost_firearrows > 0)
		addItemForCoin(trader, "Fire Arrows", cost_firearrows, true, "$mat_firearrows$", "mat_firearrows", descriptions[32]);

	if (cost_bombarrows > 0)
		addItemForCoin(trader, "Bomb Arrow", cost_bombarrows, true, "$mat_bombarrows$", "mat_bombarrows", descriptions[51]);

	if (cost_sponge > 0)
		addItemForCoin(trader, "Sponge", cost_sponge, true, "$sponge$", "sponge", descriptions[53]);

	if (cost_mountedbow > 0)
		addItemForCoin(trader, "Mounted Bow", cost_mountedbow, true, "$mounted_bow$", "mounted_bow", descriptions[31]);

	if (cost_drill > 0)
		addItemForCoin(trader, "Drill", cost_drill, true, "$drill$", "drill", descriptions[43]);

	if (cost_boulder > 0)
		addItemForCoin(trader, "Boulder", cost_boulder, true, "$boulder$", "boulder", descriptions[17]);

	if (cost_burger > 0)
		addItemForCoin(trader, "Burger", cost_burger, true, "$food$", "food", "Food for healing. Don't think about this too much.");


	if (cost_catapult > 0)
		addItemForCoin(trader, "Catapult", cost_catapult, true, "$catapult$", "catapult", descriptions[5]);

	if (cost_ballista > 0)
		addItemForCoin(trader, "Ballista", cost_ballista, true, "$ballista$", "ballista", descriptions[6]);

	if (cost_trampoline > 0)
		addItemForCoin(trader, "Trampoline", cost_trampoline, true, "$trampoline$", "trampoline", descriptions[30]);
}

string[] names;

void GiveRestartCoins(CPlayer@ p)
{
	if (keepCoinsOnRestart)
		p.server_setCoins(p.getCoins() + coinsOnRestartAdd);
	else
		p.server_setCoins(coinsOnRestartAdd);
}

void GiveRestartCoinsIfNeeded(CPlayer@ player)
{
	const string s = player.getUsername();
	for (uint i = 0; i < names.length; ++i)
	{
		if (names[i] == s)
		{
			return;
		}
	}

	names.push_back(s);
	GiveRestartCoins(player);
}

//extra coins on start to prevent stagnant round start
void Reset(CRules@ this)
{
	if (!getNet().isServer())
		return;

	names.clear();

	uint count = getPlayerCount();
	for (uint p_step = 0; p_step < count; ++p_step)
	{
		CPlayer@ p = getPlayer(p_step);
		GiveRestartCoins(p);
		names.push_back(p.getUsername());
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

//also given when plugging player -> on first spawn
void onSetPlayer(CRules@ this, CBlob@ blob, CPlayer@ player)
{
	if (!getNet().isServer())
		return;

	if (player !is null)
	{
		GiveRestartCoinsIfNeeded(player);
	}
}

//
// give coins for killing

void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ killer, u8 customData)
{
	if (!getNet().isServer())
		return;

	if (victim !is null)
	{
		if (killer !is null)
		{
			if (killer !is victim && killer.getTeamNum() != victim.getTeamNum())
			{
				killer.server_setCoins(killer.getCoins() + coinsOnKillAdd);
			}
			else if (killer.getTeamNum() == victim.getTeamNum())
			{
				killer.server_setCoins(killer.getCoins() - coinsOnTKLose);
			}
		}

		s32 lost = victim.getCoins() * (coinsOnDeathLosePercent * 0.01f);

		victim.server_setCoins(victim.getCoins() - lost);

		//drop coins
		CBlob@ blob = victim.getBlob();
		if (blob !is null)
			server_DropCoins(blob.getPosition(), XORRandom(lost));
	}
}

// give coins for damage

f32 onPlayerTakeDamage(CRules@ this, CPlayer@ victim, CPlayer@ attacker, f32 DamageScale)
{
	if (!getNet().isServer())
		return DamageScale;

	if (attacker !is null && attacker !is victim && attacker.getTeamNum() != victim.getTeamNum())
	{
        CBlob@ v = victim.getBlob();
        f32 health = 0.0f;
        if(v !is null)
            health = v.getHealth();
        f32 dmg = DamageScale;
        dmg = Maths::Min(health, dmg);

		attacker.server_setCoins(attacker.getCoins() + dmg * coinsOnDamageAdd / this.attackdamage_modifier);
	}

	return DamageScale;
}

// coins for various game events
void onCommand(CRules@ this, u8 cmd, CBitStream @params)
{
	//only important on server
	if (!getNet().isServer())
		return;

    if (cmd == this.getCommandID("score basket") && this.getCurrentState() == GAME) {
        log("onCommand", "score basket command received");
        uint8 basketNum = params.read_u8(); // either 1 or 2
        uint8 points = params.read_u8(); // either 2 or 3
        string scoringPlayerUsername = params.read_string();
        log("onCommand", "basketNum: " + basketNum);
        log("onCommand", "points: " + points);
        log("onCommand", "scoringPlayerUsername: " + scoringPlayerUsername);

        if (scoringPlayerUsername != "__noplayer__") {
            CPlayer@ scoringPlayer = getPlayerByUsername(scoringPlayerUsername);
            int coins = points * coinsOnScorePoint;

            scoringPlayer.server_setCoins(scoringPlayer.getCoins() + coins);
        }
    }
    else if (cmd == getGameplayEventID(this))
	{
		GameplayEvent g(params);

		CPlayer@ p = g.getPlayer();
		if (p !is null)
		{
			u32 coins = 0;

			switch (g.getType())
			{
				case GE_built_block:

				{
					g.params.ResetBitIndex();
					u16 tile = g.params.read_u16();
					if (tile == CMap::tile_castle)
					{
						coins = coinsOnBuild;
					}
					else if (tile == CMap::tile_wood)
					{
						coins = coinsOnBuildWood;
					}
				}

				break;

				case GE_built_blob:

				{
					g.params.ResetBitIndex();
					string name = g.params.read_string();

					if (name.findFirst("door") != -1 ||
					        name == "wooden_platform" ||
					        name == "trap_block" ||
					        name == "spikes")
					{
						coins = coinsOnBuild;
					}
					else if (name == "building")
					{
						coins = coinsOnBuildWorkshop;
					}
				}

				break;

				case GE_hit_vehicle:
					coins = coinsOnHitSiege;
					break;

				case GE_kill_vehicle:
					coins = coinsOnKillSiege;
					break;

				case GE_captured_flag:
					coins = coinsOnCapFlag;
					break;
			}

			if (coins > 0)
			{
				if (this.isWarmup())
					coins /= warmupFactor;

				p.server_setCoins(p.getCoins() + coins);
			}
		}
	}
}
