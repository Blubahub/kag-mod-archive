// show class selection on intermission
#include "GameColours.as"
#include "ClassesCommon.as"
#include "ClassPickCommon.as"
#include "RadioCharacters.as"

//helpers

Vec2f getMenuPos(int playerIndex)
{
	Vec2f pos;

	if (!getNet().isServer())
	{
		pos.Set(0.5f, 0.5f);
	}
	else
	{
		switch (playerIndex)
		{
			case 0: pos.Set(0.25f, 0.25f); break;
			case 1: pos.Set(0.75f, 0.25f); break;
			case 2: pos.Set(0.25f, 0.75f); break;
			case 3: pos.Set(0.75f, 0.75f); break;
		}
	}
	return pos;
}

bool doPickMenus(CRules@ this)
{
	if (getNet().isServer() && !getNet().isClient())
		return false;
	if (!this.isIntermission())
		return false;
	if(this.hasTag("showing_tips"))
		return false;

	return true;
}

PickMenu@[]@ getMenus(CRules@ this)
{
	PickMenu@[]@ menus;
	this.get("pick menus", @menus);
	return menus;
}

void SaveSelection(CRules@ this, CPlayer@ player, int selected)
{
	player.Tag("class picked");
	int[] classes = getClasses(this);
	const int classindex = getClassIndexByName(CLASS_NAMES[classes[selected]]);
	player.server_setClassNum(classindex);
}

//class pick menu class

class PickMenu
{
	Vec2f pos;
	int selected;
	SColor color;
	CPlayer@ p;
	CControls@ controls;
	bool joined;
	bool done;
	CRules@ rules;

	PickMenu(CPlayer@ _p)
	{
		@p = _p;
		@controls = p.getControls();
		pos = getMenuPos(controls.getIndex());
		pos.x *= getDriver().getScreenWidth();
		pos.y *= getDriver().getScreenHeight();
		color = getPlayerColor(p);
		@rules = getRules();

		selected = getClassIndexByName(rules, CLASS_NAMES[p.getClassNum()]);

		joined = done = false;
	}

	void SendPick()
	{
		CBitStream params;
		params.write_netid(p.getNetworkID());
		params.write_u8(selected);
		rules.SendCommand(rules.getCommandID("pick class"), params);
	}

	void SendJoin()
	{
		CBitStream params;
		params.write_netid(p.getNetworkID());
		rules.SendCommand(rules.getCommandID("joined"), params);
	}

	void SendCancel()
	{
		CBitStream params;
		params.write_netid(p.getNetworkID());
		rules.SendCommand(rules.getCommandID("cancel"), params);
	}

	bool isActionPressed()
	{
		return controls.isKeyJustPressed(controls.getActionKeyKey(AK_ACTION1));
	}

	bool isCancelPressed()
	{
		return controls.isKeyJustPressed(controls.getActionKeyKey(AK_ACTION2));
	}

	void Update()
	{
		color = getPlayerColor(p); // set to 255 on first tick before net update

		if (!joined)
		{
			if (isActionPressed())
			{
				Sound::Play("select");
				SendJoin();
				joined = true;
			}

			return;
		}

		if (done)
		{
			if (isCancelPressed())
			{
				Sound::Play("back");
				done = false;
				SendCancel();
			}

			return;
		}

		int len = getClasses(rules).length;
		if (controls.isKeyJustPressed(controls.getActionKeyKey(AK_MOVE_LEFT)))
		{
			Sound::Play("select");
			if (selected <= 0)
				selected = len;
			selected--;
		}
		if (controls.isKeyJustPressed(controls.getActionKeyKey(AK_MOVE_RIGHT)))
		{
			Sound::Play("select");
			selected++;
			if (selected >= len)
				selected = 0;
		}

		if (isActionPressed())
		{
			Sound::Play("buttonclick");
			SendPick();
			done = true;
		}
	}

	void Render()
	{
		GUI::SetFont("gui");

		Vec2f pixeloffset = Vec2f(1, 1);
		int[] classes = getClasses(rules);
		int len = classes.length;

		if (done)
		{
			//render "player ready" text
			Vec2f menusize = Vec2f(100, 80);
			Vec2f topleft = pos - menusize * 0.5f;

			bool pressed = controls.isKeyPressed(controls.getActionKeyKey(AK_ACTION1)) || controls.isKeyPressed(controls.getActionKeyKey(AK_ACTION2))
			               || controls.isKeyPressed(controls.getActionKeyKey(AK_JUMP)) || controls.isKeyPressed(controls.getActionKeyKey(AK_CROUCH));

			float pressedWiggleOffset = pressed ? Maths::Sin(getGameTime() / 4.0f) * 4 : 0;

			if (pressed) // show that we're pressing buttons
			{
				menusize = Vec2f(80, 100);
				topleft = pos - menusize * 0.5f + Vec2f(0, pressedWiggleOffset * -0.5f);
			}

			/*if (pressed)
			{
				DrawControls( classes );
			}
			else*/
			{
				GUI::DrawRectangle(topleft - pixeloffset, topleft + menusize + pixeloffset, Colours::BLACK);
				GUI::DrawRectangle(topleft, topleft + menusize, color);
				GUI::DrawTextCentered(CLASS_NAMES[classes[selected]] + "!", pos - Vec2f(0, pressedWiggleOffset + 4 - 32), Colours::WHITE);
			}

			// BOTS

			if (getNet().isServer() && rules.get_s16("in menu") == 0 && !rules.hasTag("expo_mode"))  // && NOT EXPO
			{
				GUI::DrawTextCentered("Press [SPACE] to play with BOTS", getDriver().getScreenCenterPos(), (getGameTime() % 40 <= 20) ? Colours::WHITE : Colours::RED);
			}

			// draw portrait

			GUI::DrawIcon(_portraits_file, getCharacterFor(controls.getIndex() % 2, classes[selected]).frame, _portraitSize, pos - _portraitSize * 0.5f + Vec2f(0.0f, pressedWiggleOffset - 8), 0.5f);

			return;
		}

		if (!joined)
		{
			//render "join" help text
			Vec2f menusize = Vec2f(140, 40);
			Vec2f topleft = pos - menusize * 0.5f;

			GUI::DrawRectangle(topleft - pixeloffset, topleft + menusize + pixeloffset, Colours::BLACK);
			GUI::DrawRectangle(topleft, topleft + menusize, color);

			const string keyIcon = "$" + controls.getActionKeyKeyName(AK_ACTION1) + "$";
			const bool show = (getGameTime() + controls.getIndex() * 15) % 40 < 30;


			if (show)
			{
				if (GUI::hasIconName(keyIcon))
				{
					GUI::DrawIconByName(keyIcon, pos - _pad_size * 0.5f, 0.5f);
				}
				else
				{
					GUI::DrawTextCentered("[" + controls.getActionKeyKeyName(AK_ACTION1) + "]", pos, Colours::WHITE);
				}
			}
			else
			{
				GUI::DrawTextCentered("[PRESS TO JOIN]", pos, Colours::WHITE);
			}

			return;
		}

		Vec2f menusize = Vec2f(220, 70);
		float textPanelHeight = 15.0f;
		Vec2f topleft = pos - menusize * 0.5f;

		GUI::DrawRectangle(topleft - pixeloffset, topleft + menusize + Vec2f(0, textPanelHeight - 1) + pixeloffset, Colours::BLACK);
		GUI::DrawRectangle(topleft, topleft + menusize, color);
		GUI::DrawRectangle(topleft + Vec2f(0, menusize.y + 1), topleft + menusize + Vec2f(0, textPanelHeight - 1), Colours::DARK);

		/*if (controls.isKeyPressed(controls.getActionKeyKey(AK_ACTION2)))
		{
			DrawControls( classes );
		}
		else*/
		{
			for (uint i = 0; i < len; i++)
			{
				Vec2f framesize = Vec2f(32, 48);
				Vec2f p = pos + Vec2f((0.5f + i - len * 0.5f) * framesize.x * 1.2f, 0.0f);
				if (i == selected)
				{
					p.y -= 8.0f;
					Vec2f arrowframesize = Vec2f(16, 16);
					GUI::DrawIcon("Sprites/UI/selection_arrow.png", classes[i], arrowframesize, p + Vec2f(0, framesize.y * 0.5f + 8.0f + Maths::Sin(getGameTime() * 0.25f) * 2.0f) - arrowframesize * 0.5f, 0.5f);
				}

				GUI::DrawIcon("Sprites/classcards.png", classes[i], framesize, p - framesize * 0.5f, 0.5f, controls.getIndex());
			}
		}

		GUI::DrawTextCentered(CLASS_NAMES[classes[selected]], pos + Vec2f(0, menusize.y * 0.5f + 4.0f), Colours::WHITE);
	}

	void DrawControls(int[]@ classes)
	{
		Vec2f framesize = Vec2f(200, 64);
		GUI::DrawIcon("Sprites/UI/controls.png", 0, framesize, pos - framesize * 0.5f, 0.5f);
		GUI::DrawText(CLASS_PRIMARIES[classes[selected]], pos - framesize * 0.5f + Vec2f(138, 8), Colours::BLACK);
		GUI::DrawText(CLASS_SECONDARIES[classes[selected]], pos - framesize * 0.5f + Vec2f(138, 32), Colours::BLACK);
	}
};

//hooks

string _pad_buttons = "Sprites/UI/pad_buttons.png";
Vec2f _pad_size(24, 24);

void onInit(CRules@ this)
{
	this.addCommandID("show class menu");
	this.addCommandID("pick class");
	this.addCommandID("joined");
	this.addCommandID("cancel");
	Reset(this);

	AddIconToken("$JOYSTICK 1 A$", _pad_buttons, _pad_size, 0);
	AddIconToken("$JOYSTICK 1 B$", _pad_buttons, _pad_size, 1);
	AddIconToken("$JOYSTICK 1 x$", _pad_buttons, _pad_size, 2);
	AddIconToken("$JOYSTICK 1 Y$", _pad_buttons, _pad_size, 3);

	AddIconToken("$JOYSTICK 2 A$", _pad_buttons, _pad_size, 0);
	AddIconToken("$JOYSTICK 2 B$", _pad_buttons, _pad_size, 1);
	AddIconToken("$JOYSTICK 2 x$", _pad_buttons, _pad_size, 2);
	AddIconToken("$JOYSTICK 2 Y$", _pad_buttons, _pad_size, 3);

	AddIconToken("$JOYSTICK 3 A$", _pad_buttons, _pad_size, 0);
	AddIconToken("$JOYSTICK 3 B$", _pad_buttons, _pad_size, 1);
	AddIconToken("$JOYSTICK 3 x$", _pad_buttons, _pad_size, 2);
	AddIconToken("$JOYSTICK 3 Y$", _pad_buttons, _pad_size, 3);

	AddIconToken("$JOYSTICK 4 A$", _pad_buttons, _pad_size, 0);
	AddIconToken("$JOYSTICK 4 B$", _pad_buttons, _pad_size, 1);
	AddIconToken("$JOYSTICK 4 x$", _pad_buttons, _pad_size, 2);
	AddIconToken("$JOYSTICK 4 Y$", _pad_buttons, _pad_size, 3);
}

void onRestart(CRules@ this)
{
	Reset(this);
}

void Reset(CRules@ this)
{
	PickMenu@[] menus;
	this.set("pick menus", menus);

	// reset players and request menus

	for (uint i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		SetTeam(this, player);
		if (!this.hasTag("use_backend"))
		{
			RequestClassesMenu(this, player);
		}
	}
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	SetTeam(this, player);

	if (!this.hasTag("use_backend"))
	{
		if (this.isIntermission())
		{
			RequestClassesMenu(this, player);
		}
	}
}


void onTick(CRules@ this)
{
	if (this.hasTag("use_backend"))
		return;

	if (this.get_s16("in menu") != 0)
		return;
	if (!doPickMenus(this))
		return;

	PickMenu@[]@ menus = getMenus(this);
	if (menus is null)
		return;

	int donecount = 0;
	for (uint i = 0; i < menus.length; i++)
	{
		menus[i].Update();
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream @params)
{
	CPlayer@ player;
	if (cmd == this.getCommandID("show class menu"))
	{
		CPlayer@ player = getPlayerByNetworkId(params.read_netid());
		if (player is null)
			return;

		const u8 players = params.read_u8();

		if (getNet().isClient())
		{
			PickMenu@[]@ menus = getMenus(this);
			if (menus is null)
				return;

			for (uint i = 0; i < players; i++)
			{
				menus.push_back(PickMenu(getPlayer(i)));
			}
		}

		player.Untag("joined");
		player.Untag("class picked");
		player.Tag("show class menu");
	}
	else if (cmd == this.getCommandID("pick class"))
	{
		CPlayer@ player = getPlayerByNetworkId(params.read_netid());
		if (player is null)
			return;

		const u8 select = params.read_u8();

		SaveSelection(this, player, select);
	}
	else if (cmd == this.getCommandID("joined"))
	{
		CPlayer@ player = getPlayerByNetworkId(params.read_netid());
		if (player is null)
			return;

		player.Tag("joined");
	}
	else if (cmd == this.getCommandID("cancel"))
	{
		CPlayer@ player = getPlayerByNetworkId(params.read_netid());
		if (player is null)
			return;

		player.Untag("class picked");
	}
}


void onRender(CRules@ this)
{
	if (this.get_s16("in menu") != 0)
		return;
	if (!doPickMenus(this))
		return;

	PickMenu@[]@ menus = getMenus(this);
	if (menus is null)
		return;

	for (uint i = 0; i < menus.length; i++)
	{
		menus[i].Render();
	}
}
