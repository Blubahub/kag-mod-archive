#include "MagicExplosion.as";
#include "MagicalHitters.as";
void onInit(CBlob@ this)
{
	this.set_string("custom_explosion_sound", "Thunder1.ogg");
	this.set_f32("map_damage_ratio", 0.2f);
	this.set_bool("explosive_teamkill", true); //EHEHHEHE
	this.set_u8("custom_hitter", MagicalHitters::Magic);
	this.getSprite().SetAnimation("Explode");
}
void onCollision( CBlob@ this, CBlob@ blob, bool solid )
{
	if(getNet().isServer() && blob !is null)
	{
		if(this.getTeamNum() != blob.getTeamNum() && (blob.hasTag("flesh") || blob.hasTag("player")))
		{
			this.server_Die();
		}
	}
}
void onTick(CBlob@ this)
{
	CSprite@ spr = this.getSprite();
	f32 amount = Maths::Sin(this.getTimeToDie() * this.getTimeToDie() ) / 20.0f + 1;
	spr.ScaleBy(Vec2f(amount, amount)); //not working
}
void onDie(CBlob@ this)
{
	f32 charge = (this.get_u16("charge") / 40.0f);
	this.set_f32("map_damage_radius", charge * 8.0f);
	Explode(this, 15.0f * charge, 0.5f * charge);
	this.getSprite().PlaySound("Bomb.ogg", charge, 1 / charge);
}