#include "ShopCommon.as"
#include "UI.as"
#include "DebugButton.as"
#include "RulesCommon.as"
#include "SoldierCommon.as"
#include "BackendCommon.as"
#include "LobbyCommon.as"
#include "HoverMessage.as"
#include "Leaderboard.as"
#include "Pets.as"

void onInit(CBlob@ this)
{
	CShape@ shape = this.getShape();
	shape.SetStatic(true);
	ShapeConsts@ consts = shape.getConsts();
	consts.mapCollisions = false;

	CSprite@ sprite = this.getSprite();
	sprite.SetZ(-50);

	//from client
	this.addCommandID("use");

	//for serverside checks (from client menu, is missing important info)
	this.addCommandID("buy");

	//from server on success/fail
	this.addCommandID("bought");
	this.addCommandID("broke");

	this.addCommandID("leaderboard");
	this.addCommandID("skinshop");
	this.addCommandID("skinshop2");
	this.addCommandID("skinshop3");
	this.addCommandID("petshop");
	this.addCommandID("toyshop");

	this.set_Vec2f("hover message offset", Vec2f(0, -16));

	Leaderboard::SetCurrentLeaderboard(0, "");

	const u8 type = getShopType(this);

	string greet = "";
	string goodbye = "";
	string name = "";
	switch (type)
	{
		case BAR:
			Leaderboard::Init("drinking leaderboard", "Top Drinkers");
			Leaderboard::Init("wins leaderboard", "Top Wins");
			Leaderboard::Init("losses leaderboard", "Top Losses");
			greet = "What can I get you?";
			goodbye = "See you later.";
			name = "bartender";
			break;
		case BAR_VIP:
			greet = "What can I do you for?";
			goodbye = "You're welcome anytime.";
			name = "barmaid";
			this.Tag("vip");
			break;
		case SKIN_SHOP:
			goodbye = "You're welcome anytime.";
			name = "costume seller";
			break;
		case PET_SHOP:
			greet = "Adopt a cute creature!";
			goodbye = "Please come back!";
			name = "petshop owner";
			break;
		case COFFEE_SHOP:
			greet = "Need a pick-me-up?";
			goodbye = "Until next time!";
			name = "barista";
			break;
	}
	this.set_string("say greet", greet);
	this.set_string("say goodbye", goodbye);
	this.set_string("owner name", name);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("use"))
	{
		CBlob@ blob = getBlobByNetworkID(params.read_netid());
		if (blob is null) return;
		CPlayer@ player = blob.getPlayer();

		UpdateLeaderboards( this, player );

		CRules@ rules = getRules();
		if (!getNet().isClient() || blob is null || hasMenus(rules))
			return;

		if (player.isMyPlayer())
		{
			ShowMainMenu(rules, this, blob);
		}
	}
	else if (cmd == this.getCommandID("buy"))
	{
		//read out so we dont corrupt stream
		u8 type = params.read_u8();
		u16 id = params.read_u16();

		//gather variables
		CBlob@ b = getBlobByNetworkID(id);
		if (b is null) return;
		CPlayer@ p = b.getPlayer();
		if (p is null) return;
		//only server does it
		if (!getNet().isServer()) return;
		//
		string name = p.getUsername();

		bool usebackend = getRules().hasTag("use_backend");

		s32 price = getPrice(this, type);

		bool allowed = true;
		Lobby::PlayerRecord@ record = null;
		if (usebackend)
		{
			//todo: display error?
			if (Lobby::hasPlayerRecord(name))
			{
				//get the record
				@record = Lobby::getPlayerRecordFromUsername(name);
				allowed = record.coins >= price;
			}
			else
			{
				allowed = false;
			}
		}

		//has money?
		if (allowed || sv_test)
		{
			if (usebackend && !sv_test)
			{
				record.coins -= price;
				Backend::PlayerCoinTransaction(p, -price);

				if (type < BUYTYPE_CIG)
				{
					Backend::PlayerMetric(p, "drink");
					Backend::PlayerMetric(p, type == BUYTYPE_BEER ? "drink_beer" : "drink_wine");
					Leaderboard::AddScore("drinking leaderboard", p.getCharacterName(), 1);
				}
				else if (type == BUYTYPE_CIG)
				{
					Backend::PlayerMetric(p, "smoke");
				}
				else if (type >= BUYTYPE_PET && type < BUYTYPE_TOY)
				{
					Backend::PlayerMetric(p, "pet");
					Backend::SetPlayerPet(p, type - BUYTYPE_PET);
				}
				else if (type >= BUYTYPE_TOY && type < BUYTYPE_COSTUME)
				{
					// no need
				}
				else if (type >= BUYTYPE_COSTUME)
				{
					//skin change
					Backend::PlayerMetric(p, "changed_costume");
					Backend::SetPlayerSkin(p, type - BUYTYPE_COSTUME);
				}
			}

			CBitStream params;
			params.write_u8(type);
			params.write_u16(id);
			this.SendCommand(this.getCommandID("bought"), params);
		}
		else
		{
			this.SendCommand(this.getCommandID("broke"));
		}

	}
	else if (cmd == this.getCommandID("bought"))
	{
		//TODO: ch-ching! sound here

		//read out so we dont corrupt stream
		u8 type = params.read_u8();
		u16 id = params.read_u16();

		//gather variables
		CBlob@ b = getBlobByNetworkID(id);
		if (b is null) return;
		//
		CBitStream params;

		if (type >= BUYTYPE_PET && type < BUYTYPE_TOY)
		{
			//gender of pet isn't really important
			//but hey lets be consistent
			const u8 pet_type = type - BUYTYPE_PET;
			string gender = "";
			if (pet_type <= CACTUS)
			{
				gender = "it";
			}
			else if (pet_type == CHICKEN)
			{
				gender = "her";
			}
			else
			{
				bool boy = (((pet_type + id) % 2) == 0);
				gender = (boy ? "him" : "her");
			}
			AddMessageTimed(this, "Take care of " + gender + "!", SAY_TIME);

			if (getNet().isServer())
			{
				CBlob@ currentpet = findPet(b);
				if (currentpet !is null)
					currentpet.server_Die();
			}

			SpawnPet(b, pet_type, b.getPosition(), false);
		}
		else if (type >= BUYTYPE_TOY && type < BUYTYPE_COSTUME)
		{
			AddMessageTimed(this, "Have fun!", SAY_TIME);
			const u8 toy_type = type - BUYTYPE_TOY;
			SpawnToy(b, toy_type, b.getPosition());
		}
		else if (type >= BUYTYPE_COSTUME)
		{
			AddMessage(this, "Looking Good!");

			//only server sends any more cmds
			if (!getNet().isServer()) return;

			CBitStream params;
			params.write_u8(u8(type - BUYTYPE_COSTUME));
			b.SendCommand(Soldier::Commands::CIVILIAN_LOADSKIN, params);
		}
		else if (type == BUYTYPE_CIG)
		{
			AddMessageTimed(this, "Smoking is bad!", SAY_TIME);

			//only server sends any more cmds
			if (!getNet().isServer()) return;

			params.write_bool(true);
			b.SendCommand(Soldier::Commands::CIVILIAN_CIGAR, params);
		}
		else if (type == BUYTYPE_COFFEE)
		{
			AddMessageTimed(this, "Enjoy", SAY_TIME);

			//only server sends any more cmds
			if (!getNet().isServer()) return;

			b.SendCommand(Soldier::Commands::CIVILIAN_COFFEE, params);
		}
		else // wine/beer
		{
			AddMessageTimed(this, "Enjoy", SAY_TIME);

			//only server sends any more cmds
			if (!getNet().isServer()) return;

			params.write_bool(type == BUYTYPE_WINE);
			b.SendCommand(Soldier::Commands::CIVILIAN_DRINK, params);
		}
	}
	else if (cmd == this.getCommandID("broke"))
	{
		if (getNet().isClient())
		{
			//alt messages, increase with repeated tries:
			string[] messages =
			{
				"Sorry mate, you're broke!",
				"...I cant accept pocket fluff.",
				"What do i look like, a charity?",
				"Gonna need to see some ID soon...",
				"Stop wasting my time!"
			};
			if (!this.exists("_client_msgcounter"))
			{
				this.set_u8("_client_msgcounter", 0);
			}
			else
			{
				this.set_u8("_client_msgcounter", this.get_u8("_client_msgcounter") + 1);
			}
			u8 _client_msgcounter = this.get_u8("_client_msgcounter");
			AddMessageTimed(this, messages[_client_msgcounter % messages.length], SAY_TIME);
		}
	}
	else if (cmd == this.getCommandID("leaderboard"))
	{
		if (getNet().isClient())
		{
			Leaderboard::Read(params);
		}
	}
	else if (cmd == this.getCommandID("skinshop") || cmd == this.getCommandID("skinshop2") || cmd == this.getCommandID("skinshop3") ||
	         cmd == this.getCommandID("petshop") || cmd == this.getCommandID("toyshop"))
	{
		CBlob@ blob = getBlobByNetworkID(params.read_netid());
		if (blob is null) return;
		CPlayer@ player = blob.getPlayer();
		CRules@ rules = getRules();
		if (!getNet().isClient() || blob is null)
			return;

		if (player.isMyPlayer())
		{
			if (cmd == this.getCommandID("skinshop"))
				ShowSkinShop(rules, this, blob);
			else if (cmd == this.getCommandID("skinshop2"))
				ShowSkinShop2(rules, this, blob);
			else if (cmd == this.getCommandID("skinshop3"))
				ShowSkinShop3(rules, this, blob);
			else if (cmd == this.getCommandID("petshop"))
				ShowPetShop(rules, this, blob);
			else if (cmd == this.getCommandID("toyshop"))
				ShowToyShop(rules, this, blob);
		}
	}
}

void UpdateLeaderboards( CBlob@ this, CPlayer@ player )
{
	if (getNet().isServer())
	{
		Leaderboard::Sync(this, "drinking leaderboard", player);
		Leaderboard::Sync(this, "basketball leaderboard", player);
		Leaderboard::Sync(this, "wins leaderboard", player);
		Leaderboard::Sync(this, "losses leaderboard", player);
	}
}

void ShowMainMenu(CRules@ this, CBlob@ bartender, CBlob@ player)
{
	const u8 type = getShopType(bartender);

	UI::AddGroup(SHOP_MENU, Vec2f(0.25f, 0.1f), Vec2f(0.7f, 0.9f));
	UI::SetFont("gui");

	if (type == BAR_VIP || type == BAR)
	{
		UI::Grid(1, type == BAR_VIP ? 8 : 7);
		UI::Debug::AddButton("Greet", MenuGreet);

		string price = "" + getPrice(bartender, BUYTYPE_BEER) + "c";

		if (type == BAR_VIP)
		{
			if (!player.hasTag("smoking"))
			{
				UI::Debug::AddButton("Buy cigar (" + price + ")", MenuCigarettes);
			}
			else
			{
				UI::Debug::AddButton("(Already smoking)", MenuNothing);
			}
		}

		bool alreadydrinking = player.hasTag("drinking");
		u8 drunk_maximum = (type == BAR_VIP) ? 20 : 10;
		bool toodrunk = (player.exists("drunk_amount") && player.get_u8("drunk_amount") >= drunk_maximum);
		if (!alreadydrinking && !toodrunk)
		{
			UI::Debug::AddButton("Buy beer  (" + price + ")", MenuDrinkBeer);
			UI::Debug::AddButton("Buy wine  (" + price + ")", MenuDrinkWine);
		}
		else
		{
			if (toodrunk)
			{
				UI::Debug::AddButton("(Too drunk)", MenuNothing);
			}
			else
			{
				UI::Debug::AddButton("(Already drinking)", MenuNothing);
			}
		}

		if (type == BAR)
		{
			UI::Debug::AddButton("Show leaderboards", MenuLeaderboards);
		}
	}
	else if (type == SKIN_SHOP)
	{
		UI::Grid(1, 7);
		UI::Debug::AddButton("What Are Costumes?", MenuWhatAreCostumes);
		UI::Debug::AddButton("Are They Permanent?", MenuPermanent);
		UI::Debug::AddButton("Remove Costume", MenuRemoveCostume);
		UI::Debug::AddButton("Buy Class Costume", SendShowSkinShop2);
		UI::Debug::AddButton("Buy Funny Costume", SendShowSkinShop3);
		UI::Debug::AddButton("Buy Other Costume", SendShowSkinShop);
	}
	else if (type == PET_SHOP)
	{
		UI::Grid(1, 5);
		UI::Debug::AddButton("What Are Pets?", MenuWhatArePets);
		UI::Debug::AddButton("Are They Permanent?", MenuPermanent);
		UI::Debug::AddButton("Buy Pet", SendShowPetShop);
		UI::Debug::AddButton("Buy Toy", SendShowToyShop);
	}
	else if (type == COFFEE_SHOP)
	{
		string price = "" + getPrice(bartender, BUYTYPE_COFFEE) + "c";

		UI::Grid(1, 5);
		UI::Debug::AddButton("Greet", MenuGreet);
		UI::Debug::AddButton("What is Coffee?", MenuWhatIsCoffee);
		UI::Debug::AddButton("What's the benefit?", MenuCoffeeBenefits);

		if(!player.hasTag("drinking"))
		{
			UI::Debug::AddButton("Buy coffee (" + price + ")", MenuDrinkCoffee);
		}
		else
		{
			UI::Debug::AddButton("(Already drinking)", MenuNothing);
		}
	}

	UI::Debug::AddButton("Goodbye", MenuBye);
	UI::SetSelector("none", Vec2f_zero);

	UI::Debug::SetSelection(0);
	UI::Debug::SetLastSelection();

	UI::SetSelection(0);
	UI::SetLastSelection();

	UI::getGroup(SHOP_MENU).vars.set("player", @player);
	UI::getGroup(SHOP_MENU).vars.set("bartender", @bartender);
}

void MenuNothing(CRules@ this, UI::Group@ group, UI::Control@ button)
{}

void MenuGreet(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	CBlob@ bartender;
	group.vars.get("bartender", @bartender);
	UI::Clear(group.name);
	if (bartender is null)
		return;
	AddMessageTimed(bartender, bartender.get_string("say greet"), SAY_TIME);
}

void MenuCigarettes(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	CBlob@ bartender;
	group.vars.get("bartender", @bartender);
	CBlob@ player;
	group.vars.get("player", @player);
	UI::Clear(SHOP_MENU);
	if (bartender is null || player is null)
		return;

	CBitStream params;
	params.write_u8(BUYTYPE_CIG);
	params.write_u16(player.getNetworkID());
	bartender.SendCommand(bartender.getCommandID("buy"), params);

}

void MenuDrinkBeer(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	CBlob@ bartender;
	group.vars.get("bartender", @bartender);
	CBlob@ player;
	group.vars.get("player", @player);
	UI::Clear(SHOP_MENU);
	if (bartender is null || player is null)
		return;

	CBitStream params;
	params.write_u8(BUYTYPE_BEER);
	params.write_u16(player.getNetworkID());
	bartender.SendCommand(bartender.getCommandID("buy"), params);
}

void MenuDrinkWine(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	CBlob@ bartender;
	group.vars.get("bartender", @bartender);
	CBlob@ player;
	group.vars.get("player", @player);
	UI::Clear(SHOP_MENU);
	if (bartender is null || player is null)
		return;

	CBitStream params;
	params.write_u8(BUYTYPE_WINE);
	params.write_u16(player.getNetworkID());
	bartender.SendCommand(bartender.getCommandID("buy"), params);
}

void MenuBack(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	CBlob@ bartender;
	group.vars.get("bartender", @bartender);
	CBlob@ player;
	group.vars.get("player", @player);
	if (bartender is null || player is null)
		return;
	UI::Clear();
	Leaderboard::SetCurrentLeaderboard(0, "");
	ShowMainMenu(this, bartender, player);
}

void MenuLeaderboards(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	CBlob@ bartender;
	group.vars.get("bartender", @bartender);
	CBlob@ player;
	group.vars.get("player", @player);
	if (bartender is null || player is null)
		return;

	UI::Clear(SHOP_MENU);
	UI::AddGroup(SHOP_MENU + "leaderboard", Vec2f(0.25f, 0.1f), Vec2f(0.7f, 0.9f));
	UI::SetFont("gui");
	UI::Grid(1, 6);
	UI::Debug::AddButton("Top Wins", MenuWinsLeaderboard);
	UI::Debug::AddButton("Top Losses", MenuLossesLeaderboard);
	UI::Debug::AddButton("Top Drinkers", MenuDrinkingLeaderboard);
	UI::Debug::AddButton("Top Basketball Scores", MenuBasketballLeaderboard);
	UI::Debug::AddButton("Back", MenuBack);
	UI::SetSelector("none", Vec2f_zero);

	UI::Debug::SetSelection(0);
	UI::Debug::SetLastSelection();

	UI::getGroup(SHOP_MENU + "leaderboard").vars.set("player", @player);
	UI::getGroup(SHOP_MENU + "leaderboard").vars.set("bartender", @bartender);
}

void MenuWinsLeaderboard(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	CBlob@ bartender;
	group.vars.get("bartender", @bartender);
	//UI::Clear(SHOP_MENU);
	if (bartender is null)
		return;
	Leaderboard::SetCurrentLeaderboard(getGameTime(), "wins leaderboard");
}

void MenuLossesLeaderboard(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	CBlob@ bartender;
	group.vars.get("bartender", @bartender);
	//UI::Clear(SHOP_MENU);
	if (bartender is null)
		return;
	Leaderboard::SetCurrentLeaderboard(getGameTime(), "losses leaderboard");
}

void MenuDrinkingLeaderboard(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	CBlob@ bartender;
	group.vars.get("bartender", @bartender);
	//UI::Clear(SHOP_MENU);
	if (bartender is null)
		return;
	Leaderboard::SetCurrentLeaderboard(getGameTime(), "drinking leaderboard");
}

void MenuBasketballLeaderboard(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	CBlob@ bartender;
	group.vars.get("bartender", @bartender);
	//UI::Clear(SHOP_MENU);
	if (bartender is null)
		return;
	Leaderboard::SetCurrentLeaderboard(getGameTime(), "basketball leaderboard");
}

void MenuBye(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	CBlob@ bartender;
	group.vars.get("bartender", @bartender);
	UI::Clear();
	if (bartender is null)
		return;
	AddMessageTimed(bartender, bartender.get_string("say goodbye"), SAY_TIME);
}

void MenuPermanent(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	CBlob@ bartender;
	group.vars.get("bartender", @bartender);
	UI::Clear(group.name);
	if (bartender is null)
		return;

	string item = getShopType(bartender) == PET_SHOP ? "pet" : "costume";

	//(backwards order)
	AddMessageTimed(bartender, "This may be improved in future.", 250);
	AddMessageTimed(bartender, "but replace your current " + item + ".", 250);
	AddMessageTimed(bartender, "Purchases are permanent,", 250);
}

// pet shop stuff


void ShowPetShop(CRules@ this, CBlob@ bartender, CBlob@ player)
{
	UI::Clear(SHOP_MENU);
	UI::AddGroup(SHOP_MENU, Vec2f(0.25f, 0.1f), Vec2f(0.7f, 0.9f));
	UI::SetFont("gui");
	UI::Grid(1, 10);


	UI::Debug::AddButton("Faithful Fern" + " (" + getPetCost(FERN) + ")", MenuPetFern);
	UI::Debug::AddButton("Prickly Cactus" + " (" + getPetCost(CACTUS) + ")", MenuPetCactus);
	UI::Debug::AddButton("Plucky Chicken" + " (" + getPetCost(CHICKEN) + ")", MenuPetChicken);
	UI::Debug::AddButton("Fluffy Bunny" + " (" + getPetCost(BUNNY) + ")", MenuPetBunny);
	UI::Debug::AddButton("Noisy Parrot" + " (" + getPetCost(PARROT) + ")", MenuPetParrot);
	UI::Debug::AddButton("Loving Dog" + " (" + getPetCost(DOG) + ")", MenuPetDog);
	UI::Debug::AddButton("Scheming Cat" + " (" + getPetCost(CAT) + ")", MenuPetCat);
	UI::Debug::AddButton("Extreme Crocodile" + " (" + getPetCost(CROC) + ")", MenuPetCroc);
	UI::Debug::AddButton("Back", MenuBack);
	UI::SetSelector("none", Vec2f_zero);

	UI::Debug::SetSelection(0);
	UI::Debug::SetLastSelection();

	UI::SetSelection(0);
	UI::SetLastSelection();

	UI::getGroup(SHOP_MENU).vars.set("player", @player);
	UI::getGroup(SHOP_MENU).vars.set("bartender", @bartender);
}

void MenuWhatArePets(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	CBlob@ bartender;
	group.vars.get("bartender", @bartender);
	UI::Clear(group.name);
	if (bartender is null)
		return;

	//(backwards order)
	AddMessageTimed(bartender, "abilities, and all are cute!", 250);
	AddMessageTimed(bartender, "the lobby! Some have special", 250);
	AddMessageTimed(bartender, "that follow you around in", 250);
	AddMessageTimed(bartender, "Pets are little companions", 250);
}

void MenuPetChicken(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	SendPetBuy(group, CHICKEN);
}

void MenuPetFern(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	SendPetBuy(group, FERN);
}

void MenuPetCactus(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	SendPetBuy(group, CACTUS);
}

void MenuPetParrot(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	SendPetBuy(group, PARROT);
}

void MenuPetBunny(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	SendPetBuy(group, BUNNY);
}

void MenuPetDog(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	SendPetBuy(group, DOG);
}

void MenuPetCat(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	SendPetBuy(group, CAT);
}

void MenuPetCroc(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	SendPetBuy(group, CROC);
}

void SendPetBuy(UI::Group@ group, u8 pet)
{
	CBlob@ bartender;
	group.vars.get("bartender", @bartender);
	CBlob@ player;
	group.vars.get("player", @player);
	UI::Clear();
	if (bartender is null || player is null)
		return;

	//send the buy command to be handled on the server
	CBitStream params;
	params.write_u8(BUYTYPE_PET + pet);
	params.write_u16(player.getNetworkID());
	bartender.SendCommand(bartender.getCommandID("buy"), params);
}

void SendShowShop(CRules@ this, UI::Group@ group, const string &in cmd)
{
	CBlob@ bartender;
	group.vars.get("bartender", @bartender);
	CBlob@ player;
	group.vars.get("player", @player);
	UI::Clear(SHOP_MENU);
	if (bartender is null || player is null)
		return;

	CBitStream params;
	params.write_u16(player.getNetworkID());
	bartender.SendCommand(bartender.getCommandID(cmd), params);
}

void SendShowPetShop(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	SendShowShop(this, group, "petshop");
}

// toy shop

void SendShowToyShop(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	SendShowShop(this, group, "toyshop");
}

void SendToyBuy(UI::Group@ group, u8 toy)
{
	CBlob@ bartender;
	group.vars.get("bartender", @bartender);
	CBlob@ player;
	group.vars.get("player", @player);
	UI::Clear();
	if (bartender is null || player is null)
		return;

	//send the buy command to be handled on the server
	CBitStream params;
	params.write_u8(BUYTYPE_TOY + toy);
	params.write_u16(player.getNetworkID());
	bartender.SendCommand(bartender.getCommandID("buy"), params);
}

void ShowToyShop(CRules@ this, CBlob@ bartender, CBlob@ player)
{
	UI::Clear(SHOP_MENU);
	UI::AddGroup(SHOP_MENU, Vec2f(0.25f, 0.1f), Vec2f(0.7f, 0.9f));
	UI::SetFont("gui");
	UI::Grid(1, 8);

	UI::Debug::AddButton("Fertilizer for Plants" + " (" + getToyCost(TOY_FERTILIZER) + ")", MenuToyFertilizer);
	UI::Debug::AddButton("Nest for Chicken" + " (" + getToyCost(TOY_NEST) + ")", MenuToyNest);
	UI::Debug::AddButton("Frisbee for Dog" + " (" + getToyCost(TOY_FRISBEE) + ")", MenuToyFrisbee);
	UI::Debug::AddButton("Wool ball for Cat" + " (" + getToyCost(TOY_WOOLBALL) + ")", MenuToyWoolBall);
	UI::Debug::AddButton("Carrot for Bunny" + " (" + getToyCost(TOY_CARROT) + ")", MenuToyCarrot);
	UI::Debug::AddButton("Bell for Parrot" + " (" + getToyCost(TOY_MASCOT) + ")", MenuToyMascot);
	UI::Debug::AddButton("Hamburger for Crocodile" + " (" + getToyCost(TOY_HAMBURGER) + ")", MenuToyHamburger);
	UI::Debug::AddButton("Back", MenuBack);
	UI::SetSelector("none", Vec2f_zero);

	UI::Debug::SetSelection(0);
	UI::Debug::SetLastSelection();

	UI::SetSelection(0);
	UI::SetLastSelection();

	UI::getGroup(SHOP_MENU).vars.set("player", @player);
	UI::getGroup(SHOP_MENU).vars.set("bartender", @bartender);
}

void MenuToyFertilizer(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	SendToyBuy(group, TOY_FERTILIZER);
}

void MenuToyFrisbee(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	SendToyBuy(group, TOY_FRISBEE);
}

void MenuToyWoolBall(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	SendToyBuy(group, TOY_WOOLBALL);
}

void MenuToyMascot(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	SendToyBuy(group, TOY_MASCOT);
}

void MenuToyHamburger(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	SendToyBuy(group, TOY_HAMBURGER);
}

void MenuToyCarrot(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	SendToyBuy(group, TOY_CARROT);
}

void MenuToyNest(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	SendToyBuy(group, TOY_NEST);
}

// coffee shop stuff

void MenuWhatIsCoffee(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	CBlob@ bartender;
	group.vars.get("bartender", @bartender);
	UI::Clear(group.name);
	if (bartender is null)
		return;

	//(backwards order)
	AddMessageTimed(bartender, "The taste grows on you.", 250);
	AddMessageTimed(bartender, "made from ground coffee beans.", 250);
	AddMessageTimed(bartender, "Coffee is a bitter drink", 250);
}

void MenuCoffeeBenefits(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	CBlob@ bartender;
	group.vars.get("bartender", @bartender);
	UI::Clear(group.name);
	if (bartender is null)
		return;

	//(backwards order)
	AddMessageTimed(bartender, "which may help if you've been drinking", 250);
	AddMessageTimed(bartender, "It also helps keep you awake,", 250);
	AddMessageTimed(bartender, "Coffee is delicious.", 250);
}

void MenuDrinkCoffee(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	CBlob@ bartender;
	group.vars.get("bartender", @bartender);
	CBlob@ player;
	group.vars.get("player", @player);
	UI::Clear(SHOP_MENU);
	if (bartender is null || player is null)
		return;

	CBitStream params;
	params.write_u8(BUYTYPE_COFFEE);
	params.write_u16(player.getNetworkID());
	bartender.SendCommand(bartender.getCommandID("buy"), params);
}

// skin shop stuff

void SendShowSkinShop(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	SendShowShop(this, group, "skinshop");
}

void SendShowSkinShop2(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	SendShowShop(this, group, "skinshop2");
}

void SendShowSkinShop3(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	SendShowShop(this, group, "skinshop3");
}

void ShowSkinShop_Abstract(CRules@ this, CBlob@ bartender, CBlob@ player, u8[]@ skins_order, UI::Debug::SELECT_FUNCTION@[]@ functions)
{
	UI::Clear(SHOP_MENU);
	UI::AddGroup(SHOP_MENU, Vec2f(0.25f, 0.1f), Vec2f(0.7f, 0.9f));
	UI::SetFont("gui");
	UI::Grid(1, skins_order.length + 1);

	for (u32 i = 0; i < skins_order.length; i++)
	{
		u8 sk = skins_order[i];
		u32 cost = getSkinCost(sk);
		string coststring = ((cost == 0) ? "free" : "" + cost + "c");
		UI::Debug::AddButton(getSkinDescription(sk) + " (" + coststring + ")", functions[i]);
	}

	UI::Debug::AddButton("Back", MenuBack);
	UI::SetSelector("none", Vec2f_zero);

	UI::Debug::SetSelection(0);
	UI::Debug::SetLastSelection();

	UI::SetSelection(0);
	UI::SetLastSelection();

	UI::getGroup(SHOP_MENU).vars.set("player", @player);
	UI::getGroup(SHOP_MENU).vars.set("bartender", @bartender);
}

void ShowSkinShop(CRules@ this, CBlob@ bartender, CBlob@ player)
{
	u8[] skins_order =
	{
		SKIN_UNIFORM,
		SKIN_BOUNTY_HUNTER_FEM,
		SKIN_FANCYDRESS,
		SKIN_FANCYSUIT
	};

	UI::Debug::SELECT_FUNCTION@[] functions =
	{
		MenuWW1Uniform,
		MenuBountyFem,
		MenuFancyDress,
		MenuFancySuit
	};

	ShowSkinShop_Abstract(this, bartender, player, skins_order, functions);
}

void ShowSkinShop2(CRules@ this, CBlob@ bartender, CBlob@ player)
{
	u8[] skins_order =
	{
		SKIN_ASSAULT,
		SKIN_SNIPER,
		SKIN_MEDIC,
		SKIN_DEMOLITIONS,
		SKIN_COMMANDO
	};

	UI::Debug::SELECT_FUNCTION@[] functions =
	{
		MenuAssault,
		MenuSniper,
		MenuMedic,
		MenuDemolitions,
		MenuCommando
	};

	ShowSkinShop_Abstract(this, bartender, player, skins_order, functions);
}

void ShowSkinShop3(CRules@ this, CBlob@ bartender, CBlob@ player)
{
	u8[] skins_order =
	{
		SKIN_HAT,
		SKIN_SUPER_RED,
		SKIN_HORSE_HEAD,
		SKIN_HORSE_BUTT,
		SKIN_RICH_BASTARD
	};

	UI::Debug::SELECT_FUNCTION@[] functions =
	{
		MenuCoolHat,
		MenuSuperSuit,
		MenuHorseHead,
		MenuHorseButt,
		MenuRich
	};

	ShowSkinShop_Abstract(this, bartender, player, skins_order, functions);
}

void MenuWhatAreCostumes(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	CBlob@ bartender;
	group.vars.get("bartender", @bartender);
	UI::Clear(group.name);
	if (bartender is null)
		return;

	//(backwards order)
	AddMessageTimed(bartender, "lobby, to show off!", 250);
	AddMessageTimed(bartender, "that you can wear in the", 250);
	AddMessageTimed(bartender, "Costumes are fun clothes", 250);
}

void SendPlayerSkinChange(UI::Group@ group, u8 skin)
{
	CBlob@ player;
	group.vars.get("player", @player);
	CBlob@ bartender;
	group.vars.get("bartender", @bartender);
	UI::Clear(group.name);
	if (player is null || bartender is null)
		return;

	if (player.exists("skin") && player.get_u8("skin") == skin)
	{
		if (player.get_u8("skin") == SKIN_NONE)
			AddMessageTimed(bartender, "You're not wearing a costume!", SAY_TIME);
		else
			AddMessageTimed(bartender, "You're already wearing that!", SAY_TIME);
		return;
	}

	//send the buy command to be handled on the server
	CBitStream params;
	params.write_u8(BUYTYPE_COSTUME + skin);
	params.write_u16(player.getNetworkID());
	bartender.SendCommand(bartender.getCommandID("buy"), params);
}

void MenuRemoveCostume(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	SendPlayerSkinChange(group, SKIN_NONE);
}

void MenuSuperSuit(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	SendPlayerSkinChange(group, SKIN_SUPER_RED);
}

void MenuCoolHat(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	SendPlayerSkinChange(group, SKIN_HAT);
}

void MenuWW1Uniform(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	SendPlayerSkinChange(group, SKIN_UNIFORM);
}

void MenuFancySuit(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	SendPlayerSkinChange(group, SKIN_FANCYSUIT);
}

void MenuFancyDress(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	SendPlayerSkinChange(group, SKIN_FANCYDRESS);
}

void MenuBountyFem(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	SendPlayerSkinChange(group, SKIN_BOUNTY_HUNTER_FEM);
}

void MenuAssault(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	SendPlayerSkinChange(group, SKIN_ASSAULT);
}

void MenuSniper(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	SendPlayerSkinChange(group, SKIN_SNIPER);
}

void MenuMedic(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	SendPlayerSkinChange(group, SKIN_MEDIC);
}

void MenuDemolitions(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	SendPlayerSkinChange(group, SKIN_DEMOLITIONS);
}

void MenuCommando(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	SendPlayerSkinChange(group, SKIN_COMMANDO);
}

void MenuHorseHead(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	SendPlayerSkinChange(group, SKIN_HORSE_HEAD);
}

void MenuHorseButt(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	SendPlayerSkinChange(group, SKIN_HORSE_BUTT);
}

void MenuRich(CRules@ this, UI::Group@ group, UI::Control@ button)
{
	SendPlayerSkinChange(group, SKIN_RICH_BASTARD);
}
