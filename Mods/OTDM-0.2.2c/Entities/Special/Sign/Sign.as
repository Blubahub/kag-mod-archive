// Sign logic

namespace Sign
{
	enum State
	{
		blank = 0,
		written
	}
}

void onInit(CBlob@ this)
{
	//setup blank state
	this.set_u8("state", Sign::blank);

	if (!this.exists("text")) this.set_string("text", "");//will probably be "" already

	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getSprite().SetZ(-500.0f);

	this.addCommandID("update sprite");
	this.SendCommand(this.getCommandID("update sprite"));

	AddIconToken("$write$", "InteractionIcons.png", Vec2f(32, 32), 15);
	this.addCommandID("write");

	AddIconToken("$cancel$", "InteractionIcons.png", Vec2f(32, 32), 9);
	this.addCommandID("cancel");
}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;

	if (getHUD().menuState != 0) return;

	CBlob@ localBlob = getLocalPlayerBlob();
	Vec2f pos2d = blob.getScreenPos();

	if (localBlob is null) return;

	if (
	    ((localBlob.getPosition() - blob.getPosition()).Length() < 0.5f * (localBlob.getRadius() + blob.getRadius())) &&
	    (!getHUD().hasButtons()))
	{
		// draw drop time progress bar
		int top = pos2d.y - 2.5f * blob.getHeight() + 000.0f;
		int left = 200.0f;
		int margin = 4;
		Vec2f dim;
		string label = blob.get_string("text");

		string nick;
		if (getPlayerByUsername(blob.get_string("owner")) !is null)
			nick = getPlayerByUsername(blob.get_string("owner")).getCharacterName();
		else
			nick = "[player left]";
		label += "\n by " + nick + " (" + blob.get_string("owner") + ")";
		GUI::SetFont("menu");		
		GUI::GetTextDimensions(label , dim);
		dim.x = Maths::Min(dim.x, 200.0f);
		dim.x += margin;
		dim.y += margin;
		dim.y *= 1.0f;
		top += dim.y;
		Vec2f upperleft(pos2d.x - dim.x / 2 - left, top - Maths::Min(int(2 * dim.y), 250));
		Vec2f lowerright(pos2d.x + dim.x / 2 - left, top - dim.y);
		GUI::DrawText(label, Vec2f(upperleft.x + margin, upperleft.y + margin + margin),
		              Vec2f(upperleft.x + margin + dim.x, upperleft.y + margin + dim.y),
		              SColor(255, 0, 0, 0), false, false, true);
	}
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CPlayer@ player = caller.getPlayer();
	if (player is null)
		return;
	if (player.getUsername() != this.get_string("owner"))
		return;

	if (caller is null)
		return;

	if (caller.exists("sign writing on") && caller.get_u16("sign writing on") == this.getNetworkID())//already writing?
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		caller.CreateGenericButton("$cancel$", Vec2f(0, 0), this, this.getCommandID("cancel"), "Cancel writing", params);
	}
	else
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		caller.CreateGenericButton("$write$", Vec2f(0, 0), this, this.getCommandID("write"), "Write on", params);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	bool isServer = (getNet().isServer());

	if (cmd == this.getCommandID("write"))
	{
		u16 caller_id;
		if (!params.saferead_netid(caller_id))
			return;

		CBlob@ caller = getBlobByNetworkID(caller_id);

		if (caller !is null)
		{
			caller.set_u16("sign writing on", this.getNetworkID());//will be looked for in chatcommands.as
			if (caller.isMyPlayer())
				client_AddToChat("Type new sign message:");
		}
	}
	else if (cmd == this.getCommandID("cancel"))
	{
		u16 caller_id;
		if (!params.saferead_netid(caller_id))
			return;

		CBlob@ caller = getBlobByNetworkID(caller_id);

		if (caller !is null)
			caller.set_u16("sign writing on", 0);
	}
	else if (cmd == this.getCommandID("update sprite"))
	{
		CSprite@ sprite = this.getSprite();
		if (sprite !is null)
		{
			string text = this.get_string("text");
			bool empty = true;
			for (int i=0;i<text.length;i++)
			{
				if (text.substr(i, 1) != " ")
					empty = false;
			}

			print("empty:" + empty + "|" + sprite.isAnimation("destruction"));

			if (empty)
			{
				if (sprite.isAnimation("destruction"))
				{
					sprite.SetAnimation("destruction_blank");
					sprite.animation.SetFrameIndex(1);
				}
				else if (sprite.isAnimation("written"))
					sprite.SetAnimation("blank");
			}
			else
			{
				if (sprite.isAnimation("destruction_blank"))
				{
					sprite.SetAnimation("destruction");
					sprite.animation.SetFrameIndex(1);
				}
				else if (sprite.isAnimation("blank"))
					sprite.SetAnimation("written");
			}
		}
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (hitterBlob !is this && this.hasTag("invincible"))
	{
		return 0.0f;
	}

	// could be this.getHealth() -= damage; but we need to modify this value by Rules::attackdamage_modifier
	// to help with this we call this helper function, which also sets the hitter
	this.Damage(damage, hitterBlob);
	// set the destruction frames if available
	CSprite @sprite = this.getSprite();

	if (sprite !is null)
	{
		Animation @destruction_anim;
		if (sprite.isAnimation("blank") || sprite.isAnimation("destruction_blank"))
			@destruction_anim = sprite.getAnimation("destruction_blank");
		else if (sprite.isAnimation("written") || sprite.isAnimation("destruction"))
			@destruction_anim = sprite.getAnimation("destruction");
		

		if (destruction_anim !is null)
		{
			if (this.getHealth() < this.getInitialHealth())
			{
				sprite.SetAnimation(destruction_anim);
				f32 ratio = this.getHealth() / this.getInitialHealth();

				if (ratio <= 0.0f)
				{
					sprite.animation.frame = sprite.animation.getFramesCount() - 1;
				}
				else
				{
					sprite.animation.frame = (1.0f - ratio) * (sprite.animation.getFramesCount());
				}
			}
		}
	}

	if (this.getHealth() <= 0.0f)
	{
		this.server_Die();
	}

	return 0.0f;
}

void onDie(CBlob@ this)
{
	// Gib if health below 0.0f
	if (this.getSprite() !is null && this.getHealth() <= 0.0f)
	{
		this.getSprite().Gib();
	}
}