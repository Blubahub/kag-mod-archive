#define CLIENT_ONLY

void onInit(CRules@ this)
{
	//forge
	AddIconToken( "$mat_coal$", "NewmtIcons.png", Vec2f(16,16), 2 );
	AddIconToken( "$Mat_coal$", "NewmtIcons.png", Vec2f(16,16), 2 );
	
	//trader shop
	AddIconToken( "$SoulStone$", "SoulStone.png", Vec2f(16,16), 0 );
	AddIconToken( "$MediumSoulStone$", "MediumSoulStone.png", Vec2f(16,16), 0 );
	AddIconToken( "$WeakSoulStone$", "WeakSoulStone.png", Vec2f(16,16), 0 );
	AddIconToken( "$Crossbow$", "TradeItems.png", Vec2f(16,16), 2 );
	AddIconToken( "$scroll$", "Scroll.png", Vec2f(16,16), 26 );
	AddIconToken( "$Coins$", "Coins.png", Vec2f(16,16), 5 );
	AddIconToken( "$flour$", "TradeItems.png", Vec2f(16,16), 4 );
	AddIconToken( "$Armorkit$", "TradeItems.png", Vec2f(16,16), 0 );
	AddIconToken( "$LongBow$", "TradeItems.png", Vec2f(16,16), 5 );
	AddIconToken( "$Invis_potion$", "Potions.png", Vec2f(8,8), 0 );
	AddIconToken( "$Light_potion$", "Potions.png", Vec2f(8,8), 5 );
	AddIconToken( "$Returnscroll$", "NewScroll.png", Vec2f(16,16), 4 );
	AddIconToken( "$Enemyreturnscroll$", "NewScroll.png", Vec2f(16,16), 5 );
	AddIconToken( "$Droughtscroll$", "NewScroll.png", Vec2f(16,16), 3 );
	AddIconToken( "$Zombiescroll$", "NewScroll.png", Vec2f(16,16), 6 );
	AddIconToken( "$Midasscroll$", "NewScroll.png", Vec2f(16,16), 0 );
	AddIconToken( "$Fishtransformscroll$", "NewScroll.png", Vec2f(16,16), 2 );
	AddIconToken( "$Healscroll$", "NewScroll.png", Vec2f(16,16), 1 );
	//siege shop
	AddIconToken( "$vehicleshop_upgradebolts$", "BallistaBolt.png", Vec2f(32,8), 1 );
	AddIconToken( "$Bomber$", "32Icons.png", Vec2f(32,32), 0 );
	AddIconToken( "$Submarine$", "32Icons.png", Vec2f(32,32), 1 );
	AddIconToken( "$Outpost$", "32Icons.png", Vec2f(32,32), 2 );
	AddIconToken( "$Cannon$", "32Icons.png", Vec2f(32,32), 3 );
	AddIconToken( "$MountedBow$", "MountedBow.png", Vec2f(16,16), 6 );
	AddIconToken( "$ShotgunBow$", "ShotgunBow.png", Vec2f(16,16), 6 );
	AddIconToken( "$Raft$", "RaftCraft.png", Vec2f(40,17), 0 );
	AddIconToken( "$divinghelmet$", "TradeItems.png", Vec2f(16,16), 3 );
	AddIconToken( "$mega_bomb$", "MegaBmb.png", Vec2f(8,8), 0 );
	AddIconToken( "$ArrowDinghy$", "ArrowDinghy.png", Vec2f(64,42), 2 );
	AddIconToken( "$Mat_cannon_balls$", "NewmtIcons.png", Vec2f(16,16), 0 );
	
	//magic shop
	AddIconToken( "$BloodJar$", "TradeItems.png", Vec2f(16,16), 1 );
	AddIconToken( "$Mega_drill$", "MegaDrill.png", Vec2f(32,16), 0 );
	
	//animal shop
	AddIconToken( "$Bison$", "MiniIcons.png", Vec2f(16,16), 21 );
	AddIconToken( "$Shark$", "MiniIcons.png", Vec2f(16,16), 22 );
	
	//kitchen
	AddIconToken( "$cake$", "Food.png", Vec2f(16,16), 5 );
	AddIconToken( "$cookedmeat$", "Food.png", Vec2f(16,16), 0 );
	AddIconToken( "$cookedfish$", "Food.png", Vec2f(16,16), 1 );
	AddIconToken( "$cake$", "Food.png", Vec2f(16,16), 5 );
	AddIconToken( "$bread$", "Food.png", Vec2f(16,16), 4 );
	
	//wizard altar
	AddIconToken( "$Mat_orbs$", "MagicOrbsMaterials.png", Vec2f(16,16), 8 );
	AddIconToken( "$Mat_fireorbs$", "MagicOrbsMaterials.png", Vec2f(16,16), 9 );
	AddIconToken( "$Mat_bomborbs$", "MagicOrbsMaterials.png", Vec2f(16,16), 10 );
	AddIconToken( "$Mat_waterorbs$", "MagicOrbsMaterials.png", Vec2f(16,16), 11 );
	
	//builder
	AddIconToken( "$stone_platform$", "StonePlatform.png", Vec2f(8,8), 0 );
	AddIconToken( "$steel_block$", "IronBlock.png", Vec2f(8,8), 0 );
	AddIconToken( "$wooden_spikes$", "WdnSpks.png", Vec2f(8,8), 0 );
	AddIconToken( "$wooden_trap_block$", "WdnTrp.png", Vec2f(8,8), 0 );
	AddIconToken( "$lamp_block$", "LampBlock.png", Vec2f(8,8), 0 );
	AddIconToken( "$DirtBlock$", "world.png", Vec2f(8,8), 16 );
	AddIconToken( "$fire_trap_block$", "TrpFireBlock.png", Vec2f(8,8), 0 );
	AddIconToken( "$teamcolored_wooden_platform$", "TeamColoredPltform.png", Vec2f(8,8), 0 );
	AddIconToken( "$gold_block$", "world.png", Vec2f(8,8), 160 );
	AddIconToken( "$explosive_trap$", "ExplosiveTrap.png", Vec2f(8,8), 0 );
	AddIconToken( "$coins_block$", "CoinsBlock.png", Vec2f(8,8), 0 );
	AddIconToken( "$triangle_wood_block$", "TriangleWood.png", Vec2f(8,8), 0 );
	AddIconToken( "$triangle_stone_block$", "TriangleStone.png", Vec2f(8,8), 0 );
	AddIconToken( "$bigbuilding$", "Bigbilding.png", Vec2f(16,16), 6 );
	AddIconToken( "$minibuilding$", "MiniBuiling.png", Vec2f(16,16), 0 );
	AddIconToken( "$farming_block$", "FarmingBlock.png", Vec2f(8,8), 0 );
	AddIconToken( "$mat_coal$", "NewmtIcons.png", Vec2f(16,16), 2 );
	
	//building
	AddIconToken( "$FightersShop$", "FightersShop.png", Vec2f(40,32), 0 );
	AddIconToken( "$MagicShop$", "MagicShop.png", Vec2f(40,24), 0 );
	AddIconToken( "$WizardAltar$", "WizardAltar.png", Vec2f(40,24), 6 );
	AddIconToken( "$Kitchen$", "CTFKitchen.png", Vec2f(40,24), 0 );
	AddIconToken( "$AnimalShop$", "AnimalShop.png", Vec2f(56,32), 0 );
	AddIconToken( "$TraderShop$", "TraderShop.png", Vec2f(40,24), 0 );
	AddIconToken( "$SiegeShop$", "SiegeShop.png", Vec2f(40,24), 0 );
	AddIconToken( "$Cristal$", "Cristal.png", Vec2f(16,16), 0 );
	AddIconToken( "$personal_storage$", "PrsnalStrage.png", Vec2f(40,24), 0 );
	AddIconToken( "$CTFnursery$", "CTFNursery.png", Vec2f(40,24), 4 );
	AddIconToken( "$Mill$", "Mill.png", Vec2f(40,24), 0 );
	AddIconToken( "$Portal$", "Teleport.png", Vec2f(40,24), 2 );
	AddIconToken( "$Forge$", "Forge.png", Vec2f(40,24), 1 );
	AddIconToken( "$Barracks$", "Barracks.png", Vec2f(40,24), 0 );
	AddIconToken( "$Well$", "Well.png", Vec2f(40,24), 0 );
	
	//knight shop
	AddIconToken( "$HiddenMineIcon$", "HiddenMn.png", Vec2f(16,16), 0 );
	AddIconToken( "$SatchelIcon$", "Satchel.png", Vec2f(16,16), 0 );
	AddIconToken( "$MiniKegIcon$", "MiniKeg.png", Vec2f(16,16), 0 );
	AddIconToken( "$BombIcon$", "Bomb.png", Vec2f(16,16), 0 );
	AddIconToken( "$WaterBombIcon$", "WaterBomb.png", Vec2f(16,16), 0 );
	AddIconToken( "$StickyBombIcon$", "StickyBomb.png", Vec2f(16,16), 0 );

	//knight
	AddIconToken( "$StickyBombKnight$", "KnightIcons.png", Vec2f(16,32), 4 );

	//wizard altar and other shops which have wizard stuff
	AddIconToken( "$Cristal$", "Cristal.png", Vec2f(16,16), 0 );
	AddIconToken( "$SoulStone$", "SoulStone.png", Vec2f(16,16), 0 );
	AddIconToken( "$soulstoneshard$", "SoulStoneShard.png", Vec2f(16,16), 0 );

	AddIconToken( "$change_color$", "ButtonIcons.png", Vec2f(32,32), 0 );

	//quarters
	AddIconToken( "$Medkit$", "Medkit.png", Vec2f(16,16), 0 );
}