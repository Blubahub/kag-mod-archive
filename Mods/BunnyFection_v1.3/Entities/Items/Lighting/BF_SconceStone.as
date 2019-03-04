// BF_SconceStone script

namespace Light
{
enum State
{
    off = 0,
    on
}
}

void onInit( CBlob@ this )
{
    this.getShape().getConsts().mapCollisions = false;
    this.getSprite().getConsts().accurateLighting = true;
    this.addCommandID("light");
    CSprite@ sprite = this.getSprite();
    CSpriteLayer@ fire = sprite.addSpriteLayer( "fire", "BF_SconceStone.png", 2, 4);
    if(fire !is null)
    {
        fire.addAnimation( "fire", 3, true );
        int[] frames = {8,9,10};
        fire.animation.AddFrames(frames);
        fire.SetRelativeZ( 1.0f);
        fire.SetVisible(false);
    }
    this.SetLightRadius( 64.0f );
    this.SetLightColor( SColor(255, 255, 240, 171 ) );
    this.SetLight(false);
    this.set_u8("LightState", Light::off);
}


void onSetStatic(CBlob@ this, const bool isStatic)
{
    Vec2f pos = this.getPosition();
    CMap@ map = getMap();
    TileType t = map.getTile(pos).type;
    CSprite@ sprite = this.getSprite();
    if ((t == CMap::tile_empty) || (t == CMap::tile_grass))
    {
        //Set frame to standalone brazier
        this.getSprite().SetFrame( 0 );
        //print("::::Empty");
    }
    else
    {
        //Set frame to background sconce
        this.getSprite().SetFrame( 1 );
        //print("::::Not-Empty");
    }
    this.getSprite().SetZ(-50);
    this.SendCommand(this.getCommandID("light"));
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
    if (caller.getDistanceTo(this) > 10.0f || caller.getTeamNum() != this.getTeamNum())
    {
        return;
    }
    u8 state = this.get_u8("LightState");
    caller.CreateGenericButton( 12, Vec2f(0,-8), this, this.getCommandID("light"), "Light " + ( state == Light::on ? "Off" : "On" ) );
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
    CSprite@ sprite = this.getSprite();
    CSpriteLayer@ fire = sprite.getSpriteLayer( "fire" );
    u8 state = this.get_u8("LightState");
    if (state == Light::on)
    {
        this.set_u8("LightState", Light::off);
        fire.SetVisible(false);
        this.SetLight(false);
        //print("::::Light Off");
    }
    else
    {
        this.set_u8("LightState", Light::on);
        fire.SetVisible(true);
        this.SetLight(true);
        //print("::::Light On");
    }
    sprite.PlaySound( "SparkleShort.ogg" );
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
    return false;
}