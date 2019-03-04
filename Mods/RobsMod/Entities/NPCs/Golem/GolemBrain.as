//brain

#define SERVER_ONLY

#include "BrainCommon.as"
#include "PressOldKeys.as";
#include "AnimalConsts.as";

void onInit( CBrain@ this )
{
	CBlob @blob = this.getBlob();
	blob.set_u8( delay_property , 5+XORRandom(5));
	blob.set_u8(state_property, MODE_IDLE);

	if (!blob.exists(terr_rad_property)) 
	{
		blob.set_f32(terr_rad_property, 32.0f);
	}

	if (!blob.exists(target_searchrad_property))
	{
		blob.set_f32(target_searchrad_property, 32.0f);
	}

	if (!blob.exists(target_lose_random))
	{
		blob.set_u8(target_lose_random,14);
	}

	if (!blob.exists("random move freq"))
	{
		blob.set_u8("random move freq",2);
	}	

	if (!blob.exists("target dist"))
	{
		blob.set_u32("target dist",0);
	}	
	
//	this.getCurrentScript().removeIfTag	= "dead";   
//	this.getCurrentScript().runFlags |= Script::tick_blob_in_proximity;
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
//	this.getCurrentScript().runProximityTag = "player";
//	this.getCurrentScript().runProximityRadius = 200.0f;
	//this.getCurrentScript().tickFrequency = 5;

	Vec2f terpos = blob.getPosition();
	terpos += blob.getRadius();
	blob.set_Vec2f(terr_pos_property, terpos);
}


void onTick( CBrain@ this )
{
	CBlob @blob = this.getBlob();
	u8 delay = blob.get_u8(delay_property);
	delay--;
	
	if (delay == 0)
	{
	
		if(1 == 1){
			CBlob@ target = getBlobByNetworkID(blob.get_netid(target_property));							  
			if(target != null)
			if((target.getPosition() - blob.getPosition()).getLength() > 96 || target.hasTag("dead")){
				blob.set_u8(state_property, MODE_IDLE);
				blob.Sync(state_property,true);
			}
		}
		
		const CBrain::BrainState state = this.getState();
		if (blob.get_u8(state_property) == MODE_TARGET)
		{
			CBlob@ target = getBlobByNetworkID(blob.get_netid(target_property));
			
			if (target is null)
			{
				blob.set_u8(state_property,MODE_IDLE);
			}
			if (state == CBrain::has_path) {
				this.SetSuggestedKeys();  // set walk keys here
				JumpOverObstacles( blob );
				delay = 4+XORRandom(4);
				blob.set_u8(delay_property, delay);
				return;
			}
			else
			{
				if (target !is null) JustGo( blob, target );
				JumpOverObstacles( blob );
				delay = 4+XORRandom(4);
				blob.set_u8(delay_property, delay);
				return;
			}
			
			const CBrain::BrainState state = this.getState();
			switch (state)
			{
			case CBrain::idle:
				Repath( this );
				break;

			case CBrain::searching:
				blob.set_u8(state_property,MODE_IDLE);
				break;

			case CBrain::stuck:
				Repath( this );
				break;

			case CBrain::wrong_path:
				Repath( this );
				break;
			}	  
			
		}
		delay = 4+XORRandom(4);
		Vec2f pos = blob.getPosition();
		
		CMap@ map = blob.getMap();
		bool facing_left = blob.isFacingLeft();
		JumpOverObstacles(blob);
		u8 mode = blob.get_u8(state_property);
	
		//printf("mode " + mode);
		
		//"blind" attacking
		if (mode == MODE_TARGET)
		{
			CBlob@ target = getBlobByNetworkID(blob.get_netid(target_property));
			
			if (target is null || target.getTeamNum() == blob.getTeamNum() || blob.hasAttached() || XORRandom( blob.get_u8(target_lose_random) ) == 0 || target.isInInventory() )
			{
				mode = MODE_IDLE;
			}
		}
		else //mode == idle
		{
			
			u8 randomMoveFrequency = blob.get_u8("random move freq");
			if (XORRandom(randomMoveFrequency) == 0 || blob.isOnWall())
			{
			//blob.wasKeyPressed(key_right)
				bool dir = XORRandom(8)>=4;
				bool idling = XORRandom(8)>=6;
				blob.setKeyPressed(dir ? key_left : key_right, true);
				blob.set_u8("idling",idling?1:0);
				blob.set_u8("left",dir?1:0);
				
			} else
			{
				u8 idling=blob.get_u8("idling");
				if (idling==0)
				{
				u8 dir=blob.get_u8("left");
				blob.setKeyPressed(dir==1 ? key_left : key_right, true);
				}
			}
		}
		
		CBlob@[] blobs;
		blob.getMap().getBlobsInRadius( pos, 96.0, @blobs );
		f32 best_dist=99999999;
		for (uint step = 0; step < blobs.length; ++step)
		{
			//TODO: sort on proximity? done by engine?
			CBlob@ other = blobs[step];

			if (other is blob) continue; //lets not run away from / try to eat ourselves...
			if (other.getTeamNum() != blob.getTeamNum() && other.hasTag("flesh") && !other.hasTag("dead")) //attack flesh blobs
			{
				Vec2f tpos = other.getPosition();									  
				f32 dist = (tpos - pos).getLength();
				if (dist < best_dist)
				{
					if (isVisible(blob,other))
					{
						mode = MODE_TARGET;
						blob.set_netid(target_property,other.getNetworkID());
						blob.Sync(target_property,true);
						best_dist=dist;
						this.SetPathTo(tpos, false);
						//break;
					}
				}
			}
		}

		blob.set_u8(state_property, mode);
		blob.Sync(state_property,true);

	}
	else
	{
		PressOldKeys( blob );
	}

	blob.set_u8(delay_property, delay);
}
