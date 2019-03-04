// const string[] hansPhrases
// {
// }

bool onServerProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	if (player is null)
		return true;

	CBlob@ blob = player.getBlob();

	if (blob is null)
	{
		return true;
	}

	///////////Lol, well you found it, feel free to look around.
	///////////If the lines here really annoy you, just send me a message.
	///////////If you're bunnie, then: AHAHAHAH :P
	
	if (player.getUsername() == "kreblthis" || player.getCharacterName() == "Hans Smooth")
	{
		if (XORRandom(100) < 20)
		{
			switch(XORRandom(13))
			{
				case 0:
					text_out += " and glory to israel btw";
					break;
					
				case 1:
					text_out += " seriously we need to stop the hatred";
					break;
					
				case 2:
					text_out += " and kick me if you dare";
					break;
					
				case 3:
					text_out += " or not???";
					break;
					
				case 4:
					text_out += text_out + ", my comrades";
					break;
					
				case 5:
					text_out += " save the refugees";
					break;
					
				case 6:
					text_out += " #votehillary 2016";
					break;
			
				case 7:
					text_out += "... im sorry :(";
					break;
					
				case 8:
					text_out += " and praise jesus";
					break;
					
				case 9:
					text_out += " hail mary";
					break;
				
				case 10:
					text_out += " we're all equal";
					break;
					
				case 11:
					text_out += " ok?";
					break;	
					
				case 12:
					text_out = "together, we will " + text_out + " and everyone will be happy!";
					break;	
					
				default:
					break;
			}
		
			if (XORRandom(100) < 50) text_out = text_out.replace("jews", "nazis").replace("jew", "nazi");
			text_out = text_out.toLower();
		}
	}
	
	if (player.getUsername() == "Vamist" || player.getCharacterName() == "Vamist") if(XORRandom(10) == 0) text_out += " Rawr~! <3";
	
	if (player.getUsername() == "BarsukEughen555" || player.getCharacterName() == "BarsukEughen")
	{
		if (XORRandom(100) == 0)
		{
			if (XORRandom(2) == 0) text_out = "As we russians tend to say, " + text_out + "!";
			else text_out = "[Russians have been muted on this server]";
		}
	}
	
	if( player.getUsername() == "TFlippy" || player.getCharacterName() == "TFlippy")if(XORRandom(100) == 0)text_out = "[If you have any problems using your TFlipppy9000, please consult your local Pirate-Rob.]";
	
	if (XORRandom(100) < 20 && player.getUsername() == "bunnie" || player.getUsername() == "Bunnie" || player.getUsername() == "wormy" || player.getUsername() == "Wormy" || player.getCharacterName() == "Duncan")
	{
		switch (XORRandom(10))
		{
			
			case 0:{
				text_out = "I hope everyone is doing well.";
			break;}
			
			case 1:{
				text_out = "You guys are all awesome.";
			break;}
			
			case 2:{
				text_out = "Thanks!";
			break;}
			
			case 3:{
				text_out = "You guys are great.";
			break;}
			
			case 4:{
				text_out = "Hope you are all having a good day.";
			break;}
			
			case 5:{
				text_out = "Remember to be nice to eachother!";
			break;}
			
			case 6:{
				text_out = "Hugs to anyone who gets me some gold please.";
			break;}
			
			case 7:{
				text_out = "Can someone kindly explain how this mod works please?";
			break;}
			
			case 8:{
				text_out = ":D";
			break;}
			
			case 9:{
				text_out = "You're all special to me <3";
			break;}
		
		}
	}
	
	if (player.getUsername() == "TheClev" || player.getCharacterName() == "Clev") if(XORRandom(100) == 0) text_out = "HONESTLY, THE NEXT PERSON TO SPEAK GETS BANNED";

	return true;
}
