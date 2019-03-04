const f32 REGEN_RATE = 0.2f;//healing per second
const f32 BOX_X = 40.0f;
const f32 BOX_Y = 30.0f;

void onInit( CBlob@ this )
{
	this.getCurrentScript().tickFrequency = 30;
}

void onTick( CBlob@ this )
{
	Vec2f hPos = this.getPosition();
	Vec2f boxTL = Vec2f( hPos.x - BOX_X/2.0f, hPos.y - BOX_Y/2.0f );
	Vec2f boxBR = Vec2f( hPos.x + BOX_X/2.0f, hPos.y + BOX_Y/2.0f );
	
	CBlob@[] targets;
	getMap().getBlobsInBox( boxTL, boxBR, @targets );
	int tNumber = targets.length();
	
	for( int i = 0; i < tNumber; i++ )
	{
		if ( targets[i] !is null )
		{
			if ( ( targets[i].hasTag( "mutant" ) || targets[i].getTeamNum() == 1 ) && targets[i].getHealth() < targets[i].getInitialHealth() )
			{
				targets[i].server_Heal( REGEN_RATE );
				if (targets[i].getName() != "bf_hatchery")
				{
					//Vec2f tPos = targets[i].getPosition();
					//ParticleAnimated("BF_EffectHeal.png", tPos, Vec2f(0,0), 0.0f, 1.0f, 5, 0.0f, true );
					ParticleAnimated("BF_EffectHeal.png", targets[i].getPosition() + Vec2f(0.0f, -3.0f), Vec2f(0,0), 0.0f, 1.0f, 5, -0.01f, true );
				}
			}
		}
	}
}