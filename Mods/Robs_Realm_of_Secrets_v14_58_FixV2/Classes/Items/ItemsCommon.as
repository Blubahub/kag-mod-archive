
int DetectSword(CBlob @this){
	int sword = 0;
	if(this.getAttachments() !is null)
	if(this.getAttachments().getAttachedBlob("SWORD") !is null){
		sword = this.getAttachments().getAttachedBlob("SWORD").get_u8("sword_id");
	}
	return sword;
}

float SwordDamageMultiplier(CBlob @this){
	f32 sworddmg = 1;
	if(this.getAttachments() !is null)
	if(this.getAttachments().getAttachedBlob("SWORD") !is null){
		sworddmg = this.getAttachments().getAttachedBlob("SWORD").get_f32("sword_damage_multi");
	}
	return sworddmg;
}