#include "PowersCommon.as";
#include "Logging.as";

#define SERVER_ONLY

// A bug occurred where, when players spawn onSetPlayer is called immediately and a power is assigned
// but the blob hasn't been created on the client yet so the client never receives the power message.
// To prevent this we wait until 1 tick after the onSetPlayer hook to perform the assignments, keeping a queue from the prev tick.
uint16[] blobs;
uint16[] players;
u32 lastOnSetPlayerTick = 0;

void onSetPlayer(CRules@ this, CBlob@ blob, CPlayer@ player) {
    if (blob !is null && player !is null) {
        log("onSetPlayer", "Called: " + blob.getName() + ", " + player.getUsername());
        blobs.push_back(blob.getNetworkID());
        players.push_back(player.getNetworkID());
        lastOnSetPlayerTick = getGameTime();
    }
}

void onTick(CRules@ this) {
    if (lastOnSetPlayerTick < getGameTime() && blobs.length > 0) {
        uint16 blobID = blobs[0];
        uint16 playerID = players[0];
        blobs.removeAt(0);
        players.removeAt(0);

        CBlob@ blob = getBlobByNetworkID(blobID);
        CPlayer@ player = getPlayerByNetworkId(playerID);

        if (blob is null) {
            log("onTick", "ERROR: blob is null");
        }
        else if (player is null) {
            log("onTick", "ERROR: player is null");
        }
        else {
            PostOnSetPlayer(this, blob, player);
        }
    }
}

void PostOnSetPlayer(CRules@ this, CBlob@ blob, CPlayer@ player) {
    log("PostOnSetPlayer", "Called for " + blob.getName() + ", " + player.getUsername());
    u8[] untakenPowers = GetUntakenPowers(this);
    if (untakenPowers.length == 0) {
        log("onSetPlayer", "ERROR: No untaken powers!");
        return;
    }

    int ix = XORRandom(untakenPowers.length);
    u8 pow = untakenPowers[ix];
    givePower(blob, pow);
}

u8[] GetUntakenPowers(CRules@ this) {
    dictionary powerTakenStates; // true for taken, false for not
    CBlob@[] playerBlobs;
    u8[] untakenPowers;

    for (u8 pow=Powers::BEGIN+1; pow < Powers::END; pow++) {
        powerTakenStates.set(""+pow, false);
    }

    getBlobsByTag("player", playerBlobs);
    for (int i=0; i < playerBlobs.length; i++) {
        CBlob@ blob = playerBlobs[i];

        for (u8 pow=Powers::BEGIN+1; pow < Powers::END; pow++) {
            if (hasPower(blob, pow))
                powerTakenStates.set(""+pow, true);
        }
    }

    for (u8 pow=Powers::BEGIN+1; pow < Powers::END; pow++) {
        bool isTaken;
        powerTakenStates.get(""+pow, isTaken);
        if (!isTaken)
            untakenPowers.push_back(pow);
    }
    return untakenPowers;
}
