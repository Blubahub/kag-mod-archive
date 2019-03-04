#include "PokerCommon.as"
#include "PokerTexas.as"
#include "Menus.as"

void onInit( CRules@ this )
{
	this.addCommandID("poker join");
	this.addCommandID("poker quit");
	Poker::LoadCardSprites();

	onReload( this );
}

void onReload( CRules@ this )
{
	// printf("---------------------RANK");
	
	// {
	// 	string name;
	// 	Poker::Card@[] cards;
	// 	Poker::AddCard( @cards, "♦", "4");
	// 	Poker::AddCard( @cards, "♥", "4");
	// 	Poker::AddCard( @cards, "♥", "8");
	// 	Poker::AddCard( @cards, "♥", "10");
	// 	Poker::AddCard( @cards, "♣", "7");
	// 	int score = Poker::valueHand( @cards, name );
	// 	printf("RANK score " + score + " = " + name);
	// }
	// {
	// 	string name;
	// 	Poker::Card@[] cards;
	// 	Poker::AddCard( @cards, "♣", "6");
	// 	Poker::AddCard( @cards, "♠", "K");
	// 	Poker::AddCard( @cards, "♥", "8");
	// 	Poker::AddCard( @cards, "♥", "10");
	// 	Poker::AddCard( @cards, "♣", "7");
	// 	int score = Poker::valueHand( @cards, name );
	// 	printf("RANK score " + score + " = " + name);
	// }

	// {
	// 	Poker::Card@[] cards;
	// 	Poker::AddCard( @cards, "♠", "4");
	// 	Poker::AddCard( @cards, "♥", "4");
	// 	Poker::AddCard( @cards, "♥", "8");
	// 	Poker::AddCard( @cards, "♥", "10");
	// 	Poker::AddCard( @cards, "♣", "7");
	// 	Poker::AddCard( @cards, "♣", "6");
	// 	Poker::AddCard( @cards, "♣", "2");

	// 	int score = 0;
	// 	int highestPlayerScore = 0;
	// 	string name;
	// 	string highestName;

	// 	for (int k=0; k < cards.length; k++)
	// 		for (int l=0; l < cards.length; l++)
	// 			if (k != l)
	// 			{
	// 				Poker::Card@[] evaluate;
	// 				evaluate = cards;
	// 				evaluate.removeAt(k);
	// 				if (l < k)
	// 					evaluate.removeAt(l);
	// 				else {
	// 					evaluate.removeAt(l-1);
	// 				}
	// 				score = Poker::valueHand( @evaluate, name );
	// 				printf("score " + score);
	// 				if (score > highestPlayerScore) {
	// 					highestPlayerScore = score;
	// 					highestName = name;
	// 				}
	// 			}
	// 	printf("highest score " + highestPlayerScore + " = " + highestName);
	// }
}

void onTick( CRules@ this )
{
	Poker::Session@[]@ sessions = Poker::getSessions(this);
	if (sessions is null)
		return;
	Vec2f screenSize( getDriver().getScreenWidth(), getDriver().getScreenHeight() );
	Vec2f center = getDriver().getScreenCenterPos();
	const u32 gametime = getGameTime();

	for (uint s = 0; s < sessions.length; s++)
	{
		Poker::Session@ session = sessions[s];

		// update players

		for (uint i=0; i < session.players.length; i++)
		{
			Poker::Player@ player = session.players[i];
			bool kick = false;

			// is blob alive = still?

			CBlob@ blob = getBlobByNetworkID(player.blob_netid);
			if (blob is null){
				kick = true;
				@player.blob = null;
			}

			// idle kick

			if (i == session.currentPlayer){
				player.idleTime++;
				if (player.idleTime >= Poker::IDLE_KICK_TICKS){
					printf("Poker: " + player.name + " is idle");
					kick = true;
				}
			}

			// local

			if (player.local){
				// quit
				if (getControls().ActionKeyPressed(AK_ACTION2)){
					kick = true;
				}
				// scrolling text
				this.set_string("scrolling text", session.message);

			}

			// remove player

			if (kick)
			{
				printf("Poker: Removing " + player.name);
				Poker::EndSessionForPlayer( session, player );
				session.players.removeAt(i);

				if (session.players.length > 0)
				{
					if (i == session.currentPlayer){
						Poker::NextPlayer(session);
						session.currentPlayer = (session.currentPlayer+1) % session.players.length;
					}
					if (i == session.dealerPlayer){
						session.dealerPlayer = (session.dealerPlayer+1) % session.players.length;
					}
					if (i == session.roundEndPlayer){
						session.roundEndPlayer = (session.roundEndPlayer+1) % session.players.length;
					}
				}
				i = 0;
			}
		}

		// end session  - no players

		bool allBots = true;
		for (uint i=0; i < session.players.length; i++)
		{
			if (!session.players[i].bot){
				allBots = false;
				break;
			}
		}

		if (session.players.length == 0 || allBots)
		{
			printf("Poker game ended " + (allBots ? ". All bots." : " No players."));
			for (uint i=0; i < session.players.length; i++)	{
				Poker::EndSessionForBlob(session.players[i].blob);
			}
			sessions.removeAt(s);
			s = 0;
			break;
		}

		// fallback to waiting

		if (session.players.length < Poker::REQUIRED_PLAYERS){
			session.state = Poker::WAITING_FOR_PLAYERS;
		}

		// states

		switch (session.state)
		{
			case Poker::WAITING_FOR_PLAYERS:

				if (session.players.length >= Poker::REQUIRED_PLAYERS)
				{
					session.state = Poker::DEAL_CARDS;
					session.currentPlayer = 0;
				}
			break;

			case Poker::DEAL_CARDS:

				Poker::DealCards( session );
				session.state = Poker::WAITING_FOR_CHOICE;
				Menus::Clear(getLocalPlayer());
			break;

			case Poker::WAITING_FOR_CHOICE:

				Poker::WaitForChoice( session );
			break;

			case Poker::GAME_OVER:

				if (session.roundEndTimer > 0){
					session.roundEndTimer--;

					if (session.roundEndTimer == 60){
						Poker::AllCardsOnDeck(session, 1);
					}

					if (session.roundEndTimer == 0){
						Poker::ResetSession( session );
					}
				}
			break;
		}

		// update cards

		for (uint i=0; i < session.all.length; i++)
		{
			UpdateCard( session.all[i] );
		}

		// update chips

		for (uint i=0; i < session.chips.length; i++){
			UpdateChip( session.chips[i] );
		}
		for (uint playerIt=0; playerIt < session.players.length; playerIt++)
		{
			Poker::Player@ player = session.players[playerIt];
			for (uint i=0; i < player.chips.length; i++){
				UpdateChip( player.chips[i] );
			}
		}
	}
}

void onCommand( CRules@ this, u8 cmd, CBitStream @params )
{
    CPlayer@ player;
    string group, caption;

    if (cmd == this.getCommandID("poker join"))
    {
    	CBlob@ blob = getBlobByNetworkID( params.read_netid() );
    	CBlob@ pokerPlayer = getBlobByNetworkID( params.read_netid() );
   		Poker::Session@ session = Poker::getSession( pokerPlayer );
		if (blob !is null && session !is null)
    	{
    		blob.Untag("requested poker join"); // UNSAFE, THIS WONT GO AWAY OF BLOB IS DEAD
    		blob.set_u16("poker session", session.id );
    		Poker::AddPlayer( session, blob );
    	}
    }
    else if (cmd == this.getCommandID("poker quit"))
    {
    	string username = params.read_string();
    	CPlayer@ player = getPlayerByUsername(username);
    	if (player !is null){
    		Poker::EndSessionForBlob( player.getBlob() );
    		if (player.isLocal()){
    			Menus::Clear(player, "poker");
    		}
    	}
   		
    }
    else if (Menus::ReadButtonCommand( this, cmd, params, player, group, caption ))
    {
        if (group == "poker")
        {
        	CBlob@ blob = player.getBlob();
        	Poker::Session@ session = Poker::getSession( blob );
        	if (session !is null)
        	{
	            if (caption == "Call")
	            {
	            	Poker::Call(session);
	           		Poker::NextPlayer(session);
	            }
	            else if (caption == "Raise")
	            {
	            	Poker::Raise(session);
	           		Poker::NextPlayer(session);
	            }
	            else if (caption == "Fold")
	            {
	            	Poker::Status( session, player.getCharacterName() + " has folded.");
	           		Poker::NextPlayer(session);
	            }
        	}

       		if (player.isLocal())
       			Menus::Clear(player, "poker");
        }
    }
}


void UpdateCard( Poker::Card@ card )
{
	card.moving = true;
	if (card.delay > 0){
		card.delay--;
	}
	else 
	{
		Vec2f vector = card.targetPosition - card.position;
		f32 dist = vector.Normalize();
		if (dist > 2.0f)
		{
			card.position += vector * Maths::Max( dist * dist * 0.001f, 2.0f);
		}
		else {
			card.position = card.targetPosition;
			card.moving = false;
		}
	}
}

void UpdateChip( Poker::Chip@ chip )
{
	chip.moving = true;
	if (chip.delay > 0){
		chip.delay--;
	}
	else 
	{
		Vec2f vector = chip.targetPosition - chip.position;
		f32 dist = vector.Normalize();
		if (dist > 5.0f)
		{
			chip.position += vector / Maths::Max( 150.0f, Maths::Min(dist,200.0f) ) * 1500.0f;
		}
		else {
			chip.position = chip.targetPosition;
			chip.moving = false;
		}
	}
}

void onRender( CRules@ this )
{
	if (this.get_s16("in menu") > 0)
		return;
	CBlob@ blob = getLocalPlayerBlob();
	Poker::Session@ session = Poker::getSession( blob );
	if (session is null)
		return;

	Vec2f screenSize( getDriver().getScreenWidth(), getDriver().getScreenHeight() );
	Vec2f center = getDriver().getScreenCenterPos();
	const u32 gametime = getGameTime();
	const bool blink = (gametime % 22 < 16);

	if (session.state == Poker::WAITING_FOR_PLAYERS)
	{
		// draw flying cards

		for (uint i=0; i < session.all.length; i++)
		{
			Poker::Card@ card = session.all[i];
			const f32 t = gametime * (0.01f - Maths::Cos(gametime*0.001f)*0.001f) + i;
			card.targetPosition = center + Vec2f(0, -40) + Vec2f(Maths::Cos(t), Maths::Sin(t))*screenSize.y*0.5f*Maths::Sin(gametime * 0.1f + i*Maths::Cos(gametime*0.001f));
			GUI::DrawIconByName( "$"+card.name, card.position );
		}
	}

	if (session.state == Poker::WAITING_FOR_CHOICE || session.state == Poker::GAME_OVER)
	{
		// draw active player

		if (blink)
		{
			Vec2f playerPos = Poker::getPlayerCardsPosition(session.currentPlayer, 0);
			GUI::DrawRectangle( playerPos, playerPos + Poker::getPlayerCardsRectangle(session.currentPlayer), Menus::SELECT_COLOR );
		}

		// draw deck

		for (uint i=0; i < session.cards.length; i++)
		{
			Poker::Card@ card = session.cards[i];
			GUI::DrawIconByName( "$card", card.position );
		}

		// draw community cards

		for (uint i=0; i < session.community.length; i++)
		{
			Poker::Card@ card = session.community[i];
			GUI::DrawIconByName( !card.moving ? "$"+card.name : "$card", card.position );
		}

		// draw player cards
		
		for (uint playerIt=0; playerIt < session.players.length; playerIt++)
		{
			Poker::Player@ player = session.players[playerIt];
			for (uint i=0; i < player.cards.length; i++)
			{
				Poker::Card@ card = player.cards[i];
				GUI::DrawIconByName( ((player.local || session.state == Poker::GAME_OVER) && !card.moving) ? "$"+card.name : "$card", card.position );
			}

			// draw player names

			Vec2f playerPos = Poker::getPlayerCardsPosition(playerIt, 0);
			GUI::DrawText( player.name, playerPos+Vec2f(0, -15), session.currentPlayer == playerIt ? Menus::SELECT_COLOR : color_white );
		}


		// draw chips

		for (uint playerIt=0; playerIt < session.players.length; playerIt++)
		{
			Poker::Player@ player = session.players[playerIt];
			for (uint i=0; i < player.chips.length; i++){
				GUI::DrawIconByName( "$chip", player.chips[i].position );
			}
		}
		for (uint i=0; i < session.chips.length; i++){
			GUI::DrawIconByName( "$chip", session.chips[i].position );
		}
	}

	GUI::DrawText( session.message, Vec2f(screenSize.x * Poker::DECK_POSITION.x-150, screenSize.y * Poker::DECK_POSITION.y - session.all.length*2.0f ), color_white );
}