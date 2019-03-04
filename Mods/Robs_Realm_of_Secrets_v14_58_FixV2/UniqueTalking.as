
bool onServerProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	if (player is null)
		return true;


	CBlob@ blob = player.getBlob();

	if (blob is null)
	{
		return true;
	}

	
	
	if(blob.getName() == "ghoul" || blob.hasTag("gibberish") || blob.hasTag("cant_speak")){
		string[]@ tokens = text_in.split(" ");
		
		string garbadge = "";
		
		switch(XORRandom(10)){
			
			case 0:{
				garbadge += "Grah";
			break;}
			
			case 1:{
				garbadge += "Groo";
			break;}
			
			case 2:{
				garbadge += "Greh";
			break;}
			
			case 3:{
				garbadge += "Grsh";
			break;}
			
			case 4:{
				garbadge += "Rawr";
			break;}
			
			case 5:{
				garbadge += "Roo";
			break;}
			
			case 6:{
				garbadge += "Flay";
			break;}
			
			case 7:{
				garbadge += "Fleg";
			break;}
			
			case 8:{
				garbadge += "Fsgeg";
			break;}
			
			case 9:{
				garbadge += "Rar";
			break;}
		
		}
		
		for(int i = 0; i < tokens.length-1; i += 1){
			garbadge += " ";
			
			switch(XORRandom(20)){
			
				case 0:{
					garbadge += "grah";
				break;}
				
				case 1:{
				garbadge += "groo";
				break;}
				
				case 2:{
					garbadge += "greh";
				break;}
				
				case 3:{
					garbadge += "grsh";
				break;}
				
				case 4:{
					garbadge += "rawr";
				break;}
				
				case 5:{
					garbadge += "roo";
				break;}
				
				case 6:{
					garbadge += "flay";
				break;}
				
				case 7:{
					garbadge += "fleg";
				break;}
				
				case 8:{
					garbadge += "fsgeg";
				break;}
				
				case 9:{
					garbadge += "rar";
				break;}
				
				case 10:{
					garbadge += "grr";
				break;}
				
				case 11:{
					garbadge += "*hiss*";
				break;}
			
				case 12:{
					garbadge += "fss";
				break;}
				
				case 13:{
					garbadge += "se";
				break;}
				
				case 14:{
					garbadge += "gres";
				break;}
				
				case 15:{
					garbadge += "gra";
				break;}
				
				case 16:{
					garbadge += "fra";
				break;}
				
				case 17:{
					garbadge += "fsh";
				break;}
				
				case 18:{
					garbadge += "shfg";
				break;}
				
				case 19:{
					garbadge += "help";
				break;}
			
			}
			
		}
		
		switch(XORRandom(4)){
			
			case 0:{
				garbadge += ".";
			break;}
			
			case 1:{
				garbadge += "!";
			break;}
			
			case 2:{
				garbadge += "?";
			break;}
			
			case 3:{
				garbadge += "...";
			break;}
		
		}
		
		text_out = garbadge;
	}
	
	
	
	
	
	
	
	///////////Lol, well you found it, feel free to look around.
	///////////If the lines here really annoy you, just send me a message.
	///////////If you're bunnie, then: AHAHAHAH :P
	
	
	if(player.getUsername() == "Vamist" || player.getCharacterName() == "Vamist")if(XORRandom(10) == 0)text_out += " Rawr~!";
	if(player.getUsername() == "BarsukEughen555" || player.getCharacterName() == "BarsukEughen")if(XORRandom(100) == 0){
		if(XORRandom(2) == 0)text_out = "As we russians tend to say, "+text_out;
		else text_out = "[Russians have been muted on this server]";
	}
	if(player.getUsername() == "TFlippy" || player.getCharacterName() == "TFlippy")if(XORRandom(100) == 0)text_out = "[If you have any problems using your TFlipppy9000, please consult your local Pirate-Rob.]";
	
	if(player.getUsername() == "bunnie" || player.getUsername() == "Bunnie" || player.getUsername() == "wormy" || player.getUsername() == "Wormy" || player.getCharacterName() == "Duncan"){
		switch(XORRandom(10)){
			
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
	
	if(player.getUsername() == "TheClev" || player.getCharacterName() == "Clev")if(XORRandom(100) == 0)text_out = "HONESTLY, THE NEXT PERSON TO SPEAK GETS BANNED";

	return true;
}
