
#include "AbilityCommon.as"

const f32 Scale = 1.0f;
const f32 PosScale = Scale*2.0f;

Vec2f HUD = Vec2f(12,12);

void onRender(CSprite@ this)
{
	if (g_videorecording)
		return;

	CBlob@ blob = this.getBlob();
	CPlayer@ player = blob.getPlayer();
	
	if(getLocalPlayer() !is player)return;
	
	
	GUI::DrawIcon("AbilityHUD.png", 0, Vec2f(264, 32), HUD, Scale);
	
	CControls@ controls = getControls();

	bool pressed = false;
	
	for(int i = 0;i < 9;i++){
		int id = blob.get_u8("slot_"+(i+1));
		
		SColor Text_colour(0xff130d1d);
		GUI::SetFont("menu");
		
		if(!pressed)
		if (controls.isKeyPressed(KEY_KEY_1+i) || (blob.get_u8("slot_setting") == i && blob.isKeyPressed(key_inventory))){
			GUI::DrawIcon("AbilityHUDHighlight.png", 0, Vec2f(28, 28), HUD+Vec2f(i*29*PosScale+2*PosScale,2*PosScale), Scale);
			pressed = true;
		}
		
		GUI::DrawText(" "+(i+1), HUD+Vec2f(i*29*PosScale+20*PosScale,20*PosScale), Text_colour);
		
		if(id == 0)GUI::DrawIcon("Emoticons.png", blob.get_u8("emotehud_"+(i+1)), Vec2f(32, 32), HUD+Vec2f(i*29*PosScale,-4*PosScale), Scale);
		else {
			//Ability[] @abilities;
			//getRules().get("abilities", @abilities);
			if(id < abilities.length){
				Ability ability = abilities[id];
				
				GUI::DrawIcon(ability.image_script(blob), 0, Vec2f(24, 24), HUD+Vec2f(i*29*PosScale+4*PosScale,4*PosScale), Scale);
				
				int CD = CheckCooldown(blob,ability.cooldown);
				
				if(CD > 0){
					SColor grey_colour(0x99999999);
					GUI::DrawRectangle(HUD+Vec2f(i*29*PosScale+4*PosScale,4*PosScale), HUD+Vec2f(i*29*PosScale+28*PosScale,28*PosScale), grey_colour);
					
					GUI::DrawText(" "+(Maths::Roundf(CD*10.0f/30.0f)/10.0f)+"s", HUD+Vec2f(i*29*PosScale+1*PosScale,20*PosScale), Text_colour);
				}
			}
			
		}
	}
	
}
