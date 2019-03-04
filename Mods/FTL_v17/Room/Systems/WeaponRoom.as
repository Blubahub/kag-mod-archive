
void onInit(CBlob@ this)
{
	this.addCommandID("vehicle getout");
	
	this.addCommandID("fire_weapon");
	this.addCommandID("auto_fire_weapon");
	
	this.Tag("builder always hit");
	
	this.set_Vec2f("AI_aim",Vec2f(0,0));
	
	if(XORRandom(2) == 0)this.Tag("AI_smart");
	
	this.Untag("auto_fire");
}

void onTick(CBlob@ this)
{
	AttachmentPoint@[] aps;
	if (this.getAttachmentPoints(@aps))
	{
		for (uint i = 0; i < aps.length; i++)
		{
			AttachmentPoint@ ap = aps[i];
			CBlob@ blob = ap.getOccupied();
			
			ap.offsetZ = 10.0f;

			if (blob !is null && ap.socket)
			{
				// GET OUT
				if (blob.isMyPlayer() && ap.isKeyJustPressed(key_up))
				{
					CBitStream params;
					params.write_u16(blob.getNetworkID());
					this.SendCommand(this.getCommandID("vehicle getout"), params);
					return;
				}
				
				//Fire
				if (blob.isMyPlayer() && ap.isKeyPressed(key_action1))
				{
					this.SendCommand(this.getCommandID("fire_weapon"));
					return;
				}
				
				//Fire
				if (blob.isMyPlayer() && ap.isKeyPressed(key_action2))
				{
					this.SendCommand(this.getCommandID("auto_fire_weapon"));
					return;
				}
				
				if(!this.hasTag("auto_fire"))this.set_Vec2f("aim",blob.getAimPos());
			}
		}
	}
	
	if(getNet().isServer()){
		if(this.hasTag("auto_fire"))fireWeapon(this);
		if(this.getTeamNum() != 0)if(XORRandom(10) == 0)fireWeapon(this);
	}
	
	if(this.getTeamNum() != 0){
		
		if(!this.hasTag("AI_smart")){
			if(this.get_Vec2f("AI_aim").x > -100)this.set_Vec2f("AI_aim",this.get_Vec2f("AI_aim")+Vec2f(-XORRandom(10),0));
			if(this.get_Vec2f("AI_aim").x < 100)this.set_Vec2f("AI_aim",this.get_Vec2f("AI_aim")+Vec2f(XORRandom(10),0));
			
			if(this.get_Vec2f("AI_aim").y > -50)this.set_Vec2f("AI_aim",this.get_Vec2f("AI_aim")+Vec2f(0,-XORRandom(10)));
			if(this.get_Vec2f("AI_aim").y < 50)this.set_Vec2f("AI_aim",this.get_Vec2f("AI_aim")+Vec2f(0,XORRandom(10)));
			
			this.set_Vec2f("aim",this.getPosition()+Vec2f(-200,0)+this.get_Vec2f("AI_aim"));
		} else {
		
			CBlob@[] blobs;
	
			getBlobsByName("turret", blobs);
			getBlobsByTag("room", blobs);

			int FoundTarget = 0;
			
			while (FoundTarget >= 0 && FoundTarget < 100)
			{
				CBlob@ blob = blobs[XORRandom(blobs.length)];
				if(blob.getTeamNum() != this.getTeamNum()){
					this.set_Vec2f("aim",blob.getPosition());
					break;
				}
				FoundTarget++;
			}
		
		}
	}
}

void fireWeapon(CBlob@ this){
	CBlob@[] turrets;
	
	getBlobsByName("turret", turrets);
	
	for (u32 l = 0; l < turrets.length; l++)
	{
		
		CBlob @turret = turrets[l];
		
		CBlob@[] blobs;
	
		getBlobsByName("weapon_room", blobs);

		int Best = -1;
		f32 bestLength = 160.0f;
		
		for (u32 k = 0; k < blobs.length; k++)
		{
			CBlob@ blob = blobs[k];
			Vec2f dir = turret.getPosition() - blob.getPosition();
			f32 length = dir.Length();
			
			if(turret.getTeamNum() == blob.getTeamNum())
			if(length < bestLength){
				bestLength = length;
				Best = k;
			}
		}
		
		if(Best >= 0){
			CBlob@ blob = blobs[Best];
			if(blob is this){
				turret.Tag("firing");
			}
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	bool isServer = getNet().isServer();

	if (isServer && cmd == this.getCommandID("vehicle getout"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());

		if (caller !is null)
		{
			this.server_DetachFrom(caller);
		}
	}
	
	if (cmd == this.getCommandID("fire_weapon"))
	{
		fireWeapon(this);
		this.Untag("auto_fire");
		if(getNet().isServer())this.Sync("auto_fire",true);
	}
	
	if (cmd == this.getCommandID("auto_fire_weapon"))
	{
		this.Tag("auto_fire");
		if(getNet().isServer())this.Sync("auto_fire",true);
	}
}


void onInit(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	CSpriteLayer@ arm_rest = this.addSpriteLayer("arm_rest", this.getFilename() , 40, 16, blob.getTeamNum(), blob.getSkinNum());

	if (arm_rest !is null)
	{
		Animation@ anim = arm_rest.addAnimation("default", 0, false);
		anim.AddFrame(1);
		//arm_rest.SetOffset(Vec2f(3.0f, -7.0f));
		arm_rest.SetRelativeZ(100);
	}
}


void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	if(getLocalPlayer() is null)return;
	if(getLocalPlayer().getBlob() is null)return;
	if(!getLocalPlayer().getBlob().isAttachedToPoint("SHOOTER"))return;
	if(getLocalPlayer().getBlob().getTeamNum() != blob.getTeamNum())return;
	
	Vec2f Aim = getDriver().getScreenPosFromWorldPos(blob.get_Vec2f("aim"));
	
	if(!blob.hasTag("auto_fire"))GUI::DrawIcon("Target.png", 0, Vec2f(16,16), Aim-Vec2f(16,16));
	else GUI::DrawIcon("AutoTarget.png", 0, Vec2f(16,16), Aim-Vec2f(16,16));
	
}
