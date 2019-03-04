void onInit( CBlob@ this )
{
	this.addCommandID("usebook");
	this.set_string("owner","");
	this.set_s16("level",0);
	this.set_s16("type",0);
	this.set_string("name","The book");
	this.set_string("author","Anon");
	this.Tag("book");
	this.server_setTeamNum(0);
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	
	CButton@ button = caller.CreateGenericButton(11, Vec2f_zero, this, this.getCommandID("usebook"), "Read: '"+this.get_string("name")+"'", params);
	button.SetEnabled(this.isAttachedTo(caller));
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("usebook"))
	{
		
	    CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if (caller !is null)
		{
            if (caller.getPlayer() is getLocalPlayer())
			{
				client_AddToChat("#-----------------'"+this.get_string("name")+"'------------------#", SColor(255, 0, 0, 0));
				client_AddToChat("Author: "+this.get_string("author"), SColor(255, 0, 0, 0));
				client_AddToChat(getQuality(this.get_s16("level")), SColor(255, 0, 0, 0));
				client_AddToChat(getContent(this.get_s16("type")), SColor(255, 0, 0, 0));
				client_AddToChat("#--------------------------------------------------#", SColor(255, 0, 0, 0));
			}
			
			if(caller.getPlayer().get_s16("book_level") < this.get_s16("level")){
				if(XORRandom(10) == 0){
					caller.getPlayer().set_s16("book_level",this.get_s16("level"));
				}
			}
		}
		
	}
}

void onTick(CBlob@ this){
	UpdateFrame(this.getSprite());
}

void UpdateFrame(CSprite@ this)
{
	// set the frame according to the material quantity
	Animation@ anim = this.getAnimation("default");

	if (anim !is null)
	{
		anim.SetFrameIndex(this.getBlob().get_s16("type"));
	}
}


string getQuality(int level){

	switch(level){
	
	case -1:{
		return "You can't seem to decipher this mess.";
	}
	
	case 0:{
		return "The writing of this book is rubbish.";
	}
	
	case 1:{
		return "The writing of this book is terrible.";
	}
	
	case 2:{
		return "The writing of this book is pretty bad.";
	}
	
	case 3:{
		return "The writing of this book is bad.";
	}
	
	case 4:{
		return "The writing of this book is poor.";
	}
	
	case 5:{
		return "The writing of this book is mediocre.";
	}
	
	case 6:{
		return "The writing of this book is average.";
	}
	
	case 7:{
		return "The writing of this book is good.";
	}
	
	case 8:{
		return "The writing of this book is great.";
	}
	
	case 9:{
		return "The writing of this book is amazing.";
	}
	
	case 10:{
		return "The writing of this book is awe-inspiring.";
	}
	
	
	}
	

	return "This book is so amazingly written that you forget you're reading a book.";

}

string getContent(int booktype){

	switch(booktype){
	
	case 0:{
		return "This book seems to be much about nothing.";
	}
	
	case 1:{
		return "This book concerns arrows.";
	}
	
	case 2:{
		return "This book is about explosives.";
	}
	
	case 3:{
		return "This book contains information about gold.";
	}
	
	case 4:{
		return "This book is about plant life.";
	}
	
	case 5:{
		return "This book touches on the subject of wood.";
	}
	
	case 6:{
		return "This book touches on the subject of stone.";
	}
	
	case 7:{
		return "This is a story about society.";
	}
	
	case 8:{
		return "This is a story of death.";
	}
	
	case 9:{
		return "This is a story about an animal.";
	}
	
	case 10:{
		return "This book contains knowledge of fire.";
	}
	
	case 11:{
		return "This book contains knowledge of water and wetness.";
	}
	
	}
	

	return "This book seems to be much about nothing.";

}