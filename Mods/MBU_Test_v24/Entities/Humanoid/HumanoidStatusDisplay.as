
#include "Ally.as"

void onRender(CSprite@ this)
{
	float Scale = getCamera().targetDistance;
	
	CBlob@ blob = this.getBlob();
	Vec2f center = blob.getPosition();
	Vec2f mouseWorld = getControls().getMouseWorldPos();
	const f32 renderRadius = (blob.getRadius()) * 0.95f;
	bool mouseOnBlob = (mouseWorld - center).getLength() < renderRadius;
	if (mouseOnBlob)
	{
		
		if(!blob.hasTag("soul") || !this.isVisible())return;
		
		if(getLocalPlayerBlob() is null || getLocalPlayerBlob() is blob)return;
		
		f32 bob = (f32(getGameTime()) % 60)-30;
		
		if(bob < 0)bob = -bob;
		
		Vec2f Pos = getDriver().getScreenPosFromWorldPos(blob.getInterpolatedPosition()+Vec2f(-12,-26-bob*0.5f));
		
		if(getLocalPlayerBlob().get_string("partner") == blob.get_string("player_name") && getLocalPlayerBlob().get_string("partner") != ""){
			string filename = "Heart.png";
			GUI::DrawIcon(filename, 0, Vec2f(16,16), Pos+Vec2f(16,16)*Scale, Scale);
		} else {
		
			if(checkAlly(getLocalPlayerBlob().getTeamNum(),blob.getTeamNum()) == Team::Ally){
				GUI::DrawIcon("FriendOrFoe.png", 0, Vec2f(16,16), Pos+Vec2f(16,16)*Scale, Scale);
			}
			
			if(checkAlly(getLocalPlayerBlob().getTeamNum(),blob.getTeamNum()) == Team::Neutral){
				GUI::DrawIcon("FriendOrFoe.png", 2, Vec2f(16,16), Pos+Vec2f(16,16)*Scale, Scale);
			}
			
			if(!getMap().rayCastSolidNoBlobs(blob.getPosition(),getLocalPlayerBlob().getPosition()))
			if(checkAlly(getLocalPlayerBlob().getTeamNum(),blob.getTeamNum()) == Team::Enemy){
				GUI::DrawIcon("FriendOrFoe.png", 1, Vec2f(16,16), Pos+Vec2f(16,16)*Scale, Scale);
			}
		
		}
		
	}
}