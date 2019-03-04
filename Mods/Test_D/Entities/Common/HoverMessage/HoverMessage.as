shared class HoverMessage
{
	int index;
	int quantity;
	string name;
	uint ticker;
	Vec2f pos;
	uint ttl;
	uint fade_ratio;
	SColor color;

	HoverMessage() {} // required for handles to work

	HoverMessage(string _name, Vec2f position, int _quantity = 0, SColor _color = color_white, bool singularise = false, uint _ttl = 75, uint _fade_ratio = 2)
	{
		if (_quantity >= 0 && _quantity < 2 && singularise)
		{
			_name = this.Singularize(_name);
		}

		name = _name;
		quantity = _quantity;
		ticker = 0;
		ttl = _ttl;
		fade_ratio = _fade_ratio;
		color = _color;

		pos = position;
	}

	// draw the text
	void Draw(CBlob@ blob)
	{
		string m = this.Message();
		UpdatePos(blob, m);

		Vec2f drawpos = getDriver().getScreenPosFromWorldPos(pos);

		f32 lineheight = 10.0f;

		int top = drawpos.y - index * lineheight;
		int margin = 4;
		Vec2f dim;
		GUI::GetTextDimensions(m , dim);
		dim.x = Maths::Min(dim.x, 200.0f);

		drawpos.x = drawpos.x - dim.x / 2;
		drawpos.y = top - int(1.5f * lineheight);

		Vec2f recttl = drawpos + Vec2f(-margin,margin);
		Vec2f rectbr = recttl + Vec2f(dim.x + margin * 2, lineheight);

		drawpos.x -= margin/2;
		drawpos.y += margin/2;

		//only long time messages have background
		if(ttl > 150)
		{
			SColor rcol = SColor(getColor().color & 0xff000000);
			rcol.setAlpha(rcol.getAlpha() * 0.5f);

			GUI::DrawRectangle(recttl, rectbr, rcol);
		}

		GUI::DrawText(m, drawpos, getColor());
	}

	// get message into a nice, friendly format
	string Message()
	{
		if (quantity == 0)
		{
			return name;
		}
		return "+" + quantity + " " + name;
	}

	// see if this message is expired, or should be removed from GUI
	bool isExpired()
	{
		ticker = ticker + 1;
		return ticker > ttl;
	}

	f32 expireStart()
	{
		return ttl * 0.5f;
	}

	// get the active color of the message. decrease proportionally by the fadeout ratio
	private SColor getColor()
	{
		uint alpha = ticker > expireStart() ? Maths::Max(0, 255 - ((ticker - expireStart() * 0.5f) * fade_ratio)) : 255;
		SColor color2 = SColor(alpha, color.getRed(), color.getGreen(), color.getBlue());
		return color2;
	}

	// slowly make it rise by decreasing by a multiple of the ticker
	private void UpdatePos(CBlob@ blob, string m)
	{
		if (ticker > expireStart())
		{
			pos.y = pos.y - ((ticker - expireStart()) / (ttl * 0.66f));
		}
	}

	// Singularize, or de-pluralize, a string
	private string Singularize(string str)
	{
		uint len = str.length();
		string lastChar = str.substr(len - 1);

		if (lastChar == "s")
		{
			str = str.substr(0, len - 1);
		}

		return str;
	}
};

HoverMessage[]@ getMessages(CBlob@ this)
{
	if (!this.exists("messages"))
	{
		HoverMessage[] messages;
		this.set("messages", messages);
	}
	HoverMessage[]@ p_messages;
	this.get("messages", @p_messages);
	return p_messages;
}

bool isSameMessageAlready(HoverMessage[]@ messages, const string &in label)
{
	for (uint i = 0; i < messages.length; i++)
	{
		HoverMessage @message = messages[i];
		if (message.name == label && message.ticker < message.ttl / 2.0f)
			return true;
	}
	return false;
}

void AddMessage(CBlob@ this, const string &in label, const int quantity = 0, const int time = 75, Vec2f offset_this = Vec2f_zero)
{
	if (this is null)
		return;
	HoverMessage[]@ messages = getMessages(this);
	if (!isSameMessageAlready(messages, label))
	{
		Vec2f offset(0, -8);
		if (this.exists("hover message offset")){
			offset = this.get_Vec2f("hover message offset");
		}
		HoverMessage m(label, this.getPosition() + offset + offset_this, quantity, color_white, false, time);
		m.index = messages.length;
		messages.push_back(m);
	}
}

void AddMessageTimed(CBlob@ this, const string &in label, const int time = 75)
{
	AddMessage(this, label, 0, time);
}

void AddMessageAbove(CBlob@ this, const string &in label)
{
	AddMessage(this, label, 0, 75, Vec2f(0.0f, -16));
}

void ClearMessages(CBlob@ this)
{
	if (this is null)
		return;

	HoverMessage[]@ msg = getMessages(this);
	if (msg !is null)
		msg.clear();
}

void AddScore(CBlob@ this, const int quantity)
{
	if (this is null)
		return;
	HoverMessage[]@ messages = getMessages(this);
	HoverMessage m("", this.getPosition(), quantity);
	messages.push_back(m);
	messages[messages.length - 1].index = messages.length - 1;
}
