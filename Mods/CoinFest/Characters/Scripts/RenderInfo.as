void onRender( CSprite@ this )
{
	CBlob@ blob = this.getBlob();
	if (blob is null)
	{
		return;
	}
	if (!blob.exists("pdamage"))
	{
		return;
	}
	CPlayer@ player = blob.getPlayer();
	if (player is null)
	{
		return;
	}

	GUI::SetFont("main");

	int coins = player.getCoins();
	string damage = formatFloat(blob.get_f32("pdamage"), "", 0, 0);
	Vec2f blobPos = blob.getInterpolatedScreenPos();
	Vec2f textPos(blobPos.x, blobPos.y + 35);
	Vec2f upperLeft(textPos.x - 15, textPos.y - 5);
	Vec2f lowerRight(textPos.x + 15, textPos.y + 5);

	Vec2f damageTextOffset;
	GUI::GetTextDimensions(damage, damageTextOffset);
	Vec2f damageIconPos(textPos.x + damageTextOffset.x / 2 + 12, textPos.y);

	GUI::DrawText(damage, upperLeft, lowerRight, SColor(255, 255, 255, 255), true, true);
	GUI::DrawIcon("Mods/CoinFest/Characters/Scripts/dmg.png", damageIconPos);

	upperLeft = upperLeft + Vec2f(0, 15);
	lowerRight = lowerRight + Vec2f(0, 15);

	Vec2f coinTextOffset;
	GUI::GetTextDimensions("" + coins, coinTextOffset);
	Vec2f coinIconPos(textPos.x + coinTextOffset.x / 2 + 12, textPos.y + 15);

	GUI::DrawText("" + coins, upperLeft, lowerRight, SColor(255, 255, 255, 255), true, true);
	GUI::DrawIcon("Mods/CoinFest/FloorCoin/floorcoin.png", coinIconPos);

	//print("" + blob.get_f32("pdamage"));
}