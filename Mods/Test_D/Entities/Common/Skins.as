//shared skins header

enum Skin
{
	//DO NOT ADD ANYTHING "INTO" THIS ENUM EXCEPT AT THE END
	//EXISTING SKINS NEED TO USE THIS TO MAP CORRECTLY

	SKIN_NONE,
	SKIN_SUPER_RED,
	SKIN_HAT,
	SKIN_UNIFORM,
	SKIN_FANCYSUIT,
	SKIN_FANCYDRESS,
	SKIN_BOUNTY_HUNTER_FEM,

	SKIN_ASSAULT,
	SKIN_SNIPER,
	SKIN_MEDIC,
	SKIN_DEMOLITIONS,
	SKIN_COMMANDO,

	SKIN_HORSE_HEAD,
	SKIN_HORSE_BUTT,

	SKIN_RICH_BASTARD,

	//ADD NEW SKINS IN HERE
	SKIN_COUNT
}

//internal stuff, dont worry about it

namespace Skinternal
{
	class SkinDescription
	{
		string filename;
		string description;
		u32 cost;
		SkinDescription(string _filename, string _description, u32 _cost)
		{
			filename = _filename;
			description = _description;
			cost = _cost;
		}
	};

	SkinDescription[] skins = {
		SkinDescription("default",							"Remove Costume",			0),
		SkinDescription("actor_civ_superhero.png", 			"Super Suit",				15),
		SkinDescription("hat", 								"Cool Hat",					5),
		SkinDescription("actor_civ_ww1uni.png",				"Officer's Uniform",		25),
		SkinDescription("actor_civ_fancy_suit.png",			"Fancy Suit",				100),
		SkinDescription("actor_civ_fancy_dress.png",		"Fancy Dress",				100),
		SkinDescription("actor_civ_bountyhunter_fem.png",	"Bounty Hunter (Femme)",	20),

		SkinDescription("actor_civ_assault.png",			"Assault",					10),
		SkinDescription("actor_civ_sniper.png",				"Sniper",					10),
		SkinDescription("actor_civ_medic.png",				"Medic",					10),
		SkinDescription("actor_civ_engineer.png",			"Demolitions",				10),
		SkinDescription("actor_civ_commando.png",			"Commando",					10),

		SkinDescription("actor_civ_horse_head.png",			"Horse Head",				25),
		SkinDescription("actor_civ_horse_butt.png",			"Horse Butt",				10),

		SkinDescription("actor_civ_rich.png",				"'I Am Rich!' Suit",	500)
	};

	int skindex(int index)
	{
		if (index >= SKIN_COUNT)
			index = 0;
		return index;
	}
}

//actual interface

u32 getSkinCount()
{
	return SKIN_COUNT;
}

string getSkin(int index)
{
	index = Skinternal::skindex(index);
	return Skinternal::skins[index].filename;
}

string getSkinDescription(int index)
{
	index = Skinternal::skindex(index);
	return Skinternal::skins[index].description;
}

u32 getSkinCost(int index)
{
	index = Skinternal::skindex(index);
	return Skinternal::skins[index].cost;
}

void LoadSkin(CSprite@ this)
{
	CBlob@ b = this.getBlob();
	u8 index = 0;
	if(b.exists("skin"))
		index = b.get_u8("skin");

	int gender = 1;
	CPlayer@ p = b.getPlayer();
	if(p !is null)
	{
		gender = p.getSex();
	}

	string skin = getSkin(index);
	if(skin == "default")
	{
		skin = ((gender == 0) ? "actor_civ_mal.png" : "actor_civ_fem.png");
	}
	if(skin == "hat")
	{
		skin = ((gender == 0) ? "actor_civ_hat_mal.png" : "actor_civ_hat_fem.png");
	}

	this.ReloadSprite(skin);   // fixes engine bug (consts.filename = filename not set in ReloadSprite overload)
	this.ReloadSprite(skin, 24, 24, 0, 0);
}
