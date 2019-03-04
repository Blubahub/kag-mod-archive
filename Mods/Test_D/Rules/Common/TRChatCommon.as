const string radio_setup_name = "radio_icon_stream";
const string radio_split_id = ",:|:,";

int lookupIcon(string name, string[]@ arr)
{
	for (uint i = 0; i < arr.length - 1; i++)
	{
		if (arr[i] == name)
		{
			return parseInt(arr[i + 1]);
		}
	}

	return 0;
}

string[] getTRChatNameIconLookup()
{
	CRules@ rules = getRules();

	if (!rules.exists(radio_setup_name))
		rules.set_string(radio_setup_name, "");

	return rules.get_string(radio_setup_name).split(radio_split_id);
}

void setTRChatNameIconLookup(string[]@ name_icon_arr)
{
	CRules@ rules = getRules();
	rules.set_string(radio_setup_name, join(name_icon_arr, radio_split_id));
	rules.Sync(radio_setup_name, true);
}

void SendChat(CRules@ this, u16 id, string message)
{
	CBitStream params;
	params.write_netid(id);
	params.write_string(message);
	this.SendCommand(this.getCommandID("say_portrait"), params);
}

// Portraits

shared class Portrait
{
	string name;
	int team, icon;
	u8 side;
	string[] fields;
	f32 showTimer;
	u16 player_id;
	string[] chat;
	f32 chatTimer;
	u32 lastSpoke;
};
