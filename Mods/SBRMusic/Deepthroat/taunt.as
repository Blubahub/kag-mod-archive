
const u8 COOLDOWN = 100;

void onTick(CBlob@ this)
{
	int timer = this.get_u8("taunt_timer");
	
	if (timer == 0)
	{
		bool pressed_V = this.isKeyPressed(key_taunts);
		
		if (pressed_V)
		{
			timer = COOLDOWN;
			CPlayer@ player = this.getPlayer();
			if (player !is null)
			{
				this.getSprite().PlaySound(this.get_string("deepthroatpath2"));
			}
		}
	}
	else
	{
		timer --;
	}
	
	
	this.set_u8("taunt_timer", timer);
}