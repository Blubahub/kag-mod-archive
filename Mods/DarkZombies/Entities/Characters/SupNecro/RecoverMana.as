//recover mana
#include "NecromancerCommon.as";
u8 manaRegenerateStep = 2;
s32 playersCount = 0;

void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 5 * getTicksASecond();
	this.getCurrentScript().removeIfTag = "dead";
}

void adjustManaRegenStepToPlayersAmount()
{
    CBlob@[] player_blobs;
    getBlobsByTag( "player", @player_blobs );

    uint necros = 0;
    uint survivors = 0;
 
    for(uint i=0; i<player_blobs.length; i++ ){
        if (player_blobs[i] !is null){
            if (player_blobs[i].getTeamNum() == 0)
                survivors++;
            else if (player_blobs[i].getTeamNum() == 1)
                necros++;
        }
    }
    if (necros > 0)
        manaRegenerateStep = survivors / necros;
    playersCount = necros + survivors;
}

void onTick(CBlob@ this)
{
    if (getPlayersCount() != playersCount)
        adjustManaRegenStepToPlayersAmount();
	NecromancerInfo@ necro;
    if (!this.get( "necromancerInfo", @necro )) {
        return;
    }
    s32 mana = necro.mana;
    s32 maxMana = necro.maxMana;
    if (mana < maxMana)
    {
    	if (maxMana - mana >= manaRegenerateStep)
    		necro.mana += manaRegenerateStep;
    	else
    		necro.mana = maxMana;
    }
}