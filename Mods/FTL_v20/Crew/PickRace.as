
#include "RosterCommon.as";

void onInit(CBlob @ this){
	
    this.addCommandID("picked_human");
	this.addCommandID("picked_engi");
	this.addCommandID("picked_zoltan");
	this.addCommandID("picked_mantis");
	this.addCommandID("picked_rock");
	this.addCommandID("picked_slug");
	
	AddIconToken("$human_icon$", "CrewIcons.png", Vec2f(32,32), 0);
	AddIconToken("$engi_icon$", "CrewIcons.png", Vec2f(32,32), 1);
	AddIconToken("$zoltan_icon$", "CrewIcons.png", Vec2f(32,32), 2);
	AddIconToken("$mantis_icon$", "CrewIcons.png", Vec2f(32,32), 3);
	AddIconToken("$rock_icon$", "CrewIcons.png", Vec2f(32,32), 4);
	AddIconToken("$slug_icon$", "CrewIcons.png", Vec2f(32,32), 5);
	
}

void onTick(CBlob @ this){
	
	if(!getNet().isClient())return;
	
	CBlob @roster = getRoster();
	
	if(roster is null)return;
	
	if(getGridMenuByName("Pick your race") is null && getLocalPlayer() !is null && getPlayerRace(roster,getLocalPlayer()) == "none"){
		CGridMenu@ menu = CreateGridMenu(Vec2f(getScreenWidth()/2,getScreenHeight()/2), this, Vec2f(12,2), "Pick your race");
		
		CBitStream params;
		params.write_string(getLocalPlayer().getUsername());
		
		print("test");
		
		menu.AddButton("$human_icon$", "Human", this.getCommandID("picked_human"),params).hoverText = "Humans are common and uninteresting.\n\n- Skills improve 10% faster (not yet implemented)";
		menu.AddButton("$engi_icon$", "Engi", this.getCommandID("picked_engi"),params).hoverText = "It's unclear if the Engi are partly organic or entirely mechanical, but it's well known that they make exceptional engineers.\n\n- Repair speed is doubled (not yet implemented)\n- Combat damage is halved. (lol, what combat)";
		menu.AddButton("$zoltan_icon$", "Zoltan", this.getCommandID("picked_zoltan"),params).hoverText = "The Zoltan are allies of the Engi. Their innate energy can power ship systems.\n\n- Provides power to occupied system (not yet implemented)\n- Explodes upon death, dealing 15 damage to each enemy in room (lol, what enemies)\n- 70% Health";
		menu.AddButton("$mantis_icon$", "Mantis", this.getCommandID("picked_mantis"),params).hoverText = "The Mantis disregard for individual lives led to their evolution as a vicious warrior race.\n\n- Combat damage is increased by 50% (lol, what combat)\n- 120% Movement speed\n- Repair speed halved (not yet implemented)";
		menu.AddButton("$rock_icon$", "Rock", this.getCommandID("picked_rock"),params).hoverText = "The Rockmen of Vrachos IV are rarely seen and are known for their fortitude.\n\n- Immune to fire\n- 150% Health\n- 50% Movement speed";
		menu.AddButton("$slug_icon$", "Slug", this.getCommandID("picked_slug"),params).hoverText = "These telepathic Slugs were shunned in the Galactic Federation for their constant thievery and attempts at manipulation.\n\n- Telepathic powers reveal rooms and other lifeforms. (not yet implemented)";
	}
	
	
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	bool isServer = getNet().isServer();

	if (cmd == this.getCommandID("picked_human"))
	{
		
		CPlayer@ player = getPlayerByUsername(params.read_string());
		
		CBlob @roster = getRoster();
	
		if(roster is null)return;
		
		setPlayerRace(roster,player,"human");
	}
	
	if (cmd == this.getCommandID("picked_engi"))
	{
		
		CPlayer@ player = getPlayerByUsername(params.read_string());
		
		CBlob @roster = getRoster();
	
		if(roster is null)return;
		
		setPlayerRace(roster,player,"engi");
	}
	
	if (cmd == this.getCommandID("picked_zoltan"))
	{
		
		CPlayer@ player = getPlayerByUsername(params.read_string());
		
		CBlob @roster = getRoster();
	
		if(roster is null)return;
		
		setPlayerRace(roster,player,"zoltan");
	}
	
	if (cmd == this.getCommandID("picked_mantis"))
	{
		
		CPlayer@ player = getPlayerByUsername(params.read_string());
		
		CBlob @roster = getRoster();
	
		if(roster is null)return;
		
		setPlayerRace(roster,player,"mantis");
	}
	
	if (cmd == this.getCommandID("picked_rock"))
	{
		
		CPlayer@ player = getPlayerByUsername(params.read_string());
		
		CBlob @roster = getRoster();
	
		if(roster is null)return;
		
		setPlayerRace(roster,player,"rock");
	}
	
	if (cmd == this.getCommandID("picked_slug"))
	{
		
		CPlayer@ player = getPlayerByUsername(params.read_string());
		
		CBlob @roster = getRoster();
	
		if(roster is null)return;
		
		setPlayerRace(roster,player,"slug");
	}
}