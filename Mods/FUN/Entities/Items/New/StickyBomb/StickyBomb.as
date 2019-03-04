#include "Hitters.as"
void onTick( CBlob@ this )
{
    if( this.hasTag("exploding") && !this.hasTag("sticked"))
    {
        if (this.isOnMap())
        {
            this.setAngleDegrees(90-this.getGroundNormal().Angle());
            this.getShape().SetStatic(true);
	this.Tag("sticked");
        }
    }
    if (this.hasTag("collided"))
    {
        CBlob@ blob = getBlobByNetworkID(this.get_u16("stick_blob_id"));
        if (blob !is null)
        {
            Vec2f offset = this.get_Vec2f("stick_offset");
            this.setPosition(blob.getPosition() + offset);
        }
    }
}

bool canBePickedUp( CBlob@ this, CBlob@ blob )
{
	return !this.hasTag("sticked");
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
    if (blob !is null && !this.hasTag("collided"))
    {
        if (
            this.getTeamNum() != blob.getTeamNum() && 
            (blob.hasTag("flesh") || blob.hasTag("blocks sword") || blob.hasTag("blocks water") || 
                blob.hasTag("door") || blob.hasTag("place norotate") || blob.getName() == "wooden_platform")
            )
        {
            this.set_u16("stick_blob_id",  blob.getNetworkID());
            Vec2f offset = this.getPosition() - blob.getPosition();
            this.set_Vec2f("stick_offset", offset);
            this.Tag("no_sprite_rotate");
            this.Tag("collided");
        }
    }
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
    //special logic colliding with players
    if (blob.hasTag("player"))
    {
        const u8 hitter = this.get_u8("custom_hitter");

        //all water bombs collide with enemies
        if (hitter == Hitters::water)
            return blob.getTeamNum() != this.getTeamNum();

        //collide with shielded enemies
        return (blob.getTeamNum() != this.getTeamNum());
    }
    return true;
}