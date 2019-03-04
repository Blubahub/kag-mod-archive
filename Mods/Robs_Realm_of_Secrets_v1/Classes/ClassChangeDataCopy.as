void CopyData(CBlob@ source, CBlob@ target){

	target.set_string("boss",source.get_string("boss"));
	
	target.set_s16("power",source.get_s16("power"));
	target.set_s16("corruption",source.get_s16("corruption"));
	target.set_s16("kills",source.get_s16("kills"));
	
	if(source.hasTag("evil"))target.Tag("evil");
	if(source.hasTag("evil_potential"))target.Tag("evil_potential");
	
	target.set_u8("race",source.get_u8("race"));
	
	for(int i = 0; i < 10; i += 1)if(source.hasTag("key"+i))target.Tag("key"+i);
}