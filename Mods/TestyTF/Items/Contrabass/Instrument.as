string[] instrument_names = {"harp","banjo","guitar"};

shared void sendNote(CBlob@ this, u8 note, u8 instr_number)
{
	CBitStream stream;
	stream.write_u8(note);
	stream.write_u8(instr_number);
	this.SendCommand(this.getCommandID("_note"), stream);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	if(point !is null)
	{
	    CBlob@ playerblob = point.getOccupied();
		if(cmd == this.getCommandID("_note") && playerblob !is null && !playerblob.isMyPlayer())
		{
			u8 note;
			u8 instr_number;
			if(!params.saferead_u8(note)) return;
			if(!params.saferead_u8(instr_number)) return;
        	//play sound
        	f32 distance = 0;
        	if(getLocalPlayerBlob() !is null)
        	{
        		Vec2f bucketpos = this.getPosition();
                Vec2f playerpos = getLocalPlayerBlob().getPosition();
        	    distance = Vec2f(bucketpos.x-playerpos.x,bucketpos.y-playerpos.y).Length();
        	}
        	f32 reduction = (distance/430);
            
        	playNote(this, note, instr_number, 1.0f-reduction);
		}

	}
}


void playNote(CBlob@ this, u8 note, u8 instr_number, f32 volume)
{
    if(volume < 0.5f)return;
    f32 pitch = 1.0f;
    this.getSprite().PlaySound(instrument_names[instr_number]+note, volume, pitch);

}