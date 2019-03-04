// Balance: LappelDuVide script

void onInit(CBlob@ this)
{
    this.set_u8("phaseTimer", 0);
    this.getCurrentScript().runFlags |= Script::tick_myplayer;
}

void onTick(CBlob@ this)
{
    if ( (this.isKeyJustReleased(key_down)) || ( (this.isOnGround()) && ( (this.isKeyPressed(key_left)) || (this.isKeyPressed(key_right)) ) ) )
    {
        Reset(this);
    }
    else if ( (this.isKeyPressed(key_down)) && (!this.hasTag("LappelDuVide")) )
    {
        u8 phaseTimer = this.get_u8("phaseTimer");
        if (phaseTimer < 6)
        {
            phaseTimer++;
            this.set_u8("phaseTimer", phaseTimer);
        }
        else
        {
            this.Tag("LappelDuVide");
            //print("Activate");
        }
        //print("phaseTimer : " +phaseTimer);
    }
}

void Reset(CBlob@ this)
{
    if (this.hasTag("LappelDuVide"))
    {
        this.Untag("LappelDuVide");
    }
    this.set_u8("phaseTimer", 0);
    //print("Reset");
}