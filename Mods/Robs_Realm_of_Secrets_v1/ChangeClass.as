
#include "ClassChangeDataCopy.as"

CBlob@ ChangeClass(CBlob@ original, string className, Vec2f position, int TeamNum){
	if (original !is null)
	{
		CBlob @newBlob = server_CreateBlob(className, TeamNum, position);

		if (newBlob !is null)
		{
			// copy health and inventory
			// make sack
			CInventory @inv = original.getInventory();

			if (inv !is null)
			{
				// keep inventory if possible
				original.MoveInventoryTo(newBlob);
			}

			// set health to be same ratio
			float healthratio = original.getHealth() / original.getInitialHealth();
			newBlob.server_SetHealth(newBlob.getInitialHealth() * healthratio);

			// plug the soul
			newBlob.server_SetPlayer(original.getPlayer());

			// no extra immunity after class change
			if (original.exists("spawn immunity time"))
			{
				newBlob.set_u32("spawn immunity time", original.get_u32("spawn immunity time"));
				newBlob.Sync("spawn immunity time", true);
			}

			if (original.exists("knocked"))
			{
				newBlob.set_u8("knocked", original.get_u8("knocked"));
				newBlob.Sync("knocked", true);
			}

			CopyData(original,newBlob);
			
			original.Tag("switch class");
			original.server_SetPlayer(null);
			original.server_Die();
			
			return newBlob;
		}
	}
	
	return null;
}