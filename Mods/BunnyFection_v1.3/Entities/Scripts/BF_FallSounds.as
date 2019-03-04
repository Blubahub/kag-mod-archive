#define CLIENT_ONLY

void Sound( CBlob@ this, Vec2f normal )
{
    const f32 vellen = this.getShape().vellen;

    if (vellen > 4.5f)
    {
        if (Maths::Abs(normal.x) > 0.5f) {
            this.getSprite().PlaySound( "FallWall" );
        }
        else {
            this.getSprite().PlaySound( "FallSmall" );
        }

        if (vellen > 6.0f) {
            MakeDustParticle( this.getPosition()+Vec2f(0.0f, 6.0f), "/dust.png" );
        }
        else {
            MakeDustParticle( this.getPosition()+Vec2f(0.0f, 11.0f), "/DustSmall.png" );
        }
    }
    else if (vellen > 2.75f) {
        this.getSprite().PlaySound( CFileMatcher("FallSmall").getRandom() );
    }
}

void MakeDustParticle(Vec2f pos, string file )
{
    CParticle@ temp = ParticleAnimated( CFileMatcher(file).getFirst(), pos - Vec2f(0,8), Vec2f(0,0), 0.0f, 1.0f, 3, 0.0f, false );

    if (temp !is null)
    {
        temp.width = 8;
        temp.height = 8;
    }
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal )
{
    if (solid && this.getOldVelocity() * normal < 0.0f) { // only if approaching
        Sound( this, normal );
    }
}
