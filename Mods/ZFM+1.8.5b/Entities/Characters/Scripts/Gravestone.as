#include "Explosion.as";

f32 explosive_radius = 28.0f;
f32 map_damage_ratio = 0.3f;
f32 explosive_damage = 3.0f;
f32 time_to_explode = 4; // 4 secs

void onInit( CBlob@ this )
{
    //setting explosion "options"
    this.set_f32("explosive_radius", explosive_radius);
    this.set_f32("map_damage_radius", explosive_radius);
    this.set_f32("map_damage_ratio", map_damage_ratio);
    this.set_bool("map_damage_raycast", true); 

    //this.setVelocity(Vec2f(XORRandom(8) - 4, -4)); This line is in RunnerDeath.as

    //Explode in some time
    this.set_u16("time_to_explode", 30 * time_to_explode + getGameTime());
}
void onTick( CBlob@ this )
{
    //check if it's time to explode
    bool explode = getGameTime() >= this.get_u16("time_to_explode");
    if (explode) 
        Boom(this);

    //stick to map
    if (!this.hasTag("on_map") && this.isOnMap()) 
    {
        int angle = this.getGroundNormal().Angle(); // to check if it's on ground
        if (angle >= 45 && angle <= 135)
        {
            StickToGround(this);
        }
    }    

}

//sprite update
void onTick( CSprite@ this )
{
    //simple rotation
    CBlob@ blob = this.getBlob();
    Vec2f vel = blob.getVelocity();
    if (vel.y != 0)
        this.RotateAllBy(5 * vel.x, Vec2f_zero);	 		  
}

void StickToGround(CBlob@ this)
{
    //resetting sprite rotation by recreating a gravestone
    if (getNet().isServer())
    {
        this.server_Die();
        CBlob@ gravestone = server_CreateBlob("gravestone", this.getTeamNum(), this.getPosition());
        if (gravestone !is null) 
        {
            gravestone.Tag("on_map");
            gravestone.shape.SetStatic(true);
        }
    }

}

void Boom(CBlob@ this)
{
    //explode n die
    Explode(this, explosive_radius, explosive_damage);
    this.server_Die();
}