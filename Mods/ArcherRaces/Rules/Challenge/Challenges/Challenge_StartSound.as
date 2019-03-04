#define CLIENT_ONLY

bool done = false;

void onTick(CRules@ this)
{
    if(done) return;

    if(this.isWarmup() || this.isIntermission())
    {
        u8 warmupSecond = this.get_u8("warmupSecond");
        if(warmupSecond == 1 || warmupSecond == 2 || warmupSecond == 3)
        {
            Sound::Play("/depleting.ogg");
        }
    }
    else
    {
        Sound::Play("/fallbig.ogg");
        done = true;
    }
}

void Reset(CRules@ this)
{
    done = false;
}

void onRestart(CRules@ this)
{
	Reset(this);
}

void onInit(CRules@ this)
{
	Reset(this);
}
