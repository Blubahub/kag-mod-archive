// include file for blobs that use portal travel capabilities
// apply "travel portal" tag to use

#include "PortalCommon.as";

void onInit(CBlob@ this)
{
	this.addCommandID("travel");
	this.addCommandID("travel none");
	this.addCommandID("travel to");
	this.addCommandID("server travel to");
	this.Tag("travel portal");

	AddIconToken("$TRAVEL_LEFT$", "GUI/MenuItems.png", Vec2f(32, 32), 23);
	AddIconToken("$TRAVEL_RIGHT$", "GUI/MenuItems.png", Vec2f(32, 32), 22);

	if (!this.exists("travel button pos"))
	{
		this.set_Vec2f("travel button pos", Vec2f_zero);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (caller.getTeamNum() == this.getTeamNum() && this.isOverlapping(caller) &&
		this.hasTag("activated") &&
	        this.hasTag("travel portal") &&
	        (!this.hasTag("teamlocked portal") || this.getTeamNum() == caller.getTeamNum()) &&
	        !this.hasTag("under raid"))
	{
		MakeTravelButton(this, caller, this.get_Vec2f("travel button pos"), "Travel", "Travel (requires Transport Portals)");
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	onPortalCommand(this, cmd, params);
}

// get all team portals sorted by team distance

bool getPortalsForButtons(CBlob@ this, CBlob@[]@ portals)
{
	CBlob@[] list;
	getBlobsByTag("travel portal", @list);
	Vec2f thisPos = this.getPosition();

	// add left portals
	for (uint i = 0; i < list.length; i++)
	{
		CBlob@ blob = list[i];
		if (blob !is this && blob.getTeamNum() == this.getTeamNum() && blob.getPosition().x < thisPos.x)
		{
			bool added = false;
			const f32 distToBlob = (blob.getPosition() - thisPos).getLength();
			for (uint portalInd = 0; portalInd < portals.length; portalInd++)
			{
				CBlob@ portal = portals[portalInd];
				if ((portal.getPosition() - thisPos).getLength() < distToBlob)
				{
					portals.insert(portalInd, blob);
					added = true;
					break;
				}
			}
			if (!added)
				portals.push_back(blob);
		}
	}

	portals.push_back(null);	// add you are here

	// add right portals
	const uint portalIndStart = portals.length;

	for (uint i = 0; i < list.length; i++)
	{
		CBlob@ blob = list[i];
		if (blob !is this && blob.getTeamNum() == this.getTeamNum() && blob.getPosition().x >= thisPos.x)
		{
			bool added = false;
			const f32 distToBlob = (blob.getPosition() - thisPos).getLength();
			for (uint portalInd = portalIndStart; portalInd < portals.length; portalInd++)
			{
				CBlob@ portal = portals[portalInd];
				if ((portal.getPosition() - thisPos).getLength() > distToBlob)
				{
					portals.insert(portalInd, blob);
					added = true;
					break;
				}
			}
			if (!added)
				portals.push_back(blob);
		}
	}
	return portals.length > 0;
}

bool isInRadius(CBlob@ this, CBlob @caller)
{
	return ((this.getPosition() - caller.getPosition()).Length() < this.getRadius() * 1.01f + caller.getRadius());
}

CButton@ MakeTravelButton(CBlob@ this, CBlob@ caller, Vec2f buttonPos, const string &in label, const string &in cantTravelLabel)
{
	CBlob@[] portals;
	const bool gotPortals = getPortals(this, @portals);
	const bool travelAvailable = gotPortals && isInRadius(this, caller);
	if (!travelAvailable)
		return null;
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	CButton@ button = caller.CreateGenericButton(8, buttonPos, this, this.getCommandID("travel"), gotPortals ? label : cantTravelLabel, params);
	if (button !is null)
	{
		button.SetEnabled(travelAvailable);
	}
	return button;
}

bool doesFitAtPortal(CBlob@ this, CBlob@ caller, CBlob@ portal)
{
	return true;
}

void Travel(CBlob@ this, CBlob@ caller, CBlob@ portal)
{
	if (caller !is null && portal !is null)
	{
		if (caller.isAttached())   // attached - like sitting in cata? move whole cata
		{
			const int count = caller.getAttachmentPointCount();
			for (int i = 0; i < count; i++)
			{
				AttachmentPoint @ap = caller.getAttachmentPoint(i);
				CBlob@ occBlob = ap.getOccupied();
				if (occBlob !is null)
				{
					occBlob.setPosition(portal.getPosition());
					occBlob.setVelocity(Vec2f_zero);
					occBlob.getShape().PutOnGround();
				}
			}
		}
		// move caller

		//FUN mod
		ParticleZombieLightning( this.getPosition() ); 
		ParticleZombieLightning( portal.getPosition() ); 
		//
		
		caller.setPosition( portal.getPosition() );
		caller.setVelocity( Vec2f_zero );			  
		caller.getShape().PutOnGround();

		if (portal.hasTag("corrupted"))
		{
			caller.AddScript( "RunnerCorruption.as" );
			caller.getSprite().AddScript( "RunnerCorruption.as" );			
		}

		if (caller.isMyPlayer())
		{
			Sound::Play( "Thunder1.ogg" );
		}
		else
		{
			Sound::Play( "Thunder1.ogg", this.getPosition() );
			Sound::Play( "Thunder1.ogg", caller.getPosition() );
		}
	}
}

void onPortalCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("travel"))
	{
		const u16 callerID = params.read_u16();
		CBlob@ caller = getBlobByNetworkID(callerID);

		CBlob@[] portals;
		if (caller !is null && getPortals(this, @portals))
		{
			// instant travel cause there is just one place to go
			if (portals.length == 1)
			{
				Travel(this, caller, portals[0]);
			}
			else
			{
				if (caller.isMyPlayer())
					BuildPortalsMenu(this, callerID);
			}
		}
	}
	else if (cmd == this.getCommandID("travel to"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		CBlob@ portal = getBlobByNetworkID(params.read_u16());
		if (caller !is null && portal !is null
		        && (this.getPosition() - caller.getPosition()).getLength() < (this.getRadius() + caller.getRadius()) * 2.0f &&
		        doesFitAtPortal(this, caller, portal))
		{
			if (getNet().isServer())
			{
				CBitStream params;
				params.write_u16(caller.getNetworkID());
				params.write_u16(portal.getNetworkID());
				this.SendCommand(this.getCommandID("server travel to"), params);
			}
		}
		else if (caller !is null && caller.isMyPlayer())
			Sound::Play("NoAmmo.ogg");
	}
	else if (cmd == this.getCommandID("server travel to"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		CBlob@ portal = getBlobByNetworkID(params.read_u16());
		Travel(this, caller, portal);
	}
	else if (cmd == this.getCommandID("travel none"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if (caller !is null && caller.isMyPlayer())
			getHUD().ClearMenus();
	}
}

const int BUTTON_SIZE = 2;

void BuildPortalsMenu(CBlob@ this, const u16 callerID)
{
	CBlob@[] portals;
	getPortalsForButtons(this, @portals);

	CGridMenu@ menu = CreateGridMenu(getDriver().getScreenCenterPos() + Vec2f(0.0f, 0.0f), this, Vec2f((portals.length) * BUTTON_SIZE, BUTTON_SIZE), "Pick portal to travel");
	if (menu !is null)
	{
		CBitStream exitParams;
		exitParams.write_netid(callerID);
		menu.AddKeyCommand(KEY_ESCAPE, this.getCommandID("travel none"), exitParams);
		menu.SetDefaultCommand(this.getCommandID("travel none"), exitParams);

		for (uint i = 0; i < portals.length; i++)
		{
			CBlob@ portal = portals[i];
			if (portal is null)
			{
				menu.AddButton("$CANCEL$", "You are here", Vec2f(BUTTON_SIZE, BUTTON_SIZE));
			}
			else
			{
				CBitStream params;
				params.write_u16(callerID);
				params.write_u16(portal.getNetworkID());
				menu.AddButton(getTravelIcon(this, portal), getTravelDescription(this, portal), this.getCommandID("travel to"), Vec2f(BUTTON_SIZE, BUTTON_SIZE), params);
			}
		}
	}
}

string getTravelIcon(CBlob@ this, CBlob@ portal)
{
	if (portal.getName() == "war_base")
		return "$WAR_BASE$";

	if (portal.getPosition().x > this.getPosition().x)
		return "$TRAVEL_RIGHT$";

	return "$TRAVEL_LEFT$";
}

string getTravelDescription(CBlob@ this, CBlob@ portal)
{
	if (portal.getName() == "war_base")
		return "Return to base";

	if (portal.getPosition().x > this.getPosition().x)
		return "Travel right";

	return "Travel left";
}