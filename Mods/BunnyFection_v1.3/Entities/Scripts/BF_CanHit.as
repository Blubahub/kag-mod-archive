//_always hit: it will get hit even if it's on the same team
//_never hit: it won't get hit even if on different teams

const string[] bunny_alwayshit = {  
    //buildings
    //"bf_workbench",
    //"bf_anvil",
    //"bf_forge",
    //"bf_workshop",
	//nature
	"bf_carrotplant",
	"bf_shrubplant",
};

const string[] bunny_neverhit = {
	//non-flesh things
	"tree_pine",
	"tree_bushy",
};


const string[] mutant_alwayshit = {
	"bf_gooball",
};

const string[] mutant_neverhit = {
	"bush",
	"grain_plant",
	"tree_pine",
	"tree_bushy",
	"bf_shrubplant",
	"bf_carrotplant",
	"bf_rootstatic",
};

bool searchBlobList( CBlob@ blob, const string[] @blobList )
{
	string name = blob.getName();
	for (uint i = 0; i < blobList.length; ++i)
	{
		if (blobList[i] == name)
			return true;
	}
	return false;
}

/////MUTANT STUFF

bool mutantCanHitMap( CBlob@ this, CMap@ map, Tile tile )
{
	string name = this.getName();
	if ( name == "bf_mutant1" && ( map.isTileGroundStuff( tile.type ) || map.isTileGrass( tile.type) ) )
		return false;
	else
		return true;
}

bool mutantCanHit( CBlob@ this, CBlob@ hitBlob )
{
	if ( hitBlob.getTeamNum() == this.getTeamNum() )
		return searchBlobList( hitBlob,  @mutant_alwayshit );
	else
		return !searchBlobList( hitBlob,  @mutant_neverhit );
}

///BUNNYSTUFF
bool bunnyCanHitMap( CBlob@ this, CMap@ map, Tile tile )
{
	return !map.isTileThickStone( tile.type ) && !map.isTileGold( tile.type );
}

bool bunnyCanHit( CBlob@ this, CBlob@ hitBlob )
{
	//print( "hit blob name: " + hitBlob.getName() );
	if ( hitBlob.hasTag( "flesh" ) )
		return false;
	if ( hitBlob.getTeamNum() == this.getTeamNum() )
		return hitBlob.hasTag( "block" ) || searchBlobList( hitBlob,  @bunny_alwayshit );
	else
		return !searchBlobList( hitBlob,  @bunny_neverhit );
}