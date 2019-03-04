
#include "AbilityCommon.as"
#include "eleven.as"
#include "HumanoidCommon.as"
#include "copy.as"
#include "RelationshipsCommon.as"

void life_link(CBlob @ this){
	if(getNet().isServer()){
		if(this.hasTag("life_linked")){
			this.Untag("life_linked");
			this.set_u16("life_link_partner",0);
		} else {
			CControls @control = this.getControls();
			
			CBlob@[] blobsInRadius;	   
			//if(control !is null)
			if (this.getMap().getBlobsInRadius(this.getAimPos(), 16.0f, @blobsInRadius)) 
			{
				for (uint i = 0; i < blobsInRadius.length; i++)
				{
					CBlob@ b = blobsInRadius[i];
					
					if(b !is null && b !is this && (b.exists("life_amount") || b.exists("death_amount"))){
						this.Tag("life_linked");
						b.Tag("life_linked");
						this.set_u16("life_link_partner",b.getNetworkID());
						b.set_u16("life_link_partner",this.getNetworkID());

						b.Sync("life_linked",true);
						b.Sync("life_link_partner",true);
					}
				}
			}
		}
		this.Sync("life_linked",true);
		this.Sync("life_link_partner",true);
	}
}
string life_link_icon(CBlob @ this){
	return "LifeLink.png";
}

void life_flow(CBlob @ this){
	if(CheckCooldown(this,"flow_cd") == 0){
		
		int state = this.get_u8("life_flow_state")+1;
		if(state == 4)state = 0;
		this.set_u8("life_flow_state",state);
		
		StartCooldown(this,"flow_cd",8);
	}
}
string life_flow_icon(CBlob @ this){
	int state = this.get_u8("life_flow_state");
	if(state == 1)return "LifeDrain.png";
	if(state == 3)return "LifeFill.png";
	return "LifeFlow.png";
}

void form_wisp(CBlob @ this){
	if(CheckCooldown(this,"morph_cd") == 0){
		
		if(getNet().isServer())
		if(this.getName() != "w"){
			CBlob @w = server_CreateBlob("w",this.getTeamNum(),this.getPosition());
			
			w.set_s16("life_amount",this.get_s16("life_amount")-1);
			this.set_s16("life_amount",1);
			
			copy(this,w,false, false, true ,true, false, false, false, false );
		}
		
		StartCooldown(this,"morph_cd",30);
	}
}
string form_wisp_icon(CBlob @ this){
	return "FormWisp.png";
}

void life_kiss(CBlob @ this){
	life_kiss(this,this.getPosition());
}

void life_kiss(CBlob @ this, Vec2f pos){
	if(this.get_s16("life_amount") > 1)
	if(CheckCooldown(this,"kiss_cd") == 0){
		if(getNet().isServer()){
			CBlob @w = server_CreateBlob("wmo",this.getTeamNum(),pos);
		}
		this.sub_s16("life_amount",1);
		
		StartCooldown(this,"kiss_cd",15);
	}
}
string life_kiss_icon(CBlob @ this){
	return "LifeKiss.png";
}

void summon_wisp(CBlob @ this){
	if(this.get_s16("life_amount") > 50)
	if(CheckCooldown(this,"wisp_cd") == 0){
		
		if(getNet().isServer()){
			CBlob @w = server_CreateBlob("w",this.getTeamNum(),this.getPosition());
			if(w !is null){
				addLoveThing(w,this.getName());
				setRelationship(w,this,50);
			}
		}
		
		this.sub_s16("life_amount",50);
		
		StartCooldown(this,"wisp_cd",30*5);
	}
}
string summon_wisp_icon(CBlob @ this){
	return "SummonWisp.png";
}

void life_infuse(CBlob @this){
	if(this.get_s16("life_amount") > 10)
	if(CheckCooldown(this,"transfuse_cd") == 0){
		
		CBlob @item = this.getCarriedBlob();

		if(item !is null){
			item.Tag("life_infused");
			
			if(!item.exists("life_amount"))item.AddScript("f.as");
			item.add_s16("life_amount",10);
			
			this.sub_s16("life_amount",10);
			if(getNet().isServer())this.Sync("life_amount", true);
			
			StartCooldown(this,"transfuse_cd",30*5);
		}
	}

}
string life_infuse_icon(CBlob @this){
	return "LifeInfuse.png";
}

void soul_infuse(CBlob @this){
	if(CheckCooldown(this,"transfuse_cd") == 0){
		
		CBlob @target = null;
		CBlob @item = this.getCarriedBlob();

		//if(item !is null && !item.hasTag("soul") && item.getPlayer() is null){
		//	@target = item;
		//} else {
		
			CBlob @partner = getBlobByNetworkID(this.get_u16("life_link_partner"));
			if(partner !is null && !partner.hasTag("soul") && partner.getPlayer() is null){
				@target = partner;
			}
		
		//}
		
		if(target !is null)
		if(this.get_s16("life_amount") >= target.get_s16("life_amount")){
		
			target.add_s16("life_amount",this.get_s16("life_amount")-1);
			this.set_s16("life_amount",1);
			
			target.AddScript("LifeTak.as");
			target.AddScript("ltqt.as");
			target.AddScript("PlayerAble.as");
			
			
			if(getNet().isServer()){
				this.Sync("life_amount", true);
				target.Sync("life_amount", true);
				
				target.server_SetTimeToDie(0);
			}
			
			copy(this,target,false, false, true ,true, false, false, false, false );
			
			StartCooldown(target,"transfuse_cd",30*5);
			StartCooldown(this,"transfuse_cd",30*5);
		}
	}

}
string soul_infuse_icon(CBlob @this){
	return "SoulInfuse.png";
}




void life_burst(CBlob @ this){
	if(this.get_s16("life_amount") > 5)
	if(CheckCooldown(this,"burst_cd") == 0){
		
		CControls @control = this.getControls();
		
		if(getNet().isServer()){
			CBlob @w = server_CreateBlob("woo",this.getTeamNum(),this.getPosition()+Vec2f(0,-8));
			if(w !is null){
				Vec2f vec = this.getAimPos()-this.getPosition();
				//if(control !is null)vec = control.getMouseWorldPos()-this.getPosition();
				vec.Normalize();
				w.setVelocity(vec*1.0f);
				
				w.Tag("burst");
				w.Sync("burst",true);
			}
		}
		
		this.sub_s16("life_amount",5);
		
		StartCooldown(this,"burst_cd",5);
	}
}
string life_burst_icon(CBlob @ this){
	return "LifeBurst.png";
}

void life_force_orb(CBlob @ this){
	if(this.get_s16("life_amount") > 1)
	if(CheckCooldown(this,"force_cd") == 0){
		
		CControls @control = this.getControls();
		
		if(getNet().isServer()){
			CBlob @w = server_CreateBlob("wooo",this.getTeamNum(),this.getPosition()+Vec2f(0,-16));
			if(w !is null){
				Vec2f vec = this.getAimPos()-this.getPosition();
				//if(control !is null)vec = control.getMouseWorldPos()-this.getPosition();
				vec.Normalize();
				w.setVelocity(vec*0.5f);
				
				w.Tag("push");
				w.Sync("push",true);
			}
		}
		
		this.sub_s16("life_amount",1);
		
		StartCooldown(this,"force_cd",5);
	}
}
string life_force_orb_icon(CBlob @ this){
	return "LifeForceOrb.png";
}


void life_falter(CBlob @ this){
	if(this.get_s16("life_amount") > 2)
	if(CheckCooldown(this,"falter_cd") == 0){
		
		CBlob@[] orbs;
		getBlobsByName("wo", @orbs);
		getBlobsByName("woo", @orbs);
		getBlobsByName("wooo", @orbs);
		getBlobsByName("woooo", @orbs);
		
		for(int j = 0; j < orbs.length; j++)
		{
			CBlob @orb = orbs[j];
			if(orb !is null && orb.getTeamNum() == this.getTeamNum() && !orb.hasTag("spawn")){
				orb.setVelocity(orb.getVelocity()*-1.0f);
				orb.set_u16("created",getGameTime());
			}
		}
		
		if(getNet().isServer()){
			Vec2f angle = Vec2f(-1,0);
			for(int i = 0; i < 8; i++){
			
				angle.RotateBy(22.5f);
				CBlob @w = server_CreateBlob("wo",this.getTeamNum(),this.getPosition());
				if(w !is null){
					w.setVelocity(angle);
				}
			
			}
		}
		
		this.sub_s16("life_amount",2);
		
		StartCooldown(this,"falter_cd",30);
	}
}
string life_falter_icon(CBlob @ this){
	return "LifeFalter.png";
}

void life_globe(CBlob @ this){
	if(this.get_s16("life_amount") > 5)
	if(CheckCooldown(this,"globe_cd") == 0){
		
		CControls @control = this.getControls();
		
		if(getNet().isServer()){
			CBlob @w = server_CreateBlob("woooo",this.getTeamNum(),this.getPosition()+Vec2f(0,-32));
			if(w !is null){
				Vec2f vec = this.getAimPos()-this.getPosition();
				//if(control !is null)vec = control.getMouseWorldPos()-this.getPosition();
				vec.Normalize();
				w.setVelocity(vec*0.5f);
			}
		}
		
		this.sub_s16("life_amount",5);
		
		StartCooldown(this,"globe_cd",30);
	}
}
string life_globe_icon(CBlob @ this){
	return "LifeGlobe.png";
}


void life_parting(CBlob @ this){
	if(this.get_s16("life_amount") > 20)
	if(CheckCooldown(this,"parting_cd") == 0){
		
		if(getNet().isServer()){
			
			{CBlob @w = server_CreateBlob("wooo",this.getTeamNum(),this.getPosition()+Vec2f(0,-16));
			if(w !is null){
				w.setVelocity(Vec2f(0,-2.0f));
			}}
			
			CBlob@[] orbs;
			getBlobsByName("woo", @orbs);
			getBlobsByName("wooo", @orbs);
			getBlobsByName("woooo", @orbs);
			
			for(int j = 0; j < orbs.length; j++)
			{
				CBlob @orb = orbs[j];
				if(orb !is null && orb.getTeamNum() == this.getTeamNum()){
					Vec2f Ang1 = orb.getVelocity();
					Ang1.RotateBy(20.0f);
					Vec2f Ang2 = orb.getVelocity();
					Ang2.RotateBy(-20.0f);
					
					if(orb.getName() == "woooo"){
						Vec2f angle = Vec2f(0.5f,0);
						for(int i = 0; i < 8; i++){
						
							angle.RotateBy(45.0f);
							CBlob @w = server_CreateBlob("wooo",orb.getTeamNum(),orb.getPosition());
							if(w !is null){
								w.setVelocity(angle);
							}
						
						}
					} else {
						string name = "wo";
						if(orb.getName() == "wooo")name = "woo";
						
						CBlob @w = server_CreateBlob(name,orb.getTeamNum(),orb.getPosition());
						if(w !is null)w.setVelocity(Ang1);
						CBlob @w2 = server_CreateBlob(name,orb.getTeamNum(),orb.getPosition());
						if(w2 !is null)w2.setVelocity(Ang2);
					}
					
					orb.server_Die();
				}
			}
		}
		
		this.sub_s16("life_amount",20);
		
		StartCooldown(this,"parting_cd",30);
	}
}
string life_parting_icon(CBlob @ this){
	return "LifeParting.png";
}

void life_cage(CBlob @ this){
	life_cage(this, this.getPosition()+Vec2f(0,-32));
}
void life_cage(CBlob @ this, Vec2f pos){
	if(this.get_s16("life_amount") > 50)
	if(CheckCooldown(this,"cage_cd") == 0){
		
		if(getNet().isServer()){
			
			{CBlob @w = server_CreateBlob("wooo",this.getTeamNum(),pos);
			if(w !is null){
				w.setVelocity(Vec2f(1.0f,0));
				w.Tag("spawn");
				w.set_u16("created",getGameTime());
			}}
			
			{CBlob @w = server_CreateBlob("wooo",this.getTeamNum(),pos);
			if(w !is null){
				w.setVelocity(Vec2f(-1.0f,0));
				w.Tag("spawn");
				w.set_u16("created",getGameTime());
			}}

		}
		
		this.sub_s16("life_amount",50);
		
		StartCooldown(this,"cage_cd",30*15);
	}
}
string life_cage_icon(CBlob @ this){
	return "LifeCage.png";
}