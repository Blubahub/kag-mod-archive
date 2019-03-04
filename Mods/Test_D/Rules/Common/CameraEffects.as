#define CLIENT_ONLY

//////////////////////////////////////////////
// set shader vars
//////////////////////////////////////////////

f32 _drunk = 0.0f;
const f32 _drunk_slide_amount_second = 0.5f;
const f32 _drunk_slide_amount = _drunk_slide_amount_second / 30.0f;

void onInit(CRules@ this)
{

}

f32 slide(f32 from, f32 towards, f32 amount)
{
	if (from < towards)
		return Maths::Min(towards, from + amount);
	if (from > towards)
		return Maths::Max(towards, from - amount);
	return towards;
}

void onTick(CRules@ this)
{
	Driver@ driver = getDriver();

	f32 cam_x = getCamera().getPosition().x * getCamera().targetDistance;
	driver.SetShaderFloat("palette", "scroll_x", cam_x * 0.25f);

	driver.SetShaderFloat("drunk", "time", getGameTime() / 30.0f);
	driver.SetShaderFloat("drunk", "scroll_x", cam_x);

	CBlob@ localblob = getLocalPlayerBlob();
	if (localblob !is null && localblob.exists("drunk_amount"))
	{
		f32 amount = localblob.get_u8("drunk_amount");
		//far away - fast slide
		if (Maths::Abs(amount - _drunk) > 2.0f)
		{
			_drunk = (_drunk + amount) * 0.5f;
		}
		else
		{
			_drunk = slide(_drunk, amount, _drunk_slide_amount);
		}
		driver.SetShaderFloat("drunk", "amount", _drunk);
	}
}
