#include "States.as"
#include "SoldierCommon.as"


namespace Brain
{
	const int FORGET_SECS = 10;
	const int TRACK_SECS = 3;

	void UpdateMemory( CBlob@ this, BlobMemory[]@ blobs )
	{
		const u32 time = getGameTime();

		// gather visible blobs

		CBlob@[] all;
		getBlobs( @all );

		AddAndUpdate( this, blobs, all );

		// remove redundant blobs

		for (uint b_it=0; b_it < blobs.length; b_it++)
		{
			BlobMemory@ bm = blobs[b_it];
			CBlob@ blob = getBlobByNetworkID(bm.id);

			// dead
			if (blob is null){
				b_it = RemoveMemory( blobs, b_it );
				continue;
			}

			// too long ago
			if (time - bm.time > FORGET_SECS * getTicksASecond() ){
				b_it = RemoveMemory( blobs, b_it );
				continue;
			}
		}
	}

	void AddAndUpdate( CBlob@ this, BlobMemory[]@ blobs, CBlob@[]@ all )
	{
		const u32 time = getGameTime();
		const u8 team = this.getTeamNum();

		for (uint i=0; i < all.length; i++)
		{
			CBlob@ b = all[i];
			const int memoryIndex = FindMemory( blobs, b.getNetworkID() );
			if (memoryIndex < 0) { // create
				AddMemory( blobs, b );
			}
			else
			{ // update
				BlobMemory@ bm = blobs[ memoryIndex ];
				if (bm.update 
					&& (b is this 
					|| time - bm.time < TRACK_SECS * getTicksASecond()
					|| b.hasTag("visible to team " + team ))
				)
				{
					UpdateMemoryFromBlob( bm, b );
				}
			}
		}
	}

	uint RemoveMemory( BlobMemory[]@ blobs, uint index )
	{
		blobs.erase(index);
		return index--;
	}

	int FindMemory( BlobMemory[]@ blobs, const u16 blobid )
	{
		for (uint b_it=0; b_it < blobs.length; b_it++)
		{
			BlobMemory@ bm = blobs[b_it];
			if (bm.id == blobid)
				return b_it;
		}
		return -1;
	}

	void UpdateMemoryFromBlob( BlobMemory@ bm, CBlob@ blob )
	{
		const u32 time = getGameTime();
		bm.id = blob.getNetworkID();
		bm.time = time;
		bm.pos = blob.getPosition();
		@bm.node = blob.getMap().getHighLevelNode( bm.pos );
		bm.velocity = blob.getVelocity();
		bm.health = blob.getHealth() / blob.getInitialHealth();
		bm.team = blob.getTeamNum();

		Soldier::Data@ data = Soldier::getData( blob );
		if (data !is null)	{
			bm.ammo = data.initialAmmo == 0 ? 1.0f : (float(data.ammo) / float(data.initialAmmo));
			bm.grenades = data.initialGrenades == 0 ? 1.0f : (float(data.grenades) / float(data.initialGrenades));
		}
	}

	void AddMemory( BlobMemory[]@ blobs, CBlob@ blob )
	{
		BlobMemory bm;
		UpdateMemoryFromBlob( bm, blob );
		blobs.push_back( bm );
	}

	void CopyMemory( BlobMemory[]@ to, BlobMemory[]@ _from )
	{
		for (uint b_it=0; b_it < _from.length; b_it++)
		{
			BlobMemory@ bm = _from[b_it];
			BlobMemory newbm = bm;
			to.push_back( newbm );
		}
	}

	void RenderMemory( BlobMemory@ bm, Vec2f pos2d, const bool self, const bool friend )
	{
		CBlob@ b = getBlobByNetworkID( bm.id );
		if (b !is null)	{
			SColor blobcolor = self ? SColor(255, 242,232,232) : (friend ? SColor(255, 102,222,102) : SColor(255, 242,102,102));
			//GUI::DrawText( "@" + b.getName() + " [" + bm.pos.x + "," + bm.pos.y + "]", pos2d, blobcolor );
			for (uint i=0; i < bm.debugtext.length; i++)
				GUI::DrawText( "#"+bm.debugtext[i], pos2d + Vec2f(10.0f, 10.0f*(i+1)),	blobcolor );
		}
	}
}