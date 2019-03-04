#include "Hitters.as";
#include "StandardFire.as";
const uint8 FIRE_INTERVAL    = 4; //Used maybe?
const float BULLET_DAMAGE    = 0.7;   //Unused
const uint8 PROJECTILE_SPEED = 27;  //Unused
const float TIME_TILL_DIE    = 0.9; //Unused

const uint8 CLIP        = 32; //Used
const uint8 TOTAL       = 150; //Used
const uint8 RELOAD_TIME = 16; //Used, reload timer (in ticks)


//NEW BULLET PROPS
const int8  B_SPREAD = 0; //the higher the value, the more 'uncontrolable' bullets get
const Vec2f B_SPEED  = Vec2f(0,0.025); //DEFAULT, bullet stuff is very 'weird' currently, use and expirement
const int8  B_TTL    = 100; //TTL = Time To Live, bullets will live for 120 ticks before getting destory IF nothing has been hit
const float B_DAMAGE = 0.7; //1 heart
const Vec2f B_KB     = Vec2f(0,0); //KnockBack velocity on hit


const string AMMO_TYPE   = "bullet"; //Used i think?
const string AMMO_SPRITE = "Bullet.png"; //Unused
const bool SNIPER        = false; //Unused
const uint8 SNIPER_TIME  = 0; //Unused

const string FIRE_SOUND    = "mp40.ogg.ogg"; //Used
const string RELOAD_SOUND  = "Reload.ogg"; //Used

const Vec2f RECOIL = Vec2f(1.0f,0.0); //Unused probably
const float BULLET_OFFSET_X = 6; // ^
const float BULLET_OFFSET_Y = 0; // ^