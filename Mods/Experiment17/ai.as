string botName = "Henry";
string jsonMarker = "[-AI-]";
string jsonMarkerEnd = "[/-AI-]";
string jsonMarker2 = "[-AI-AGENT-]";
string jsonMarkerEnd2 = "[/-AI-AGENT-]";

// this is the logic for the ai which runs every tick for its blob, if it exists.
void runBotTick(CPlayer@ botPlayer) {
    if (botPlayer == null || botPlayer.getUsername() != botName) {
        return;
    }
    // print("Running for "+botPlayer.getUsername());
    printJson(jsonMarker2, jsonMarkerEnd2, 0.5);

    // botkey, which, as long as tagged, indicates the key the neural net has chosen to execute.
    // this may not change every tick, depending on the update frequency, but the keypresses have to be consistent.
    // so i wrote this to keep pressing that suggested key.
    // expand into multiple keys later maybe? (two movement, one attack perhaps?)
    CBlob@ botBlob = botPlayer.getBlob();
    if (botBlob == null) { return; }
    if (botBlob.get_u32("botkey") != -1) {
        u32 botkey = botBlob.get_u32("botkey");
        print("botkey: "+botkey);
        if (botkey == key_left) {
            botBlob.setKeyPressed(key_left, true);
            print('active key: left');
        }
        else if (botkey == key_right) {
            botBlob.setKeyPressed(key_right, true);
            print('active key: right');
        }
        else if (botkey == key_down) {
            botBlob.setKeyPressed(key_down, true);
            print('active key: down');
        }
        else if (botkey == key_up) {
            botBlob.setKeyPressed(key_up, true);
            print('active key: up');
        }
    }
}


void onNewPlayerJoin( CRules@ this, CPlayer@ player ) {
    if (player !is null) {
       print("Welcome "+player.getUsername()+"!");
       if ( player.getUsername() == botName) {
            print("I have arrived!");
       }
    }
}

// death is a learning moment. ;-)
void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ killer, u8 customData)
{
	if (!getNet().isServer() || getPlayerByUsername(botName) == null)
		return;

    float score = 0.5;

    if (victim.getUsername() == botName) {
        print('Was killed! :-(');
        score = 0.0;
    }
    else if (killer != null && killer.getUsername() == botName) {
        print('Killed a dude! :-)');
        score = 1.0;
    }

    printJson(jsonMarker, jsonMarkerEnd, score);

}

void printJson(string starter, string ender, float score)
{
    CBlob@ botBlob = getPlayerByUsername(botName).getBlob();
    if (botBlob == null) { return; }

    float healthScore = botBlob.getHealth() / botBlob.getInitialHealth();
    if (healthScore < 0) {healthScore = 0;}
    if (healthScore > 1) {healthScore = 1;}
    print('healthScore : '+healthScore);
    score = (score + healthScore) / 2;
    print('newScore : '+score);

    const bool left		= botBlob.isKeyPressed(key_left);
    const bool right	= botBlob.isKeyPressed(key_right);
    const bool up		= botBlob.isKeyPressed(key_up);
    const bool down		= botBlob.isKeyPressed(key_down);

    //wasKeyPressed expansion?

    Vec2f botPos = botBlob.getPosition();

    print(starter + " { ");
    print("\"score\" : "+score+", ");
    print("\"keys\" : { \"u\": " +up+ ", \"d\": "+down+", \"r\": "+right+", \"l\": "+left+" },");
    print("\"players\" : {");

    for (int i=0; i<getPlayerCount(); ++i) {
        CBlob@ blob = getPlayer(i).getBlob();
        if (blob == null) { continue; }
        Vec2f pos = blob.getPosition();
        print("\""+i+"\":");
        string hostile = "";
        if(blob.getPlayer().getTeamNum() == getPlayerByUsername(botName).getTeamNum()) {
            hostile=0;
        }
        else {
            hostile=1;
        }

        // distance
        Vec2f distance = Vec2f(botPos.x - pos.x, botPos.y - pos.y);

        // send the result to the neural net.
        print("{ \"hostile"+i+"\": "+hostile+", \"dx"+i+"\": "+ distance.x + ", \"dy"+i+"\": "+distance.y+" }");
        if (i<getPlayerCount()-1) { print(","); }
        }
    print("} } "+ender);
}

/*


    we can add to the bot a script

    this script will go off every tick (ontick)

    it will remember past state, and compare (such as health, velocity, and so on)

    it will detect a few events which will be marked as a success

    NORMALIZATION:

  data going into the neural net:
    - distance to all friendly and hostile blobs

    V 1. get data
    V 2. feed to net (how? file out?)

  data coming out:

    3. should be an array of four numbers, each of the four being a key (up, down, right left) to push

    - based on evaluation function.
        evaluation function:
            0 - 1: ratings for: 1 killed enemy 2 being near enemy (0.5)
    score = success rate

    ------------

    up vote
3
down vote
accepted
While this is not a complete answer, the basic principle goes:

Where the outcome is unpredictable, current state + possible moves = outcome. so, for any given state (in the case of having a certain number/combination of cards, possibly in combination with others having a number of unknown cards, or certain cards having been seen since the last shuffle) of the game, there are a number of possible moves you can do (hit, stand). You would then try either one, and record if that gives you a good or a bad (or somewhere in between) outcome. Next time you see the same current state, you see which possible move gave you the best statistical outcome so far (with a % of randomness).

Where the out

If you have multiple moves, and you don't get an actual result until the end, you would keep a track of all (state+tried move) so far; once you get a result, you apply that to every step along the way.

Once this is done, you get it to play a huge number of games, and it should get better as it goes.

The trick, usually, is to work out what constitutes a "state". The more possible states there are, the more games have to be played before the AI gets good, and the larger your database will be. In blackjack, you might have a state of just the sum of the number of cards (which gives you 20 states), or it might include how many of those are aces (which gives you, I guess, maybe, around about 40 states); it might include how many cards other players have; it might include exactly which values you have in your hand but not the suit (if you have 4 aces, you know noone else has an ace), or might include (pointlessly for Blackjack) the order a suit of the cards.

In some cases, the "state" might be more abstract. For example, in the case of chess, there are many possible "states" to learn them all, and we have to abstract. I don't know what's usually used for this; perhaps what is attacking what and what is defending what, how many squares are covered by how many pieces, which pieces are defended by what, etc.; or

You might also want to consider what constitutes "good" and "bad" outcomes. You might assume that, for blackjack, a win is good, and a loss is bad, and that's all there is to it. However, there is something to be avoided more than losing: making an invalid move. In the example of blackjack, assuming your AI does not know the rules, splitting if you have any hand other than a pair, is something far worse than (possibly) losing. If you count this as a "loss", it would eventually get the hint and stop doing that.

*/
