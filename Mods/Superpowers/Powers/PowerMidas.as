#include "Logging.as";
#include "RunnerCommon.as";

const int COIN_DROP_FREQ = 30; 
const int COIN_DROP_AMOUNT = 10;
const int MIDAS_FREQ = 2;

void onTick(CBlob@ this) {
    if (getGameTime() % COIN_DROP_FREQ == 0) {
        if (this.getVelocity().Length() > 0)
            server_DropCoins(this.getPosition(), COIN_DROP_AMOUNT);
	}

	if (getGameTime() % MIDAS_FREQ == 0) {
		float tx = this.getPosition().x;
		float ty = this.getPosition().y;
		Vec2f[] checkPositions = {};
		if (this.isOnGround()) {
			checkPositions.push_back(Vec2f(tx-8, ty+8));
			checkPositions.push_back(Vec2f(tx, ty+8));
			checkPositions.push_back(Vec2f(tx+8, ty+8));
		}
		
		if (this.isOnWall()) {
			checkPositions.push_back(Vec2f(tx-8, ty+8)); 
			checkPositions.push_back(Vec2f(tx-8, ty));
			checkPositions.push_back(Vec2f(tx-8, ty-8));
			checkPositions.push_back(Vec2f(tx+8, ty+8));
			checkPositions.push_back(Vec2f(tx+8, ty));
			checkPositions.push_back(Vec2f(tx+8, ty-8));
		}

		if (this.isOnCeiling()) {
			checkPositions.push_back(Vec2f(tx-8, ty-8)); 
			checkPositions.push_back(Vec2f(tx, ty-8));
			checkPositions.push_back(Vec2f(tx+8, ty-8));
		}

		for (int i=0; i < checkPositions.length; i++) {
			Vec2f pos = checkPositions[i];
			u16 t = getMap().getTile(pos).type;
			if (t == CMap::tile_ground ||
					t == CMap::tile_castle ||
					t == CMap::tile_stone ||
					t == CMap::tile_wood) {
				getMap().server_SetTile(pos, CMap::tile_gold);
			}
		}
	}
}
