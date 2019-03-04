// Storage.as

void onInit(CSprite@ this)
{
	// Building
	this.SetZ(-60); //-60 instead of -50 so sprite layers are behind ladders

}

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);
	this.getShape().getConsts().mapCollisions = false;
	AddIconToken("$read$", "Glasses.png", Vec2f(16, 16), 0);
	this.inventoryButtonPos = Vec2f(12, 0);
	this.addCommandID("writebook");
	this.getCurrentScript().tickFrequency = 60;
	
	this.set_s16("timer",0);
}

void onTick(CBlob@ this)
{
	if(this.get_s16("timer") > 0)this.set_s16("timer",this.get_s16("timer")-1);
	PickupOverlap(this);
}

void PickupOverlap(CBlob@ this)
{
	if (getNet().isServer())
	{
		Vec2f tl, br;
		this.getShape().getBoundingRect(tl, br);
		CBlob@[] blobs;
		this.getMap().getBlobsInBox(tl, br, @blobs);
		for (uint i = 0; i < blobs.length; i++)
		{
			CBlob@ blob = blobs[i];
			if (!blob.isAttached() && blob.isOnGround() && blob.hasTag("book"))
			{
				this.server_PutInInventory(blob);
			}
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if(caller.getTeamNum() == this.getTeamNum() && caller.isOverlapping(this))
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		caller.CreateGenericButton("$read$", Vec2f(-6, 0), this, this.getCommandID("writebook"), "Attempt to write a book.", params);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (getNet().isServer())
	{
		if (cmd == this.getCommandID("writebook"))
		if(this.get_s16("timer") <= 0){
			CBlob@ caller = getBlobByNetworkID(params.read_u16());
			if (caller !is null){
				CPlayer@ player = caller.getPlayer();
				if (player !is null)
				{
					if(XORRandom(100) < player.get_s16("book_level")*5){
					
						int makebook = 0;
						
						CBlob@[] blobsInRadius;	   
						if (this.getMap().getBlobsInRadius(this.getPosition(), 64.0f, @blobsInRadius)) 
						{
							CBlob@ b = blobsInRadius[XORRandom(blobsInRadius.length)];
							if(itemType(b.getName()) == 10 || itemType(b.getName()) == 11)makebook = 3;
							if(b.hasTag("player")){
								if(b.hasTag("dead"))makebook = 1;
								else makebook = 2;
							}
						}
						
						if(makebook == 1){
							CBlob @newBlob = server_CreateBlob("deathbook", 0, this.getPosition());
						}
						
						if(makebook == 2){
							CBlob @newBlob = server_CreateBlob("gravbook", 0, this.getPosition());
						}
						
						if(makebook == 3){
							CBlob @newBlob = server_CreateBlob("elembook", 0, this.getPosition());
						}
					
					}else {

						CBlob @newBlob = server_CreateBlob("book", 0, this.getPosition());
						
						int booktype = 0;
						
						int level = 0;
						
						level = player.get_s16("book_level")+XORRandom(3)-1;
						
						if(level > player.get_s16("book_level"))if(XORRandom(3) == 0)player.set_s16("book_level",player.get_s16("book_level")+1);
						
						CBlob@[] blobsInRadius;	   
						if (this.getMap().getBlobsInRadius(this.getPosition(), 64.0f, @blobsInRadius)) 
						{
							CBlob@ b = blobsInRadius[XORRandom(blobsInRadius.length)];
							booktype = itemType(b.getName());
							if(b.hasTag("player")){
								if(b.hasTag("dead"))booktype = 8;
								else booktype = 7;
							}
						}
						
						string name = "The book";
						
						switch(booktype){
							case 0:{
								name = "Why Pirate-Rob is cool";
								if(XORRandom(1) == 0)name = "A funny tale";
								if(XORRandom(1) == 0)name = "Walls are important";
								if(XORRandom(1) == 0)name = "Knights are too strong";
								if(XORRandom(1) == 0)name = "How I eat food";
								if(XORRandom(1) == 0)name = "How to pee over a ledge proply";
								if(XORRandom(1) == 0)name = "How to swim (without drown)";
							break;}
							
							case 1:{
								name = "Why arrows are sharp";
								if(XORRandom(1) == 0)name = "Archers are too strong";
								if(XORRandom(1) == 0)name = "Arr0wz 4r3 b4d p3nz";
								if(XORRandom(1) == 0)name = "Why people shouldn't leave arrows lying around";
							break;}
							
							case 2:{
								name = "Bombs and you";
								if(XORRandom(1) == 0)name = "Bomb bouncing";
								if(XORRandom(1) == 0)name = "Bomb jumping";
								if(XORRandom(1) == 0)name = "Bombs for idiots";
								if(XORRandom(1) == 0)name = "Bombs for dummies";
								if(XORRandom(1) == 0)name = "Too many kegs";
							break;}
							
							case 3:{
								name = "Gold is good";
								if(XORRandom(1) == 0)name = "Gold is glory";
								if(XORRandom(1) == 0)name = "Gold is golden";
								if(XORRandom(1) == 0)name = "Gold shines a lot";
								if(XORRandom(1) == 0)name = "I think of stealing gold too much";
							break;}
							
							case 4:{
								name = "Leaves taste bad";
								if(XORRandom(1) == 0)name = "Grass is gross with food";
								if(XORRandom(1) == 0)name = "Grass tastes bad";
								if(XORRandom(1) == 0)name = "Grass is soft";
								if(XORRandom(1) == 0)name = "Trees are nice and shady";
							break;}
							
							case 5:{
								name = "Splinters and you";
								if(XORRandom(1) == 0)name = "Wood is hard";
								if(XORRandom(1) == 0)name = "Wood, hehehehe";
								if(XORRandom(1) == 0)name = "Why chopping wood is a good life choice";
								if(XORRandom(1) == 0)name = "Make trees fall AWAY from you";
							break;}
							
							case 6:{
								name = "Stone is hard";
								if(XORRandom(1) == 0)name = "Stone tastes bad";
								if(XORRandom(1) == 0)name = "My life is stone walls";
								if(XORRandom(1) == 0)name = "Everything I see is stone now";
								if(XORRandom(1) == 0)name = "Using rocks is a good way to practize making out";
							break;}
							
							case 7:{
								name = "My lyf story";
								if(XORRandom(1) == 0)name = "My friend Bob";
								if(XORRandom(1) == 0)name = "My teammates are dweebs";
								if(XORRandom(1) == 0)name = "My team colour would look better in blue";
								if(XORRandom(1) == 0)name = "Why are people stupud";
								if(XORRandom(1) == 0)name = "Griefer!";
							break;}
							
							case 8:{
								name = "Death is bad for your life";
								if(XORRandom(1) == 0)name = "Death is bad for your body";
								if(XORRandom(1) == 0)name = "Dead people look wierd";
								if(XORRandom(1) == 0)name = "My friend won't wake up";
								if(XORRandom(1) == 0)name = "Medical 101";
								if(XORRandom(1) == 0)name = "Teamkiller!";
							break;}
							
							case 9:{
								name = "My best friend chicken";
								if(XORRandom(1) == 0)name = "Sylw's farming 101 guide";
								if(XORRandom(1) == 0)name = "Buck buck buuuuuck";
							break;}
							
							case 10:{
								name = "Fire is hot";
								if(XORRandom(1) == 0)name = "Why you shouldn't stick your hand in fire";
								if(XORRandom(1) == 0)name = "I NEED WATER";
							break;}
							
							case 11:{
								name = "Why drowing is bad, part 1";
								if(XORRandom(1) == 0)name = "Why drowing is bad, part 2";
								if(XORRandom(1) == 0)name = "Water is good for drinking and a quick piss";
							break;}
						}
						
						switch(level){
						
							case -1:{
								name = "Random Scribblings";
								if(XORRandom(1) == 0)name = "Writing?";
							break;}
							
							case 0:{
								name = "Sky iz blu?";
								if(XORRandom(1) == 0)name = "Wat iz dirt";
								if(XORRandom(1) == 0)name = "My naem iz bob";
							break;}
						}
						
						
						newBlob.set_string("name",name);
						
						newBlob.set_string("author",player.getUsername());
						
						newBlob.set_s16("type",booktype);
						newBlob.set_s16("level",level);
						
						this.set_s16("timer",3);
					
					}
				}
			}
		}
	}
}

int itemType(string name){

	if(name == "keg" || name == "mat_bomb" || name == "mat_bombarrows")return 2;
	
	if(name == "mat_gold" || name == "herosword" || name == "goldenorb" || name == "goldenfish" || name == "goldenstatue")return 3;

	if(name == "mat_waterarrows" || name == "mat_firearrows" || name == "mat_bombarrows" || name == "mat_arrows")return 1;
	
	if(name == "grain" || name == "tree_bushy" || name == "tree_pine" || name == "flowers" || name == "bush")return 4;
	
	if(name == "mat_wood" || name == "wooden_door" || name == "platform")return 5;
	
	if(name == "mat_stone" || name == "stone_door")return 6;
	
	if(name == "chicken" || name == "shark" || name == "bison")return 9;
	
	if(name == "lantern" || name == "mat_firearrows")return 10;
	if(name == "bucket")return 11;
	
	return 0;
}

void onDie(CBlob@ this)
{
	if (this.exists("lantern id"))
	{
		CBlob@ lantern = getBlobByNetworkID(this.get_u16("lantern id"));
		if (lantern !is null)
		{
			lantern.server_Die();
		}
	}
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return (forBlob.getTeamNum() == this.getTeamNum() && forBlob.isOverlapping(this));
}