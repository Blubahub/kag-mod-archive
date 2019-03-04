
#include "Diplomat_Main.as";
#include "EXP_sys.as";
#include "TeamMenu.as";
/*
const string warText = " are at WAR with ";
const string neutralText = " are neutral with ";
const string friendText = " are friends with ";
const SColor warColour = SColor(255,200,80,80);
const SColor neutralColour = SColor(255,0,204,204);
const SColor friendColour = SColor(255,102,255,102);*/

void onRender(CRules@ this)
{
	if (g_videorecording)
		return;

	CPlayer@ p = getLocalPlayer();

	if (p is null || !p.isMyPlayer())
		return;

	if(p.getBlob() !is null)
	{

		GUI::SetFont("");//sets it to normal font
		GUI::DrawText("[PLACE HOLDER]", Vec2f(20,20), SColor(255,40,200,200));
		u8 team = p.getTeamNum();
		u8 team0Status = getDiplomatStatus(this,team,1);
		u8 team1Status = getDiplomatStatus(this,team,1);
		u8 team2Status = getDiplomatStatus(this,team,2);
		u8 team3Status = getDiplomatStatus(this,team,3);

		GUI::DrawPane(Vec2f(15,35), Vec2f(195,100), SColor(200,50,50,50));//Diplomatic backdrop

		GUI::DrawPane(Vec2f(15,110), Vec2f(135,155), SColor(200,50,50,50));//EXP backdrop
		string ourTeam = this.get_string("Team" + p.getTeamNum());

		switch(team)//TODO clean up or optimize a little? Looks kinda 'messy'
		{
			case 0:
				//GUI::DrawText(ourTeam+" are at WAR with " +this.get_string("Team1"), Vec2f(20,40), SColor(255,200,80,80));

				if(team1Status == 1)
					GUI::DrawText(ourTeam+" are at WAR with " +this.get_string("Team1"), Vec2f(20,40), SColor(255,200,80,80));
				else if(team1Status == 2)
					GUI::DrawText(ourTeam+" are neutral with "+this.get_string("Team1"), Vec2f(20,40), SColor(255,0,204,204));
				else
					GUI::DrawText(ourTeam+" are friends with "+this.get_string("Team1"), Vec2f(20,40), SColor(255,102,255,102));

				if(team2Status == 1)
					GUI::DrawText(ourTeam+" are at WAR with " +this.get_string("Team2"), Vec2f(20,60), SColor(255,200,80,80));
				else if(team2Status == 2)
					GUI::DrawText(ourTeam+" are neutral with "+this.get_string("Team2"), Vec2f(20,60), SColor(255,0,204,204));
				else
					GUI::DrawText(ourTeam+" are friends with "+this.get_string("Team2"), Vec2f(20,60), SColor(255,102,225,102));

				if(team3Status == 1)
					GUI::DrawText(ourTeam+" are at WAR with " +this.get_string("Team3"), Vec2f(20,80), SColor(255,200,80,80));
				else if(team3Status == 2)
					GUI::DrawText(ourTeam+" are neutral with "+this.get_string("Team3"), Vec2f(20,80), SColor(255,0,204,204));
				else
					GUI::DrawText(ourTeam+" are friends with "+this.get_string("Team3"), Vec2f(20,80), SColor(255,102,225,102));
				break;

			case 1:
				if(team0Status == 1)
					GUI::DrawText(ourTeam+" are at WAR with " +this.get_string("Team0"), Vec2f(20,40), SColor(255,200,80,80));
				else if(team0Status == 2)
					GUI::DrawText(ourTeam+" are neutral with "+this.get_string("Team0"), Vec2f(20,40), SColor(255,0,204,204));
				else
					GUI::DrawText(ourTeam+" are friends with "+this.get_string("Team0"), Vec2f(20,40), SColor(255,102,255,102));

				if(team2Status == 1)
					GUI::DrawText(ourTeam+" are at WAR with " +this.get_string("Team2"), Vec2f(20,60), SColor(255,200,80,80));
				else if(team2Status == 2)
					GUI::DrawText(ourTeam+" are neutral with "+this.get_string("Team2"), Vec2f(20,60), SColor(255,0,204,204));
				else if(team2Status == 3)
					GUI::DrawText(ourTeam+" are friends with "+this.get_string("Team2"), Vec2f(20,60), SColor(255,102,225,102));

				if(team3Status == 1)
					GUI::DrawText(ourTeam+" are at WAR with " +this.get_string("Team3"), Vec2f(20,80), SColor(255,200,80,80));
				else if(team3Status == 2)
					GUI::DrawText(ourTeam+" are neutral with "+this.get_string("Team3"), Vec2f(20,80), SColor(255,0,204,204));
				else
					GUI::DrawText(ourTeam+" are friends with "+this.get_string("Team3"), Vec2f(20,80), SColor(255,102,225,102));
				break;

			case 2:
				if(team0Status == 1)
					GUI::DrawText(ourTeam+" are at WAR with " +this.get_string("Team0"), Vec2f(20,40), SColor(255,200,80,80));
				else if(team0Status == 2)
					GUI::DrawText(ourTeam+" are neutral with "+this.get_string("Team0"), Vec2f(20,40), SColor(255,0,204,204));
				else if(team0Status == 3)
					GUI::DrawText(ourTeam+" are friends with "+this.get_string("Team0"), Vec2f(20,40), SColor(255,102,255,102));

				if(team1Status == 1)
					GUI::DrawText(ourTeam+" are at WAR with " +this.get_string("Team1"), Vec2f(20,60), SColor(255,200,80,80));
				else if(team2Status == 2)
					GUI::DrawText(ourTeam+" are neutral with "+this.get_string("Team1"), Vec2f(20,60), SColor(255,0,204,204));
				else
					GUI::DrawText(ourTeam+" are friends with "+this.get_string("Team1"), Vec2f(20,60), SColor(255,102,225,102));

				if(team3Status == 1)
					GUI::DrawText(ourTeam+" are at WAR with " +this.get_string("Team3"), Vec2f(20,80), SColor(255,200,80,80));
				else if(team3Status == 2)
					GUI::DrawText(ourTeam+" are neutral with "+this.get_string("Team3"), Vec2f(20,80), SColor(255,0,204,204));
				else
					GUI::DrawText(ourTeam+" are friends with "+this.get_string("Team3"), Vec2f(20,80), SColor(255,102,225,102));
				break;

			case 3:
				if(team0Status == 1)
					GUI::DrawText(ourTeam+" are at WAR with " +this.get_string("Team0"), Vec2f(20,40), SColor(255,200,80,80));
				else if(team0Status == 2)
					GUI::DrawText(ourTeam+" are neutral with "+this.get_string("Team0"), Vec2f(20,40), SColor(255,0,204,204));
				else if(team0Status == 3)
					GUI::DrawText(ourTeam+" are friends with "+this.get_string("Team0"), Vec2f(20,40), SColor(255,102,255,102));

				if(team2Status == 1)
					GUI::DrawText(ourTeam+" are at WAR with " +this.get_string("Team1"), Vec2f(20,60), SColor(255,200,80,80));
				else if(team2Status == 2)
					GUI::DrawText(ourTeam+" are neutral with "+this.get_string("Team1"), Vec2f(20,60), SColor(255,0,204,204));
				else if(team2Status == 3)
					GUI::DrawText(ourTeam+" are friends with "+this.get_string("Team1"), Vec2f(20,60), SColor(255,102,225,102));

				if(team2Status == 1)
					GUI::DrawText(ourTeam+" are at WAR with " +this.get_string("Team2"), Vec2f(20,80), SColor(255,200,80,80));
				else if(team2Status == 2)
					GUI::DrawText(ourTeam+" are neutral with "+this.get_string("Team2"), Vec2f(20,80), SColor(255,0,204,204));
				else if(team2Status == 3)
					GUI::DrawText(ourTeam+" are friends with "+this.get_string("Team2"), Vec2f(20,80), SColor(255,102,225,102));
				break;

		//do other teams next
		}

		if(this.exists(p.getUsername() + " EXP " + p.getBlob().getName()))
		{
			GUI::DrawText("Class : " + p.getBlob().getName(), Vec2f(20,115), SColor(255,200,200,200));
			GUI::DrawText("Level : " + getStuff(p.getUsername(), p.getBlob().getName(), false), Vec2f(20,125), SColor(255,200,80,80));
			GUI::DrawText("Experience : " + getStuff(p.getUsername(), p.getBlob().getName(), true), Vec2f(20,135), SColor(255,200,80,80));
		}
		else
		{
			GUI::DrawText("Class : "+ p.getBlob().getName() , Vec2f(20,115), SColor(255,200,200,200));
			GUI::DrawText("Level : 0", Vec2f(20,125), SColor(255,200,80,80));
			GUI::DrawText("Experience : 0", Vec2f(20,135), SColor(255,200,80,80));
		}

		if(p.hasTag("Grave Nearby"))//Need to make it scale better
		{	//Move it to mouse Pos and maybe have text change on render if its unreadable
			Vec2f gravePos = p.get_Vec2f("gravePos");
			int radius = p.getBlob().getRadius();
			if((p.getBlob().getPosition() - gravePos).Length() < 1.5f * (radius*2))
			{
				Vec2f dim;
				string text = p.get_string("text");

				GUI::GetTextDimensions(text , dim);
				dim.x = (dim.x / 6) + 15;//Works with big enough text
				GUI::DrawPane(Vec2f(15,165), Vec2f(135,175 + dim.x + 10 ), SColor(200,50,50,50));//Back panel for graves stuff
				GUI::DrawText("Grave text reads:", Vec2f(20,170), SColor(255,200,80,80));
				GUI::DrawText(text, Vec2f(20,185), Vec2f(135,185 + dim.x), SColor(255,200,80,80), false,false);
				//GUI::DrawText(p.get_string("text") + "\n", Vec2f(20,185), SColor(255,200,80,80));
			}
			else
			{
				p.Untag("Grave Nearby");
			}

		}

		if(p.hasTag("EXP Menu"))
		{//Improve before release. 
			Vec2f screenBy2 = Vec2f(getScreenWidth() / 2, getScreenHeight() / 2);
			Vec2f[] buttonCenter = {(Vec2f(screenBy2.x - 25, screenBy2.y - 25) + Vec2f(+ 25,  + 25))};
			int[] buttonLength = {buttonCenter[0].Length() * 30};
			//Vec2f mousePos = Vec2f(mousePos.x,mousePos.y);
			CControls@ controls = getControls();
			Vec2f mousePos = controls.getMouseScreenPos() - Vec2f(screenBy2.x - 400,screenBy2.y - 250);
			int mouseLength = mousePos.Length();
			CHUD@ hud = getHUD();
			hud.menuState = 1;
			hud.disableButtonsForATick = true;

			bool mouseClicked = controls.isKeyJustPressed(KEY_LBUTTON);
			GUI::DrawPane(Vec2f(screenBy2.x - 400,screenBy2.y - 250), Vec2f(screenBy2.x + 400,screenBy2.y + 250), SColor(255,50,50,50));

			GUI::DrawIcon("EXPIsUnlocked.png", 0, Vec2f(8,4), Vec2f(screenBy2.x + 23, screenBy2.y - 4), 7.0f, 1.0f, SColor(255,155,155,155));
			//2 testies

			GUI::DrawButtonHover(Vec2f(screenBy2.x - 25, screenBy2.y - 25), Vec2f(screenBy2.x + 25, screenBy2.y + 25));

			
			GUI::DrawButtonHover(Vec2f(screenBy2.x - 25, screenBy2.y - 25), Vec2f(screenBy2.x + 25, screenBy2.y + 25));

			GUI::DrawButtonHover(Vec2f(screenBy2.x + 125, screenBy2.y - 25), Vec2f(screenBy2.x + 175, screenBy2.y + 25));

			//if((mousePos - ).Length() < 1.5f * (radius*2))

			if(mouseClicked)//does count a few times for some reason, TODO fix this
			{
				//get mouse sector

				//if((mousePos - buttonCenter[0]).Length() < 30)
				//{
				//	print(""+isSquareUnlocked(p,0));
				//	print(""+(mousePos - buttonCenter[0]).Length());
				//}

				print(""+(mousePos.Length()));
				//445
				//758
				//942


			}
	

			//middle level 1 button
			//GUI::DrawButtonHover(Vec2f(screenBy2.x - 25, screenBy2.y - 25), Vec2f(screenBy2.x + 25, screenBy2.y + 25));

			// left side, top side, right side, bottom side

			//right 2nd
			/*GUI::DrawButtonHover(Vec2f(screenBy2.x + 125, screenBy2.y - 25), Vec2f(screenBy2.x + 175, screenBy2.y + 25)); 

			//right 3rd (middle)
			GUI::DrawButtonHover(Vec2f(screenBy2.x + 275, screenBy2.y - 25), Vec2f(screenBy2.x + 325, screenBy2.y + 25)); 

			//right 3rd + upper
			GUI::DrawButtonHover(Vec2f(screenBy2.x + 275, screenBy2.y - 125), Vec2f(screenBy2.x + 325, screenBy2.y - 75)); 

			//right 3rd + lower
			GUI::DrawButtonHover(Vec2f(screenBy2.x + 275, screenBy2.y + 75), Vec2f(screenBy2.x + 325, screenBy2.y + 125)); 

			//right bottom
			GUI::DrawButtonHover(Vec2f(screenBy2.x + 275, screenBy2.y + 175), Vec2f(screenBy2.x + 325, screenBy2.y + 225)); 

			//right top
			GUI::DrawButtonHover(Vec2f(screenBy2.x + 275, screenBy2.y - 225), Vec2f(screenBy2.x + 325, screenBy2.y - 175));



			//left 2nd
			GUI::DrawButtonHover(Vec2f(screenBy2.x - 175, screenBy2.y - 25), Vec2f(screenBy2.x - 125, screenBy2.y + 25)); 

			//left 3rd (middle)
			GUI::DrawButtonHover(Vec2f(screenBy2.x - 325, screenBy2.y - 25), Vec2f(screenBy2.x - 275, screenBy2.y + 25)); 

			//left 3rd upper
			GUI::DrawButtonHover(Vec2f(screenBy2.x - 325, screenBy2.y - 125), Vec2f(screenBy2.x - 275, screenBy2.y - 75)); 

			//left 3rd lower
			GUI::DrawButtonHover(Vec2f(screenBy2.x - 325, screenBy2.y + 75), Vec2f(screenBy2.x - 275, screenBy2.y + 125)); 

			//left bottom
			GUI::DrawButtonHover(Vec2f(screenBy2.x - 325, screenBy2.y + 175), Vec2f(screenBy2.x - 275, screenBy2.y + 225)); 

			//left top
			GUI::DrawButtonHover(Vec2f(screenBy2.x - 325, screenBy2.y - 225), Vec2f(screenBy2.x - 275, screenBy2.y - 175));*/




				////
		}

		
	}
	else//player blob is dead
	{
		s32 respawnTime = p.get_u32("respawn time");
		if(respawnTime > getGameTime())//Respawn timer that comes up
		{
			if (p.getTeamNum() < 253)
			{
				GUI::DrawPane(Vec2f(0,0), Vec2f(getScreenWidth(),getScreenHeight()), SColor(255,0,0,0));
				//GUI::DrawShadowedText("You have died", Vec2f(getScreenWidth() / 2 - 70, getScreenHeight() / 3 + 60), SColor(255,200,0,0));
				GUI::drawRulesFont("You have died",SColor(255,255,50,50), Vec2f(getScreenWidth() / 2 - 70, getScreenHeight() / 3 + 60), Vec2f(0,0), false, false);
			
				GUI::SetFont("menu");
				//print(""+(Maths::Sin(getGameTime() / 2.0f) * 25) ); //For SColor in the future (maybe)
				GUI::DrawText(getTranslatedString("Respawning in: "+((respawnTime / 30) - (getGameTime() / 30))), Vec2f((getScreenWidth() - 25) / 2 - 70, getScreenHeight() / 3 + Maths::Sin(getGameTime() / 2.0f) * 5.0f), SColor(255, 255, 255, 55));
			}
		}
		else if(getLocalPlayer().getTeamNum() == 254)//if player does not have a respawn time (because they just joined or match restarted)
		{
			if(!this.hasTag("Menu Loaded"))//keep popping the menu up until it loads
			{
			    getHUD().ClearMenus(true);
				ShowTeamMenu(this);
			}
		}

	}
}
