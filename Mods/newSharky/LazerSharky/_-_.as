bool onServerProcessChat(  CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player )
{
	CBlob@ blob=player.getBlob();
	if (player !is null)
	{
	if (player.isMod())
	{
		if(getNet().isServer())
		  {
		   if (blob !is null)
		    {
		      if (text_in=="@lazershark")
		        {
                  CBlob@ c = server_CreateBlob("nshark_725176513629739817329");
                  blob.server_AttachTo(c, "PICKUP");
                  return false;
		        }
		          
	        }
	      }
    }
    }
    return true;
}