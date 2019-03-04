#include "Hitters.as";

const uint8 FIRE_INTERVAL = 50; //105
const float BULLET_DAMAGE = 6;
const uint8 PROJECTILE_SPEED = 35; 
const float TIME_TILL_DIE = 0.5;

const uint8 CLIP = 5;
const uint8 TOTAL = 15;
const uint8 RELOAD_TIME = 50;

const string AMMO_TYPE = "bullet";
const bool SNIPER = true;
const uint8 SNIPER_TIME = 15;

const string FIRE_SOUND = "SniperFire.ogg";
const string RELOAD_SOUND  = "Reload.ogg";

const Vec2f RECOIL = Vec2f(1.0f,0.0);
const float BULLET_OFFSET_X = 4;
const float BULLET_OFFSET_Y = 0;

#include "SniperFire.as";
#include "SniperStandard.as";
