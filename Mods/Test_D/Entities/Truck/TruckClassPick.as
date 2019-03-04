#include "GameColours.as"
#include "ClassesCommon.as"
#include "RadioCharacters.as"


const Soldier::Type[] SKIRMISH_CLASSES = { Soldier::ASSAULT, Soldier::SNIPER, Soldier::ENGINEER, Soldier::COMMANDO };
const Soldier::Type[] CAMPAIGN_CLASSES = { Soldier::ASSAULT, Soldier::SNIPER, Soldier::MEDIC, Soldier::ENGINEER, Soldier::COMMANDO};

Soldier::Type[]@ getGamemodeClasses(CBlob@ this)
{
	string gamemode = this.get_string("gamemode");
	return gamemode == "Skirmish" ? SKIRMISH_CLASSES : CAMPAIGN_CLASSES;
}

void onInit(CBlob@ this)
{
	this.set_u8("class selection", 0);
}

void onTick(CBlob@ this)
{
	if (!getNet().isClient() || !this.hasTag("show classes"))
	{
		return;
	}

	int classSel = this.get_u8("class selection");
	Soldier::Type[]@ classes = getGamemodeClasses(this);
	const int len = classes.length;
	CControls@ controls = getControls();
	int failsafe = 0;


	if (controls.isKeyJustPressed(controls.getActionKeyKey(AK_MOVE_LEFT)))
	{
		Sound::Play("select");
		while (failsafe++ < len)
		{
			classSel--;
			if (classSel < 0)
			{
				classSel = len - 1;
			}
			if (!isPicked(classes[classSel], this))
			{
				break;
			}
		}
		SendPick(this, classSel);
	}
	else if (controls.isKeyJustPressed(controls.getActionKeyKey(AK_MOVE_RIGHT)))
	{
		Sound::Play("select");
		while (failsafe++ < len)
		{
			classSel++;
			if (classSel >= len)
			{
				classSel = 0;
			}
			if (!isPicked(classes[classSel], this))
			{
				break;
			}
		}
		SendPick(this, classSel);
	}
	if (controls.isKeyJustPressed(controls.getActionKeyKey(AK_ACTION1)))
	{
		Sound::Play("buttonclick");
	}
	if (controls.isKeyJustPressed(controls.getActionKeyKey(AK_ACTION2)))
	{
		Sound::Play("option");
	}
}

void SendPick(CBlob@ this, const u8 classSel)
{
	this.set_u8("class selection", classSel);
	CBlob@ playerblob = getLocalPlayerBlob();
	if (playerblob !is null)
	{
		Soldier::Type[]@ classes = getGamemodeClasses(this);

		playerblob.set_u8("class pick", classes[classSel]);
		playerblob.Sync("class pick", false);
		//	printf("syncing class " + classSel);
	}
}


void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint@ attachedPoint)
{
	if (attached.isMyPlayer() && attached.getPlayer() !is null)
	{
		this.Tag("show classes");

		Soldier::Type[]@ classes = getGamemodeClasses(this);
		u8 blobclass = 255;

		u8 picked = attached.get_u8("class pick");
		for (u32 i = 0; i < classes.length; i++)
		{
			//skip any picked classes
			if (isPicked(classes[i], this))
				continue;

			if (blobclass == 255)
			{
				blobclass = i;
			}

			if (classes[i] == picked)
			{
				blobclass = i;
				break;
			}
		}
		SendPick(this, blobclass);
	}
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	if (detached.isMyPlayer() && detached.getPlayer() !is null)
	{
		this.Untag("show classes");
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("ride away"))
	{
		this.Untag("show classes");
	}
}

bool isPicked(int classnum, CBlob@ fortruck)
{
	if (fortruck.get_string("gamemode") == "Skirmish")
	{
		return false;
	}

	CBlob@[] players;
	getBlobsByTag("player", @players);
	for (uint i = 0; i < players.length; i++)
	{
		CBlob@ blob = players[i];
		//skip players not in this truck
		if (!fortruck.isAttachedTo(blob))
			continue;

		u8 classSel  = blob.get_u8("class pick");
		//printf("classel " + classSel + " i " + classnum);
		if (classSel == classnum)
		{
			return true;
		}
	}
	return false;
}

// RENDER

void onRender(CSprite@ this)
{
	CRules@ rules = getRules();
	CBlob@ blob = this.getBlob();

	if (!blob.hasTag("show classes"))
	{
		return;
	}

	GUI::SetFont("gui");

	Vec2f screenpos = blob.getScreenPos();
	screenpos.x = getDriver().getScreenCenterPos().x;
	SColor color = color_white;

	Soldier::Type[]@ classes = getGamemodeClasses(blob);
	int len = classes.length;

	Vec2f pixeloffset = Vec2f(1, 1);

	Vec2f menusize = Vec2f(220, 70);
	Vec2f pos = screenpos;
	pos.y -= menusize.y + 45;

	float textPanelHeight = 15.0f;
	Vec2f topleft = pos - menusize * 0.5f;

	u8 classSel = blob.get_u8("class selection");

	bool renderFaces = (blob.get_string("gamemode") == "Campaign");

	for (uint i = 0; i < len; i++)
	{
		Vec2f framesize = Vec2f(32, 48);
		Vec2f p = pos + Vec2f((0.5f + i - len * 0.5f) * framesize.x * 1.2f, 0.0f);
		if (i == classSel)
		{
			p.y -= 8.0f;
			Vec2f arrowframesize = Vec2f(16, 16);
			GUI::DrawIcon("Sprites/UI/selection_arrow.png",
			              0,
			              arrowframesize,
			              p + Vec2f(0, framesize.y * 0.5f + 8.0f + Maths::Sin(getGameTime() * 0.25f) * 2.0f) - arrowframesize * 0.5f,
			              0.5f);

			if (renderFaces)
			{
				Vec2f radioframe = Vec2f(48, 48);
				Vec2f rpos = Vec2f(screenpos.x, 20);

				RadioCharacter@ ourchar = getCharacterFor(blob.getTeamNum(), classes[i]);
				GUI::DrawIcon("Sprites/UI/radio_portraits.png",
				              ourchar.frame,
				              radioframe,
				              rpos + radioframe * -0.5f ,
				              0.5f);

				GUI::DrawTextCentered(ourchar.name, rpos + Vec2f(0, 28), Colours::WHITE);
			}
		}

		//dont shade our selection
		if (!isPicked(classes[i], blob) || i == classSel)
		{
			GUI::DrawIcon("Sprites/classcards.png", classes[i], framesize, p - framesize * 0.5f, 0.5f);
		}
		else
		{
			GUI::DrawIcon("Sprites/classcards.png", classes[i], framesize, p - framesize * 0.5f, 0.5f, SColor(255, 128, 128, 128));
		}
	}

	GUI::DrawTextCentered(CLASS_NAMES[classes[classSel]], pos + Vec2f(0, -menusize.y * 0.5f - 8.0f), Colours::WHITE);
}
