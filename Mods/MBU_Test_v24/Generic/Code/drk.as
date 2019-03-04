
void onTick(CRules @this){
	if(getGameTime() % 301 == 0){
		CBlob@[] blobs;	   
		getBlobsByTag("darkened", @blobs);
		for (uint i = 0; i < blobs.length; i++)
		{
			CBlob@ b = blobs[i];
			if(b !is null){
				if(!b.hasScript("crpting.as"))b.AddScript("crpting.as");
			}
		}
	}
}