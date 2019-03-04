#include "SoldierCommon.as"
#include "SoldierFireCommon.as"
#include "Shell.as"
#include "HoverMessage.as"

const f32 GRENADE_TIMEOUT = 3.0f;

void onInit( CBlob@ this )
{
	Soldier::Data@ data = Soldier::getData( this );
	data.fireRate = 3;
	data.fireSpread = 0.5f;
	data.fireMuzzleVelocity = 20.0f;
	data.bulletLifeSecs = 0.4f;
	data.bulletDamage = 1.0f;
	data.grenadeTimeout = getTicksASecond() * GRENADE_TIMEOUT;
	data.grenades = data.initialGrenades = 3;
	data.grenadeType = Soldier::GRENADE;
	data.ammo = data.initialAmmo = 30;
}

void onTick( CBlob@ this )
{
	Soldier::Data@ data = Soldier::getData( this );

	if (data.dead || data.stunned || getRules().isWarmup())
		return;

	// fire
	if (data.fire && !data.fire2 && !data.crosshair)
	{
		if (data.ammo <= 0)				{
			if (!data.inMenu && this.isKeyJustPressed( key_action1 )){
				data.sprite.PlaySound("DryShot");
				AddMessageAbove( this, "no ammo" );
			}
		}
		else if (data.local && Soldier::canShoot(data))
		{
			Vec2f aimvector = Vec2f( data.facingLeft ? -1 : 1, 0 );
			Soldier::Fire( this, data, aimvector );
		}
	}

	// crouch when nade

	Soldier::SetCrouching( this, data, data.crouching || data.crosshair );
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	Soldier::Data@ data = Soldier::getData( this );

    if (cmd == Soldier::Commands::FIRE && getNet().isClient() && getCamera() !is null)
    {
    	// client-effects
    	CPlayer@ local = getLocalPlayer();
    	u8 localTeam = local !is null ? local.getTeamNum() : 0;
	    CSprite@ sprite = this.getSprite();
    	data.shotTime = data.gametime;
    	if (data.ammo <= 0){
    		sprite.PlaySound("DryShot");
    		AddMessageAbove( this, "no ammo" );
    	}
    	else 
    	{
	    	if (!Sound::isTooFar(data.pos))
	    	{
	    		sprite.PlayRandomSound( "Ak47Shot");
		    	Particles::Shell( data.pos, Vec2f(0,-7), SColor(255, 255, 255, 90) );
	    	}
	    	else
	    	{
	    		Sound::Play2D("DistantShot", 0.1f, data.pos.x > getCamera().getPosition().x ? 1.0f : -1.0f);
	    	}    		
    	}
    }
}
