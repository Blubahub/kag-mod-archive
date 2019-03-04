
#include "Hitters.as";
#include "Fabrics.as";
#include "MakeMat.as";

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
	AddIconToken("$knife_icon$", "knife_icon.png", Vec2f(24, 24), 0);
	
	AddIconToken("$sword_icon$", "sword_icon.png", Vec2f(24, 24), 0);
	AddIconToken("$short_sword_icon$", "short_sword_icon.png", Vec2f(24, 24), 0);
	AddIconToken("$shield_icon$", "shield_icon.png", Vec2f(24, 24), 0);
	
	
	AddIconToken("$breast_plate_icon$", "metal_shirt_icon.png", Vec2f(24, 24), 0);
	AddIconToken("$greaves_icon$", "metal_pants_icon.png", Vec2f(24, 24), 0);
	AddIconToken("$helmet_icon$", "metal_helmet_icon.png", Vec2f(24, 24), 0);
	
	
	AddIconToken("$stub_hook_icon$", "StubHook.png", Vec2f(7, 12), 0);
	AddIconToken("$flintlock_icon$", "flintlock_icon.png", Vec2f(24, 24), 0);
	AddIconToken("$helm_icon$", "metal_helm_icon.png", Vec2f(24, 24), 0);
	
	AddIconToken("$machine_parts_icon$", "MachineParts.png", Vec2f(16, 16), 1);
	
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
			CGridMenu@ menu = CreateGridMenu(getDriver().getScreenCenterPos() + Vec2f(0.0f, 0.0f), this, Vec2f(3, 5), "\nForging\n-\nNot all items can be turned into equipment.\n-\nOnce you have selected an item, stay by the\nforge to finish the product.");
			if (menu !is null)
			{
				CAttachment@ attach = this.getAttachments();
				CBlob @attachedBlob = attach.getAttachedBlob("SMITH");
				if(attachedBlob !is null){
					///////Row 1
					{
						CBitStream params;
						params.write_u8(0);
						CGridButton @but = menu.AddButton("$pick_icon$", "Pick", this.getCommandID("set_smith"),params);
						if(this.get_s8("smith") == 0)but.SetSelected(1);
						but.SetEnabled(false);
						if(isValidFabric(attachedBlob.getName()))but.SetEnabled(true);
					}
					{
						CBitStream params;
						params.write_u8(1);
						CGridButton @but = menu.AddButton("$axe_icon$", "Axe", this.getCommandID("set_smith"),params);
						if(this.get_s8("smith") == 1)but.SetSelected(1);
						but.SetEnabled(false);
						if(isValidFabric(attachedBlob.getName()))but.SetEnabled(true);
					}
					{
						CBitStream params;
						params.write_u8(9);
						CGridButton @but = menu.AddButton("$knife_icon$", "Knife", this.getCommandID("set_smith"),params);
						if(this.get_s8("smith") == 9)but.SetSelected(1);
						but.SetEnabled(false);
						if(isValidFabric(attachedBlob.getName()))but.SetEnabled(true);
					}
					///////Row 2
					{
						CBitStream params;
						params.write_u8(6);
						CGridButton @but = menu.AddButton("$sword_icon$", "Sword", this.getCommandID("set_smith"),params);
						if(this.get_s8("smith") == 6)but.SetSelected(1);
						but.SetEnabled(false);
						if(isValidFabric(attachedBlob.getName()))but.SetEnabled(true);
					}
					{
						CBitStream params;
						params.write_u8(10);
						CGridButton @but = menu.AddButton("$short_sword_icon$", "Short Sword", this.getCommandID("set_smith"),params);
						if(this.get_s8("smith") == 10)but.SetSelected(1);
						but.SetEnabled(false);
						if(isValidFabric(attachedBlob.getName()))but.SetEnabled(true);
					}
					{
						CBitStream params;
						params.write_u8(2);
						CGridButton @but = menu.AddButton("$shield_icon$", "Shield", this.getCommandID("set_smith"),params);
						if(this.get_s8("smith") == 2)but.SetSelected(1);
						but.SetEnabled(false);
						if(attachedBlob.getName() == "metal_bar")but.SetEnabled(true);
					}
					///////Row 3
					{
						CBitStream params;
						params.write_u8(4);
						CGridButton @but = menu.AddButton("$breast_plate_icon$", "Breastplate", this.getCommandID("set_smith"),params);
						if(this.get_s8("smith") == 4)but.SetSelected(1);
						but.SetEnabled(false);
						if(attachedBlob.getName() == "metal_bar")but.SetEnabled(true);
						if(attachedBlob.getName() == "duram_bar")but.SetEnabled(true);
					}
					{
						CBitStream params;
						params.write_u8(5);
						CGridButton @but = menu.AddButton("$greaves_icon$", "Greaves", this.getCommandID("set_smith"),params);
						if(this.get_s8("smith") == 5)but.SetSelected(1);
						but.SetEnabled(false);
						if(attachedBlob.getName() == "metal_bar")but.SetEnabled(true);
						if(attachedBlob.getName() == "duram_bar")but.SetEnabled(true);
					}
					{
						CBitStream params;
						params.write_u8(8);
						CGridButton @but = menu.AddButton("$helmet_icon$", "Full Helmet", this.getCommandID("set_smith"),params);
						if(this.get_s8("smith") == 8)but.SetSelected(1);
						but.SetEnabled(false);
						if(attachedBlob.getName() == "metal_bar")but.SetEnabled(true);
					}
					///////Row 4
					{
						CBitStream params;
						params.write_u8(3);
						CGridButton @but = menu.AddButton("$stub_hook_icon$", "Hook", this.getCommandID("set_smith"),params);
						if(this.get_s8("smith") == 3)but.SetSelected(1);
						but.SetEnabled(false);
						if(attachedBlob.getName() == "metal_bar")but.SetEnabled(true);
					}
					{
						CBitStream params;
						params.write_u8(11);
						CGridButton @but = menu.AddButton("$flintlock_icon$", "Flintlock", this.getCommandID("set_smith"),params);
						if(this.get_s8("smith") == 11)but.SetSelected(1);
						but.SetEnabled(false);
						if(attachedBlob.getName() == "metal_bar")but.SetEnabled(true);
					}
					{
						CBitStream params;
						params.write_u8(7);
						CGridButton @but = menu.AddButton("$helm_icon$", "Half Helm", this.getCommandID("set_smith"),params);
						if(this.get_s8("smith") == 7)but.SetSelected(1);
						but.SetEnabled(false);
						if(attachedBlob.getName() == "metal_bar")but.SetEnabled(true);
					}
					
					///////Row 5
					{
						CBitStream params;
						params.write_u8(12);
						CGridButton @but = menu.AddButton("$machine_parts_icon$", "Machine Part", this.getCommandID("set_smith"),params);
						if(this.get_s8("smith") == 12)but.SetSelected(1);
						but.SetEnabled(false);
						if(attachedBlob.getName() == "metal_bar")but.SetEnabled(true);
						if(attachedBlob.getName() == "duram_bar")but.SetEnabled(true);
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
						
						CBlob @result = null;
						
						string result_name = "";
						
						int MaterialID = fabricIDFromBlobName(name);
						
						if(MaterialID == FabricID::Gold && attachedBlob.hasTag("light_infused"))MaterialID = FabricID::FloatingGold;
						
						if(ID == 0)result_name = "pick";
						if(ID == 1)result_name = "axe";
						if(ID == 2)@result = server_CreateBlob("shield",XORRandom(7),this.getPosition()+Vec2f(0,-16));
						if(ID == 3)result_name = "stub_hook";
						if(ID == 4){
							if(name == "metal_bar")result_name = "metal_shirt";
							if(name == "duram_bar")result_name = "duram_shirt";
						}
						if(ID == 5){
							if(name == "metal_bar")result_name = "metal_pants";
							if(name == "duram_bar")result_name = "duram_pants";
						}
						if(ID == 6)result_name = "sword";
						if(ID == 7){
							if(name == "metal_bar")result_name = "metal_helm";
							//if(name == "duram_bar")result_name = "duram_helm";
						}
						if(ID == 8){
							if(name == "metal_bar")result_name = "metal_helmet";
							//if(name == "duram_bar")result_name = "duram_helmet";
						}
						if(ID == 9)result_name = "knife";
						if(ID == 10)result_name = "short_sword";
						if(ID == 11){
							if(attachedBlob.getName() == "metal_bar")result_name = "flintlock";
						}
						if(ID == 12){
							if(attachedBlob.getName() == "metal_bar")MakeMat(this, worldPoint, "mat_machine_parts", 1);
							if(attachedBlob.getName() == "duram_bar")MakeMat(this, worldPoint, "mat_machine_parts", 2);
						}
						
						if(result is null){
							@result = server_CreateBlob(result_name,-1,this.getPosition()+Vec2f(0,-16));
						}
						
						if(result !is null){
							if(MaterialID != 0)result.set_u8("fabric",MaterialID);
							
							if(attachedBlob.hasTag("light_infused"))result.Tag("light_infused");
						}
						
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