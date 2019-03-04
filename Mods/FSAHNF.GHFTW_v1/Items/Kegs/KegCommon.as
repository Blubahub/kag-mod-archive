
#define SERVER_ONLY

#include "MathCheckExplosion.as";

void onInit(CBlob @this){

	f32 explode = this.get_f32("explosive_radius")/getRules().get_u8("blob")*32;
	
	if(this.get_bool("map_damage_raycast"))explode = explode*2.0f;
	
	this.set_f32("explosive_rads",explode);
	
	this.set_f32("map_damage_radius", CheckExplosion(this,explode)*1.125);
	this.set_f32("explosive_radius",CheckExplosion(this,explode));
	

}