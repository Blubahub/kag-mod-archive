//default actor hud
// a bar with hearts in the bottom left, bottom right free for actor specific stuff

#include "ActorHUDStartPos.as";


void renderBackBar(CBlob@ blob, Vec2f origin, f32 width, f32 scale)
{
	f32 hp = blob.getHealth();
	if(blob.getInitialHealth() > hp)hp = blob.getInitialHealth();
	for (f32 step = 0.0f; step < (width / scale - 64)+(hp-2)*64.0f*scale; step += 64.0f * scale)
	{
		GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 1, Vec2f(64, 32), origin + Vec2f(step * scale, 0), scale);
	}

	GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 1, Vec2f(64, 32), origin + Vec2f(width - 128 * scale, 0), scale);
}

void renderBackStone(CBlob@ blob, Vec2f origin)
{
	int segmentWidth = 32;
	GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 0, Vec2f(16, 32), origin + Vec2f(-segmentWidth, 0));
	
	int Slot = 0;
	
	for (uint elem = 0; elem < 2; elem += 1)
	{

		if(elem == 0)
		if(blob.get_s16("power") != 100 || blob.hasTag("holy")){
			GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 2, Vec2f(16, 32), origin + Vec2f(segmentWidth * Slot, 0));
			
			Vec2f textpos = Vec2f(4, 24);
			if(blob.get_s16("power") > 99)textpos = Vec2f(0, 24);
			if(blob.get_s16("power") > 999)textpos = Vec2f(-8, 24);
			GUI::DrawIcon("MaterialIcons.png", 2, Vec2f(16, 16), origin + Vec2f(segmentWidth * Slot, 10), 1.0f);
			SColor col = SColor(255, 255, 255, 255);
			GUI::SetFont("menu");
			GUI::DrawText("" + blob.get_s16("power") + "%", origin + Vec2f(segmentWidth * Slot, 10) + textpos, col);
			
			Slot += 1;
		}
		
		if(elem == 1)
		if(blob.get_s16("corruption") > 0 || blob.hasTag("evil")){
			GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 2, Vec2f(16, 32), origin + Vec2f(segmentWidth * Slot, 0));
			
			Vec2f textpos = Vec2f(8, 24);
			if(blob.get_s16("corruption") > 99)textpos = Vec2f(4, 24);
			if(blob.get_s16("corruption") > 999)textpos = Vec2f(-4, 24);
			GUI::DrawIcon("Soul.png", 0, Vec2f(16, 16), origin + Vec2f(segmentWidth * Slot, 10), 1.0f);
			SColor col = SColor(255, 255, 255, 255);
			GUI::SetFont("menu");
			GUI::DrawText("" + blob.get_s16("corruption"), origin + Vec2f(segmentWidth * Slot, 10) + textpos, col);
			
			Slot += 1;
		}
		
	}
	
	GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 3, Vec2f(16, 32), origin + Vec2f(32 * Slot, 0));

	
}


void renderFrontStone(CBlob@ blob, Vec2f farside, f32 width, f32 scale)
{
	f32 hp = blob.getHealth();
	if(blob.getInitialHealth() > hp)hp = blob.getInitialHealth();
	for (f32 step = 0.0f; step < width / scale - 16.0f * scale * 2; step += 16.0f * scale * 2)
	{
		GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 2, Vec2f(16, 32), farside + Vec2f(-step * scale - 32 * scale+(hp-2)*64.0f*scale, 0), scale);
	}

	if (width > 16)
	{
		GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 2, Vec2f(16, 32), farside + Vec2f(-width+(hp-2)*64.0f*scale, 0), scale);
	}
	
	GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 0, Vec2f(16, 32), farside + Vec2f(-width - 32 * scale+(hp-2)*64.0f*scale, 0), scale);
	GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 3, Vec2f(16, 32), farside + Vec2f((hp-2)*64.0f*scale, 0), scale);
}

void renderHPBar(CBlob@ blob, Vec2f origin)
{
	string heartFile = "GUI/HeartNBubble.png";
	int segmentWidth = 32;
	GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 0, Vec2f(16, 32), origin + Vec2f(-segmentWidth, 0));
	int HPs = 0;
	
	for (f32 step = 0.0f; step < blob.getInitialHealth() || step < blob.getHealth(); step += 0.5f)
	{
		GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 1, Vec2f(16, 32), origin + Vec2f(segmentWidth * HPs, 0));
		f32 thisHP = blob.getHealth() - step;

		if (thisHP > 0)
		{
			Vec2f heartoffset = (Vec2f(2, 10) * 2);
			Vec2f heartpos = origin + Vec2f(segmentWidth * HPs, 0) + heartoffset;

			if (thisHP <= 0.125f)
			{
				GUI::DrawIcon(heartFile, 4, Vec2f(12, 12), heartpos);
			}
			else if (thisHP <= 0.25f)
			{
				GUI::DrawIcon(heartFile, 3, Vec2f(12, 12), heartpos);
			}
			else if (thisHP <= 0.375f)
			{
				GUI::DrawIcon(heartFile, 2, Vec2f(12, 12), heartpos);
			}
			else
			{
				GUI::DrawIcon(heartFile, 1, Vec2f(12, 12), heartpos);
			}
		}

		HPs++;
	}

	GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 3, Vec2f(16, 32), origin + Vec2f(32 * HPs, 0));
}

void onInit(CSprite@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getCurrentScript().removeIfTag = "dead";
}

void onRender(CSprite@ this)
{
	if (g_videorecording)
		return;

	CBlob@ blob = this.getBlob();
	Vec2f dim = Vec2f(362, 64);
	Vec2f ul(HUD_X - dim.x / 2.0f, HUD_Y - dim.y + 12);
	Vec2f lr(ul.x + dim.x, ul.y + dim.y);
	//GUI::DrawPane(ul, lr);
	
	renderBackStone(blob, ul + Vec2f(20, -44));
	renderBackBar(blob, ul, dim.x, 1.0f);
	u8 bar_width_in_slots = blob.get_u8("gui_HUD_slots_width");
	f32 width = bar_width_in_slots * 32.0f;
	renderFrontStone(blob, ul + Vec2f(dim.x + 32, 0), width, 1.0f);
	renderHPBar(blob, ul);
	//GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 0, Vec2f(128,32), topLeft);
}
