void onInit( CBlob@ this )
{
    //these don't actually use it, they take the controls away
	this.push("names to activate", "mega_lantern");	
	this.push("names to activate", "lantern");	
	this.push("names to activate", "mega_bomb");
	this.push("names to activate", "medkit");		
	this.push("names to activate", "satchel");
	this.push("names to activate", "mini_keg");
	this.push("names to activate", "invis_potion");
	this.push("names to activate", "light_potion");

	this.getCurrentScript().runFlags |= Script::remove_after_this;
}
