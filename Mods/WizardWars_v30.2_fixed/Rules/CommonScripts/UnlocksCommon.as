//Unlocks related functions. mostly server-side that sync to clients
const int TOTAL_UNLOCKS = 4;

void SetupUnlocks( CRules@ this )
{
	if ( getNet().isServer() )
	{
		dictionary@ current_uSet;
		if ( !this.get( "UnlocksSet", @current_uSet ) )
		{
			print( "** Setting Unlocks Dictionary" );
			dictionary uSet;
			this.set( "UnlocksSet", uSet );
		}
	}
}
 
dictionary@ getUnlocksSet()
{
	dictionary@ uSet;
	getRules().get( "UnlocksSet", @uSet );
	
	return uSet;
}

void setStartingUnlocks( CRules@ this )
{
	//reset properties
	print( "** SetStartingUnlocks routine" );
	dictionary@ unlocksSet = getUnlocksSet();
	/*//causes seg faults
	string[]@ bKeys = unlocksSet.getKeys();
	for ( u8 i = 0; i < bKeys.length; i++ )
	{
		print( bKeys[i] );
		this.set_bool( bKeys[i], false );
	}*/
	
	//unlocksSet.deleteAll();//clear unlocks
	dictionary uSet;
	this.set( "UnlocksSet", uSet );

	print( "** Setting Starting Player Unlocks ");
	
	bool[] defaultUnlocks = getDefaultUnlocks();

	if ( getNet().isServer() )
	{		
		ConfigFile cfg;
		if ( cfg.loadFile("../Cache/WW_UnlocksAccounts.cfg") )
		{
			for ( u8 p = 0; p < getPlayersCount(); ++p )
			{
				CPlayer@ player = getPlayer(p);
				if ( player is null )
					continue;
				
				string playerName = player.getUsername();	
				
				if ( cfg.exists( playerName ) )
				{
					bool[] unlocks;
					cfg.readIntoArray_bool(unlocks, playerName);
					
					server_setPlayerUnlocks( playerName, unlocks );
				}
				else
					server_setPlayerUnlocks( playerName, defaultUnlocks );
			}
		}
		else
		{
			for ( u8 p = 0; p < getPlayersCount(); ++p )
			{
				CPlayer@ player = getPlayer(p);
				if ( player is null )
					continue;
				
				string playerName = player.getUsername();	
				
				server_setPlayerUnlocks( playerName, defaultUnlocks );
			}	
		}
	}
}

//player
bool[] server_getPlayerUnlocks( string name )
{
	if ( getNet().isServer() )
	{
		CRules@ rules = getRules();
		bool[] unlocks;
		for ( u8 i = 0; i < TOTAL_UNLOCKS; ++i )
		{
			unlocks.push_back( rules.get_bool("unlocks" + name + i ) );
			//getUnlocksSet().get( "unlocks" + name + i, unlocks[i] );
			print( "Getting unlock " + i + " as: " + unlocks[i] );
		}
		
		return unlocks;
	}
	
	return getDefaultUnlocks();
}

bool[] client_getPlayerUnlocks( string name )
{
	if ( getNet().isClient() )
	{
		CRules@ rules = getRules();
		bool[] unlocks;
		for ( u8 i = 0; i < TOTAL_UNLOCKS; ++i )
		{
			unlocks.push_back( rules.get_bool("unlocks" + name + i ) );
		}
		
		return unlocks;
	}
	
	return getDefaultUnlocks();
}
 
void server_setPlayerUnlocks( string name, bool[] unlocks )
{
	if ( getNet().isServer() )
	{
		//sync to clients
		CRules@ rules = getRules();
		
		for ( u8 i = 0; i < unlocks.length; ++i )
		{
			print( "Setting unlock " + i + " as: " + unlocks[i] );
			getUnlocksSet().set( "unlocks" + name + i, unlocks[i] );
			rules.set_bool( "unlocks" + name + i, unlocks[i] );
			rules.Sync( "unlocks" + name + i, true );
		}
		
		CPlayer@ player = getPlayerByUsername( name );
		
		ConfigFile cfg;
		cfg.loadFile("../Cache/WW_UnlocksAccounts.cfg");
		
		cfg.addArray_bool(name, unlocks);
		
		cfg.saveFile( "WW_UnlocksAccounts.cfg" );
	}
}

bool[] getDefaultUnlocks()
{
	bool[] defaultUnlocks;
	for ( u8 i = 0; i < TOTAL_UNLOCKS; ++i )
	{
		defaultUnlocks.push_back(false);
	}	
	
	return defaultUnlocks;
}