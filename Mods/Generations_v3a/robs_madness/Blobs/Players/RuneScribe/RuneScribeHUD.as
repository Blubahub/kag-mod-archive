/*
Do you really have to read this file?

That's kinda boring :/






















































*/

#include "RunesCommon.as";

void onInit(CSprite@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getCurrentScript().removeIfTag = "dead";
}

void onRender(CSprite@ this)
{
	if (g_videorecording)
		return;


	CBlob@ blob = this.getBlob();
	
	if(getHUD().hasMenus())
	if(blob.getName() == "runescribe"){
	
		Vec2f Pos = Vec2f(getScreenWidth()-200,getScreenHeight()/2-(177));
		
		Pos = blob.get_Vec2f("InventoryPos")+Vec2f(120,-128);
		
		GUI::DrawIcon("scrollHUD.png", 0, Vec2f(100, 177), Pos, 1.0f);
		
		GUI::DrawTextCentered("Write Scroll", Pos+Vec2f(50*2,9*2), SColor(255, 19, 13, 29));
		
		
		GUI::DrawTextCentered("Main\nRune:", Pos+Vec2f(14*2,34*2), SColor(255, 19, 13, 29));
		GUI::DrawTextCentered("Sub\nRune:", Pos+Vec2f(66*2,34*2), SColor(255, 19, 13, 29));
		
		int width = blob.get_string("scroll").length();
		for (int step = 2; step < width; step += 1)
		{
			GUI::DrawIcon("runeIcons.png", getRuneFromLetter(blob.get_string("scroll").substr(step,1)), Vec2f(8, 8), Pos+Vec2f(14*2,153*2)+Vec2f(13*2,0)*(step-2), 1.0f);
		}
		
		int MainRune = getRuneFromLetter(blob.get_string("scroll").substr(0,1));
		int SubRune = getRuneFromLetter(blob.get_string("scroll").substr(1,1));
		
		int AbilityID = getPrimaryAbilityID(blob.get_string("scroll"));
		int SecondaryAbilityID = getSecondaryAbilityID(blob.get_string("scroll"));
		
		if(MainRune != -1){
			GUI::DrawIcon("runeIconsLarge.png", MainRune, Vec2f(16, 16), Pos+Vec2f(32*2,25*2), 1.0f);
			GUI::DrawText(""+primaryNames(AbilityID), Pos+Vec2f(9*2,50*2), SColor(255, 19, 13, 29));
		}
		if(SubRune != -1){
			GUI::DrawIcon("runeIcons.png", SubRune, Vec2f(8, 8), Pos+Vec2f(84*2,29*2), 1.0f);
			GUI::DrawText(""+secondaryNames(SecondaryAbilityID), Pos+Vec2f(9*2,60*2), SColor(255, 19, 13, 29));
		}
		
		
		
		int HeatBarAmount = getRunesHeat(blob.get_string("scroll"));
		int FlowBarAmount = getRunesFlow(blob.get_string("scroll"));
		int ComplexityBarAmount = getRunesComplexity(blob.get_string("scroll"));
		int HolyBarAmount = 5+getRunesHoliness(blob.get_string("scroll"));
		
		int PowerBarAmount = HeatBarAmount;
		int CostBarAmount = HeatBarAmount-FlowBarAmount;
		
		CostBarAmount += ComplexityBarAmount;
		if(ComplexityBarAmount >= 6)PowerBarAmount += ComplexityBarAmount-5;
		
		if(CostBarAmount < 1)CostBarAmount = 1;
		CostBarAmount += secondaryCosts(SecondaryAbilityID);
		if(CostBarAmount < 1)CostBarAmount = 1;
		
		int HeatRequirement = 0;
		int FlowRequirement = 0;
		int HolyRequirement = 0;
		bool HeatLargerOrEqual = false;
		bool FlowLargerOrEqual = false;
		bool HolyLargerOrEqual = false;
		
		if(AbilityID > 0){
			HeatRequirement = AbilityHeatRequirement(AbilityID);
			FlowRequirement = AbilityFlowRequirement(AbilityID);
			HolyRequirement = AbilityHolyRequirement(AbilityID);
			HeatLargerOrEqual = AbilityHeatRequirementLarger(AbilityID);
			FlowLargerOrEqual = AbilityFlowRequirementLarger(AbilityID);
			HolyLargerOrEqual = AbilityHolyRequirementLarger(AbilityID);
		}
		
		
		for (int i = 0; i < Maths::Clamp(PowerBarAmount, 0, 10); i += 1){
			int frame = (i == 0) ? 2 : 1;
			if(i == 9)frame = 0;
			GUI::DrawIcon("PowerGauge.png", frame, Vec2f(7, 5), Pos+Vec2f(7*2,131*2-i*10), 1.0f);
		}
		
		for (int i = 0; i < Maths::Clamp(CostBarAmount, 0, 10); i += 1){
			int frame = (i == 0) ? 2 : 1;
			if(i == 9)frame = 0;
			GUI::DrawIcon("CostGauge.png", frame, Vec2f(7, 5), Pos+Vec2f(86*2,131*2-i*10), 1.0f);
		}
		
		
		for (int i = 0; i < Maths::Clamp(HeatBarAmount, 0, 10); i += 1){
			int frame = (i == 0) ? 0 : 1;
			if(i == HeatBarAmount-1 || i == 9)frame = 2;
			GUI::DrawIcon("ScrollGauge.png", frame, Vec2f(4, 4), Pos+Vec2f(24*2,127*2-i*8), 1.0f);
		}
		if(HeatRequirement > 0){
			int frame = 0;
			if(HeatLargerOrEqual){
				if(HeatBarAmount >= HeatRequirement)frame = 1;
			} else {
				if(HeatBarAmount < HeatRequirement)frame = 2;
				else frame = 3;
			}
			GUI::DrawIcon("GaugeRequirement.png", frame, Vec2f(6, 4), Pos+Vec2f(23*2,129*2-(HeatRequirement-1)*8), 1.0f);
		}
		if(HeatBarAmount > 10)if(getGameTime() % 30 < 15)GUI::DrawIcon("HotGauge.png", 0, Vec2f(12, 47), Pos+Vec2f(20*2,88*2), 1.0f);
		
		for (int i = 0; i < Maths::Clamp(FlowBarAmount, 0, 10); i += 1){
			int frame = (i == 0) ? 0 : 1;
			if(i == FlowBarAmount-1 || i == 9)frame = 2;
			GUI::DrawIcon("ScrollGauge.png", frame+3, Vec2f(4, 4), Pos+Vec2f(24*2+16*2,127*2-i*8), 1.0f);
		}
		if(FlowRequirement > 0){
			int frame = 0;
			if(FlowLargerOrEqual){
				if(FlowBarAmount >= FlowRequirement)frame = 1;
			} else {
				if(FlowBarAmount < FlowRequirement)frame = 2;
				else frame = 3;
			}
			GUI::DrawIcon("GaugeRequirement.png", frame, Vec2f(6, 4), Pos+Vec2f(23*2+16*2,129*2-(FlowRequirement-1)*8), 1.0f);
		}
		
		for (int i = 0; i < Maths::Clamp(ComplexityBarAmount, 0, 10); i += 1){
			int frame = (i == 0) ? 0 : 1;
			if(i == ComplexityBarAmount-1 || i == 9)frame = 2;
			GUI::DrawIcon("ScrollGauge.png", frame+6, Vec2f(4, 4), Pos+Vec2f(24*2+16*4,127*2-i*8), 1.0f);
		}
		if(ComplexityBarAmount > 10)if(getGameTime() % 30 < 15)GUI::DrawIcon("HotGauge.png", 0, Vec2f(12, 47), Pos+Vec2f(20*2+16*4,88*2), 1.0f);
		
		for (int i = 0; i < Maths::Clamp(HolyBarAmount, 0, 10); i += 1){
			int frame = (i == 0) ? 0 : 1;
			if(i == HolyBarAmount-1 || i == 9)frame = 2;
			GUI::DrawIcon("ScrollGauge.png", frame+9, Vec2f(4, 4), Pos+Vec2f(24*2+16*6,127*2-i*8), 1.0f);
		}
		if(HolyRequirement > 0){
			int frame = 0;
			if(HolyLargerOrEqual){
				if(HolyBarAmount >= HolyRequirement)frame = 1;
			} else {
				if(HolyBarAmount < HolyRequirement)frame = 2;
				else frame = 3;
			}
			GUI::DrawIcon("GaugeRequirement.png", frame, Vec2f(6, 4), Pos+Vec2f(23*2+16*6,129*2-(HolyRequirement-1)*8), 1.0f);
		}
	}
}
