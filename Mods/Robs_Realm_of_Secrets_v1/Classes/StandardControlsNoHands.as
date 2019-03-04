// Standard menu player controls

#include "EmotesCommon.as"
#include "StandardControlsCommonNoHands.as"

int zoomLevel = 1; // we can declare a global because this script is just used by myPlayer

void onInit(CBlob@ this)
{
	this.set_s32("tap_time", getGameTime());
	CBlob@[] blobs;
	this.set("pickup blobs", blobs);
	this.set_u16("hover netid", 0);
	this.set_bool("release click", false);
	this.set_bool("can button tap", true);
	this.addCommandID("pickup");
	this.addCommandID("putin");
	this.addCommandID("getout");
	this.addCommandID("detach");
	this.addCommandID("cycle");

	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getCurrentScript().removeIfTag = "dead";
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (!getNet().isServer())                                // server only!
	{
		return;
	}

	if (cmd == this.getCommandID("detach"))
	{
		CBlob@ obj = getBlobByNetworkID(params.read_netid());

		if (obj !is null)
		{
			this.server_DetachFrom(obj);
		}
	}
	else if (cmd == this.getCommandID("getout"))
	{
		if (this.getInventoryBlob() !is null)
		{
			this.getInventoryBlob().server_PutOutInventory(this);
		}
	}
}

void onTick(CBlob@ this)
{
	if (getCamera() is null)
	{
		return;
	}
	ManageCamera(this);
}

// show dots on chat

void onEnterChat(CBlob @this)
{
	set_emote(this, Emotes::dots, 100000);
}

void onExitChat(CBlob @this)
{
	set_emote(this, Emotes::off);
}

void onDie(CBlob@ this)
{
	set_emote(this, Emotes::off);
}

// CAMERA

void ManageCamera(CBlob@ this)
{
	CCamera@ camera = getCamera();
	f32 zoom = camera.targetDistance;
	CControls@ controls = this.getControls();

	// mouse look & zoom
	if ((getGameTime() - this.get_s32("tap_time") > 5) && controls !is null)
	{
		if (controls.isKeyJustPressed(controls.getActionKeyKey(AK_ZOOMOUT)))
		{
			if (zoomLevel == 2)
			{
				zoomLevel = 1;
			}
			else if (zoomLevel == 1)
			{
				zoomLevel = 0;
			}
			else if (zoomLevel == 3)
			{
				zoomLevel = 0;
			}

			Tap(this);
		}
		else  if (controls.isKeyJustPressed(controls.getActionKeyKey(AK_ZOOMIN)))
		{
			if (zoomLevel == 0)
			{
				zoomLevel = 3;
			}
			else if (zoomLevel == 3)
			{
				zoomLevel = 2;
			}
			else if (zoomLevel == 1)
			{
				zoomLevel = 2;
			}

			Tap(this);
		}
	}

	f32 zoomSpeed = 0.1f;
	f32 minZoom = 0.5f; // TODO: make vars
	f32 maxZoom = 2.0f;

	if (zoomLevel == 1 && (this.wasKeyPressed(key_use) || this.wasKeyPressed(key_pickup)))
	{
		zoom = 1.0f;
	}

	switch (zoomLevel)
	{
		case 0:
			if (zoom > 0.5f)
			{
				zoom -= zoomSpeed;
			}

			break;

		case 1:
			if (zoom > 1.0f)
			{
				zoom -= zoomSpeed;
			}
			else
			{
				zoom = 1.0f;
			}

			break;

		case 2:
			if (zoom < maxZoom)
			{
				zoom += zoomSpeed;
			}

			break;

		case 3:
			if (zoom < 1.0f)
			{
				zoom += zoomSpeed;
			}
			else
			{
				zoom = 1.0f;
			}

			break;

		default:
			zoom = 1.0f;
			break;
	}

	// security check

	if (zoom < minZoom)
	{
		zoom = minZoom;
	}

	if (zoom > maxZoom)
	{
		zoom = maxZoom;
	}


	bool fixedCursor = true;
	if (zoom < 1.0f)  // zoomed out
	{
		camera.mousecamstyle = 1; // fixed
	}
	else
	{
		// gunner
		if (this.isAttachedToPoint("GUNNER"))
		{
			camera.mousecamstyle = 2;
		}
		else if (g_fixedcamera) // option
		{
			camera.mousecamstyle = 1; // fixed
		}
		else
		{
			camera.mousecamstyle = 2; // soldatstyle
		}
	}

	// camera
	camera.mouseFactor = 0.5f; // doesn't affect soldat cam
	camera.targetDistance = zoom;
}


