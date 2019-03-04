CBlob@ getAttached( CBlob@ this, string point )
{	
	CAttachment@ attachment = this.getAttachments();
	AttachmentPoint@ attachmentPoint = attachment.getAttachmentPointByName(point);
	CBlob@ attached = attachmentPoint.getOccupied();
	return attached;
}