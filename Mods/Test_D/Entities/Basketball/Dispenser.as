#include "HoverMessage.as"
#include "BackendCommon.as"
#include "LobbyCommon.as"
#include "Leaderboard.as"

void onInit(CBlob@ this)
{
	CShape@ shape = this.getShape();
	shape.SetStatic(true);
	ShapeConsts@ consts = shape.getConsts();
	consts.mapCollisions = false;

	CSprite@ sprite = this.getSprite();
	sprite.SetZ(-50);

	this.addCommandID("use");
	this.addCommandID("bought");
	this.addCommandID("broke");	

	// basketball leaderboard
	Leaderboard::Init("basketball leaderboard", "Top Basketball Scores");
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("use"))
	{
		CBlob@ blob = getBlobByNetworkID(params.read_netid());
		CRules@ rules = getRules();

		//gather variables
		if (blob is null) return;
		CPlayer@ p = blob.getPlayer();
		if (p is null) return;
		//only server does it
		if (!getNet().isServer()) return;
		//
		string name = p.getUsername();

		bool usebackend = getRules().hasTag("use_backend") && g_debug == 0;

		bool allowed = true;
		Lobby::PlayerRecord@ record = null;
		if (usebackend)
		{
			//todo: display error?
			if (Lobby::hasPlayerRecord(name))
			{
				//get the record
				@record = Lobby::getPlayerRecordFromUsername(name);
				allowed = record.coins > 0;
			}
			else
			{
				allowed = false;
			}
		}

		//has money?
		if (allowed || sv_test)
		{
			if (usebackend && !sv_test)
			{
				record.coins--;
				Backend::PlayerCoinTransaction(p, -1);
				Backend::PlayerMetric(p, "basketball");
			}

			CBitStream params;
			params.write_u16(blob.getNetworkID());
			this.SendCommand(this.getCommandID("bought"), params);
		}
		else
		{
			this.SendCommand(this.getCommandID("broke"));
		}

	}
	else if (cmd == this.getCommandID("bought"))
	{
		if (getNet().isServer())
		{
			CBlob @newBlob = server_CreateBlobNoInit("ball");
			if (newBlob !is null)
			{
				const f32 sign = (this.isFacingLeft() ? -1.0f : 1.0f);
				newBlob.server_setTeamNum(0);
				newBlob.setPosition(this.getPosition() + Vec2f(sign*10, 0) );
				newBlob.Init();		
			}
		}		

		this.getSprite().PlaySound("Blop");				
	}	
	else if (cmd == this.getCommandID("broke"))
	{
		if (getNet().isClient())
		{
			AddMessage(this, "1 coin required");
		}
	}	
}