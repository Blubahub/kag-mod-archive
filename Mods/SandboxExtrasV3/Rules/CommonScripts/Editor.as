/* Editor.as
 * original editor author: Aphelion3371
 * slightly modified by JaytleBee
 */
 
#include "EditorConfig.as";
#include "EditorUtils.as";

#include "BuildBlock.as";

const string cmd_place = "editor place";
const string cmd_remove = "editor remove";
const string cmd_copy = "editor copy";
 
void onInit( CRules@ this )
{
    this.addCommandID(cmd_place);
    this.addCommandID(cmd_remove);
    this.addCommandID(cmd_copy);
    //this.set_u32("bs", 1); // brush size
}

void onTick( CRules@ this )
{
    if(getNet().isClient())
	{
		CPlayer@ p = getLocalPlayer();
		if      (p !is null && p.getBlob() !is null && p.getBlob().hasTag("editor"))
		{
        	if (getControls().isKeyPressed(KEY_KEY_Z))
        	{
			    CBitStream params;
	            params.write_u16(p.getNetworkID());
				
	            this.SendCommand(this.getCommandID(cmd_place), params);
        	}
			else if (getControls().isKeyPressed(KEY_KEY_X))
        	{
			    CBitStream params;
	            params.write_u16(p.getNetworkID());
				
	            this.SendCommand(this.getCommandID(cmd_remove), params);
			}
			else if (getControls().isKeyPressed(KEY_KEY_V))
			{
			    CBitStream params;
	            params.write_u16(p.getNetworkID());
				
	            this.SendCommand(this.getCommandID(cmd_copy), params);
			}

        	if (getControls().isKeyPressed(KEY_KEY_B))
        	{        		
        		CBlob@ blob = p.getBlob();
				CBlob@[] blobsInRadius;
				if (blob.getMap().getBlobsInRadius(blob.getAimPos(), 32.0f, @blobsInRadius))
				{
					for (uint i = 0; i < blobsInRadius.length; i++)
					{
						CBlob @select = blobsInRadius[i];
						if (select !is null)
						{
							select.server_Die();
							select.getBrain().server_SetActive(true);
						}


					}
				}
        	}
		}
    }
}

void onCommand( CRules@ this, u8 cmd, CBitStream@ params )
{
    if(!getNet().isServer()) return;

    if (cmd == this.getCommandID(cmd_place))
	{
	    CPlayer@ player = ResolvePlayer(params);
		
		if (MayUseEditor(player))
		{
		    CBlob@ blob = player.getBlob();
			if    (blob !is null)
			{
			    Vec2f cursorPos = blob.getAimPos();
				u32 brushsize = this.get_u32("bs_"+player.getUsername());

				u16 tile = blob.get_TileType("editor_tile");

				if(brushsize == 0) brushsize = 1;

			     getMap().server_SetTile( cursorPos, tile );
			    for(uint i = 0; i < brushsize; i++)
			    {
			    	for(uint e = 0; e < brushsize; e++)
			    	{
			    		Vec2f offset = Vec2f(e, i);
			    		offset -= Vec2f(brushsize/2.0f, brushsize/2.0f);
			    		Vec2f cursorPos2 = cursorPos + offset*8;
			   			getMap().server_SetTile( cursorPos2, tile );
			    	}
			    }
				


				
			    string editorBlob = blob.get_string( "editor_blob" );
				
				if (canPlaceBlobAtPos(cursorPos))
				{
					if(editorBlob != "")
					{
						CBlob@ blockBlob = server_CreateBlob(editorBlob, blob.getTeamNum(), cursorPos);
						if    (blockBlob !is null)
						{
							SnapToGrid(blockBlob, cursorPos);
							if (blockBlob.isSnapToGrid())
							{
								CShape@ shape = blockBlob.getShape();
								shape.SetStatic(true);
							}
						}

					}
				}
				return;
			}
		}
	}
	else if (cmd == this.getCommandID(cmd_remove))
	{
	    CPlayer@ player = ResolvePlayer(params);
		
		if (MayUseEditor(player))
		{
		    CBlob@ blob = player.getBlob();
			if    (blob !is null)
			{
			    Vec2f cursorPos = blob.getAimPos();
				
            	// destroy tile
            	getMap().server_DestroyTile( cursorPos, 10.0f );
				
            	// destroy blob
				CBlob@ behindBlob = getMap().getBlobAtPosition( cursorPos );
				if    (behindBlob !is null)
					   behindBlob.server_Die();
			}
		}
	}
	else if (cmd == this.getCommandID(cmd_copy))
	{
	    CPlayer@ player = ResolvePlayer(params);
		
		if (MayUseEditor(player))
		{
		    CBlob@ blob = player.getBlob();
			if    (blob !is null)
			{
			    ResetEditorData(blob);
				
				blob.set_TileType( "editor_tile", getMap().getTile( blob.getAimPos() ).type );
				blob.Tag("editor_menu_off");
		    }
		}
	}
}

bool onServerProcessChat( CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player )
{
	string[]@ args = text_in.split(" ");

	if ((args[0] == "!e" || args[0] == "!editor" ) && MayUseEditor(player))
	{
	    CBlob@ blob = player.getBlob();
		if    (blob !is null && args.length >= 2)
		{
		    if(args[1] == "g" || args[1] == "on")
			{
			    ResetEditorData(blob);
				
				blob.Tag("editor");
				blob.Sync("editor", true);
			}

			//set brush size
		    if(args[1] == "s")
			{
			    ResetEditorData(blob);
				u32 bs = parseInt(args[2]);
				this.set_u32("bs_"+player.getUsername(), Maths::Min(bs, 30));
			}

			else if(args[1] == "off")
			{
			    ResetEditorData(blob);
				
				blob.Untag("editor");
				blob.Sync("editor", true);
			}
			
			if(blob.hasTag("editor") && args.length >= 3)
			{
				if((args[1] == "b" || args[1] == "setblob") && MaySpawnBlobs(player))
				{
			        ResetEditorData(blob);
				    
			    	blob.set_string("editor_blob", args[2]);
					blob.Tag("editor_menu_off");
				}
				else if(args[1] == "t" || args[1] == "settile")
				{
			        ResetEditorData(blob);
					
				    if (args[2] == "ground")
						blob.set_TileType("editor_tile", CMap::tile_ground);
			    	else if (args[2] == "ground_back")
						blob.set_TileType("editor_tile", CMap::tile_ground_back);
			    	else if (args[2] == "grass")
						blob.set_TileType("editor_tile", CMap::tile_grass);
			    	else if (args[2] == "castle")
						blob.set_TileType("editor_tile", CMap::tile_castle);
			    	else if (args[2] == "castle_moss")
						blob.set_TileType("editor_tile", CMap::tile_castle_moss);
			    	else if (args[2] == "castle_back")
						blob.set_TileType("editor_tile", CMap::tile_castle_back);
			    	else if (args[2] == "castle_back_moss")
						blob.set_TileType("editor_tile", CMap::tile_castle_back_moss);
			    	else if (args[2] == "gold")
						blob.set_TileType("editor_tile", CMap::tile_gold);
			    	else if (args[2] == "stone")
						blob.set_TileType("editor_tile", CMap::tile_stone);
			    	else if (args[2] == "thickstone")
						blob.set_TileType("editor_tile", CMap::tile_thickstone);
			    	else if (args[2] == "bedrock")
						blob.set_TileType("editor_tile", CMap::tile_bedrock);
			    	else if (args[2] == "wood")
						blob.set_TileType("editor_tile", CMap::tile_wood);
			    	else if (args[2] == "wood_back")
						blob.set_TileType("editor_tile", CMap::tile_wood_back);
					
					blob.Tag("editor_menu_off");
				}
			}
		}
		return false;
	}
    return true;
}

// -- OPTIONAL DEBUG MESSAGES
// bool onClientProcessChat( CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player )
// {
// 	string[]@ args = text_in.split(" ");
// 	if       (args[0] == "!editor" && MayUseEditor(player) && player is getLocalPlayer())
// 	{
// 	    CBlob@ blob = player.getBlob();
// 		if    (blob !is null)
// 		{
// 		    if(args[1] == "on")
// 			    client_AddToChat("EDITOR: Enabled", SColor(255, 255, 0, 0));
// 			else if(args[1] == "off")
// 			    client_AddToChat("EDITOR: Disabled", SColor(255, 255, 0, 0));
			
// 			if(blob.hasTag("editor"))
// 			{
// 				if(args[1] == "setblob")
// 				{
// 			        client_AddToChat("EDITOR: Blob set to " + args[2], SColor(255, 255, 0, 0));
// 				}
// 				else if(args[1] == "settile")
// 				{
// 			    	if (args[2] == "ground" ||
// 			    		args[2] == "ground_back" ||
// 			    		args[2] == "grass" ||
// 			    		args[2] == "castle" ||
// 			    		args[2] == "castle_moss" ||
// 			    		args[2] == "castle_back" ||
// 			    		args[2] == "castle_back_moss" ||
// 			    		args[2] == "gold" ||
// 			    		args[2] == "stone" ||
// 			    		args[2] == "thickstone" ||
// 			    		args[2] == "bedrock" ||
// 			    		args[2] == "wood" ||
// 			    		args[2] == "wood_back")
// 			            client_AddToChat("EDITOR: Tile set to " + args[2], SColor(255, 255, 0, 0));
// 				    else
// 			            client_AddToChat("EDITOR: Specified tile does not exist", SColor(255, 255, 0, 0));
// 				}
// 			}
// 		}
//     	return false;
// 	}
// 	return true;
// }