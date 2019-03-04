// Materials
#include "Help.as";
#include "Hitters.as";

// use this.Tag("do not set materials") to prevent the amount changing.

void onInit(CBlob@ this)
{
	int max=250; // default
	string name=this.getName();
	bool set=false;

	this.Tag("material");

	if(name=="mat_bombs" || name=="mat_waterbombs" || name=="mat_bombarrows" || name=="mat_bigbomb" || name == "mat_bombita")
	{
		max=1;
		set=true;
		if(name=="mat_bombs" && getNet().isServer()) { // show only on localhost 
			SetHelp(this, "help activate", "knight", "$mat_bombs$Light    $KEY_SPACE$", "$mat_bombs$Only KNIGHT can light bombs", 3);
		}
	}
	else if(name=="mat_firearrows" || name=="mat_waterarrows" || name=="mat_incendiarybomb")
	{
		max=2;
		set=true;
	}
	else if(name=="mat_smallrocket")
	{
		max=3;
		set=true;
	}
	else if(name=="mat_tankshell" || name=="mat_howitzershell" || name == "mat_shotgunammo")
	{
		max=4;
		set=true;
	}
	else if(name=="mat_rifleammo")
	{
		max=5;
		set=true;
	}
	else if(	name=="mat_copperingot" || name=="mat_ironingot" || name=="mat_steelingot" || name=="mat_goldingot" || name=="mat_mithrilingot" ||
				name=="mat_lifesteelingot" || name=="mat_wilmetingot" || name=="mat_copperwire" || name=="mat_smallbomb" || name=="card_stack")
	{
		max=8;
		set=true;
	}
	else if(name=="mat_bolts")
	{
		max=12;
		set=true;
		SetHelp(this, "help use carried", "", "$mat_bolts$Put in $ballista$    $KEY_E$", "", 3);
		SetHelp(this, "help pickup", "", "$mat_bolts$Pickup    $KEY_C$", "", 3);
	}
	else if (name=="mat_pistolammo")
	{
		max=20;
		set=true;
	}
	else if(name=="mat_arrows" || name=="mat_gatlingammo")
	{
		max=30;
		set=true;
	}
	else if(name=="mat_oil" || name=="mat_coal" || name == "mat_lancerod" || name == "mat_sulphur" || name == "mat_plasteel" || name == "mat_methane" ||  name == "mat_mustard")
	{
		max=50;
		set=true;
	}
	else if(this.getQuantity()==1)   // hack: fix me!
	{
		set=true;
	}

	if(getNet().isServer() && set && !this.hasTag("do not set materials")) {
		this.server_SetQuantity(max);
	}

	this.maxQuantity=max;

	this.getShape().getVars().waterDragScale=20.0f;

	// force frame update
	onQuantityChange(this, 1);
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if(customData==Hitters::crush) //crush removes quantity
	{
		//fix massive lag - prevent overflow :)
		this.server_SetQuantity(Maths::Max(0, int(this.getQuantity()) - 100));
	}

	return damage;
}

void onQuantityChange(CBlob@ this, int oldQuantity)
{
	UpdateFrame(this.getSprite());

	if(getNet().isServer())
	{
		int quantity=this.getQuantity();

		// safety, we don't want 0 mats
		if(quantity==0)
		{
			this.server_Die();
		}
	}
}

void UpdateFrame(CSprite@ this)
{
	// set the frame according to the material quantity
	Animation@ anim=this.getAnimation("default");
	
	if (anim !is null)
	{
		CBlob@ blob = this.getBlob();
	
		// print("frames: " + (anim.getFramesCount() - 1) + "; Mult: " + (f32(blob.getQuantity()) / f32(blob.maxQuantity)) + "; Quantity: " + blob.getQuantity());
	
		u8 frame =  u8((anim.getFramesCount() - 1) * (f32(blob.getQuantity()) / f32(blob.maxQuantity)));
		// u8 frame = 0;
		// print(this.getBlob().getName() + " " + frame);
		
		this.animation.frame = frame;
		blob.SetInventoryIcon(this.getConsts().filename, anim.getFrame(frame), Vec2f(this.getConsts().frameWidth, this.getConsts().frameHeight));

		// this.animation.frame = u8((sprite.this.getFramesCount() - 1) * (f32(inv.getItemsCount()) / f32(inventory_size)));
	
		// u16 max=this.getBlob().maxQuantity;
		// int frames=anim.getFramesCount();
		// int quantity=this.getBlob().getQuantity();
		// f32 div=float(max / 4);
		// int frame=div < 0.01f ? 0 : Maths::Min(frames - 1, int(Maths::Floor(float(quantity) / div)));
		// anim.SetFrameIndex(frame);
		// CBlob@ blob=this.getBlob();
		// blob.SetInventoryIcon(blob.getSprite().getConsts().filename, anim.getFrame(frame), Vec2f(blob.getSprite().getConsts().frameWidth, blob.getSprite().getConsts().frameHeight));
	}
}
