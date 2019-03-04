#include "MakeSeed.as";
#include "MakeMat.as";
//BECAUSE I AM LAZY AND DUMB 7_7
CBlob@ ProduceMat(string mutagen, u16 mutatechance, string mutatedseed, string material, u16 amount, u16 pluschance, CBlob @blob)
{
	const f32 radius = 20.0f;
	const Vec2f position = blob.getPosition();
	const string Name = blob.getName();
	const u16 qual = blob.get_u16("quality");
	if (getNet().isServer())
	{
		if (blob.hasTag("has grain"))
		{
			//-- GROWTH ENHANCER CHECK
			CBlob@[] nearBlobs;
			blob.getMap().getBlobsInRadius( position, 200.0f, @nearBlobs );
			
			for(int step = 0; step < nearBlobs.length; ++step)
			{
				if (nearBlobs[step].getName() == "enhancer")
				{
					CInventory@ enhancer = nearBlobs[step].getInventory();
					if (enhancer !is null)
					{
						if (enhancer.isInInventory("mat_wood", 100))
						{
							blob.set_bool("increase quality", true);
							enhancer.server_RemoveItems("mat_wood", 100);
						}
					}
				}
			}
		//-- MAKING MATERIALS
		MakeMat(blob, position, material, amount + (qual*amount/(blob.get_bool("increase quality") ? 85 : 170)));
		Produce(mutagen, mutatechance, mutatedseed, pluschance, blob);
		}
	}
	blob.set_bool("increase quality", false);
	return(null);
}
//SO THAT I CAN DO MY OWN MAKING MAT (E.G WITH BLOBS INSTEAD), AND STILL USE THIS!
CBlob@ Produce(string mutagen, u16 mutatechance, string mutatedseed, u16 pluschance, CBlob @blob)
{
	const f32 radius = 20.0f;
	const Vec2f position = blob.getPosition();
	const string Name = blob.getName();
	const u16 qual = blob.get_u16("quality");
	if (getNet().isServer())
	{
		if (blob.hasTag("has grain"))
		{
			//-- GROWTH ENHANCER CHECK
			CBlob@[] nearBlobs;
			blob.getMap().getBlobsInRadius( position, 200.0f, @nearBlobs );
			
			for(int step = 0; step < nearBlobs.length; ++step)
			{
				if (nearBlobs[step].getName() == "enhancer")
				{
					CInventory@ enhancer = nearBlobs[step].getInventory();
					if (enhancer !is null)
					{
						if (enhancer.isInInventory("mat_wood", 100))
						{
							blob.set_bool("increase quality", true);
							enhancer.server_RemoveItems("mat_wood", 100);
							blob.set_u16("quality", blob.get_u16("quality")+1);
						}
					}
				}
			}
			//-- MUTATIONS
			ExtraMutate( mutagen, mutatechance, mutatedseed, blob);
			//--MAKING SEEDS
			if (XORRandom( blob.get_bool("increase quality") ? pluschance / 2 : pluschance ) == 1) 
			{
				server_MakeSeed(position, Name, 100, 7, 4, qual);
			}
			server_MakeSeed(position, Name, 100, 7, 4, qual);
		}
	}
	blob.set_bool("increase quality", false);
	return (null);
}
//--MUTATIONS, SO THAT PPL CAN DO 2 DIFFERENT POSSIBLE MUTATIONS WITHOUT HAVING 2 OF EVERYTHING ELSE
CBlob@ ExtraMutate( string mutagen, u16 mutatechance, string mutatedseed, CBlob @blob)
{
	const f32 radius = 20.0f;
	const Vec2f position = blob.getPosition();
	const string Name = blob.getName();
	const u16 qual = blob.get_u16("quality");
	if (getNet().isServer())
	{
		if (blob.hasTag("has grain"))
		{
			//-- GROWTH ENHANCER CHECK
			CBlob@[] nearBlobs;
			blob.getMap().getBlobsInRadius( position, 200.0f, @nearBlobs );
			
			for(int step = 0; step < nearBlobs.length; ++step)
			{
				if (nearBlobs[step].getName() == "enhancer")
				{
					CInventory@ enhancer = nearBlobs[step].getInventory();
					if (enhancer !is null)
					{
						if (enhancer.isInInventory("mat_wood", 60))
						{
							blob.set_bool("increase quality", true);
							enhancer.server_RemoveItems("mat_wood", 60);
						}
					}
				}
			}
			//-- MUTATIONS
			CBlob@[] nearerBlobs;
			blob.getMap().getBlobsInRadius( position, radius, @nearerBlobs );
			
			for(int step = 0; step < nearerBlobs.length; ++step)
			{
				if (nearerBlobs[step].getName() == mutagen && XORRandom( blob.get_bool("increase quality") ? mutatechance / 2 : mutatechance ) == 1)
				{
					server_MakeSeed(position, mutatedseed, 100, 7, 4, qual/2);
				}
			}
		}
	}
	blob.set_bool("increase quality", false);
	return (null);
}