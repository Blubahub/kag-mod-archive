

bool bodyPartFunctioning(CBlob@ this, string limb){
	return (this.get_s8(limb+"_type") > -1) && (this.get_f32(limb+"_hp") > 0.0f);
}