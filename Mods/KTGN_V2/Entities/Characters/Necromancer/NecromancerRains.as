#include "NecromancerCommon.as";

void SummonBlob(string name, Vec2f pos, int team)
{
    if (getNet().isServer())
        server_CreateBlob( name, team, pos );
}

namespace NecroRainTypes
{
    enum type{
        finished = 0,
        zombieRain,
        meteorRain,
        skeletonRain
    }
}

class NecroRain
{
    u8 type;
    u8 level;
    Vec2f position;
    int team;

    uint time;
    uint objectsAmount;

    NecroRain(CBlob@ blob, u8 i_type, u8 i_level, Vec2f pos)
    {
        type = i_type;
        level = i_level;
        position = pos;
        team = blob.getTeamNum();

        if (type == NecroRainTypes::zombieRain)
        {
            if (level == NecroParams::extra_ready)
                SummonBlob("zombieknight", position, team);
            objectsAmount = 5;
            if (level == NecroParams::extra_ready)
                objectsAmount += XORRandom(15);
            else if (level == NecroParams::cast_3)
                objectsAmount += XORRandom(10);
            else if (level == NecroParams::cast_2)
                objectsAmount += XORRandom(6);
            else if (level == NecroParams::cast_1)
                objectsAmount += XORRandom(3);
            time = 1 + XORRandom(6);
        }
        else if (type == NecroRainTypes::meteorRain)
        {
            objectsAmount = 5;
            if (level == NecroParams::extra_ready)
                objectsAmount += XORRandom(10);
            else if (level == NecroParams::cast_3)
                objectsAmount += XORRandom(8);
            else if (level == NecroParams::cast_2)
                objectsAmount += XORRandom(6);
            else if (level == NecroParams::cast_1)
                objectsAmount += XORRandom(3);
            time = 1 + XORRandom(6);
        }
        else if (type == NecroRainTypes::skeletonRain)
        {
            objectsAmount = 5;
            if (level == NecroParams::extra_ready)
                objectsAmount += XORRandom(15);
            else if (level == NecroParams::cast_3)
                objectsAmount += XORRandom(10);
            else if (level == NecroParams::cast_2)
                objectsAmount += XORRandom(6);
            else if (level == NecroParams::cast_1)
                objectsAmount += XORRandom(3);
            time = 1;
        }
    }

    void Manage()
    {
        time -= 1;
        if (time <= 0)
        {
            if (type == NecroRainTypes::zombieRain)
            {
                string[] possibleZombies = {"skeleton", "zombie"};
                if (level >= NecroParams::cast_3)
                {
                    possibleZombies.insertLast("greg");
                    possibleZombies.insertLast("wraith");
                }
                SummonBlob(possibleZombies[XORRandom(possibleZombies.length)], position + Vec2f(XORRandom(80) - 40, XORRandom(80) - 40), team);

                time = 1 + XORRandom(6);
            }
            else if (type == NecroRainTypes::meteorRain)
            {
                SummonBlob("meteor", Vec2f(position.x + 100.0f - XORRandom(200.0f), 20.0f), team);

                time = 1 + XORRandom(6);
            }
            else if (type == NecroRainTypes::skeletonRain)
            {
                SummonBlob("skeleton", position + Vec2f(XORRandom(80) - 40, XORRandom(80) - 40), team);
			    SummonBlob("skeleton", position + Vec2f(XORRandom(80) - 40, XORRandom(80) - 40), team);
                time = 1;
            }
            objectsAmount -= 1;
            if (objectsAmount <= 0)
            {
                type = NecroRainTypes::finished;
            }
        }
    }

    bool CheckFinished()
    {
        return (type == NecroRainTypes::finished);
    }
}

void onInit(CBlob@ this)
{
    this.addCommandID("rain");

    NecroRain[] rains;
    this.set("necromancerRains", rains);

    this.getCurrentScript().tickFrequency = getTicksASecond()/2;
    this.getCurrentScript().removeIfTag = "dead";
}

void onTick(CBlob@ this)
{
    if (!getNet().isServer())
        return;

    NecroRain[]@ rains;
    if (!this.get("necromancerRains", @rains)){
        return;
    }

    if (rains.length == 0)
        return;
    for (int i=rains.length-1; i>=0; i--)
    {
        if (rains[i].CheckFinished())
        {
            rains.removeAt(i);
        }
    }
    for (uint i=0; i<rains.length; i++)
        rains[i].Manage();
}

void addRain(CBlob@ this, string type, u8 level, Vec2f pos)
{
    NecroRain[]@ rains;
    if (!this.get("necromancerRains", @rains)){
        return;
    }
    if (!getNet().isServer())
        return;
    if (type == "zombie_rain")
        rains.insertLast(NecroRain(this, NecroRainTypes::zombieRain, level, pos));
    else if(type == "meteor_rain")
        rains.insertLast(NecroRain(this, NecroRainTypes::meteorRain, level, pos));
    else if(type == "skeleton_rain")
        rains.insertLast(NecroRain(this, NecroRainTypes::skeletonRain, level, pos));
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
    if (cmd == this.getCommandID("rain"))
    {
        string type = params.read_string();
        u8 charge_state = params.read_u8();
        Vec2f aimpos = params.read_Vec2f();
        addRain(this, type, charge_state, aimpos);
    }
}


/*
void ManageRains( CBlob@ this )
{
    if (this.hasTag("ZombieRain"))
    {
        s32 time = this.get_s32("zombiesTimeSpawn") - 1;
        if (time <= 0 )
        {
            Vec2f pos = this.get_Vec2f("zombiesRainPos") + Vec2f(20.0f - XORRandom(40.0f), 20.0f - XORRandom(40.0f));
            string name = zombieTypes[XORRandom(zombieTypes.length)];
            SummonZombie(name, pos,  this.getTeamNum());
            u8 zombiesToSpawn = this.get_u8("zombiesToSpawn");
            this.set_u8("zombiesToSpawn", zombiesToSpawn - 1);
            time = 15 + XORRandom(90);
        }
        if (this.get_u8("zombiesToSpawn") <= 0)
            this.Untag("ZombieRain");
        this.set_s32("zombiesTimeSpawn", time);    
    }// zombie_rain
    if (this.hasTag("SkeletonRain"))
    {
        s32 time = this.get_s32("skeletonsTimeSpawn") - 1;
        if (time <= 0 )
        {
            if (!getNet().isServer())
                return;
            Vec2f pos = Vec2f(this.get_Vec2f("skeletonsRainPos").x + 20.0f - XORRandom(40.0f), 20.0f);
            server_CreateBlob( "skeleton", this.getTeamNum(), pos );
            u8 skeletonsToSpawn = this.get_u8("skeletonsToSpawn");
            this.set_u8("skeletonsToSpawn", skeletonsToSpawn - 1);
            this.set_s32("skeletonsTimeSpawn", 15 + XORRandom(90));
        }
        if (this.get_u8("skeletonsToSpawn") <= 0)
            this.Untag("SkeletonRain");
        this.set_s32("skeletonsTimeSpawn", time);     
    }// meteor_rain
    if (this.hasTag("MeteorRain"))
    {
        s32 time = this.get_s32("meteorsTimeSpawn") - 1;
        if (time <= 0 )
        {
            if (!getNet().isServer())
                return;
            Vec2f pos = Vec2f(this.get_Vec2f("meteorsRainPos").x + 100.0f - XORRandom(200.0f), 20.0f);
            server_CreateBlob( "skeleton", this.getTeamNum(), pos );
            u8 meteorsToSpawn = this.get_u8("meteorsToSpawn");
            this.set_u8("meteorsToSpawn", meteorsToSpawn - 1);
            time = 15 + XORRandom(60);
        }
        if (this.get_u8("meteorsToSpawn") <= 0)
            this.Untag("MeteorRain");
        this.set_s32("meteorsTimeSpawn", time);     
    }// meteor_rain
}*/