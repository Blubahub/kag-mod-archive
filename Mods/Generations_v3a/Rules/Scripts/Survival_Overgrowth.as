#define SERVER_ONLY
#include "canGrow.as";
#include "MakeSeed.as";
#include "Hitters.as";
#include "Decay_Common.as";

// A tiny mod by TFlippy

float tickrate = 5;

void onRestart(CRules@ this)
{
	CMap@ map = getMap();
	tickrate = Maths::Ceil(30 / (3 + (0.02 * map.tilemapwidth)));
}


void onTick(CRules@ this)
{
	DecayStuff(1);
}