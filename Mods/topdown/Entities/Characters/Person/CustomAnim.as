
/*void onInit(CSprite@ this)
{
	onSetPlayer(t )
}*/
const f32 config_offset = -4.0f;

void onSetPlayer(CBlob@ this, CPlayer@ player)
{	
	CSprite@ sprite = this.getSprite();
	if(this.hasTag("dead"))
	{
		//print("is ded");
		return;
	}
	if (sprite is null) return;
	if (player !is null)
	{
		string playersprite = "Body_" + player.getUsername() + ".png";
		CFileImage@ image = CFileImage(playersprite);
		if (image is null)
		{
			//print("skin image not found");
		}

		if (image.getSizeInPixels() == 3072 || image.getSizeInPixels() == 6144 )
		{
			this.getSprite().ReloadSprite("../Mods/osmod/Entities/Characters/Custom/"+playersprite);
			this.set_string("skinpath2", "../Mods/osmod/Entities/Characters/Custom/"+playersprite);
			//if(!this.getSprite().ReloadSprite("../Mods/osmod/Entities/Characters/Custom/"+playersprite)) return;
			//print("player set");
			LoadSprites2(sprite, "../Mods/osmod/Entities/Characters/Custom/"+playersprite);
			return;
		}


	}
	u16 randomnum = XORRandom(4);
	string randomskin = "../Mods/osmod/Entities/Characters/Skins/Default_"+randomnum+".png";
	this.getSprite().ReloadSprite(randomskin);
	this.set_string("skinpath", randomskin);
	//print("randomskin onsetplayer");
	LoadSprites2(sprite, randomskin);
}

void onInit(CBlob@ this, CPlayer@ player)
{	
	CSprite@ sprite = this.getSprite();
	if (sprite is null)
	{
		//print("no sprite");
		return;
	}

	if (player is null && !this.hasTag("dead"))
	{/*
		if(this.hasTag("type skin"))
		{
			string skinname = this.get_string("skinname");
			string path = ("../Mods/osmod/Entities/Characters/Skins/"+skinname + ".png");
			this.getSprite().ReloadSprite(path);
			LoadSprites2(sprite, path);
			print("loaded type skin");
			return;
		}*/
		u16 randomnum = XORRandom(4);
		string randomskin = "../Mods/osmod/Entities/Characters/Skins/Default_"+randomnum+".png";
		this.getSprite().ReloadSprite(randomskin);
		this.set_string("skinpath", randomskin);
		LoadSprites2(sprite, randomskin);
		//print("randomskin oninit");
		return;
	}

}
void onTick(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();	
	if (sprite is null)
	{
		print("no sprite2");
		return;
	}
	if(this.getTickSinceCreated() < 10 && !this.hasTag("typeskinned"))
	{
		if (this.hasTag("type skin"))
		{
			this.Init();
			string skinname = this.get_string("skinname") + ".png";
			string path = ("../Mods/osmod/Entities/Characters/Skins/"+skinname);
			this.set_string("skinpath", path);
			this.getSprite().ReloadSprite(path);
			LoadSprites2(sprite, path);
			//print("loaded type skin2");
			this.Tag("typeskinned");
			return;
		}

	}
}
void LoadSprites2(CSprite@ this, string texname)
{
	//Vec2f config_offset = Vec2f(0,0);
	//string texname = "BodyParts.png";
	
	CBlob@ blob = this.getBlob();/*
	if(blob !is null)
	{	
		CPlayer@ player = blob.getPlayer();
		if(player !is null)
		{
			texname = blob.get_string("skinpath2");

		}

	}*/

	this.ReloadSprite(texname, this.getConsts().frameWidth, this.getConsts().frameHeight,
	                  this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
	this.RemoveSpriteLayer("head");
	CSpriteLayer@ head = this.addSpriteLayer("head", texname, 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (head !is null)
	{
		Animation@ anim = head.addAnimation("default", 0, false);
		anim.AddFrame(3);
		head.SetOffset(Vec2f(0.0f, 3.0f + config_offset));
		head.SetAnimation("default");
		head.SetVisible(true);
		head.SetRelativeZ(0.15);
	}

	this.RemoveSpriteLayer("rightarm");
	CSpriteLayer@ rightarm = this.addSpriteLayer("rightarm", texname, 16, 16, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (rightarm !is null)
	{
		Animation@ anim = rightarm.addAnimation("default", 0, false);
		anim.AddFrame(3);
		rightarm.SetOffset(Vec2f(-0.0f, 0.0f + config_offset));
		rightarm.SetAnimation("default");
		rightarm.SetVisible(true);
		rightarm.SetRelativeZ(-0.5);
	}

	this.RemoveSpriteLayer("leftarm");
	CSpriteLayer@ leftarm = this.addSpriteLayer("leftarm", texname, 16, 16, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (leftarm !is null)
	{
		Animation@ anim = leftarm.addAnimation("default", 0, false);
		anim.AddFrame(2);
		leftarm.SetOffset(Vec2f(-0.0f, 0.0f + config_offset));
		leftarm.SetAnimation("default");
		leftarm.SetVisible(true);
		leftarm.SetRelativeZ(-0.5);
	}

	this.RemoveSpriteLayer("righthand");
	CSpriteLayer@ righthand = this.addSpriteLayer("righthand", texname, 16, 16, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (righthand !is null)
	{
		Animation@ anim = righthand.addAnimation("default", 0, false);
		anim.AddFrame(5);
		righthand.SetOffset(Vec2f(-0.0f, 0.0f + config_offset));
		righthand.SetAnimation("default");
		righthand.SetVisible(true);
		righthand.SetRelativeZ(-0.3);
	}
	this.RemoveSpriteLayer("lefthand");
	CSpriteLayer@ lefthand = this.addSpriteLayer("lefthand", texname, 16, 16, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (lefthand !is null)
	{
		Animation@ anim = lefthand.addAnimation("default", 0, false);
		anim.AddFrame(4);
		lefthand.SetOffset(Vec2f(-0.0f, 0.0f + config_offset));
		lefthand.SetAnimation("default");
		lefthand.SetVisible(true);
		lefthand.SetRelativeZ(-0.3);
	}
	this.RemoveSpriteLayer("rightleg");
	CSpriteLayer@ rightleg = this.addSpriteLayer("rightleg", texname, 16, 16, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (rightleg !is null)
	{
		Animation@ anim = rightleg.addAnimation("default", 0, false);
		anim.AddFrame(9);
		rightleg.SetOffset(Vec2f(-0.0f, 0.0f + config_offset));
		rightleg.SetAnimation("default");
		rightleg.SetVisible(true);
		rightleg.SetRelativeZ(-1.3);
	}


	this.RemoveSpriteLayer("leftleg");
	CSpriteLayer@ leftleg = this.addSpriteLayer("leftleg", texname, 16, 16, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (leftleg !is null)
	{
		Animation@ anim = leftleg.addAnimation("default", 0, false);
		anim.AddFrame(8);
		leftleg.SetOffset(Vec2f(-0.0f, 0.0f + config_offset));
		leftleg.SetAnimation("default");
		leftleg.SetVisible(true);
		leftleg.SetRelativeZ(-0.8);
	}

	this.RemoveSpriteLayer("leftfoot");
	CSpriteLayer@ leftfoot = this.addSpriteLayer("leftfoot", texname, 16, 16, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (leftfoot !is null)
	{
		Animation@ anim = leftfoot.addAnimation("default", 0, false);
		anim.AddFrame(10);
		leftfoot.SetOffset(Vec2f(-0.0f, 0.0f + config_offset));
		leftfoot.SetAnimation("default");
		leftfoot.SetVisible(true);
		leftfoot.SetRelativeZ(-0.7);
	}

	this.RemoveSpriteLayer("rightfoot");
	CSpriteLayer@ rightfoot = this.addSpriteLayer("rightfoot", texname, 16, 16, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (rightfoot !is null)
	{
		Animation@ anim = rightfoot.addAnimation("default", 0, false);
		anim.AddFrame(11);
		rightfoot.SetOffset(Vec2f(-0.0f, 0.0f + config_offset));
		rightfoot.SetAnimation("default");
		rightfoot.SetVisible(true);
		rightfoot.SetRelativeZ(-1.0);
	}


}