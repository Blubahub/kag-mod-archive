string _portraits_file = "Sprites/UI/radio_portraits.png";
Vec2f _portraitSize(48,48);

class RadioCharacter
{
	u8 frame;
	string name;
	f32 pitch;

	RadioCharacter(string _name, u16 _frame, f32 _pitch)
	{
		frame = _frame;
		name = _name;
		pitch = _pitch;
	}
};

//lookup of characters
array<RadioCharacter> characters =
{
	//assault
	RadioCharacter("Jack", 2, 0.85f),
	RadioCharacter("Shelly", 3, 1.3f),

	//sniper
	RadioCharacter("Ursula", 8, 1.2f),
	RadioCharacter("Pete", 7, 0.95f),

	//medic
	RadioCharacter("Tanya", 6, 1.1f),
	RadioCharacter("Harold", 5, 1.1f),

	//engineer
	RadioCharacter("Thomas", 10, 0.75f),
	RadioCharacter("Courtney", 11, 1.15f),

	//commando
	RadioCharacter("Sharon", 13, 1.4f),
	RadioCharacter("Charlie", 12, 0.9f)
};

//lookup index
array<array<u8>> chars_index =
{
	{0, 2, 4, 6, 8},
	{1, 3, 5, 7, 9}
};

RadioCharacter@ getCharacterFor(u8 teamnum, u8 classnum)
{
	if(teamnum >= chars_index.length)
		teamnum = 0;

	if(classnum >= 5)
		classnum = 0;

	return characters[chars_index[teamnum][classnum]];
}
