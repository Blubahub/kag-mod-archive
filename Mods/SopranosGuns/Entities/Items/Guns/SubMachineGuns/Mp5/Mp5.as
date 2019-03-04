#include "Hitters.as";

//const uint8 FIRE_INTERVAL = 4;
//const float BULLET_DAMAGE = 1;
//const uint8 PROJECTILE_SPEED = 20; 

const uint8 FIRE_INTERVAL = 1;
const float BULLET_DAMAGE = 1.8; // Buffed from 1.5 - 1.8
const uint8 PROJECTILE_SPEED = 20; // same as chicom
const float TIME_TILL_DIE = 0.7; // buffed from 0.5 to 0.7

const uint8 CLIP = 30; // RL Mp5 clip is 30
const uint8 TOTAL = 120;
const uint8 RELOAD_TIME = 23; // Slighly faster than Chicom

const string AMMO_TYPE = "bullet";

const string FIRE_SOUND = "AssaultFire.ogg";
const string RELOAD_SOUND  = "Reload.ogg";

const Vec2f RECOIL = Vec2f(1.0f,0.0);
const float BULLET_OFFSET_X = 10;
const float BULLET_OFFSET_Y = 0;

#include "StandardFire.as";
#include "GunStandard";
