
namespace BombType
{
	enum type
	{
		normal = 0,
		mini_keg,
		sticky_bomb,
		water,
		count
	};
}

shared class BomberInfo
{
	u8 bomb_type;
	BomberInfo()
	{
		bomb_type = BombType::normal;
	}
};
const string[] bombTypeNames = {  "mat_bombs",
								  "mini_keg",
								  "mat_stickybombs",
								  "mat_waterbombs"
                                };
const string[] bombNames = { "Bomb",
                              "Mini Keg",
							  "Sticky Bomb",
							  "Water Bomb"
                            };

const string[] bombIcons = { "$BombIcon$",
							  "$MiniKegIcon$",
							  "$StickyBombIcon$",
							  "$WaterBombIcon$"
};
const string[] bombBlob = { "bomb",
							  "mini_keg",
							  "sticky_bomb",
							  "waterbomb"
};
const Vec2f btnSize = Vec2f(1,1);
const int maxY = 150;
const int fireBombPrice = 50;