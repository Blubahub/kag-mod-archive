// Game Music

#define CLIENT_ONLY

enum GameMusicTags
{
    world_intro,
    world_home,
    world_calm,
    world_battle,
    world_battle_2,
    world_outro,
    world_quick_out,
};

void onInit( CBlob@ this )
{
    CMixer@ mixer = getMixer();	 
    if (mixer is null) { return; } //prevents aids on server

    mixer.ResetMixer();
    this.set_bool("initialized game", false);
}

void onTick( CBlob@ this )
{
    CMixer@ mixer = getMixer();	   
    if (mixer is null) { return; } //prevents aids on server

    if (s_gamemusic && s_soundon != 0)
    {
        if (!this.get_bool("initialized game")) {
            AddGameMusic( this, mixer );
        }

        GameMusicLogic( this, mixer );
    }
    else
    {
        mixer.FadeOutAll(0.0f, 2.0f);
    }
}

//sound references with tag
void AddGameMusic( CBlob@ this, CMixer@ mixer )
{
	 if (mixer is null) { return; }
    this.set_bool("initialized game", true);
    mixer.AddTrack( "Sounds/Music/KAGWorldIntroShortA.ogg", world_intro );
    mixer.AddTrack( "Sounds/Music/KAGWorld1-1a.ogg", world_home );
    mixer.AddTrack( "Sounds/Music/KAGWorld1-2a.ogg", world_home);
    mixer.AddTrack( "Sounds/Music/KAGWorld1-3a.ogg", world_home );
    mixer.AddTrack( "Sounds/Music/KAGWorld1-4a.ogg", world_home );
    mixer.AddTrack( "Sounds/Music/KAGWorld1-5a.ogg", world_calm );
    mixer.AddTrack( "Sounds/Music/KAGWorld1-6a.ogg", world_calm );
    mixer.AddTrack( "Sounds/Music/KAGWorld1-7a.ogg", world_calm );
    mixer.AddTrack( "Sounds/Music/KAGWorld1-8a.ogg", world_calm );
    mixer.AddTrack( "Sounds/Music/KAGWorld1-9a.ogg", world_home );
    mixer.AddTrack( "Sounds/Music/KAGWorld1-10a.ogg", world_battle );
    mixer.AddTrack( "Sounds/Music/KAGWorld1-11a.ogg", world_battle );
    mixer.AddTrack( "Sounds/Music/KAGWorld1-12a.ogg", world_battle );
    mixer.AddTrack( "Sounds/Music/KAGWorld1-13+Intro.ogg", world_battle_2 );
    mixer.AddTrack( "Sounds/Music/KAGWorld1-14.ogg", world_battle_2 );
    mixer.AddTrack( "Sounds/Music/KAGWorldQuickOut.ogg", world_quick_out );
}

uint timer = 0;

void GameMusicLogic( CBlob@ this, CMixer@ mixer )
{
	 if (mixer is null) { return; }

    //warmup
    CRules @rules = getRules();

    if (rules.isWarmup())
    {
        if (mixer.getPlayingCount() == 0)
        {
            mixer.FadeInRandom( world_home , 0.01);
        }
    }
    //every beat, checks situation for appropriate music
    else if (rules.isMatchRunning())
    {
        timer++;

        if (timer % 32 == 0 || mixer.getPlayingCount() == 0)
        {
            CBlob @blob = getLocalPlayerBlob();

            if (blob is null)
            {
                return;
            }

			CMap@ map = blob.getMap();
			if (map is null) { return; }

            Vec2f pos = blob.getPosition();
            //check blobs around player for various traits
            CBlob@[] potentials;
            map.getBlobsInRadius(pos, 250.0f, @potentials);

            for (uint i=0; i < potentials.length; i++)
            {
				CBlob @potentialBlob = potentials[i];
                if (potentialBlob !is null)
                {
                    if ( potentialBlob.hasTag("player") &&
                            blob.getTeamNum() != potentialBlob.getTeamNum() &&
                            !potentialBlob.hasTag("dead"))
                    {
                        bool hasLineOfSight = !map.rayCastSolid(pos, potentialBlob.getPosition());

                        if (hasLineOfSight || mixer.getLastAddedTag() == world_battle)
                        {
                            changeMusic ( mixer, world_battle );
                            timer = 0;
                            return;
                        }
                    }
                }
            }

            changeMusic ( mixer, world_home );
            timer = 0;
        }
    }
}

// handle fadeouts / fadeins dynamically
void changeMusic( CMixer@ mixer, int nextTrack )
{
	if (mixer is null) { return; }

    if (!mixer.isPlaying (nextTrack ))
    {
        mixer.FadeOutAll(0.0f, 1.6f);
    }

    if ( mixer.getPlayingCount() == 0 )
    {
        mixer.FadeInRandom(nextTrack , 0.01 );
    }
    else
    {
        mixer.FadeInRandom(nextTrack , 1.60 );
    }
}
