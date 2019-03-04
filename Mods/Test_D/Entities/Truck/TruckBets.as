#include "GameColours.as"
#include "BackendCommon.as"
#include "LobbyCommon.as"
#include "TrucksCommon.as"

#define CLIENT_ONLY

const int KEY_DELAY = 4;
int _keyDelay = 0;

void onInit(CBlob@ this)
{
}

void onTick(CBlob@ this)
{
	if (!getNet().isClient() || !this.hasTag("show classes")){
		return;
	}
	CPlayer@ player = getLocalPlayer();
	CBlob@ playerblob = player.getBlob();
	if (playerblob is null){
		return;
	}

	u32 bet = playerblob.get_u32("bet");

	CControls@ controls = getControls();

	if (getGameTime() - _keyDelay > KEY_DELAY)
	{
		if (controls.isKeyPressed(controls.getActionKeyKey(AK_MOVE_UP)))
		{
			Sound::Play("select");
			if (bet < player.getCoins()){
				bet++;
			}
			_keyDelay = getGameTime();
		}
		else if (controls.isKeyPressed(controls.getActionKeyKey(AK_MOVE_DOWN)))
		{
			Sound::Play("select");
			if (bet > 0){
				bet--;
			}
			_keyDelay = getGameTime();
		}

		playerblob.set_u32("bet", bet);
		playerblob.Sync("bet", false);
	}
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	detached.set_u32("bet", 0);
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint@ attachedPoint)
{
	attached.set_u32("bet", 0);
}

// RENDER

const string _arrow = "Sprites/UI/selection_arrow.png";

void onRender(CSprite@ this)
{
	CRules@ rules = getRules();
	CBlob@ blob = this.getBlob();
	CPlayer@ player = getLocalPlayer();
	CBlob@ playerblob = player.getBlob();

	if (playerblob is null || !blob.hasTag("show classes") || player.getCoins() == 0)
	{
		return;
	}

	u32 bet = playerblob.get_u32("bet");
	CPlayer@[] queuedPlayers;
	GetPlayersFromTruck(blob, queuedPlayers);
	u32 pool = Lobby::getPlayerBets( queuedPlayers ); 

	GUI::SetFont("gui");

	Vec2f screenpos = blob.getScreenPos();
	screenpos.x = getDriver().getScreenCenterPos().x;

	bool drawDownArrow = false;

	string text;
	Vec2f textPos( screenpos.x, screenpos.y );

	if (bet == 0)
	{
		text = "BET ON YOURSELF ["+getControls().getActionKeyKeyName(AK_MOVE_UP)+"]";
	}
	else
	{
		text = "\nCurrent bet: " + bet + "c\nPool: " + pool +"c\nPotential win: " + (pool - bet) + "c";
		drawDownArrow = true;
	}

	// current bet text

	Vec2f dim;
	GUI::GetTextDimensions(text, dim);
	DrawTRGuiFrame(textPos - dim * 0.5f - Vec2f(8,0), textPos + dim * 0.5f + Vec2f(8,8));
	GUI::DrawTextCentered(text, textPos, Colours::WHITE);

	// up/down arrows

	Vec2f arrowframesize = Vec2f(16, 16);
	Vec2f arrowOffset(0.0f, 8.0f + Maths::Sin(getGameTime() * 0.25f) * 2.0f);
	arrowOffset -= arrowframesize * 0.5f;
	Vec2f upArrowPos( textPos.x, textPos.y - 30.0f );
	Vec2f downArrowPos( textPos.x, textPos.y + 24.0f );

	GUI::DrawIcon(_arrow,
	              0,
	              arrowframesize,
	              upArrowPos + arrowOffset,
	              0.5f);

	if (drawDownArrow)
	{
		GUI::DrawIcon(_arrow,
		              1,
		              arrowframesize,
		              downArrowPos + arrowOffset,
		              0.5f);
	}
}
