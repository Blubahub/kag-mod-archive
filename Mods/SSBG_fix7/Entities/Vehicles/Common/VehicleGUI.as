#include "VehicleCommon.as" 

void onInit( CSprite@ this )
 {
	 this.getCurrentScript().runFlags |= Script::tick_hasattached;
 }

void onRender( CSprite@ this )
{
	if (this is null) return; //can happen with bad reload
	
    // draw only for local player
    CBlob@ localBlob = getLocalPlayerBlob();
	CBlob@ blob = this.getBlob();

    if (localBlob is null) {
        return;
    }
	    
	VehicleInfo@ v;
	if (!blob.get( "VehicleInfo", @v )) {
		return;
	}

	if (!v.infinite_ammo)
	{
		AttachmentPoint@ gunner = blob.getAttachments().getAttachmentPointByName("GUNNER");
		if (gunner !is null	&& gunner.getOccupied() is localBlob)
		{
			// draw ammo count

			Vec2f pos2d = blob.getScreenPos();
			Vec2f upperleft(pos2d.x - 18, pos2d.y + blob.getHeight()+30);
			Vec2f lowerright(pos2d.x + 18, upperleft.y + 20);

			GUI::DrawRectangle( upperleft, lowerright );

			u16 ammo = v.ammo_stocked;

			string reqsText = " "+ammo;
			GUI::DrawText( reqsText, upperleft, lowerright, color_white, true, true, false );
		}
	}
}

void Vehicle_onFire( CBlob@ this, VehicleInfo@ v, CBlob@ bullet, const u8 charge ) {}
bool Vehicle_canFire( CBlob@ this, VehicleInfo@ v, bool isActionPressed, bool wasActionPressed, u8 &out chargeValue ) {return false;}