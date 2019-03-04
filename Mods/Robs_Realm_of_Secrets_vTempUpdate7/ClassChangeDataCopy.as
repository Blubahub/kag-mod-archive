void CopyData(CBlob@ source, CBlob@ target){

	if(source.exists("boss"))target.set_string("boss",source.get_string("boss"));
	
	if(source.exists("corruption"))target.set_s16("corruption",source.get_s16("corruption"));
	if(source.exists("kills"))target.set_s16("kills",source.get_s16("kills"));
	
	if(source.exists("death"))target.set_s16("death",source.get_s16("death"));
	if(source.exists("life"))target.set_s16("life",source.get_s16("life"));
	if(source.exists("blood"))target.set_s16("blood",source.get_s16("blood"));
	
	if(source.exists("flesh_hunger"))target.set_u8("flesh_hunger",source.get_u8("flesh_hunger"));
	
	target.Tag("checkedfaceless");
	
	if(source.hasTag("evil"))target.Tag("evil");
	if(source.hasTag("evil_potential"))target.Tag("evil_potential");
	
	if(source.hasTag("onewithnature"))target.Tag("onewithnature");
	
	if(source.hasTag("faceless"))target.Tag("faceless");
	
	if(source.hasTag("init_life_death"))target.Tag("init_life_death");
	
	if(source.get_u8("race") != 0 && !source.hasTag("ghost"))target.set_u8("race",source.get_u8("race"));
	
	for(int i = -1; i < 255; i += 1)if(source.hasTag("key"+i))target.Tag("key"+i);
	
	if(getNet().isServer()){
		if(target.exists("life"))target.Sync("life",true);
		if(target.exists("death"))target.Sync("death",true);
		if(target.exists("blood"))target.Sync("blood",true);
		if(target.exists("corruption"))target.Sync("corruption",true);
		if(target.hasTag("evil"))target.Sync("evil",true);
		if(target.hasTag("evil_potential"))target.Sync("evil_potential",true);
		if(target.hasTag("onewithnature"))target.Sync("onewithnature",true);
		if(target.hasTag("init_life_death"))target.Sync("init_life_death",true);
	}
}