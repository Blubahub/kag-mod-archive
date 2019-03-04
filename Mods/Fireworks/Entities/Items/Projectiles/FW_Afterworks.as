#include "FW_FireParticle.as"

void onInit(CBlob@ this)
{
    CShape@ shape = this.getShape();
    shape.SetGravityScale( 0.0f );
    this.setVelocity(Vec2f(0,0));
}

void onTick(CBlob@ this)
{   
    f32 angle = this.getAngleDegrees();
    Vec2f force = Vec2f(0, -8);

    if (this.getTickSinceCreated() >= 20+XORRandom(90))
    {  
       // CreateExplosion(this.getPosition(), this.getTeamNum());
        this.server_Die();
        return;
    }

    if (getGameTime() % 1 == 0)
    {
        
        force.y -= 3000.0f; // Thrust amount//
        force.RotateBy(this.getShape().getAngleDegrees()); 
        this.AddForce(force);
        this.AddTorque(XORRandom(2) == 1 ? -2500 : 2500);
        makeFireParticle(this.getPosition());    
    }
}

void CreateExplosion( Vec2f pos, int team)
{  
    CBlob @blob = server_CreateBlob("fw_explosion");
    if (blob !is null)
    {
        //SetScreenFlash( 5, 0, 0, 150 );
        blob.Tag("afterworks eplosion");
        blob.AddScript("FW_Explosion.as");
        blob.setPosition(pos);
        //blob.SetLight(true);
        //blob.SetLightColor(SColor(255, 255, 240, 171));
        //blob.SetLightRadius(50.0f);

        blob.Init();        
    }
}

