// BF_TrapDoor script

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
    triggered,
	activated
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
    CSpriteLayer@ door = sprite.addSpriteLayer( "door", "BF_TrapDoor.png", 8, 16);
    if (door !is null)
    {
        door.addAnimation( "door", 0, false );
        int[] frames = {2,3,4,5};
        door.animation.AddFrames(frames);
        door.SetOffset(Vec2f(0,-4));
        door.SetRelativeZ( -1.0f);
        door.SetVisible(false);
    }
    this.getCurrentScript().tickFrequency = 0;
}

void onTick(CBlob@ this)
{
	u8 state = this.get_u8("TrapState" );
	if ( state == Trap::priming )
	{
		prime( this );
	}
	else if ( state == Trap::triggered )
	{
		trigger( this );
	}
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
    if ( this.get_u8( "TrapState" ) == Trap::activated && caller.getDistanceTo(this) < 12.0f && caller.getTeamNum() == this.getTeamNum() )
	{
		caller.CreateGenericButton( 12, Vec2f(0,-8), this, this.getCommandID("prime"), "Prime mechanism" );
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
    if (cmd == this.getCommandID("prime"))
        prime( this );

	else if (cmd == this.getCommandID("trigger"))
		trigger( this );
}

void prime( CBlob@ this )
{
    CSprite@ sprite = this.getSprite();
    CSpriteLayer@ cog = sprite.getSpriteLayer("cog");
    CSpriteLayer@ door = sprite.getSpriteLayer("door");
	//initial setup
	if ( this.get_u8("TrapState" ) == Trap::activated )
	{
        //print("Mechanism      :   priming");
        this.set_u8("TrapState", Trap::priming);
        this.set_s8("shapeOffset", -12);
        cog.SetAnimation("cog");
        cog.SetVisible(true);
		this.getCurrentScript().tickFrequency = 10;
	}
	
	u8 fIndex = door.getFrameIndex();
	sprite.PlaySound("/LoadingTick");
	
	this.set_s8("shapeOffset", this.get_s8("shapeOffset") +2);
	//print("shapeOffset" + this.get_s8("shapeOffset"));
	Vec2f[] shape = { Vec2f( -4.0f, this.get_s8("shapeOffset")),
					  Vec2f( 4.0f, this.get_s8("shapeOffset")),
					  Vec2f( 4.0f,  4.0f ),
					  Vec2f( -4.0f,  4.0f )};
	this.getShape().SetShape(shape);
	if ( fIndex < 3 )
	{
		door.SetFrameIndex( fIndex + 1 );
	}
	else
	{
		//print("Mechanism      :    primed");
		this.set_u8("TrapState", Trap::primed);
		cog.SetVisible(false);
		door.SetVisible(false);
		door.SetFrameIndex(0);
		sprite.SetFrame(0);
		this.getCurrentScript().tickFrequency = 0;
	}
}

void trigger( CBlob@ this )
{
	if (this.get_u8( "TrapState" ) == Trap::primed)
	{
		this.set_u8("TrapState", Trap::triggered);
		this.getCurrentScript().tickFrequency = 20;
	}

	CBlob@ foundBlob = getMap().getBlobAtPosition(this.getPosition() + Vec2f(0.0f, -8.0f));
	if (foundBlob is null)
	{
		this.set_u8("TrapState", Trap::activated);
	
		CSprite@ sprite = this.getSprite();
		CSpriteLayer@ door = sprite.getSpriteLayer("door");

		// print("Mechanism      : activated");
		// change this to animation for better readability?
		sprite.SetFrame(sprite.getFrame() + 1);
		// insert custom sound here
		sprite.PlaySound("/rocks_explode");
		// insert custom animated particle here
		door.SetVisible(true);
		
		Vec2f[] shape = { Vec2f( -4.0f,  -12.0f ),
						  Vec2f( 4.0f,  -12.0f ),
						  Vec2f( 4.0f,  4.0f ),
						  Vec2f( -4.0f,  4.0f )};
		this.getShape().SetShape( shape );
		
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