#include "Logging.as"

void onInit(CBlob@ this) {
    this.getCurrentScript().tickFrequency = 30;
}

void onTick(CBlob@ this) {
    CBlob@[] players;
    getBlobsByTag("player", players);

    if (players.length > 0) {
        CBlob@ player = players[0];
        this.SetFacingLeft(player.getPosition().x < this.getPosition().x);
    }
}
