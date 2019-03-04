#include "Hitters.as";

const uint8 FIRE_INTERVAL = 3;
const float BULLET_DAMAGE = 0; //Irrelevent
const uint8 PROJECTILE_SPEED = 10; 
const float TIME_TILL_DIE = 120; //Irrelevent

const uint8 CLIP = 15;
const uint8 TOTAL = 45;
const uint8 RELOAD_TIME = 60;

const string AMMO_TYPE = "flame";
const bool SNIPER = false;
const uint8 SNIPER_TIME = 0;

const string FIRE_SOUND = "FlamethrowerFire.ogg";
const string RELOAD_SOUND  = "Reload.ogg";

const Vec2f RECOIL = Vec2f(0.0f,0.0);
const float BULLET_OFFSET_X = 23;
const float BULLET_OFFSET_Y = -4;

#include "StandardFire.as";
#include "GunStandard";