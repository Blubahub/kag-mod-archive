
void onInit(CBlob@ this)
{
	this.addCommandID("vehicle getout");
}

void onTick(CBlob@ this)
{
	AttachmentPoint@[] aps;
	if (this.getAttachmentPoints(@aps))
	{
		for (uint i = 0; i < aps.length; i++)
		{
			AttachmentPoint@ ap = aps[i];
			CBlob@ blob = ap.getOccupied();
			
			ap.offsetZ = 10.0f;

			if (blob !is null && ap.socket)
			{
				// GET OUT
				if (blob.isMyPlayer() && ap.isKeyJustPressed(key_up))
				{
					CBitStream params;
					params.write_u16(blob.getNetworkID());
					this.SendCommand(this.getCommandID("vehicle getout"), params);
					return;
				}
			}
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	bool isServer = getNet().isServer();

	if (isServer && cmd == this.getCommandID("vehicle getout"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());

		if (caller !is null)
		{
			this.server_DetachFrom(caller);
		}
	}
}


void onInit(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	CSpriteLayer@ arm_rest = this.addSpriteLayer("arm_rest", this.getFilename() , 40, 16, blob.getTeamNum(), blob.getSkinNum());

	if (arm_rest !is null)
	{
		Animation@ anim = arm_rest.addAnimation("default", 0, false);
		anim.AddFrame(1);
		//arm_rest.SetOffset(Vec2f(3.0f, -7.0f));
		arm_rest.SetRelativeZ(100);
	}
}
