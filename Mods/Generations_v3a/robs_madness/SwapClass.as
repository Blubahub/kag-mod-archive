
CBlob@ swapClass(CBlob @ original, string newClass){
	
	if(original !is null && !original.hasTag("exploding")){
		
		CBlob @newBlob = server_CreateBlob(newClass, original.getTeamNum(), original.getPosition());
		
		
		if(newBlob !is null){
			// copy health and inventory
			// make sack
			
			if(original.getTeamNum() == 1)newBlob.Tag("evil");
			
			CInventory @inv = original.getInventory();

			if (inv !is null)
			{
				{
					// keep inventory if possible
					original.TakeBlob("minimine", 100);
					if(newClass != "archer" && newClass != "crossbow")original.TakeBlob("mat_arrows", 30);
					original.MoveInventoryTo(newBlob);
				}
			}
			if(original.getName() != "ghoul"){
				// set health to be same ratio
				float healthratio = original.getHealth() / original.getInitialHealth();
				newBlob.server_SetHealth(newBlob.getInitialHealth() * healthratio);
			}
			// plug the soul
			newBlob.server_SetPlayer(original.getPlayer());
			newBlob.setPosition(original.getPosition());

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

			original.Tag("switch class");
			original.server_SetPlayer(null);
			original.server_Die();
		}
		
		return newBlob;
	
	}
	
	return null;
}