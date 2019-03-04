#include "CopyTatoos.as";

void Polymorph(CBlob@ blob, string polytype, int time){
	
	if (!getNet().isServer())return;
	
	CBlob @newBlob = server_CreateBlob(polytype, blob.getTeamNum(), blob.getPosition());

	if (newBlob !is null)
	{
		// copy health and inventory
		// make sack
		CInventory @inv = blob.getInventory();

		if (inv !is null)
		{
			blob.MoveInventoryTo(newBlob);
		}

		// plug the soul
		newBlob.server_SetPlayer(blob.getPlayer());
		newBlob.setPosition(blob.getPosition());

		// no extra immunity after class change
		if (blob.exists("spawn immunity time"))
		{
			newBlob.set_u32("spawn immunity time", blob.get_u32("spawn immunity time"));
			newBlob.Sync("spawn immunity time", true);
		}

		if (blob.exists("knocked"))
		{
			newBlob.set_u8("knocked", blob.get_u8("knocked"));
			newBlob.Sync("knocked", true);
		}
		newBlob.set_string("oldtype",blob.getName());
		newBlob.set_s16("time",time);
		newBlob.Tag("polymorphed");
		copyTatoos(blob,newBlob);

		blob.Tag("switch class");
		blob.server_SetPlayer(null);
		blob.server_Die();
	}
}