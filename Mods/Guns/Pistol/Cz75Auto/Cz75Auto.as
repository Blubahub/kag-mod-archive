#include "Hitters.as";

const uint8 FIRE_INTERVAL = 2;
const float BULLET_DAMAGE = 2;
const uint8 PROJECTILE_SPEED = 20; 
const float TIME_TILL_DIE = 0.3;

const uint8 CLIP = 12;
const uint8 TOTAL = 24;
const uint8 RELOAD_TIME = 25;

const string AMMO_TYPE = "bullet";
const bool SNIPER = false;
const uint8 SNIPER_TIME = 0;

const string FIRE_SOUND = "PistolFire.ogg";
const string RELOAD_SOUND  = "Reload.ogg";

const Vec2f RECOIL = Vec2f(1.0f,0.0);
const float BULLET_OFFSET_X = 8;
const float BULLET_OFFSET_Y = 1;

#include "StandardFire.as";
#include "GunStandard";
