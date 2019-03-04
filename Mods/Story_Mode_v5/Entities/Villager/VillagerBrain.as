// Migrant brain

#define SERVER_ONLY

#include "/Entities/Common/Emotes/EmotesCommon.as"

void onInit(CBrain@ this)
{
	CBlob @blob = this.getBlob();
	blob.set_Vec2f("target spot", blob.getPosition());
	blob.set_Vec2f("home spot", blob.getPosition());
	blob.set_Vec2f("last spot", blob.getPosition());
	this.getCurrentScript().removeIfTag = "dead";   //won't be removed if not bot cause it isnt run
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
}

void onTick(CBrain@ this)
{
	CBlob @blob = this.getBlob();
	if (blob.getTeamNum() > 10)
		return;
	
	
	if(blob.get_Vec2f("last spot").x > blob.getPosition().x-0.5 && blob.get_Vec2f("last spot").x < blob.getPosition().x+0.5){
		if(XORRandom(10) == 0)blob.set_Vec2f("target spot", blob.getPosition());
	}
	
	if(XORRandom(200) == 0){
		blob.set_Vec2f("target spot", blob.get_Vec2f("home spot")+Vec2f(XORRandom(64)-32,0));
	}
	
	
	if(blob.getPosition().x < blob.get_Vec2f("target spot").x-8)blob.setKeyPressed(key_right, true);
	else blob.setKeyPressed(key_right, false);
	if(blob.getPosition().x > blob.get_Vec2f("target spot").x+8)blob.setKeyPressed(key_left, true);
	else blob.setKeyPressed(key_left, false);
	
	if(blob.getPosition().y < blob.get_Vec2f("target spot").y-8)blob.setKeyPressed(key_down, true);
	else blob.setKeyPressed(key_down, false);
	if(blob.getPosition().y > blob.get_Vec2f("target spot").y+8)blob.setKeyPressed(key_up, true);
	else blob.setKeyPressed(key_up, false);
	
	blob.set_Vec2f("last spot", blob.getPosition());
	
	if (blob.isInWater())
	{
		blob.setKeyPressed(key_up, true);
	}
}