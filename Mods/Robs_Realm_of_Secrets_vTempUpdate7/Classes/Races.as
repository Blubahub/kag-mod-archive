#include "RunnerCommon.as";
#include "ItemsCommon.as";
#include "Health.as";
#include "ChangeClass.as";

void onInit(CBlob@ this)
{
	this.set_u8("race",0);
	this.set_u8("race_sprite",-1);
	
	this.set_u8("flesh_hunger",0);
}

void onTick(CBlob@ this)
{
	if(!this.hasTag("checkedfaceless")){
		if(XORRandom(100) == 0)
		if(this.getTeamNum() < 20)this.Tag("faceless");
		this.Tag("checkedfaceless");
	}
	
	int Race = this.get_u8("race");
	
	RunnerMoveVars@ moveVars;
	if (this.get("moveVars", @moveVars)){
		if(Race == 2){
			moveVars.jumpFactor *= 0.9f;
			moveVars.walkFactor *= 0.9f;
		}
		if(Race == 3){
			moveVars.walkFactor *= 1.5f;
		}
		if(Race == 6){
			moveVars.jumpFactor *= 1.5f;
			moveVars.walkFactor *= 0.5f;
		}
		if(Race == 7){
			moveVars.jumpFactor *= 1.1f;
			moveVars.walkFactor *= 1.1f;
		}
		if(Race == 8){
			moveVars.jumpFactor *= 1.5f;
			moveVars.walkFactor *= 1.5f;
		}
		if(Race == 9){
			moveVars.jumpFactor *= 2.0f;
			moveVars.walkFactor *= 2.0f;
		}
	}
	
	if(!this.hasTag("canfly"))this.Untag("flying");
	else this.Tag("flying");
	
	if(this.get_s16("corruption") > 500)if(Race != 6 && Race != 7 && Race != 8)this.set_u8("race",1);
	
	if(Race == 1){
		this.Tag("evil");
		this.Tag("pure_corruption");
	} else {
		this.Untag("pure_corruption");
	}

	if(Race == 3){
		this.Tag("flying");
		this.set_s16("blood",500);
	}
	
	if(Race == 5){
		this.Tag("onewithnature");
	}
	
	if(Race == 6){
		this.Tag("gold");
	}
	
	if(Race == 7){
		this.Tag("holy");
	}
	
	if(Race == 8){
		this.Tag("holy");
	}
	
	if(getNet().isServer()){
		if(this.get_u8("race_sprite") != Race || XORRandom(1000) == 0)this.Sync("race", true);
	}
}


void onTick(CSprite@ this)
{
	int Race = this.getBlob().get_u8("race");
	int RaceSpr = this.getBlob().get_u8("race_sprite");
	if(Race != RaceSpr){
		string modpath = getFilePath(getCurrentScriptName())+"/Sprites/";
		
		string classname = "Builder";
		if(this.getBlob().getName() == "knight")classname = "Knight";
		if(this.getBlob().getName() == "archer")classname = "Archer";
		
		string racename = "Human";
		if(Race == 0)racename = "Human";
		if(Race == 1)racename = "Shadow";
		if(Race == 2)racename = "Risen";
		if(Race == 3)racename = "Faceless";
		if(Race == 4)racename = "Lifeless";
		if(Race == 5)racename = "Druid";
		if(Race == 6)racename = "Golden";
		if(Race == 7)racename = "Holy";
		if(Race == 8)racename = "Ascended";
		if(Race == 9)racename = "Husk";
		
		string texname = modpath+racename+"_"+classname+".png";
		
		print(getFilePath(getCurrentScriptName()));
		
		this.ReloadSprite(texname);
		
		CSpriteLayer@ head = this.getSpriteLayer("head");
		if(head !is null)head.ReloadSprite(modpath+racename+"_Heads.png",16,16,this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		
		if(this.getBlob().getName() == "archer"){
			if(this.getSpriteLayer("frontarm") !is null)
			this.getSpriteLayer("frontarm").ReloadSprite(modpath+racename+"_"+classname+".png",32,16,this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
			if(this.getSpriteLayer("backarm") !is null)
			this.getSpriteLayer("backarm").ReloadSprite(modpath+racename+"_"+classname+".png",32,16,this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
			if(this.getSpriteLayer("quiver") !is null)
			this.getSpriteLayer("quiver").ReloadSprite(modpath+racename+"_"+classname+".png",16,16,this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
			if(this.getSpriteLayer("hook") !is null)
			this.getSpriteLayer("hook").ReloadSprite(modpath+racename+"_"+classname+".png",16,8,this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
			if(this.getSpriteLayer("rope") !is null)
			this.getSpriteLayer("rope").ReloadSprite(modpath+racename+"_"+classname+".png",32,8,this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		}
		
		if(this.getBlob().getName() == "knight" && DetectSword(this.getBlob()) != 0){
			if(this.getSpriteLayer("chop") !is null)
			this.getSpriteLayer("chop").ReloadSprite(modpath+racename+"_"+classname+".png",32,32,this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		}
		
		if(Race == 3){
			this.RemoveSpriteLayer("cape");
			CSpriteLayer@ cape = this.addSpriteLayer("cape", modpath+racename+"_Cape.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
			cape.SetRelativeZ(-1.0f);
		} else {
			this.RemoveSpriteLayer("cape");
		}
		
		this.getBlob().set_u8("race_sprite",Race);
	}
	

}

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	if(hitBlob !is null)
	if(hitBlob !is this)
	if(hitBlob.hasTag("dead") && hitBlob.hasTag("flesh") && hitBlob.getName() != "chicken" && hitBlob.getName() != "bison"){
		if(hitBlob.getHealth()-hitBlob.get_f32("gib health") <= 0){
			this.set_u8("flesh_hunger",this.get_u8("flesh_hunger")+1);
			if(this.getPlayer() !is null)
			if(this.getPlayer().isMyPlayer()){
				
				string warning = "Defiling the dead is a horrible idea.";
				
				switch(XORRandom(10)){
				
					case 0:{
						warning = "Defiling the dead is not something you should do.";
					break;}
				
					case 1:{
						warning = "Bad things happen to those who defile the dead.";
					break;}
					
					case 2:{
						warning = "The dead should not be defiled!";
					break;}
					
					case 3:{
						warning = "The dead do not like being defiled.";
					break;}
					
					case 4:{
						warning = "Destroying bodies, what a morbid task.";
					break;}
					
					case 5:{
						warning = "That body should of been buried, not defiled.";
					break;}
					
					case 6:{
						warning = "How can the dead rest with someone like you around?";
					break;}
					
					case 7:{
						warning = "Destroying the body, adding insult to injury.";
					break;}
					
					case 8:{
						warning = "Only the evil defile, are you evil?";
					break;}
					
					case 9:{
						warning = "Defiling bodies like this, this is madness.";
					break;}
					
				}
				
				if(this.get_u8("flesh_hunger") > 10){
					switch(XORRandom(10)){
					
						case 0:{
							warning = "This is madness, stop defiling bodies!";
						break;}
					
						case 1:{
							warning = "Destroying bodies, You walk down a dangerous road...";
						break;}
						
						case 2:{
							warning = "The men who defile bodies like you go insane.";
						break;}
						
						case 3:{
							warning = "Destroying bodies, your madness is over coming you.";
						break;}
						
						case 4:{
							warning = "Stop! Soon you won't be able to control yourself.";
						break;}
						
						case 5:{
							warning = "Defiling bodies, don't give into this madness!";
						break;}
						
						case 6:{
							warning = "All these bodies defiled, how can you live with yourself?";
						break;}
						
						case 7:{
							warning = "Stop defiling bodies before your hunger of flesh grows!";
						break;}
						
						case 8:{
							warning = "Defiling others only defiles yourself!";
						break;}
						
						case 9:{
							warning = "Soon, you will want to stop defiling, but won't be able to.";
						break;}
						
					}
				}
				
				if(this.get_u8("flesh_hunger") > 20){
					warning = "YOU LOSE CONTROL OF YOUR MIND";
				}
				
				client_AddToChat(warning, SColor(255, 100, 50, 50));
			}
			
			if(getNet().isServer()){
				if(!this.hasTag("ghoultransform"))
				if(this.get_u8("flesh_hunger") > 20){
					ChangeClass(this, "ghoul", this.getPosition(), this.getTeamNum());
					this.Tag("ghoultransform");
				}
			}
		}
	}
}