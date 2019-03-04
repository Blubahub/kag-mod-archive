#include "GameColours.as"
#include "BackendCommon.as"
#include "LobbyCommon.as"
#include "TrucksCommon.as"
#include "LobbyStatsCommon.as"

string[] _names;
const int KEY_DELAY = 3;
int _keyDelay = 0;
int _index = 0;
const int MAX_NAMES = 12;

void onInit(CBlob@ this)
{
	this.addCommandID("servers");
}

void onTick(CBlob@ this)
{
	const int count = _names.length;

	// periodically renew servers info
	if (getNet().isServer())
	{
		if (getGameTime() % 300 == 0)
		{
			CBlob@[] players;
			getBlobsByTag("player", @players);
			for (uint i = 0; i < players.length; i++)
			{
				CBlob@ blob = players[i];
				//skip players not in this truck
				if (!this.isAttachedTo(blob))
					continue;
				SendServersToPlayer( this, blob.getPlayer());
			}									
		}
	}

	if (!getNet().isClient() || !this.hasTag("show classes") || count == 0){
		return;
	}
	CPlayer@ player = getLocalPlayer();
	CBlob@ playerblob = player.getBlob();
	if (playerblob is null){
		return;
	}

	CControls@ controls = getControls();

	if (getGameTime() - _keyDelay > KEY_DELAY)
	{
		if (controls.isKeyPressed(controls.getActionKeyKey(AK_MOVE_DOWN)))
		{
			Sound::Play("select");
			_index++;
			if (_index >= count)
				_index = 0;
			_keyDelay = getGameTime();
		}
		else if (controls.isKeyPressed(controls.getActionKeyKey(AK_MOVE_UP)))
		{
			Sound::Play("select");
			_index--;
			if (_index < 0)
				_index = count-1;
			_keyDelay = getGameTime();
		}
	}
}


void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint@ attachedPoint)
{
	// server send recently used servers

	CPlayer@ player = attached.getPlayer();
	SendServersToPlayer( this, player );
}

void SendServersToPlayer( CBlob@ this, CPlayer@ player )
{
	if (getNet().isServer() && player !is null)
	{
		LobbyStats@ stats = getStats();

		string[] names;
		for (int i = 0; i < stats._players_times_cache.length; i++)
		{
			if (stats._players_times_cache[i] > Time() - 5 * 60 && stats._players_cache[i] != player.getCharacterName())
			{
				names.push_back(stats._players_cache[i]);
			}
		}		

		//TEST
		/*names.push_back("1Homer");
		names.push_back("2Lisa");
		names.push_back("3Bart");
		names.push_back("const");
		names.push_back("d");
		names.push_back("else");
		names.push_back("for");
		names.push_back("got");
		names.push_back("hasTag");
		names.push_back("if");
		names.push_back("j");
		names.push_back("KEY_DELAY");
		names.push_back("l");
		names.push_back("more");
		names.push_back("null");
		names.push_back("p");*/
		//TEST

		if(player !is null && !player.isBot())
		{
			CBitStream params;
			params.write_u16(names.length);
			for (uint i=0; i < names.length; i++)
			{
				params.write_string(names[i]);
			}

			this.server_SendCommandToPlayer(this.getCommandID("servers"), params, player);			
		}		
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("servers") && getNet().isClient())
	{
		_names.clear();
		u16 length = params.read_u16();
		for (uint i=0; i < length; i++)
		{
			_names.push_back( params.read_string() );
		}
	}
}

// RENDER

const string _arrow = "Sprites/UI/selection_arrow.png";

void onRender(CSprite@ this)
{
	CRules@ rules = getRules();
	CBlob@ blob = this.getBlob();
	CPlayer@ player = getLocalPlayer();
	CBlob@ playerblob = player.getBlob();
//printf("_servers.server_names.length " + _servers.server_names.length);
	const int count = _names.length;
	if (playerblob is null || !blob.hasTag("show classes") || count == 0)
	{
		return;
	}
	if (_index < 0 || _index >= count || count < MAX_NAMES){
		_index = 0;
	}

	GUI::SetFont("irrlicht");

	Vec2f screenpos = blob.getScreenPos();
	screenpos.x = getDriver().getScreenCenterPos().x;

	Vec2f textPos( screenpos.x, screenpos.y );
	string text = "Currently playing:                  \n";
	if (_names.length >= MAX_NAMES){
		text +="(Press [DOWN] for more...)    \n";
	}
	text += "\n";

	int nameHeight = 8;
	Vec2f dim;
	GUI::GetTextDimensions(text, dim);
		
	dim.y += _names.length * (nameHeight-2);

	if (blob.getScreenPos().x > getDriver().getScreenCenterPos().x){
		// right
		textPos.x = dim.x - 35.0f;
	}
	else{ 
		// left
		textPos.x = getDriver().getScreenWidth() - dim.x + 35.0f;
	}
	textPos.y += -dim.y*0.25f;

	DrawTRGuiFrame(textPos - dim * 0.5f - Vec2f(8,0), textPos + dim * 0.5f + Vec2f(8,8));
	GUI::DrawTextCentered(text, textPos + Vec2f(0,-dim.y*0.33f + 8), Colours::WHITE);

	GUI::SetFont("irrlicht");
	Vec2f namesPos = textPos;
	namesPos.x -= dim.x*0.5f;
	namesPos.y -= dim.y*0.25f;
	int drawn = 0;
	for (uint i = _index; i < Maths::Min((_index+MAX_NAMES), _names.length); i++)
	{
		GUI::DrawText( _names[i], namesPos, color_white);
		namesPos.y += 8;
		drawn++;
	}
	if (_index > 0)
	{
		for (uint i = 0; i < MAX_NAMES-drawn; i++)
		{
			if (i < _names.length){
				GUI::DrawText( _names[i], namesPos, color_white);
				namesPos.y += 8;
			}
		}
	}

	// up/down arrows

	if (_names.length >= MAX_NAMES)
	{
		Vec2f arrowframesize = Vec2f(16, 16);
		Vec2f arrowOffset(0.0f, 8.0f + Maths::Sin(getGameTime() * 0.25f) * 2.0f);
		arrowOffset -= arrowframesize * 0.5f;
		Vec2f arrowPos( textPos.x, textPos.y + dim.y*0.5f - 5.0f );

		GUI::DrawIcon(_arrow,
		              1,
		              arrowframesize,
		              arrowPos + arrowOffset,
		              0.5f);
	}
}
