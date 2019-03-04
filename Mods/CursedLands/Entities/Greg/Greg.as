#include "EmotesCommon.as"
#include "Knocked.as"

Random gregRand;

void resetTimeout(CBlob@ this)
{
    this.set_u32("timeout", getGameTime());

}

u32 getElapsedTime(CBlob@ this)
{
    return getGameTime() - this.get_u32("timeout");

}

void pickRandTargetPos(CBlob@ this)
{
    CMap@ map = this.getMap();
    int width = map.tilemapwidth*8;
    Vec2f npos(Maths::Abs(gregRand.Next())%width, 20.0f + gregRand.Next()%40);
    this.set_Vec2f("target pos", npos);
    printVec2f("greg go to", npos);
    
    this.set_bool("use pos", true);
    resetTimeout(this);

}

void pickRandPlayer(CBlob@ this)
{

    this.Untag("doneparis");
    this.Untag("paris");

    CBlob@[] players;
    getBlobsByTag("player", players);
    if(players.size() == 0)
    {
        this.set_bool("no target", true);
        pickRandTargetPos(this);
        return;

    }
    u16 targetId = players[gregRand.Next()%players.size()].getNetworkID();
    this.set_u16("targetId", targetId);
    this.set_bool("no target", false);
    this.set_bool("use pos", false);
    resetTimeout(this);

}

CBlob@ getTarget(CBlob@ this)
{
    if(this.get_bool("no target") || this.get_bool("use pos"))
    {
        return null;

    }

    u16 targetId = this.get_u16("targetId");
    CBlob@ target = getBlobByNetworkID(targetId);
    return target;

}

Vec2f getTargetPos(CBlob@ this)
{
    return this.get_Vec2f("target pos");

}

bool useTargetPos(CBlob@ this)
{
    return this.get_bool("use pos");

}

void onInit(CBlob@ this)
{
    pickRandTargetPos(this);
    this.getCurrentScript().tickFrequency = 5;

    CSprite@ sprite = this.getSprite();
    if(sprite !is null)
    {
        sprite.SetEmitSound("Wings.ogg");
        sprite.SetEmitSoundPaused(false);

    }

    Sound::Play("GregCry.ogg", this.getPosition());
    this.server_setTeamNum(255); //greg team

    

}

void onTick(CBlob@ this)
{
    //do knocking logic
    DoKnockedUpdate(this);

    CBlob@ target = getTarget(this);
    Vec2f targetP = getTargetPos(this);
    bool usepos = useTargetPos(this);

    bool targetAttached = this.isAttachedTo(target);

    //check if we need a new target.
    if((target is null || target.hasTag("dead")) && !usepos)
    {
        pickRandTargetPos(this);
        return;

    }

    //in case greg gets stuck start doing something else
    if(!targetAttached)
    {
        u32 elapsed = getElapsedTime(this);
        if(usepos && elapsed > 30*10)
        {
            pickRandPlayer(this);

        }
        else if(target !is null && elapsed > 30*30) //go after player for a long time
        {
            pickRandTargetPos(this);
        
        }

    }

    u8 knocked = this.get_u8("knocked");
    if(knocked > 0)
    {
        if(targetAttached)
        {
            this.server_DetachAll();
            pickRandTargetPos(this);


        }

        return;

    }

    //if on fire drop target
    s16 burn_time = this.get_s16("burn timer");
    if(this.isInFlames() || burn_time > 0)
    {
        if(targetAttached)
        {
            this.server_DetachAll();

        }

       pickRandTargetPos(this);

    }

    Vec2f vel = this.getVelocity();

    //set the facing of the greg towards the target
    if(!targetAttached)
    {
        bool faceLeft = (vel.x > 0);
        this.SetFacingLeft(faceLeft);

    }

    Vec2f targetPos = usepos ? targetP : target.getPosition();

    if(vel.y > 4) //flap to slow decent
    {
        //120 is enough for a strong flap which actually caries the greg up
        this.setVelocity(Vec2f(vel.x, 3.85f));

        //if we have our target flap into the air.
        f32 force = 70.0f;
        if(targetAttached || (usepos && targetPos.y < this.getPosition().y
            || (target !is null && targetPos.y < this.getPosition().y)))
        {
            force += 20.0f;

        }

        this.AddForce(Vec2f(0, -force));

        //Sound::Play("Wings.ogg", this.getPosition());

    }
    else if(this.isOnGround()) //get off the ground
    {
        this.setVelocity(Vec2f(vel.x, 0.0f));
        this.AddForce(Vec2f(0, -70.0f));

    }

    Vec2f gregPos = this.getPosition();

    //if we are close to our node
    Vec2f dif = targetPos - gregPos;
    if(usepos && dif.Length() < 25.0f)
    {
        pickRandPlayer(this);

    }

    if(targetAttached)
    {
        //drop the player
        CMap@ map = this.getMap();
        f32 distToGround = map.getLandYAtX(gregPos.x/8.0f)*8.0f - gregPos.y;
        if(distToGround > 240.0f && !is_emote(this, Emotes::troll) && !this.hasTag("doneparis"))
        {
            if(this.hasTag("paris"))
            {
                this.Tag("doneparis");
                this.Chat("i lied.");
            }

            set_emote(this, Emotes::troll);

        }

        if(distToGround > 260.0f)
        {
            //detach and add some velocity so they hopefully die.
            this.server_DetachAll();
            this.set_bool("no target", true);
            target.setVelocity(Vec2f(0, 8.0f));

        }

    }

    f32 absVelx = Maths::Abs(vel.x);
    //don't accelarte to quickly
    if(absVelx < 5)
    {
        //calculate a rough distance factor to mult by
        f32 xdist = (gregPos.x - targetPos.x)/50.0f;
        xdist = Maths::Min(Maths::Abs(xdist), 1.0f);

        f32 force = xdist*5.0f;

        f32 stopping = absVelx/10.0f;

        //move towards target
        if(gregPos.x > targetPos.x)
        {
            this.AddForce(Vec2f(-force, 0));

            //apply a stopping force so we start going the other dir quicker
            if(vel.x > 0)
            {
                this.AddForce(Vec2f(-40.0f*stopping, 0));

            }

        }
        else if(gregPos.x < targetPos.x)
        {
            this.AddForce(Vec2f(force, 0));

            if(vel.x < 0)
            {
                this.AddForce(Vec2f(40.0f*stopping, 0));

            }


        }

    }

}

void onCollision( CBlob@ this, CBlob@ blob, bool solid )
{
    u8 knocked = this.get_u8("knocked");
    if(knocked > 0 || blob is null || !solid)
    {
        return;

    }

    CBlob@ target = getTarget(this);
    if(target is blob)
    {
        this.server_AttachTo(blob, this.getAttachmentPoint(0));
        this.setVelocity(Vec2f_zero);
        this.AddForce(Vec2f(0, -30.0f)); //get a little hop up into the air going.

        if(gregRand.Next()%5 == 0)
        {
            this.Tag("paris");
            this.Chat("we're going to paris.");
            Sound::Play("MigrantSayHello.ogg", this.getPosition());

        }
        else
        {
            Sound::Play("GregRoar.ogg", this.getPosition()); //play sound

        }

        SetKnocked(blob, 60); //kock the player when we first pick them up so they can't fight back
        blob.Tag("dazzled");

        //make player play the stunned sound
        blob.getSprite().PlaySound("Stun.ogg", 1.0f, this.getSexNum() == 0 ? 1.0f : 2.0f);

    }

}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
    return blob.getName() != "greg";

}
