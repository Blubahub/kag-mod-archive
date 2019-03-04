void onInit( CBlob@ this )
{
	this.set_u8("sword_id",3);
	this.set_f32("sword_damage_multi",0);
	this.set_u16("kills",0);
}

void onTick( CBlob@ this ){
	this.set_f32("sword_damage_multi",Maths::Log(this.get_u16("kills")+1)*2+1);
}