//player grave
#include "ModName"

void onInit(CBlob@ this)
{
	if (!this.exists("text"))
	{
		this.set_string("text", "Just a small example"); // Should be ok even if the server and the client run it?
	}
}

void onInit(CSprite@ this)
{
	CSpriteLayer@ graveType;
	this.SetTexture(" ");
	print(""+XORRandom(5));
	switch(XORRandom(5))
	{
		case 0:
			@graveType = this.addSpriteLayer("grave", CurrentModName+"/Entities/Graves/Items/graveDamaged.png",16,16);
			break;

		case 1:
			@graveType = this.addSpriteLayer("grave", CurrentModName+"/Entities/Graves/Items/graveDamaged2.png",16,16);
			break;

		case 2:
			@graveType = this.addSpriteLayer("grave", CurrentModName+"/Entities/Graves/Items/graveMossy.png",16,16);
			break;

		case 3:
			@graveType = this.addSpriteLayer("grave", CurrentModName+"/Entities/Graves/Items/graveBasic.png",16,16);
			break;

		case 4:
			@graveType = this.addSpriteLayer("grave", CurrentModName+"/Entities/Graves/Items/graveUnreadable.png",16,16);

			if(getNet().isServer())
			{
				string[] corruptedList = {"&AC*ASZ( ","%czxd$% "," £^zxc%"," *!ZdVD","%ZXASKDA* ","ASC*Z ","*LK £PO","@D {E" ,"~F{ EQ A","/V !£",">£ ) o("};
				string[]@ tokens = this.getBlob().get_string("text").split(" ");
				string text = "";
				for(int a = 0; a < tokens.length; a++)
				{
					switch(XORRandom(4))
					{
						case 0:
							//do nothing
							break;

						case 1:
							text += corruptedList[XORRandom(11)];
							break;

						case 2:
							text += corruptedList[XORRandom(11)];
							break;

						case 3:
							text += corruptedList[XORRandom(11)] + tokens[XORRandom(tokens.length)];
							break;

					}
				}
				this.getBlob().set_string("text",text);
				this.getBlob().Sync("text",false);
			}
			break;
	}
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
    return false;
}



void onTick(CBlob@ this)
{
	if(this.isOnGround())
	{
		this.getSprite().SetZ(-10.0f);
		this.getShape().SetStatic(true);//set static (no moving)
		this.doTickScripts = false;//now no more ticks
		this.server_SetTimeToDie(30);//will die in 30 seconds
		print(""+this.isSnapToGrid());

	}	
}

void onDie(CBlob@ this)
{
	server_DropCoins(this.getPosition(),this.get_u16("coins"));
}


void onCollision( CBlob@ this, CBlob@ blob, bool solid )
{
	if(blob !is null)
	{
		CPlayer@ player = blob.getPlayer();
		if(player !is null)
		{
			player.Tag("Grave Nearby");
			player.set_string("text", this.get_string("text"));
			player.set_Vec2f("gravePos", Vec2f(this.getPosition()));
		}
	}
}
/*
void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;

	if (getHUD().menuState != 0) return;

	CBlob@ localBlob = getLocalPlayerBlob();
	Vec2f pos2d = blob.getScreenPos();

	if (localBlob is null)
	{
		return;
	} 

	if (
	    ((localBlob.getPosition() - blob.getPosition()).Length() < 0.5f * (localBlob.getRadius() + blob.getRadius())) &&
	    (!getHUD().hasButtons()))
	{
		CPlayer@ player = localBlob.getPlayer();
		if(player !is null)
		{
			if(!player.hasTag("Menu stuff"))
			{
				player.Tag("Menu stuff");
				if(!player.hasTag("Grave Nearby"))
				{
					player.Tag("Grave Nearby");
					player.set_string("text", blob.get_string("text"));

				}
			}
		}
	}
	else if(((localBlob.getPosition() - blob.getPosition()).Length() < 1.5f * (localBlob.getRadius() + blob.getRadius())) &&
	    (!getHUD().hasButtons()))
	{
		CPlayer@ player = localBlob.getPlayer();
		if(player !is null)
		{
			player.Untag("Menu stuff");
			player.Untag("Grave Nearby");
		}
	}
	
}
*/