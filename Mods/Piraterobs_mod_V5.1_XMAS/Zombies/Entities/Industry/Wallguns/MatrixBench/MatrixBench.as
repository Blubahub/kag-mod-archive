// Mystery Box

#include "Requirements.as"
#include "ShopCommon.as";
#include "Descriptions.as";
#include "WARCosts.as";
#include "CheckSpam.as";


void onInit( CBlob@ this )
{	
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("can settle"); //for DieOnCollapse to prevent 2 second life :)

	InitWorkshop( this );
}


void InitWorkshop( CBlob@ this )
{
	//Cost variables
	s32 cost_lantern = 1;
	s32 cost_cobra = 20;
	s32 cost_anaconda = 50;
	s32 cost_bulldog = 20;
	s32 cost_britishbulldog = 25;
	s32 cost_glock18 = 15;
	s32 cost_enfieldno2 = 60;
	s32 cost_usp = 40;
	s32 cost_ragingbull = 70;
	s32 cost_fiveseven = 20;
	s32 cost_goldengun = 150;
	s32 cost_ak47 = 60;
	s32 cost_m16 = 80;
	s32 cost_chicom = 65;
	s32 cost_mp5 = 55;
	s32 cost_deagle = 45;
	s32 cost_cz = 25;
	s32 cost_colt1911 = 15;
	s32 cost_m1 = 70;
	s32 cost_gl = 250;
	s32 cost_rpg = 300;
	s32 cost_m79 = 270;
	s32 cost_plasma = 120;
	s32 cost_sawnoffshotgun = 50;
	s32 cost_itachishotgun = 60;
	s32 cost_AA12 = 100;
	s32 cost_sniper = 75;	
	//End Cost variables
	
	
	
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(8,8)); // 8 x 8 for now


	{	 
		ShopItem@ s = addShopItem( this, "Lantern", "$lantern$", "lantern", descriptions[9], false );
		AddRequirement( s.requirements, "coin", "", "Coins", cost_lantern );
	}
		{
			ShopItem@ s = addShopItem(this, "coltcobra", "$lantern$", "coltcobra", "6 Shot Revolver", true);
			AddRequirement(s.requirements, "coin", "", "Coins", cost_cobra);
		}
		
		{
			ShopItem@ s = addShopItem(this, "coltanaconda", "$lantern$", "coltanaconda", "6 Shot Revolver", true);
			AddRequirement(s.requirements, "coin", "", "Coins", cost_anaconda);
		}
		
		{
			ShopItem@ s = addShopItem(this, "charterarmsbulldog", "$lantern$", "charterarmsbulldog", "6 Shot Revolver", true);
			AddRequirement(s.requirements, "coin", "", "Coins", cost_bulldog);
		}
		
		{
			ShopItem@ s = addShopItem(this, "britishbulldogrevolver", "$lantern$", "britishbulldogrevolver", "6 Shot Revolver", true);
			AddRequirement(s.requirements, "coin", "", "Coins", cost_britishbulldog);
		}
		
		{
			ShopItem@ s = addShopItem(this, "glock18", "$lantern$", "glock18", "20 shot, rapid firing pistol yo! Get yo gangsta lean on.", true);
			AddRequirement(s.requirements, "coin", "", "Coins", cost_glock18);
		}
		
		{
			ShopItem@ s = addShopItem(this, "enfieldno2", "$lantern$", "enfieldno2", "6 Shot Revolver", true);
			AddRequirement(s.requirements, "coin", "", "Coins", cost_enfieldno2);
		}
		
		{
			ShopItem@ s = addShopItem(this, "uspsilenced", "$lantern$", "uspsilenced", "uspsilenced", true);
			AddRequirement(s.requirements, "coin", "", "Coins", cost_usp);
		}
		
		{
			ShopItem@ s = addShopItem(this, "ragingbull", "$lantern$", "ragingbull", "ragingbull", true);
			AddRequirement(s.requirements, "coin", "", "Coins", cost_ragingbull);
		}
		
		{
			ShopItem@ s = addShopItem(this, "fiveseven", "$lantern$", "fiveseven", "fiveseven", true);
			AddRequirement(s.requirements, "coin", "", "Coins", cost_fiveseven);
		}
		
		{
			ShopItem@ s = addShopItem(this, "goldengun", "$lantern$", "goldengun", "goldengun", true);
			AddRequirement(s.requirements, "coin", "", "Coins", cost_goldengun);
		}
		
		{
			ShopItem@ s = addShopItem(this, "ak47", "$lantern$", "ak47", "ak47 for everyone!", true);
			AddRequirement(s.requirements, "coin", "", "Coins", cost_ak47);
		}
		
		{
			ShopItem@ s = addShopItem(this, "m16", "$lantern$", "m16", "m16 for everyone!", true);
			AddRequirement(s.requirements, "coin", "", "Coins", cost_m16);
		}
		
		{
			ShopItem@ s = addShopItem(this, "chicom", "$lantern$", "chicom", "chicom for everyone!", true);
			AddRequirement(s.requirements, "coin", "", "Coins", cost_chicom);
		}
		
		{
			ShopItem@ s = addShopItem(this, "mp5", "$lantern$", "mp5", "mp5 for everyone!", true);
			AddRequirement(s.requirements, "coin", "", "Coins", cost_mp5);
		}
		
		{
			ShopItem@ s = addShopItem(this, "deagle", "$lantern$", "deagle", "deagle for everyone!", true);
			AddRequirement(s.requirements, "coin", "", "Coins", cost_deagle);
		}
		
		{
			ShopItem@ s = addShopItem(this, "cz75auto", "$lantern$", "cz75auto", "cz75auto for everyone!", true);
			AddRequirement(s.requirements, "coin", "", "Coins", cost_cz);
		}
		
		{
			ShopItem@ s = addShopItem(this, "colt1911", "$lantern$", "colt1911", "colt1911 for everyone!", true);
			AddRequirement(s.requirements, "coin", "", "Coins", cost_colt1911);
		}
		
		{
			ShopItem@ s = addShopItem(this, "m1", "$lantern$", "m1", "m1 for everyone!", true);
			AddRequirement(s.requirements, "coin", "", "Coins", cost_m1);
		}
		
		{
			ShopItem@ s = addShopItem(this, "gl", "$lantern$", "gl", "gl for everyone!", true);
			AddRequirement(s.requirements, "coin", "", "Coins", cost_gl);
		}
		
		{
			ShopItem@ s = addShopItem(this, "rpg", "$lantern$", "rpg", "rpg for everyone!", true);
			AddRequirement(s.requirements, "coin", "", "Coins", cost_rpg);
		}
		
		{
			ShopItem@ s = addShopItem(this, "m79", "$lantern$", "m79", "m79 for everyone!", true);
			AddRequirement(s.requirements, "coin", "", "Coins", cost_m79);
		}
		
		{
			ShopItem@ s = addShopItem(this, "plasma", "$lantern$", "plasma", "plasma for everyone!", true);
			AddRequirement(s.requirements, "coin", "", "Coins", cost_plasma);
		}
		
		{
			ShopItem@ s = addShopItem(this, "sawnoffshotgun", "$lantern$", "sawnoffshotgun", "sawnoffshotgun for everyone!", true);
			AddRequirement(s.requirements, "coin", "", "Coins", cost_sawnoffshotgun);
		}
		
		{
			ShopItem@ s = addShopItem(this, "ithaca37", "$lantern$", "ithaca37", "ithaca37 for everyone!", true);
			AddRequirement(s.requirements, "coin", "", "Coins", cost_itachishotgun);
		}
		
		{
			ShopItem@ s = addShopItem(this, "aa12", "$lantern$", "aa12", "aa12 for everyone!", true);
			AddRequirement(s.requirements, "coin", "", "Coins", cost_AA12);
		}
		
		{
			ShopItem@ s = addShopItem(this, "sniper", "$lantern$", "sniper", "sniper for everyone!", true);
			AddRequirement(s.requirements, "coin", "", "Coins", cost_sniper);
		}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	bool isServer = getNet().isServer();

	if (cmd == this.getCommandID("shop buy"))
	{
		u16 callerID;
		if (!params.saferead_u16(callerID))
			return;
		bool spawnToInventory = params.read_bool();
		bool spawnInCrate = params.read_bool();
		bool producing = params.read_bool();
		string blobName = params.read_string();		
		u8 s_index = params.read_u8();
						
		// check spam
		//if (blobName != "factory" && isSpammed( blobName, this.getPosition(), 12 ))
		//{				
		//}
		//else
		{
			this.getSprite().PlaySound("/ConstructShort" );
		}
	}
}

//sprite - planks layer

void onInit(CSprite@ this)
{
	this.SetZ(50); //foreground
	
	CBlob@ blob = this.getBlob();
	CSpriteLayer@ planks = this.addSpriteLayer( "planks", this.getFilename() , 16, 16, blob.getTeamNum(), blob.getSkinNum() );

    if (planks !is null)
    {
        Animation@ anim = planks.addAnimation( "default", 0, false );
        anim.AddFrame(6);
        planks.SetOffset( Vec2f(3.0f,-7.0f) );
        planks.SetRelativeZ( -100 );
    }
}
