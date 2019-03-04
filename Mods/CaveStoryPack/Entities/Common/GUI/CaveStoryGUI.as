//Replaces ActorHUDStartPos (and adds some things of it's own)

const f32 HUD_X = 430.0f;
const f32 HUD_Y = getScreenHeight();


Vec2f getActorHUDStartPosition(CBlob@ blob, const u8 bar_width_in_slots)
{
	f32 width = bar_width_in_slots * 32.0f;
	return Vec2f(HUD_X + 160 + 50 - width, HUD_Y - 40);
}

void DrawInventoryOnHUD(CBlob@ this, Vec2f tl)
{
	SColor col;
	CInventory@ inv = this.getInventory();
	string[] drawn;
	for (int i = 0; i < inv.getItemsCount(); i++)
	{
		CBlob@ item = inv.getItem(i);
		const string name = item.getName();
		if (drawn.find(name) == -1)
		{
			const int quantity = this.getBlobCount(name);
			drawn.push_back(name);

			GUI::DrawIcon(item.inventoryIconName, item.inventoryIconFrame, item.inventoryFrameDimension, tl + Vec2f(2 + (drawn.length - 1) * 64, -6), 1.0f);

			f32 ratio = float(quantity) / float(item.maxQuantity);
			col = ratio > 0.4f ? SColor(255, 255, 255, 255) :
			      ratio > 0.2f ? SColor(255, 255, 255, 128) :
			      ratio > 0.1f ? SColor(255, 255, 128, 0) : SColor(255, 255, 0, 0);

			CaveStoryGUI::DrawNumber(quantity, tl + Vec2f(45 + (drawn.length - 1) * 64, 40), true, ratio < 0.2f);
			//GUI::DrawText("" + quantity, tl + Vec2f(8 + (drawn.length - 1) * 32 , 24), col);
		}
	}
}

void DrawCoinsOnHUD(CBlob@ this, const int coins, Vec2f tl, const int slot)
{
	if (coins > 0)
	{
		GUI::DrawIconByName("$COIN$", tl + Vec2f(0 + slot * 32, 0));
		GUI::DrawText("" + coins, tl + Vec2f(8 + slot * 32 , 24), color_white);
	}
}

namespace CaveStoryGUI
{
	void DrawNumber(float number, Vec2f position)
	{
		CaveStoryGUI::DrawNumber(number, position, false, false);
	}

	void DrawNumber(float number, Vec2f position, bool small, bool red)
	{
		int numDigits = int(Maths::Log(number) / Maths::Log(10));
		Vec2f currentDigitPosition;

		//Choose the right texture
		string numbers = small?"Entities/Common/GUI/CaveStoryNumbersSmall.png":"Entities/Common/GUI/CaveStoryNumbers.png";

		int sizeFactor = small?1:2;
		int redAddend = red?10:0;//red numbers are directly after the normal ones (one row below)
		for (int i=numDigits;i>=0;i--)
		{
			//This stuff is pretty hard to understand. If you can, treat it as a black box
			currentDigitPosition = position + Vec2f(-16 * sizeFactor - 16  * sizeFactor *  i, 0);
			GUI::DrawIcon(numbers, 
				(number % Maths::Pow(10, i+1) - 
					number % Maths::Pow(10, i)) 
				/ Maths::Pow(10, i) + redAddend, 
				Vec2f(8 * sizeFactor, 8 * sizeFactor), currentDigitPosition);
		}
	}
}