
#include "RelationshipsCommon.as";

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData){

	CBlob @real_attacker = hitterBlob;
	
	if(hitterBlob.getDamageOwnerPlayer() !is null)if(hitterBlob.getDamageOwnerPlayer().getBlob() !is null)@real_attacker = hitterBlob.getDamageOwnerPlayer().getBlob();
	
	if(this is real_attacker)return damage;

	
	
	CBlob@[] friends;
	getBlobsByTag("relationship", @friends);
	
	for(int j = 0; j < friends.length; j++)
	{
		CBlob @friend = friends[j];
		if(friend !is null){
			int relation = checkRelationshipTotal(friend,this);
			if(relation > 75)editRelationship(friend,real_attacker,-2.0f*damage);
			else if(relation > 50)editRelationship(friend,real_attacker,-1.5f*damage);
			else if(relation > 25)editRelationship(friend,real_attacker,-1.0f*damage);
			else if(relation > 0)editRelationship(friend,real_attacker,-0.5f*damage);
			else if(relation < -75)editRelationship(friend,real_attacker,2.0f*damage);
			else if(relation < -50)editRelationship(friend,real_attacker,1.5f*damage);
			else if(relation < -25)editRelationship(friend,real_attacker,1.0f*damage);
			else if(relation < 0)editRelationship(friend,real_attacker,0.5f*damage);
		}
	}
	
	return damage;

}