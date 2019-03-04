#include "ItemsCommon.as";

void onInit(CBlob@ this)
{
	this.set_u8("sword",0);

	this.addCommandID("unequipstaff");
	this.addCommandID("unequipsword");
}

void onTick(CBlob@ this)
{

	for(int i = 0; i < 10; i += 1)if(this.getTeamNum() == i)this.Tag("key"+i);

}

void onCreateInventoryMenu(CBlob@ this, CBlob@ forBlob, CGridMenu @gridmenu)
{
	
	Vec2f pos(gridmenu.getUpperLeftPosition().x + 0.5f * (gridmenu.getLowerRightPosition().x - gridmenu.getUpperLeftPosition().x - 32 * 10),
				  gridmenu.getUpperLeftPosition().y + 32 * 2 - 16);
	CGridMenu@ menu = CreateGridMenu(pos, this, Vec2f(2,2), "Equipment");
	
	AddIconToken("$staffy$", "Staff.png", Vec2f(16, 16), 0);
	AddIconToken("$sword$", "SwordIcon.png", Vec2f(16, 16), 0);
	
	if (menu !is null)
		{
			menu.deleteAfterClick = false;
	
		if(this.getAttachments().getAttachedBlob("STAFF") !is null){
			{
				CGridButton@ b = menu.AddButton("$staffy$", "Unequip Staff.", this.getCommandID("unequipstaff"));
			}
		}
		if(this.getAttachments().getAttachedBlob("SWORD") !is null){
			{
				CGridButton@ b = menu.AddButton("$sword$", "Unequip Sword.", this.getCommandID("unequipsword"));
			}
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	
	if (cmd == this.getCommandID("unequipstaff")){
		if (getNet().isServer())
		{
			this.server_DetachFrom(this.getAttachments().getAttachedBlob("STAFF"));
		}
	}
	if (cmd == this.getCommandID("unequipsword")){
		if (getNet().isServer())
		{
			this.server_DetachFrom(this.getAttachments().getAttachedBlob("SWORD"));
		}
	}
}

void onInit(CSprite@ this)
{
	//reloadSwordSprite(this,0);
}

void onTick(CSprite@ this)
{
	if(this.getBlob().getName() == "knight"){
		CSpriteLayer@ sword = this.getSpriteLayer("sword");
		if(sword !is null){
			sword.SetFrame(this.getFrame());
		}
		if(this.getBlob().get_u8("sword") != DetectSword(this.getBlob())){
			reloadSwordSprite(this,DetectSword(this.getBlob()));
			this.getBlob().set_u8("sword",DetectSword(this.getBlob()));
		}
	}
}

void reloadSwordSprite(CSprite@ this, int id){
	this.RemoveSpriteLayer("sword");
	if(id != 0){
		CSpriteLayer@ sword = this.addSpriteLayer("sword", "sword"+id+".png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (sword !is null)
		{
			Animation@ anim = sword.addAnimation("default", 0, false);
			for(int i = 0; i < 8*8; i += 1)anim.AddFrame(i);
			sword.SetRelativeZ(2.0f);
			sword.SetOffset(Vec2f(0, -4));
			sword.SetFacingLeft(this.isFacingLeft());
		}
	}
	if(this.getSpriteLayer("chop") !is null)
	this.getSpriteLayer("chop").ReloadSprite("sword"+id+".png",32,32,this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
}

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	if(DetectSword(this) == 3){
		if(hitBlob !is null)
		if(hitBlob.hasTag("dead")){
			if(getNet().isServer()){
				CBlob @newBlob = server_CreateBlob("evil_zombie", this.getTeamNum(), hitBlob.getPosition());
				if(this.getPlayer() !is null)newBlob.set_string("boss",this.getPlayer().getUsername());
			}
			hitBlob.server_Die();
			if(this.getAttachments().getAttachedBlob("SWORD") !is null)this.getAttachments().getAttachedBlob("SWORD").set_u16("kills",this.get_u16("kills")+1);
		}
	}
}