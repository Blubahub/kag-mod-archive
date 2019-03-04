#include "MakeMat.as";

void server_SpawnRandomItem(CBlob@ this, const string[][]&in items)
{
    int index = GetRandomItem();

    if (index < 0)
    {
        printf("error while spawning loot! index: " + index);
        return;
    }
    MakeMat(this, this.getPosition(), items[index][0], parseInt(items[index][1]) + XORRandom(parseInt(items[index][2])));
}

void server_SpawnCoins(CBlob@ this, u16 count)
{
	server_DropCoins(this.getPosition(), count);
}


int sum = 0;

int GetRandomItem()
{
	if (sum == 0)
	{
		for (int i = 0; i < items.length; i++)
		{
			sum += parseInt(items[i][3]);
		}

		printf("missing loot sum! sum is now " + sum);
	}

	int rnd = XORRandom(sum);
	int num = 0;

	for (int i = 0; i < items.length; i++)
	{
		u32 weight = parseInt(items[i][3]);

		if (rnd <= (num + weight))
		{
			return i;
		}

		num += weight;
	}

	print("random: " + rnd + "; got nothing!");

	return -1;
}
