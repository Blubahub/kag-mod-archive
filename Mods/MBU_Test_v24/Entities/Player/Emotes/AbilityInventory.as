
#include "AbilityCommon.as"
#include "Abilities.as"

void onInit(CBlob@ this)
{
	this.addCommandID("use_ability");
	this.addCommandID("set_hotbar_slot");
	this.addCommandID("set_hotbar");
	if(!this.exists("slot_setting"))this.set_u8("slot_setting",0);
	
	this.Tag("emote_ability");
}

bool inv_pressed = false;

void onTick(CBlob@ this)
{
	if(this.getPlayer() !is getLocalPlayer())return;
	
	CControls @control = this.getControls();
	
	if(control is null)return;
	
	if (control.ActionKeyPressed(AK_INVENTORY) && !inv_pressed)
	{
		this.set_bool("release click", true);
		inv_pressed = true;
		
		int ability_amount = 0;
		bool human = this.getName() == "humanoid";
	
		for(int i = 0; i < abilities.length; i++)if(hasAbility(this,abilities[i].tag) && (!abilities[i].humanoid_only || human))ability_amount += 1;
		
		int AbilityRows = 1+ability_amount/10;
		
		Vec2f InvPos = getDriver().getScreenCenterPos();
		
		if(this.hasTag("no hands"))InvPos += Vec2f(- 294.0f,0);

		Vec2f abilitypos(InvPos.x + 294.0f,
				  InvPos.y - 32 * 1 - AbilityRows * 24 - 4);
		
		CGridMenu@ menu_abilities = CreateGridMenu(abilitypos, this, Vec2f(9, AbilityRows), "Availble Abilities");
		menu_abilities.deleteAfterClick = false;
		//Ability[] @abilities_array;
		//getRules().get("abilities", @abilities_array);
		for(int i = 0; i < abilities.length; i++){
			Ability ability = abilities[i];
			if(hasAbility(this,ability.tag) && (!abilities[i].humanoid_only || human)){
				CBitStream params;
				params.write_u8(i);
				CGridButton @but = menu_abilities.AddButton(ability.image_script(this), 0, Vec2f(24,24), "Set '"+ability.name+"' to slot "+(this.get_u8("slot_setting")+1), this.getCommandID("set_hotbar"), Vec2f(1,1), params);
				if(but !is null){
					but.SetHoverText(ability.hover_text+"\n");
				}
			}
		}
		
		CGridMenu@ hotbar = CreateGridMenu(abilitypos+Vec2f(0,-AbilityRows * 24 - 64), this, Vec2f(9, 1), "Hotbar slot");
		hotbar.deleteAfterClick = false;
		for(int i = 0;i < 9; i++){
			CBitStream params;
			params.write_u8(i);
			CGridButton @but = hotbar.AddTextButton("("+(i+1)+")", this.getCommandID("set_hotbar_slot"), Vec2f(1,1),params);
			if(but !is null){
				if(this.get_u8("slot_setting") == i)but.SetSelected(1);
			}
		}

	}
	else if (control.ActionKeyReleased(AK_INVENTORY) && inv_pressed)
	{
		this.ClearGridMenus();
		inv_pressed = false;
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("set_hotbar_slot")){
		int slot = params.read_u8();
		this.set_u8("slot_setting",slot);
	}
	
	if (cmd == this.getCommandID("set_hotbar")){
		int ability = params.read_u8();
		this.set_u8("slot_"+(this.get_u8("slot_setting")+1),ability);
		
		this.add_u8("slot_setting",1);
		if(this.get_u8("slot_setting") > 8)this.set_u8("slot_setting",0);
	}
	
	if (cmd == this.getCommandID("use_ability")){
		int ability = params.read_u8();
		UseAbility(this,ability);
	}
	
}