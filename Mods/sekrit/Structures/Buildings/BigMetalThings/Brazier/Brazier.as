//Made by vamist
void onInit(CSprite@ this)
{
	this.SetAnimation("default");// sets default animation

}	

void onInit(CBlob@ this)
{
	this.addCommandID("nowLetThereBeLight!");//good name
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	// button for runner
	// create menu for class change
	if (caller.getTeamNum() == this.getTeamNum())
	{
		CBitStream params;
		caller.CreateGenericButton("$change_class$", Vec2f(10, 0), this, this.getCommandID("nowLetThereBeLight!"), getTranslatedString("Light"), params);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if(cmd == this.getCommandID("nowLetThereBeLight!"))
	{
		this.getSprite().SetAnimation("lit");
	}
}
