#define CLIENT_ONLY
//#include "GameHelp.as";
#include "KGUI.as";
#include "Achievements.as";
int oldBooty; //used for achievement processing

//topedo kill core -rysi

//----KGUI ELEMENTS----\\
	 	AchieveList shipAchievements;

void intitializeAchieves()
{
	string configstr = "../Cache/WizardWars_Achievements"+achievementsVersion+".cfg";
	ConfigFile cfg = ConfigFile( configstr );
	if (!cfg.exists("Version")){cfg.add_string("Version","Achievements 1.2");
		cfg.saveFile("WizardWars_Achievements"+achievementsVersion+".cfg");}
	shipAchievements = AchieveList(Vec2f(50,40),Vec2f(700,400),1);
	shipAchievements.isEnabled = false;
	shipAchievements.registerAchievement("Tester","You're an official, bonafide, Wizard Wars tester!",3,5,"WizardWars");
	shipAchievements.registerAchievement("First Join","First time here? Heh, you've got a lot to learn, buddy.",1,0,"WizardWars");
	shipAchievements.registerConditionAchievement("Ten Joins","Ring the bells, we got a ten timer over here!",2,1,"WizardWars",10.0f,SColor(240,0,0,255));
	shipAchievements.registerConditionAchievement("Keeps Coming Back","You obviously enjoy this mod, but have you truly mastered it yet?",1,2,"WizardWars",100.0f,SColor(240,0,0,255),"GUI/AchievementsM.png",1);

	shipAchievements.registerAchievement("Winner","Congrats on your first win! You've got potential, kid.",8,0,"WizardWars");
	shipAchievements.registerConditionAchievement("Champion","Hey champ, you've earned it. You're on your way to the big leagues now.",9,1,"WizardWars",100.0f,SColor(240,0,0,255));
	shipAchievements.registerConditionAchievement("Unstoppable","Dayum son, I would give you more but all I have is this gold trophy!",10,6,"WizardWars",1000.0f,SColor(240,0,0,255));
	
	shipAchievements.registerAchievement("Flawless","You won without so much as a scratch! You're a diamond in the rough.",11,3,"WizardWars");

	string servName = getNet().joined_servername;
	if (servName == "Wizard Wars Test Center")shipAchievements.unlockByName("Tester");	
}

void onCommand( CRules@ this, u8 cmd, CBitStream @params )
{
	if (this.getCommandID("unlock") == cmd){
		string playerName = params.read_string(), achieveName = params.read_string();
		client_AddToChat("***"+playerName+" has got the achievement \""+achieveName+"\"!***", SColor(255,0,196,155));
	}
	if (this.getCommandID("requestAchieves") == cmd){	
		CPlayer@ sendFrom = getPlayerByUsername(params.read_string()),sendTo = getPlayerByUsername(params.read_string());
		if(sendFrom.isMyPlayer()){
			CBitStream toSend;
			toSend.write_string(sendTo.getUsername());
			for (int i = 0; i < shipAchievements.list.length; i++){
				toSend.write_bool(shipAchievements.list[i].checkUnlocked());
				print("Added "+shipAchievements.list[i].checkUnlocked()+" gained for "+shipAchievements.list[i].name);
				if (shipAchievements.list[i].hasCon){
					toSend.write_f32(shipAchievements.list[i].getProgress());
					print("Added "+shipAchievements.list[i].getProgress()+" progress for "+shipAchievements.list[i].name);
				}
			}
			this.SendCommand(this.getCommandID("sendAchieves"),toSend);
		}
	}	
	if (this.getCommandID("sendAchieves") == cmd){
		CPlayer@ sendTo = getPlayerByUsername(params.read_string());
		if (sendTo.isMyPlayer()){
			for (int i = 0; i < shipAchievements.list.length; i++){
				shipAchievements.list[i].gained = params.read_bool();
				print("Set "+shipAchievements.list[i].gained+" gained for "+shipAchievements.list[i].name);
				if (shipAchievements.list[i].hasCon){
					shipAchievements.list[i].conditionSet(params.read_f32());
					print("Set "+shipAchievements.list[i].conCurrent+" progress for "+shipAchievements.list[i].name);
				}
			}
		}
	}		
}