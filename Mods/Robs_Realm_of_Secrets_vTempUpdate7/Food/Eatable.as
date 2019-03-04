
#include "Health.as";

void onInit(CBlob@ this)
{
	if (!this.exists("eat sound"))
	{
		this.set_string("eat sound", "/Eat.ogg");
	}

	this.addCommandID("eat");
	
	this.set_f32("nutrition_starch",0);
	this.set_f32("nutrition_fat",0);
	this.set_f32("nutrition_protein",0);
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if(caller.getCarriedBlob() is this){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		CButton@ button = caller.CreateGenericButton(22, Vec2f(0,0), this, this.getCommandID("eat"), "Eat", params);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("eat"))
	{
		this.getSprite().PlaySound(this.get_string("eat sound"));
		if (getNet().isServer())
		{
			u16 blob_id;
			if (!params.saferead_u16(blob_id)) return;

			CBlob@ theBlob = getBlobByNetworkID(blob_id);
			if (theBlob !is null)
			{
				theBlob.set_f32("food_starch",theBlob.get_f32("food_starch")+this.get_f32("nutrition_starch"));
				theBlob.set_f32("food_fat",theBlob.get_f32("food_fat")+this.get_f32("nutrition_fat"));
				theBlob.set_f32("food_protein",theBlob.get_f32("food_protein")+this.get_f32("nutrition_protein"));
			}
			this.server_Die();
		}
	}
}
/*
void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null)
	{
		return;
	}

	if (getNet().isServer() && !blob.hasTag("dead") && blob.hasTag("player") && blob.hasTag("flesh"))
	{
		if((this.get_f32("nutrition_starch")/2 + blob.get_f32("food_starch") < 100) &&
		(this.get_f32("nutrition_fat")/2 + blob.get_f32("food_fat") < 100) &&
		(this.get_f32("nutrition_protein")/2 + blob.get_f32("food_protein") < 100)){
			CBitStream params;
			params.write_u16(blob.getNetworkID());
			this.SendCommand(this.getCommandID("eat"), params);
		}
	}
}*/