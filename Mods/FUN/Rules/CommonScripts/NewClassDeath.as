#include "Explosion.as";

void onPlayerDie( CRules@ this, CPlayer@ victim, CPlayer@ killer, u8 customData ){
	if (victim !is null ){
		CBlob@ blob = victim.getBlob();
		if (blob !is null && blob.getName() == "wizard"){
			int team = victim.getTeamNum();
			if(getNet().isServer()){
				victim.lastBlobName = "knight";
				
				blob.server_setTeamNum(255);
				victim.server_setCoins(0);
				server_CreateBlob( "soulstoneshard", 1, blob.getPosition() );
			}
		}
		else if (blob !is null && blob.getName() == "heavyknight"){
			int team = victim.getTeamNum();
			if(getNet().isServer()){
				victim.lastBlobName = "knight";
				server_CreateBlob( "mace", 1, blob.getPosition() );
				server_CreateBlob( "chestplate", 1, blob.getPosition() );
			}
		}
		else if (blob !is null && blob.getName() == "crossbowman"){
			int team = victim.getTeamNum();
			if(getNet().isServer()){
				victim.lastBlobName = "knight";
				server_CreateBlob( "crossbow", 1, blob.getPosition() );
			}
		}
		else if (blob !is null && blob.getName() == "druid"){
			int team = victim.getTeamNum();
			if(getNet().isServer()){
				victim.lastBlobName = "knight";
			}
		}
		else if (blob !is null && blob.getName() == "Necromancer"){
			int team = victim.getTeamNum();
			if(getNet().isServer()){
				victim.lastBlobName = "knight";
			}
		}
		else if (blob !is null && blob.getName() == "hunter"){
			int team = victim.getTeamNum();
			if(getNet().isServer()){
				victim.lastBlobName = "knight";
				server_CreateBlob( "longbow", 1, blob.getPosition() );
			}
		}
	}
}