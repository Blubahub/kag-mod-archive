#include "BombCommon.as";
#include "ClassChangeDataCopy.as";
#include "ChangeClass.as";

void onInit(CBlob@ this)
{
	
	
	
	if(!this.hasTag("ghost") && this.getName() != "ghost"){
		this.set_s16("life",80);
		this.set_s16("death",0);
	} else {
		this.set_s16("life",0);
		this.set_s16("death",80);
	}
	
	this.addCommandID("invisible");
	//this.addCommandID("gbomb");
	this.addCommandID("ghostself");
	this.addCommandID("wraithself");
	this.addCommandID("possess");
	this.addCommandID("shardself");
	this.addCommandID("spiritview");
	
	this.addCommandID("createwisp");
	this.addCommandID("drainlife");
	this.addCommandID("makemissile");
	this.addCommandID("maketurret");
}

void onTick(CBlob @ this)
{
	if(getNet().isServer()){
		if(this.getPlayer() !is null){
			if(!this.getPlayer().exists("soul_strength")){
				this.getPlayer().set_u8("soul_strength", 80);
				this.set_s16("life",this.getPlayer().get_u8("soul_strength"));
				this.Sync("life",true);
			} else {
			
				if(getGameTime() % (10*60*30) == 0){
					if(this.getPlayer().get_u8("soul_strength") < 100){
						this.getPlayer().set_u8("soul_strength", this.getPlayer().get_u8("soul_strength")+10);
					}
				}
				
				
				if(!this.hasTag("init_life_death"))
				if(this.getPlayer().get_u8("soul_strength") >= 10 && this.getPlayer().get_u8("soul_strength") <= 100){
					if(!this.hasTag("ghost") && this.getName() != "ghost"){
						this.set_s16("life",this.getPlayer().get_u8("soul_strength"));
						this.Tag("init_life_death");
						this.Sync("init_life_death",true);
						this.Sync("life",true);
					}
				}
				
			}
		}
	}
	
	if(getGameTime() % (10*60*30) == 0){
		if(this.getPlayer() !is null)
		if(this.getPlayer().isMyPlayer())
		client_AddToChat("Your soul has strengthened with time.", SColor(255, 0, 200, 200));
	}

	if(this.get_s16("death") > 0){
		this.Tag("DeathMenu");
	} else {
		this.Untag("DeathMenu");
	}
	
	if(this.get_s16("life") <= 0){
		if(this.get_u8("race") == 0){
			this.set_u8("race",4);
		}
	}
	
	if(this.get_s16("life") > 100){
		this.Tag("LifeMenu");
	} else {
		this.Untag("LifeMenu");
	}
	if(getNet().isServer()){
		if(XORRandom(1000) == 0)this.Sync("death",true);
		if(this.get_s16("life") > 100)this.Sync("life",true);
	}
	
	if(this.getName() == "wraithknight" || this.getName() == "wraitharcher")if(this.get_s16("death") <= 0)
	if(getNet().isServer()){
		CBlob @newBlob = server_CreateBlob("ghost", this.getTeamNum(), this.getPosition());
		if (newBlob !is null)
		{
			newBlob.server_SetPlayer(this.getPlayer());
			CopyData(this,newBlob);
			this.server_SetPlayer(null);
			this.Tag("switch class");
			this.server_Die();
		}
	}
}

void onCreateInventoryMenu(CBlob@ this, CBlob@ forBlob, CGridMenu @gridmenu)
{
	if(this.hasTag("DeathMenu")){
		int X = 0;
		//I'm here
		if(this.hasTag("BloodMenu"))X -= 16 * 7;
		if(this.hasTag("EvilMenu"))X -= 16 * 7;
		if(this.hasTag("HolyMenu"))X -= 16 * 7;
		if(this.hasTag("NatureMenu"))X -= 16 * 7;
		if(this.hasTag("LifeMenu"))X -= 16 * 7;

		int Height = 2;
		if(this.getName() != "ghost")Height = 4;
		
		Vec2f pos(gridmenu.getUpperLeftPosition().x + 0.5f * (gridmenu.getLowerRightPosition().x - gridmenu.getUpperLeftPosition().x + X),
				  gridmenu.getUpperLeftPosition().y + 32 * 6 - 16+(Height*24-48));
		CGridMenu@ menu = CreateGridMenu(pos, this, Vec2f(2,Height), "Death Abilities");

		AddIconToken("$invis$", "Invisible.png", Vec2f(16, 16), 0);
		AddIconToken("$gbomb$", "GhostBomb.png", Vec2f(16, 16), 0);
		AddIconToken("$possess$", "PossessIcon.png", Vec2f(16, 16), 0);
		AddIconToken("$wraithself$", "BecomeWraith.png", Vec2f(16, 16), 0);
		AddIconToken("$shardself$", "GhostShard.png", Vec2f(8, 8), 0);
		AddIconToken("$spiritview$", "ViewIcon.png", Vec2f(16, 16), 0);
		
		AddIconToken("$ghostself$", "Ghost.png", Vec2f(32, 32), 0);
		
		if (menu !is null)
		{
			menu.deleteAfterClick = false;
			if(this.hasTag("ghost"))
			{
				CGridButton@ b = menu.AddButton("$shardself$", "Turn yourself into a shard.", this.getCommandID("shardself"));
			}
			if(!this.hasTag("ghost"))
			{
				CGridButton@ b = menu.AddButton("$spiritview$", "Ghost Watching.", this.getCommandID("spiritview"));
				if(this.get_s16("death") < 50)if(b !is null)b.SetEnabled(false);
			}
			{
				CGridButton@ b = menu.AddButton("$invis$", "Turn Inivisible.", this.getCommandID("invisible"));
				if(this.get_s16("death") < 20)if(b !is null)b.SetEnabled(false);
			}
			//if(this.getName() != "ghost")
			//{
			//	CGridButton@ b = menu.AddButton("$gbomb$", "This has been disabled temporarily.", this.getCommandID("gbomb"));
			//	//if(this.get_s16("death") < 50)if(b !is null)
			//	b.SetEnabled(false);
			//}
			if(this.getName() != "wraithknight" && this.getName() != "wraitharcher")
			{
				CGridButton@ b = menu.AddButton("$wraithself$", "Become a wraith.", this.getCommandID("wraithself"));
				if(this.get_s16("death") < 100)if(b !is null)b.SetEnabled(false);
			}
			if(this.hasTag("ghost"))
			{
				CGridButton@ b = menu.AddButton("$possess$", "Possess something.", this.getCommandID("possess"));
				if(this.get_s16("death") < 50)if(b !is null)b.SetEnabled(false);
			}
			if(this.getName() != "ghost"){
				{
					CGridButton@ b = menu.AddButton("$ghostself$", "Become a ghost again.", this.getCommandID("ghostself"));
					if(this.get_s16("death") < 100)if(b !is null)b.SetEnabled(false);
				}
			}
		}
	}
	if(this.hasTag("LifeMenu")){
		int X = 0;
		if(this.hasTag("DeathMenu"))X += 16 * 7;
		if(this.hasTag("BloodMenu"))X += 16 * 7;
		if(this.hasTag("EvilMenu"))X += 16 * 7;
		if(this.hasTag("HolyMenu"))X += 16 * 7;
		if(this.hasTag("NatureMenu"))X += 16 * 7;

		int Height = 2;
		
		Vec2f pos(gridmenu.getUpperLeftPosition().x + 0.5f * (gridmenu.getLowerRightPosition().x - gridmenu.getUpperLeftPosition().x + X),
				  gridmenu.getUpperLeftPosition().y + 32 * 6 - 16+(Height*24-48));
		CGridMenu@ menu = CreateGridMenu(pos, this, Vec2f(2,Height), "Life Abilities");
		
		AddIconToken("$wisp$", "LifeAbilities.png", Vec2f(16, 16), 0);
		AddIconToken("$drainlifeicon$", "LifeAbilities.png", Vec2f(16, 16), 1);
		AddIconToken("$missileicon$", "LifeAbilities.png", Vec2f(16, 16), 2);
		AddIconToken("$lifeturreticon$", "LifeAbilities.png", Vec2f(16, 16), 3);
		
		if (menu !is null)
		{
			menu.deleteAfterClick = false;
			{
				CGridButton@ b = menu.AddButton("$wisp$", "Summon a wisp.", this.getCommandID("createwisp"));
				if(this.get_s16("life") < 200)if(b !is null)b.SetEnabled(false);
			}
			{
				CGridButton@ b = menu.AddButton("$drainlifeicon$", "Drain a nearby player's life.", this.getCommandID("drainlife"));
				if(this.get_s16("life") < 200)if(b !is null)b.SetEnabled(false);
			}
			{
				CGridButton@ b = menu.AddButton("$missileicon$", "Summon a missile to hunt enemies.", this.getCommandID("makemissile"));
				if(this.get_s16("life") < 300)if(b !is null)b.SetEnabled(false);
			}
			{
				CGridButton@ b = menu.AddButton("$lifeturreticon$", "Summon a rapid fire turret.", this.getCommandID("maketurret"));
				if(this.get_s16("life") < 600)if(b !is null)b.SetEnabled(false);
			}
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("createwisp")){
		if(this.get_s16("life") >= 100)
		{
			if (getNet().isServer()){
				server_CreateBlob("wisp", -1, this.getPosition());
				this.set_s16("life",this.get_s16("life")-10);
				this.Sync("life",true);
				this.server_Hit(this, this.getPosition(), Vec2f(0,1), 0.5f, Hitters::suddengib, false);
			}
			
		}
	}
	
	if (cmd == this.getCommandID("drainlife")){
		if(this.get_s16("life") >= 100)
		{
			if (getNet().isServer()){
				CBlob@[] blobsInRadius;	   
				if (this.getMap().getBlobsInRadius(this.getPosition(), 128.0f, @blobsInRadius)) 
				{
					for (uint i = 0; i < blobsInRadius.length; i++)
					{
						CBlob@ b = blobsInRadius[i];
						if(b.get_s16("life") > 0 && b !is this && b.getTeamNum() != this.getTeamNum())
						{
							int Amount = Maths::Min(b.get_s16("life"),5);
							this.set_s16("life",this.get_s16("life")+Amount);
							this.set_s16("death",this.get_s16("death")-Amount);
							if(this.get_s16("death") < 0)this.set_s16("death",0);
							b.set_s16("death",b.get_s16("death")+Amount);
							b.set_s16("life",b.get_s16("life")-Amount);
							this.server_Hit(b, b.getPosition(), Vec2f(0,0), 0.5f, Hitters::suddengib, false);
						}
						if(b.getName() == "wisp"){
							this.set_s16("life",this.get_s16("life")+10);
							b.server_Die();
						}
						if(b.getName() == "derangedwisp"){
							this.set_s16("life",this.get_s16("life")+1);
							b.server_Die();
						}
					}
				}
			}
		}
	}
	
	if (cmd == this.getCommandID("makemissile")){
		if(this.get_s16("life") >= 200)
		{
			if (getNet().isServer()){
				CBlob @mis = server_CreateBlob("lifemissile", this.getTeamNum(), this.getPosition());
				mis.SetDamageOwnerPlayer(this.getPlayer());
				this.set_s16("life",this.get_s16("life")-20);
				this.Sync("life",true);
				this.server_Hit(this, this.getPosition(), Vec2f(0,1), 0.5f, Hitters::suddengib, false);
			}
			
		}
	}
	
	if (cmd == this.getCommandID("maketurret")){
		if(this.get_s16("life") >= 500)
		{
			if (getNet().isServer()){
				CBlob @mis = server_CreateBlob("lifeorb", this.getTeamNum(), this.getPosition());
				mis.SetDamageOwnerPlayer(this.getPlayer());
				this.set_s16("life",this.get_s16("life")-50);
				this.Sync("life",true);
				this.server_Hit(this, this.getPosition(), Vec2f(0,1), 1.0f, Hitters::suddengib, false);
			}
			
		}
	}
	
	if (cmd == this.getCommandID("invisible")){
		if(this.get_s16("death") >= 10)
		{
			if(this.get_s16("invisible") <= 0 || !this.hasTag("ghost"))this.set_s16("invisible",300);
			else this.set_s16("invisible",0);
		}
	}
	//if (cmd == this.getCommandID("gbomb")){
	//	if(this.get_s16("death") >= 20)
	//	{
	//		if(getNet().isServer()){
	//			CBlob @bomb = server_CreateBlob("bomb", this.getTeamNum(), this.getPosition());
	//			SetupBomb(bomb, 120, 48, 0.0f, 0, 0.0f, false);
	//		}
	//	}
	//}
	if (cmd == this.getCommandID("ghostself")){
		if(this.get_s16("death") >= 100)
		{
			if(getNet().isServer()){
				CBlob @newBlob = server_CreateBlob("ghost", this.getTeamNum(), this.getPosition());
				if (newBlob !is null)
				{
					if(this.getPlayer() !is null)this.set_string("username",this.getPlayer().getUsername());
					newBlob.server_SetPlayer(this.getPlayer());
					CopyData(this,newBlob);
					this.server_SetPlayer(null);
					if(this.hasTag("ghost")){
						this.Tag("switch class");
						this.server_Die();
					}
				}
			}
		}
	}
	if (cmd == this.getCommandID("wraithself")){
		if(this.get_s16("death") >= 100)
		{
			if(getNet().isServer()){
				CBlob @newBlob = server_CreateBlob("wraithknight", this.getTeamNum(), this.getPosition());
				if (newBlob !is null)
				{
					if(this.getPlayer() !is null)this.set_string("username",this.getPlayer().getUsername());
					newBlob.server_SetPlayer(this.getPlayer());
					CopyData(this,newBlob);
					this.server_SetPlayer(null);
					if(this.hasTag("ghost")){
						this.Tag("switch class");
						this.server_Die();
					}
				}
			}
		}
	}
	
	if (cmd == this.getCommandID("shardself")){
		if(getNet().isServer()){
			CBlob @blob = server_CreateBlob("ghost_shard", this.getTeamNum(), this.getPosition());
			blob.server_SetPlayer(this.getPlayer());
		
			CopyData(this,blob);
		
			this.Tag("switch class");
			this.server_SetPlayer(null);
			this.server_Die();
		}
	}
	
	if (cmd == this.getCommandID("spiritview")){
		if(this.get_s16("death") >= 50)this.Tag("spirit_view");
	}
	
	if (cmd == this.getCommandID("possess")){
		if(this.get_s16("death") >= 50){
			CBlob@[] blobsInRadius;	   
			if (this.getMap().getBlobsInRadius(this.getPosition(), 16.0f, @blobsInRadius)) 
			{
				for (uint i = 0; i < blobsInRadius.length; i++)
				{
					CBlob@ b = blobsInRadius[i];
					if((b.getName() == "builder" || b.getName() == "knight" || b.getName() == "archer") && b.getPlayer() is null && !b.hasTag("dead"))
					{
						if (getNet().isServer()){
							b.server_SetPlayer(this.getPlayer());
							
							int race = b.get_u8("race");
							CopyData(this,b);
							b.set_u8("race",race);
							
							this.Tag("switch class");
							this.server_SetPlayer(null);
							this.server_Die();
						}
						
						if(this.getPlayer() !is null)
						if(this.getPlayer().isMyPlayer()){
							client_AddToChat("Your soul floods in the souless body.", SColor(255, 150, 150, 150));
						}
						
						break;
					}
					if(b.getName() == "zombie")
					{
						if (getNet().isServer()){
							CBlob @builder = ChangeClass(this, "builder", b.getPosition(), this.getTeamNum());
							
							builder.set_u8("race",2);
							
							this.Tag("switch class");
							this.server_SetPlayer(null);
							this.server_Die();
							b.server_Die();
						}
						
						if(this.getPlayer() !is null)
						if(this.getPlayer().isMyPlayer()){
							client_AddToChat("Your soul struggles to gain control over this blood thirsty corpse, the body uncomfortable and rotting.", SColor(255, 150, 150, 150));
						}
						
						break;
					}
					if(b.getName() == "blood_zombie")
					{
						if (getNet().isServer()){
							CBlob @builder = ChangeClass(this, "builder", b.getPosition(), this.getTeamNum());
							
							builder.set_u8("race",2);
							//builder.set_s16("blood",30);
							
							this.Tag("switch class");
							this.server_SetPlayer(null);
							this.server_Die();
							b.server_Die();
						}
						
						if(this.getPlayer() !is null)
						if(this.getPlayer().isMyPlayer()){
							client_AddToChat("Your soul struggles to gain control over this blood thirsty corpse, the body uncomfortable and rotting.", SColor(255, 150, 150, 150));
						}
						
						break;
					}
					if(b.getName() == "plant_zombie")
					{
						if (getNet().isServer()){
							CBlob @builder = ChangeClass(this, "builder", b.getPosition(), this.getTeamNum());
							
							builder.set_u8("race",2);
							builder.Tag("onewithnature");
							
							this.Tag("switch class");
							this.server_SetPlayer(null);
							this.server_Die();
							b.server_Die();
						}
						
						if(this.getPlayer() !is null)
						if(this.getPlayer().isMyPlayer()){
							client_AddToChat("Your soul struggles to gain control over this blood thirsty corpse, the body uncomfortable and rotting.", SColor(255, 150, 150, 150));
						}
						
						break;
					}
					if(b.getName() == "gold_zombie")
					{
						if (getNet().isServer()){
							CBlob @builder = ChangeClass(this, "builder", b.getPosition(), this.getTeamNum());
							
							builder.set_u8("race",2);
							builder.Tag("gold");
							builder.Tag("holy");
							
							this.Tag("switch class");
							this.server_SetPlayer(null);
							this.server_Die();
							b.server_Die();
						}
						
						if(this.getPlayer() !is null)
						if(this.getPlayer().isMyPlayer()){
							client_AddToChat("Your soul struggles to gain control over this blood thirsty corpse, the body uncomfortable and rotting.", SColor(255, 150, 150, 150));
						}
						
						break;
					}
					if(b.getName() == "evil_zombie")
					{
						if (getNet().isServer()){
							CBlob @builder = ChangeClass(this, "builder", b.getPosition(), this.getTeamNum());
							
							builder.set_u8("race",2);
							builder.Tag("evil");
							builder.Tag("evil_potential");
							
							this.Tag("switch class");
							this.server_SetPlayer(null);
							this.server_Die();
							b.server_Die();
						}
						
						if(this.getPlayer() !is null)
						if(this.getPlayer().isMyPlayer()){
							client_AddToChat("Your soul struggles to gain control over this blood thirsty corpse, the body uncomfortable and rotting.", SColor(255, 150, 150, 150));
						}
						
						break;
					}
					if((b.getName() == "golem" || b.getName() == "wooden_golem" || b.getName() == "gold_golem") && b.get_u8("core") == 0)
					{
						if (getNet().isServer()){
							b.server_SetPlayer(this.getPlayer());
							
							CopyData(this,b);
							
							this.Tag("switch class");
							this.server_SetPlayer(null);
							this.server_Die();
						}
						
						if(this.getPlayer() !is null)
						if(this.getPlayer().isMyPlayer()){
							client_AddToChat("Your soul painfully and slowly seeps through the golem's cracks and engravings.", SColor(255, 150, 150, 150));
						}
						
						break;
					}
				}
			}
		}
	}
	
	if(getNet().isServer())this.Sync("life",true);
}