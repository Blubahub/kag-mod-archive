// Simple chat processing example.
// If the player sends a command, the server does what the command says.
// You can also modify the chat message before it is sent to clients by modifying text_out

#include "MakeSeed.as";
#include "MakeCrate.as";
#include "MakeScroll.as";
#include "HumanoidCommon.as";
#include "EquipCommon.as";
#include "Hitters.as";

bool onServerProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	if (player is null)
		return true;

	if (sv_test && player.isMod())
	if (text_in == "!life")
	{
		this.add_u8(player.getUsername()+"_lives",1);
		
		CBitStream params;
		params.write_u16(player.getNetworkID());
		params.write_u8(this.get_u8(player.getUsername()+"_lives"));
		this.SendCommand(this.getCommandID("sync_life"), params);
		
		return false;
	}
	
		
	CBlob@ blob = player.getBlob();

	if (blob is null)
	{
		return true;
	}

	//commands that don't rely on sv_test

	if (text_in == "!bot" && player.isMod()) // TODO: whoaaa check seclevs
	{
		CPlayer@ bot = AddBot("Henry");
		return true;
	}
	else if (text_in == "!debug" && player.isMod())
	{
		// print all blobs
		CBlob@[] all;
		getBlobs(@all);

		for (u32 i = 0; i < all.length; i++)
		{
			CBlob@ blob = all[i];
			print("[" + blob.getName() + " " + blob.getNetworkID() + "] ");
		}
	}

	//spawning things

	//these all require sv_test - no spawning without it
	//some also require the player to have mod status
	if (sv_test && player.isMod())
	{
		Vec2f pos = blob.getPosition();
		int team = blob.getTeamNum();

		if (text_in == "!fire")
		{
			CBlob@[] blobsInRadius;
			if (getMap().getBlobsInRadius(blob.getPosition(), 32.0f, @blobsInRadius)) 
			{
				for (uint i = 0; i < blobsInRadius.length; i++)
				{
					CBlob@ b = blobsInRadius[i];
					
					if(b !is null && b !is blob){

						blob.server_Hit(b, b.getPosition(), Vec2f(0,0), 1.0f, Hitters::fire, true);
					}
				}
			}
		}
		else 
		if (text_in == "!killme")
		{
			blob.server_Die();
		}
		else 
		if (text_in == "!minimap")
		{
			getMap().MakeMiniMap();
			return false;
		} else
		if (text_in == "!tree")
		{
			server_MakeSeed(pos, "tree_pine", 600, 1, 16);
		} else
		if (text_in == "!testmap")
		{
			LoadMap("TestMap.png");
		}
		else if (text_in == "!btree")
		{
			server_MakeSeed(pos, "tree_bushy", 400, 2, 16);
		}
		else if (text_in == "!stones")
		{
			CBlob@ b = server_CreateBlob('mat_stone', -1, pos);
		}
		else if (text_in == "!arrows")
		{
			for (int i = 0; i < 3; i++)
			{
				CBlob@ b = server_CreateBlob('mat_arrows', -1, pos);
			}
		}
		else if (text_in == "!bombs")
		{
			for (int i = 0; i < 3; i++)
			{
				CBlob@ b = server_CreateBlob('mat_bombs', -1, pos);
			}
		}
		else if (text_in == "!spawnwater" && player.isMod())
		{
			getMap().server_setFloodWaterWorldspace(pos, true);
		}
		else if (text_in == "!crate")
		{
			client_AddToChat("usage: !crate BLOBNAME [DESCRIPTION]", SColor(255, 255, 0, 0));
			server_MakeCrate("", "", 0, team, Vec2f(pos.x, pos.y - 30.0f));
		}
		else if (text_in == "!coins")
		{
			player.server_setCoins(player.getCoins() + 100);
		}
		else if (text_in == "!bloodaddict" || text_in == "!blood_addict")
		{
			blob.set_u8("blood_addiction",5);
			blob.Sync("blood_addiction",true);
		}
		else if (text_in == "!ectoplasm")
		{
			blob.set_s16("death_amount", 500);
			blob.Sync("death_amount",true);
		}
		else if (text_in == "!life_force" || text_in == "!lifeforce")
		{
			blob.set_s16("life_amount", 1000);
			blob.Sync("life_amount",true);
		}
		else if (text_in == "!bloodwell")
		{
			blob.add_s16("blood_amount", 500);
			blob.Sync("blood_amount",true);
		}
		else if (text_in == "!blind")
		{
			blob.set_u8("eyes", 0);
			blob.Sync("eyes",true);
		}
		else if (text_in == "!light_eye" || text_in == "!lighteye")
		{
			if(blob.get_u8("eyes") > 0){
				blob.set_u8("eyes", blob.get_u8("eyes")-1);
				blob.Sync("eyes",true);
				blob.set_u8("light_eyes", blob.get_u8("light_eyes")+1);
				blob.Sync("light_eyes",true);
			}
		}
		else if (text_in == "!sight")
		{
			blob.set_u8("eyes", 2);
			blob.Sync("eyes",true);
			blob.set_u8("burnt_eyes", 0);
			blob.Sync("burnt_eyes",true);
		}
		else if (text_in == "!burn_eye" || text_in == "!burneye")
		{
			if(blob.get_u8("eyes") > 0){
				blob.set_u8("eyes", blob.get_u8("eyes")-1);
				blob.Sync("eyes",true);
				blob.set_u8("burnt_eyes", blob.get_u8("burnt_eyes")+1);
				blob.Sync("burnt_eyes",true);
			}
		}
		else if (text_in == "!infused_gold")
		{
			CBlob @gold = server_CreateBlob("gold_bar", team, pos);
			gold.Tag("light_infused");
		}
		else if (text_in == "!priest")
		{
			blob.Tag("light_ability");
			blob.set_s16("light_amount", 500);
			blob.Sync("light_ability", true);
			blob.Sync("light_amount", true);
		}
		else if (text_in == "!corrupt")
		{
			blob.set_s16("dark_amount", 1000);
			blob.Sync("dark_amount", true);
		}
		else if (text_in == "!engineer")
		{
			CBlob @barrel = server_CreateBlob("barrel",-1,blob.getPosition());
			equipItem(blob, barrel, "back");
			
			for(int i = 0;i < 10;i++)barrel.server_PutInInventory(server_CreateBlob("metal_bar",-1,blob.getPosition()));
			for(int i = 0;i < 10;i++)barrel.server_PutInInventory(server_CreateBlob("lecit_bar",-1,blob.getPosition()));
			for(int i = 0;i < 4;i++)barrel.server_PutInInventory(server_CreateBlob("mat_machine_parts",-1,blob.getPosition()));
			for(int i = 0;i < 10;i++)barrel.server_PutInInventory(server_CreateBlob("duram_bar",-1,blob.getPosition()));
			for(int i = 0;i < 2;i++)barrel.server_PutInInventory(server_CreateBlob("mat_wood",-1,blob.getPosition()));
			for(int i = 0;i < 2;i++)barrel.server_PutInInventory(server_CreateBlob("mat_stone",-1,blob.getPosition()));
		}
		else if (text_in == "!gunsman" || text_in == "!gunslinger")
		{
			CBlob @barrel = server_CreateBlob("backpack",-1,blob.getPosition());
			equipItem(blob, barrel, "back");
			
			barrel.server_PutInInventory(server_CreateBlob("revolver",-1,blob.getPosition()));
			barrel.server_PutInInventory(server_CreateBlob("flintlock",-1,blob.getPosition()));
			for(int i = 0;i < 2;i++)barrel.server_PutInInventory(server_CreateBlob("mat_fizz",-1,blob.getPosition()));
			for(int i = 0;i < 5;i++)barrel.server_PutInInventory(server_CreateBlob("mat_bullet",-1,blob.getPosition()));
		}
		else if (text_in.substr(0, 1) == "!")
		{
			// check if we have tokens
			string[]@ tokens = text_in.split(" ");

			if (tokens.length > 1)
			{
				if (tokens[0] == "!crate")
				{
					int frame = tokens[1] == "catapult" ? 1 : 0;
					string description = tokens.length > 2 ? tokens[2] : tokens[1];
					server_MakeCrate(tokens[1], description, frame, -1, Vec2f(pos.x, pos.y));
				}
				else if (tokens[0] == "!team")
				{
					int team = parseInt(tokens[1]);
					blob.server_setTeamNum(team);
				}
				else if (tokens[0] == "!class")
				{
					string str = tokens[1];
					CBlob @create = server_CreateBlob(str, team, pos);
					if(create !is null){
						create.server_SetPlayer(player);
						create.Tag("soul");
						blob.server_Die();
						if(str == "humanoid"){
							int type = parseInt(tokens[2]);
							
							setupBody(create, type, type, type, type, type, type);
						}
					}
				}
				else if (tokens[0] == "!scroll")
				{
					string s = tokens[1];
					for (uint i = 2; i < tokens.length; i++)
						s += " " + tokens[i];
					server_MakePredefinedScroll(pos, s);
				}
				else if (tokens[0] == "!humanoid")
				{
					int type = parseInt(tokens[1]);
					CBlob @uman = server_CreateBlob("humanoid", team, pos);
					setupBody(uman, type, type, type, type, type, type);
				}
				else if (tokens[0] == "!hair")
				{
					int type = parseInt(tokens[1]);
					blob.set_u8("hair_index", type);
					blob.Sync("hair_index",true);
					if(blob.getSprite() !is null)blob.getSprite().RemoveSpriteLayer("head");
				}
				else if (tokens[0] == "!hair_colour" || tokens[0] == "!haircolour")
				{
					int type = parseInt(tokens[1]);
					blob.set_u8("hair_colour", type);
					blob.Sync("hair_colour",true);
					if(blob.getSprite() !is null)blob.getSprite().RemoveSpriteLayer("head");
				}
				else if (tokens[0] == "!seed")
				{
					server_MakeSeed(pos, tokens[1]);
				}

				return true;
			}

			// try to spawn an actor with this name !actor
			string name = text_in.substr(1, text_in.size());

			if (server_CreateBlob(name, team, pos) is null)
			{
				client_AddToChat("blob " + text_in + " not found", SColor(255, 255, 0, 0));
			}
		}
	}

	return true;
}

bool onClientProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	if (text_in == "!debug" && !getNet().isServer())
	{
		// print all blobs
		CBlob@[] all;
		getBlobs(@all);

		for (u32 i = 0; i < all.length; i++)
		{
			CBlob@ blob = all[i];
			print("[" + blob.getName() + " " + blob.getNetworkID() + "] ");

			if (blob.getShape() !is null)
			{
				CBlob@[] overlapping;
				if (blob.getOverlapping(@overlapping))
				{
					for (uint i = 0; i < overlapping.length; i++)
					{
						CBlob@ overlap = overlapping[i];
						print("       " + overlap.getName() + " " + overlap.isLadder());
					}
				}
			}
		}
	}

	return true;
}
