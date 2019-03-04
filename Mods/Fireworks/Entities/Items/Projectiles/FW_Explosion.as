Random _r(12692930456); //clientside
void onInit(CBlob@ this)
{
    //this.server_setTeamNum(XORRandom(8));

    SetScreenFlash(3, 255, 255, 255);

    Vec2f pos = this.getPosition();
    pixelsparks(pos, this);
	return; 	
}

void pixelsparks(Vec2f at, CBlob@ this)
{
    SColor presetcolor1;SColor presetcolor2;SColor presetcolor3;SColor presetcolor4;SColor presetcolor5;
    u8 colnum; 
    /* colnum is trail color
        0 = blue
        1 = red
        2 = green
        3 = purple
        4 = darkblue
        5 = orange
        6 = teal
        7 = grey
    */
    switch (XORRandom(18))
    {
        case 0: presetcolor1 = SColor(255, 155,219,255);  // blight blue
                presetcolor2 = SColor(255, 39,197,239); 
                presetcolor3 = SColor(255, 0,164,255);  
                presetcolor4 = SColor(255, 75,105,200);  
                presetcolor5 = SColor(255, 119,90,167); 
                colnum = 0;
                break; 

        case 1: presetcolor1 = SColor(255, 253,229,119);  // fire watch
                presetcolor2 = SColor(255, 255,108,64);  
                presetcolor3 = SColor(255, 199,42,64);  
                presetcolor4 = SColor(255, 82,8,51);   
                presetcolor5 = SColor(255, 44,17,43);  
                colnum = 1;
                break;  

        case 2: presetcolor1 = SColor(255, 197,225,90);  // summer melon
                presetcolor2 = SColor(255, 151,199,83);   
                presetcolor3 = SColor(255, 87,163,70);   
                presetcolor4 = SColor(255, 255,97,97);    
                presetcolor5 = SColor(255, 255,59,59); 
                colnum = 2; 
                break;  

        case 3: presetcolor1 = SColor(255, 70,249,223);  // tropical candy
                presetcolor2 = SColor(255, 172,249,129);  
                presetcolor3 = SColor(255, 249,240,105);    
                presetcolor4 = SColor(255, 254,184,85);    
                presetcolor5 = SColor(255, 247,101,185);  
                colnum = 5;     
                break;  

        case 4: presetcolor1 = SColor(255, 255,78,80);  // summer coming
                presetcolor2 = SColor(255, 252,145,58);  
                presetcolor3 = SColor(255, 249,214,46);    
                presetcolor4 = SColor(255, 234,227,116);    
                presetcolor5 = SColor(255, 226,244,199); 
                colnum = 4;     
                break;   

        case 5: presetcolor1 = SColor(255, 254,0,0);  // neon
                presetcolor2 = SColor(255, 253,254,2);  
                presetcolor3 = SColor(255, 11,255,1);    
                presetcolor4 = SColor(255, 1,30,254);    
                presetcolor5 = SColor(255, 254,0,246);   
                colnum = 6;    
                break;   

        case 6: presetcolor1 = SColor(255, 60,255,0);  // electric love
                presetcolor2 = SColor(255, 124,255,0);  
                presetcolor3 = SColor(255, 176,255,0);    
                presetcolor4 = SColor(255, 201,255,0);    
                presetcolor5 = SColor(255, 214,255,0);   
                colnum = 4;    
                break;

        case 7: presetcolor1 = SColor(255, 20,232,30);  // aurora borealis
                presetcolor2 = SColor(255, 0,234,141);  
                presetcolor3 = SColor(255, 1,126,213);    
                presetcolor4 = SColor(255, 181,61,255);    
                presetcolor5 = SColor(255, 141,0,196);  
                colnum = 2;     
                break;

        case 8: presetcolor1 = SColor(255, 255,150,0);  // fire
                presetcolor2 = SColor(255, 255,175,0);  
                presetcolor3 = SColor(255, 255,200,0);    
                presetcolor4 = SColor(255, 255,225,0);    
                presetcolor5 = SColor(255, 255,250,0);  
                colnum = 1;     
                break; 

        case 9: presetcolor1 = SColor(255, 240,65,85);  // Frosty Fruit
                presetcolor2 = SColor(255, 255,130,58);  
                presetcolor3 = SColor(255, 242,242,111);    
                presetcolor4 = SColor(255, 255,247,189);    
                presetcolor5 = SColor(255, 149,207,183);  
                colnum = 5;     
                break;

        case 10: presetcolor1 = SColor(255, 255,39,0);  // red to purple
                 presetcolor2 = SColor(255, 167,4,4);  
                 presetcolor3 = SColor(255, 131,25,67);    
                 presetcolor4 = SColor(255, 127,53,141);    
                 presetcolor5 = SColor(255, 119,56,199);   
                 colnum = 3;    
                 break;

        case 11: presetcolor1 = SColor(255, 105,210,231);  // Giant Goldfish
                 presetcolor2 = SColor(255, 167,219,216);  
                 presetcolor3 = SColor(255, 224,228,204);    
                 presetcolor4 = SColor(255, 243,134,48);    
                 presetcolor5 = SColor(255, 250,105,0);  
                 colnum = 5;     
                 break;

        case 12: presetcolor1 = SColor(255, 255,253,247);  // jhakas
                 presetcolor2 = SColor(255, 212,243,32);  
                 presetcolor3 = SColor(255, 141,235,113);    
                 presetcolor4 = SColor(255, 8,197,184);    
                 presetcolor5 = SColor(255, 244,54,150);   
                 colnum = 6;    
                 break;

        case 13: presetcolor1 = SColor(255, 168,240,132);  // quilt
                 presetcolor2 = SColor(255, 223,251,121);  
                 presetcolor3 = SColor(255, 186,216,211);    
                 presetcolor4 = SColor(255, 238,213,155);    
                 presetcolor5 = SColor(255, 226,211,227); 
                 colnum = 4;     
                 break;

        case 14: presetcolor1 = SColor(255, 242,210,19);  // hint of lemon
                 presetcolor2 = SColor(255, 226,249,39);  
                 presetcolor3 = SColor(255, 246,225,13);    
                 presetcolor4 = SColor(255, 230,231,20);    
                 presetcolor5 = SColor(255, 239,253,22);   
                 colnum = 5;    
                 break;

        case 15: presetcolor1 = SColor(255, 9,0,255);  // fourth of july
                 presetcolor2 = SColor(255, 255,0,0);  
                 presetcolor3 = SColor(255, 255,255,255);    
                 presetcolor4 = SColor(255, 255,0,0);    
                 presetcolor5 = SColor(255, 9,0,255);    
                 colnum = 7;   
                 break;

        case 16: presetcolor1 = SColor(255, 119, 156, 255);  // generic fireworks
                 presetcolor2 = SColor(255, 200, 136, 255);  
                 presetcolor3 = SColor(255, 243, 147, 255);    
                 presetcolor4 = SColor(255, 255, 170, 239);    
                 presetcolor5 = SColor(255, 255, 224, 224);    
                 colnum = XORRandom(7);   
                 break;

        case 17: presetcolor1 = SColor(255, 255, 98, 59);  // fire cream
                 presetcolor2 = SColor(255, 255, 194, 102);  
                 presetcolor3 = SColor(255, 255, 141, 113);    
                 presetcolor4 = SColor(255, 255, 234, 147);    
                 presetcolor5 = SColor(255, 255, 239, 190);     
                 colnum = 5;  
                 break;

        default: break;     
    }
        this.set_u8("colnum", colnum);  
    
    int amount = 30; // Amount of Pixels.
    int type = (XORRandom(3));

    string effectname = "Emit Smoke";
    if(!CustomEmitEffectExists(effectname))
    { 
        SetupCustomEmitEffect( effectname, "FW_Explosion.as", "EmitFire", 10, 5, 45 );
        //SetupCustomEmitEffect( name, scriptfile, scriptfunction, u8 hard_freq, u8 chance_freq, u16 timeout )
    }
    u8 emiteffect = GetCustomEmitEffectID(effectname);

    if (type == 0) // big round bang
    {        

        //CreateAfterworks(this.getPosition(), this.getVelocity());
        for (int i = 0; i < amount; i++)
        {
            Vec2f vel = this.getVelocity() + getRandomVelocity(0, 1+XORRandom(4), 360);
            CParticle@ p1 = ParticlePixel( at, vel,  presetcolor1, true );

            if(p1 is null) return;

            p1.timeout = 20 + XORRandom(100);
            p1.scale = 1.0f + (XORRandom(35)*0.1f);
            p1.damping = 0.88f ;
            p1.Z = -10 + XORRandom(10);
            p1.gravity *= 0.02f;
            p1.rotates = true;
            p1.growth = 0.02f;
        }

        for (int i = 0; i < amount; i++)
        {
            Vec2f vel = this.getVelocity() + getRandomVelocity(0, 5+XORRandom(5), 360);
            CParticle@ p2 = ParticlePixel( at, vel, presetcolor2, true );
            if(p2 is null) return;

            p2.timeout = 20 + XORRandom(100);
            p2.scale = 1.0f + (XORRandom(30)*0.1f);
            p2.damping = 0.88f ;
            p2.Z = -10 + XORRandom(10);
            p2.gravity *= 0.02f;
            p2.growth = 0.02f;
        }

        for (int i = 0; i < amount; i++)
        {
            Vec2f vel = this.getVelocity() + getRandomVelocity(0, 10+XORRandom(5), 360);
            CParticle@ p3 = ParticlePixel( at, vel, presetcolor3, true );
            if(p3 is null) return;

            p3.timeout = 20 + XORRandom(100);
            p3.scale = 1.0f + (XORRandom(25)*0.1f);
            p3.damping = 0.88f ;
            p3.Z = -10 + XORRandom(10);
            p3.gravity *= 0.02f;
            p3.growth = 0.02f;
            p3.emiteffect = emiteffect;
        }

        for (int i = 0; i < amount; i++)
        {
            Vec2f vel = this.getVelocity() + getRandomVelocity(0, 15+XORRandom(5), 360);
            CParticle@ p4 = ParticlePixel( at, vel, presetcolor4, true );
            if(p4 is null) return;

            p4.timeout = 20 + XORRandom(100);
            p4.scale = 1.0f + (XORRandom(25)*0.1f);
            p4.damping = 0.88f ;
            p4.Z = -10 + XORRandom(10);
            p4.gravity *= 0.02f;
            p4.growth = 0.02f;
        }

        for (int i = 0; i < amount; i++)
        {
            Vec2f vel = this.getVelocity() + getRandomVelocity(0, 20+XORRandom(5), 360);
            CParticle@ p5 = ParticlePixel( at, vel, presetcolor5, true );
            if(p5 is null) return;

            p5.timeout = 20 + XORRandom(100);
            p5.scale = 1.0f + (XORRandom(20)*0.1f);
            p5.damping = 0.88f;
            p5.Z = -10 + XORRandom(10);
            p5.gravity *= 0.02f;
            p5.growth = 0.02f;
            p5.emiteffect = emiteffect;

        }
    }
    
    if (type == 1) // split
    { 
    
        for (int i = 0; i < amount; i++)
        {
            Vec2f pos = this.getPosition();
            
            Vec2f vel_1 = getRandomVelocity(0, 2, 360);
            vel_1.x = (XORRandom(2) == 0 ? 1.5f+i*0.2 : -1.5f-i*0.2);

            Vec2f vel_2 = getRandomVelocity(0, 1+XORRandom(2), 360);

            Vec2f vel_3 = getRandomVelocity(0, 2, 360);
            vel_3.y = (XORRandom(2) == 0 ? 1.5f+i*0.2 : -1.5f-i*0.2);

            CParticle@ p1 = ParticlePixel( at, vel_1,  presetcolor1, true );
            CParticle@ p2 = ParticlePixel( at, vel_1*0.75,  presetcolor2, true );
            CParticle@ p3 = ParticlePixel( at, vel_2,  presetcolor3, true );
            CParticle@ p4 = ParticlePixel( at, vel_3*0.75,  presetcolor4, true );
            CParticle@ p5 = ParticlePixel( at, vel_3,  presetcolor5, true );

            if(p1 is null) return;

            p1.timeout = 20 + XORRandom(50);
            p1.scale = 1.0f + (XORRandom(50)*0.1f);
            p1.damping = 0.92f;
            p1.Z = -10 + XORRandom(10);
            p1.gravity = Vec2f_zero;
            p1.emiteffect = emiteffect;

            if(p2 is null) return;

            p2.timeout = 20 + XORRandom(50);
            p2.scale = 1.0f + (XORRandom(40)*0.1f);
            p2.damping = 0.91f;
            p2.Z = -10 + XORRandom(10);
            p2.gravity = Vec2f_zero;

            if(p3 is null) return;

            p3.timeout = 20 + XORRandom(50);
            p3.scale = 1.0f + (XORRandom(30)*0.1f);
            p3.damping = 0.94f;
            p3.Z = -10 + XORRandom(10);
            p3.gravity = Vec2f_zero;

            if(p4 is null) return;

            p4.timeout = 20 + XORRandom(50);
            p4.scale = 1.0f + (XORRandom(25)*0.1f);
            p4.damping = 0.91f;
            p4.Z = -10 + XORRandom(10);
            p4.gravity = Vec2f_zero;

            if(p5 is null) return;

            p5.timeout = 20 + XORRandom(50);
            p5.scale = 1.0f + (XORRandom(50)*0.1f);
            p5.damping = 0.92f;
            p5.Z = -10 + XORRandom(10);
            p5.gravity = Vec2f_zero;
            p5.emiteffect = emiteffect;

        }
    }

    if (type == 2) // spray 2
    { 
        int steps = 80;
    
        for (int step = 0; step <= steps; ++step)
        {
            Vec2f vel = (this.getVelocity() + getRandomVelocity(0, 1+XORRandom(12), 360));

            CParticle@ p1 = ParticlePixel( at, vel*1.59,  presetcolor1, true );
            CParticle@ p2 = ParticlePixel( at, vel*1.58,  presetcolor2, true );
            CParticle@ p3 = ParticlePixel( at, vel*1.57,  presetcolor3, true );
            CParticle@ p4 = ParticlePixel( at, vel*1.56,  presetcolor4, true );
            CParticle@ p5 = ParticlePixel( at, vel*1.55,  presetcolor5, true );

            if(p1 is null) return;

            p1.timeout = 20 + XORRandom(50);
            p1.scale = 1.0f + (XORRandom(20)*0.1f);
            p1.damping = 0.80f;
            p1.Z = -10 + XORRandom(10);
            p1.gravity *= 0.02f;

            if(p2 is null) return;

            p2.timeout = 20 + XORRandom(50);
            p2.scale = 1.0f + (XORRandom(25)*0.1f);
            p2.damping = 0.85f;
            p2.Z = -10 + XORRandom(10);
            p2.gravity *= 0.04f;

            if(p3 is null) return;

            p3.timeout = 20 + XORRandom(50);
            p3.scale = 1.0f + (XORRandom(30)*0.1f);
            p3.damping = 0.80f;
            p3.Z = -10 + XORRandom(10);
            p3.gravity *= 0.06f;

            if(p4 is null) return;

            p4.timeout = 20 + XORRandom(50);
            p4.scale = 1.0f + (XORRandom(40)*0.1f);
            p4.damping = 0.85f;
            p4.Z = -10 + XORRandom(10);
            p4.gravity *= 0.08f;

            if(p5 is null) return;


            p5.emiteffect = emiteffect;
            p5.timeout = 20 + XORRandom(50);
            p5.scale = 1.0f + (XORRandom(50)*0.1f);
            p5.damping = 0.9f;
            p5.Z = -10 + XORRandom(10);
            p5.gravity *= 0.1f;

        }
    }

    if (type == 3) // spray 3
    { 
        int steps = 5;
        //CreateAfterworks(this.getPosition(), this.getVelocity());
    
        for (int step = 0; step <= steps; ++step)
        {
            Vec2f vel = (this.getVelocity() + getRandomVelocity(0, 1+XORRandom(12), 1080));

            CParticle@ p1 = ParticlePixel( at, vel*1.59,  presetcolor1, true );
            CParticle@ p2 = ParticlePixel( at, vel*1.58,  presetcolor2, true );
            CParticle@ p3 = ParticlePixel( at, vel*1.57,  presetcolor3, true );
            CParticle@ p4 = ParticlePixel( at, vel*1.56,  presetcolor4, true );
            CParticle@ p5 = ParticlePixel( at, vel*1.55,  presetcolor5, true );

            if(p1 is null) return;

            p1.timeout = 20 + XORRandom(50);
            p1.scale = 1.0f + (XORRandom(20)*0.1f);
            p1.damping = 0.80f;
            p1.Z = -10 + XORRandom(10);
            p1.gravity *= 0.02f;

            if(p2 is null) return;

            p2.timeout = 20 + XORRandom(50);
            p2.scale = 1.0f + (XORRandom(25)*0.1f);
            p2.damping = 0.85f;
            p2.Z = -10 + XORRandom(10);
            p2.gravity *= 0.04f;

            if(p3 is null) return;

            p3.timeout = 20 + XORRandom(50);
            p3.scale = 1.0f + (XORRandom(30)*0.1f);
            p3.damping = 0.80f;
            p3.Z = -10 + XORRandom(10);
            p3.gravity *= 0.06f;

            if(p4 is null) return;

            p4.timeout = 20 + XORRandom(50);
            p4.scale = 1.0f + (XORRandom(40)*0.1f);
            p4.damping = 0.85f;
            p4.Z = -10 + XORRandom(10);
            p4.gravity *= 0.08f;

            if(p5 is null) return;

            p5.timeout = 20 + XORRandom(50);
            p5.scale = 1.0f + (XORRandom(50)*0.1f);
            p5.damping = 0.9f;
            p5.Z = -10 + XORRandom(10);
            p5.gravity *= 0.1f;

        }
    }

    if (type == 4) //  2 way split
    { 
    
        for (int i = 0; i < amount; i++)
        {
            Vec2f pos = this.getPosition();
            
            Vec2f vel_1 = getRandomVelocity(0, 2, 360);
            vel_1.x = (XORRandom(2) == 0 ? 1.5f+i*0.2 : -1.5f-i*0.2);

            Vec2f vel_2 = getRandomVelocity(0, 1+XORRandom(2), 360);

            Vec2f vel_3 = getRandomVelocity(0, 2, 360);
            vel_3.y = (XORRandom(2) == 0 ? 1.5f+i*0.2 : -1.5f-i*0.2);

            CParticle@ p1 = ParticlePixel( at, vel_1,  presetcolor1, true );
            CParticle@ p2 = ParticlePixel( at, vel_1*0.75,  presetcolor2, true );
            CParticle@ p3 = ParticlePixel( at, vel_2,  presetcolor3, true );
            CParticle@ p4 = ParticlePixel( at, vel_3*0.75,  presetcolor4, true );
            CParticle@ p5 = ParticlePixel( at, vel_3,  presetcolor5, true );

            if(p1 is null) return;

            p1.timeout = 20 + XORRandom(50);
            p1.scale = 1.0f + (XORRandom(50)*0.1f);
            p1.damping = 0.92f;
            p1.Z = -10 + XORRandom(10);
            p1.gravity = Vec2f_zero;
            p1.emiteffect = emiteffect;

            if(p2 is null) return;

            p2.timeout = 20 + XORRandom(50);
            p2.scale = 1.0f + (XORRandom(40)*0.1f);
            p2.damping = 0.91f;
            p2.Z = -10 + XORRandom(10);
            p2.gravity = Vec2f_zero;

            if(p3 is null) return;

            p3.timeout = 20 + XORRandom(50);
            p3.scale = 1.0f + (XORRandom(30)*0.1f);
            p3.damping = 0.94f;
            p3.Z = -10 + XORRandom(10);
            p3.gravity = Vec2f_zero;

            if(p4 is null) return;

            p4.timeout = 20 + XORRandom(50);
            p4.scale = 1.0f + (XORRandom(25)*0.1f);
            p4.damping = 0.91f;
            p4.Z = -10 + XORRandom(10);
            p4.gravity = Vec2f_zero;

            if(p5 is null) return;

            p5.timeout = 20 + XORRandom(50);
            p5.scale = 1.0f + (XORRandom(50)*0.1f);
            p5.damping = 0.92f;
            p5.Z = -10 + XORRandom(10);
            p5.gravity = Vec2f_zero;
            p5.emiteffect = emiteffect;

        }
    }
}

void onTick(CBlob@ this)
{       
    if (this.getTickSinceCreated() >= 1)
    {  
        this.server_Die();
        return;
    }
}

void CreateAfterworks(Vec2f pos, Vec2f vel)
{  
    for (int step = 0; step <= 25; ++step)
    { 
        CBlob @blob = server_CreateBlob("fw_afterworks");
        if (blob !is null)
        {
            u8 angle = step;
            blob.setPosition(pos);
            //blob.setVelocity(getRandomVelocity(5, 5, angle));

            blob.AddScript("FW_Afterworks.as"); 
            blob.setAngleDegrees(angle*14.4f);    
        }
    }
}

void EmitFire(CParticle@ p)
{
     CBlob@ b = getBlobByName( "fw_explosion" );
        string texture;
        switch (b.get_u8("colnum"))
        {
            case 0: texture = "particle_trail_blue.png"; break;
            case 1: texture = "particle_trail_red.png"; break;
            case 2: texture = "particle_trail_green.png"; break;
            case 3: texture = "particle_trail_purple.png"; break;
            case 4: texture = "particle_trail_darkblue.png"; break;
            case 5: texture = "particle_trail_orange.png"; break;
            case 6: texture = "particle_trail_teal.png"; break;
            case 7: texture = "particle_trail_grey.png"; break;
        }

    TinyFires(p.position, 1, Vec2f(), texture);
}

    void TinyFires(Vec2f pos, int amount, Vec2f vel, string texture)
    {
        for (int j = 0; j < amount; j++)
        {
            CParticle@ p = ParticleAnimated( texture,
                                             pos,
                                             vel,
                                             0.0f,
                                             1.0f,
                                             3 + _r.NextRanged(2), //animtime
                                             -0.0f,
                                             true );

            if(p is null) return; //bail if we stop getting particles

            p.damping = 0.85f;
            p.collides = false;
            p.Z = -10.0f;

        }
    }