//A place for all the chat commands for all ranks



void template()
{
	//does nothing
}

void kick()
{

}


void playerInvo(CPlayer@ localPlayer)
{
	//get mouse
	CControls@ controls = localPlayer.getControls();
	Vec2f mosPos = controls.getMouseWorldPos();
	CMap@ map = getMap();
	if(map !is null)
	{
		CBlob@ blobBeingChecked = map.getBlobAtPosition(mosPos);
		if(blobBeingChecked !is null)
		{
			CInventory@ invo = blobBeingChecked.getInventory();
			int itemCount = invo.getItemsCount();
			for(int a = 0; a < itemCount; a++)
			{
				//do something
				CBlob@ blobInvo = invo.getItem(a);
				if(blobInvo !is null)
				{
					print(blobInvo.getName());
				}
			}
		}
	}

}