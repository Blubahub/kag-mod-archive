#include "GameColours.as"

const string _overlay_file = "Sprites/UI/screen_menu_overlay.png";

const string _chips_file = "Sprites/UI/chips_screen.png";
Vec2f _class_box_frame(198, 50);
Vec2f _chip_frame(50, 50);

const string _portraits_file = "Sprites/UI/radio_portraits.png";
Vec2f _portrait_frame(48, 48);

namespace MenuColours
{
	const uint BLUE = 0xff1d286f;
	const uint GRAY = 0xff818181;
};

class ClassBox
{
	Vec2f ul, lr, portraitPos;
	u8 frame, frame2, portrait;
	u8 team, cclass;
	string name;
	CPlayer@ player;

	ClassBox(Vec2f _ul, Vec2f _lr, Vec2f _portraitPos, u8 _frame, u8 _frame2, u8 _portrait, u8 _team, u8 _cclass)
	{
		ul = _ul;
		lr = _lr;
		portraitPos = _portraitPos;
		frame = _frame;
		frame2 = _frame2;
		portrait = _portrait;
		team = _team;
		cclass = _cclass;
	}
};

ClassBox@[] _classBoxes;

Vec2f _lastChipPos;

void onInit(CRules@ this)
{
	this.addCommandID("chip select");
//	this.set_u16("scrolling text offset", 31);
	this.set_string("scrolling text", "PICK YOUR CLASSSSSSSSSS.");
}

void onTick(CRules@ this)
{
	if (!this.isIntermission())
	{
		return;
	}

	if (getNet().isClient())
	{
		// create _classBoxes

		if (_classBoxes.length == 0)
		{
			for (uint c = 0; c < 5; c++)
			{
				const int ystep = c * 52;
				ClassBox box(Vec2f(4, 54 + ystep), Vec2f(4 + _class_box_frame.x, 54 + _class_box_frame.y + ystep), Vec2f(4 + 17, 55 + ystep), 0, 2, 0, 0, c);
				ClassBox box2(Vec2f(366, 54 + ystep), Vec2f(366 + _class_box_frame.x, 54 + _class_box_frame.y + ystep), Vec2f(499, 55 + ystep), 1, 3, 0, 1, c);
				_classBoxes.push_back(box);
				_classBoxes.push_back(box2);
			}

			// setup portraits
			_classBoxes[0].portrait = 2; _classBoxes[0].name = "Assault";
			_classBoxes[1].portrait = 3; _classBoxes[1].name = "Assault";

			_classBoxes[2].portrait = 7; _classBoxes[2].name = "Sniper";
			_classBoxes[3].portrait = 8; _classBoxes[3].name = "Sniper";

			_classBoxes[4].portrait = 6; _classBoxes[4].name = "Medic";
			_classBoxes[5].portrait = 5; _classBoxes[5].name = "Medic";

			_classBoxes[6].portrait = 10; _classBoxes[6].name = "Demolitions";
			_classBoxes[7].portrait = 11; _classBoxes[7].name = "Demolitions";

			_classBoxes[8].portrait = 13; _classBoxes[8].name = "Commando";
			_classBoxes[9].portrait = 12; _classBoxes[9].name = "Commando";
		}

		// check _classBoxes collisions

		for (uint c = 0; c < _classBoxes.length; c++)
		{
			ClassBox@ box = _classBoxes[c];
			@box.player = null;
		}

		ClassBox@ myBox;
		Vec2f resFactor = getDriver().getResolutionFactor();
		CBlob@[] chips;
		getBlobsByName("chip", @chips);
		for (uint i = 0; i < chips.length; i++)
		{
			CBlob@ chip = chips[i];
			Vec2f pos = chip.getScreenPos();
			pos.x /= resFactor.x;
			pos.y /= resFactor.y;

			// select box

			for (uint c = 0; c < _classBoxes.length; c++)
			{
				ClassBox@ box = _classBoxes[c];
				if (pos.x > box.ul.x && pos.x < box.lr.x && pos.y > box.ul.y && pos.y < box.lr.y)
				{
					@box.player = chip.getPlayer();
					if (chip.isMyPlayer())
					{
						@myBox = box;
					}
				}
			}

			// my chip

			if (chip.isMyPlayer())
			{
				Vec2f pos = chip.getPosition();
				if (/*chip.getVelocity().getLength() <= 0.1f && */(_lastChipPos - pos).getLength() > 5.0f)
				{
					_lastChipPos = pos;
					//print("Select chip");
					CBitStream params;
					params.write_netid(chip.getPlayer().getNetworkID());
					if (myBox is null)
					{
						params.write_u8(255);
						params.write_u8(255);
					}
					else
					{
						params.write_u8(myBox.team);
						params.write_u8(myBox.cclass);
					}
					this.SendCommand(this.getCommandID("chip select"), params);
				}
			}
		}

		// still camera

		CMap@ map = getMap();
		getCamera().setPosition(Vec2f(map.tilemapwidth * map.tilesize * 0.5f, map.tilemapheight * map.tilesize * 0.5f));
	}


	// spawn chip for anyone that doesn't have one

	for (uint i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		if (player.getBlob() is null || player.getBlob().getName() == "soldier")
		{
			SpawnChip(this, player);
			//print("spawn chip");
		}
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream @params)
{
	CPlayer@ player;
	if (cmd == this.getCommandID("chip select"))
	{
		CPlayer@ player = getPlayerByNetworkId(params.read_netid());
		if (player is null)
			return;

		const u8 team = params.read_u8();
		const u8 cclass = params.read_u8();

		player.server_setTeamNum(team);
		player.server_setClassNum(cclass);
		//print("set class " + team + " " + cclass);
	}
}

void onRender(CRules@ this)
{
	if (this.get_s16("in menu") > 0)
		return;

	CMap@ map = getMap();
	if (map is null)
		return;
	CPlayer@ player = getLocalPlayer();
	if (player is null)
	{
		return;
	}

	const u8 state = this.getCurrentState();

	if (state == INTERMISSION)
	{

		//draw background
		Vec2f screenSize(getDriver().getScreenWidth(), getDriver().getScreenHeight());
		GUI::DrawRectangle(Vec2f(0, 0), screenSize, color_black);
		GUI::DrawIcon(_overlay_file, Vec2f(0, 0), 0.5f);

//void DrawIcon( const ::string &in textureFilename, int iconFrame, ::Vec2f frameDimension, ::Vec2f pos, ::f32 scale, ::SColor color )",
		// class boxes

		for (uint c = 0; c < _classBoxes.length; c++)
		{
			ClassBox@ box = _classBoxes[c];
			GUI::DrawIcon(_portraits_file, box.portrait, _portrait_frame, box.portraitPos, 0.5f, color_white);   // portrait
			GUI::DrawIcon(_chips_file, box.frame, _class_box_frame, box.ul, 0.5f, box.player is null ? SColor(MenuColours::GRAY) : SColor(MenuColours::BLUE));   // outer
			GUI::DrawIcon(_chips_file, box.frame2, _class_box_frame, box.ul, 0.5f, color_white);   // inner
			GUI::DrawTextCentered(box.name, Vec2f(box.ul.x + (box.lr.x - box.ul.x) / 2, box.ul.y + 10), box.player is null ? color_white : SColor(MenuColours::BLUE));
		}

		// chips

		CBlob@[] chips;
		getBlobsByName("chip", @chips);
		for (uint i = 0; i < chips.length; i++)
		{
			CBlob@ chip = chips[i];
			GUI::DrawIcon(_chips_file, 14, _chip_frame, chip.getScreenPos() + _chip_frame * -0.5f, 0.5f, color_white); // chip
		}
	}
}


CBlob@ SpawnChip(CRules@ this, CPlayer@ player)
{
	CBlob @newBlob = server_CreateBlob("chip");
	if (newBlob !is null)
	{
		CMap@ map = getMap();
		newBlob.server_setTeamNum(player.getTeamNum());
		newBlob.setPosition(Vec2f(map.tilemapwidth * map.tilesize * 0.5f, map.tilemapheight * map.tilesize * 0.5f));
		newBlob.server_SetPlayer(player);
	}
	return newBlob;
}
