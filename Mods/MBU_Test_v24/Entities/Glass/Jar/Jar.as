
void onInit(CBlob@ this)
{
	if(getNet().isServer())this.server_setTeamNum(0);
	
	this.Tag("jar");
	
	this.addCommandID("empty");
	this.addCommandID("fill");
	this.addCommandID("drink");
	this.addCommandID("merge");
	
	this.set_u8("meat",0);
	this.set_u8("plant",0);
	this.set_u8("starch",0);
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(this.getName() != "jar"){
		CBlob @carry = caller.getCarriedBlob();
		if(carry is this){
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			
			caller.CreateGenericButton(19, Vec2f(0,0), this, this.getCommandID("empty"), "Empty Contents",params);
		} else {
			if(carry !is null)if(carry.hasTag("jar")){
				CBitStream params;
				params.write_u16(caller.getNetworkID());
				
				caller.CreateGenericButton(8, Vec2f(0,0), this, this.getCommandID("merge"), "Mix",params);
			}
		}
	}
	
	if(this.getName() == "jar")
	if(caller.getCarriedBlob() !is null && caller.getCarriedBlob() !is this){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		
		CButton@ button = caller.CreateGenericButton(20, Vec2f(0,0), this, this.getCommandID("fill"), "Insert", params);
	}
}


void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("fill"))
	{	
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null)
		{
			CBlob@ hold = caller.getCarriedBlob();
			if(hold !is null){
				if(getNet().isServer())
				if(!this.hasTag("filled")){
					if(hold.getName() == "flower_bundle"){
						this.server_Die();
						CBlob @jar = server_CreateBlob("dye_jar",0,this.getPosition());
						jar.set_s8("contents", hold.getTeamNum());
						jar.Sync("contents",true);
						hold.server_Die();
						this.Tag("filled");
					}
					if(hold.hasTag("can_dye") && this.getName() == "dye_jar"){
						hold.server_setTeamNum(this.get_s8("contents"));						
						this.server_Die();
						server_CreateBlob("jar",0,this.getPosition());
						this.Tag("filled");
					}
					if(hold.getName() == "chicken" && hold.hasTag("dead")){
						this.server_Die();
						CBlob @jar = server_CreateBlob("blood_jar",0,this.getPosition());
						hold.Tag("butchered");
						hold.server_Die();
						this.Tag("filled");
					}
					if(hold.getName() == "w"){
						this.server_Die();
						CBlob @jar = server_CreateBlob("wj",0,this.getPosition());
						hold.server_Die();
						this.Tag("filled");
					}
					if(hold.getName() == "p"){
						this.server_Die();
						CBlob @jar = server_CreateBlob("emj",0,this.getPosition());
						hold.server_Die();
						this.Tag("filled");
					}
					if(hold.getName() == "fishy" || hold.getName() == "fish_stick"){
						this.server_Die();
						CBlob @jar = server_CreateBlob("oil_jar",0,this.getPosition());
						hold.server_Die();
						this.Tag("filled");
					}
				}
				
				if(getNet().isClient())if(hold.hasTag("can_dye") && this.getName() == "dye_jar")this.getSprite().PlaySound("wetfall1.ogg");
			}
		}
	}
	
	if (cmd == this.getCommandID("merge"))
	{	
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null)
		{
			CBlob@ hold = caller.getCarriedBlob();
			if(hold !is null){
				if(getNet().isServer())
				if(!this.hasTag("filled")){
					string result = Alchemy(hold.getName(),this.getName());
					if(result != "none"){
						this.server_Die();
						hold.server_Die();
						this.Tag("filled");
						
						server_CreateBlob(result,0,this.getPosition());
						caller.server_Pickup(server_CreateBlob(result,0,this.getPosition()));
					}
				}
			}
		}
	}
	
	if (cmd == this.getCommandID("empty"))
	{	
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null)
		{
			if(getNet().isServer())
			if(!this.hasTag("emptied")){
				this.server_Die();
				caller.server_Pickup(server_CreateBlob("jar",0,this.getPosition()));
				this.Tag("emptied");
			}
			
			if(getNet().isClient())this.getSprite().PlaySound("wetfall1.ogg");
		}
	}
}

string Alchemy(string ingrediant, string ingrediant2){
	
	for(int i = 0;i < 2;i++){
	
		if(i > 0){
			string temp = ingrediant;
			ingrediant = ingrediant2;
			ingrediant2 = temp;
		}
	
		if(ingrediant == "wj" && ingrediant2 == "oil_jar"){
			return "woj";
		}
	
	}
	
	return "none";
}