// Trading Post

#include "MakeDustParticle.as";
							 
void onInit( CBlob@ this )
{	    
	this.getSprite().SetZ( -50.0f ); // push to background
	this.getShape().getConsts().mapCollisions = false;	   
	
	// defaultnobuild
	this.set_Vec2f("nobuild extend", Vec2f(0.0f, 8.0f));

	//TODO: set shop type and spawn trader based on some property
}

   

//Sprite updates

void onTick( CSprite@ this )
{
    //TODO: empty? show it.
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
    if (hitterBlob.getTeamNum() == this.getTeamNum() && hitterBlob !is this) {
        return 0.0f;
    } //no griffing

	this.Damage( damage, hitterBlob );

	return 0.0f;
}


void onHealthChange( CBlob@ this, f32 oldHealth )
{
	CSprite @sprite = this.getSprite();

	if (oldHealth > 0.0f && this.getHealth() < 0.0f)
	{
		MakeDustParticle(this.getPosition(), "Smoke.png");
		this.getSprite().PlaySound("/BuildingExplosion");
	}
}
