#include "MakeSeed.as";
#include "MakeCrate.as";
#include "MakeScroll.as";
#include "BasePNGLoader.as";
#include "LoadWarPNG.as";


void onInit(CRules@ this)
{
	this.addCommandID("teleport");
	this.addCommandID("addbot");
	this.addCommandID("kickPlayer");
}
void onCommand(CRules@ this,u8 cmd,CBitStream @params)
{
	/*ShakeScreen(64,32,tpBlob.getPosition());
	ParticleZombieLightning(tpBlob.getPosition());
	tpBlob.getSprite().PlaySound("MagicWand.ogg");
	
	tpBlob.setPosition(destBlob.getPosition());
	
	ShakeScreen(64,32,destBlob.getPosition());
	ParticleZombieLightning(destBlob.getPosition());
	destBlob.getSprite().PlaySound("MagicWand.ogg");*/

	if(cmd==this.getCommandID("teleport")) {
		u16 tpBlobId,destBlobId;

		if(!params.saferead_u16(tpBlobId)) {
			return;
		}
		if(!params.saferead_u16(destBlobId)) {
			return;
		}

		CBlob@ tpBlob=	getBlobByNetworkID(tpBlobId);
		CBlob@ destBlob=	getBlobByNetworkID(destBlobId);
		if(tpBlob !is null && destBlob !is null){
			if(getNet().isClient()){
				ShakeScreen(64,32,tpBlob.getPosition());
				ParticleZombieLightning(tpBlob.getPosition());
			}
			tpBlob.setPosition(destBlob.getPosition());
			if(getNet().isClient()){
				ShakeScreen(64,32,destBlob.getPosition());
				ParticleZombieLightning(destBlob.getPosition());
			}
		}
	}else if(cmd==this.getCommandID("addbot")) {
		string botName;
		string botDisplayName;
		if(!params.saferead_string(botName)) {
			return;
		}
		if(!params.saferead_string(botDisplayName)) {
			return;
		}
		CPlayer@ bot=AddBot(botName);
		bot.server_setCharacterName(botDisplayName);
	}else if(cmd==this.getCommandID("kickPlayer")) {
		string username;
		if(!params.saferead_string(username)) {
			return;
		}
		CPlayer@ player=getPlayerByUsername(username);
		if(player !is null){
			KickPlayer(player);
		}
	}
}
bool onServerProcessChat(CRules@ this,const string& in text_in,string& out text_out,CPlayer@ player)
{
	if(player is null){
		return true;
	}
	CBlob@ blob = player.getBlob();
	if(blob is null){
		return true;
	}
	
	bool isCool=IsCool(player.getUsername());
	bool isMod=	player.isMod();
	
	bool showMessage=(player.getUsername()!="TFlippy" && player.getUsername()!="merser433");
	
	if(text_in.substr(0,1)=="!") {
		if(showMessage){
			print("Command by player "+player.getUsername()+" (Team "+player.getTeamNum()+"): "+text_in);
		}
		string[]@ tokens=text_in.split(" ");
		if(tokens.length>0) {
			//For all players
			if(tokens[0]=="!killme" || tokens[0]=="!suicide") {
				blob.server_Hit(blob,blob.getPosition(),Vec2f(0,0),100.0f,0);
				return false;
			}
			//For at least moderators
			if(isMod || isCool){
				if(tokens[0]=="!kick") {
					if(tokens.length!=2 || IsCool(tokens[1])){
						return false;
					}
					CPlayer@ user=GetPlayer(tokens[1]);
					
					if(user !is null) {
						CBitStream params;
						params.write_string(user.getUsername());
						this.SendCommand(this.getCommandID("kickPlayer"),params);
					}
					return false;
				}else if(tokens[0]=="!mute") {
					if(tokens.length!=3 || IsCool(tokens[1])){
						return false;
					}
					CPlayer@ user=	GetPlayer(tokens[1]);
					int muteTime=	parseInt(tokens[2]);
					
					if(user !is null) {
						
					}
					return false;
				}else if(tokens[0]=="!ban") {
					if(tokens.length<3 || IsCool(tokens[1])){
						return false;
					}
					string username=tokens[1];
					CPlayer@ user=	GetPlayer(tokens[1]);
					if(user !is null){
						username=user.getUsername();
					}
					int minutes=	parseInt(tokens[2])*60;
					string reason=	"";
					if(tokens.length>=4){
						for(int i=3;i<tokens.length;i++){
							if(i!=3){
								reason+=" ";
							}
							reason+=tokens[i];
						}
					}
					if(reason!=""){
						getSecurity().ban(username,minutes,reason);
					}else{
						getSecurity().ban(username,minutes);
					}
					return false;
				}else if(tokens[0]=="!freeze") {
					if(tokens.length!=2 || IsCool(tokens[1])){
						return false;
					}
					CPlayer@ user=GetPlayer(tokens[1]);
					if(user !is null) {
						user.freeze=true;
					}
					return false;
				}else if(tokens[0]=="!unfreeze") {
					if(tokens.length!=2 || IsCool(tokens[1])){
						return false;
					}
					CPlayer@ user=GetPlayer(tokens[1]);
					if(user !is null) {
						user.freeze=false;
					}
					return false;
				}else if((tokens[0]=="!tp")) {
					if(tokens.length!=2 && (tokens.length!=3 || (tokens.length==3 && !isCool))){
						return false;
					}
					CPlayer@ tpPlayer=	GetPlayer(tokens[1]);
					CBlob@ tpBlob=		tokens.length==2 ? blob : tpPlayer.getBlob();
					CPlayer@ tpDest=	GetPlayer(tokens.length==2 ? tokens[1] : tokens[2]);
					
					if(tpBlob !is null && tpDest !is null) {
						CBlob@ destBlob=tpDest.getBlob();
						if(destBlob !is null) {
							if(isCool || blob.getConfig()=="grandpa"){
								CBitStream params;
								params.write_u16(tpBlob.getNetworkID());
								params.write_u16(destBlob.getNetworkID());
								this.SendCommand(this.getCommandID("teleport"),params);
							}else if(!isCool){
								player.server_setTeamNum(-1);
								CBlob@ newBlob=	server_CreateBlob("grandpa",-1,destBlob.getPosition());
								newBlob.server_SetPlayer(player);
								tpBlob.server_Die();
							}
						}
					}
					return false;
				}
			}
			//For cool people only.
			if(isCool){
				if(tokens[0]=="!coins") {
					int amount=	tokens.length>=2 ? parseInt(tokens[1]) : 100;
					player.server_setCoins(player.getCoins()+amount);
					return false;
				}else if(tokens[0]=="!removebot" || tokens[0]=="!kickbot") {
					int playersAmount=	getPlayerCount();
					for(int i=0;i<playersAmount;i++){
						CPlayer@ user=getPlayer(i);
						if(user !is null && user.isBot()){
							CBitStream params;
							params.write_u16(getPlayerIndex(user));
							this.SendCommand(this.getCommandID("kickPlayer"),params);
							return false;
						}
					}
					return false;
				}else if(tokens[0]=="!addbot" || tokens[0]=="!bot") {
					if(tokens.length<2){
						return false;
					}
					string botName=			tokens[1];
					string botDisplayName=	tokens[1];
					for(int i=2;i<tokens.length;i++){
						botName+=		tokens[i];
						botDisplayName+=" "+tokens[i];
					}
					
					CBitStream params;
					params.write_string(botName);
					params.write_string(botDisplayName);
					this.SendCommand(this.getCommandID("addbot"),params);
					return false;
				}else if(tokens[0]=="!crate") {
					if(tokens.length<2){
						return false;
					}
					int frame = tokens[1]=="catapult" ? 1 : 0;
					string description = tokens.length > 2 ? tokens[2] : tokens[1];
					server_MakeCrate(tokens[1],description,frame,-1,blob.getPosition());
					return false;
				}else if(tokens[0]=="!scroll") {
					if(tokens.length<2){
						return false;
					}
					string s = tokens[1];
					for(uint i=2;i<tokens.length;i++){
						s+=" "+tokens[i];
					}
					server_MakePredefinedScroll(blob.getPosition(),s);
					return false;
				}else if(tokens[0]=="!time") {
					if(tokens.length<2){
						return false;
					}
					getMap().SetDayTime(parseFloat(tokens[1]));
					return false;
				}else if(tokens[0]=="!team") {
					if(tokens.length<2){
						return false;
					}
					int team=parseInt(tokens[1]);
					blob.server_setTeamNum(team);
					
					player.server_setTeamNum(team); // Finally
					return false;
				}else if(tokens[0]=="!playerteam") {
					if(tokens.length!=3){
						return false;
					}
					CPlayer@ user = GetPlayer(tokens[1]);
					
					if(user !is null) {
						CBlob@ userBlob=user.getBlob();
						if(userBlob !is null){
							userBlob.server_setTeamNum(parseInt(tokens[2]));
						}
					}
					return false;
				}else if(tokens[0]=="!class") {
					if(tokens.length!=2){
						return false;
					}
					CBlob@ newBlob = server_CreateBlob(tokens[1],blob.getTeamNum(),blob.getPosition());
					if(newBlob !is null){
						newBlob.server_SetPlayer(player);
						blob.server_Die();
					}
					return false;
				}else if(tokens[0]=="!playerclass") {
					if(tokens.length!=3){
						return false;
					}
					CPlayer@ user = GetPlayer(tokens[1]);
					
					if(user !is null) {
						CBlob@ userBlob=user.getBlob();
						if(userBlob !is null){
							CBlob@ newBlob = server_CreateBlob(tokens[2],userBlob.getTeamNum(),userBlob.getPosition());
							if(newBlob !is null){
								newBlob.server_SetPlayer(user);
								userBlob.server_Die();
							}
						}
					}
					return false;
				}else if(tokens[0]=="!tphere") {
					if(tokens.length!=2){
						return false;
					}
					CPlayer@ tpPlayer=		GetPlayer(tokens[1]);
					if(tpPlayer !is null){
						CBlob@ tpBlob=		tpPlayer.getBlob();
						if(tpBlob !is null) {
							CBitStream params;
							params.write_u16(tpBlob.getNetworkID());
							params.write_u16(blob.getNetworkID());
							getRules().SendCommand(this.getCommandID("teleport"),params);
						}
					}
					return false;
				}else if(tokens[0]=="!tree") {
					server_MakeSeed(blob.getPosition(),"tree_pine",600,1,16);
					return false;
				}else if(tokens[0]=="!teambot") {
					CPlayer@ bot = AddBot("gregor_builder");
					bot.server_setTeamNum(player.getTeamNum());
					
					CBlob@ newBlob = server_CreateBlob("builder",player.getTeamNum(),blob.getPosition());
					newBlob.server_SetPlayer(bot);
					return false;
				}else if(tokens[0]=="!debug") {
					CBlob@[] all; // print all blobs
					getBlobs(@all);

					for(u32 i=0;i<all.length;i++) {
						CBlob@ blob=all[i];
						print("["+blob.getName()+" "+blob.getNetworkID()+"] ");
					}
					return false;
				}else if(tokens[0]=="!bigtree") {
					server_MakeSeed(blob.getPosition(),"tree_bushy",400,2,16);
					return false;
				}else if(tokens[0]=="!spawnwater") {
					getMap().server_setFloodWaterWorldspace(blob.getPosition(),true);
					return false;
				}else if(tokens[0]=="!savefile") {
					ConfigFile cfg;
					cfg.add_u16("something",1337);
					cfg.saveFile("TestFile.cfg");
					return false;
				}else if(tokens[0]=="!loadfile") {
					ConfigFile cfg;
					if(cfg.loadFile("../Cache/TestFile.cfg")) {
						print("loaded");
						print("value is " + cfg.read_u16("something"));
						print(getFilePath(getCurrentScriptName()));
					}
					return false;
				}else if(tokens[0]=="!nextmap"){
					LoadNextMap();
					return false;
				}else if(tokens[0]=="!loadmap") {
					LoadMap(getMap(),"lol.png");
					return false;
				}else if(tokens[0]=="!savemap") {
					SaveMap(getMap(),"lol.png");
					return false;
				}else{
					//Spawn a blob. !banana
					string name=	tokens[0].substr(1,tokens[0].size());
					server_CreateBlob(name,blob.getTeamNum(),blob.getPosition());
					return false;
				}
			}
		}
		return false;
	}else{
		if(blob.getConfig()=="chicken"){
			string[] messages={
				"Bwak!!!",
				"Coo-coo!!",
				"bwaaaak.. bwak.. bwak",
				"Coo-coo-coo",
				"bwuk-bwuk-bwuk...",
				"bwak???",
				"bwakwak, bwak!"
			};
			text_out=messages[XORRandom(messages.length)];
		}else if(blob.getConfig()=="bison"){
			string[] messages={
				"Moo...",
				"moooooooo?",
				"Mooooooooo...",
				"MOOO!",
				"Mooooo.. Moo."
			};
			text_out=messages[XORRandom(messages.length)];
		}
	}
	return true;
}
/*else if(tokens[0]=="!tpinto")
{
	if(tokens.length!=2){
		return false;
	}
	CPlayer@ tpPlayer=	GetPlayer(tokens[1]);
	if(tpPlayer !is null){
		CBlob@ tpBlob=		tpPlayer.getBlob();
		if(tpBlob !is null) {
			AttachmentPoint@ point=	blob.getAttachments().getAttachmentPointByName("PICKUP");
			if(point is null){
				return false;
			}
			for(int i=0;i<blob.getAttachments().getOccupiedCount();i++){
				AttachmentPoint@ point2=blob.getAttachments().getAttachmentPointByID(i);
				if(point !is null){
					CBlob@ pointBlob3=point2.getOccupied();
					if(pointBlob3 !is null){
						print(pointBlob3.getName());
					}
				}
			}
			//tpBlob.setPosition(blob.getPosition());
			//tpBlob.server_AttachTo(CBlob@ blob,AttachmentPoint@ ap)
		}
	}
	return false;
}*/

bool IsCool(string username)
{
	return 	username=="merser433" ||
			username=="TFlippy" ||
			username=="_Koi" ||
			username=="BarsukEughen555";
}
CPlayer@ GetPlayer(string username)
{
	username=			username.toLower();
	int playersAmount=	getPlayerCount();
	for(int i=0;i<playersAmount;i++){
		CPlayer@ player=getPlayer(i);
		if(player.getUsername().toLower()==username || (username.length()>=3 && player.getUsername().toLower().findFirst(username,0)==0)){
			return player;
		}
	}
	return null;
}

bool onClientProcessChat(CRules@ this,const string& in text_in,string& out text_out,CPlayer@ player)
{
	if(text_in=="!debug" && !getNet().isServer())
	{
		// print all blobs
		CBlob@[] all;
		getBlobs(@all);

		for(u32 i = 0; i < all.length; i++)
		{
			CBlob@ blob = all[i];
			print("[" + blob.getName() + " " + blob.getNetworkID() + "] ");

			if(blob.getShape() !is null)
			{
				CBlob@[] overlapping;
				if(blob.getOverlapping(@overlapping))
				{
					for(uint i = 0; i < overlapping.length; i++)
					{
						CBlob@ overlap = overlapping[i];
						print("       " + overlap.getName() + " " + overlap.isLadder());
					}
				}
			}
		}
	}

	return true;
}
