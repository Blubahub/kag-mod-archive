#include "MenusCommon.as"
#include "GameColours.as"
// Menus include

namespace Menus
{
	shared class Button
	{
		string caption;
		int iconIndex;
	};

	shared class Group
	{
		Button@[] buttons;
		string name;
		Vec2f position;
		string iconFilename;
		Vec2f buttonSize;
		bool horizontal;
		// runtime
		int selection;
	};

	shared class Data
	{
		Group@[] groups;
		bool canControl;
		bool selecting;
		uint activeGroup;

		CControls@ controls;
		bool startControl;

		dictionary vars;
	};

	Data@ getData(CPlayer@ player)
	{
		if (player is null)
			return null;
		Data@ data;
		getRules().get("menus" + player.getControls().getIndex(), @data);
		return data;
	}

	void Clear()
	{
		CRules@ rules = getRules();

		for (int p_it = 0; p_it < getLocalPlayersCount(); p_it++)
		{
			CPlayer@ player = getLocalPlayer(p_it);
			if (player is null)
				continue;
			Data@ data = getData(player);
			if (data is null)
				continue;
			rules.set_s16("in menu", rules.get_s16("in menu") - data.groups.length);
			data.groups.clear();
		}
	}

	void Clear(CPlayer@ player)
	{
		CRules@ rules = getRules();
		Data@ data = getData(player);
		if (data is null)
			return;
		rules.set_s16("in menu", rules.get_s16("in menu") - data.groups.length);
		data.groups.clear();
	}

	void Clear(CPlayer@ player, string groupName)
	{
		if (player is null)
			return;
		CRules@ rules = getRules();
		Data@ data = getData(player);
		if (data is null)
			return;
		for (uint groupIt = 0; groupIt < data.groups.length; groupIt++)
		{
			Group@ group = data.groups[ groupIt ];
			if (group.name == groupName)
			{
				data.groups.removeAt(groupIt);
				rules.set_s16("in menu", rules.get_s16("in menu") - 1);
				break;
			}
		}
	}

	bool hasMenu(CPlayer@ player, string groupName)
	{
		CRules@ rules = getRules();
		Data@ data = getData(player);
		for (uint groupIt = 0; groupIt < data.groups.length; groupIt++)
		{
			Group@ group = data.groups[ groupIt ];
			if (group.name == groupName)
			{
				return true;
			}
		}
		return false;
	}

	Group@ AddMenu(CPlayer@ player, string name, Vec2f position = Vec2f(0.5f, 0.5f), Vec2f buttonSize = Vec2f_zero, bool horizontal = false, string iconFilename = "")
	{
		CRules@ rules = getRules();
		Data@ data = getData(player);

		Group group;
		group.name = name;
		group.position = position;
		group.iconFilename = iconFilename;
		group.buttonSize = buttonSize * SCALE;
		group.horizontal = horizontal;
		group.selection = 0;

		data.groups.push_back(group);

		rules.set_s16("in menu", rules.get_s16("in menu") + 1);

		data.activeGroup = data.groups.length - 1;
		return data.groups[ data.activeGroup ];
	}

	void AddButton(CPlayer@ player, string caption, int iconIndex = -1)
	{
		CRules@ rules = getRules();
		Data@ data = getData(player);

		if (data.groups.length == 0)
		{
			warn("Menus: No groups found to add button");
			return;
		}

		Button button;
		button.caption = caption;
		button.iconIndex = iconIndex;

		Group@ group = data.groups[ data.groups.length - 1 ];
		group.buttons.push_back(button);

		if (iconIndex == -1)
		{
			Vec2f textDim;
			GUI::GetTextDimensions(caption, textDim);
			if (textDim.x > group.buttonSize.x)
				group.buttonSize.x = textDim.x + 2 * SCALE;
			if (textDim.y > group.buttonSize.y)
				group.buttonSize.y = textDim.y + 2 * SCALE;
		}

		data.startControl = false;
	}

	void AddSeparator(CPlayer@ player)
	{
		AddButton(player, "");
	}

	bool hasMenus(CRules@ rules)
	{
		for (int p_it = 0; p_it < getLocalPlayersCount(); p_it++)
		{
			CPlayer@ player = getLocalPlayer(p_it);
			Data@ data = getData(player);
			if (data !is null && data.groups.length > 0)
				return true;
		}
		return false;
	}

	void Render(CRules@ rules)
	{
		if (!hasMenus(rules))
			return;

		Vec2f screenSize(getDriver().getScreenWidth(), getDriver().getScreenHeight());
		// (dont dim game)

		// TEST
		// GUI::DrawIcon( "Sprites/UI/TitleScreen.png", screenSize * 0.5f - Vec2f(333, 136) * 0.85f );
		// if (getGameTime() % 40 < 20)
		// 	GUI::DrawTextCentered( "PRE-ALPHA TEST VERSION", Vec2f(screenSize.x*0.5f, 35), color_white );
		// else
		// 	GUI::DrawTextCentered( "PRE-ALPHA TEST VERSION", Vec2f(screenSize.x*0.5f, screenSize.y - 45), color_white );
		// TEST

		for (int p_it = 0; p_it < getLocalPlayersCount(); p_it++)
		{
			CPlayer@ player = getLocalPlayer(p_it);
			Data@ data = getData(player);
			if (data is null || data.groups.length == 0)
				continue;

			// draw buttons
			for (uint groupIt = 0; groupIt < data.groups.length; groupIt++)
			{
				Group@ group = data.groups[ groupIt ];
				Vec2f menucenter(screenSize.x * group.position.x, screenSize.y * group.position.y);
				const uint buttonCount = group.buttons.length;
				Vec2f menupos = menucenter - getMenuOffset(group);   // align

				// draw icons
				Vec2f buttonpos = menupos;
				int selected = 0;
				for (uint buttonIt = 0; buttonIt < buttonCount; buttonIt++)
				{
					Button@ button = group.buttons[buttonIt];
					group.horizontal ? buttonpos.x += getButtonOffset(group).x : buttonpos.y += getButtonOffset(group).y;
					if (isButtonSeparator(button))
						continue;

					const bool hasIcon = button.iconIndex >= 0;
					const bool isSelected = group.selection == buttonIt;
					Vec2f margin(SCALE, SCALE);

					if (isSelected)
					{
						GUI::DrawRectangle(buttonpos - margin, buttonpos + group.buttonSize + margin, getPlayerColor(player));
						selected = buttonIt;
					}
					else if (!hasIcon)
						GUI::DrawRectangle(buttonpos, buttonpos + group.buttonSize, color_white);

					if (hasIcon)
					{
						GUI::DrawIcon(group.iconFilename, button.iconIndex, group.buttonSize / SCALE, buttonpos, 0.5f);
					}
				}

				// draw captions
				buttonpos = menupos;
				for (uint buttonIt = 0; buttonIt < buttonCount; buttonIt++)
				{
					Button@ button = group.buttons[buttonIt];
					group.horizontal ? buttonpos.x += getButtonOffset(group).x : buttonpos.y += getButtonOffset(group).y;
					if (isButtonSeparator(button))
						continue;

					const bool isSelected = group.selection == buttonIt;
					if (isSelected){
						GUI::SetFont("gui");
						GUI::DrawText(button.caption, buttonpos + getButtonCaptionOffset(group, button), color_white);
					}
				}

				// TEST

				// Vec2f helpPos;
				// switch (data.controls.getIndex())
				// {
				// 	case 0: helpPos.Set( screenSize.x*0.1f, screenSize.y*0.022f ); break;
				// 	case 1: helpPos.Set( screenSize.x*0.75f, screenSize.y*0.022f ); break;
				// 	case 2: helpPos.Set( screenSize.x*0.1f, screenSize.y*(1.0f-0.1f) ); break;
				// 	case 3: helpPos.Set( screenSize.x*0.75f, screenSize.y*(1.0f-0.1f) ); break;
				// }
				// GUI::DrawIcon( "Sprites/UI/controls.png", selected, Vec2f(200,64), helpPos, 0.5f );

				// TEST
			}
		}
	}

	void Control(CRules@ rules)
	{
		if (rules.get_s16("in menu") > 0)
		{
			return;
		}

		for (int p_it = 0; p_it < getLocalPlayersCount(); p_it++)
		{
			CPlayer@ player = getLocalPlayer(p_it);
			Data@ data = getData(player);
			if (data is null || data.controls is null)
				continue;
			CControls@ controls = data.controls;

			bool anyKeyPressed = controls.ActionKeyPressed(AK_MOVE_LEFT) || controls.ActionKeyPressed(AK_MOVE_RIGHT)
			                     || controls.ActionKeyPressed(AK_MOVE_UP) || controls.ActionKeyPressed(AK_MOVE_DOWN)
			                     || controls.ActionKeyPressed(AK_ACTION1) || controls.ActionKeyPressed(AK_ACTION2);

			if (!data.startControl)
			{
				if (anyKeyPressed)
				{
					return;
				}
				data.startControl = true;
			}

			if (data.canControl && data.activeGroup < data.groups.length)
			{
				Group@ group = data.groups[ data.activeGroup ];

				if (isPrevPressed(controls, group))
				{
					DoPrevSelection(group);
					while (isButtonSeparator(group.buttons[group.selection]))    // unsafe: will hang with only separators
					{
						DoPrevSelection(group);
					}
					Sound::Play("select");
				}
				if (isNextPressed(controls, group))
				{
					DoNextSelection(group);
					while (isButtonSeparator(group.buttons[group.selection]))    // unsafe: will hang with only separators
					{
						DoNextSelection(group);
					}
					Sound::Play("select");
				}
				if (controls.ActionKeyPressed(AK_ACTION1) || controls.ActionKeyPressed(AK_ACTION2))
				{
					Select(rules, group, player);
					Sound::Play("buttonclick");
				}

				if (anyKeyPressed)
					data.canControl = false;
			}

			if (!anyKeyPressed)
				data.canControl = true;

			rules.set_bool("in class menu", data.groups.length > 0);
		}
	}

	void Select(CRules@ rules, Group@ group, CPlayer@ player)
	{
		Button@ button = group.buttons[group.selection];
		CBitStream params;
		params.write_netid(player.getNetworkID());
		params.write_string(group.name);
		params.write_string(button.caption);
		rules.SendCommand(rules.getCommandID(CMD_STRING), params);
		CBlob@ localBlob = player.getBlob();
		if (localBlob !is null)
		{
			localBlob.SendCommand(localBlob.getCommandID(CMD_STRING), params);
		}
		if (g_debug == 1)
			printf("CLICK [" + group.name + "] " + button.caption);
	}

	void Init(CRules@ rules, CPlayer@ player)
	{
		Menus::Data data;
		data.canControl = true;
		data.activeGroup = 0;
		data.startControl = false;
		@data.controls = player.getControls();
		rules.set("menus" + player.getControls().getIndex(), @data);
	}

	void Init(CBlob@ blob)
	{
		blob.addCommandID(CMD_STRING);
	}

	bool ReadCommand(CBitStream@ params, CPlayer@ &out player, string &out group, string &out caption)
	{
		@player = getPlayerByNetworkId(params.read_netid());
		group = params.read_string();
		caption = params.read_string();
		return true;
	}

	bool ReadButtonCommand(CRules@ rules, u8 cmd, CBitStream@ params, CPlayer@ &out player, string &out group, string &out caption)
	{
		if (cmd == rules.getCommandID(CMD_STRING))
		{
			return ReadCommand(params, player, group, caption);
		}
		return false;
	}

	bool ReadButtonCommand(CBlob@ blob, u8 cmd, CBitStream@ params, CPlayer@ &out player, string &out group, string &out caption)
	{
		if (cmd == blob.getCommandID(CMD_STRING))
		{
			return ReadCommand(params, player, group, caption);
		}
		return false;
	}

} // GUI
