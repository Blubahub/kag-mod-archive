void SetConfig_u32( CRules@ this, ConfigFile@ cfg, const string &in configvar, const u32 def )
{
	this.set_u32( configvar, cfg.read_s32(configvar, def) );
	this.Sync(configvar, true);
}

void SetConfig_string( CRules@ this, ConfigFile@ cfg, const string &in configvar, const string &in def )
{
	this.set_string( configvar, cfg.read_string(configvar, def) );
	this.Sync(configvar, true);
}

void SetConfig_tag( CRules@ this, ConfigFile@ cfg, const string &in configvar, const bool def )
{
	if (cfg.read_bool(configvar, def)){
		this.Tag( configvar );
		printf("SET " + configvar);
	}
	else{
		printf("UNSET " + configvar);
		this.Untag( configvar );
	}
	this.Sync(configvar, true);
}
