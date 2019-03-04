// Minelogic

const u32 PRIMING_TICKS = 45;

void onInit( CBlob@ this )
{
    this.getShape().getVars().waterDragScale = 16.0f;
    AttachmentPoint@ att = this.getAttachments().getAttachmentPointByName("PICKUP");
    att.SetKeysToTake( key_action1 | key_action2 );
    att.SetMouseTaken( false );
    this.set_f32("explosive_radius",74.0f);
    this.set_f32("explosive_damage",7.5f);
    this.set_string("custom_explosion_sound", "Entities/Items/Explosives/KegExplosion.ogg");  
    this.set_f32("map_damage_radius", 42.0f);
    this.set_f32("map_damage_ratio", 0.5f);
    this.set_bool("map_damage_raycast", true);
	this.set_u32("priming ticks", 0 );

	this.getShape().getConsts().collideWhenAttached = true;

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().tickFrequency = 10;
}

void onTick( CBlob@ this )
{
	//if (this.isOnGround() || this.isInWater())
	{
		u32 ticks = this.get_u32("priming ticks");
		u32 add = this.getCurrentScript().tickFrequency;
		this.set_u32("priming ticks", ticks + add);
		if (ticks + add >= PRIMING_TICKS)
		{  
			this.getShape().checkCollisionsAgain = true;
			this.getCurrentScript().tickFrequency = 0;
			this.getSprite().PlaySound("/MineArmed.ogg");
			this.getSprite().SetFrameIndex(1);
		}
	}
}


void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{  
	this.set_u32("priming ticks", 0);
	this.getCurrentScript().tickFrequency = 10;
	this.getSprite().SetFrameIndex(0);
}


bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )	
{
	return ( blob.hasTag("door") || //early out collide with doors
			this.getTeamNum() != blob.getTeamNum() &&
			!this.isAttachedTo(blob) &&
			(blob.getMass() > 500.0f || blob.hasTag("flesh") || blob.getShape().vellen > 5.0f));
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid )
{
	if (blob !is null && doesCollideWithBlob( this, blob ) && this.get_u32("priming ticks") >= PRIMING_TICKS )
	{	
		Boom( this );		
	}
}

void Boom( CBlob@ this )
{
	this.Tag("exploding");
	this.server_SetHealth(-1.0f);
	this.getSprite().Gib();
	this.server_Die();
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return (this.getTeamNum() == byBlob.getTeamNum());
}
