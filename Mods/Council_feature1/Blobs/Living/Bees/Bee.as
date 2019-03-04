
//script for a cute... SWARM OF BEES, OH MY ARGH--

//And thus, the creator Oli declared bees shall inhabit the trees, the sky, and basically every where except water.


#include "Hitters.as"

void onInit(CSprite@ this)
{
	this.ReloadSprites(0, 0); //random colour
	
	this.SetZ(100);
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	
	
	
	if(blob.get_u16("Bee_Amount") != blob.get_u16("Bee_Amount_Sprite")){
		
		for(int i = 0; i < (blob.get_u16("Bee_Amount")+3)/5+1; i++){
			string name = "bee"+i;
			
			if(this.getSpriteLayer(name) is null){
				CSpriteLayer@ bee = this.addSpriteLayer(name, "Bee.png" , 3, 3,0,0);

				if (bee !is null)
				{
					Animation@ normal = bee.addAnimation("normal", 1, true);
					normal.AddFrame(0);
					normal.AddFrame(1);
					Animation@ angry = bee.addAnimation("angry", 1, true);
					angry.AddFrame(2);
					angry.AddFrame(3);
					//bee.SetOffset(Vec2f(-1.0f, -5.0f));
					bee.SetAnimation("normal");
				}
			}
		}
		
		blob.set_u16("Bee_Amount_Sprite",blob.get_u16("Bee_Amount"));
	}
	
	{
	
		for(int i = 0; i < (blob.get_u16("Bee_Amount")+3)/5+1; i++){
			string name = "bee"+i;
			
			CSpriteLayer@ bee = this.getSpriteLayer(name);

			if (bee !is null)
			{
				Vec2f origin = bee.getOffset();
				
				int size = (i+1)*3;
				
				int RandX = XORRandom(3)-1;
				int RandY = XORRandom(3)-1;
				if(origin.x < -size)RandX = 1;
				if(origin.x > size)RandX = -1;
				if(origin.y < -size)RandY = 1;
				if(origin.y > size/3)RandY = -1;
				
				if(blob.hasTag("angry") && bee.isAnimation("normal"))bee.SetAnimation("angry");
				if(!blob.hasTag("angry") && bee.isAnimation("angry"))bee.SetAnimation("normal");
				
				bee.SetOffset(origin+Vec2f(RandX, RandY));
			}
		}
		
		for(int i = 0; i < (blob.get_u16("Bee_Amount")+3)/5+1+5; i++)if(i >= (blob.get_u16("Bee_Amount")+3)/5+1){
			string name = "bee"+i;
			
			this.RemoveSpriteLayer(name);
		}
	
	}
}

//blob

void onInit(CBlob@ this)
{
	this.Tag("flesh");
	//this.Tag("builder always hit");

	this.getCurrentScript().tickFrequency = 1;
	
	this.set_u16("Bee_Amount",2);
	this.set_u16("Bee_Amount_Sprite",0);
	
	this.getShape().SetGravityScale(0.2);
	
	this.getShape().getConsts().mapCollisions = false;
}

void onTick(CBlob@ this)
{
	CBlob @blob = null;
	int dis = 160;
	
	if(this.hasTag("angry")){
		CBlob@[] blobs;
			
		getBlobsByTag("player", blobs);
		
		for (u32 k = 0; k < blobs.length; k++)
		{
			CBlob@ b = blobs[k];
			if(this.getDistanceTo(b) < dis || dis == -1){
				dis = this.getDistanceTo(b);
				@blob = b;
			}
		}
	}
	
	if(blob !is null){
		Vec2f direction = blob.getPosition()-this.getPosition();
		direction.Normalize();
		
		this.AddForce(direction*0.2f);
	} else {
		if(getNet().isServer())if(XORRandom(100) == 0){
			this.Untag("angry");
			this.Sync("angry",true);
		}
	}
	
	if(getNet().isServer())
	if(this.hasTag("angry"))
	{
	
		CBlob@[] blobs;
			
		getBlobsByName("bee", blobs);
		
		for (u32 k = 0; k < blobs.length; k++)
		{
			CBlob@ b = blobs[k];
			if(b !is this && this.getDistanceTo(b) < 16){
				if(!this.hasTag("merge")){
					b.Tag("merge");
					this.set_u16("Bee_Amount",this.get_u16("Bee_Amount")+b.get_u16("Bee_Amount"));
					this.Sync("Bee_Amount",true);
					b.server_Die();
				}
			}
		}
	
	}
	
	if(XORRandom(100) == 0){
		this.AddForce(Vec2f(XORRandom(4)-2, 0));
	}
	
	//this.set_u16("Bee_Amount",this.get_u16("Bee_Amount")+1);
	
	Vec2f surfacepos;
	if(getMap().rayCastSolid(this.getPosition(), this.getPosition()+Vec2f(0,16), surfacepos))this.AddForce(Vec2f(0, -(0.1f+(XORRandom(3)*0.1f))));
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if(getNet().isServer()){
		
		int BeeHurt = 1;
		
		if(customData == Hitters::arrow)BeeHurt = 0;
		
		if(customData == Hitters::water)BeeHurt = 10;
		if(customData == Hitters::water_stun)BeeHurt = 20;
		if(customData == Hitters::water_stun_force)BeeHurt = 30;
		
		if(customData == Hitters::explosion)BeeHurt = 100;
		if(customData == Hitters::keg)BeeHurt = 100;
		if(customData == Hitters::mine)BeeHurt = 100;
		if(customData == Hitters::mine_special)BeeHurt = 100;
		
		if(this.get_u16("Bee_Amount")-BeeHurt <= 0)this.server_Die();
		else {
			this.set_u16("Bee_Amount",this.get_u16("Bee_Amount")-BeeHurt);
			this.Sync("Bee_Amount",true);
		}
		this.Tag("angry");
		this.Sync("angry",true);
	}
	
	return 0;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if(getNet().isServer()){
		if(blob !is null)
		if(blob.hasTag("player"))
		if(XORRandom(100) < this.get_u16("Bee_Amount") || this.hasTag("angry")){
			if(XORRandom(2) == 0){
				this.Tag("angry");
				this.Sync("angry",true);
			}
			
			int BeesHit = this.get_u16("Bee_Amount")/40+1;
			
			if(BeesHit > 4)BeesHit = 4;
			
			this.server_Hit(blob, point1, Vec2f(0,0), 0.125f*(BeesHit*1.0f), Hitters::suddengib,true);
			
			if(this.get_u16("Bee_Amount")-BeesHit <= 0)this.server_Die();
			else {
				this.set_u16("Bee_Amount",this.get_u16("Bee_Amount")-BeesHit);
				this.Sync("Bee_Amount",true);
			}
		}
	}
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob ){

	return false; //no

}