// CP Point logic

uint InchPrePoint_common = 10;
uint Full_health_common = InchPrePoint_common * getTicksASecond();
uint InchPrePoint = 10;
uint Full_health = InchPrePoint * getTicksASecond();

void onInit( CBlob@ this )
{
	this.set_s32("health", Full_health);
	this.Sync("health",true);
	this.set_s32("common_health", 0);
	this.Sync("common_health",true);
	
    this.CreateRespawnPoint( "cp_point", Vec2f(0.0f, 16.0f) );
    this.getShape().SetStatic(true);
    this.getShape().getConsts().mapCollisions = false;
	
	CSprite@ sprite = this.getSprite();
	sprite.SetZ( -50.0f ); // push to background
	sprite.SetAnimation("default");
	this.SetLight( true );
	this.SetLightRadius( 50 );
			
	Put_Bar (this, sprite, this.getTeamNum());
}

void onTick( CBlob@ this )
{
    if (this is null) return; //can happen with bad reload
	
	CP_Point_Interface(this);
	
	CBlob@[] players;
	u8 RedCountTeam = 0, BlueCountTeam = 0;
	
	getMap().getBlobsInRadius( this.getPosition(), this.getRadius(), @players );
	
	for (u8 i=0; i<players.length; i++) //
	{
		if( players[i].hasTag("player") ){
			if(players[i].getTeamNum() == 0){	BlueCountTeam++;	}
			if(players[i].getTeamNum() == 1){	RedCountTeam++;		}
		}
	}
	
	if( (RedCountTeam == 0) && (BlueCountTeam == 0) ){	Regeneration(this); return;	 }
	
	if( this.getTeamNum() == 7)
	{
		if(RedCountTeam == 0)
		{
			s32 health = this.get_s32("common_health");
			health += 1 + (0.4 * BlueCountTeam);
			
			if(health == Full_health_common)
			{
				health = 0;
					
				this.server_setTeamNum(0);
				
				Sound::Play( "/flag_capture.ogg" );
			}
			
			this.set_s32("common_health", health);
			this.Sync("common_health",true);
		}
		
		else if(BlueCountTeam == 0)	
		{
			s32 health = this.get_s32("common_health");
			health -= 1 + (0.4 * RedCountTeam);
			
			if(health == ((-1)*Full_health_common) )
			{
				health = 0;
				
				this.server_setTeamNum(1);		
				
				Sound::Play( "/flag_capture.ogg" );
			}
			
			this.set_s32("common_health", health);
			this.Sync("common_health",true);
		}
	}
	
	else if( this.getTeamNum() == 0 )
	{
		if(BlueCountTeam == 0)
		{
			s32 health = this.get_s32("health");
			health -= 1 + (0.4 * RedCountTeam);
			if(health <= 0)
			{
				health = Full_health;
	
				this.server_setTeamNum(7);
				
				Sound::Play( "/flag_return.ogg" );
			}
			this.set_s32("health", health);
			this.Sync("health",true);
		}
	}
	
	else if( this.getTeamNum() == 1 )
	{
		if(RedCountTeam == 0)
		{
			s32 health = this.get_s32("health");
			health -= 1 + (0.4 * BlueCountTeam);
			if(health <= 0)
			{
				health = Full_health;
	
				this.server_setTeamNum(7);
				
				Sound::Play( "/flag_return.ogg" );
			}
			this.set_s32("health", health);
			this.Sync("health",true);
		}
	}
}

void Regeneration( CBlob@ this )
{
	if ( getGameTime() % 5 == 0 )
	{
		s32 health = this.get_s32("health");
		
		if( health != Full_health ){
			health++;
			this.set_s32("health", health);
			this.Sync("health",true);
		}
	}
}

void CP_Point_Interface(CBlob@ Point)
{		
	CSprite@ sprite = Point.getSprite();
	
	u8 PointTeam = Point.getTeamNum();
	
	if(PointTeam != 7)
	{
		s32 health = Point.get_s32("health");
	
		if( health > InchPrePoint )
		{ 
			sprite.RemoveSpriteLayer("scale");
			CSpriteLayer@ scale = sprite.addSpriteLayer( "scale", sprite.getConsts().filename, health/InchPrePoint, 4, PointTeam, 2);
			scale.SetHUD(true);
			scale.addAnimation( "default_scale", 0, false ).AddFrame(0);
			scale.SetOffset( Vec2f(0.0f, 35.0f) );
			sprite.SetAnimation("default_scale");
		}
		Put_Bar (Point, sprite, PointTeam);
	}
	else
	{
		s32 health = Point.get_s32("common_health");
		
		if( health > InchPrePoint_common )
		{
			sprite.RemoveSpriteLayer("scale");
			CSpriteLayer@ scale = sprite.addSpriteLayer( "scale", sprite.getConsts().filename, health/InchPrePoint_common, 4, 0, 2);
			scale.SetHUD(true);
			scale.addAnimation( "default_scale_blue", 0, false ).AddFrame(0);
			scale.SetOffset( Vec2f(0.0f, 35.0f) );
			sprite.SetAnimation("default_scale_blue");
			
			Put_Bar (Point, sprite, 0);
		}
		else if( health < ((-1)*InchPrePoint_common) )
		{
			sprite.RemoveSpriteLayer("scale");
			health *= (-1);
			CSpriteLayer@ scale = sprite.addSpriteLayer( "scale", sprite.getConsts().filename, health/InchPrePoint_common, 4, 1, 2);
			scale.SetHUD(true);
			scale.addAnimation( "default_scale_red", 0, false ).AddFrame(0);
			scale.SetOffset( Vec2f(0.0f, 35.0f) );
			sprite.SetAnimation("default_scale_red");
			
			Put_Bar (Point, sprite, 1);
		}
	}
}

void Put_Bar (CBlob@ Point, CSprite@ sprite, u8 team)
{
	sprite.RemoveSpriteLayer("Bar");
	CSpriteLayer@ Bar = sprite.addSpriteLayer( "Bar", sprite.getConsts().filename, 48, 8, team, 2);
	Animation@ anim = Bar.addAnimation( "default_Bar", 0, false );
	Bar.SetOffset( Vec2f(0, 35.0f) );
	anim.AddFrame(4);
	Bar.SetLighting(true);
	Bar.SetHUD(true);    
	sprite.SetAnimation("default_Bar");
}
