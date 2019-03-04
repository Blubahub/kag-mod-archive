#include "Requirements.as"
#include "Requirements_Tech.as"
#include "ShopCommon.as";
#include "WARCosts.as";
#include "CheckSpam.as";
#include "ProductionCommon.as";
#include "TechsCommon.as";

const int grainToProduce = 20;
void onInit( CBlob@ this )
{	 
	this.addCommandID("start");
	this.addCommandID("add grain");
	
	this.set_TileType("background tile", CMap::tile_wood_back);	
	this.Tag("inventory access");
	this.set_string("autograb blob", "grain");
	this.inventoryButtonPos = Vec2f(0.0f, -4.0f);
	CSprite@ sprite = this.getSprite();
	CSpriteLayer@ windmill = sprite.addSpriteLayer( "windmill", "Windmill.png", 33, 33 );

	if (windmill !is null)
	{
		Animation@ anim = windmill.addAnimation( "windmill", 0, true );
		int[] frames = {0};
		anim.AddFrames(frames);
		windmill.SetAnimation(anim);
		windmill.SetRelativeZ(50.0f);
		windmill.SetOffset(Vec2f(9.0, -8.0));
	}
	
	::int num = XORRandom(90);
	windmill.RotateBy(num, Vec2f_zero);
	
	
	
}

void onTick(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	
	CSpriteLayer@ windmill = sprite.getSpriteLayer("windmill");
	
	if (this.hasTag("runned")) windmill.RotateBy(2.3435, Vec2f_zero);
	
	PickUpIntoMill( this );
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if (!caller.isOverlapping(this)) return;

	CBitStream params;
	params.write_u16(caller.getNetworkID());
	
	const u16 grainCount = this.getBlobCount("grain");
	if (grainCount < 20 && !this.hasTag("runned"))
	{
	caller.CreateGenericButton( 12, Vec2f(-4.0,3.0), this, this.getCommandID("add grain"), "Load grain.", params );
	}
	if (!this.hasTag("runned") && grainCount >= grainToProduce)
	{
		caller.CreateGenericButton( 12, Vec2f(0,3.0), this, this.getCommandID("start"), "Start producing flour.", params );
	}
	else if ( !this.hasTag("runned") && grainCount < grainToProduce)
	{
		CButton@ button = caller.CreateGenericButton( 9, Vec2f(4.0,3.0), this, 0, "There are no 20 grain in windmill.");
		if (button !is null) button.SetEnabled( false );
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	
	CBlob@ blob = getBlobByNetworkID( params.read_netid() );
	CBlob@ grain;
	const u16 grainCount = blob.getBlobCount("grain");
	if (cmd == this.getCommandID("start"))
	{
		addProductionItem( this, "Flour", "$flour$", "flour", "Flower used to be sold", 100, false, 3 );
		this.TakeBlob("grain", grainToProduce);
		this.getSprite().SetAnimation("enabled");
		this.Tag("runned");
	}
	if (cmd == this.getCommandID("add grain"))
	{
		if (blob !is null) blob.TakeBlob("grain", grainCount);
		for (int i = 0; i < grainCount; i++)
		{
			@grain = server_CreateBlob( "grain", this.getTeamNum(), this.getPosition());
			
			if (grain !is null)
				this.server_PutInInventory(grain);
		}
	}
}
 		   
void PickUpIntoMill( CBlob@ this )
{
	CBlob@[] blobsInRadius;	   
	CMap@ map = this.getMap();
	if (map.getBlobsInRadius( this.getPosition(), this.getRadius()*1.5f, @blobsInRadius ) && !this.hasTag("runned") )
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob @b = blobsInRadius[i];
			const string name = b.getName();
			if (b !is this && !b.isAttached() && b.isOnGround() && b.getShape().vellen < 0.1f
				&& b.getConfig() == "grain"
				&& !map.rayCastSolid(this.getPosition(), b.getPosition())
				)
			{
				this.server_PutInInventory(b);
			}
		}
	}
}
bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return (forBlob.isOverlapping(this));
}