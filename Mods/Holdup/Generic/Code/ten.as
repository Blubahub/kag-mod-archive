
string ToString(byte[] inBytes)
{
	string converted = "";

	for (int i = 0; i < inBytes.length; i++)
	{
		converted += (char)inBytes[i];
	}

	return converted;
}

void onInit(CBlob @this){

	this.setInventoryName(this.getInventoryName());

}