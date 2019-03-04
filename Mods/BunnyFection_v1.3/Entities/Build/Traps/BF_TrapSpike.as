// BF_TrapSpike script

#include "Hitters.as"
#include "BF_Costs.as"
//#include "MakeDustParticle.as";

const u8 primingTime = 30;

namespace Trap
{
enum State
{
    priming = 0,
    primed,
    triggered
}
}

void onInit(CBlob@ this)
{
    this.addCommandID("prime");
    this.addCommandID("trigger");
    CSprite@ sprite = this.getSprite();
    CSpriteLayer@ cog = sprite.addSpriteLayer( "cog", "BF_TrapCog.png", 2, 2);
    if (cog !is null)
    {
        cog.addAnimation( "cog", 5, true );
        int[] frames = {0,1,2,3,4,5};
        cog.animation.AddFrames(frames);
        cog.SetOffset(Vec2f(-2,0));
        cog.SetRelativeZ( 1.0f);
        cog.SetVisible(false);
    }
    CSpriteLayer@ spike = sprite.addSpriteLayer( "spike", "BF_TrapSpike.png", 8, 16);
    if(spike !is null)
    {
        spike.addAnimation( "spike", 0, false );
        int[] frames = {2,3,4,5};
        spike.animation.AddFrames(frames);
        spike.SetOffset(Vec2f(0,-6));
        spike.SetRelativeZ( 1.0f);
        spike.SetVisible(false);
    }
    this.getCurrentScript().tickFrequency = 0;
}

void onTick(CBlob@ this)
{
	prime( this );
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point)
{
	if ( blob !is null )
	{
		if ( this.get_u8( "TrapState" ) == Trap::primed && point.y < this.getPosition().y && blob.getTeamNum() != this.getTeamNum() && blob.hasTag( "flesh" ) && !blob.hasTag( "dead" ) )
		{
			CBlob@ findBlob = getMap().getBlobAtPosition(this.getPosition() + Vec2f(0.0f, -8.0f));
			if (findBlob !is null)
				this.SendCommand(this.getCommandID("trigger"));
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
    if ( this.get_u8( "TrapState" ) == Trap::triggered && caller.getDistanceTo(this) < 12.0f && caller.getTeamNum() == this.getTeamNum() )
		caller.CreateGenericButton( 12, Vec2f(0,-8), this, this.getCommandID("prime"), "Prime mechanism" );
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
    if (cmd == this.getCommandID("prime"))
        prime( this );
    
	if (cmd == this.getCommandID("trigger"))
		trigger( this );
}

void trigger( CBlob@ this )
{
	if ( this.get_u8( "TrapState" ) == Trap::triggered )//just in case
		return;
		
	this.set_u8("TrapState", Trap::triggered);
	//Sprite
	CSprite@ sprite = this.getSprite();
	CSpriteLayer@ spike = sprite.getSpriteLayer("spike");
	//print("Mechanism      : triggered");
	// change this to animation for better readability?
    sprite.SetFrame(sprite.getFrame() + 1);
	// insert custom sound here
	sprite.PlaySound("/SpikesOut", 2.0f);
	// insert custom animated particle here
	spike.SetVisible(true);
	
	//Damage
	if ( !getNet().isServer() )
		return;
		
	CMap@ map = this.getMap();
	Vec2f pos = this.getPosition();
	CBlob@[] blobs;
	map.getBlobsInRadius( pos + Vec2f( 1.0f, -8.0f ), 3.7f, @blobs );
	for (uint i = 0; i < blobs.length(); i++)
	{
		CBlob@ blob = blobs[i];
		if ( blob.hasTag( "flesh" ) )
			this.server_Hit(blob, pos, Vec2f(0,0), DAMAGE_TRAP_SPIKE, Hitters::spikes, true);
	}	
}

void prime( CBlob@ this )
{    
	CSprite@ sprite = this.getSprite();
	CSpriteLayer@ cog = sprite.getSpriteLayer("cog");
	CSpriteLayer@ spike = sprite.getSpriteLayer("spike");
	//initial setup
	if ( this.get_u8("TrapState" ) == Trap::triggered )
	{
		this.set_u8("TrapState", Trap::priming);
		cog.SetAnimation("cog");
		cog.SetVisible(true);
		
		this.getCurrentScript().tickFrequency = 10;
	}
	
	u8 fIndex = spike.getFrameIndex();
	//print("Countdown      :     Timer = " + Timer);
	sprite.PlaySound("/LoadingTick");
	
	if ( fIndex < 3 )
		spike.SetFrameIndex( fIndex + 1 );
	else
	{
		//print("Mechanism      :    primed");
		this.set_u8("TrapState", Trap::primed);
		cog.SetVisible(false);
		spike.SetVisible(false);
		spike.SetFrameIndex(0);
		this.getCurrentScript().tickFrequency = 0;
	}
}

void onSetStatic(CBlob@ this, const bool isStatic)
{
    this.set_u8("TrapState", Trap::primed);
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
    return false;
}