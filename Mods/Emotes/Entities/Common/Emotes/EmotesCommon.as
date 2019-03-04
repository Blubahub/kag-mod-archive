//handy dandy frame lookup
namespace Emotes
{
	enum Emote_Indices
	{
		skull = 0,  //0
		blueflag,	//1
		note,		//2
		right,		//3
		smile,		//4
		redflag,	//5
		flex,		//6
		down,		//7
		frown,		//8
		troll,		//9
		finger,		//10
		left,		//11
		mad,		//12
		archer,		//13
		sweat,		//14
		up,			//15
		laugh,		//16
		knight,		//17
		question,	//18
		thumbsup,	//19
		wat,		//20
		builder,	//21
		disappoint,	//22
		thumbsdown,	//23
		derp,		//24
		ladder,		//25
		attn,		//26
		pickup,		//27
		cry,		//28
		wall,		//29
		heart,		//30
		fire,		//31
		check,		//32
		cross,		//33
		dots,		//34
		cog,		//35

		emotes_total,
		off
	};
}

void set_emote(CBlob@ this, u8 emote, int time)
{
	if (emote >= Emotes::emotes_total)
	{
		emote = Emotes::off;
	}

	this.set_u8("emote", emote);
	this.set_u32("emotetime", getGameTime() + time);
	bool client = this.getPlayer() !is null;
	this.Sync("emote", !client);
	this.Sync("emotetime", !client);
}

void set_emote(CBlob@ this, u8 emote)
{
	set_emote(this, emote, 90);
}

bool is_emote(CBlob@ this, u8 emote = 255, bool checkBlank = false)
{
	u8 index = emote;
	if (index == 255)
		index = this.get_u8("emote");

	u32 time = this.get_u32("emotetime");

	return time > getGameTime() && index != Emotes::off && (!checkBlank || (index != Emotes::dots));
}

