#include "Growth.as";
#include "Health.as";
#include "Hitters.as";
#include "ChangeClass.as";

void onInit(CBlob@ this)
{
	this.set_s16("sap",calculateSap());
	this.set_s16("original_sap",calculateSap());
	this.set_s16("blood",0);

	this.set_s16("blood_suck_cooldown",0);
	
	this.set_s16("nature_ability",0);
	this.addCommandID("makeslime");
	this.addCommandID("makeent");
	this.addCommandID("poison");
	this.addCommandID("overgrowzombies");
	
	this.addCommandID("heal");
	this.addCommandID("overgrow");
	this.addCommandID("makewisp");
	this.addCommandID("globalheal");
	
	this.addCommandID("makedruid");
	
	this.addCommandID("blooddrain");
	this.addCommandID("bloodstrength");
	this.addCommandID("bloodheal");
	this.addCommandID("bloodregen");
	this.addCommandID("bloodmimic");
	this.addCommandID("bloodmorph");
	
	this.addCommandID("becomefaceless");
}


void onTick(CBlob @ this)
{
	if (getNet().isServer()){
		if(XORRandom(100) == 0){
			this.set_s16("sap",calculateSap());
			this.Sync("sap",true);
			this.Sync("original_sap",true);
		}
	}
	
	int amount = 2;
	if(this.get_s16("sap") > this.get_s16("original_sap")/2)amount = 1;
	
	if(this.get_s16("nature_ability") < 1000)
	this.set_s16("nature_ability",this.get_s16("nature_ability")+amount);
	
	if(this.getName() == "naturebeing" || this.hasTag("onewithnature")){
		this.Tag("NatureMenu");
	} else {
		this.Untag("NatureMenu");
	}
	if((this.get_s16("blood") > 0 || this.hasTag("faceless")) && this.hasTag("flesh")){
		this.Tag("BloodMenu");
	}
	if(!this.hasTag("flesh"))
	{
		this.Untag("BloodMenu");
	}
	
	if(!this.hasTag("dead") && this.hasTag("flesh") && (this.get_s16("blood") > 0 || this.hasTag("faceless")) && this.hasTag("BloodMenu")){
		if(getMap().getDayTime() > 0.1 && getMap().getDayTime() < 0.8 && !getMap().rayCastSolidNoBlobs(Vec2f(this.getPosition().x,0), this.getPosition())){
			if(this.getPlayer() != null)
			if(this.getPlayer().isMyPlayer()){
				SetScreenFlash(100, 255, 255, 255);
				if(getGameTime() % 150 == 0 || !this.hasTag("hotsun")){
					string burn = "THE SUN, IT BURNS!!!";
					if(this.get_s16("blood") > 0)if(XORRandom(2) == 0)burn = "You feel the sun burn away some of your stolen blood.";
					
					client_AddToChat(burn, SColor(255, 255, 0, 0));
					this.Tag("hotsun");
				}
			}
			
			if(getNet().isServer()){
				if(this.get_s16("blood") > 0)if(getGameTime() % 15 == 0){
					this.set_s16("blood",this.get_s16("blood")-1);
					this.Sync("blood",true);
				}
			}
		} else {
			this.Untag("hotsun");
		}
	}
	
	if(this.get_s16("blood_suck_cooldown") > 0)this.set_s16("blood_suck_cooldown",this.get_s16("blood_suck_cooldown")-1);
	
	if(this.hasTag("BloodMenu"))this.set_f32("food",this.get_s16("blood"));
	
	if(getGameTime() % 15 == 0)
	if(this.hasTag("BloodMenu")){
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), 16.0f, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(b.getName() == "holybook")
				{
					if(getNet().isServer())b.server_Hit(this, this.getPosition(), Vec2f(0,0.1), 0.25, Hitters::suddengib, true);
				}
			}
		}
	}
}

int calculateSap(){
	int sap = 0;
	
	CBlob@[] Blobs;	   
	getBlobsByName("tree_bushy", @Blobs);
	getBlobsByName("tree_pine", @Blobs);
	getBlobsByName("bush", @Blobs);
	getBlobsByName("flowers", @Blobs);
	//for (uint i = 0; i < Blobs.length; i++)
	//{
	//	CBlob@ b = Blobs[i];
	//	sap += 1;
	//}
	
	sap = Blobs.length;
	
	return sap;
}

void onCreateInventoryMenu(CBlob@ this, CBlob@ forBlob, CGridMenu @gridmenu)
{
	if(this.hasTag("NatureMenu")){
		int X = 0;
		if(this.hasTag("DeathMenu"))X += 16 * 7;
		if(this.hasTag("BloodMenu"))X += 16 * 7;
		if(this.hasTag("EvilMenu"))X += 16 * 7;
		if(this.hasTag("HolyMenu"))X += 16 * 7;
		//I'm here
		if(this.hasTag("LifeMenu"))X -= 16 * 7;
		
		int Height = 1;
		if(this.getName() == "naturebeing"){
			Height = 4;
		}
		Vec2f pos(gridmenu.getUpperLeftPosition().x + 0.5f * (gridmenu.getLowerRightPosition().x - gridmenu.getUpperLeftPosition().x + X),
				  gridmenu.getUpperLeftPosition().y + 32 * 6 - 16+(Height*24-48));
		CGridMenu@ menu = CreateGridMenu(pos, this, Vec2f(2,Height), "Nature Abilities");

		AddIconToken("$slime$", "NatureAbilities.png", Vec2f(16, 16), 0);
		AddIconToken("$ent$", "NatureAbilities.png", Vec2f(16, 16), 1);
		AddIconToken("$poison$", "NatureAbilities.png", Vec2f(16, 16), 2);
		AddIconToken("$plantzombie$", "NatureAbilities.png", Vec2f(16, 16), 3);
		
		AddIconToken("$heal$", "NatureAbilities.png", Vec2f(16, 16), 4);
		AddIconToken("$overgrow$", "NatureAbilities.png", Vec2f(16, 16), 5);
		AddIconToken("$wisp$", "NatureAbilities.png", Vec2f(16, 16), 6);
		AddIconToken("$globalheal$", "NatureAbilities.png", Vec2f(16, 16), 7);
		
		AddIconToken("$druid$", "NatureAbilities.png", Vec2f(32, 32), 2);
		
		int discount = 1;
		if(this.getName() == "naturebeing" && this.hasTag("summoned"))discount = 2;
		
		if (menu !is null)
		{
			menu.deleteAfterClick = false;
			
			if(this.get_s16("sap") <= this.get_s16("original_sap")*0.80){
				{
					CGridButton@ b = menu.AddButton("$poison$", "Poison a nearby player.", this.getCommandID("poison"));
					if(this.get_s16("nature_ability") < 100/discount)if(b !is null)b.SetEnabled(false);
				}
			}
			
			
			if(this.get_s16("sap") <= this.get_s16("original_sap")*0.60){
				{
					CGridButton@ b = menu.AddButton("$slime$", "Summon a slime at a nearby tree or bush.", this.getCommandID("makeslime"));
					if(this.get_s16("nature_ability") < 150/discount)if(b !is null)b.SetEnabled(false);
				}
			}
			
			if(this.getName() == "naturebeing"){
				if(this.get_s16("sap") <= this.get_s16("original_sap")*0.40){
					{
						CGridButton@ b = menu.AddButton("$ent$", "Turn a nearby tree into an ent.", this.getCommandID("makeent"));
						if(this.get_s16("nature_ability") < 500/discount)if(b !is null)b.SetEnabled(false);
					}
				}
				
				if(this.get_s16("sap") <= this.get_s16("original_sap")*0.20){
					{
						CGridButton@ b = menu.AddButton("$plantzombie$", "Turn nearby bodies into zombies.", this.getCommandID("overgrowzombies"));
						if(this.get_s16("nature_ability") < 750/discount)if(b !is null)b.SetEnabled(false);
					}
				}
			}
			
			if(this.get_s16("sap") > this.get_s16("original_sap")*0.20){
				{
					CGridButton@ b = menu.AddButton("$heal$", "Heal a nearby player.", this.getCommandID("heal"));
					if(this.get_s16("nature_ability") < 100/discount)if(b !is null)b.SetEnabled(false);
				}
			}
			
			if(this.get_s16("sap") > this.get_s16("original_sap")*0.40){
				{
					CGridButton@ b = menu.AddButton("$overgrow$", "Grow flora around you.", this.getCommandID("overgrow"));
					if(this.get_s16("nature_ability") < 500/discount)if(b !is null)b.SetEnabled(false);
				}
			}
				
			if(this.getName() == "naturebeing"){
				if(this.get_s16("sap") > this.get_s16("original_sap")*0.60){
					{
						CGridButton@ b = menu.AddButton("$wisp$", "Summon a wisp at a nearby tree.", this.getCommandID("makewisp"));
						if(this.get_s16("nature_ability") < 500/discount)if(b !is null)b.SetEnabled(false);
					}
				}
				
				if(this.get_s16("sap") > this.get_s16("original_sap")*0.80){
					{
						CGridButton@ b = menu.AddButton("$globalheal$", "Heal all players.", this.getCommandID("globalheal"));
						if(this.get_s16("nature_ability") < 1000/discount)if(b !is null)b.SetEnabled(false);
					}
				}
				
				{
					CGridButton@ b = menu.AddButton("$druid$", "Turn a nearby player into a druid.", this.getCommandID("makedruid"));
					if(this.get_s16("nature_ability") < 1000/discount)if(b !is null)b.SetEnabled(false);
				}
			}
		}
	}
	
	if(this.hasTag("BloodMenu")){
		int X = 0;
		if(this.hasTag("DeathMenu"))X += 16 * 7;
		//I'm here
		if(this.hasTag("EvilMenu"))X -= 16 * 7;
		if(this.hasTag("HolyMenu"))X -= 16 * 7;
		if(this.hasTag("NatureMenu"))X -= 16 * 7;
		if(this.hasTag("LifeMenu"))X -= 16 * 7;
		
		int Height = 1;
		if(this.get_s16("blood") >= 50)Height += 1;
		if(this.get_s16("blood") >= 100)Height += 1;
		if(this.hasTag("faceless"))Height = 5;
		if(this.get_u8("race") == 3)Height = 3;
		Vec2f pos(gridmenu.getUpperLeftPosition().x + 0.5f * (gridmenu.getLowerRightPosition().x - gridmenu.getUpperLeftPosition().x + X),
				  gridmenu.getUpperLeftPosition().y + 32 * 6 - 16+(Height*24-48));
		CGridMenu@ menu = CreateGridMenu(pos, this, Vec2f(2,Height), "Blood Abilities");
	
		AddIconToken("$blooddrain_icon$", "BloodAbilities.png", Vec2f(16, 16), 0);
		AddIconToken("$bloodstrength_icon$", "BloodAbilities.png", Vec2f(16, 16), 1);
		AddIconToken("$bloodheal_icon$", "BloodAbilities.png", Vec2f(16, 16), 2);
		AddIconToken("$bloodregen_icon$", "BloodAbilities.png", Vec2f(16, 16), 3);
		AddIconToken("$bloodmimic_icon$", "BloodAbilities.png", Vec2f(16, 16), 4);
		AddIconToken("$bloodmorph_icon$", "BloodAbilities.png", Vec2f(16, 16), 5);
		
		AddIconToken("$facelessmorph_icon$", "BloodAbilities.png", Vec2f(32, 32), 2);
	
		int HealthBlood = Health(this)*10;
	
		if (menu !is null)
		{
			menu.deleteAfterClick = true;
			
			{
				CGridButton@ b = menu.AddButton("$blooddrain_icon$", "Sneakily suck a nearby players blood.", this.getCommandID("blooddrain"));
				if(this.get_s16("blood_suck_cooldown") > 0)if(b !is null)b.SetEnabled(false);
			}
			
			{
				CGridButton@ b = menu.AddButton("$bloodstrength_icon$", "Become strong temporarily.", this.getCommandID("bloodstrength"));
				if(this.get_s16("blood")+HealthBlood < 20)if(b !is null)b.SetEnabled(false);
			}
			
			{
				CGridButton@ b = menu.AddButton("$bloodheal_icon$", "Use blood to heal to full health.", this.getCommandID("bloodheal"));
				if(this.get_s16("blood") <= 0)if(b !is null)b.SetEnabled(false);
			}
			
			{
				CGridButton@ b = menu.AddButton("$bloodregen_icon$", "Slower healing, but more effecient.", this.getCommandID("bloodregen"));
				if(this.get_s16("blood") < 5)if(b !is null)b.SetEnabled(false);
			}
			
			{
				CGridButton@ b = menu.AddButton("$bloodmimic_icon$", "Swap your team to a nearby player's.", this.getCommandID("bloodmimic"));
				if(this.get_s16("blood")+HealthBlood < 10)
				if(b !is null)b.SetEnabled(false);
			}
			
			{
				CGridButton@ b = menu.AddButton("$bloodmorph_icon$", "Become a small flying creature.", this.getCommandID("bloodmorph"));
				if(this.get_s16("blood")+HealthBlood < 100)if(b !is null)b.SetEnabled(false);
			}
			
			{
				CGridButton@ b = menu.AddButton("$facelessmorph_icon$", "Revert to your true form.", this.getCommandID("becomefaceless"));
				if(this.get_s16("blood")+HealthBlood < 500)if(b !is null)b.SetEnabled(false);
			}
			
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{	
	int HealthBlood = Health(this)*10;
	
	bool Faceless = (this.get_u8("race") == 3);
	
	if (cmd == this.getCommandID("blooddrain")){
		if(this.get_s16("blood_suck_cooldown") <= 0)
		if (getNet().isServer()){
			CBlob@[] blobsInRadius;	   
			if (this.getMap().getBlobsInRadius(this.getPosition(), 128.0f, @blobsInRadius)) 
			{
				for (uint i = 0; i < blobsInRadius.length; i++)
				{
					int amount = 5;
					if(Faceless)amount = 20;
					CBlob@ b = blobsInRadius[i];
					
					if(b.get_s16("blood") > 0 && b !is this){
						this.set_s16("blood",this.get_s16("blood")+amount);
						b.set_s16("blood",b.get_s16("blood")-amount);
						b.Sync("blood",true);
						this.Sync("blood",true);
						if(!Faceless)break;
					}
					if(Health(b) > 0 && b !is this && b.hasTag("flesh") && b.hasTag("player"))
					{
						OverHeal(b,-((amount*1.0)/10.0));
						this.set_s16("blood",this.get_s16("blood")+amount);
						if(Health(b) <= 0){
							b.set_u8("race",9);
							b.Sync("race",true);
						}
						if(!Faceless)break;
					}
					if(b.getName() == "heart" && !b.hasTag("dont_eat")){
						this.set_s16("blood",this.get_s16("blood")+10);
						b.server_Die();
					}
				}
			}
			this.set_s16("blood_suck_cooldown",30);
			this.Sync("blood_suck_cooldown",true);
		}
	}
	
	if (cmd == this.getCommandID("bloodmimic")){
		if(this.get_s16("blood")+HealthBlood > 10)
		{
			if (getNet().isServer()){
				CBlob@[] blobsInRadius;	   
				if (this.getMap().getBlobsInRadius(this.getPosition(), 128.0f, @blobsInRadius)) 
				{
					for (uint i = 0; i < blobsInRadius.length; i++)
					{
						CBlob@ b = blobsInRadius[i];
						if(b.getTeamNum() != this.getTeamNum() && b.getTeamNum() < 20)
						{
							this.server_setTeamNum(b.getTeamNum());
							this.set_s16("blood",this.get_s16("blood")-10);
							break;
						}
					}
				}
			}
		}
	}
	
	if (cmd == this.getCommandID("bloodregen")){
		if(this.get_s16("blood") >= 5)
		{
			if (getNet().isServer()){
				this.set_s16("blood_regen",4);
				if(Faceless)this.set_s16("blood_regen",20);
				this.Sync("blood_regen",true);
				this.set_s16("blood",this.get_s16("blood")-5);
				
			}
			
		}
	}
	
	if (cmd == this.getCommandID("bloodstrength")){
		if(this.get_s16("blood")+HealthBlood > 20)
		{
			if (getNet().isServer()){
				this.set_s16("blood_strength",30*20);
				if(Faceless)this.set_s16("blood_strength",30*60);
				this.Sync("blood_strength",true);
				this.set_s16("blood",this.get_s16("blood")-20);
			}
		}
	}
	
	if (cmd == this.getCommandID("bloodheal")){
		if (getNet().isServer()){
			while(this.get_s16("blood") >= 5 && Health(this) < MaxHealth(this))
			{
				Heal(this,0.5);
				this.set_s16("blood",this.get_s16("blood")-5);
			}
		}
	}
	
	if (cmd == this.getCommandID("bloodmorph")){
		if(this.get_s16("blood")+HealthBlood >= 100)
		{
			if (getNet().isServer()){
				CBlob @bat = ChangeClass(this,"bloodbat",this.getPosition(),this.getTeamNum());
				bat.set_string("old_class",this.getName());
			}
		}
	}
	
	if (cmd == this.getCommandID("becomefaceless")){
		if(this.get_s16("blood")+HealthBlood >= 500)
		{
			if (getNet().isServer()){
				CBlob@[] blobsInRadius;	   
				if (this.getMap().getBlobsInRadius(this.getPosition(), 128.0f, @blobsInRadius)) 
				{
					for (uint i = 0; i < blobsInRadius.length; i++)
					{
						CBlob@ b = blobsInRadius[i];
						if(b.hasTag("flesh") && b.hasTag("player"))
						{
							SetHealth(b,0);
							b.set_u8("race",9);
							this.server_setTeamNum(12);
							this.set_u8("race",3);
							this.Untag("faceless");
							SetHealth(this,MaxHealth(this));
							break;
						}
					}
				}
			}
		}
	}
	
	if (getNet().isServer()){
		if(this.get_s16("blood") < 0){
			this.server_Hit(this, this.getPosition(), Vec2f(0,1), (this.get_s16("blood")/10)*-1, Hitters::suddengib, false);
			this.set_s16("blood",0);
		}
		this.Sync("blood",true);
	}
	
	
	int discount = 1;
	if(this.getName() == "naturebeing" && this.hasTag("summoned"))discount = 2;
	
	if (cmd == this.getCommandID("makeslime")){
		if(this.get_s16("nature_ability") >= 150/discount)
		{
			if (getNet().isServer()){
				CBlob@[] blobsInRadius;	   
				if (this.getMap().getBlobsInRadius(this.getPosition(), 128.0f, @blobsInRadius)) 
				{
					for (uint i = 0; i < blobsInRadius.length; i++)
					{
						CBlob@ b = blobsInRadius[i];
						if(b.getName() == "bush" || b.getName() == "tree_pine" || b.getName() == "tree_bushy")
						{
							server_CreateBlob("slime", -1, b.getPosition());
							this.set_s16("nature_ability",this.get_s16("nature_ability")-150/discount);
							this.Sync("nature_ability",true);
							if(!this.hasTag("summoned"))return;
						}
					}
				}
			}
			
		}
	}
	
	if (cmd == this.getCommandID("makeent")){
		if(this.get_s16("nature_ability") >= 500/discount)
		{
			if (getNet().isServer()){
				if(!this.hasTag("summoned")){
					CBlob@[] blobsInRadius;	   
					if (this.getMap().getBlobsInRadius(this.getPosition(), 128.0f, @blobsInRadius)) 
					{
						for (uint i = 0; i < blobsInRadius.length; i++)
						{
							CBlob@ b = blobsInRadius[i];
							if(b.getName() == "tree_pine" || b.getName() == "tree_bushy")
							{
								server_CreateBlob("ent", -1, b.getPosition());
								this.set_s16("nature_ability",this.get_s16("nature_ability")-500/discount);
								this.Sync("nature_ability",true);
								b.server_Die();
								return;
							}
						}
					}
				} else {
					server_CreateBlob("ent", -1, this.getPosition());
					this.set_s16("nature_ability",this.get_s16("nature_ability")-500/discount);
					this.Sync("nature_ability",true);
					return;
				}
			}
			
		}
	}
	
	if (cmd == this.getCommandID("overgrow")){
		if(this.get_s16("nature_ability") >= 500/discount)
		{
			if (getNet().isServer()){
				Growth(this.getPosition());
				this.set_s16("nature_ability",this.get_s16("nature_ability")-500/discount);
				this.Sync("nature_ability",true);
			}
			
		}
	}
	
	if (cmd == this.getCommandID("makewisp")){
		if(this.get_s16("nature_ability") >= 500/discount)
		{
			if (getNet().isServer()){
				CBlob@[] blobsInRadius;	   
				if (this.getMap().getBlobsInRadius(this.getPosition(), 128.0f, @blobsInRadius)) 
				{
					for (uint i = 0; i < blobsInRadius.length; i++)
					{
						CBlob@ b = blobsInRadius[i];
						if(b.getName() == "tree_pine" || b.getName() == "tree_bushy")
						{
							server_CreateBlob("wisp", -1, b.getPosition());
							this.set_s16("nature_ability",this.get_s16("nature_ability")-500/discount);
							this.Sync("nature_ability",true);
							if(!this.hasTag("summoned"))return;
						}
					}
				}
			}
			
		}
	}
	
	if (cmd == this.getCommandID("overgrowzombies")){
		if(this.get_s16("nature_ability") >= 750/discount)
		{
			if (getNet().isServer()){
				CBlob@[] blobsInRadius;	   
				if (this.getMap().getBlobsInRadius(this.getPosition(), 160.0f, @blobsInRadius)) 
				{
					for (uint i = 0; i < blobsInRadius.length; i++)
					{
						CBlob@ b = blobsInRadius[i];
						if(b.hasTag("dead"))
						{
							CBlob @newBlob = server_CreateBlob("plant_zombie", this.getTeamNum(), b.getPosition());
							b.server_Die();
						}
					}
				}
				this.set_s16("nature_ability",this.get_s16("nature_ability")-750/discount);
				this.Sync("nature_ability",true);
			}
		}
	}
	
	if (cmd == this.getCommandID("heal")){
		if(this.get_s16("nature_ability") >= 100/discount)
		{
			if (getNet().isServer()){
				CBlob@[] blobsInRadius;	   
				if (this.getMap().getBlobsInRadius(this.getPosition(), 128.0f, @blobsInRadius)) 
				{
					for (uint i = 0; i < blobsInRadius.length; i++)
					{
						CBlob@ b = blobsInRadius[i];
						if(b.hasTag("player") && b.get_s16("nature_regen") <= 0)
						{
							b.set_s16("nature_regen",24);
							this.set_s16("nature_ability",this.get_s16("nature_ability")-100/discount);
							this.Sync("nature_ability",true);
							return;
						}
					}
				}
			}
			
		}
	}
	
	if (cmd == this.getCommandID("poison")){
		if(this.get_s16("nature_ability") >= 100/discount)
		{
			if (getNet().isServer()){
				CBlob@[] blobsInRadius;	   
				if (this.getMap().getBlobsInRadius(this.getPosition(), 128.0f, @blobsInRadius)) 
				{
					for (uint i = 0; i < blobsInRadius.length; i++)
					{
						CBlob@ b = blobsInRadius[i];
						if(b.hasTag("player") && b.get_s16("poison") <= 0 && b !is this)
						{
							b.set_s16("poison",4);
							if(this.hasTag("summoned"))b.set_s16("poison",4*8);
							this.set_s16("nature_ability",this.get_s16("nature_ability")-100/discount);
							this.Sync("nature_ability",true);
							return;
						}
					}
				}
			}
			
		}
	}
	
	if (cmd == this.getCommandID("globalheal")){
		if(this.get_s16("nature_ability") >= 1000/discount)
		{
			if (getNet().isServer()){
				CBlob@[] Blobs;	   
				getBlobsByTag("player", @Blobs);
				for (uint i = 0; i < Blobs.length; i++)
				{
					CBlob@ b = Blobs[i];
					b.set_s16("nature_regen",24);
				}
				this.set_s16("nature_ability",this.get_s16("nature_ability")-1000/discount);
				this.Sync("nature_ability",true);
			}
		}
	}
	
	if (cmd == this.getCommandID("makedruid")){
		if(this.get_s16("nature_ability") >= 1000/discount)
		{
			if (getNet().isServer()){
				CBlob@[] blobsInRadius;	   
				if (this.getMap().getBlobsInRadius(this.getPosition(), 128.0f, @blobsInRadius)) 
				{
					for (uint i = 0; i < blobsInRadius.length; i++)
					{
						CBlob@ b = blobsInRadius[i];
						if(b.hasTag("player") && b.hasTag("flesh") && (b.get_u8("race") == 0 || b.get_u8("race") == 2 || b.get_u8("race") == 4))
						{
							b.set_u8("race",5);
							this.set_s16("nature_ability",this.get_s16("nature_ability")-1000/discount);
							this.Sync("nature_ability",true);
							return;
						}
					}
				}
			}
			
		}
	}
}