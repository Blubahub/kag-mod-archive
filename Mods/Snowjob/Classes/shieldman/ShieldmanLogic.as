// Template logic
// If I haven't commented something, it's because I don't know what it is, but I do know it's important.


//Import scripts! These are important for reasons. Basically, they let you steal code from base to use as your own, legally.
#include "Hitters.as"; //Basically, all the types of attacks you get.
#include "Knocked.as"; //Known as stun.
#include "ThrowCommon.as"; //You know when you press 'C' in game and you throw what you're holding?
#include "RunnerCommon.as"; //Movement scripts.

void onInit(CBlob@ this)
{
	this.set_f32("gib health", -3.0f); //When the class/blob reaches negative 3 hp, it explodes into gore.

	this.Tag("player"); //This is a player
	this.Tag("flesh"); //This class is also flesh. Tags like plant/stone/metal don't work unless you code them yourself

	CShape@ shape = this.getShape(); //Getting our physics variable
	shape.SetRotationsAllowed(false); //Let's not roll all over the place.
	shape.getConsts().net_threshold_multiplier = 0.5f;

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
	
	
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if(player !is null)
	{
		player.SetScoreboardVars("ScoreboardIcons.png", 1, Vec2f(16, 16)); //This basically sets our score board icon.
	}
}

void onTick(CBlob@ this) //This script is called 30 times a second. It's a general update script. Most of your modding will be done here.
{
	if(this.isInInventory())return;
	const bool ismyplayer = this.isMyPlayer();
	if(ismyplayer && getHUD().hasMenus())return;

	if(ismyplayer)
	if(this.isKeyJustPressed(key_action3))
	{
		CBlob@ carried = this.getCarriedBlob();
		if(carried is null)client_SendThrowOrActivateCommand(this);
	}
	
	bool Action1 = this.isKeyPressed(key_action1);
	bool Action2 = this.isKeyPressed(key_action2);
	
	f32 angle = getAimAngle(this);
	
	if(Action2 || Action1){
		if(angle > 45 && angle < 135){
			if(this.getVelocity().y > 0)this.getShape().SetGravityScale(0.2);
		} else {
			this.getShape().SetGravityScale(1);
		}
		
		RunnerMoveVars@ moveVars;
		if (this.get("moveVars", @moveVars))
		{
			if(angle > 270-45 && angle < 270+45)moveVars.jumpFactor *= 0.0f;
			else moveVars.jumpFactor *= 0.5f;
		}
		this.Tag("shielding");
	} else {
		this.Untag("shielding");
	}
	
	if(getGameTime() % 30 == 0){
	
		
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), 64.0f, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(b !is null)if(b.getTeamNum() == this.getTeamNum() && b.hasTag("player"))
				if(b.getPosition().x > this.getPosition().x ^^ !this.isFacingLeft()){
					MakeHomingParticle(this.getPosition(),b);
				}
			}
		}
	
	}
	
	
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	// play cling sound if other knight attacked us
	// dmg could be taken out here if we ever want to

	if(this.hasTag("shielding")){
		Vec2f pos = this.getPosition();
		f32 aimangle = getAimAngle(this);

		Vec2f vec = worldPoint - pos;
		f32 angle = vec.Angle();
		
		if((aimangle+60 > angle && aimangle-60 < angle) || aimangle-60+360 < angle || aimangle+60-360 < angle)return 0;
	}

	return damage; //no block, damage goes through
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point)
{
	if(solid && point.y > this.getPosition().y)
	if(this.hasTag("shielding")){
		if(this.isKeyPressed(key_up))
		if(getAimAngle(this) > 270-45 && getAimAngle(this) < 270+45){
			if(this.isKeyPressed(key_right) && this.isKeyPressed(key_left))this.setVelocity(Vec2f(0,-3));
			else if(this.isKeyPressed(key_left))this.setVelocity(Vec2f(-5,-3));
			else if(this.isKeyPressed(key_right)) this.setVelocity(Vec2f(5,-3));
			else this.setVelocity(Vec2f(0,-3));
			
			Vec2f velr = getRandomVelocity(!this.isFacingLeft() ? 70 : 110, 4.3f, 40.0f);
			velr.y = -Maths::Abs(velr.y) + Maths::Abs(velr.x) / 3.0f - 2.0f - float(XORRandom(100)) / 100.0f;
			ParticlePixel(point, velr, SColor(255, 255, 255, 0), true);
			this.getSprite().PlayRandomSound("/Scrape");
		}
	}
}

f32 getAimAngle(CBlob @this){

	Vec2f pos = this.getPosition();
	Vec2f aimpos = this.getAimPos();
	Vec2f vec = aimpos - pos;
	return vec.Angle();

}


void MakeHomingParticle(Vec2f position, CBlob @targ){

	if(getNet().isServer()){
	
		CBlob @part = server_CreateBlob("shieldheal", -1, position);
		if(part !is null && targ !is null)part.set_u16("following",targ.getNetworkID());
	
	}
}