

void ControlElements(float power, Vec2f pos, bool fire, bool water, bool gold, bool evil, bool blood, bool sap, bool life, bool death, bool air, bool stone, bool legendary){
	CBlob@[] blobsInRadius;
	if (getMap().getBlobsInRadius(pos, 64.0f, @blobsInRadius)) 
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];
			
			float Size = (b.get_s16("size")*1.0f)/1000.0f;
			
			if(((b.getName() == "gold_blob" || b.hasTag("gold_element")) && (gold || air))
			|| ((b.getName() == "evil_blob" || b.hasTag("evil_element")) && (evil || air))
			|| ((b.getName() == "blood_blob" || b.hasTag("blood_element")) && (blood || air))
			|| ((b.getName() == "plant_blob" || b.hasTag("plant_element")) && (sap || air))
			|| ((b.getName() == "slime_blob" || b.hasTag("slime_element")) && (sap || air))
			|| ((b.getName() == "death_blob" || b.hasTag("death_element")) && (death || air))){
				Vec2f dir = pos-b.getPosition();
				dir.Normalize();
				b.setVelocity((dir*(1.5f-Size)+b.getVelocity()/4.0f)*power+(b.getVelocity()*(1.0f-power)));
				b.set_u8("moldable", 2);
			}
			
			if(((b.getName() == "water_blob" || b.hasTag("water_element")) && (water || air))
			|| ((b.getName() == "life_blob" || b.hasTag("life_element")) && (life || air))){
				Vec2f dir = pos-b.getPosition();
				dir.Normalize();
				b.setVelocity((dir*(1.0f-Size)+b.getVelocity()/2.0f)*power+(b.getVelocity()*(1.0f-power)));
				b.set_u8("moldable", 2);
			}
			
			if(((b.getName() == "fire_blob" || b.hasTag("fire_element")) && (fire || air))){
				Vec2f dir = pos-b.getPosition();
				dir.Normalize();
				b.setVelocity((dir*(1.5f-Size)+b.getVelocity()/2.0f)*power+(b.getVelocity()*(1.0f-power)));
				b.set_u8("moldable", 2);
			}
			
			if(gold){
				if(b.getName() == "mat_gold" && !b.hasTag("drained"))if(getNet().isServer()){
					CBlob @blob = server_CreateBlob("gold_blob", b.getTeamNum(), b.getPosition());
					blob.set_u8("moldable", 2);
					blob.set_s16("size", b.getQuantity());
					blob.setVelocity(b.getVelocity());
					b.Tag("drained");
					b.server_Die();
				}
			}
			
			if(death){
				if(b.getName() == "ectoplasm" && !b.hasTag("drained"))if(getNet().isServer()){
					CBlob @blob = server_CreateBlob("death_blob", b.getTeamNum(), b.getPosition());
					blob.set_u8("moldable", 2);
					blob.set_s16("size", b.getQuantity());
					blob.setVelocity(b.getVelocity());
					b.Tag("drained");
					b.server_Die();
				}
				if(XORRandom(100) == 0)
				if(b.hasTag("ghost"))if(b.get_s16("death") > 0)if(getNet().isServer()){
					CBlob @blob = server_CreateBlob("death_blob", b.getTeamNum(), b.getPosition());
					blob.set_u8("moldable", 2);
					blob.set_s16("size", 1);
					blob.setVelocity(b.getVelocity());
					b.set_s16("death",b.get_s16("death")-1);
					b.Sync("death",true);
					if(b.getName() == "ghost")b.server_SetTimeToDie(b.getTimeToDie()*1.09);
				}
			}
			
			if(water){
				if(b.getName() == "bucket")if(b.get_u8("filled") > 0){
					if(getNet().isServer()){
						CBlob @blob = server_CreateBlob("water_blob", b.getTeamNum(), b.getPosition());
						blob.set_u8("moldable", 2);
						blob.set_s16("size", b.get_u8("filled")*5);
					}
					b.set_u8("filled", 0);
				}
			}
			
			if(blood){
				if(b.getName() == "heart" && !b.hasTag("drained"))if(getNet().isServer()){
					CBlob @blob = server_CreateBlob("blood_blob", b.getTeamNum(), b.getPosition());
					blob.set_u8("moldable", 2);
					blob.set_s16("size", 10);
					blob.setVelocity(b.getVelocity());
					b.Tag("drained");
					b.server_Die();
				}
			}
			
			if(sap){
				if(b.getName() == "log" || b.getName() == "flowers" || b.getName() == "grain" || b.getName() == "grain_plant" || b.getName() == "bush" && !b.hasTag("drained"))if(getNet().isServer()){
					CBlob @blob = server_CreateBlob("plant_blob", b.getTeamNum(), b.getPosition());
					blob.set_u8("moldable", 2);
					blob.set_s16("size", 10);
					blob.setVelocity(b.getVelocity());
					b.Tag("drained");
					b.server_Die();
				}
				if(b.getName() == "slime" && !b.hasTag("drained"))if(getNet().isServer()){
					CBlob @blob = server_CreateBlob("slime_blob", b.getTeamNum(), b.getPosition());
					blob.set_u8("moldable", 2);
					blob.setVelocity(b.getVelocity());
					if(b.hasTag("baby"))blob.set_s16("size", 50);
					else blob.set_s16("size", 100);
					b.Tag("drained");
					b.server_Die();
				}
			}
			
			if(life){
				if(b.getName() == "wisp" && !b.hasTag("drained"))if(getNet().isServer()){
					CBlob @blob = server_CreateBlob("life_blob", b.getTeamNum(), b.getPosition());
					blob.set_u8("moldable", 2);
					blob.set_s16("size", 10);
					blob.setVelocity(b.getVelocity());
					b.Tag("drained");
					b.server_Die();
				}
				if(b.getName() == "derangedwisp" && !b.hasTag("drained"))if(getNet().isServer()){
					CBlob @blob = server_CreateBlob("life_blob", b.getTeamNum(), b.getPosition());
					blob.set_u8("moldable", 2);
					blob.set_s16("size", 1);
					blob.setVelocity(b.getVelocity());
					b.Tag("drained");
					b.server_Die();
				}
			}
			
			if(fire){
				if(b.getName() == "lantern")if(b.isLight()){
					if(getNet().isServer()){
						CBlob @blob = server_CreateBlob("fire_blob", b.getTeamNum(), b.getPosition());
						blob.set_u8("moldable", 2);
						blob.set_s16("size", 10);
						blob.setVelocity(b.getVelocity());
					}
					b.SetLight(false);
					b.getSprite().SetAnimation("nofire");
				}
				if(b.getName() == "fireball" && !b.hasTag("drained"))if(getNet().isServer()){
					CBlob @blob = server_CreateBlob("fire_blob", b.getTeamNum(), b.getPosition());
					blob.set_u8("moldable", 2);
					blob.set_s16("size", 5);
					blob.setVelocity(b.getVelocity());
					b.Tag("drained");
					b.server_Die();
				}
			}
			
			if(evil){
				if(XORRandom(10) == 0)
				if(b.hasTag("player"))if(b.get_s16("corruption") >= 1)if(getNet().isServer()){
					CBlob @blob = server_CreateBlob("evil_blob", b.getTeamNum(), b.getPosition());
					blob.set_u8("moldable", 2);
					blob.set_s16("size", 1);
					blob.setVelocity(b.getVelocity());
					b.set_s16("corruption",b.get_s16("corruption")-1);
					b.Sync("corruption",true);
				}
				if(b.getName() == "corruption_orb")if(getNet().isServer()){
					CBlob @blob = server_CreateBlob("evil_blob", b.getTeamNum(), b.getPosition());
					blob.set_u8("moldable", 2);
					blob.set_s16("size", 100);
					blob.setVelocity(b.getVelocity());
					b.server_Die();
				}
			}
		}
	}
	
	if(water)
	if(getMap().isInWater(pos)){
		if(getNet().isServer()){
			CBlob @blob = server_CreateBlob("water_blob", -1, pos);
			blob.set_u8("moldable", 2);
			blob.set_s16("size", 2);
			getMap().server_setFloodWaterWorldspace(pos, false);
		}
	}
}