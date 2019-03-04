#include "Hitters.as";

const uint8 FIRE_INTERVAL = 9; //10 to
const float BULLET_DAMAGE = 0.5; //0.4 to
const uint8 PROJECTILE_SPEED = 23; //15 to
const float TIME_TILL_DIE = 0.9; // 0.5 to 

const uint8 CLIP = 9;
const uint8 TOTAL = 48;
const uint8 RELOAD_TIME = 4; //14 to

const string AMMO_TYPE = "bullet";

const string FIRE_SOUND = "PistolFire.ogg";
const string RELOAD_SOUND  = "Reload.ogg";

const Vec2f RECOIL = Vec2f(1.0f,0.0);
const float BULLET_OFFSET_X = 8;
const float BULLET_OFFSET_Y = 1;

#include "StandardFire.as";
#include "GunStandard";
