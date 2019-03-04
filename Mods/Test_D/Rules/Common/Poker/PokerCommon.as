namespace Poker
{
	Random _random;
	// texas hold'em rules
	const int START_CARDS = 2;
	const int COMMUNITY_CARDS_START = 3;
	const int COMMUNITY_CARDS_END = 5;
	const int REQUIRED_PLAYERS = 2;
	Vec2f DECK_POSITION = Vec2f(0.5f, 0.5f);
	Vec2f COMMUNITY_POSITION = Vec2f(0.4f, 0.6f);
	const f32 CARD_WIDTH = 58;
	const f32 CARD_HEIGHT = 92;
	const uint FIRST_BLIND = 1;
	const uint SECOND_BLIND = 2;
	const uint IDLE_KICK_TICKS = 450;
	const uint ROUNDEND_TICKS = 400;

	const SColor CHAT_COLOR(255, 50, 100, 220);

	const string[] SUITS = { "♠", "♣", "♦", "♥" };
	const string[] NUMBERS = { "A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K" };
	const int[] SUIT_SCORES = { 1, 2, 8, 4 };
	const int[] NUMBER_SCORES = { 14, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13 };
	
	const int STRAIGHT_FLUSH = 8000000;                                              // + valueHighCard()
    const int FOUR_OF_A_KIND = 7000000;                                              // + Quads Card Rank
    const int FULL_HOUSE     = 6000000;                                              // + SET card rank
    const int FLUSH          = 5000000;                                              // + valueHighCard()
    const int STRAIGHT       = 4000000;                                              // + valueHighCard()
    const int SET            = 3000000;                                              // + Set card value
    const int TWO_PAIRS      = 2000000;                                              // + High2*14^4+ Low2*14^2 + card
    const int ONE_PAIR       = 1000000;                                              // + high*14^2 + high2*14^1 + low	

	shared enum State
	{
		WAITING_FOR_PLAYERS = 0,
		DEAL_CARDS,
		WAITING_FOR_CHOICE,
		GAME_OVER
	};

	shared class Chip
	{
		uint amount;
		Vec2f position;
		Vec2f targetPosition;
		int delay;
		bool moving;
	};

	shared class Card
	{
		string suit;
		string number;
		string name;
		int rank;
		int suitn;
		Vec2f position;
		Vec2f targetPosition;
		int delay;
		bool moving;
	};

	shared class Player
	{
		CBlob@ blob;
		u16 blob_netid;
		string name;
		string username;
		Chip@[] chips;
		Card@[] cards;
		bool local;
		bool bot;
		uint inStake;
		uint due;
		int idleTime;
		int score;
		string handName;

		int _choiceWaitTime;
	};

	shared class Session
	{
		int id;
		State state;
		Card@[] all;
		Card@[] cards;
		Card@[] community;
		Player@[] players;
		Chip@[] chips;
		uint currentPlayer;
		uint dealerPlayer;
		uint roundEndPlayer;
		uint firstBlind;
		uint secondBlind;
		uint stake;
		string message;
		int roundEndTimer;
	};


	Session@ StartSession( CBlob@ blob )
	{
		CRules@ rules = getRules();
		Session@[]@ sessions;
		rules.get("poker", @sessions);
		// create new array if doesn't exist
		if (sessions is null)
		{
			Session@[] _sessions;
			rules.set("poker", @_sessions);
			rules.get("poker", @sessions);
		}
		
		Session session;
		session.id = 1 + sessions.length;
		for (uint s=0; s < SUITS.length; s++){
		for (uint n=0; n < NUMBERS.length; n++){
				AddCard( session, SUITS[s], NUMBERS[n] );
			}
		}
		AddPlayer( session, blob );
		sessions.push_back( session );

		Session @pSession = sessions[sessions.length-1];
		ResetSession(pSession);
		
		printf("Poker session started");
		return pSession;
	}

	void EndSessionForBlob( CBlob@ blob )
	{
		if (blob !is null){
			blob.set_u16("poker session", 0);
			blob.Untag("requested poker join");
		}
	}

	void EndSessionForPlayer( Session@ session, Player@ player )
	{
		EndSessionForBlob( player.blob );
		QuitPoker( player.username );
		Status( session, player.name + " quit the poker game.");
	}

	void ResetRound( Session@ session )
	{
		session.stake = 0;
		session.roundEndPlayer = (session.dealerPlayer+3) % session.players.length;
	}

	void ResetSession( Session@ session )
	{
		session.firstBlind = FIRST_BLIND;
		session.secondBlind = SECOND_BLIND;
		session.state = WAITING_FOR_PLAYERS;
		session.message = "Waiting for at least " + Poker::REQUIRED_PLAYERS + " POKER players...";
		session.dealerPlayer = session.currentPlayer = 0;
		session.stake = 0;
		session.all.clear();
		session.cards.clear();
		session.community.clear();
		for (uint s=0; s < SUITS.length; s++){
		for (uint n=0; n < NUMBERS.length; n++){
				AddCard( session, SUITS[s], NUMBERS[n] );
			}
		}
	}

	Session@[]@ getSessions( CRules@ rules )
	{
		Session@[]@ sessions;
		rules.get("poker", @sessions);
		return sessions;
	}

	Session@ getSession( CBlob@ blob )
	{
		if (blob is null)
			return null;
		Session@[]@ sessions = getSessions( getRules() );
		if (sessions is null)
			return null;
		for (uint i=0; i < sessions.length; i++){
			Session@ session = sessions[i];
			Player@ player = getPlayerOfBlob( session, blob );
			if (player !is null)
				return session;
		}
		return null;
	}

	Player@ getPlayerOfBlob( Session@ session, CBlob@ blob )
	{
		for (uint i=0; i < session.players.length; i++)
		{
			Player@ player = session.players[i];
			if (player.blob is blob)
				return player;
		}
		return null;
	}

	bool hasLocalPokerSession( CRules@ this )
	{
		Poker::Session@[]@ sessions = Poker::getSessions(this);
		if (sessions is null)
			return false;

		for (uint s = 0; s < sessions.length; s++)
		{
			Poker::Session@ session = sessions[s];

			for (uint i=0; i < session.players.length; i++)
			{
				Poker::Player@ player = session.players[i];
				if (player.local){
					return true;
				}
			}
		}
		return false;
	}

	void LoadCardSprites()
	{
		Vec2f cardsize(32,48);
		u32 cards_frames_wide = 16;

		for (uint s=0; s < SUITS.length; s++){
		for (uint n=0; n < NUMBERS.length; n++){
				AddIconToken( "$" + NUMBERS[n] + SUITS[s],
							  "Sprites/cards.png",
							  cardsize,
							  s*cards_frames_wide + n );
			}
		}

		AddIconToken( "$card", "Sprites/cards.png", cardsize, 64 );
		AddIconToken( "$chip", "Sprites/cig.png", Vec2f(3,16), 0 );
	}

	void AddPlayer( Session@ session, CBlob@ playerBlob )
	{
		if (playerBlob is null)
			return;

		Player player;
		@player.blob = playerBlob;
		player.blob_netid = playerBlob.getNetworkID();
		player.name = playerBlob.getPlayer() !is null ? playerBlob.getPlayer().getCharacterName() : "mook";
		player.username = playerBlob.getPlayer() !is null ? playerBlob.getPlayer().getUsername() : "mook";
		int money = XORRandom(16)+9; // calculate this from items
		// temp // calculate this from items
		for (uint n=0; n < money; n++){
			AddChip( player.chips, session.players.length );
		}
		player.local = playerBlob.isMyPlayer();
		player.bot = playerBlob.isBot() || playerBlob.getBrain() is null;
		player.inStake = player.due = 0;
		player.idleTime = 0;
		session.players.push_back( player );

		playerBlob.set_u16("poker session", session.id);

		Status( session, player.name + ((session.players.length == 1) ? " started a poker game." : " joined the poker game."));
	}

	void SetCardRank( Card@ card )
	{
		for (uint i=0; i<SUITS.length; i++) {
			if (card.suit == SUITS[i])		{
				card.suitn = SUIT_SCORES[i];
				break;
			}
		}
		for (uint i=0; i<NUMBERS.length; i++) {
			if (card.number == NUMBERS[i]){
				card.rank = NUMBER_SCORES[i];
				break;
			}
		}
	}

	void AddCard( Card@[]@ cards, const string suit, const string number )
	{
		Card card;
		card.suit = suit;
		card.number = number;
		card.name = number + suit;
		SetCardRank( card );
		cards.push_back( card );
	}

	void AddCard( Session@ session, const string suit, const string number )
	{
		Card card;
		card.suit = suit;
		card.number = number;
		card.name = number + suit;
		SetCardRank( card );
		Vec2f screenSize( getDriver().getScreenWidth(), getDriver().getScreenHeight() );
		card.position = card.targetPosition = Vec2f(-screenSize.x, -screenSize.y) * 0.5f;
		session.cards.push_back( card );
		session.all.push_back( card );
	}

	void AddChip( Chip@[]@ chips, const uint playerIndex, uint amount = 1 )
	{
		Chip chip;
		chip.amount = amount;
		Vec2f screenSize( getDriver().getScreenWidth(), getDriver().getScreenHeight() );
		chip.position = chip.targetPosition = getPlayerCardsPosition(playerIndex, 0);
		chips.push_back( chip );
	}

	Card@ TakeRandomCard( Session@ session )
	{
		if (session.cards.length == 0){
			warn("Poker: ran out of cards!");
			return null;
		}
		uint index = _random.NextRanged( session.cards.length );
		Card@ card = session.cards[index];
		session.cards.removeAt(index);
		return card;
	}

	bool isGameOver( Session@ session )
	{
		return session.community.length == COMMUNITY_CARDS_END;
	}

	Vec2f getPlayerCardsPosition( const uint playerIndex, const uint index )
	{
		Vec2f screenSize( getDriver().getScreenWidth(), getDriver().getScreenHeight() );
		Vec2f cardsSize( Poker::CARD_WIDTH * START_CARDS / 2.0f, Poker::CARD_HEIGHT * START_CARDS / 2.0f );
		switch (playerIndex)
		{
			case 0:
			return Vec2f(screenSize.x*0.5f + Poker::CARD_WIDTH * index, screenSize.y * 0.9f) - cardsSize;

			case 1:
			return Vec2f(screenSize.x*0.1f, screenSize.y * 0.5f + Poker::CARD_HEIGHT * index) - cardsSize;

			case 2:
			return Vec2f(screenSize.x*0.5f + Poker::CARD_WIDTH * index, screenSize.y * 0.27f) - cardsSize;

			case 3:
			return Vec2f(screenSize.x*0.92f, screenSize.y * 0.5f + Poker::CARD_HEIGHT * index) - cardsSize;
		}
		return screenSize * 0.5f;
	}

	Vec2f getPlayerCardsRectangle( const uint playerIndex )
	{
		return playerIndex % 2 == 0 ? Vec2f( Poker::CARD_WIDTH * Poker::START_CARDS + 7, Poker::CARD_HEIGHT * Poker::START_CARDS / 2.0f + 5 )
									: Vec2f( Poker::CARD_WIDTH * Poker::START_CARDS / 2.0f + 7, Poker::CARD_HEIGHT * Poker::START_CARDS + 5 );
	}

	Vec2f getCommunityCardsPosition(const uint index)
	{
		Vec2f screenSize( getDriver().getScreenWidth(), getDriver().getScreenHeight() );
		return Vec2f(screenSize.x * COMMUNITY_POSITION.x + Poker::CARD_WIDTH * index, screenSize.y * COMMUNITY_POSITION.y);
	}

	void Status( Session@ session, const string &in text )
	{
		client_AddToChat("[Poker] " + text, CHAT_COLOR);
		session.message = text;
	}

	void StatusAdd( Session@ session, const string &in text )
	{
		client_AddToChat("[Poker] " + text, CHAT_COLOR);
		session.message += " " + text;
	}

	void JoinPoker( CBlob@ blob, CBlob@ pokerPlayer )
	{
		CBitStream params;
		params.write_netid( blob.getNetworkID() );
		params.write_netid( pokerPlayer.getNetworkID() );
		getRules().SendCommand( getRules().getCommandID("poker join"), params );
	}

	void QuitPoker( const string &in username )
	{
		CBitStream params;
		params.write_string( username );
		getRules().SendCommand( getRules().getCommandID("poker quit"), params );
	}

	int getPlayerValueHand( Session@ session, Player@ player, string &out handName )
	{
		int highestPlayerScore = 0;
		string name;

		// permuatate over community cards
		Poker::Card@[] cards;
		cards = session.community;
		for (int i=0; i < player.cards.length; i++)
			cards.push_back( player.cards[i] );

		for (int k=0; k < cards.length; k++)
			for (int l=0; l < cards.length; l++)
				if (k != l)
				{
					Poker::Card@[] evaluate;
					evaluate = cards;
					if (cards.length > 5)
					{
						evaluate.removeAt(k);
						if (cards.length > 6)
						{
							if (l < k)
								evaluate.removeAt(l);
							else {
								evaluate.removeAt(l-1);
							}
						}
					}
					int score = Poker::valueHand( @evaluate, name );
					if (score > highestPlayerScore) {
						highestPlayerScore = score;
						handName = name;
					}
				}

		return highestPlayerScore;
	}

	int valueHand( Card@[]@ h, string &out handName )
    {
      if ( isFlush(h) && isStraight(h) )
      {
      	 handName = "a Straight Flush";
         return valueStraightFlush(h);
      }
      else if ( is4s(h) )
      {
      	 handName = "4 of a Kind";
         return valueFourOfAKind(h);
      }
      else if ( isFullHouse(h) )
      {
      	 handName = "a Full House";
         return valueFullHouse(h);
      }
      else if ( isFlush(h) )
      {
      	 handName = "a Flush";
         return valueFlush(h);
      }
      else if ( isStraight(h) )
      {
      	 handName = "a Straight";
         return valueStraight(h);
      }
      else if ( is3s(h) )
      {
      	 handName = "3 of a Kind";
         return valueSet(h);
      }
      else if ( is22s(h) )
      {
         handName = "2 Pair";
         return valueTwoPairs(h);
      }
      else if ( is2s(h) )
      {
      	 handName = "1 Pair";
         return valueOnePair(h);
      }
      else
      {
      	 handName = "a High Card";
         return valueHighCard(h);
      }
    }

    int valueStraightFlush( Card@[]@ h )
    {
      return STRAIGHT_FLUSH + valueHighCard(h);
    }

	int valueFlush( Card@[]@ h )
    {
       return FLUSH + valueHighCard(h);
    }

	int valueStraight( Card@[]@ h )
    {
      return STRAIGHT + valueHighCard(h);
    }
   
   int valueFourOfAKind( Card@[]@ h )
   {
      sortByRank(h);
      return FOUR_OF_A_KIND + h[2].rank;
   }

   /* -----------------------------------------------------------
      valueFullHouse(): return value of a Full House hand

            value = FULL_HOUSE + SetCardRank

      Trick: card h[2] is always a card that is part of
             the 3-of-a-kind in the full house hand
	     There is ONLY ONE hand with a FH of a given set.
      ----------------------------------------------------------- */
   int valueFullHouse( Card@[]@ h )
   {
      sortByRank(h);
      return FULL_HOUSE + h[2].rank;
   }

   /* ---------------------------------------------------------------
      valueSet(): return value of a Set hand

            value = SET + SetCardRank

      Trick: card h[2] is always a card that is part of the set hand
	     There is ONLY ONE hand with a set of a given rank.
      --------------------------------------------------------------- */
   int valueSet( Card@[]@ h )
   {
      sortByRank(h);
      return SET + h[2].rank;
   }

   /* -----------------------------------------------------
      valueTwoPairs(): return value of a Two-Pairs hand

            value = TWO_PAIRS
                   + 14*14*HighPairCard
                   + 14*LowPairCard
                   + UnmatchedCard
      ----------------------------------------------------- */
   int valueTwoPairs( Card@[]@ h )
   {
      int val = 0;
      sortByRank(h);
      if ( h[0].rank == h[1].rank &&
           h[2].rank == h[3].rank )
         val = 14*14*h[2].rank + 14*h[0].rank + h[4].rank;
      else if ( h[0].rank == h[1].rank &&
                h[3].rank == h[4].rank )
         val = 14*14*h[3].rank + 14*h[0].rank + h[2].rank;
      else 
         val = 14*14*h[3].rank + 14*h[1].rank + h[0].rank;

      return TWO_PAIRS + val;
   }

   /* -----------------------------------------------------
      valueOnePair(): return value of a One-Pair hand

            value = ONE_PAIR 
                   + 14^3*PairCard
                   + 14^2*HighestCard
                   + 14*MiddleCard
                   + LowestCard
      ----------------------------------------------------- */
   int valueOnePair( Card@[]@ h )
   {
      int val = 0;
      sortByRank(h);
      if ( h[0].rank == h[1].rank )
         val = 14*14*14*h[0].rank +  
                + h[2].rank + 14*h[3].rank + 14*14*h[4].rank;
      else if ( h[1].rank == h[2].rank )
         val = 14*14*14*h[1].rank +  
                + h[0].rank + 14*h[3].rank + 14*14*h[4].rank;
      else if ( h[2].rank == h[3].rank )
         val = 14*14*14*h[2].rank +  
                + h[0].rank + 14*h[1].rank + 14*14*h[4].rank;
      else
         val = 14*14*14*h[3].rank +  
                + h[0].rank + 14*h[1].rank + 14*14*h[2].rank;

      return ONE_PAIR + val;
   }

   /* -----------------------------------------------------
      valueHighCard(): return value of a high card hand

            value =  14^4*highestCard 
                   + 14^3*2ndHighestCard
                   + 14^2*3rdHighestCard
                   + 14^1*4thHighestCard
                   + LowestCard
      ----------------------------------------------------- */
   int valueHighCard( Card@[]@ h )
   {
      int val;
      sortByRank(h);
      val = h[0].rank + 14* h[1].rank + 14*14* h[2].rank 
            + 14*14*14* h[3].rank + 14*14*14*14* h[4].rank;
      return val;
   }

   /***********************************************************
     Methods used to determine a certain Poker hand
    ***********************************************************/

   /* ---------------------------------------------
      is4s(): true if h has 4 of a kind
              false otherwise
      --------------------------------------------- */
   bool is4s( Card@[]@ h )
   {
      bool a1, a2;

      if ( h.length != 5 )
         return(false);

      sortByRank(h);

      a1 = h[0].rank == h[1].rank &&
           h[1].rank == h[2].rank &&
           h[2].rank == h[3].rank ;

      a2 = h[1].rank == h[2].rank &&
           h[2].rank == h[3].rank &&
           h[3].rank == h[4].rank ;

      return( a1 || a2 );
   }


   /* ----------------------------------------------------
      isFullHouse(): true if h has Full House
                     false otherwise
      ---------------------------------------------------- */
   bool isFullHouse( Card@[]@ h )
   {
      bool a1, a2;

      if ( h.length != 5 )
         return(false);

      sortByRank(h);

      a1 = h[0].rank == h[1].rank &&  //  x x x y y
           h[1].rank == h[2].rank &&
           h[3].rank == h[4].rank;

      a2 = h[0].rank == h[1].rank &&  //  x x y y y
           h[2].rank == h[3].rank &&
           h[3].rank == h[4].rank;

      return( a1 || a2 );
   }



   /* ----------------------------------------------------
      is3s(): true if h has 3 of a kind
              false otherwise

      **** Note: use is3s() ONLY if you know the hand
                 does not have 4 of a kind 
      ---------------------------------------------------- */
   bool is3s( Card@[]@ h )
   {
      bool a1, a2, a3;

      if ( h.length != 5 )
         return(false);

      if ( is4s(h) || isFullHouse(h) )
         return(false);        // The hand is not 3 of a kind (but better)

      /* ----------------------------------------------------------
         Now we know the hand is not 4 of a kind or a full house !
         ---------------------------------------------------------- */
      sortByRank(h);

      a1 = h[0].rank == h[1].rank &&
           h[1].rank == h[2].rank ;

      a2 = h[1].rank == h[2].rank &&
           h[2].rank == h[3].rank ;

      a3 = h[2].rank == h[3].rank &&
           h[3].rank == h[4].rank ;

      return( a1 || a2 || a3 );
   }

   /* -----------------------------------------------------
      is22s(): true if h has 2 pairs
               false otherwise

      **** Note: use is22s() ONLY if you know the hand
                 does not have 3 of a kind or better
      ----------------------------------------------------- */
   bool is22s( Card@[]@ h )
   {
      bool a1, a2, a3;

      if ( h.length != 5 )
         return(false);

      if ( is4s(h) || isFullHouse(h) || is3s(h) )
         return(false);        // The hand is not 2 pairs (but better)

      sortByRank(h);

      a1 = h[0].rank == h[1].rank &&
           h[2].rank == h[3].rank ;

      a2 = h[0].rank == h[1].rank &&
           h[3].rank == h[4].rank ;

      a3 = h[1].rank == h[2].rank &&
           h[3].rank == h[4].rank ;

      return( a1 || a2 || a3 );
   }


   /* -----------------------------------------------------
      is2s(): true if h has one pair
              false otherwise

      **** Note: use is22s() ONLY if you know the hand
                 does not have 2 pairs or better
      ----------------------------------------------------- */
   bool is2s( Card@[]@ h )
   {
      bool a1, a2, a3, a4;

      if ( h.length != 5 )
         return(false);

      if ( is4s(h) || isFullHouse(h) || is3s(h) || is22s(h) )
         return(false);        // The hand is not one pair (but better)

      sortByRank(h);

      a1 = h[0].rank == h[1].rank ;
      a2 = h[1].rank == h[2].rank ;
      a3 = h[2].rank == h[3].rank ;
      a4 = h[3].rank == h[4].rank ;

      return( a1 || a2 || a3 || a4 );
   }


   /* ---------------------------------------------
      isFlush(): true if h has a flush
                 false otherwise
      --------------------------------------------- */
   bool isFlush( Card@[]@ h )
   {
      if ( h.length != 5 )
         return(false);

      sortBySuit(h);

      return( h[0].suitn == h[4].suitn );   // All cards has same suit
   }


   /* ---------------------------------------------
      isStraight(): true if h is a Straight
                    false otherwise
      --------------------------------------------- */
   bool isStraight( Card@[]@ h )
   {
      int i, testRank;

      if ( h.length != 5 )
         return(false);

      sortByRank(h);

      /* ===========================
         Check if hand has an Ace
         =========================== */
      if ( h[4].rank == 14 )
      {
         /* =================================
            Check straight using an Ace
            ================================= */
         bool a = h[0].rank == 2 && h[1].rank == 3 &&
                     h[2].rank == 4 && h[3].rank == 5 ;
         bool b = h[0].rank == 10 && h[1].rank == 11 &&
                     h[2].rank == 12 && h[3].rank == 13 ;

         return ( a || b );
      }
      else
      {
         /* ===========================================
            General case: check for increasing values
            =========================================== */
         testRank = h[0].rank + 1;

         for ( i = 1; i < 5; i++ )
         {
            if ( h[i].rank != testRank )
               return(false);        // Straight failed...

            testRank++;
         }

         return(true);        // Straight found !
      }
   }

   /* ===========================================================
      Helper methods
      =========================================================== */

   /* ---------------------------------------------
      Sort hand by rank:

          smallest ranked card first .... 

      (Finding a straight is eaiser that way)
      --------------------------------------------- */
   void sortByRank( Card@[]@ h )
   {
      int i, j, min_j;

      /* ---------------------------------------------------
         The selection sort algorithm
         --------------------------------------------------- */
      for ( i = 0 ; i < h.length ; i ++ )
      {
         /* ---------------------------------------------------
            Find array element with min. value among
            h[i], h[i+1], ..., h[n-1]
            --------------------------------------------------- */
         min_j = i;   // Assume elem i (h[i]) is the minimum
 
         for ( j = i+1 ; j < h.length ; j++ )
         {
            if ( h[j].rank < h[min_j].rank )
            {
               min_j = j;    // We found a smaller minimum, update min_j     
            }
         }
 
         /* ---------------------------------------------------
            Swap a[i] and a[min_j]
            --------------------------------------------------- */
         Card@ help = h[i];
         @h[i] = h[min_j];
         @h[min_j] = help;
      }
   }

   /* ---------------------------------------------
      Sort hand by suit:

          smallest suit card first .... 

      (Finding a flush is eaiser that way)
      --------------------------------------------- */
   void sortBySuit( Card@[]@ h )
   {
      int i, j, min_j;

      /* ---------------------------------------------------
         The selection sort algorithm
         --------------------------------------------------- */
      for ( i = 0 ; i < h.length ; i ++ )
      {
         /* ---------------------------------------------------
            Find array element with min. value among
            h[i], h[i+1], ..., h[n-1]
            --------------------------------------------------- */
         min_j = i;   // Assume elem i (h[i]) is the minimum
 
         for ( j = i+1 ; j < h.length ; j++ )
         {
            if ( h[j].suitn < h[min_j].suitn )
            {
               min_j = j;    // We found a smaller minimum, update min_j     
            }
         }
 
         /* ---------------------------------------------------
            Swap a[i] and a[min_j]
            --------------------------------------------------- */
         Card@ help = h[i];
         @h[i] = h[min_j];
         @h[min_j] = help;
      }
   }
};