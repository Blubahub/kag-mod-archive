//person HUD

#include "PersonCommon.as";
//#include "PlacementCommon.as";
#include "ActorHUDStartPos.as";
#include "EmotesCommon.as";
//#include "BlobPlacement.as";


const string iconsFilename = "Entities/Characters/Person/PersonIcons.png";
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
		// set cursor
		getHUD().SetCursorImage("Entities/Characters/Person/PersonCursor.png", Vec2f(32, 32));
		getHUD().SetCursorOffset(Vec2f(-32, -32));
		// frame set in logic
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

	const u8 type = getArrowType(blob);
	u8 arrow_frame = 0;

	if (type != ArrowType::normal)
	{
		arrow_frame = type;
	}

	// draw coins
	const int coins = player !is null ? player.getCoins() : 0;
	DrawCoinsOnHUD(blob, coins, tl, slotsSize - 2);

	// class weapon icon

	string cfgFileName = "SW/stats.cfg";
	ConfigFile cfg;
	cfg.loadFile("../Cache/" + cfgFileName);
	if (!cfg.loadFile("../Cache/" + cfgFileName))
	{
		error("Couldn't load " + cfgFileName);
		cfg.saveFile(cfgFileName);

	}

	cfg.loadFile("../Cache/" + cfgFileName);
/*
	BlockCursor @bc;
	this.get("blockCursor", @bc);
	if (bc is null)
	{
		return;
	}

	SetTileAimpos(this, bc);
*/
	bool clicking = blob.get_bool("clicking");

	if(blob !is null)
	{
		if(blob.isKeyPressed(key_action1))
		{
			Vec2f aimpos = blob.getAimPos();
			Vec2f pos = blob.getPosition();
			/*Vec2f cursorpos = getMap().getTileSpacePosition(aimpos);
			cursorpos = getMap().getTileWorldPosition(cursorpos);
			cursorpos = getControls().getMouseWorldPos();*/
			Vec2f cursorpos = getDriver().getScreenPosFromWorldPos(aimpos);
			if(!clicking)
			{
				clicking = true;
				blob.set_Vec2f("rectangle start", cursorpos);
				blob.set_Vec2f("rectangle start world", aimpos);

			}
			blob.set_bool("clicking", clicking);

			Vec2f startpos = blob.get_Vec2f("rectangle start");

			//print("cursorpos: " + cursorpos.x + ", " + cursorpos.y);
			//print("pos: " + pos.x + ", " + pos.y);	



			//RTS STYLE MOUSE BOX SELECTION		
/*
			if(startpos.x < cursorpos.x && startpos.y < cursorpos.y)
			{
				GUI::DrawRectangle( startpos, cursorpos, SColor(90,0,120,255) );
			}

			else if(startpos.x < cursorpos.x && startpos.y > cursorpos.y)
			{
				GUI::DrawRectangle( Vec2f(startpos.x, cursorpos.y), Vec2f(cursorpos.x, startpos.y), SColor(90,0,120,255) );
			}

			else if(startpos.x > cursorpos.x && startpos.y < cursorpos.y)
			{
				GUI::DrawRectangle( Vec2f(cursorpos.x, startpos.y), Vec2f(startpos.x, cursorpos.y), SColor(90,0,120,255) );
			}

			else
			{
				GUI::DrawRectangle( cursorpos, startpos, SColor(90,0,120,255) );
			}*/
		}

		else if(clicking)
		{
			blob.set_bool("clicking", false);
			CBlob@[] troops;
			//Vec2f pos = troop.getPosition();
			Vec2f start = blob.get_Vec2f("rectangle start world");
			Vec2f end = blob.getAimPos();
			if(blob.getMap().getBlobsInBox(start, end, @troops))
			{
				for(uint i = 0; i < troops.length; i++)
				{
					CBlob@ troop = troops[i];
					if(troop !is null && troop.getName() == "person" && troop.getTeamNum() == blob.getTeamNum())
					{
						//if(troop.getSprite() !is null) troop.getSprite().setRenderStyle(RenderStyle::light);
						//troop.Chat("I have " + troop.getHealth()*2 + "/" + troop.getInitialHealth()*2 + " health left. " + "\n" +troop.get_string("information")/*troop.getInventoryName() + "." */);
					}
				}
			}
		}

	}
/*
	if(blob.getPlayer() is null)
	{
		print("no player");
		return;
	}

	string fired = blob.getPlayer().getUsername()+"_fired";


	u32 shotsfired = 0;
	if (!cfg.exists(fired))
	{
		cfg.add_u32(fired, shotsfired);
		cfg.saveFile(cfgFileName);
	}

	shotsfired = cfg.read_u32(fired);
	if (shotsfired > 10)
	{
		//blob.server_Die();
	}
	GUI::DrawIcon(iconsFilename, arrow_frame, Vec2f(16, 32), tl + Vec2f(8 + (slotsSize - 1) * 32, -16), 1.0f);*/
}
