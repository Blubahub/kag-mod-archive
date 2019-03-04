#include "Logging.as";

namespace Powers {
    shared enum pows {
        BEGIN = 0, // as a marker for looping
        BOUNCE,
        STRENGTH,
        VAMPIRISM,
        DRAIN,
        SPEED,
        QUICK_ATTACK,
        MOUNTAIN,
        FEATHER,
        TRIPLE_JUMP,
        MONKEY,
        MIDAS,
        FIRE_LORD,
        FORCE,
        GHOST,
        END
    }
}

string getPowerName(u8 pow) {
    switch(pow) {
        case Powers::BOUNCE: return "Bounce";
        case Powers::STRENGTH: return "Strength";
        case Powers::VAMPIRISM: return "Vampirism";
        case Powers::DRAIN: return "Drain";
        case Powers::SPEED: return "Speed";
        case Powers::QUICK_ATTACK: return "Quick Attack";
        case Powers::MOUNTAIN: return "Mountain";
        case Powers::FEATHER: return "Feather";
        case Powers::TRIPLE_JUMP: return "Triple Jump";
        case Powers::MONKEY: return "Monkey";
        case Powers::MIDAS: return "Midas";
        case Powers::FIRE_LORD: return "Fire Lord";
        case Powers::FORCE: return "The Force";
        case Powers::GHOST: return "Ghost";
    }
    return "No Power";
}

string getPowerScriptName(u8 pow) {
    switch(pow) {
        case Powers::BOUNCE: return "PowerBounce.as";
        case Powers::STRENGTH: return "PowerStrength.as";
        case Powers::VAMPIRISM: return "PowerVampirism.as";
        case Powers::DRAIN: return "PowerDrain.as";
        case Powers::SPEED: return "PowerSpeed.as";
        case Powers::QUICK_ATTACK: return "PowerQuickAttack.as";
        case Powers::MOUNTAIN: return "PowerMountain.as";
        case Powers::FEATHER: return "PowerFeather.as";
        case Powers::TRIPLE_JUMP: return "PowerTripleJump.as";
        case Powers::MONKEY: return "PowerMonkey.as";
        case Powers::MIDAS: return "PowerMidas.as";
        case Powers::FIRE_LORD: return "PowerFireLord.as";
        case Powers::FORCE: return "PowerForce.as";
        case Powers::GHOST: return "PowerGhost.as";
    }
    return "";
}

string getPowerTip(u8 pow) {
    switch(pow) {
        case Powers::BOUNCE: return "The Bounce power makes you immune to fall damage.";
        case Powers::STRENGTH: return "The Strength power makes your attacks stronger and allows you to damage stone blocks.";
        case Powers::VAMPIRISM: return "The Vampirism power makes your attacks heals you.";
        case Powers::DRAIN: return "The Drain power drains the health of enemies near you.";
        case Powers::SPEED: return "The Speed power makes you move much faster.";
        case Powers::QUICK_ATTACK: return "The Quick Attack power increases your slashing speed.";
        case Powers::MOUNTAIN: return "The Mountain power makes you take 50% damage at the cost of extra weight.";
        case Powers::FEATHER: return "The Feather power makes you very light - try shield gliding!";
        case Powers::TRIPLE_JUMP: return "The Triple Jump power lets you jump 3 times.";
        case Powers::MONKEY: return "The Monkey power allows you to climb walls and ceilings.";
        case Powers::MIDAS: return "The Midas power makes you very rich!";
        case Powers::FIRE_LORD: return "The Fire Lord power burns things around you and enemies you touch.";
        case Powers::FORCE: return "To use The Force, aim your mouse at something and press E.";
        case Powers::GHOST: return "The Ghost power allows you to move through objects.";
    }
    return "";
}

bool hasPower(CBlob@ blob, u8 pow) {
    return blob.hasTag(getPowerName(pow));
}

void givePower(CBlob@ blob, u8 pow) {
    log("givePower", "Assigning power " + getPowerName(pow) + " to " + blob.getName());
    if (!blob.hasCommandID("receive_power")) {
        log("givePower", "ERROR: Blob doesn't have receive_power command ID");
    }
    else {
        CBitStream params;
        params.write_u8(pow);
        blob.SendCommand(blob.getCommandID("receive_power"), params);
    }
}
