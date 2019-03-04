// Tent logic

#include "StandardRespawnCommand.as"

bool MusicOn = false;

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-50.0f);
	this.set_TileType("background tile", CMap::tile_castle_back);
	this.CreateRespawnPoint("tent", Vec2f(0.0f, -4.0f));
	InitClasses(this);
	this.Tag("change class drop inventory");
	//this.getSprite().PlaySound("/ringwraith.ogg");
	//if(getGameTime() % 15 == 0)
	//{
	//	Sound::Play("Entities\Special\Tent2\ringwraith.ogg");
	//}

	this.Tag("respawn");
	
	// minimap
	this.SetMinimapOutsideBehaviour(CBlob::minimap_snap);
	this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 1, Vec2f(8, 8));
	this.SetMinimapRenderAlways(true);

	// defaultnobuild
	this.set_Vec2f("nobuild extend", Vec2f(0.0f, 8.0f));
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	// button for runner
	// create menu for class change
	if (canChangeClass(this, caller) && caller.getTeamNum() == this.getTeamNum())
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		caller.CreateGenericButton("$change_class$", Vec2f(0, 0), this, SpawnCmd::buildMenu, "Swap Class", params);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	onRespawnCommand(this, cmd, params);
 //	this.getSprite().SetEmitSoundPaused(false);
	if(MusicOn == false)
{
//this.getSprite().PlaySound("/isengard.ogg");
//this.getSprite().PlayRandomSound("/mordor.ogg");

MusicOn = true;

} 
}

/* void onTick(CBlob@ this)
{




}


void PlayMusic(CBlob@ this)
{
//Vec2f pos = this.getPosition();
this.getSprite().PlaySound("/mordor.ogg");
//this.getSprite().SetEmitSoundPaused(false);
//Sound::Play("Entities/Characters/Sounds/NoAmmo.ogg");
//Sound::Play("Entities/Special/Tent2/mordor.ogg");

} */