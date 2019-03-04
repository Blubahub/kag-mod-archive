			
			
			
			
			
			
		void clearBasicBlobs
			CBlob@[] allBlobs;
			getBlobs(@allBlobs);
			int deletedCount;
			for (int x = 0; x < allBlobs.length; x++) 
			{
				string blobName = allBlobs[x].getName();
				if (blobName == "mat_stone" && !allBlobs[x].isInInventory()) 
				{
					allBlobs[x].server_Die();
					deletedCount++;
				}
				else if (blobName == "mat_wood" && !allBlobs[x].isInInventory())
				{
					allBlobs[x].server_Die();
					deletedCount++;
				}
				else if (blobName == "mat_bombs" && !allBlobs[x].isInInventory())
				{
					allBlobs[x].server_Die();
					deletedCount++;
				}
				else if (blobName == "mat_arrows" && !allBlobs[x].isInInventory())
				{
					allBlobs[x].server_Die();
					deletedCount++;
				}
				else if (blobName == "mat_waterbombs" && !allBlobs[x].isInInventory())
				{
					allBlobs[x].server_Die();
					deletedCount++;
				}
				else if (blobName == "mat_firearrows" && !allBlobs[x].isInInventory())
				{
					allBlobs[x].server_Die();
					deletedCount++;
				}
				else if (blobName == "mat_bombarrows" && !allBlobs[x].isInInventory())
				{
					allBlobs[x].server_Die();
					deletedCount++;
				}
				else if (blobName == "mat_waterarrows" && !allBlobs[x].isInInventory())
				{
					allBlobs[x].server_Die();
					deletedCount++;
				}
				else if (blobName == "ballista_bolt" && !allBlobs[x].isInInventory())
				{
					allBlobs[x].server_Die();
					deletedCount++;
				}
				else if (blobName == "mat_bolts" && !allBlobs[x].isInInventory())
				{
					allBlobs[x].server_Die();
					deletedCount++;
				}
				else if (blobName == "drill" && !allBlobs[x].isInInventory())
				{
					allBlobs[x].server_Die();
					deletedCount++;
				}
				else if (blobName == "arrow" && !allBlobs[x].isInInventory())
				{
					allBlobs[x].server_Die();
					deletedCount++;
				}
			}