
void onInit(CBlob @ this)
{
	this.server_setTeamNum(-1);
	this.Tag("medium weight");
	this.set_u16("partner",0);
}

void onTick(CBlob @ this)
{
	if(!this.hasTag("madePartner")){
		if(getNet().isServer()){
			CBlob@ partner = getBlobByNetworkID(this.get_u16("partner"));

			if(partner is null){
				CBlob@ newpartner = server_CreateBlob("grapple", this.getTeamNum(), this.getPosition());
				newpartner.set_u16("partner",this.getNetworkID());
				this.set_u16("partner",newpartner.getNetworkID());
				this.Tag("madePartner");
				newpartner.Tag("madePartner");
				this.Tag("RopeMaster");
			}
		}
	}
	
	CBlob@ partner = getBlobByNetworkID(this.get_u16("partner"));
	if (partner !is null)
	{
		
		CBlob @objectA = this;
		CBlob @objectB = partner;
		
		Vec2f offsetA = this.getPosition();
		Vec2f offsetB = partner.getPosition();
		
		if (this.isAttached()){
			AttachmentPoint@[] aps;
			if (this.getAttachmentPoints(@aps))
			{
				for(uint i = 0; i < aps.length; i++)
				{
					AttachmentPoint@ ap = aps[i];
					if(ap.getOccupied() !is null){
						@objectA = ap.getOccupied();
						CAttachment@ Attachs = objectA.getAttachments();
						if(Attachs !is null){
							AttachmentPoint@ att = Attachs.getAttachmentWithBlob(this);
							if(att !is null){
								offsetA = att.getPosition();
							}
						}
					}
				}
			}
		}
		
		if (partner.isAttached()){
			AttachmentPoint@[] aps;
			if (partner.getAttachmentPoints(@aps))
			{
				for(uint i = 0; i < aps.length; i++)
				{
					AttachmentPoint@ ap = aps[i];
					if(ap.getOccupied() !is null){
						@objectB = ap.getOccupied();
						CAttachment@ Attachs = objectB.getAttachments();
						if(Attachs !is null){
							AttachmentPoint@ att = Attachs.getAttachmentWithBlob(this);
							if(att !is null){
								offsetB = att.getPosition();
							}
						}
					}
				}
			}
		}
		
		f32 grapple_length = 32;
		f32 grapple_accel_limit = 1.5;
		f32 grapple_force = 2;
		f32 grapple_slack = 16;
		f32 grapple_force_limit = objectA.getMass() * grapple_accel_limit;

		//get the force
		Vec2f force;
		f32 dist;
		
		force = (offsetB) - (offsetA);
		
		dist = force.Normalize();
		f32 offdist = dist - grapple_length;
		if (offdist > 0)
		{
			force *= Maths::Min(grapple_force_limit, Maths::Max(0.0f, offdist + grapple_slack) * grapple_force);
		}
		else
		{
			force.Set(0, 0);
		}
	
		float mod = 1;// - Maths::Min(objectB.getMass(), objectA.getMass()) / Maths::Max(objectB.getMass(), objectA.getMass());
		Vec2f resForce = Vec2f(Maths::Max(-1000, Maths::Min(force.x * mod, 1000)), Maths::Max(-1000, Maths::Min(force.y * mod, 1000)));   

		objectA.AddForceAtPosition(resForce, offsetA);
	}
	
}

void onThisAddToInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	if (inventoryBlob is null) return;

	CInventory@ inv = inventoryBlob.getInventory();

	if (inv is null) return;

	this.doTickScripts = true;
	
	inv.doTickScripts = true;
}












void onInit(CSprite@ this)
{
	string texname = "Grapple.png";

	this.RemoveSpriteLayer("rope");
	CSpriteLayer@ rope = this.addSpriteLayer("rope", texname , 16, 16, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (rope !is null)
	{
		Animation@ anim = rope.addAnimation("default", 0, false);
		anim.AddFrame(81);
		rope.SetRelativeZ(-20.0f);
		rope.SetVisible(false);
	}

}


void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	CSpriteLayer@ rope = this.getSpriteLayer("rope");

	CBlob@ partner = getBlobByNetworkID(blob.get_u16("partner"));
	
	bool visible = (partner !is null && blob.hasTag("RopeMaster"));

	rope.SetVisible(visible);

	if (!visible)
	{
		return;
	}

	Vec2f off = partner.getPosition() - blob.getPosition();

	f32 ropelen = Maths::Max(0.1f, off.Length() / 16.0f);
	if (ropelen > 200.0f)
	{
		rope.SetVisible(false);
		return;
	}

	rope.ResetTransform();
	rope.ScaleBy(Vec2f(ropelen, 1.0f));

	rope.TranslateBy(Vec2f(ropelen * 8.0f, 0.0f));

	rope.RotateBy(-off.Angle() , Vec2f());

	//GUI::DrawLine(blob.getPosition(), archer.grapple_pos, SColor(255,255,255,255));
}


