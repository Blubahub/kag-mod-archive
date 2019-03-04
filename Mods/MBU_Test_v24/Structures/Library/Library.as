
void onInit(CSprite@ this)
{
	// Building
	this.SetZ(-50); //-60 instead of -50 so sprite layers are behind ladders
}

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_wood_back);
	//this.getSprite().getConsts().accurateLighting = true;

	
	this.getShape().getConsts().mapCollisions = false;
	this.getCurrentScript().tickFrequency = 60;

	this.Tag("builder always hit");
	
	this.addCommandID("open");
	this.addCommandID("research");
	this.addCommandID("write");
	this.addCommandID("read");
	
	this.set_u8("books",0);
	
	this.SetFacingLeft(false);
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	
	CButton@ button = caller.CreateGenericButton(23, Vec2f(0,0), this, this.getCommandID("open"), "Browse", params);
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params ){
	if (cmd == this.getCommandID("open"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null && caller.getPlayer() is getLocalPlayer())
		{

			CGridMenu@ menu = CreateGridMenu(getDriver().getScreenCenterPos() + Vec2f(0.0f, 0.0f), this, Vec2f(2, 2), "Bookshelf");
			if (menu !is null)
			{
				CBitStream params;
				params.write_u16(caller.getNetworkID());

				for(int i = 0;i <8;i++){
					if(this.hasTag("researched_"+i)){
						CBitStream params;
						params.write_u8(i);
						params.write_u16(caller.getNetworkID());
						menu.AddButton("ResearchBooks.png", i, "Read", this.getCommandID("read"),params);
					}
				}
				
				menu.AddButton("Research.png", 0, "Conduct research", this.getCommandID("research"),params);
			}
		}
	}
	
	if (cmd == this.getCommandID("research"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null && caller.getPlayer() is getLocalPlayer())
		{

			CGridMenu@ menu = CreateGridMenu(getDriver().getScreenCenterPos() + Vec2f(0.0f, 0.0f), this, Vec2f(4, 2), "Research");
			if (menu !is null)
			{
				for(int i = 0;i <8;i++){
					if(caller.hasTag(research_tag_needed[i])){
						if(!this.hasTag("researched_"+i)){
							CBitStream params;
							params.write_u8(i);
							menu.AddButton("Research.png", 2+i, "Research: "+research_name[i], this.getCommandID("write"),params);
						} else {
							menu.AddButton("Research.png", 2+i, "Researched", this.getCommandID("research")).SetEnabled(false);
						}
					} else {
						menu.AddButton("Research.png", 1, "Research", this.getCommandID("research")).SetEnabled(false);
					}
				}
			}
		}
	}
	
	if (cmd == this.getCommandID("write"))
	{
		int research = params.read_u8();
		
		if(!this.hasTag("researched_"+research)){
			int books = this.get_u8("books");
			if(books < 4){
				CSprite @sprite = this.getSprite();
				if(sprite !is null){
					Vec2f[] pos = {
						Vec2f(3,-2),
						Vec2f(-2,-2),
						Vec2f(3,5),
						Vec2f(-2,5)
					};
					
					CSpriteLayer @book = sprite.addSpriteLayer(research_name[research], "LibraryBooks.png", 6, 4, 0 ,0);
					if(book !is null){
						book.SetFrame(research);
						book.SetOffset(pos[books]);
					}
					
				}
			}
			books += 1;
			this.set_u8("books",books);
		}
		
		this.Tag("researched_"+research);
	}
	
	if (cmd == this.getCommandID("read"))
	{
		int research = params.read_u8();
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if(caller !is null)
		{
			caller.Tag("researched_"+(research_name[research].toLower()));
		
			if(caller.getPlayer() is getLocalPlayer()){
				CGridMenu@ menu = CreateGridMenu(getDriver().getScreenCenterPos() + Vec2f(0.0f, 0.0f), this, Vec2f(5, 6), "Research");
				menu.SetCaptionEnabled(false);
				if (menu !is null)
				{
					menu.AddTextButton(research_text[research], Vec2f(5,6));
				}
			}
		}
	}
}

string[] research_text = {
	"\n\n\n\n\n\n\n\n\n\n\n\n\nLife\n----\n\nWisps are commonplace\nin our world, but up till\nnow no one's been sure\nof what makes them tick.\nRecent findings suggests\nwisps are the pure\nmanifestation of\nlife itself.\nThis has some bizarre\nimplications, if life can\nexist without a vessel,\ncan it be infused\nor even...\nremoved from one?\n\nFurther investigation is\nrequired, potentially\ntrying to ingest a\nwisp's life force in a\nway that doesn't burn\nmight be a good\nfirst step.",
	
	
	"\n\n\n\n\n\n\n\n\n\n\n\n\nDeath\n----\n\nMemories, ghosts of the\ndead, have been around\nsince the unsealing,\nhowever, without the use\nof a memorial stone, they\nremain complete invisible.\nI recently discovered\nectoplasm, a strange\nalmost ethereal slimey\ngoo. It shares many\nvisual similarities\nto memories, so I\nbelieve they are related.\n\nI've fomulated a theory\nthat ectoplasm, when\ningested, may provide\nsight into the world\nof the dead. However,\nI fear it may be too\npoisoness to do so.",
	
	
	"\n\n\n\n\n\n\n\n\nFire\n----\n\nI recently found myself\non fire, a rather\npainful situation.\n\nHowever, as I found myself\nburning, I saw something\nthrough the flames. I'm not\nsure what it was, but\nvisions of it keep haunting\nme. I find myself constantly\nstaring at lanterns to\ntry and see it again.",
	
	
	"\n\n\n\n\n\n\n\n\nFlow\n----\n\nNot yet implemented.",
	
	
	"\n\n\n\n\n\n\n\n\nGold\n----\n\nGold, the most\nvaluable substance on\nearth. A near useless metal\nbarring electrical applications.\n\nOccasionally, a near weightless\nfloating version is found.\nIt seems to hold all the same\nproperties as normal gold,\nhowever it faintly glows with\na white-yellow light.\n\nThere's a myth that there\nused to be an entire\ncity made of gold\nwith altars dedicated to the\nlight it produces.",
	
	
	"\n\n\n\n\n\n\n\n\nDarkness\n----\n\nI've... killed a man.\nI've never felt more\nguilty in my whole life.\nTo take someone else's life...\nIt's just so wrong.\n\nHowever, no matter what I\ndo, there seems to be this...\nItch at the back of my\nhead, urging me to do it\nagain. Am I evil to be\nthinking this way?\n\nI don't want to become\na vile murderer...\nas well...",
	
	
	"\n\n\n\n\n\n\n\n\nNature\n----\n\nNot yet implemented.",
	
	
	"\n\n\n\n\n\n\n\n\n\n\n\n\nBlood\n----\n\nThe liquid substance flowing\nthrough all humans, without\nexception. Loss of blood has\nproven to be rather fatal in\nmost cases, however, I believe\nI have made a discovery. It\nseems if one consumes\nblood directly, then the blood\nimmediatly enters one's blood\nstream, no need for digestion.\nWith this knowledge, we could\npotentially save hundreds of\nlives!\n\nI have one concern however, it\nseem this method may be\nslightly... addictive. Patients\nshould drink no more than 2-3,\nmaximum 4 jars, at a time, until\na  cure for the addictive nature\ncan be found."
};

string[] research_name = {
	"Life",
	"Death",
	"Heat",
	"Flow",
	"Gold",
	"Darkness",
	"Nature",
	"Blood",
};

string[] research_tag_needed = {
	"life_knowledge",
	"death_knowledge",
	"fire_knowledge",
	"water_knowledge",
	"gold_knowledge",
	"dark_knowledge",
	"nature_knowledge",
	"blood_knowledge",
};