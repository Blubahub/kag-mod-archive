// Keg logic
#include "Hitters.as";

void onInit( CBlob@ this )
{
    this.set_f32("explosive_radius", 24.0f);
    this.set_f32("explosive_damage",10.0f);
    this.set_string("custom_explosion_sound", "Entities/Items/Explosives/KegExplosion.ogg");
    this.set_f32("map_damage_radius", 24.0f);
    this.set_f32("map_damage_ratio", 0.8f);
    this.set_bool("map_damage_raycast", true);
	this.set_f32("keg_time", 180.0f);  // 180.0f
	this.set_u8("custom_hitter", Hitters::keg);
    
    CSpriteLayer@ fuse = this.getSprite().addSpriteLayer( "fuse", "MiniKeg.png" , 16, 16, 0, 0 );

	if (fuse !is null)
	{
		fuse.addAnimation("default",0,false);
		int[] frames = {0,1,2,3};
		fuse.animation.AddFrames(frames);
	}

	this.getCurrentScript().runFlags |= Script::remove_after_this;
}

//sprite update

void onTick( CSprite@ this )
{
    CBlob@ blob = this.getBlob();
    
    this.animation.frame = (this.animation.getFramesCount()) * (1.0f - (blob.getHealth() / blob.getInitialHealth()));
    
    s32 timer = blob.get_s32("explosion_timer") - getGameTime();

    if (timer < 0) {
        return;
    }
    
    CSpriteLayer@ fuse = this.getSpriteLayer( "fuse" );
    
    if (fuse !is null)
    {
		fuse.animation.frame = 1 + (fuse.animation.getFramesCount() - 1) * (1.0f - ((timer + 5) / f32(blob.get_f32("keg_time"))));
	}
    
}
