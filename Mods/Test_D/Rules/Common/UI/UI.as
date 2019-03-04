#include "UICommon.as"
#include "UIProxy.as"
// UI include

namespace UI
{
	funcdef void SELECT_FUNCTION(CRules@, Group@, Control@);
	funcdef bool NEXT_FUNCTION(Group@);
	funcdef void INPUT_FUNCTION(Control@, const s32, bool &out, bool &out);
	funcdef bool ESCAPE_FUNCTION(CRules@);

	shared class Control
	{
		int x;
		int y;
		string caption;
		bool selectable;
		int groupIcon;
		SELECT_FUNCTION@ select;
		SELECT_FUNCTION@ select2;
		INPUT_FUNCTION@ input;
		dictionary vars;

		Group@ group;
	};

	shared class Group
	{
		Control@[][] controls;
		string name;
		Vec2f upperLeft;
		Vec2f lowerRight;
		int columns;
		int rows;

		// appearance
		string selectorImage;
		Vec2f selectorOffset;

		string iconFilename;
		Vec2f iconSize;

		// runtime
		Control@ activeControl;
		int selx, sely;
		bool modal;
		bool keyReleased;

		Control@ lastAddedControl;
		Control@ editControl;

		Data@ data;
		Proxy@ proxy;

		dictionary vars;
	};

	shared class Data
	{
		Group@[] groups;
		bool canControl;
		Group@ activeGroup;

		string font;

		Proxy@[] proxies;

		// useful
		dictionary lastSelection;
		u32 holdKeyTime;
		Vec2f mousePos;

		// cache
		CRules@ rules;
		Vec2f screenSize;

		// exit
		ESCAPE_FUNCTION@ escape_func;
	};

	Data@ getData(CRules@ rules)
	{
		Data@ data;
		rules.get("ui", @data);
		if(data is null)
		{
			warn("(initialising UI late)");
			Init(rules);
			return getData(rules);
		}
		return data;
	}

	Data@ getData()
	{
		return getData(getRules());
	}

	void Clear()
	{
		Data@ data = getData();

		if (data is null) return;

		data.rules.set_s16("in menu", data.rules.get_s16("in menu") - data.groups.length);

		// remove proxies
		RemoveProxies(data);

		data.groups.clear();
		@data.activeGroup = null;
		CControls@ controls = getControls();
		controls.externalControl = false;
	}

	void Clear(string groupName)
	{
		Data@ data = getData();
		if (data is null)
		{
			warn("UI:Clear: no data; have you added UIHooks to rules?");
			return;
		}
		for (uint groupIt = 0; groupIt < data.groups.length; groupIt++)
		{
			Group@ group = data.groups[ groupIt ];
			if (group.name == groupName)
			{
				if (data.activeGroup is group)
					@data.activeGroup = null;

				// remove proxy
				RemoveProxies(data, group);

				data.groups.erase(groupIt);
				data.rules.set_s16("in menu", data.rules.get_s16("in menu") - 1);
				break;
			}
		}

		// ?
		CControls@ controls = getControls();
		controls.externalControl = false;		
	}

	bool hasGroup(string groupName)
	{
		Data@ data = getData();
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

	bool hasAnyGroup()
	{
		Data@ data = getData();
		return data !is null && data.groups.length > 0;
	}

	bool hasAnyContent()
	{
		Data@ data = getData();
		return data !is null && (data.groups.length > 0 || data.proxies.length > 0);
	}

	Group@ getGroup(Data@ data, string groupName)
	{
		for (uint groupIt = 0; groupIt < data.groups.length; groupIt++)
		{
			Group@ group = data.groups[ groupIt ];
			if (group.name == groupName)
			{
				return group;
			}
		}
		return null;
	}

	Group@ getGroup(string groupName)
	{
		return getGroup(getData(), groupName);
	}

	Group@ AddGroup(string name, Vec2f upperLeft = Vec2f(0.25f, 0.25f), Vec2f lowerRight = Vec2f(0.75f, 0.75f), string iconFilename = "", Vec2f iconSize = Vec2f_zero)
	{
		Data@ data = getData();

		Group group;
		group.name = name;
		group.upperLeft = upperLeft;
		group.lowerRight = lowerRight;
		group.iconFilename = iconFilename;
		group.iconSize = iconSize;
		group.rows = group.columns = 0;
		group.selx = group.sely = 0;
		group.modal = false;
		group.keyReleased = false;
		@group.data = data;

		data.groups.push_back(group);
		@data.activeGroup = data.groups[ data.groups.length - 1 ];
		@group.proxy = AddProxy(data, null, UpdateGroup, data.activeGroup, null, 0.0f);

		data.rules.set_s16("in menu", data.rules.get_s16("in menu") + 1);

		return data.activeGroup;
	}

	Control@ AddControl(string caption)
	{
		Data@ data = getData();

		if (data.groups.length == 0)
		{
			warn("UI: No groups found to add control");
			return null;
		}

		Group@ group = data.activeGroup;

		Control control;
		control.caption = caption;
		control.groupIcon = -1;
		@control.group = group;

		for (uint y = 0; y < group.rows; y++)
		{
			for (uint x = 0; x < group.columns; x++)
			{
				if (group.controls[x][y] is null)
				{
					Control@ pControl = control;
					@group.controls[x][y] = pControl;
					control.x = x;
					control.y = y;
					@group.lastAddedControl = pControl;

					if (group.activeControl is null)
					{
						@group.activeControl = pControl;
					}
					return pControl;
				}
			}
		}

		warn("UI: no space on grid to add control");
		return null;
	}

	Control@ getControlByCaption(Group@ group, string caption)
	{
		for (uint y = 0; y < group.rows; y++)
		{
			for (uint x = 0; x < group.columns; x++)
			{
				if (group.controls[x][y] !is null)
				{
					Control@ pControl = group.controls[x][y];
					if (pControl.caption == caption)
						return pControl;
				}
			}
		}
		return null;
	}

	void AddSeparator()
	{
		Control@ c = AddControl("");
		c.selectable = false;
	}

	void SetSelection(int index)
	{
		Data@ data = getData();
		Group@ group = data.activeGroup;

		int count = 0;
		for (uint y = 0; y < group.rows; y++)
		{
			for (uint x = 0; x < group.columns; x++)
			{
				Control@ pControl = group.controls[x][y];
				if (pControl !is null && pControl.selectable)
				{
					if (count == index)
					{
						group.selx = x;
						group.sely = y;
						@group.activeControl = getActiveControl(group);
						data.lastSelection.set(group.name, index);
						return;
					}
					if (index == -1)
					{
						group.selx = x;
						group.sely = y;
						@group.activeControl = getActiveControl(group);
						data.lastSelection.set(group.name, index);
					}
					count++;
				}
			}
		}
	}

	int getSelectionIndex(Group@ group, int cx, int cy)
	{
		Data@ data = getData();

		int count = 0;
		for (uint y = 0; y < group.rows; y++)
		{
			for (uint x = 0; x < group.columns; x++)
			{
				Control@ pControl = group.controls[x][y];
				if (pControl !is null && pControl.selectable)
				{
					if (pControl.x == cx && pControl.y == cy)
					{
						return count;
					}
					count++;
				}
			}
		}
		return 0;
	}

	void SetNextSelection()
	{
		Data@ data = getData();
		int index = getSelectionIndex(data.activeGroup, data.activeGroup.selx, data.activeGroup.sely);
		SetSelection(index + 1);
	}

	void SetLastSelection(const int fallbackIndex = -1)
	{
		Data@ data = getData();
		Group@ group = data.activeGroup;
		// set last remembered selection
		if (group !is null && data.lastSelection.exists(group.name))
		{
			int index;
			data.lastSelection.get(group.name, index);
			SetSelection(index);
		}
		else
		{
			SetSelection(fallbackIndex);
		}
	}

	void SetSelection(Control@ control)
	{
		if (control !is null)
		{
			Data@ data = getData();
			@data.activeGroup = control.group;
			int count = 0;
			for (uint y = 0; y < control.group.rows; y++)
			{
				for (uint x = 0; x < control.group.columns; x++)
				{
					Control@ pControl = control.group.controls[x][y];
					if (pControl is control)
					{
						control.group.selx = x;
						control.group.sely = y;
						@control.group.activeControl = control;
						data.lastSelection.set(control.group.name, count);
					}
					count++;
				}
			}

		}

	}

	void SetFont(string font)
	{
		Data@ data = getData();
		if (data !is null)
		{
			data.font = font;
		}
	}

	Vec2f getAbsolutePosition(Vec2f p, Vec2f size)
	{
		return Vec2f(p.x * size.x, p.y * size.y);
	}

	void Render(CRules@ rules)
	{
		Data@ data = getData(rules);
		if (data is null || data.proxies.length == 0)
			return;

		Driver@ driver = getDriver();
		Vec2f screenDim = driver.getScreenDimensions();
		GUI::DrawRectangle(Vec2f(0, 0), screenDim, SColor(255, 0, 0, 0));

		// draw proxies
		for (uint pIt = 0; pIt < data.proxies.length; pIt++)
		{
			Proxy@ proxy = data.proxies[ pIt ];
			if (proxy.renderFunc !is null)
			{
				GUI::SetFont(proxy.font);

				// TODO: refactor these into function pointers
				if (proxy.selected && proxy.control !is null && proxy.control.selectable)
				{
					if (proxy.group.selectorImage == "none")
					{}
					else if (proxy.group.selectorImage != "")
					{
						GUI::DrawIcon(proxy.group.selectorImage,
						              Vec2f(proxy.ul.x, (proxy.ul.y + proxy.lr.y) / 2) - proxy.group.selectorOffset / 2, 0.5f
						             );
					}
					else
					{
						GUI::DrawIcon("Sprites/UI/mainmenu_selector_big.png",
						              Vec2f(proxy.ul.x, (proxy.ul.y + proxy.lr.y) / 2) - Vec2f(124, 25) / 2, 0.5f
						             );
					}
				}

				proxy.renderFunc(proxy);
			}
		}
	}

	void Tick(CRules@ rules)
	{
		Data@ data = getData(rules);

		if (data is null)
		{
			return;
		}

		UpdateControls(rules);

		// update proxies
		data.proxies.sortAsc();
		for (uint pIt = 0; pIt < data.proxies.length; pIt++)
		{
			Proxy@ proxy = data.proxies[ pIt ];
			// remove dead proxy
			if (proxy.dead)
			{
				data.proxies.erase(pIt);
				if (pIt > 0)
					pIt--;
				continue;
			}
			// update proxy
			if (proxy.updateFunc !is null)
			{
				proxy.updateFunc(proxy);
			}
		}

		// escape

		if (data.escape_func !is null)
		{
			if (data.escape_func(rules))
			{
				Clear();
				data.proxies.clear();
				rules.set("ui", null);
			}
		}
	}

	void UpdateControls(CRules@ rules)
	{
		Data@ data = getData(rules);
		CControls@ controls = getControls();
		const u32 time = getGameTime();
		const bool hasCursor = getHUD().hasCursor();

	    if (Engine::hasStandardGUIFocus())
	    	return;

		const bool keyLeft = controls.ActionKeyPressed(AK_MOVE_LEFT) || controls.isKeyPressed(KEY_LEFT);
		const bool keyRight = controls.ActionKeyPressed(AK_MOVE_RIGHT) || controls.isKeyPressed(KEY_RIGHT);
		const bool keyUp = controls.ActionKeyPressed(AK_MOVE_UP) || controls.isKeyPressed(KEY_UP);
		const bool keyDown = controls.ActionKeyPressed(AK_MOVE_DOWN) || controls.isKeyPressed(KEY_DOWN);
		const bool keyAction1 = controls.ActionKeyPressed(AK_ACTION1) || controls.isKeyPressed(KEY_RETURN);
		const bool keyAction2 = controls.ActionKeyPressed(AK_ACTION2) || controls.isKeyPressed(KEY_SPACE);
		const bool anyKeyPressed = keyLeft || keyRight || keyUp || keyDown || keyAction1 || keyAction2 || (hasCursor && controls.mousePressed1);


		// continuous keys update

		if (anyKeyPressed && data.canControl)
		{
			data.holdKeyTime = time;
		}

		if (anyKeyPressed && !data.canControl)
		{
			if ((time - data.holdKeyTime) > 7)
			{
				data.canControl = true;
				data.holdKeyTime += 2;
			}
		}

		if (!anyKeyPressed)
		{
			data.holdKeyTime = 0;
		}

		// control

		if (data.canControl && data.activeGroup !is null)
		{
			Group@ group = data.activeGroup;

			if (!group.keyReleased)
			{
				if (!keyAction1 && !keyAction2)
				{
					group.keyReleased = true;
				}
			}
			else if (group.editControl !is null || controls.externalControl)
			{
				// cease control until all keys unpressed after exiting from external control
				if (group.editControl is null)
				{
					data.canControl = false;
					return;
				}

				// input box control
				if (group.editControl.input !is null)
				{
					bool ok, cancel;
					group.editControl.input(group.editControl, controls.lastKeyPressed, ok, cancel);
					if (ok || cancel)
					{
						@group.editControl = null;
					}
				}
			}
			else
			{
				Vec2f currMousePos = controls.getMouseScreenPos();				
				if (hasCursor && (data.mousePos - currMousePos).Length() > 0)
				{
					PickGroupFromPosition(data, currMousePos);
					data.mousePos = currMousePos;
				}
				else
				{
					if (keyLeft)
					{
						if (!DoLeftControl(group))
						{
							DoPrevGroup(data, DoLeftControl);
						}
						onChangeControl(group);
					}
					else if (keyRight)
					{
						if (!DoRightControl(group))
						{
							DoNextGroup(data, DoRightControl);
						}
						onChangeControl(group);
					}
					else if (keyUp)
					{
						if (!DoUpControl(group))
						{
							DoPrevGroup(data, DoUpControl);
						}
						onChangeControl(group);
					}
					else if (keyDown)
					{
						if (!DoDownControl(group))
						{
							DoNextGroup(data, DoDownControl);
						}
						onChangeControl(group);
					}
				}

				if (keyAction1 || (hasCursor && controls.mousePressed1))
				{
					Select(rules, group, 0);
					Sound::Play("buttonclick");
				}
				if (keyAction2)
				{
					Select(rules, group, 1);
					Sound::Play("buttonclick");
				}
				if (data.activeGroup is null)
				{
					printf("EXIT UI");
					return;
				}

				if (anyKeyPressed)
				{
					data.canControl = false;
				}
			}
		}

		if (!anyKeyPressed)
		{
			data.canControl = true;
		}
	}

	void onChangeControl(Group@ group)
	{
		Sound::Play("select");
	}

	void Select(CRules@ rules, Group@ group, uint button)
	{
		CPlayer@ local = getLocalPlayer();
		Control@ control = group.activeControl;

		int index = getSelectionIndex(group, control.x, control.y);
		group.data.lastSelection.set(group.name, index);

		// callback first
		if (button == 0 && control.select !is null)
		{
			control.select(rules, group, control);
		}
		else if (button == 1 && control.select2 !is null)
		{
			control.select2(rules, group, control);
		}
		else   // else send command
		{
			CBitStream params;
			params.write_netid(local.getNetworkID());
			params.write_string(group.name);
			params.write_string(control.caption);
			rules.SendCommand(rules.getCommandID(CMD_STRING), params);
			CBlob@ localBlob = local.getBlob();
			if (localBlob !is null)
			{
				localBlob.SendCommand(localBlob.getCommandID(CMD_STRING), params);
			}
		}
		if (g_debug == 1)
			printf("CLICK [" + group.name + "] " + control.caption);
	}

	void Init(CRules@ rules)
	{
		Driver@ driver = getDriver();

		Data data;
		data.canControl = true;
		data.screenSize.Set(driver.getScreenWidth(), driver.getScreenHeight());
		@data.rules = rules;

		rules.set("ui", @data);

		rules.addCommandID(CMD_STRING);
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

	bool ReadControlCommand(CRules@ rules, u8 cmd, CBitStream@ params, CPlayer@ &out player, string &out group, string &out caption)
	{
		if (cmd == rules.getCommandID(CMD_STRING))
		{
			return ReadCommand(params, player, group, caption);
		}
		return false;
	}

	bool ReadControlCommand(CBlob@ blob, u8 cmd, CBitStream@ params, CPlayer@ &out player, string &out group, string &out caption)
	{
		if (cmd == blob.getCommandID(CMD_STRING))
		{
			return ReadCommand(params, player, group, caption);
		}
		return false;
	}

	// sort these somewhere

	void Grid(int columns, int rows)
	{
		Data@ data = getData();
		if (data.groups.length == 0)
		{
			warn("UI: No groups found for grid setting");
			return;
		}

		Group@ group = data.activeGroup;
		group.columns = columns;
		group.rows = rows;

		group.controls.resize(columns);
		for (uint i = 0; i < columns; i++)
		{
			group.controls[i].resize(rows);
		}
	}

	void Transition(Vec2f offset)
	{
		Data@ data = getData();
		Group@ group = data.activeGroup;
		Transition(group, offset);
	}

	void Transition(Group@ group, Vec2f offset)
	{
		Data@ data = getData();
		if (data is null || group is null)
		{
			return;
		}
		for (uint pIt = 0; pIt < data.proxies.length; pIt++)
		{
			Proxy@ proxy = data.proxies[ pIt ];
			if (proxy.group is group && proxy.control !is null)
			{
				SetupTransition(proxy, offset);
			}
		}
	}

	void Transition(Control@ control, Vec2f offset)
	{
		Data@ data = getData();
		if (data is null || control is null)
		{
			return;
		}
		for (uint pIt = 0; pIt < data.proxies.length; pIt++)
		{
			Proxy@ proxy = data.proxies[ pIt ];
			if (proxy.control is control)
			{
				SetupTransition(proxy, offset);
			}
		}
	}

	void ClearGroup(Group@ group)
	{
		for (uint y = 0; y < group.rows; y++)
		{
			for (uint x = 0; x < group.columns; x++)
			{
				RemoveProxies(group.data, group.controls[x][y]);
				@group.controls[x][y] = null;
			}
		}
		group.selx = group.sely = 0;
	}

	void SetSelector(const string &in selectorImage, Vec2f selectorOffset)
	{
		Data@ data = getData();
		if (data.groups.length == 0)
		{
			warn("UI: No groups found to add control");
			return;
		}
		Group@ group = data.activeGroup;
		group.selectorImage = selectorImage;
		group.selectorOffset = selectorOffset;
	}

	void PickGroupFromPosition(Data@ data, Vec2f pos)
	{
		const bool modals = hasModalGroup(data);

		Control@ activeControl;
		if (data.activeGroup !is null)
		{
			@activeControl = data.activeGroup.activeControl;
		}

		for (uint pIt = 0; pIt < data.proxies.length; pIt++)
		{
			Proxy@ proxy = data.proxies[ pIt ];
			// remove dead proxy
			if (!proxy.dead && proxy.group !is null && proxy.control !is null
			        && proxy.control.selectable && proxy.control !is activeControl
			        && ((modals && proxy.group.modal) || !modals))
			{
				if (pos.x > proxy.ul.x && pos.x < proxy.lr.x && pos.y > proxy.ul.y && pos.y < proxy.lr.y)
				{
					@data.activeGroup = proxy.group;
					@data.activeGroup.activeControl = proxy.control;
					onChangeControl(proxy.group);
					return;
				}
			}
		}
	}

	bool hasModalGroup(Data@ data)
	{
		for (uint groupIt = 0; groupIt < data.groups.length; groupIt++)
		{
			Group@ group = data.groups[ groupIt ];
			if (group.modal){
				return true;
			}
		}
		return false;
	}	


} // GUI
