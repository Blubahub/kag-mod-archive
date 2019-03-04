// Drill.as

#include "Hitters.as";
#include "BuilderHittable.as";


void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	this.SetFrame(0);
	if(blob.get_u8("charge") > 10)this.SetFrame(1);
}

void onRender(CSprite@ this)
{
	if (g_videorecording)
		return;

	CBlob@ blob = this.getBlob();
	Vec2f center = blob.getPosition();
	Vec2f mouseWorld = getControls().getMouseWorldPos();
	const f32 renderRadius = (blob.getRadius()) * 0.95f;

	Vec2f pos2d = blob.getScreenPos() + Vec2f(0, 20);
	Vec2f dim = Vec2f(24, 8);
	const f32 y = blob.getHeight() * 2.4f;
	const f32 initialHealth = 250;
	if(getLocalPlayer() !is null)
	if(getLocalPlayer().getBlob() !is null)
	if(getLocalPlayer().getBlob().getCarriedBlob() is blob)
	if (initialHealth > 0.0f)
	{
		const f32 perc = blob.get_u8("charge") / initialHealth;
		if (perc >= 0.0f)
		{
			GUI::DrawRectangle(Vec2f(pos2d.x - dim.x - 2, pos2d.y + y - 2), Vec2f(pos2d.x + dim.x + 2, pos2d.y + y + dim.y + 2));
			GUI::DrawRectangle(Vec2f(pos2d.x - dim.x + 2, pos2d.y + y + 2), Vec2f(pos2d.x - dim.x + perc * 2.0f * dim.x - 2, pos2d.y + y + dim.y - 2), SColor(0xffac1512));
		}
	}
}

void onInit(CBlob@ this)
{
	this.addCommandID("load");
	this.addCommandID("fire");
	
	this.set_u8("charge",0);
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(!this.isAttachedToPoint("CUP")){
		if(caller.getCarriedBlob() !is this){
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			
			CButton@ button = caller.CreateGenericButton(2, Vec2f(0,0), this, this.getCommandID("load"), "Load", params);
		}
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	CBlob@ caller = getBlobByNetworkID(params.read_u16());
	if    (caller !is null)
	{
		if (cmd == this.getCommandID("load"))
		{
			CBlob@ hold = caller.getCarriedBlob();
			if(hold !is null){
				hold.server_DetachAll();
				this.server_AttachTo(hold, "CUP");
			} else {
				this.server_AttachTo(caller, "CUP");
			}
		}
	}
	
	if (cmd == this.getCommandID("fire"))
	{
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		CBlob@ holder = point.getOccupied();
		
		if(holder !is null)
		for(int i = 0;i < this.getAttachmentPointCount(); i += 1){
			if(this.getAttachmentPoint(i).name == "CUP"){
			CBlob @blob = this.getAttachmentPoint(i).getOccupied();
				if(blob !is null){
					blob.server_DetachFrom(this);
					Vec2f shootVel = holder.getAimPos()-this.getPosition();
					shootVel.Normalize();
					blob.setVelocity(shootVel*float(this.get_u8("charge"))/10.0f);
					
					if(blob.getName().findFirst("keg") != -1 || blob.getName() == "nuke")blob.SendCommand(blob.getCommandID("activate"));
				}
			}
		}
	}
}

void onTick(CBlob@ this)
{

	if (this.isAttached())
	{
		this.getCurrentScript().runFlags &= ~(Script::tick_not_sleeping);
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		CBlob@ holder = point.getOccupied();

		this.getShape().SetRotationsAllowed(false);
		
		if (holder is null) return;

		if (!holder.isKeyPressed(key_action1) || holder.get_u8("knocked") > 0)
		{
			if(this.get_u8("charge") > 10){
				this.SendCommand(this.getCommandID("fire"));
			}
			this.set_u8("charge",0);
		} else {
			if(this.get_u8("charge") < 250)this.set_u8("charge",this.get_u8("charge")+5);
		}
		for(int i = 0;i < this.getAttachmentPointCount(); i += 1){
			if(this.getAttachmentPoint(i).name == "CUP"){
				if(this.get_u8("charge") > 10)this.getAttachmentPoint(i).offset = Vec2f(10,0);
				else this.getAttachmentPoint(i).offset = Vec2f(13,0);
			}
		}
		
		Vec2f AngleVec = holder.getPosition()-holder.getAimPos();
		
		bool facingleft = this.isFacingLeft();
		Vec2f direction = Vec2f(1, 0).RotateBy(AngleVec.Angle() + (facingleft ? 180.0f : 0.0f));
		
		this.setAngleDegrees(direction.Angle()-180);

	}
	else
	{
		this.getShape().SetRotationsAllowed(true);
		this.getCurrentScript().runFlags |= Script::tick_not_sleeping;
	}
}