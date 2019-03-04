
#include "RuneNames.as";

void copyTatoos(CBlob@ source, CBlob@ target){

	for(int i = 0; i < 24; i += 1)if(source.hasTag(getRuneCodeName(i)+"runetatoo"))target.Tag(getRuneCodeName(i)+"runetatoo");

}