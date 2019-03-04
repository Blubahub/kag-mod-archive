#include "ParachuteCommon.as"
#include "ExplosionParticles.as"
#include "Explosion.as"
#include "GameColours.as"
#include "Sparks.as"
#include "SoldierCommon.as"

int _mode = 0;
int _maxModes = 6;
int _facing = 0;
int _skin = 1;

void onInit(CRules@ this)
{
	if (sv_test)
	{
		getHUD().ShowCursor();
		print("DEBUG MOUSE ON"); 
	}
}

void onTick(CRules@ this)
{
	if (!sv_test)
		return;

	CControls@ controls = getControls();
	Vec2f mousepos = controls.getMouseWorldPos();

	if (controls.isKeyJustPressed(KEY_LBUTTON))
	{
		CBlob@ blob;

		// grenade

		switch (_mode)
		{
			case 0:
			{
				@blob = server_CreateBlobNoInit("soldier");
				if (blob !is null)
				{
					blob.setPosition(mousepos);
					blob.set_u8("class", 5);					
					blob.set_u8("skin", (_skin++) % 7);
					blob.Init();
					//after init
					blob.getBrain().server_SetActive( true );
					blob.SetFacingLeft((_facing++) % 2 == 0);
				}
			}
			break;		
			case 1:
			{
				@blob = server_CreateBlobNoInit("pet");
				if (blob !is null)
				{
					blob.setPosition(mousepos);
					blob.set_u8("type", XORRandom(5));
					blob.set_netid("owner", getLocalPlayerBlob().getNetworkID());
					blob.Init();
				}
			}
			break;
			case 2:
			{
				@blob = server_CreateBlob("grenade", 255, mousepos);
				if (blob !is null)
				{
					blob.server_SetTimeToDie(3.0f);
				}
			}
			break;
			case 3:
			{
				@blob = server_CreateBlobNoInit("supply");
				if (blob !is null){
					blob.setPosition(mousepos);
					blob.set_u8("supply type", 1);
					blob.Init();
				}
			}
			break;
			case 4:
			{
				@blob = server_CreateBlob("truck", 255, mousepos);
				for (uint i = 0; i < 5; i++){
					CBlob@ soldier = server_CreateBlobNoInit("soldier");
					if (soldier !is null)
					{
						soldier.setPosition(mousepos);
						soldier.set_u8("class", 5);					
						soldier.set_u8("skin", (_skin++) % 7);
						soldier.Init();
						//after init
						soldier.getBrain().server_SetActive( true );

						CBitStream params;
						params.write_netid(soldier.getNetworkID());
						blob.SendCommand(blob.getCommandID("use"), params);						
					}

				}

			}
			break;		
			case 5:
			{
				@blob = server_CreateBlob("remotebomb", 255, mousepos);
			}
			break;	
		}

		if (blob !is null)
		{
			if (controls.isKeyPressed(KEY_LSHIFT))
			{
				AddParachute(blob);
			}
		}
	}

	if (controls.isKeyJustPressed(KEY_RBUTTON))
	{
		_mode++;
		if (_mode >= _maxModes)
		{
			_mode = 0;
		}
	}

	// explosion 
	if (controls.isKeyJustPressed(KEY_KEY_Q))
	{
		const f32 RADIUS = 40.0f;
		const f32 DAMAGE = 3.0f;		
		ExplodeAtPosition(null, mousepos, RADIUS, DAMAGE);
		if (getNet().isClient())
		{
			Particles::Sparks(mousepos, 18, 37.0f, SColor(Colours::RED));
			Particles::Sparks(mousepos, 13, 37.0f, SColor(Colours::YELLOW));
			Particles::Explosion(mousepos, 8, Vec2f_zero);
			Sound::Play("GrenadeExplosion", mousepos);
		}
	}

	// kill all 
	if (controls.isKeyJustPressed(KEY_KEY_P))
	{
        CBlob@[] blobs;
        getBlobsByName( "soldier", @blobs );
        for (uint i=0; i < blobs.length; i++) 
        {
            CBlob@ blob = blobs[i];
            Soldier::Data@ data = Soldier::getData( blob );
            data.dead = true;
        }		
	}	

	// bring all 
	if (controls.isKeyJustPressed(KEY_KEY_O))
	{
        CBlob@[] blobs;
        getBlobsByName( "soldier", @blobs );
        for (uint i=0; i < blobs.length; i++) 
        {
            CBlob@ blob = blobs[i];
            Soldier::Data@ data = Soldier::getData( blob );
            data.pos = mousepos + Vec2f(-50,0) + Vec2f(XORRandom(100),-XORRandom(30));
            blob.setPosition(data.pos);
        }		
	}	

}

void onRender(CRules@ this)
{
	if (!sv_test)
		return;

	CControls@ controls = getControls();
	string modeName = "";
	switch (_mode)
	{
		case 0: modeName = "soldier"; break;
		case 1: modeName = "pet"; break;
		case 2: modeName = "grenade"; break;
		case 3: modeName = "supply"; break;
		case 4: modeName = "truck"; break;
		case 5: modeName = "remotebomb"; break;
	}

	GUI::SetFont("irrlicht");
	GUI::DrawText(modeName, controls.getMouseScreenPos() + Vec2f(-15.0f, 25.0f), SColor(255, 19, 229, 99));
}


