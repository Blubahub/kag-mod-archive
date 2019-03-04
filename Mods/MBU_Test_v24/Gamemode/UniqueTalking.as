#include "HumanoidCommon.as";

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


bool onClientProcessChat( CRules@ this, const string &in textIn, string &out textOut, CPlayer@ player ){
	
	if(textIn.substr(0, 1) == "!")return false;
	
	if (player is null){
		client_AddToChat("????: "+textIn);
		return false;
	}

	CBlob@ blob = player.getBlob();

	if (blob is null)
	{
		client_AddToChat(player.getUsername()+": "+textIn);
		return false;
	}
	
	bool canLocalHearDead = (getLocalPlayer() !is null && getLocalPlayer().hasTag("death_sight"));

	SColor color_spirit(0xff61775c);
	
	if(textIn.substr(0, 2) == "s "){
		if(blob.hasTag("death_sight")){
			if(canLocalHearDead){
				client_AddToChat("[Ecto]"+player.getUsername()+": "+textIn.substr(2, textIn.length-2),color_spirit);
				blob.Chat(textIn.substr(2, textIn.length-2));
			}
		}
		return false;
	}
	
	if(blob.get_s8("head_type") == BodyType::Ghost || blob.get_s8("head_type") == BodyType::Wraith){
		
		if(canLocalHearDead){
			client_AddToChat("[Ecto]"+player.getUsername()+": "+textIn,color_spirit);
			blob.Chat(textIn);
		}
		
		return false;
	}
	
	CBlob @localblob = getLocalPlayerBlob();
	
	if(localblob !is null)
	if(localblob.get_s8("head_type") == BodyType::Ghost || localblob.get_s8("head_type") == BodyType::Wraith){//If the local blob has a ghost/wraith head, they can't hear anything but the spirit chat
		return false;
	}
	
	SColor color_evil(0xff58307a);
	if(localblob !is null)
	if(player !is getLocalPlayer())
	if(localblob.get_s16("dark_amount") >  XORRandom(2000)){

		string message = textIn.toLower();
		
		message = message.replace(" i ", " all ");
		message = message.replace("you", "all");
		message = message.replace("we", "all");
		message = message.replace("can", "must");
		message = message.replace("may", "must");
		message = message.replace("lets", "all will");
		message = message.replace("let's", "all will");
		message = message.replace("please", "now");
		message = message.replace("pls", "now");
		message = message.replace("plox", "now");
		message = message.replace("don't", "do");
		message = message.replace("dont", "do");
		message = message.replace("do not", "do");
		
		message = message.replace("yeah", "nah");
		message = message.replace("yea", "nah");
		message = message.replace("ye", "nah");
		message = message.replace("yes", "no");
		
		message = message.replace("lol", "kys");
		message = message.replace("rofl", "ffs");
		message = message.replace("lmao", "cunt");
		message = message.replace("lel", "asshole");
		message = message.replace("lul", "idiot");
		
		message = message.replace("build", "destroy");
		message = message.replace("heal", "hurt");
		message = message.replace("life", "death");
		message = message.replace("live", "die");
		
		message = message.replace(".", ",");
		
		string after_message = "";
		
		if(XORRandom(3) == 0){
			switch(XORRandom(14)){
				case 0: after_message = " but we'll kill them all";break;
				case 1: after_message = " and they shall be destroyed";break;
				case 2: after_message = " but remember, they want to kill you";break;
				case 3: after_message = " and then they'll try kill you";break;
				case 4: after_message = " ... the end is near";break;
				case 5: after_message = " however they are out to destroy you";break;
				case 6: after_message = " so stop them with death";break;
				case 7: after_message = " ... to kill them all is the only way";break;
				case 8: after_message = " remember: destroy, murder, and finally, mayham";break;
				case 9: after_message = " but bring more death immediatly";break;
				case 10: after_message = " and then? just destruction";break;
				case 11: after_message = " but let me tell you a secret, i cannot be contained";break;
				case 12: after_message = " but let me tell you a secret, we will kill them all";break;
				case 13: after_message = " but let me tell you a secret, we shall destroy them all";break;
			}
		}
		
		
		client_AddToChat(message+after_message,color_evil);
		return false;
	}
	
	
	
	
	
	client_AddToChat(player.getUsername()+": "+textIn);
	blob.Chat(textIn);
	
	return false;
	
}