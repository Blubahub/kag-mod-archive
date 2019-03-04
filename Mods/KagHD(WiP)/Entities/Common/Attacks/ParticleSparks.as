void sparks(Vec2f at, f32 angle, f32 damage)
{
    int amount = damage*10 + XORRandom(10);

    for (int i = 0; i < amount; i++)
    {
        Vec2f vel = getRandomVelocity(angle, damage * 6.0f, 360.0f);
        vel.y = -Maths::Abs( vel.y ) + Maths::Abs(vel.x)/6.0f - 4.0f - float(XORRandom(200))/200.0f;
        ParticlePixel( at, vel, SColor( 255, 255, 255, 0), true );
    }
}
