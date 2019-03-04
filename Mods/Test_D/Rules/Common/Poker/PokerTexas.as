#include "PokerCommon.as"
#include "Menus.as"

namespace Poker
{
	void WaitForChoice( Session@ session )
	{
		Player@ player = session.players[session.currentPlayer];
		if (player.local)
		{
			CPlayer@ localplayer = getLocalPlayer();
			if (!Menus::hasMenu(localplayer, "poker"))
			{
				Menus::Clear(localplayer);
			    Menus::AddMenu(localplayer, "poker", Vec2f(0.5f, 0.95f), Vec2f(50,20), true );
	        		Menus::AddButton(localplayer, "Call");
	        		Menus::AddButton(localplayer, "Raise");
	        		Menus::AddButton(localplayer, "Fold");
			}
		}
		else
		{
			bool cardsStopped = true;
			for (uint i=0; i < session.all.length; i++)
			{
				if (session.all[i].moving){
					cardsStopped = false;
					break;
				}
			}
	
			if (cardsStopped && player._choiceWaitTime > 0)
			{
				player._choiceWaitTime--;
				if (player._choiceWaitTime == 0)
				{
					string handname;
					int score = Poker::getPlayerValueHand( session, player, handname );
					if (_random.NextRanged(STRAIGHT_FLUSH) < score)
						Poker::Raise(session);
					else
						Poker::Call(session);
					Poker::NextPlayer(session);
				}
			}
		}
	}

	void NextPlayer( Session@ session )
	{
		session.currentPlayer = (session.currentPlayer + 1) % session.players.length;
		Player@ player = session.players[session.currentPlayer];
		player._choiceWaitTime = player.blob.isBot() ? 25 : 0;
		player.idleTime = 0;

printf("session.currentPlayer " + session.currentPlayer + " / " + session.roundEndPlayer);
		if (session.currentPlayer == session.roundEndPlayer)
		{
			if (!isGameOver(session)){
				NextRound(session);
			}
			else{
				GameOver(session);
				return;
			}
		}
		
		Poker::StatusAdd( session, " " + player.name + "'s turn...");
	}

	void Call( Session@ session )
	{
		Player@ player = session.players[session.currentPlayer];
		int amount = session.stake - player.inStake;
		printf("session.stake " + session.stake + " / " + player.inStake);
		if (ChipIn(session, player, amount) == 0){
			// error
		}

		Poker::Status(session, player.name + " has called. (added " + amount + ")");
	}

	void Raise( Session@ session )
	{
		Call( session );

		Player@ player = session.players[session.currentPlayer];
		const uint raised = ChipIn(session, player, session.secondBlind);
		session.stake += raised;
		if (raised > 0)
		{
			session.roundEndPlayer = session.currentPlayer;
       		Poker::Status(session, player.name + " has raised by " + raised);
       	}
	}

	void NextRound( Session@ session )
	{
		ResetRound( session );

		for (uint playerIt = 0; playerIt < session.players.length; playerIt++)
		{
			Player@ player = session.players[playerIt];
			player.inStake = 0;
		}

		Status(session, "New card is dealt.");
		Card@ card = TakeRandomCard(session);
		card.targetPosition = getCommunityCardsPosition(session.community.length);
		session.community.push_back( card );
	}

	void GameOver( Session@ session )
	{
		session.state = GAME_OVER;

		// calc winner

		string handName;
		uint winnerPlayer = getWinner( session, handName );
		Player@ player = session.players[winnerPlayer];
		Vec2f lastCardPos = Poker::getPlayerCardsPosition(winnerPlayer, player.cards.length);
		session.currentPlayer = winnerPlayer;

		Poker::Status( session, player.name + " has won the round with " + handName);

		// add chips to winner
		uint count = session.chips.length;
		while (session.chips.length > 0) 
		{
			Chip@ chip = session.chips[0];
			player.chips.push_back( chip );
			session.chips.removeAt(0);
			chip.targetPosition = lastCardPos + Vec2f(player.chips.length * 4 + 8.0f, 8.0f);		//REFACTOR
			chip.delay = 15 + session.all.length*1 + (count-session.chips.length)*4;
		}

		session.roundEndTimer = ROUNDEND_TICKS;
	}

	uint getWinner( Session@ session, string &out handName )
	{
		// calculate hand values

		for (uint playerIt = 0; playerIt < session.players.length; playerIt++)
		{
			Player@ player = session.players[playerIt];
			player.score = Poker::getPlayerValueHand( session, player, player.handName );
		}

		// get player with highest score

		int highestScore = 0;
		uint winnerIndex = 0;
		for (uint playerIt = 0; playerIt < session.players.length; playerIt++)
		{
			Player@ player = session.players[playerIt];
			printf(player.name +"'s score is: " + player.score);
			if (player.score > highestScore){
				winnerIndex = playerIt;
				highestScore = player.score;
				handName = player.handName;
			}
		}

		return winnerIndex;
	}

	void AllCardsOnDeck( Session@ session, const int interval )
	{
		Vec2f screenSize( getDriver().getScreenWidth(), getDriver().getScreenHeight() );
		for (uint i=0; i < session.all.length; i++)
		{
			Poker::Card@ card = session.all[i];
			card.targetPosition = Vec2f(screenSize.x * DECK_POSITION.x, screenSize.y * DECK_POSITION.y - session.all.length -i*0.5f );
			card.delay = interval * i;
		}
	}

	void DealCards( Session@ session )
	{
		Vec2f screenSize( getDriver().getScreenWidth(), getDriver().getScreenHeight() );
		const int interval1 = 0;
		_random.Reset(getMap().getMapSeed() + getGameTime());

		// put cards on their positions

		AllCardsOnDeck(session, interval1);

		const int interval2 = 5;

		// for players 

		for (uint playerIt = 0; playerIt < session.players.length; playerIt++)
		{
			Player@ player = session.players[playerIt];
			for (uint cardsIt = 0; cardsIt < START_CARDS; cardsIt++)
			{
				Card@ card = TakeRandomCard(session);
				card.targetPosition = getPlayerCardsPosition( playerIt, cardsIt );
				player.cards.push_back( card );
				card.delay = interval1 * session.all.length + interval2 * (playerIt + playerIt * cardsIt);
			}

			// place chips
			Vec2f lastCardPos = Poker::getPlayerCardsPosition(playerIt, player.cards.length);
			for (uint chipIt = 0; chipIt < player.chips.length; chipIt++) {
				player.chips[chipIt].targetPosition = lastCardPos + Vec2f(chipIt * 4 + 8.0f, 8.0f);
			}
		}

		// deal blinds

		for (uint playerIt = session.dealerPlayer; playerIt < session.dealerPlayer + session.players.length; playerIt++)
		{
			Player@ player = session.players[playerIt % session.players.length];
			// first blind
			if (playerIt == session.dealerPlayer+1){
				if (ChipIn(session, player, session.firstBlind, 60) == 0){
					// fold
				}
			}
			// first blind
			if (playerIt == session.dealerPlayer+2){
				if (ChipIn(session, player, session.secondBlind, 60) == 0){
					// fold
				}
			}
		}

		// for community

		const int interval3 = 30;

		for (uint cardsIt = 0; cardsIt < COMMUNITY_CARDS_START; cardsIt++)
		{
			Card@ card = TakeRandomCard(session);
			card.position = Vec2f(screenSize.x * DECK_POSITION.x, screenSize.y * DECK_POSITION.y - 1.5f*session.all.length);
			card.targetPosition = getCommunityCardsPosition(cardsIt);
			session.community.push_back( card );
			card.delay = 60 + interval1 * session.all.length + interval2 * session.players.length * START_CARDS + interval3 * cardsIt;
		}

		session.currentPlayer = (session.dealerPlayer+2) % session.players.length;
		Poker::Status( session, "Starting new round.");
		NextPlayer(session);

		ResetRound(session);
		session.stake = session.secondBlind;
	}

	int ChipIn( Session@ session, Player@ player, uint amount, const uint delay = 0 )
	{
		if (player.chips.length < amount)
		{
			if (player.chips.length == 0)
				return 0;
			player.due = amount - player.chips.length;
			amount = player.chips.length;
		}
		for (uint i=0; i < amount; i++)
		{
			Chip@ chip = player.chips[0];
			session.chips.push_back( chip );
			player.chips.removeAt(0);
			chip.targetPosition = getCommunityCardsPosition(0) + Vec2f(0*CARD_WIDTH + _random.NextRanged(CARD_HEIGHT), -1.5f*CARD_HEIGHT  + _random.NextRanged(CARD_HEIGHT));
			chip.delay = delay;
		}
		player.inStake += amount;
		return amount;
	}
}