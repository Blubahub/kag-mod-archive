
const string tagname = "played fanfare";

void onInit( CRules@ this )
{
Sound::Play( "/ReadyGo.ogg" );
}

void onRestart(CRules@ this)
{
    this.set_bool(tagname, false);
	Sound::Play( "/ReadyGo.ogg" );
}

void onTick(CRules@ this)
{
    if (this.isGameOver() && this.getTeamWon() >= 0 && !this.get_bool(tagname))
    {
        // only play for winners
        CPlayer@ localplayer = getLocalPlayer();
        if (localplayer !is null)
        {
			CBlob@ playerBlob = getLocalPlayerBlob();
			int teamNum = playerBlob !is null ? playerBlob.getTeamNum() : localplayer.getTeamNum() ; // bug fix (cause in singelplayer player team is 255) 
            if (this.getTeamWon() == 1) {
                Sound::Play( "/BlueTeamWins.ogg" );
            }
            else {
                Sound::Play( "/RedTeamWins.ogg" );
            }
        }

        this.set_bool(tagname, true);
        // no sound played on spectator or tie
    }
}
