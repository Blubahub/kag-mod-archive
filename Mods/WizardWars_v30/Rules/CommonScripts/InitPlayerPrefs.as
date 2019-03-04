#include "PlayerPrefsCommon.as";
#include "Platinum.as";

void onInit( CRules@ this )
{
	this.addCommandID("load playerPrefs");
	
	CPlayer@ localPlayer = getLocalPlayer();
	if (localPlayer is null)
	{
		return;
	}
	
	u16 callerID = localPlayer.getNetworkID();

	CBitStream params;
	params.write_u16(callerID);
	
	this.SendCommand(this.getCommandID("load playerPrefs"), params);
	
	setStartingPlatinum( this );
}

void onNewPlayerJoin( CRules@ this, CPlayer@ player )
{
	string pName = player.getUsername();
	u16 pPlatinum = server_getPlayerPlatinum( pName );
	
	if ( getNet().isServer() )
	{		
		ConfigFile cfg;
		if ( cfg.loadFile("../Cache/WW_Accounts.cfg") )
		{
			if ( cfg.exists( pName ) )
			{
				u32 platinum = cfg.read_u32(pName);
				
				server_setPlayerPlatinum( pName, platinum );
			}
			else
				server_setPlayerPlatinum( pName, 0 );
		}
	}
}

void onRestart( CRules@ this )
{
	setStartingPlatinum( this );
}

void onTick(CRules@ this)
{
	CPlayer@ localPlayer = getLocalPlayer();
	if (localPlayer is null)
	{
		return;
	}
	
	PlayerPrefsInfo@ playerPrefsInfo;
	if ( !localPlayer.get("playerPrefsInfo", @playerPrefsInfo) )
	{
		u16 callerID = localPlayer.getNetworkID();

		CBitStream params;
		params.write_u16(callerID);
		
		this.SendCommand(this.getCommandID("load playerPrefs"), params);
	}
	else if ( playerPrefsInfo.infoLoaded == false )
	{
		loadHotbarAssignments( localPlayer, "wizard" );
		loadHotbarAssignments( localPlayer, "necromancer" );
		
		playerPrefsInfo.infoLoaded = true;
	}
	else
		ManageCooldowns(playerPrefsInfo);
}

void ManageCooldowns(PlayerPrefsInfo@ playerPrefsInfo)
{
	int ticksPerSec = getTicksASecond();
	
	if (getGameTime() % ticksPerSec == 0)
	{
		for (uint i = 0; i < MAX_SPELLS; ++i)
		{
			s8 currCooldown = playerPrefsInfo.spell_cooldowns[i];
			
			if ( currCooldown > 0 )
				playerPrefsInfo.spell_cooldowns[i] = Maths::Max( currCooldown - 1, 0 );
		}
	}
}

void onCommand( CRules@ this, u8 cmd, CBitStream @params )
{
	if (this.getCommandID("load playerPrefs") == cmd)
	{
		u16 playerID = params.read_u16();
		
		CPlayer@ player = getPlayerByNetworkId(playerID);
		if ( player is null )
			return;
			
		PlayerPrefsInfo playerPrefsInfo;
		player.set( "playerPrefsInfo", @playerPrefsInfo );
		
		print("playerPrefs set");
	}
}