//common wizard header
const bool IS_TEST = sv_rconpassword == "kwasss";
//vars
const int TELEPORT_FREQUENCY = (IS_TEST ? 25 : 250);
const int TELEPORT_DISTANCE = 68*8;//getMap().tilesize;

const int FIRE_FREQUENCY = 15;
const f32 ORB_SPEED = 3.0f;
const u8 ORB_LIMIT = 5;
const u32 ORB_BURST_COOLDOWN = (IS_TEST ? 25 : 330);

