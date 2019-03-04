const string config_path = "../Mods/Editor/Settings/EditorConfig.cfg";
const string config_param = "users";

// config
string[] users;

void onRestart( CRules@ this )
{
	if(getNet().isServer())
	{
        LoadUsers(this);
    }
}

void LoadUsers( CRules@ this )
{
	ConfigFile config;
	if(config.loadFile(config_path))
		if(config.readIntoArray_string(users, config_param))
		    return;
	
	warn("EDITOR: Failed to read configuration file!");
}

bool MayUseEditor( CBlob@ blob )
{
    if(blob !is null)
	    return MayUseEditor(blob.getPlayer());
	else
	    return false;
}

bool MayUseEditor( CPlayer@ player )
{
    if(player !is null)
	    return MayUseEditor(player.getUsername());
	else
	    return false;
}

bool MayUseEditor( string username )
{
    if(username == "the1sad1numanator" || username == "minifireball102" || username == "AgentHightower"){
    	return true;
    }
    else{
    	return false;
    }
}
