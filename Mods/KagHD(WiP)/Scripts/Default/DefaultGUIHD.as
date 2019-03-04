// DefaultGUI.as

void LoadDefaultGUI()
{
	if (v_driver > 0)
	{
		// add color tokens
		AddColorToken("$RED$", SColor(255, 105, 25, 5));
		AddColorToken("$GREEN$", SColor(255, 5, 105, 25));
		AddColorToken("$GREY$", SColor(255, 195, 195, 195));

		// add default icon tokens
		AddIconToken("$NONE$", "GUI/InteractionIcons.png", Vec2f(64, 64), 9);
		AddIconToken("$TIME$", "GUI/InteractionIcons.png", Vec2f(64, 64), 0);
		AddIconToken("$COIN$", "GUI/MaterialIconsHD.png", Vec2f(32, 32), 5);
		AddIconToken("$GOLD$", "GUI/MaterialIconsHD.png", Vec2f(32, 32), 2);
		AddIconToken("$TEAMS$", "GUI/MenuItems.png", Vec2f(32, 32), 1);
		AddIconToken("$SPECTATOR$", "GUI/MenuItems.png", Vec2f(32, 32), 19);
		AddIconToken("$FLAG$", CFileMatcher("flag.png").getFirst(), Vec2f(64, 16), 0);
		AddIconToken("$DISABLED$", "GUI/InteractionIcons.png", Vec2f(64, 64), 9, 1);
		AddIconToken("$CANCEL$", "GUI/MenuItems.png", Vec2f(32, 32), 29);
		AddIconToken("$RESEARCH$", "GUI/InteractionIcons.png", Vec2f(64, 64), 27);
		AddIconToken("$ALERT$", "GUI/InteractionIcons.png", Vec2f(64, 64), 10);
		AddIconToken("$down_arrow$", "GUI/ArrowDown.png", Vec2f(16, 16), 0);
		AddIconToken("$ATTACK_LEFT$", "GUI/InteractionIcons.png", Vec2f(64, 64), 18, 1);
		AddIconToken("$ATTACK_RIGHT$", "GUI/InteractionIcons.png", Vec2f(64, 64), 17, 1);
		AddIconToken("$ATTACK_THIS$", "GUI/InteractionIcons.png", Vec2f(64, 64), 19, 1);
		AddIconToken("$DEFEND_LEFT$", "GUI/InteractionIcons.png", Vec2f(64, 64), 18, 2);
		AddIconToken("$DEFEND_RIGHT$", "GUI/InteractionIcons.png", Vec2f(64, 64), 17, 2);
		AddIconToken("$DEFEND_THIS$", "GUI/InteractionIcons.png", Vec2f(64, 64), 19, 2);
		AddIconToken("$CLASSCHANGE$", "Rules/Tutorials/TutorialImages.png", Vec2f(64, 64), 7);
		AddIconToken("$BUILD$", "GUI/InteractionIcons.png", Vec2f(64, 64), 15);
		AddIconToken("$STONE$", "Sprites/World.png", Vec2f(16, 16), 48);
		AddIconToken("$!!!$", "/Emoticons.png", Vec2f(22, 22), 48);

		// classes
		AddIconToken("$ARCHER$",        "ClassIcons.png",       Vec2f(16, 16), 2);
		AddIconToken("$KNIGHT$",        "ClassIcons.png",       Vec2f(16, 16), 1);
		AddIconToken("$BUILDER$",       "ClassIcons.png",       Vec2f(16, 16), 0);

		// blocks
		AddIconToken("$stone_block$", "Sprites/World.png", Vec2f(16, 16), CMap::tile_castle);
		AddIconToken("$back_stone_block$", "Sprites/World.png", Vec2f(16, 16), CMap::tile_castle_back);
		AddIconToken("$wood_block$", "Sprites/World.png", Vec2f(16, 16), CMap::tile_wood);
		AddIconToken("$back_wood_block$", "Sprites/World.png", Vec2f(16, 16), CMap::tile_wood_back);

		// SOURCE
		AddIconToken("$coin_slot2$",     "CoinSlot2.png",         Vec2f(16, 16), 18);
		AddIconToken("$lever2$",         "Lever2.png",            Vec2f(16, 16), 8);
		AddIconToken("$pressureplate2$", "PressurePlate2.png",    Vec2f(16, 16), 2);
		AddIconToken("$pushbutton2$",    "PushButton2.png",       Vec2f(16, 16), 1);
		AddIconToken("$sensor2$",    	 "Sensor2.png",           Vec2f(16, 16), 0);

		// PASSIVE
		AddIconToken("$diode2$",         "Diode2.png",            Vec2f(16, 16), 11);
		AddIconToken("$elbow2$",         "Elbow2.png",            Vec2f(16, 16), 32);
		AddIconToken("$junction2$",      "Junction2.png",         Vec2f(16, 16), 16);
		AddIconToken("$inverter2$",      "Inverter2.png",         Vec2f(16, 16), 12);
		AddIconToken("$oscillator2$",    "Oscillator2.png",       Vec2f(16, 16), 19);
		AddIconToken("$magazine2$",      "Magazine2.png",         Vec2f(16, 16), 0);
		AddIconToken("$randomizer2$",    "Randomizer2.png",       Vec2f(16, 16), 24);
		AddIconToken("$resistor2$",      "Resistor2.png",         Vec2f(16, 16), 12);
		AddIconToken("$tee2$",           "Tee2.png",              Vec2f(16, 16), 16);
		AddIconToken("$toggle2$",        "Toggle2.png",           Vec2f(16, 16), 12);
		AddIconToken("$transistor2$",    "Transistor2.png",       Vec2f(16, 16), 24);
		AddIconToken("$wire2$",          "Wire2.png",             Vec2f(16, 16), 6);
		AddIconToken("$emitter2$",       "Emitter2.png",          Vec2f(16, 16), 20);
		AddIconToken("$receiver2$",      "Receiver2.png",         Vec2f(16, 16), 20);

		// LOAD
		AddIconToken("$bolter2$",        "Bolter2.png",           Vec2f(16, 16), 0);
		AddIconToken("$dispenser2$",     "Dispenser2.png",        Vec2f(16, 16), 0);
		AddIconToken("$lamp2$",          "Lamp2.png",             Vec2f(16, 16), 0);
		AddIconToken("$obstructor2$",    "Obstructor2.png",       Vec2f(16, 16), 0);
		AddIconToken("$spiker2$",        "Spiker2.png",           Vec2f(16, 16), 3);

		// techs
		AddIconToken("$tech_stone$", "GUI/TechnologyIcons.png", Vec2f(32, 32), 16);

		// keys
		const Vec2f keyIconSize(32, 32);
		AddIconToken("$KEY_W$", "GUI/Keys.png", keyIconSize, 6);
		AddIconToken("$KEY_A$", "GUI/Keys.png", keyIconSize, 0);
		AddIconToken("$KEY_S$", "GUI/Keys.png", keyIconSize, 1);
		AddIconToken("$KEY_D$", "GUI/Keys.png", keyIconSize, 2);
		AddIconToken("$KEY_E$", "GUI/Keys.png", keyIconSize, 3);
		AddIconToken("$KEY_F$", "GUI/Keys.png", keyIconSize, 4);
		AddIconToken("$KEY_C$", "GUI/Keys.png", keyIconSize, 5);
		AddIconToken("$KEY_M$", "GUI/Keys.png", keyIconSize, 10);
		AddIconToken("$KEY_Q$", "GUI/Keys.png", keyIconSize, 7);
		AddIconToken("$LMB$", "GUI/Keys.png", keyIconSize, 8);
		AddIconToken("$RMB$", "GUI/Keys.png", keyIconSize, 9);
		AddIconToken("$KEY_SPACE$", "GUI/Keys.png", Vec2f(24, 16), 8);
		AddIconToken("$KEY_HOLD$", "GUI/Keys.png", Vec2f(24, 16), 9);
		AddIconToken("$KEY_TAP$", "GUI/Keys.png", Vec2f(24, 16), 10);
		AddIconToken("$KEY_F1$", "GUI/Keys.png", Vec2f(24, 16), 12);
		AddIconToken("$KEY_ESC$", "GUI/Keys.png", Vec2f(24, 16), 13);
		AddIconToken("$KEY_ENTER$", "GUI/Keys.png", Vec2f(24, 16), 14);

		// vehicles
		AddIconToken("$LoadAmmo$", "GUI/InteractionIcons.png", Vec2f(32, 32), 7, 7);
	}
}