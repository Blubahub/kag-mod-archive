
#include "Hitters.as";

//config

const int splash_width = 9;
const int splash_height = 7;
const int splashes = 3;

//logic
void onInit(CBlob@ this)
{
    AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");	 
    if (ap !is null)
    {
        ap.SetKeysToTake( key_action1 | key_action2 | key_action3 );
    }

    this.getSprite().ReloadSprites(0,0);
    //this.addCommandID("splash");
	//this.set_u8("filled", 0);

	this.getCurrentScript().runFlags |= Script::tick_attached;
}

void onTick(CBlob@ this)
{
	// u8 filled = this.get_u8("filled");
    // if (filled == 0)
    // {
        // if (this.isInWater())
        // {
            // this.set_u8("filled", splashes);
            // this.set_u8("water_delay", 30);
			// this.getSprite().SetAnimation("full");
        // }
    // }
    // else
    // {
        // AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
        // u8 water_delay = this.get_u8("water_delay");

        // if (water_delay > 0)
        // {
            // this.set_u8("water_delay", water_delay - 1);
        // }
        // else if(point.getOccupied() !is null && point.getOccupied().isMyPlayer() && point.isKeyJustPressed(key_action1) && !this.isInWater())
        // {
            // this.SendCommand(this.getCommandID("splash"));            
			// this.set_u8("water_delay", 30);
        // }
    // }
}

void onDie(CBlob@ this)
{
    // if (this.get_u8("filled") > 0)
    // {
        // Splash(this);
    // }
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
    // if (cmd == this.getCommandID("splash"))
    // {
        // Splash(this);
    // }
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point )
{
	// if (solid && getNet().isServer() && this.getShape().vellen > 6.8f && this.get_u8("filled") > 0)  {
		 // this.SendCommand(this.getCommandID("splash"));
	// }

}

const int splash_halfwidth = splash_width / 2;
const int splash_halfheight = splash_height / 2;
const f32 splash_offset = 0.7f;

void Splash( CBlob@ this )
{
    //extinguish fire
    CMap@ map = this.getMap();
    Sound::Play( "SplashSlow.ogg", this.getPosition(), 3.0f );
		
	u8 filled = this.get_u8("filled");
	if (filled > 0)
		filled--;
	
	if (filled == 0)
	{
		filled = 0;
		this.getSprite().SetAnimation("empty");
	}
	this.set_u8("filled", filled);	

    if (map !is null)
    {
        bool is_server = getNet().isServer();
        Vec2f pos = this.getPosition() +
                    Vec2f( this.isFacingLeft()?
                           -splash_halfwidth*map.tilesize*splash_offset :
                           splash_halfwidth*map.tilesize*splash_offset,
                           0 );

        for(int x_step = -splash_halfwidth; x_step < splash_halfwidth; ++x_step)
        {
            for(int y_step = -splash_halfheight; y_step < splash_halfheight; ++y_step)
            {
                Vec2f wpos = pos + Vec2f( x_step * map.tilesize, y_step * map.tilesize );
                Vec2f outpos;

                //extinguish the fire at this pos
                if (is_server) {
                    map.server_setFireWorldspace( wpos, false );
                }

                //make a splash!
                if ((x_step + y_step + 125678) % 7 > 3 || XORRandom(3) == 0 ) {
                    map.SplashEffect( wpos, Vec2f(0,10), 8.0f );
                }
            }
        }

        Vec2f offset = Vec2f(splash_halfwidth,splash_halfheight);
        Vec2f tl = pos - offset;
        Vec2f br = pos + offset;

        if (is_server)
        {
            CBlob@[] blobs;
            map.getBlobsInBox( tl, br, @blobs );

            for (uint i = 0; i < blobs.length; i++)
            {
                this.server_Hit( blobs[i], pos, Vec2f(0,0), 0.0f, Hitters::water, true);
            }
        }
    }
}


//sprite

void onInit(CSprite@ this)
{
    // this.SetAnimation("empty");
	// if (this.getBlob().hasTag("filled")) {
		// this.SetAnimation("full");
	// }
}