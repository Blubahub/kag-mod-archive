#include "Logging.as";
#include "PowersCommon.as";

void onInit(CBlob@ this)
{
    log("onInit", "ReceivePower onInit called.");
    this.addCommandID("receive_power");
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
    log("onCommand", "called");
    if (cmd == this.getCommandID("receive_power"))
    {
        printf("commandID is receive_power!");
        u8 pow;
        if (!params.saferead_u8(pow)) {
            log("onCommand", "ERROR: Couldn't read pow from params");
        }
        else {
            log("onCommand", "Assigning power " + getPowerName(pow) + " to " + this.getName());
            if (!this.hasTag(getPowerName(pow))) {
                this.Tag(getPowerName(pow));
            }

			// Shouldn't matter if we add the script twice
			// In fact this solves a bug of the hasTag clause above
			// preventing the script being run client side as well as server side
			if (getPowerScriptName(pow) != "") {
				this.AddScript(getPowerScriptName(pow));
			}

			// Force GUI
			if (pow == Powers::FORCE) {
				this.getSprite().AddScript(getPowerScriptName(pow));
			}
        }
    }
}
