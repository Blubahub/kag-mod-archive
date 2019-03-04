

void onTick(CRules @this){

	if(this.hasTag("electric_grid_recal")){

		this.Untag("electric_grid_recal");
	
		CBlob@[] blobs;	   
		getBlobsByName("power_node", @blobs);
		for (uint i = 0; i < blobs.length; i++)
		{
			CBlob@ b = blobs[i];
			if(b !is null){
				u16[] @Connections;
				if(b.get("connections",@Connections)){
					for (uint j = 0; j < Connections.length; j++)
					{
						CBlob @con = getBlobByNetworkID(Connections[j]);
						if(con !is null){
							if(con.get_u16("grid_id") > b.get_u16("grid_id")){
								b.set_u16("grid_id",con.get_u16("grid_id"));
								this.Tag("electric_grid_recal");
							}
						}
					}
				}
			}
		}
	}
	
	int[] grid;
	
	CBlob@[] blobs;	   
	getBlobsByTag("grid_blob", @blobs);
	for (uint i = 0; i < blobs.length; i++)
	{
		CBlob@ b = blobs[i];
		if(b !is null){
			int id = b.get_u16("grid_id");
			bool found = false;
			
			for (uint j = 0; j < grid.length; j++)
			{
				if(grid[j] == id)found = true;
			}
			
			if(!found)grid.push_back(id);
		}
	}
	
	for (uint j = 0; j < grid.length; j++)
	{
		f32 watts_needed = 0.0f;
		f32 power = 0.0f;
		
		CBlob@[] blobs;	   
		getBlobsByTag("grid_blob", @blobs);
		for (uint i = 0; i < blobs.length; i++)
		{
			CBlob@ b = blobs[i];
			if(b !is null && b.get_u16("grid_id") == grid[j]){
				if(b.exists("watts_needed")){
					watts_needed += b.get_u16("watts_needed");
				}
				if(b.exists("power")){
					power += b.get_u16("power");
				}
			}
		}
		
		if(watts_needed > 0)this.set_f32("grid_"+grid[j]+"_power_ratio",power/watts_needed);
		else this.set_f32("grid_"+grid[j]+"_power_ratio",1.0f);
		this.set_u16("grid_"+grid[j]+"_power",power);
		this.set_u16("grid_"+grid[j]+"_watts_needed",watts_needed);
		
		if(getNet().isServer()){
			this.Sync("grid_"+grid[j]+"_power_ratio",true);
			this.Sync("grid_"+grid[j]+"_power",true);
			this.Sync("grid_"+grid[j]+"_watts_needed",true);
		}
	}
}