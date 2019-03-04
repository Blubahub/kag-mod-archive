#include "EmotesCommon.as"
#include "Logging.as"

u8[] happy_emotes = {
    Emotes::note,
    Emotes::smile,
    Emotes::laugh,
    Emotes::thumbsup
};

u8[] sad_emotes = {
    Emotes::mad,
    Emotes::disappoint,
    Emotes::cry,
    Emotes::thumbsdown
};

void onInit(CBlob@ this) {
    this.addCommandID("score basket");
    this.getCurrentScript().tickFrequency = 90;
}

void onTick(CBlob@ this) {
    if (XORRandom(10) == 0) {
        doHappyEmote(this);
    }
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params) {
    if (cmd == this.getCommandID("score basket")) {
        //log("onCommand", "score basket command received");

        if (XORRandom(5) > 3) {
            return;
        }

        uint8 basketNum = params.read_u8();

        float mapMid = getMap().tilemapwidth * 8 / 2.0;
        bool happy = false;
        if (basketNum == 1 && this.getPosition().x > mapMid) {
            happy = true;
        }
        else if (basketNum == 2 && this.getPosition().x < mapMid) {
            happy = true;
        }

        if (happy) {
            doHappyEmote(this);
        }
        else {
            doSadEmote(this);
        }
    }
}

void doHappyEmote(CBlob@ this) {
    set_emote(this, happy_emotes[XORRandom(happy_emotes.length)]);
}

void doSadEmote(CBlob@ this) {
    set_emote(this, sad_emotes[XORRandom(sad_emotes.length)]);
}
