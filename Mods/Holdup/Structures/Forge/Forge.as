
#include "Hitters.as";

void onInit(CBlob @ this)
{
	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.addCommandID("open_menu");
	this.addCommandID("set_smith");
	this.addCommandID("place_item");

	AddIconToken("$pick_icon$", "pick_icon.png", Vec2f(24, 24), 0);
	AddIconToken("$axe_icon$", "axe_icon.png", Vec2f(24, 24), 0);
	AddIconToken("$shield_icon$", "Shield.png", Vec2f(16, 16), 0);
	AddIconToken("$stub_hook_icon$", "StubHook.png", Vec2f(7, 12), 0);
	
	this.set_s8("smith",-1);
	
	this.set_u8("progress",0);
	
	if(getNet().isServer())this.server_setTeamNum(-1);
	
	this.Tag("heavy weight");
	
	this.getCurrentScript().tickFrequency = 30;
}

void onTick(CBlob@ this)
{
	if(this.get_s8("smith") > -1){
		bool workers = false;
		CBlob@[] blobsInRadius;	
		if (getMap().getBlobsInRadius(this.getPosition(), 12.0f, @blobsInRadius))
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(b.getName() == "humanoid"){
					workers = true;
				}
			}
		}
		if(workers)this.server_Hit(this, this.getPosition(), Vec2f(0,0), 1.0f, Hitters::builder, true);
	}
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(caller.getCarriedBlob() !is this){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		
		if(this.isAttachedToPoint("SMITH")){caller.CreateGenericButton(15, Vec2f(0,0), this, this.getCommandID("open_menu"), "Smith", params);}
		
		if(this.isAttachedToPoint("SMITH")){
			caller.CreateGenericButton(16, Vec2f(0,-8), this, this.getCommandID("place_item"), "Remove Item", params);
		} else {
			caller.CreateGenericButton(19, Vec2f(0,0), this, this.getCommandID("place_item"), "Place Item", params);
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("open_menu")){
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if(caller !is null)
		if(caller.getPlayer() is getLocalPlayer())
		{
			CGridMenu@ menu = CreateGridMenu(getDriver().getScreenCenterPos() + Vec2f(0.0f, 0.0f), this, Vec2f(3, 3), "\nForging\n-\nNot all items can be turned into equipment.\n-\nOnce you have selected an item, stay by the\nforge to finish the product.");
			if (menu !is null)
			{
				CAttachment@ attach = this.getAttachments();
				CBlob @attachedBlob = attach.getAttachedBlob("SMITH");
				if(attachedBlob !is null){
					{
						CBitStream params;
						params.write_u8(0);
						CGridButton @but = menu.AddButton("$pick_icon$", "Pick", this.getCommandID("set_smith"),params);
						if(this.get_s8("smith") == 0)but.SetSelected(1);
						but.SetEnabled(false);
						if(attachedBlob.getName() == "metal_bar")but.SetEnabled(true);
					}
					{
						CBitStream params;
						params.write_u8(1);
						CGridButton @but = menu.AddButton("$axe_icon$", "Axe", this.getCommandID("set_smith"),params);
						if(this.get_s8("smith") == 1)but.SetSelected(1);
						but.SetEnabled(false);
						if(attachedBlob.getName() == "metal_bar")but.SetEnabled(true);
					}
					{
						CBitStream params;
						params.write_u8(2);
						CGridButton @but = menu.AddButton("$shield_icon$", "Shield", this.getCommandID("set_smith"),params);
						if(this.get_s8("smith") == 2)but.SetSelected(1);
						but.SetEnabled(false);
						if(attachedBlob.getName() == "metal_bar")but.SetEnabled(true);
					}
					{
						CBitStream params;
						params.write_u8(3);
						CGridButton @but = menu.AddButton("$stub_hook_icon$", "Hook", this.getCommandID("set_smith"),params);
						if(this.get_s8("smith") == 3)but.SetSelected(1);
						but.SetEnabled(false);
						if(attachedBlob.getName() == "metal_bar")but.SetEnabled(true);
					}
				}
			}
		}
	}
	
	if (cmd == this.getCommandID("set_smith")){
		int ID = params.read_u8();
		this.set_s8("smith",ID);
		this.set_u8("progress",0);
		if(getNet().isServer()){
			this.Sync("smith",true);
			this.Sync("progress",true);
		}
	}
	
	if (cmd == this.getCommandID("place_item"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null)
		{
			if(getNet().isServer()){
				
				if(this.isAttachedToPoint("SMITH")){
					CAttachment@ attach = this.getAttachments();
					if(attach.getAttachedBlob("SMITH") !is null){
						CBlob @attachedBlob = attach.getAttachedBlob("SMITH");
						this.server_DetachFrom(attachedBlob);
						this.set_s8("smith",-1);
						this.set_u8("progress",0);
						if(getNet().isServer()){
							this.Sync("smith",true);
							this.Sync("progress",true);
						}
					}
				} else {
				
					CBlob@ hold = caller.getCarriedBlob();
					if(hold !is null){
						caller.DropCarried();
						this.server_AttachTo(hold, "SMITH");
						this.set_s8("smith",-1);
						this.set_u8("progress",0);
						if(getNet().isServer()){
							this.Sync("smith",true);
							this.Sync("progress",true);
						}
					}
				
				}
			}
		}
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if(hitterBlob is this)
	if(customData == Hitters::builder){
		if(this.get_s8("smith") > -1){
			this.set_u8("progress",this.get_u8("progress")+1);
			if(this.get_u8("progress") > 5){
				this.set_u8("progress",0);
				
				if(getNet().isServer()){
					CAttachment@ attach = this.getAttachments();
					CBlob @attachedBlob = attach.getAttachedBlob("SMITH");
					if(attachedBlob !is null){
						string name = attachedBlob.getName();
						
						int ID = this.get_s8("smith");
						
						if(ID == 0)server_CreateBlob("pick",-1,this.getPosition()+Vec2f(0,-16));
						if(ID == 1)server_CreateBlob("axe",-1,this.getPosition()+Vec2f(0,-16));
						if(ID == 2)server_CreateBlob("shield",XORRandom(7),this.getPosition()+Vec2f(0,-16));
						if(ID == 3)server_CreateBlob("stub_hook",-1,this.getPosition()+Vec2f(0,-16));
						
						attachedBlob.server_Die();
						
						this.set_s8("smith",-1);
					}
				}
			}
			if(getNet().isServer()){
				this.Sync("progress",true);
				this.Sync("smith",true);
			}
		}
		for(int i = 0; i < 10;i++){
			if (XORRandom(100) < 50) ParticlePixel(worldPoint, getRandomVelocity(90, 4, 45), SColor(255, 255, 50 + XORRandom(100), 0), true, 10 + XORRandom(20));
			else  makeFireParticle(worldPoint, "SmallFire" + (XORRandom(2) + 1));
		}
		this.getSprite().PlaySound("dig_stone2.ogg");
		return 0;
	}
	return damage;
}

void makeFireParticle(Vec2f worldPoint, const string filename = "SmallSmoke")
{
	Vec2f random = Vec2f(XORRandom(128) - 64, XORRandom(128) - 64) * 0.015625f * 4;
	ParticleAnimated(CFileMatcher(filename).getFirst(), worldPoint + random, getRandomVelocity(90, 0.50f, 45), 0, 1.0f, 2 + XORRandom(3), ((XORRandom(200) - 100) / 800.00f), true);
}