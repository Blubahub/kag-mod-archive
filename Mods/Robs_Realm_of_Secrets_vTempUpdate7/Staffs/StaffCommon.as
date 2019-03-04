void onInit(CSprite@ this)
{
	this.RemoveSpriteLayer("basestaff");
	CSpriteLayer@ basestaff = this.addSpriteLayer("basestaff", "StaffBase.png" , 16, 16, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (basestaff !is null)
	{
		Animation@ anim = basestaff.addAnimation("default", 0, false);
		basestaff.SetOffset(Vec2f(0, 0));
		basestaff.SetAnimation("default");
		basestaff.SetVisible(true);
		basestaff.SetRelativeZ(-1.5f);
	}
	
	this.SetZ(5.0f);
}

void onTick(CSprite@ this){
	CBlob @ blob = this.getBlob();
	
	if(blob is null)return;
	
	if(this.getSpriteLayer("basestaff") !is null){
		this.getSpriteLayer("basestaff").SetFrame(blob.get_u8("staffbase"));
	}
	
	if (!blob.isAttached()){
		if(this.getSpriteLayer("basestaff") !is null){
			this.getSpriteLayer("basestaff").SetOffset(Vec2f(0, 0));
		}
	} else {
		if(this.getSpriteLayer("basestaff") !is null){
			this.getSpriteLayer("basestaff").SetOffset(Vec2f(7, 1));
			//this.getSpriteLayer("basestaff").SetOffset(blob.getAttachments().getAttachmentPointByName("PICKUP").offset*-0.5);
		}
	}

}

void onInit(CBlob@ this)
{
	this.addCommandID("equip");
	this.addCommandID("combine");
	this.Tag("staff");
	
	this.set_f32("power",1);
	
	this.set_u8("staffbase",1);
	//0 - wood
	//1 - burnt wood
	//2 - metal/stone
	//3 - gold
}

void onTick(CBlob@ this){

	if (this.isAttached()){
	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	CBlob@ holder = point.getOccupied();
	if(holder !is null){
	
		f32 distance = Maths::Sqrt((Maths::Pow(holder.getAimPos().x-holder.getPosition().x,2))+(Maths::Pow(holder.getAimPos().y-holder.getPosition().y,2)));
		if(distance > 250)distance = 250.0;
		distance = 1.0-(distance/(250.0));
		
		if(this.get_u8("staffbase") == 0){
			distance = distance*0.25;
		}
		
		if(this.get_u8("staffbase") == 1){
			distance = distance*0.50;
		}
		
		if(this.get_u8("staffbase") == 2){
			distance = distance*0.75;
		}
		
		if(this.get_u8("staffbase") == 3){
			distance = distance*1.0;
		}
		
		if(distance < 0)distance = 0;
		
		this.set_f32("power",distance);
	
	}}
	
	
	bool isFire = (this.getName().find("fire") != -1);
	if(this.getName() == "bad_staff")isFire = true;
	
	if(isFire && this.get_u8("staffbase") == 0)this.set_u8("staffbase",1);
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(caller.getCarriedBlob() is this){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		
		CButton@ button = caller.CreateGenericButton(11, Vec2f(0,0), this, this.getCommandID("equip"), "Equip staff", params);
	} else 
	if(caller.getCarriedBlob() !is null)
	if(caller.getCarriedBlob().hasTag("staff")){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		
		CButton@ button = caller.CreateGenericButton(16, Vec2f(0,0), this, this.getCommandID("combine"), "Combine staffs", params);
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	CBlob@ caller = getBlobByNetworkID(params.read_u16());
	if(caller !is null)
	{
		if (cmd == this.getCommandID("equip"))
		{
			caller.DropCarried();
			caller.server_AttachTo(this, "STAFF");
		}
		if (cmd == this.getCommandID("combine"))
		if(caller.getCarriedBlob() !is null){
			if(CombineStaffs(this, this.getName(),caller.getCarriedBlob().getName(),Maths::Max(caller.getCarriedBlob().get_u8("staffbase"),this.get_u8("staffbase")))){
				CBlob @staff = server_CreateBlob("staff", this.getTeamNum(), this.getPosition());
				staff.set_u8("staffbase",Maths::Min(caller.getCarriedBlob().get_u8("staffbase"),this.get_u8("staffbase")));
				caller.getCarriedBlob().server_Die();
				this.server_Die();
			}
		}
	}
}

bool CombineStaffs(CBlob@ this, string name, string name2, int base){
	if(getNet().isServer()){
		if(name+":"+name2 == "fire_staff:life_staff" || name2+":"+name == "fire_staff:life_staff"){
			CBlob @staff = server_CreateBlob("lifefire_staff", this.getTeamNum(), this.getPosition());
			staff.set_u8("staffbase",base);
			return true;
		}
		
		if(name+":"+name2 == "water_staff:life_staff" || name2+":"+name == "water_staff:life_staff"){
			CBlob @staff = server_CreateBlob("waterlife_staff", this.getTeamNum(), this.getPosition());
			staff.set_u8("staffbase",base);
			return true;
		}
		
		if(name+":"+name2 == "fire_staff:stone_staff" || name2+":"+name == "fire_staff:stone_staff"){
			CBlob @staff = server_CreateBlob("firestone_staff", this.getTeamNum(), this.getPosition());
			staff.set_u8("staffbase",base);
			return true;
		}
		
		if(name+":"+name2 == "evil_staff:plant_staff" || name2+":"+name == "evil_staff:plant_staff"){
			CBlob @staff = server_CreateBlob("evilplant_staff", this.getTeamNum(), this.getPosition());
			staff.set_u8("staffbase",base);
			return true;
		}
		
		if(name+":"+name2 == "gold_staff:blood_staff" || name2+":"+name == "gold_staff:blood_staff"){
			CBlob @staff = server_CreateBlob("goldblood_staff", this.getTeamNum(), this.getPosition());
			staff.set_u8("staffbase",base);
			return true;
		}
		
		//if(name+":"+name2 == "death_staff:gold_staff"){
		//	CBlob @wraithstaff = server_CreateBlob("golddeath_staff", this.getTeamNum(), this.getPosition()); 
		//	wraithstaff.set_string("ghost",this.get_string("ghost"));
		//	return true;
		//}
		
		if(name+":"+name2 == "death_staff:water_staff"){
			CBlob @wraithstaff = server_CreateBlob("waterdeath_staff", this.getTeamNum(), this.getPosition()); 
			wraithstaff.set_string("ghost",this.get_string("ghost"));
			wraithstaff.set_u8("staffbase",base);
			return true;
		}
		
		if(name+":"+name2 == "fire_staff:blood_staff" || name2+":"+name == "fire_staff:blood_staff"){
			CBlob @staff = server_CreateBlob("fireblood_staff", this.getTeamNum(), this.getPosition());
			staff.set_u8("staffbase",base);
			return true;
		}
		
		if(name+":"+name2 == "water_staff:plant_staff" || name2+":"+name == "water_staff:plant_staff"){
			CBlob @staff = server_CreateBlob("waterplant_staff", this.getTeamNum(), this.getPosition());
			staff.set_u8("staffbase",base);
			return true;
		}
		
		if(name+":"+name2 == "evildeath_staff:fireblood_staff"){
			CBlob @wraithstaff = server_CreateBlob("bad_staff", this.getTeamNum(), this.getPosition()); 
			wraithstaff.set_string("ghost",this.get_string("ghost"));
			wraithstaff.set_u8("staffbase",base);
			return true;
		}
		
		if(name+":"+name2 == "goldlife_staff:waterplant_staff" || name2+":"+name == "goldlife_staff:waterplant_staff"){
			CBlob @staff = server_CreateBlob("good_staff", this.getTeamNum(), this.getPosition()); 
			staff.set_u8("staffbase",base);
			return true;
		}
		
		if(name+":"+name2 == "bad_staff:good_staff"){
			CBlob @wraithstaff = server_CreateBlob("omni_staff", this.getTeamNum(), this.getPosition()); 
			wraithstaff.set_string("ghost",this.get_string("ghost"));
			wraithstaff.set_u8("staffbase",base);
			return true;
		}
	}
	return false;
}