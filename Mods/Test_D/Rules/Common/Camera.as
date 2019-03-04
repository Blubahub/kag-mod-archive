#define CLIENT_ONLY

#include "SoldierCommon.as";

const f32 _deadzoom = 1.0f;
const f32 _defaultzoom = 0.5f;
const f32 _zoomspeed = 0.1f;
int _deathCam = 0;

void onInit(CRules@ this)
{
	onRestart( this );
}

void onRestart(CRules@ this)
{
	CCamera@ camera = getCamera();
	if (camera !is null)
	{
		CMap@ map = getMap();
		camera.setPosition(Vec2f(map.tilemapwidth * map.tilesize * 0.5f, map.tilemapheight * map.tilesize * 0.5f));
		camera.targetDistance = _defaultzoom;
	}
}

void onSetPlayer(CRules@ this, CBlob@ blob, CPlayer@ player)
{
	CCamera@ camera = getCamera();
	if (camera !is null && player !is null
	        && (player is getLocalPlayer()
	            //|| (g_debug > 0 && player.isBot())
	           )
	   )
	{
		camera.setPosition(blob.getPosition());
		camera.setTarget(blob);
		camera.targetDistance = _defaultzoom;
	}
}

void ScrollingCamera( CRules@ this )
{
	CCamera@ camera = getCamera();
	const int players = getLocalPlayersCount();
	CBlob@ localblob = getLocalPlayerBlob();

	if (camera !is null)
	{
		CMap@ map = getMap();
		Vec2f campos = camera.getPosition();

		if (players == 0 || localblob is null || this.hasTag("camera control"))
		{
			//campos = Vec2f(map.tilemapwidth * map.tilesize * 0.5f, map.tilemapheight * map.tilesize * 0.5f);
			camera.targetDistance = _defaultzoom;
			_deathCam = 0;
		}
		else
		{
			bool dead = false;
			// get average of local players position
			Vec2f p;
			u8 team;
			f32 minX = map.tilemapwidth * map.tilesize, maxX = 0.0f;
			for (uint i = 0; i < players; i++)
			{
				CBlob@ blob = getLocalPlayerBlob(i);
				team = blob.getTeamNum();
				Soldier::Data@ data = Soldier::getData(blob);
				Vec2f pos;
				if (data !is null)
				{
					if (data.isMyPlayer && data.dead){
						dead = true;
						pos = data.pos;
					}
					else {
						pos = data.cameraTarget;
					}
				}
				else
				{
					pos = blob.getPosition();
				}
				if (pos.x < minX)
					minX = pos.x;
				if (pos.x > maxX)
					maxX = pos.x;
				p += pos;
			}
			p /= float(players);

			// adjust from center
			minX += 40.0f;
			maxX -= 40.0f;

			// clamp to left or right
			if (p.x > minX)
				p.x = minX;
			else if (p.x < maxX)
				p.x = maxX;

			f32 speed_fac = 0.005f;
			f32 max_amount = 1.0f;

			const f32 offsetX = Maths::Min(speed_fac * Maths::Max(0.1f, Maths::Abs(p.x - campos.x)), max_amount);
			const f32 offsetY = Maths::Min(speed_fac * Maths::Max(0.1f, Maths::Abs(p.y - campos.y)), max_amount);

			campos.x = campos.x + (p.x - campos.x) * offsetX * 0.1f;
			campos.y = campos.y + (p.y - campos.y) * offsetY * 0.1f;

			// zoom

			f32 currentZoom = _defaultzoom;

			if (_deathCam > 0){
				currentZoom = _deadzoom;
			}

			if (camera.targetDistance <= currentZoom-_zoomspeed)
			{
				camera.targetDistance += _zoomspeed;
			}
			else if (camera.targetDistance >= currentZoom+_zoomspeed)
			{
				camera.targetDistance -= _zoomspeed;
			}

			// clamp to edge of map
			const int screenWidth = getDriver().getScreenWidth();
			const int screenHeight = getDriver().getScreenHeight();
			const f32 edgeMod = 0.25f / camera.targetDistance;
			f32 edge = screenWidth * edgeMod + map.tilesize * 2;
			if (campos.x < edge)
			{
				campos.x = edge;
			}
			edge = map.tilemapwidth * map.tilesize - screenWidth * edgeMod - map.tilesize * 2;
			if (campos.x > edge)
			{
				campos.x = edge;
			}
			edge = map.tilemapheight * map.tilesize - screenHeight * edgeMod - map.tilesize * 2;
			if (camera.targetDistance < 1.0f)
			{
				campos.y = edge;
			}

			camera.setPosition(campos);

			Sound::SetListenerPosition(p);
		}
	}
}

void RecordedCamera( CRules@ this )
{
	CCamera@ camera = getCamera();
	const int players = getLocalPlayersCount();
	CBlob@ localblob = getLocalPlayerBlob();

	if (camera !is null)
	{
		CMap@ map = getMap();
		Vec2f campos = camera.getPosition();

		if (players == 0 || localblob is null || this.hasTag("camera control"))
		{
			//campos = Vec2f(map.tilemapwidth * map.tilesize * 0.5f, map.tilemapheight * map.tilesize * 0.5f);
			camera.targetDistance = _defaultzoom;
			_deathCam = 0;
		}
		else
		{
			Vec2f p;
			CBlob@ blob = getLocalPlayerBlob();
			if (blob is null)
				return;
			p = blob.getPosition();

			f32 speed_fac = 0.05f;
			f32 max_amount = 1.0f;

			campos.x = campos.x + (p.x - campos.x) * speed_fac;
			campos.y = campos.y + (p.y - campos.y) * speed_fac;

			// clamp to edge of map
			const int screenWidth = getDriver().getScreenWidth();
			const int screenHeight = getDriver().getScreenHeight();
			const f32 edgeMod = 0.25f / camera.targetDistance;
			f32 edge = screenWidth * edgeMod + map.tilesize * 2;
			if (campos.x < edge)
			{
				campos.x = edge;
			}
			edge = map.tilemapwidth * map.tilesize - screenWidth * edgeMod - map.tilesize * 2;
			if (campos.x > edge)
			{
				campos.x = edge;
			}
			edge = map.tilemapheight * map.tilesize - screenHeight * edgeMod - map.tilesize * 2;
			if (camera.targetDistance < 1.0f)
			{
				campos.y = edge;
			}

			camera.setPosition(campos);
			Sound::SetListenerPosition(p);
		}
	}
}

void onTick(CRules@ this)
{
	if (!v_drawhud)
	{
		ScrollingCamera( this );
	}
	else
	{
		ScrollingCamera( this );
	}
}


