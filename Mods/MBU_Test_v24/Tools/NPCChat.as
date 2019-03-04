

void speakToNearby(CBlob @this, string prefix, string text, SColor col = SColor(255,0,0,0)){
	if(getLocalPlayerBlob() !is null)
	if(this.getDistanceTo(getLocalPlayerBlob()) < 320.0f){
		this.Chat(text);
		client_AddToChat(prefix+text, col);
	}
}