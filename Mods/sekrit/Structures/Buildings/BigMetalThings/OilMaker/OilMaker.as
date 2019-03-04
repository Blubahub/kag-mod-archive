//Made by vamist

const int BurnTime       = 30; 	 // How long it takes in seconds to make oil
const int WoodCostPerUse = 300;  // How much wood is required to make oil
const int OilOutput      = 50;	 // How much oil you get from burning wood
const int MaxOilStored   = 300;  // Max oil 'Stored'
const int MaxWoodStored  = 300;  // Max wood 'Stored'

const bool Debug         = false;// Debug stuff


void onInit(CBlob@ this)
{
	//Animation stuff
	this.getSprite().SetAnimation("default");
	this.addCommandID("nowLetThereBeLight!");
	this.addCommandID("AddBucket");
	this.addCommandID("AddWood");
	this.addCommandID("OutputOilBucket");

	//Oil props
	this.set_u16("ProcessTime",0);// How long have we processed this wood for?
	this.set_u16("OilStored",0);  // How much oil we currently have
	this.set_u16("WoodStored",0); // How much wood we currently have
	this.set_u16("BucketCount",0);
	this.set_bool("Active",false);// Are we currently active (no, i've just been made)


}

void onTick(CBlob@ this)
{
	if(getNet().isServer())//Do server side only (so we just need to sync (or cmd))
	{
		if(this.get_bool("Active"))
		{
			print("am are working");

			if(getGameTime() % 30 == 0)
				this.add_u16("ProcessTime",1);

			if(this.get_u16("ProcessTime") == BurnTime)
			{
				print("am done");
				this.SendCommand(this.getCommandID("OutputOilBucket"));

			}
		}
	}
	else
	{
		//send command to client to change sprite


		//If active & we have a default sprite
		//Set new layer
		//else do something else

	}
	
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{

	if(this.get_bool("Active"))
		return;
	if(Debug)
	{
		if (caller.getTeamNum() == this.getTeamNum())
		{
			CBitStream params;
			caller.CreateGenericButton("$change_class$", Vec2f(10, 0), this, this.getCommandID("nowLetThereBeLight!"), getTranslatedString("Light"), params);
		}
	}
	if(caller.getTeamNum() == this.getTeamNum())
	{
		//Bucket request
		{
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			caller.CreateGenericButton("$change_class$", Vec2f(-5, 0), this, this.getCommandID("AddBucket"), getTranslatedString("Hold oil using a bucket"), params);
		}

		//Wood request
		{
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			caller.CreateGenericButton("$change_class$", Vec2f(5, 0), this, this.getCommandID("AddWood"), getTranslatedString("Add "+WoodCostPerUse+" wood to start making oil"), params);
		}
	}
//
	//If(caller) has bucket blob
	//allow input

}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	//TODO make switch instead of if
	//Not possible, AS only accepts const as a num

	if(cmd == this.getCommandID("nowLetThereBeLight!"))
	{
		this.getSprite().SetAnimation("lit");
	}
	else if(cmd == this.getCommandID("AddBucket"))
	{
		CBlob@ blob = getBlobByNetworkID(params.read_u16());
		if(blob is null) 
			return;
		CBlob@ attachedBlob = blob.getAttachments().getAttachedBlob("PICKUP");
		if(attachedBlob is null)
			return;
		print(attachedBlob.getName());
		if(attachedBlob.getName() == "bucket")
		{
			attachedBlob.server_Die();
			this.add_u16("BucketCount",1);
			checkIfActive(this);
		}
	}
	else if(cmd == this.getCommandID("AddWood"))
	{
		u16 blobNum = 0;
		params.saferead_u16(blobNum);
		//print(getNet().isServer() + " | " + blobNum);
		CBlob@ blob = getBlobByNetworkID(blobNum);
		//if(blob is null)  //Removed null check since blob is not null for some reason, but client says it is (but you can call its name and what not..)
			//return;
		CInventory@ invo = blob.getInventory();
		int woodCount = invo.getCount("mat_wood");
		print("Going to check");
		if(woodCount >= WoodCostPerUse)
		{
			invo.server_RemoveItems("mat_wood", WoodCostPerUse);
			this.add_u16("WoodStored", WoodCostPerUse);
			checkIfActive(this);
		}
	}
	else if(cmd == this.getCommandID("OutputOilBucket"))
	{
		print("hello world");
		this.set_bool("Active",false);
		this.getSprite().SetAnimation("default");
		//this.add_u16("OilStored",OilOutput);
		this.add_u16("WoodStored",-WoodCostPerUse);
		this.add_u16("BucketCount",-1);
		if(getNet().isServer())
		{
			print("hi server");
			this.set_u16("ProcessTime",0);
			server_CreateBlob("bucket", this.getTeamNum(), this.getPosition());
		}
	}
}


void checkIfActive(CBlob@ this)
{
	print("checking");
	if(this.get_bool("Active"))
		return;
	print(this.get_u16("BucketCount") + " || " + this.get_u16("WoodStored"));
	if(this.get_u16("BucketCount") > 0 && this.get_u16("WoodStored") >= WoodCostPerUse)
	{
		this.set_bool("Active",true);
		this.getSprite().SetAnimation("lit");
	}
}



//Wood count + oil count needs to stay both client + server side


// Count server side, sync value to all other players
//To do ^