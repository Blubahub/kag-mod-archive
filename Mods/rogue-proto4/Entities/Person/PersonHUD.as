//archer HUD

#include "/Entities/Common/GUI/ActorHUDStartPos.as";

const string iconsFilename = "Entities/Characters/Builder/BuilderIcons.png";
const int slotsSize = 6;

void onInit(CSprite@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getCurrentScript().removeIfTag = "dead";
	this.getBlob().set_u8("gui_HUD_slots_width", slotsSize);
}

void ManageCursors(CBlob@ this)
{
	// set cursor
	if (getHUD().hasButtons())
	{
		getHUD().SetDefaultCursor();
	}
	else
	{
		if (this.isAttached() && this.isAttachedToPoint("GUNNER"))
		{
			getHUD().SetCursorImage("Entities/Characters/Archer/ArcherCursor.png", Vec2f(32, 32));
			getHUD().SetCursorOffset(Vec2f(-32, -32));
		}
		else
		{
			getHUD().SetCursorImage("Entities/Characters/Builder/BuilderCursor.png");
		}

	}
}

void onRender(CSprite@ this)
{
	if (g_videorecording)
		return;

	CBlob@ blob = this.getBlob();
	CPlayer@ player = blob.getPlayer();

	ManageCursors(blob);

	// draw inventory

	Vec2f tl = getActorHUDStartPosition(blob, slotsSize);
	DrawInventoryOnHUD(blob, tl);

	// draw coins

	const int coins = player !is null ? player.getCoins() : 0;
	DrawCoinsOnHUD(blob, coins, tl, slotsSize - 2);

	// draw class icon

	GUI::DrawIcon(iconsFilename, 3, Vec2f(16, 32), tl + Vec2f(8 + (slotsSize - 1) * 32, -13), 1.0f);


	u16 flash = blob.get_u16("flash");
	if(flash <= 25)
	{
		flash+=1;
	}
	else flash = 0;
	blob.set_u16("flash", flash);
	//print(" "+blob.get_u16("flash"));
	CMap@ map = getMap();
	CBlob@ hover = map.getBlobAtPosition(blob.getAimPos());
	SColor color = SColor(255, 255, 255, 255);
	SColor color2 = SColor(255, 255, 255, 255);
	CBlob@[] blobsInRadius;
	if(hover !is null)
	{
		if(blob is getLocalPlayerBlob())
		{
			if(hover.hasTag("enemy")) color = SColor(255,125+flash*5,0,0);
			if(hover.hasTag("enemy")) color2 = SColor(255,255-flash*5,0,0);
			GUI::DrawCircle(getDriver().getScreenPosFromWorldPos(hover.getPosition()), flash, color);
			GUI::DrawCircle(getDriver().getScreenPosFromWorldPos(hover.getPosition()), 25-flash, color2);
			DrawItemInfo(hover);
		}
		//print("yeah "+hover.getName());
	}

	//animate flashing rings


	else if (blob.getMap().getBlobsInRadius(blob.getAimPos(), 20.0f, @blobsInRadius))
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob @b = blobsInRadius[i];
			{
				if(b !is null && b !is blob)
				{
					if(blob is getLocalPlayerBlob() && b !is blob.getCarriedBlob())
					{
						if(b.hasTag("enemy")) color = SColor(255,125+flash*5,0,0);
						if(b.hasTag("enemy")) color2 = SColor(255,255-flash*5,0,0);
						GUI::DrawCircle(getDriver().getScreenPosFromWorldPos(b.getPosition()), flash, color);
						GUI::DrawCircle(getDriver().getScreenPosFromWorldPos(b.getPosition()), 25-flash, color2);

						DrawItemInfo(b);
						break;
					}		
				}
			}
		}
	}

	CBlob@ target = getBlobByNetworkID(blob.get_u16("target_id"));

	if(target !is null && blob.get_string("state2") == "chasing")
	{
		SColor color3 = SColor(255, 0, 255, 100);
		GUI::DrawCircle(getDriver().getScreenPosFromWorldPos(target.getPosition()), 40-flash, color3);
	}

	else if(blob.get_string("state") == "moving")
	{

		GUI::DrawCircle(getDriver().getScreenPosFromWorldPos(blob.get_Vec2f("target_pos")), 40-flash, color_white);
	}

}

void DrawItemInfo(CBlob@ blob)
{
	//getScreenHeight() / 3
	Vec2f pos = blob.getPosition();
	pos.x += 10;
	pos.y += 10;

	SColor color = SColor(255, 0, 255, 100);
	if(blob.hasTag("item"))
	{
		if(blob.hasTag("weapon")) color = SColor(255, 180, 180, 255);
		if(blob.hasTag("ranged")) color = SColor(255, 255, 180, 180);
		string info = "\n Damage: " + blob.get_f32("damage") + "\n Cooldown: " + blob.get_u32("cooldown") + (blob.hasTag("ranged") ? ("\n Range: " + blob.get_u32("range")) : "");
		GUI::DrawText(blob.getInventoryName(), getDriver().getScreenPosFromWorldPos(pos), color);
		GUI::DrawText(info, getDriver().getScreenPosFromWorldPos(pos), color_white);
	}	

	else if(blob.hasTag("enemy"))
	{
		color = SColor(255, 200, 0, 0);
		string info = "\n Health: " + blob.getHealth() + "\n Level: " + blob.get_u32("level");
		GUI::DrawText(blob.getInventoryName(), getDriver().getScreenPosFromWorldPos(pos), color);
		GUI::DrawText(info, getDriver().getScreenPosFromWorldPos(pos), color_white);
	}
}