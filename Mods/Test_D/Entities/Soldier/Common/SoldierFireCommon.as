namespace Soldier
{
	Random _shotspreadrandom(0x11598); //clientside

	void Fire(CBlob@ this, Soldier::Data@ data, Vec2f aimvector)
	{
		const f32 aimdist = aimvector.Normalize();

		Vec2f offset;
		if (data.fireSpread > 0.0f){
			offset.Set(data.direction * _shotspreadrandom.NextFloat() * data.fireSpread * Maths::Max(1.0f, (0.75f / data.fireSpread)*data.vellen), 0) ;
			offset.RotateBy(_shotspreadrandom.NextFloat() * 360.0f, Vec2f_zero);
		}
		Vec2f _vel = (aimvector * data.fireMuzzleVelocity) + offset;

		CBitStream params;
		params.write_netid(this.getNetworkID());
		params.write_Vec2f(data.pos + aimvector * data.radius + getFireOffset(this, data));
		params.write_Vec2f(_vel);
		params.write_f32(data.bulletLifeSecs);
		params.write_f32(data.bulletDamage);
		this.SendCommand(Soldier::Commands::FIRE, params);
		data.fireTime = getGameTime();
	}

	bool canShoot(Data@ this)
	{
		return this.fireTime + this.fireRate < this.gametime;
	}
}