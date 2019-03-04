//common wizard header
const bool IS_TEST = sv_rconpassword == "kwasss";
//vars
const int TELEPORT_FREQUENCY = (IS_TEST ? 25 : 100);
const int TELEPORT_DISTANCE = 100;//getMap().tilesize;

const int FIRE_FREQUENCY = 20;
const f32 ORB_SPEED = 3.0f;
const u8 ORB_LIMIT = 3;
const u32 ORB_BURST_COOLDOWN = (IS_TEST ? 25 : 200);

