#include "MaterialCommon.as";

void onDie(CBlob@ this)
{
	if (getNet().isServer())
	{
		Material::createFor(this, "mat_hemp", 10);
	}
}