void onInit( CBlob@ this )
{
    //these don't actually use it, they take the controls away
	this.push("names to activate", "lantern");	
	this.push("names to activate", "bluelantern");
	this.push("names to activate", "darklantern");
	this.push("names to activate", "bomb_satchel");
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}
