CBlob@ getRoster(){

	CBlob@[] blobs;
	
	getBlobsByName("roster", blobs);
	
	if(blobs.length > 0)return blobs[0];
	return null;

}

void addPlayerToRoster(CBlob@ this, CPlayer@ player){

	//this.Tag(player.getUsername()+"_canspawn");
	this.set_string(player.getUsername()+"_race","none");
	print("Added "+player.getUsername()+" to the roster.");

}

void setPlayerRace(CBlob@ this, CPlayer@ player, string race){

	this.Tag(player.getUsername()+"_canspawn");
	this.set_string(player.getUsername()+"_race",race);
	print("Allowing "+player.getUsername()+" to spawn and set thier race to: "+race);

}

string getPlayerRace(CBlob@ this, CPlayer@ player){
	
	return this.get_string(player.getUsername()+"_race");

}