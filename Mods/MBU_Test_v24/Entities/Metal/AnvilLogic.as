
#include "Hitters.as";

void onInit(CBlob @ this)
{
	this.addCommandID("open_menu");
	this.addCommandID("set_smith");
	this.addCommandID("place_item");

	AddIconToken("$pickhead_icon$", "PickHead.png", Vec2f(13, 4), 0);
	AddIconToken("$axehead_icon$", "AxeHead.png", Vec2f(6, 6), 0);
	AddIconToken("$shield_icon$", "Shield.png", Vec2f(16, 16), 0);
	AddIconToken("$lockset_icon$", "SimpleLockSet.png", Vec2f(16, 16), 0);
	AddIconToken("$lock_icon$", "SimpleLock.png", Vec2f(7, 8), 0);
	AddIconToken("$anvil_icon$", "Anvil.png", Vec2f(18, 10), 0);
	AddIconToken("$stub_hook_icon$", "StubHook.png", Vec2f(7, 12), 0);
	AddIconToken("$metal_door_icon$", "MetalDoor.png", Vec2f(16, 16), 0);
	AddIconToken("$forge_bar_icon$", "ForgeBar.png", Vec2f(24, 24), 0);
	
	this.set_s8("smith",-1);
	
	this.set_u8("progress",0);
	
	if(getNet().isServer())this.server_setTeamNum(-1);
	
	this.Tag("heavy weight");
}

void onTick(CBlob@ this)
{
	
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
			CGridMenu@ menu = CreateGridMenu(getDriver().getScreenCenterPos() + Vec2f(0.0f, 0.0f), this, Vec2f(3, 3), "Smithing\n-\nNot all items can be turned into equipment.\n-\nOnce you have selected an item, hit the anvil\nwith a hammer to finish the product.");
			if (menu !is null)
			{
				CAttachment@ attach = this.getAttachments();
				CBlob @attachedBlob = attach.getAttachedBlob("SMITH");
				if(attachedBlob !is null){
					{
						CBitStream params;
						params.write_u8(0);
						CGridButton @but = menu.AddButton("$pickhead_icon$", "Pick Head", this.getCommandID("set_smith"),params);
						if(this.get_s8("smith") == 0)but.SetSelected(1);
						but.SetEnabled(false);
						if(attachedBlob.getName() == "metal_bar")but.SetEnabled(true);
					}
					{
						CBitStream params;
						params.write_u8(1);
						CGridButton @but = menu.AddButton("$axehead_icon$", "Axe Head", this.getCommandID("set_smith"),params);
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
						CGridButton @but = menu.AddButton("$lockset_icon$", "Simple Lock Set", this.getCommandID("set_smith"),params);
						if(this.get_s8("smith") == 3)but.SetSelected(1);
						but.SetEnabled(false);
						if(attachedBlob.getName() == "metal_bar_large")but.SetEnabled(true);
					}
					{
						CBitStream params;
						params.write_u8(4);
						CGridButton @but = menu.AddButton("$lock_icon$", "Simple Lock", this.getCommandID("set_smith"),params);
						if(this.get_s8("smith") == 4)but.SetSelected(1);
						but.SetEnabled(false);
						if(attachedBlob.getName() == "metal_bar")but.SetEnabled(true);
					}
					{
						CBitStream params;
						params.write_u8(5);
						CGridButton @but = menu.AddButton("$anvil_icon$", "Anvil", this.getCommandID("set_smith"),params);
						if(this.get_s8("smith") == 5)but.SetSelected(1);
						but.SetEnabled(false);
						if(attachedBlob.getName() == "metal_bar_large")but.SetEnabled(true);
					}
					{
						CBitStream params;
						params.write_u8(6);
						CGridButton @but = menu.AddButton("$stub_hook_icon$", "Hook", this.getCommandID("set_smith"),params);
						if(this.get_s8("smith") == 6)but.SetSelected(1);
						but.SetEnabled(false);
						if(attachedBlob.getName() == "metal_bar")but.SetEnabled(true);
					}
					{
						CBitStream params;
						params.write_u8(7);
						CGridButton @but = menu.AddButton("$forge_bar_icon$", "Smith into bars", this.getCommandID("set_smith"),params);
						if(this.get_s8("smith") == 7)but.SetSelected(1);
						but.SetEnabled(false);
						if(attachedBlob.getName() == "metal_bar_large")but.SetEnabled(true);
					}
					{
						CBitStream params;
						params.write_u8(8);
						CGridButton @but = menu.AddButton("$metal_door_icon$", "Metal Door", this.getCommandID("set_smith"),params);
						if(this.get_s8("smith") == 8)but.SetSelected(1);
						but.SetEnabled(false);
						if(attachedBlob.getName() == "metal_bar_large")but.SetEnabled(true);
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
	if(damage > 0.5f)
	if(customData == Hitters::builder){
		if(this.get_s8("smith") > -1){
			this.set_u8("progress",this.get_u8("progress")+1);
			if(this.get_u8("progress") > 10){
				this.set_u8("progress",0);
				
				if(getNet().isServer()){
					CAttachment@ attach = this.getAttachments();
					CBlob @attachedBlob = attach.getAttachedBlob("SMITH");
					if(attachedBlob !is null){
						string name = attachedBlob.getName();
						
						int ID = this.get_s8("smith");
						
						if(ID == 0)server_CreateBlob("pickhead",-1,this.getPosition()+Vec2f(0,-16));
						if(ID == 1)server_CreateBlob("axehead",-1,this.getPosition()+Vec2f(0,-16));
						if(ID == 2)server_CreateBlob("shield",XORRandom(7),this.getPosition()+Vec2f(0,-16));
						if(ID == 3){
							int pass = XORRandom(10);
							CBlob@ slock = server_CreateBlob("simplelock",-1,this.getPosition()+Vec2f(0,-16));
							CBlob@ skey = server_CreateBlob("simplekey",-1,this.getPosition()+Vec2f(0,-16));
							
							slock.set_s16("password",pass);
							slock.Sync("password",true);
							skey.set_s16("password",pass);
							skey.Sync("password",true);
						}
						if(ID == 4)server_CreateBlob("simplelock",-1,this.getPosition()+Vec2f(0,-16));
						if(ID == 5)server_CreateBlob("anvil",-1,this.getPosition()+Vec2f(0,-16));
						if(ID == 6)server_CreateBlob("stub_hook",-1,this.getPosition()+Vec2f(0,-16));
						if(ID == 7){
							if(name == "metal_bar_large"){
								server_CreateBlob("metal_bar",-1,this.getPosition()+Vec2f(0,-16));
								server_CreateBlob("metal_bar",-1,this.getPosition()+Vec2f(0,-16));
							}
						}
						if(ID == 8)server_CreateBlob("metal_door",-1,this.getPosition()+Vec2f(0,-16));
						
						attachedBlob.server_Die();
					}
				}
			}
			if(getNet().isServer()){
				this.Sync("progress",true);
			}
		}
		for(int i = 0; i < 10;i++){
			if (XORRandom(100) < 50) ParticlePixel(worldPoint, getRandomVelocity(90, 4, 45), SColor(255, 255, 50 + XORRandom(100), 0), true, 10 + XORRandom(20));
			else  makeFireParticle(worldPoint, "SmallFire" + (XORRandom(2) + 1));
		}
		this.getSprite().PlaySound("dig_stone2.ogg");
	}
	return damage;
}

void makeFireParticle(Vec2f worldPoint, const string filename = "SmallSmoke")
{
	Vec2f random = Vec2f(XORRandom(128) - 64, XORRandom(128) - 64) * 0.015625f * 4;
	ParticleAnimated(CFileMatcher(filename).getFirst(), worldPoint + random, getRandomVelocity(90, 0.50f, 45), 0, 1.0f, 2 + XORRandom(3), ((XORRandom(200) - 100) / 800.00f), true);
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return !this.isAttachedToPoint("SMITH");
}

void onRender(CSprite@ this)
{
	if (g_videorecording)
		return;
		
	CBlob @ blob = this.getBlob();

	if(blob is null)return;
	
	Vec2f pos2d = blob.getScreenPos() + Vec2f(0, 20);
	Vec2f dim = Vec2f(24, 8);
	const f32 y = blob.getHeight() * 2.4f;
	if (blob.get_u8("progress") > 0.0f)
	{
		const f32 perc = blob.get_u8("progress")*1.0f / 10.0f;
		if (perc >= 0.0f)
		{
			GUI::DrawRectangle(Vec2f(pos2d.x - dim.x - 2, pos2d.y + y - 2), Vec2f(pos2d.x + dim.x + 2, pos2d.y + y + dim.y + 2));
			GUI::DrawRectangle(Vec2f(pos2d.x - dim.x + 2, pos2d.y + y + 2), Vec2f(pos2d.x - dim.x + perc * 2.0f * dim.x - 2, pos2d.y + y + dim.y - 2), SColor(0xffac1512));
		}
	}
}