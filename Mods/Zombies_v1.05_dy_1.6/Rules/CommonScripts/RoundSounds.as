

void onInit(CRules@ this)
{
    this.set_s32("bossroundtag", 0);
    this.set_s32("losetag", 1);
    this.set_s32("wintag", 1);
}

void onRestart(CRules@ this)
{
    this.set_s32("bossroundtag", 0);
    this.set_s32("losetag", 1);
    this.set_s32("wintag", 1);
}

void onTick(CRules@ this)
{
            //this.set_s32(tagname, true);
        int gamestart = this.get_s32("gamestart");
        int day_cycle = this.daycycle_speed * 60;
        int dayNumber = ((getGameTime()-gamestart)/getTicksASecond()/day_cycle)+1;
        int bossRound = this.get_s32("bossRound");
        s32 mapRecord = this.get_s32("mapRecord");
        int bossroundtag = this.get_s32("bossroundtag");
        int wintag = this.get_s32("wintag");
        int losetag = this.get_s32("losetag");
        this.Sync("bossRound", true);
        this.Sync("wintag", true);
        this.Sync("losetag", true);
        this.Sync("bossroundtag", true);
        if (bossRound == 1 && bossroundtag == 1)
        {
           
             CPlayer@ localplayer = getLocalPlayer();
            if (localplayer !is null)
            {
                Sound::Play( "/BossRoundSound.ogg" );
            }
                 this.set_s32("bossroundtag", 0);
            
        }
        else if (bossRound == 0)
             this.set_s32("bossroundtag", 1);
        if (dayNumber < mapRecord)
        {
            //printf("dayNumber = "+dayNumber+" mapRecord = "+mapRecord);
            if (this.isGameOver() && dayNumber < mapRecord && losetag == 1)
            {
                CPlayer@ localplayer = getLocalPlayer();
                if (localplayer !is null)
                {
                    Sound::Play( "/LoseSound.ogg" );
                }
                this.set_s32("losetag", 0);
            }
        }

        if (this.isGameOver() && dayNumber >= mapRecord && wintag == 1)
        {
            CPlayer@ localplayer = getLocalPlayer();
            if (localplayer !is null)
            {
                Sound::Play( "/FanfareWin.ogg" );
            }
            this.set_s32("wintag", 0);
        }

}
