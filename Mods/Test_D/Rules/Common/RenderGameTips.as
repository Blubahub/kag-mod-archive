#define CLIENT_ONLY

string[] tips_files;
const s32 tip_file_time_seconds = 3;
s32 tip_index;
u32 last_tip_time;

void onRestart(CRules@ this)
{
	tips_files = array<string>();
}

void onInit(CRules@ this)
{
	onRestart(this);
}

void onTick(CRules@ this)
{
	//note: we only shred our local client version :)
	if (this.exists("tips_files") && this.get_string("tips_files") != "")
	{
		tip_index = 0;
		last_tip_time = Time();
		tips_files = this.get_string("tips_files").split(",");
		this.set_string("tips_files", "");
	}

	CControls@ controls = getControls();

	if (Time() > last_tip_time + tip_file_time_seconds ||
	        controls !is null && (
	            controls.isKeyJustPressed(controls.getActionKeyKey(AK_ACTION2)) ||
	            controls.isKeyJustPressed(KEY_RETURN) ||
	            controls.isKeyJustPressed(KEY_SPACE) ||
	            controls.isKeyJustPressed(KEY_ESCAPE)
	        ))
	{
		last_tip_time = Time();
		tip_index++;
	}

	if(tip_index < tips_files.length)
	{
		this.Tag("showing_tips");
	}
	else
	{
		this.Untag("showing_tips");
	}
}

void onRender(CRules@ this)
{
	if (tip_index < tips_files.length)
	{
		GUI::DrawIcon(tips_files[tip_index], 0, Vec2f(568, 360),
		              Vec2f(0, 0),
		              0.5f);
	}

}
