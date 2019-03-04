void onInit(CBlob@ this)
{
	this.Tag("smoke");
	this.Tag("gas");

	this.getShape().SetGravityScale(-0.1f);

	this.getSprite().SetZ(XORRandom(3) * 10);

	this.SetMapEdgeFlags(CBlob::map_collide_sides);
	this.getCurrentScript().tickFrequency = 5;

	this.getSprite().RotateBy(90 * XORRandom(4), Vec2f());

	if (!this.exists("toxicity")) this.set_f32("toxicity", 0.75f);
	
	if (getNet().isServer()) this.server_SetTimeToDie(60 + XORRandom(120));
}

void onTick(CBlob@ this)
{
	if (this.getPosition().y < 0) this.server_Die();
	if(XORRandom(3) == 0)MakeParticle(this);
}

void MakeParticle(CBlob@ this, const string filename = "LargeSmoke")
{
	if (!getNet().isClient()) return;
	ParticleAnimated(CFileMatcher(filename).getFirst(), this.getPosition() + Vec2f(XORRandom(200) / 10.0f - 10.0f, XORRandom(200) / 10.0f - 10.0f), Vec2f(), float(XORRandom(360)), 0.75f + (XORRandom(50) / 100.0f), 3, 0.0f, false);
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
   return blob.hasTag("smoke");
}
