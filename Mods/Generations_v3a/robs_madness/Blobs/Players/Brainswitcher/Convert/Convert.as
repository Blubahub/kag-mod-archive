#include "Hitters.as";
#include "PixelOffsets.as"
#include "RunnerTextures.as"

void onInit(CBlob@ this)
{
	//dont collide with edge of the map
	this.SetMapEdgeFlags(CBlob::map_collide_none);
	
	this.getShape().getConsts().bullet = true;
	
	this.getShape().SetGravityScale(0.0f);
	this.server_SetTimeToDie(10);
	
	this.Tag("can_dispell");
	
	// Sounds by TFlippy
	this.getSprite().PlaySound("WC3_MindGuy_Cast", 1.00f, 1.50f);
}

void onTick(CBlob@ this)
{
	
	this.setAngleDegrees(-((this.getVelocity()).Angle()+180));
	
	{
		u16 id = this.get_u16("target");
		if (id != 0xffff && id != 0)
		{
			CBlob@ b = getBlobByNetworkID(id);
			if (b !is null)
			{
				Vec2f vel = this.getVelocity();
				if (vel.LengthSquared() < 9.0f)
				{
					Vec2f dir = b.getPosition() - this.getPosition();
					dir.Normalize();


					this.setVelocity(vel + dir);
				}
			}
		}
	}
	if(getGameTime() % 4 == 0)ParticleAnimated("ConvertParticle.png", this.getPosition(), (this.getVelocity()/4*3)+Vec2f(XORRandom(3)-1,XORRandom(3)-1)*0.2, XORRandom(360), 1.0f, 3, -0.01, true);
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return (blob.getTeamNum() != this.getTeamNum() && blob.hasTag("player"));
}

// Sounds by TFlippy
void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if (blob !is null && blob.getTeamNum() != this.getTeamNum() && blob.hasTag("flesh") && blob.hasTag("player"))
	{
		if (getNet().isServer())
		{
			int Team = 9;
			blob.server_setTeamNum(Team);
			string name = blob.getName();
			string CapsName = toUpper(name.substr(0, 1))+name.substr(1, name.length()-1);
			ensureCorrectRunnerTexture(blob.getSprite(), name, CapsName);
			this.server_Die();
		}

		if (getNet().isClient())
		{
			this.getSprite().PlaySound("AOE1_Wololo.ogg", 1.00f, 1.00f);
		}
	}
	
	if (getNet().isServer())
	{
		if (solid) this.server_Die(); // Should happen on collision with anything solid, including doors
		// else if (blob !is null && blob.getName() == "stone_door" || blob.getName() == "wooden_door") this.server_Die();
	}
	
	// if(blob !is null && blob.getTeamNum() != this.getTeamNum() && blob.hasTag("flesh") && blob.hasTag("player"))
	// {
		// int Team = 2;
		// if(this.getTeamNum() > 1)Team = XORRandom(6)+2;
		// blob.server_setTeamNum(Team);
		// string name = blob.getName();
		// string CapsName = toUpper(name.substr(0, 1))+name.substr(1, name.length()-1);
		// ensureCorrectRunnerTexture(blob.getSprite(), name, CapsName);
		// this.server_Die();
	// }
	
	// if(solid)this.server_Die();
	// if(blob !is null)if(blob.getName() == "stone_door" || blob.getName() == "wooden_door")if(blob.getShape().getConsts().collidable)this.server_Die();
}

string toUpper(string char)
{
    if(char == "a")return "A";
	if(char == "b")return "B";
	if(char == "c")return "C";
	if(char == "d")return "D";
	if(char == "e")return "E";
	if(char == "f")return "F";
	if(char == "g")return "G";
	if(char == "h")return "H";
	if(char == "i")return "I";
	if(char == "j")return "J";
	if(char == "k")return "K";
	if(char == "l")return "L";
	if(char == "m")return "M";
	if(char == "n")return "N";
	if(char == "o")return "O";
	if(char == "p")return "P";
	if(char == "q")return "Q";
	if(char == "r")return "R";
	if(char == "s")return "S";
	if(char == "t")return "T";
	if(char == "u")return "U";
	if(char == "v")return "V";
	if(char == "w")return "W";
	if(char == "x")return "X";
	if(char == "y")return "Y";
	if(char == "z")return "Z";
    return char;
}