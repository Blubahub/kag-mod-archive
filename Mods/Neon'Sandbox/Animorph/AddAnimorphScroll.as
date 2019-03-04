//AddAnimorphScroll.as
//@author: Verrazano
//@description: Adds the animorph scroll to the trader shop.
//@usage: add this file to gamemode.cfg.

#include "ScrollCommon.as"
#include "TradingCommon.as"
#include "MiniIconsInc.as"

void onInit(CRules@ this)
{
	defineAnimorphScroll(this);

}

void onRestart(CRules@ this)
{
	if(this is null || getRules() is null)
		return;

	defineAnimorphScroll(this);

}

void onTick(CRules@ this)
{
	CBlob@[] blobList;
	getBlobsByName("trader", blobList);

	for (uint i = 0; i < blobList.length(); i++)
	{ 
		CBlob@ trader = blobList[i];
		if(trader.hasTag("has animorph scroll"))
			continue;
		trader.Tag("has animorph scroll");
		addTradeScrollFromScrollDef(trader, "animorph", 300, "This magic scroll will turn everyone in a large surrounding orb into an animal.");

	}

}

void defineAnimorphScroll(CRules@ this)
{
	ScrollDef def;
	def.name = "Scroll of Animorph";
	def.scrollFrame = FactoryFrame::magic_gib;
	def.scripts.push_back("ScrollAnimorph.as");

	ScrollSet@ all = getScrollSet("all scrolls");
	if(all is null)
		return;
	all.scrolls.set("animorph", def);
	all.names.push_back("animorph");

}