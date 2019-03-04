// Tent logic

#include "StandardRespawnCommand.as"

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-50.0f);
	this.getCurrentScript().tickFrequency = 30;
	this.set_u8("Attack", 0);
  this.Sync("Attack",true);
  
  this.set_u32("Win0", 0);
  this.Sync("Win0",true);
  
  this.set_u32("Win1", 0);
  this.Sync("Win1",true);
	// minimap
	this.SetMinimapOutsideBehaviour(CBlob::minimap_snap);
	this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 1, Vec2f(8, 8));
	this.SetMinimapRenderAlways(true);
}

void onRender(CSprite@ this)
{

	CBlob@ blob = this.getBlob();
	Vec2f pos2d = blob.getScreenPos() - Vec2f(40.0f,5.0f);
		//VV right here VV
	if (blob.get_u8("Attack") > 0)
  {
      //print("hi");
		GUI::DrawProgressBar(pos2d , Vec2f(pos2d.x + 80, pos2d.y + 10),float( blob.get_u8("Attack"))/5.0f);
	}
	pos2d.y -= 20.0f;
	pos2d.x -= 20.0f;
  GUI::DrawSunkenPane(pos2d , Vec2f(pos2d.x + 60, pos2d.y + 10));
  GUI::DrawSunkenPane(Vec2f(pos2d.x + 60, pos2d.y ) , Vec2f(pos2d.x + 120, pos2d.y + 10));
  
  if(blob.get_u32("Win0") > 0)
    GUI::DrawPane(pos2d , Vec2f(((float(blob.get_u32("Win0"))/180)*60) +pos2d.x, pos2d.y + 10), SColor(255, 60, 60, 255));
  
  if(blob.get_u32("Win1") > 0)
    GUI::DrawPane(Vec2f((120 -((float(blob.get_u32("Win1"))/180)*60)) +pos2d.x, pos2d.y ) , Vec2f(pos2d.x + 120, pos2d.y + 10), SColor(255, 255, 60, 60));
  GUI::DrawTextCentered("Win" , Vec2f(pos2d.x + 60, pos2d.y + 10), SColor(255, 255, 255, 255));
}

void onTick(CBlob@ this)
{
	DetectOn(this);
}

void DetectOn(CBlob@ this)
{
		Vec2f tl, br;
		this.getShape().getBoundingRect(tl, br);
		CBlob@[] blobs;
		this.getMap().getBlobsInBox(tl, br, @blobs);
		u8 team = this.getTeamNum();
		u8 friends = 0;
		u8 foes = 0;
		for (uint i = 0; i < blobs.length; i++)
		{
			CBlob@ blob = blobs[i];
			if(blob.hasTag("player")) 
			{
				if(team == 255)
				{
					team = blob.getTeamNum();
					this.server_setTeamNum(team);
				
				}
				if(blob.getTeamNum() == team)
				{
					friends += 1;
				}
				else
				foes += 1;
			
			}
		}
		if(foes > 0)
		{
			this.Tag("under attack");
		}
		else
		this.Untag("under attack");
  
    if(this.get_u8("Attack") == 5)
		{
			this.server_setTeamNum(this.getTeamNum() == 0 ? 1 : 0);
			this.set_u8("Attack", 0);
		}
		
		if(foes > 0 && friends == 0) 
		{
			this.set_u8("Attack", this.get_u8("Attack") + 1);
		}
		else
		{
			this.set_u8("Attack", 0);
		}
    
    if(!this.hasTag("under attack") && team != 255) 
    {
      this.set_u32("Win" + team, this.get_u32("Win" + team) + 1);
    }
		
		
	
}
