
void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed( true );
	this.SetLightRadius(100);
	this.SetLight(true);
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
    return true;
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint@ attachedPoint)
{
	this.server_setTeamNum(attached.getTeamNum());
}



void onTick(CBlob@ this)
{
	switch (this.getTeamNum())
	{
		case 0:
			this.SetLightColor(0xff4492f1);
			break;

		case 1:
			this.SetLightColor(0xffed1e24);
			break;

		case 2:
			this.SetLightColor(0xff66bc46);
			break;

		case 3:
			this.SetLightColor(0xff663481);
			break;

		case 4:
			this.SetLightColor(0xffe86217);
			break;

		case 5:
			this.SetLightColor(0xff76e6e9);
			break;

		case 6:
			this.SetLightColor(0xff4e6cd5);
			break;

		default:
			this.SetLightColor(0xffffffff);
			break;
	}
}
