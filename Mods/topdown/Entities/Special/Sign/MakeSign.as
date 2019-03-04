CBlob@ createSign(Vec2f position, const string &in text, const string &in owner)
{
	CBlob@ sign = server_CreateBlobNoInit("sign");
	if (sign !is null)
	{
		sign.setPosition(position);
		sign.set_string("text", text);
		sign.set_string("owner", owner);
		sign.Init();
		// no floaty signs
		// sign.getShape().SetStatic(true);
	}
	return sign;
}