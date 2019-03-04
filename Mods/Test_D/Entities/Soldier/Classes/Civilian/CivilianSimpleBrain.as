#define SERVER_ONLY

#include "SimpleStates.as"
#include "SoldierCommon.as"
#include "SimpleCommonStates.as"

void onInit( CBrain@ this )
{
	CBlob@ blob = this.getBlob();	
	//blob.Tag("smoking");
}

void onTick( CBrain@ this )
{
	CBlob@ blob = this.getBlob();
	Vec2f pos = blob.getPosition();
	const u32 time = getGameTime();
	bool dance = false;

	CBlob@[] overlapping;
	if (blob.getOverlapping(@overlapping))
	{
		for (uint i = 0; i < overlapping.length; i++)
		{
			CBlob@ overlap = overlapping[i];
			if (overlap.getName() == "band_member"){
				dance = true;
				break;
			}
			else if (overlap.getName() == "shop"){
				if (overlap.get_u8("shop type") == 0){
					blob.Tag("drinking");
				}
				else {
					blob.Tag("smoking");
				}
				break;
			}	
			else if (overlap.getName() == "truck"){
			CBitStream params;
			params.write_netid(blob.getNetworkID());
			overlap.SendCommand(overlap.getCommandID("use"), params);
			break;
			}			
		}
	}

	// dance 

	if (dance)
	{
		if (XORRandom(20) == 0){
			if (blob.hasTag("crouching")){
				blob.Untag("crouching");
			}
			else{
				blob.Tag("crouching");		
			}
		}

		blob.setKeyPressed(key_action2, time % 30 < 16);
	}

	// keys

	if (blob.hasTag("crouching")){
		blob.setKeyPressed(key_crouch, true);
	}
}
