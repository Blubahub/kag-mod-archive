#include "AnimalConsts.as";

const u8 DEFAULT_PERSONALITY = AGGRO_BIT;
const string bite_tag = "biteing";

//sprite

void onInit(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	
    this.ReloadSprites(blob.getTeamNum(),0);
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	
	if (this.isAnimation("revive") && !this.isAnimationEnded()) return;
	if (this.isAnimation("bite") && !this.isAnimationEnded()) return;
    if (blob.getHealth() > 0.0)
    {
		f32 x = blob.getVelocity().x;
		
		if(blob.get_u8("core_sprite") == 0){
			this.SetAnimation("default");
		}
		else
		if (this.isAnimation("dead"))
		{
			this.SetAnimation("revive");
		}
		else
		if( blob.get_s32("climb") > 1 ) 
		{
			if (!this.isAnimation("climb")) {
				this.SetAnimation("climb");
			}
		}
		else
		if( blob.hasTag(bite_tag) && !this.isAnimation("bite"))
		{
			if (!this.isAnimation("bite")) {
				this.SetAnimation("bite");
				return;
			}
		}
		else
		if (Maths::Abs(x) > 0.1f)
		{
			if (!this.isAnimation("walk")) {
				this.SetAnimation("walk");
			}
		}
		else
		{
			if (!this.isAnimation("idle")) {
			this.SetAnimation("idle");
			}
		}
	}
	else 
	{
		if (!this.isAnimation("dead"))
		{
			this.SetAnimation("dead");
		}
		this.getCurrentScript().runFlags |= Script::remove_after_this;
	}
}

void onRender(CSprite@ this)
{
	if (getLocalPlayer().getUsername() == "Pirate-Rob")
	{
		CBlob@ blob = this.getBlob();
		if(blob.get_u8(state_property) == MODE_TARGET )
		{
			CBlob@ b = getBlobByNetworkID(blob.get_netid(target_property));
			if (b !is null)
			{
				Vec2f mypos = getDriver().getScreenPosFromWorldPos(blob.getPosition());
				Vec2f targetpos = getDriver().getScreenPosFromWorldPos(b.getPosition());
				GUI::DrawArrow2D( mypos,targetpos , SColor(0xffdd2212) );
			}
		}
	}
}

//blob
void onInit(CBrain@ this)
{
	this.getCurrentScript().runFlags = Script::tick_not_attached;
}
void onInit(CBlob@ this)
{
	
	//for EatOthers
	string[] tags = {"player"};
	this.set("tags to eat", tags);
	
	this.set_f32("bite damage", 1.0f);
	this.set_u16("bite freq", 60);
	this.set_u16("bite charge", 20);
	//brain
	this.set_u8(personality_property, DEFAULT_PERSONALITY);
	this.set_u8("random move freq",6);
	this.set_f32(target_searchrad_property, 160.0f);
	this.set_f32(terr_rad_property, 185.0f);
	this.set_u8(target_lose_random,34);
	
	this.getBrain().server_SetActive( true );
	
	//for shape
	this.getShape().SetRotationsAllowed(false);
	
	this.Tag("stone");
	
	this.getCurrentScript().runFlags = Script::tick_not_attached;
	
	this.set_u8("core",0);
	this.set_u8("core_sprite",0);
	
	this.addCommandID("interact");
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(this.get_u8("core") == 0 || this.getTeamNum() == caller.getTeamNum())
	if(this.get_u8("core") != 3){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		int image = 23;
		if(this.get_u8("core") == 0)image = 27;
		CButton@ button = caller.CreateGenericButton(image, Vec2f(0,0), this, this.getCommandID("interact"), "Core", params);
		button.SetEnabled(this.get_u8("core") != 0 || caller.getCarriedBlob() !is null);
	}
}

void onDie(CBlob@ this){
	if(this.get_u8("core") == 1)server_CreateBlob("stone_core", this.getTeamNum(), this.getPosition()+Vec2f(0,-8)); 
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	CBlob@ caller = getBlobByNetworkID(params.read_u16());
	if(caller !is null)
	{
		if (cmd == this.getCommandID("interact"))
		{
			CBlob@ hold = caller.getCarriedBlob();
			if(hold is null){
				if(this.get_u8("core") == 1){
					server_CreateBlob("stone_core", this.getTeamNum(), this.getPosition()+Vec2f(0,-8));
					this.set_u8("core",0);
				}
				if(this.get_u8("core") == 2){
					server_CreateBlob("gold_core", this.getTeamNum(), this.getPosition()+Vec2f(0,-8));
					this.set_u8("core",0);
				}
			} else if(this.get_u8("core") == 0){
				if(hold.getName() == "stone_core"){
					this.set_u8("core",1);
					hold.server_Die();
				}
				if(hold.getName() == "gold_core"){
					this.set_u8("core",2);
					hold.server_Die();
				}
				if(hold.getName() == "ghost_shard"){
					this.set_u8("core",3);
					this.server_SetPlayer(hold.getPlayer());
					hold.Tag("switch class");
					hold.server_SetPlayer(null);
					hold.server_Die();
				}
			}
		}
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ blob)
{
	return false;
}

void onTick(CBlob@ this)
{
	if(this.get_u8("core") != 0 && this.get_u8("core") != 3)
		this.getBrain().server_SetActive(true);
	else
		this.getBrain().server_SetActive(false);

	CBlob@ b = getBlobByNetworkID(this.get_netid(target_property));
	
	if(this.isInWater()){
		if(b is null)this.AddForce(Vec2f(0,-8));
		else {
			if(b.getPosition().y <= this.getPosition().y)this.AddForce(Vec2f(0,-8));
		}
	}
	
	u16 lastbite = this.get_u16("lastbite");
	u16 bitefreq = this.get_u16("bite freq");
	
	if (lastbite <= bitefreq-this.get_u16("bite charge"))this.set_u16("lastbite",this.get_u16("lastbite")+1);
	
	if (getNet().isServer())
	{
		if (bitefreq<0) bitefreq=20;

		if (lastbite > bitefreq-this.get_u16("bite charge"))this.set_u16("lastbite",this.get_u16("lastbite")+1);
		
		if(this.getBrain().isActive()){
			if(b !is null && this.getDistanceTo(b) <24.0f){
				float aimangle=0;
				if(this.get_u8(state_property) == MODE_TARGET )
				{
					Vec2f vel;
					if(b !is null)
					{
						vel = b.getPosition()-this.getPosition();
					}
					else vel = Vec2f(1,0);
					
					vel.Normalize();
					if (b !is null)
					{
						if (b.getTeamNum() != this.getTeamNum())
						{
							if (lastbite > bitefreq){
								f32 power = this.get_f32("bite damage");
								this.server_Hit(b,b.getPosition(),vel,power,Hitters::bite, true);
								this.set_u16("lastbite",0);
								if(this.hasTag(bite_tag)){
									this.Untag(bite_tag);
									this.Sync(bite_tag,true);
								}
							} else if (lastbite > bitefreq-this.get_u16("bite charge")){
								if(!this.hasTag(bite_tag)){
									this.Tag(bite_tag);
									this.Sync(bite_tag,true);
								}
							}
						}
					} else {
						if(this.hasTag(bite_tag)){
							this.Untag(bite_tag);
							this.Sync(bite_tag,true);
						}
					}
				} else {
					if(this.hasTag(bite_tag)){
						this.Untag(bite_tag);
						this.Sync(bite_tag,true);
					}
				}
			}
		}
		if(this.getPlayer() !is null)if(this.isKeyPressed(key_action1)){
			if (lastbite > bitefreq){
				CBlob@[] blobsInRadius;	   
				if (this.getMap().getBlobsInRadius(this.getPosition(), 16.0f, @blobsInRadius)) 
				{
					for (uint i = 0; i < blobsInRadius.length; i++)
					{
						CBlob@ b = blobsInRadius[i];
						if(b.getTeamNum() != this.getTeamNum())
						{
							f32 power = this.get_f32("bite damage");
							this.server_Hit(b,b.getPosition(),Vec2f(0,0),power,Hitters::bite, true);
							this.set_u16("lastbite",0);
							if(this.hasTag(bite_tag)){
								this.Untag(bite_tag);
								this.Sync(bite_tag,true);
							}
						}
					}
				}
			} else if (lastbite > bitefreq-this.get_u16("bite charge")){
				if(!this.hasTag(bite_tag)){
					this.Tag(bite_tag);
					this.Sync(bite_tag,true);
				}
			}
		}
	} else {
		if(this.hasTag(bite_tag)){
			this.Untag(bite_tag);
			this.Sync(bite_tag,true);
		}
	}
	
	if(this.getBrain().isActive()){
		f32 x = this.getVelocity().x;
		if (Maths::Abs(x) > 1.0f)
		{
			this.SetFacingLeft( x < 0 );
		}
		else
		{
			if (this.isKeyPressed(key_left)) {
				this.SetFacingLeft( true );
			}
			if (this.isKeyPressed(key_right)) {
				this.SetFacingLeft( false );
			}
		}
	}
	if(this.getPlayer() !is null){
		if(this.get_u8("core") == 0)this.set_u8("core",3);
		if (this.isKeyPressed(key_left)) {
			this.SetFacingLeft( true );
			this.AddForce(Vec2f(-15,0));
		} else 
		if (this.isKeyPressed(key_right)) {
			this.SetFacingLeft( false );
			this.AddForce(Vec2f(15,0));
		}
		if(this.isKeyPressed(key_up)){
			if(this.getName() != "gold_golem"){if(this.isOnGround())this.AddForce(Vec2f(0,-200));}
			else this.AddForce(Vec2f(0,-8));
		}
	}
	
}

void MadAt( CBlob@ this, CBlob@ hitterBlob )
{
	const u16 damageOwnerId = (hitterBlob.getDamageOwnerPlayer() !is null && hitterBlob.getDamageOwnerPlayer().getBlob() !is null) ? 
		hitterBlob.getDamageOwnerPlayer().getBlob().getNetworkID() : 0;
	this.set_u8(state_property, MODE_TARGET);
	if (hitterBlob.hasTag("player"))
		this.set_netid(target_property, hitterBlob.getNetworkID() );
	else
	if (damageOwnerId > 0) {
		this.set_netid(target_property, damageOwnerId );
	}
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{		
	if (damage>this.getHealth() && this.getHealth()>0)
	{
		if (hitterBlob.hasTag("player"))
		{
			CPlayer@ player = hitterBlob.getPlayer();
		} else
		if(hitterBlob.getDamageOwnerPlayer() !is null)
		{
			CPlayer@ player = hitterBlob.getDamageOwnerPlayer();
		}
	}
	Sound::Play("rock_hit1.ogg", this.getPosition());
	MadAt( this, hitterBlob );
	return damage;
}														

#include "Hitters.as";

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	if (blob.hasTag("dead"))
		return false;
	if (this.getTeamNum() == blob.getTeamNum() || blob.getTeamNum() == -1 || blob.getTeamNum() == 255) return false;
	return true;
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1 )
{
	if (this.getHealth() <= 0.0) return; // dead
	if (blob is null)
		return;

	const u16 friendId = this.get_netid(friend_property);
	CBlob@ friend = getBlobByNetworkID(friendId);
	if (blob.getTeamNum() != this.getTeamNum() && blob.hasTag("flesh") && !blob.hasTag("dead"))
	{
		MadAt( this, blob );
	}
}