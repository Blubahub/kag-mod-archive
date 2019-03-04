// SHOW KILL MESSAGES ON CLIENT

#include "Hitters.as";
#include "FUNHitters.as";
#include "TeamColour.as";
#include "HoverMessage.as";

int fade_time = 300;


class KillMessage
{
    string victim;
    string attacker;
    int attackerteam;
    int victimteam;
    u8 hitter;
    s16 time;

    KillMessage( ) {} //dont use this

    KillMessage( CPlayer@ _victim, CPlayer@ _attacker, u8 _hitter )
    {
        victim = _victim.getCharacterName();
        victimteam = _victim.getTeamNum();

        if (_attacker !is null)
        {
            attacker = _attacker.getCharacterName();
            attackerteam = _attacker.getTeamNum();
			//print("victimteam " + victimteam  + " " + (_victim.getBlob() !is null) + " attackerteam " + attackerteam + " " + (_attacker.getBlob() !is null));
        }
        else
        {
            attacker = "";
            attackerteam = -1;
        }		

        hitter = _hitter;
        time = fade_time;
    }
};

class KillFeed
{
    KillMessage[] killMessages;

    void Update()
    {
        while(killMessages.length > 10)
        {
            killMessages.erase(0);
        }

        for (uint message_step = 0; message_step < killMessages.length; ++message_step)
        {
            KillMessage@ message = killMessages[message_step];
            message.time--;
			
			if(message.time == 0)
				killMessages.erase(message_step--);
        }
    }

    void Render()
    {
		const uint count = Maths::Min( 10, killMessages.length ); 
        for (uint message_step = 0; message_step < count; ++message_step)
        {
            KillMessage@ message = killMessages[message_step];
            Vec2f dim, ul, lr;

            if (message.attackerteam != -1)
            {
                //draw attacker name
				GUI::GetTextDimensions( message.attacker, dim );
                ul.Set( getScreenWidth() - dim.x - 204, (message_step+1) * 16 );
                SColor col = getTeamColor(message.attackerteam);
                GUI::DrawText( message.attacker, Vec2f (ul.x - 8.0, ul.y), col);		  // true, true caches juxta_banner, so we got that bug with wrong team colors
            }

            //draw icon in between based on hitter
            string hitterIcon;

            switch(message.hitter)
            {
            case Hitters::fall:     hitterIcon = "$killfeed_fall$"; break;

            case Hitters::stomp:    hitterIcon = "$killfeed_stomp$"; break;

            case Hitters::builder:  hitterIcon = "$killfeed_builder$"; break;

            case Hitters::sword:    hitterIcon = "$killfeed_sword$"; break;

            case Hitters::shield:   hitterIcon = "$killfeed_shield$"; break;

            case Hitters::bomb:     hitterIcon = "$killfeed_bomb$"; break;

            case Hitters::arrow:    hitterIcon = "$killfeed_arrow$"; break;

            case Hitters::ballista: hitterIcon = "$killfeed_ballista$"; break;
			
			case Hitters::keg: hitterIcon = "$killfeed_keg$"; break;
			
			case Hitters::spikes: hitterIcon = "$killfeed_spikes$"; break;
			
			case Hitters::cata_stones: hitterIcon = "$killfeed_cata_stones$"; break;
			
			case Hitters::fire: hitterIcon = "$killfeed_fire$"; break;
			
			case Hitters::burn: hitterIcon = "$killfeed_fire$"; break;
			
			case Hitters::saw: hitterIcon = "$killfeed_saw$"; break;
			
			case Hitters::suddengib: hitterIcon = "$killfeed_suddengib$"; break;
			
			case Hitters::drown: hitterIcon = "$killfeed_drown$"; break;
			
			//case FUNHitters::boulder: hitterIcon = "$killfeed_boulder$"; break;
			
			//case FUNHitters::cannon: hitterIcon = "$killfeed_cannon$"; break;
			
			case FUNHitters::explosive_trap: hitterIcon = "$killfeed_explosive_trap$"; break;
			
			case FUNHitters::drill: hitterIcon = "$killfeed_drill$"; break;
			
			case FUNHitters::mega_drill: hitterIcon = "$killfeed_mega_drill$"; break;
			
			//case FUNHitters::mega_bomb: hitterIcon = "$killfeed_mega_bomb$"; break;
			
			case FUNHitters::orb: hitterIcon = "$killfeed_orb$"; break;
			
			case FUNHitters::fire_orb: hitterIcon = "$killfeed_fire_orb$"; break;
			
			case FUNHitters::bomb_orb: hitterIcon = "$killfeed_bomb_orb$"; break;
			
			case FUNHitters::water_orb: hitterIcon = "$killfeed_water_orb$"; break;
			
			//case FUNHitters::wooden_spikes: hitterIcon = "$killfeed_wooden_spikes$"; break;
			
			case FUNHitters::chainsaw: hitterIcon = "$killfeed_chainsaw$"; break;
			
			case FUNHitters::bison: hitterIcon = "$killfeed_bison$"; break;
			
			case FUNHitters::shark: hitterIcon = "$killfeed_shark$"; break;
			
			case FUNHitters::zombie: hitterIcon = "$killfeed_zombie$"; break;
			
			case FUNHitters::skeleton: hitterIcon = "$killfeed_skeleton$"; break;
			
			case FUNHitters::chaparral: hitterIcon = "$killfeed_chaparral$"; break;

            default: hitterIcon = "$killfeed_default$";
            }

            if (hitterIcon != "")
            {
                ul.Set( getScreenWidth() - 212, ((message_step+1) * 16) - 8 );
                GUI::DrawIconByName( hitterIcon, ul);
            }

				//draw victim name
			if (message.victimteam != -1)
			{
				GUI::GetTextDimensions( message.victim, dim );
				ul.Set( getScreenWidth() - 164, (message_step+1) * 16 );
				SColor col = getTeamColor(message.victimteam);
				GUI::DrawText( message.victim, Vec2f (ul.x + 8.0, ul.y), col);
			}
        }
    }

};


void onInit( CRules@ this )
{
    AddIconToken( "$killfeed_fall$", "GUI/KillfeedIcons.png", Vec2f(32,16), 1 );
    AddIconToken( "$killfeed_stomp$", "GUI/KillfeedIcons.png", Vec2f(32,16), 4 );
    AddIconToken( "$killfeed_builder$", "GUI/KillfeedIcons.png", Vec2f(32,16), 8 );
    AddIconToken( "$killfeed_axe$", "GUI/KillfeedIcons.png", Vec2f(32,16), 9 );
    AddIconToken( "$killfeed_sword$", "GUI/KillfeedIcons.png", Vec2f(32,16), 12 );
    AddIconToken( "$killfeed_shield$", "GUI/KillfeedIcons.png", Vec2f(32,16), 13 );
    AddIconToken( "$killfeed_bomb$", "GUI/KillfeedIcons.png", Vec2f(32,16), 14 );
    AddIconToken( "$killfeed_arrow$", "GUI/KillfeedIcons.png", Vec2f(32,16), 16 );
    AddIconToken( "$killfeed_ballista$", "GUI/KillfeedIcons.png", Vec2f(32,16), 17 );
	AddIconToken( "$killfeed_fire$", "GUI/KillfeedIcons.png", Vec2f(32,16), 2 );
	AddIconToken( "$killfeed_catapult$", "GUI/KillfeedIcons.png", Vec2f(32,16), 7 );
	AddIconToken( "$killfeed_cata_stones$", "GUI/KillfeedIcons.png", Vec2f(32,16), 11 );
	AddIconToken( "$killfeed_saw$", "GUI/KillfeedIcons.png", Vec2f(32,16), 10 );
	AddIconToken( "$killfeed_spikes$", "GUI/KillfeedIcons.png", Vec2f(32,16), 15 );
	AddIconToken( "$killfeed_keg$", "GUI/KillfeedIcons.png", Vec2f(32,16), 18 );
	AddIconToken( "$killfeed_suddengib$", "GUI/KillfeedIcons.png", Vec2f(32,16), 19 );
	AddIconToken( "$killfeed_boulder$", "GUI/KillfeedIcons.png", Vec2f(32,16), 3 );
	AddIconToken( "$killfeed_cannon$", "GUI/KillfeedIcons.png", Vec2f(32,16), 6 );
	AddIconToken( "$killfeed_explosive_trap$", "GUI/KillfeedIcons.png", Vec2f(32,16), 0 );
	AddIconToken( "$killfeed_drill$", "GUI/KillfeedIcons.png", Vec2f(32,16), 20 );
	AddIconToken( "$killfeed_mega_drill$", "GUI/KillfeedIcons.png", Vec2f(32,16), 21 );
	AddIconToken( "$killfeed_mega_bomb$", "GUI/KillfeedIcons.png", Vec2f(32,16), 22 );
	AddIconToken( "$killfeed_orb$", "GUI/KillfeedIcons.png", Vec2f(32,16), 24 );
	AddIconToken( "$killfeed_fire_orb$", "GUI/KillfeedIcons.png", Vec2f(32,16), 25 );
	AddIconToken( "$killfeed_bomb_orb$", "GUI/KillfeedIcons.png", Vec2f(32,16), 26 );
	AddIconToken( "$killfeed_water_orb$", "GUI/KillfeedIcons.png", Vec2f(32,16), 27 );
	AddIconToken( "$killfeed_wooden_spikes$", "GUI/KillfeedIcons.png", Vec2f(32,16), 23 );
	AddIconToken( "$killfeed_chainsaw$", "GUI/KillfeedIcons.png", Vec2f(32,16), 28 );
	AddIconToken( "$killfeed_default$", "GUI/KillfeedIcons.png", Vec2f(32,16), 29 );
	AddIconToken( "$killfeed_drown$", "GUI/KillfeedIcons.png", Vec2f(32,16), 30 );
	AddIconToken( "$killfeed_shark$", "GUI/KillfeedIcons.png", Vec2f(32,16), 32 );
	AddIconToken( "$killfeed_bison$", "GUI/KillfeedIcons.png", Vec2f(32,16), 33 );
	AddIconToken( "$killfeed_zombie$", "GUI/KillfeedIcons.png", Vec2f(32,16), 34 );
	AddIconToken( "$killfeed_skeleton$", "GUI/KillfeedIcons.png", Vec2f(32,16), 35 );
	AddIconToken( "$killfeed_chaparral$", "GUI/KillfeedIcons.png", Vec2f(32,16), 31 );
}

void onRestart( CRules@ this )
{
    KillFeed feed;
    this.set( "KillFeed", feed );
}

void onPlayerDie( CRules@ this, CPlayer@ victim, CPlayer@ killer, u8 customdata )
{
    if (victim !is null)
    {
        KillFeed@ feed;
        if (this.get( "KillFeed", @feed ))
        {
            KillMessage message = KillMessage(victim, killer, customdata);
            feed.killMessages.push_back(message);
        }
						
		// hover message


		if (killer !is null)
		{
			CBlob@ killerblob = killer.getBlob();
			CBlob@ victimblob = victim.getBlob();
			if (killerblob !is null && victimblob !is null && killerblob.isMyPlayer() && killerblob !is victimblob)
			{
				if (!killerblob.exists("messages")) {
					HoverMessage[] messages;
					killerblob.set( "messages", messages);
				}
	
				HoverMessage[]@ messages;		   
				if (killerblob.get("messages",@messages))
				{
						HoverMessage m( victimblob.getInventoryName(), 1, SColor(255, 255, 20,20), 75, 2, false);
						killerblob.push("messages",m);
				}
			}
		}
    }
}

void onTick( CRules@ this )
{
    KillFeed@ feed;

    if (this.get( "KillFeed", @feed ))
    {
        feed.Update();
    }
}

void onRender( CRules@ this )
{
    KillFeed@ feed;

    if (this.get( "KillFeed", @feed ))
    {
        feed.Render();
    }
}
