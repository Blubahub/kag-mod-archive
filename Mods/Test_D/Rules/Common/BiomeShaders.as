#define CLIENT_ONLY

#include "GameColours.as";

///////////////////////////////////////////////////
//
//	biome shader setting script
//
//		usage: set biome string in rules to
//		automatically change the shader
//		if needed.
//
///////////////////////////////////////////////////

string prev_biome = "";

void SetBiomeShader(string biome)
{
	Driver@ driver = getDriver();
	CMap@ map = getMap();
	map.CreateSky(SColor(Colours::SKY));

	if (driver.hasShaders())
	{
		if (biome == "desert")
		{
			driver.SetShaderExtraTexture("palette", "Sprites/Palettes/desert_palette.png");
			map.AddBackground("Sprites/BiomeEffects/desert_backdrop.png", Vec2f(0.7f, 0), Vec2f(0.25, 0), SColor(0xffffffff));
		}
		else if (biome == "forest")
		{
			driver.SetShaderExtraTexture("palette", "Sprites/Palettes/forest_palette.png");
			map.AddBackground("Sprites/BiomeEffects/night_backdrop.png", Vec2f(0.3f, 0), Vec2f(0.25, 0), SColor(0xffffffff));
		}
		else if (biome == "trenches")
		{
			driver.SetShaderExtraTexture("palette", "Sprites/Palettes/trench_palette.png");
			map.AddBackground("Sprites/BiomeEffects/trenches_backdrop.png", Vec2f(0.2f, 0), Vec2f(0.25, 0), SColor(0xffffffff));
		}
		else if (biome == "swamp")
		{
			driver.SetShaderExtraTexture("palette", "Sprites/Palettes/swamp_palette.png");
			map.AddBackground("Sprites/BiomeEffects/forest_backdrop", Vec2f(0.1f, 0), Vec2f(0.25, 0), SColor(0xffffffff));
		}
		else if (biome == "village")
		{
			driver.SetShaderExtraTexture("palette", "Sprites/Palettes/village_palette.png");
			map.AddBackground("Sprites/BiomeEffects/forest_backdrop", Vec2f(0.4f, 0), Vec2f(0.25, 0), SColor(0xffffffff));
		}
		else if (biome == "city")
		{
			driver.SetShaderExtraTexture("palette", "Sprites/Palettes/city_palette.png");
			map.AddBackground("Sprites/BiomeEffects/city_backdrop", Vec2f(0.3f, 0), Vec2f(0.25, 0), SColor(0xffffffff));
		}
		else if (biome == "mountain")
		{
			driver.SetShaderExtraTexture("palette", "Sprites/Palettes/mountain_palette.png");
			map.AddBackground("Sprites/BiomeEffects/forest_backdrop", Vec2f(0.8f, 0), Vec2f(0.25, 0), SColor(0xffffffff));
		}
		else
		{
			driver.SetShaderExtraTexture("palette", "Sprites/Palettes/default_palette.png");
			map.AddBackground("Sprites/BiomeEffects/forest_backdrop", Vec2f(0.6f, 0), Vec2f(0.25, 0), SColor(0xffffffff));
		}
	}
}

void onRestart(CRules@ this)
{
	prev_biome = "";
}

void onTick(CRules@ this)
{
	string biome = this.get_string("biome");
	if (biome != prev_biome || this.exists("force biome") && this.get_bool("force biome"))
	{
		//printf("BIOME   " + biome);
		this.set_bool("force biome", false);
		prev_biome = biome;
		SetBiomeShader(biome);
		printf("NEW BIOME " + biome);
	}
	getDriver().SetShaderFloat("palette", "tick", getGameTime());
}
