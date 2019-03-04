// Necro logic

#include "Hitters.as";
#include "Knocked.as";
#include "NecroCommon.as";
#include "ThrowCommon.as";
#include "RunnerCommon.as";
#include "Help.as";
#include "Requirements.as"
#include "PlacementCommon.as";
#include "BombCommon.as";

//can't be <2 - needs one frame less for gathering infos
const s32 hit_frame = 2;
const f32 hit_damage = 0.5f;

void onInit(CBlob@ this)
{
	this.set_f32("gib health", -3.0f);

	this.Tag("player");
	this.Tag("flesh");
	this.Tag("evil");
	
	this.set_s16("mode",0);
	
	this.set_s16("darktimer",0);

	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
	shape.getConsts().net_threshold_multiplier = 0.5f;

	this.set_Vec2f("inventory offset", Vec2f(0.0f, 160.0f));

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
	
	
	this.addCommandID("modeshoot");
	this.addCommandID("modebrick");
	this.addCommandID("modewall");
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if(player !is null)
	{
		player.SetScoreboardVars("ScoreboardIconsMod.png", 4, Vec2f(16, 16));
	}
}

void onTick(CBlob@ this)
{
	if(this.isInInventory())
		return;

	const bool ismyplayer = this.isMyPlayer();

	if(ismyplayer && getHUD().hasMenus())
	{
		return;
	}

	// activate/throw
	if(ismyplayer)
	{

		if(this.isKeyJustPressed(key_action3))
		{
			CBlob@ carried = this.getCarriedBlob();
			if(carried is null || !carried.hasTag("temp blob"))
			{
				client_SendThrowOrActivateCommand(this);
			}
		}
	}

	if(this.get_s16("mode") == 0){
		if (!(getKnocked(this) > 0))
		if(this.isKeyPressed(key_action2))
		{
			RunnerMoveVars@ moveVars;
			if(this.get("moveVars", @moveVars))
			{
				moveVars.walkFactor = 0.1f;
				moveVars.jumpFactor = 0.1f;
			}
			CBlob@[] blobsInRadius;	   
			if (this.getMap().getBlobsInRadius(this.getPosition(), 128.0f, @blobsInRadius)) 
			{
				for (uint i = 0; i < blobsInRadius.length; i++)
				{
					CBlob@ b = blobsInRadius[i];
					if    (b.hasTag("dead"))
					{
						if (getNet().isServer())server_CreateBlob("zombie", this.getTeamNum(), b.getPosition()); 
						b.server_Die();
					}
				}
			}
		}
		
		if (getNet().isServer())
		if(this.get_s16("darktimer") > 3){
			if (!(getKnocked(this) > 0))
			if(this.isKeyPressed(key_action1))
			{
				RunnerMoveVars@ moveVars;
				if(this.get("moveVars", @moveVars))
				{
					moveVars.walkFactor = 0.5f;
					moveVars.jumpFactor = 0.5f;
				}
				
				if(this.isKeyPressed(key_action1))
				{
					CBlob @blob = server_CreateBlob("necromissile", this.getTeamNum(), this.getPosition()+Vec2f(XORRandom(8)-4,XORRandom(8)-4));
					if (blob !is null)
					{
						blob.getSprite().PlaySound("/OrbExplosion", 1.2f, 0.70f); // TFlippy
					
						Vec2f smiteVel = this.getAimPos()-this.getPosition();
						smiteVel.Normalize();
						blob.setVelocity(smiteVel*8);
						blob.set_string("owner",this.get_string("owner"));
					}
					this.set_s16("darktimer",0);
				}
			
			}
		} else this.set_s16("darktimer",this.get_s16("darktimer")+1);
	}
	
	if(this.get_s16("mode") == 1){
		if (getNet().isServer())
		if (!(getKnocked(this) > 0))
		if(this.isKeyPressed(key_action1)){
			
			if(this.getAimPos().x < this.getPosition().x+64 && this.getAimPos().x > this.getPosition().x-64)
			if(this.getAimPos().y < this.getPosition().y+64 && this.getAimPos().y > this.getPosition().y-64)
			if(!this.getMap().rayCastSolid(this.getPosition(), this.getAimPos()) ||
			!this.getMap().rayCastSolid(this.getPosition()+Vec2f(8,0), this.getAimPos()+Vec2f(8,0)) ||
			!this.getMap().rayCastSolid(this.getPosition()+Vec2f(-8,0), this.getAimPos()+Vec2f(-8,0)) ||
			!this.getMap().rayCastSolid(this.getPosition()+Vec2f(0,8), this.getAimPos()+Vec2f(0,8)) ||
			!this.getMap().rayCastSolid(this.getPosition()+Vec2f(0,-8), this.getAimPos()+Vec2f(0,-8))){
				if(!this.getMap().isTileSolid(this.getAimPos()))
				if(this.getMap().hasSupportAtPos(this.getAimPos()))
				if(this.getMap().getBlobAtPosition(this.getAimPos()) is null)
					this.getMap().server_SetTile(this.getAimPos(), CMap::tile_castle);
			}
		}
		
		if (getNet().isServer())
		if (!(getKnocked(this) > 0))
		if(this.isKeyPressed(key_action2)){
			
			if(this.getAimPos().x < this.getPosition().x+64 && this.getAimPos().x > this.getPosition().x-64)
			if(this.getAimPos().y < this.getPosition().y+64 && this.getAimPos().y > this.getPosition().y-64)
			if(!this.getMap().rayCastSolid(this.getPosition(), this.getAimPos())){
				for(int i = -1; i <= 1; i += 1)
				for(int j = -1; j <= 1; j += 1)
				if(!this.getMap().isTileSolid(Vec2f(this.getAimPos().x+i*8,this.getAimPos().y+j*8))){
					if(this.getMap().hasSupportAtPos(Vec2f(this.getAimPos().x+i*8,this.getAimPos().y+j*8)))
					this.getMap().server_SetTile(Vec2f(this.getAimPos().x+i*8,this.getAimPos().y+j*8), CMap::tile_castle_back);
				}
			}
		}
	}
	/*
	if (getNet().isServer())
	if(this.get_s16("mode") == 2)
	if (!(getKnocked(this) > 0))
	if(this.isKeyPressed(key_action1)){
		
		if(this.getAimPos().x < this.getPosition().x+64 && this.getAimPos().x > this.getPosition().x-64)
		if(this.getAimPos().y < this.getPosition().y+64 && this.getAimPos().y > this.getPosition().y-64)
		if(!this.getMap().rayCastSolid(this.getPosition(), this.getAimPos()) ||
		!this.getMap().rayCastSolid(this.getPosition()+Vec2f(8,0), this.getAimPos()+Vec2f(8,0)) ||
		!this.getMap().rayCastSolid(this.getPosition()+Vec2f(-8,0), this.getAimPos()+Vec2f(-8,0)) ||
		!this.getMap().rayCastSolid(this.getPosition()+Vec2f(0,8), this.getAimPos()+Vec2f(0,8)) ||
		!this.getMap().rayCastSolid(this.getPosition()+Vec2f(0,-8), this.getAimPos()+Vec2f(0,-8))){
			for(int i = -1; i <= 1; i += 1)
			for(int j = -1; j <= 1; j += 1){
				Vec2f pos = Vec2f(Maths::Round((this.getAimPos().x+4)/8)*8+i*8+4,Maths::Round((this.getAimPos().y+4)/8)*8+j*8+4);
				if(!this.getMap().isTileSolid(pos)){
					if(this.getMap().hasSupportAtPos(pos))
					if(this.getMap().isTileSolid(pos+Vec2f(8,0)) || this.getMap().isTileSolid(pos+Vec2f(-8,0)) ||
					this.getMap().isTileSolid(pos+Vec2f(0,8)) || this.getMap().isTileSolid(pos+Vec2f(0,-8)))
					if(this.getMap().getBlobAtPosition(pos) is null){
						CBlob@ sp = server_CreateBlob("spikes", this.getTeamNum(), pos);
						sp.getShape().SetStatic(true);
					}
				}
			}
		}
	}*/
	
	
}

void onCreateInventoryMenu(CBlob@ this, CBlob@ forBlob, CGridMenu @gridmenu)
{
	this.ClearGridMenusExceptInventory();
	Vec2f pos(gridmenu.getUpperLeftPosition().x + 0.5f * (gridmenu.getLowerRightPosition().x - gridmenu.getUpperLeftPosition().x),
	          gridmenu.getUpperLeftPosition().y - 128 * 1 - 2 * 24);
	CGridMenu@ menu = CreateGridMenu(pos, this, Vec2f(2, 1), "Abilities");
	
	AddIconToken("$deathcoil$", "NecroMissile.png", Vec2f(16, 16), 0);
	
	if (menu !is null)
	{
		menu.deleteAfterClick = true;
		
		menu.AddButton("$deathcoil$", "Shoot zombifying coils.", this.getCommandID("modeshoot"));
		menu.AddButton("$stone_block$", "Build bricks.", this.getCommandID("modebrick"));
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("modeshoot")){
		this.set_s16("mode",0);
	}
	if (cmd == this.getCommandID("modebrick")){
		this.set_s16("mode",1);
	}
	if (cmd == this.getCommandID("modewall")){
		this.set_s16("mode",2);
	}
}