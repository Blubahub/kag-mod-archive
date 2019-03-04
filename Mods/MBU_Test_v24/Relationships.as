///OTPs.txt

#include "RelationshipsCommon.as";

void onInit(CBlob @this){

	string[] thingsILove = {"love"};
	this.set("blobLove",thingsILove);

	string[] thingsIHate = {"hate"};
	this.set("blobHate",thingsIHate);
	
	this.Tag("relationship");
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{

	editRelationship(this,hitterBlob,-Maths::Max(damage*2.5f,1));

	return damage;
}

void onBlobCreated( CRules@ this, CBlob@ blob ){
	blob.AddScript("AbusiveRelationship.as");
}