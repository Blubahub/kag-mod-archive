
shared class TribeInfo
{
	u8[][] TribePlan;
	//0 - leave as is
	//1 - brick ?floor?
	//2 - brick
	//3 - wood ?floor?
	//4 - wood
	//5 - ladder
	//6 - stone backwall
	//7 - wood backwall
	//8 - platform

	TribeInfo()
	{
		int W = getMap().tilemapwidth;
		int H = getMap().tilemapheight;
		
		print("Initing town plan. W:"+W+" H:"+H);
		
		for(int i = 0; i < W; i += 1){
			u8[] temp;
			for(int j = 0; j < H; j += 1){
				temp.push_back(0);
			}
			TribePlan.push_back(temp);
		}
		
	}
	
	void MakeFiller(){
	
		int W = getMap().tilemapwidth/6;
		int H = getMap().tilemapheight/6;
	
		bool[][] TribeNodes; //Initialise the node grid
		for(int i = 0; i < W; i += 1){
			bool[] temp;
			for(int j = 0; j < H; j += 1){
				temp.push_back(true);
			}
			TribeNodes.push_back(temp);
		}
		
		for(int i = 0; i < W; i += 1){ //Set up nodes. No nodes on map edges or in air
			for(int j = 0; j < H; j += 1){
				if(i == 0 || j == 0 || i == W-1 || j == H-1){
					TribeNodes[i][j] = false;
					continue;
				}
				
				if(TribeNodes[i][j])
				if(!getMap().isTileSolid(Vec2f(i*6*8,j*6*8))){
					TribeNodes[i][j] = false;
				}
			}
		}
		
		for(int i = 1; i < W-1; i += 1){ //Clear/kill singular/lonely nodes :(
			for(int j = 1; j < H-1; j += 1){
				if(TribeNodes[i][j]){
					if(!TribeNodes[i-1][j])
					if(!TribeNodes[i+1][j])
					if(!TribeNodes[i][j+1])
					if(!TribeNodes[i][j-1])
					TribeNodes[i][j] = false;
				}
			}
		}
		
		for(int i = 1; i < W-1; i += 1){ //Make a node above all existing nodes.
			for(int j = 1; j < H-1; j += 1){
				if(TribeNodes[i][j+1]){
					TribeNodes[i][j] = true;
				}
			}
		}
		
		for(int j = 1; j < H-1; j += 1){ //Draw nodes to console (temp)
			string temp = "";
			for(int i = 1; i < W-1; i += 1){
				if(TribeNodes[i][j]){
					temp += "+";
				} else {
					temp += "O";
				}
			}
			print(temp);
		}
		
		for(int j = 1; j < H-1; j += 1){ //Fill in the tribe plan with the nodes
			for(int i = 1; i < W-1; i += 1){
				if(TribeNodes[i][j]){
					int X = i*6;
					int Y = j*6;
					
					TribePlan[X-1][Y-1] = 2;
					TribePlan[X+1][Y-1] = 2;
					TribePlan[X-1][Y+1] = 1;
					TribePlan[X+1][Y+1] = 1;
					
					if(TribeNodes[i][j-1] || TribeNodes[i][j+1])TribePlan[X][Y] = 5;
					else TribePlan[X][Y] = 6;
					
					if(!TribeNodes[i-1][j])TribePlan[X-1][Y] = 2;
					else TribePlan[X-1][Y] = 6;
					if(!TribeNodes[i+1][j])TribePlan[X+1][Y] = 2;
					else TribePlan[X+1][Y] = 6;
					if(!TribeNodes[i][j-1])TribePlan[X][Y-1] = 2;
					else TribePlan[X][Y-1] = 5;
					if(!TribeNodes[i][j+1])TribePlan[X][Y+1] = 1;
					else TribePlan[X][Y+1] = 5;
					
					if(TribeNodes[i+1][j])
					for(int k = 0; k < 4; k += 1){
						TribePlan[X+2+k][Y] = 7;
						TribePlan[X+2+k][Y-1] = 4;
						TribePlan[X+2+k][Y+1] = 3;
					}
					
					if(TribeNodes[i][j+1])
					for(int k = 0; k < 4; k += 1){
						TribePlan[X][Y+2+k] = 5;
						TribePlan[X-1][Y+2+k] = 4;
						TribePlan[X-1][Y+2+k] = 4;
					}
				}
			}
		}
		
		for(int j = 1; j < (H-1)*6; j += 1){ //Change floors/walls according to the world
			for(int i = 1; i < (W-1)*6; i += 1){
				if(TribePlan[i][j] == 1){
					if(getMap().isTileSolid(Vec2f(i*8,j*8)))TribePlan[i][j] = 2;
					else TribePlan[i][j] = 8;
				}
				if(TribePlan[i][j] == 3){
					if(getMap().isTileSolid(Vec2f(i*8,j*8)))TribePlan[i][j] = 4;
					else TribePlan[i][j] = 8;
				}
				if(TribePlan[i][j] == 6){
					if(getMap().isTileBackground(getMap().getTile(Vec2f(i*8,j*8))) || getMap().isTileSolid(Vec2f(i*8,j*8)))TribePlan[i][j] = 6;
					else TribePlan[i][j] = 7;
				}
			}
		}
		
		/*
		for(int j = 1; j < (H-1)*6; j += 1){ //Copy tribe plan to world (temp)
			for(int i = 1; i < (W-1)*6; i += 1){
				if(TribePlan[i][j] == 1){
					if(getMap().isTileSolid(Vec2f(i*8,j*8)))getMap().server_SetTile(Vec2f(i*8,j*8), 48);
					else getMap().server_SetTile(Vec2f(i*8,j*8), 196); //platform
				}
				if(TribePlan[i][j] == 2){
					if(getMap().isTileSolid(Vec2f(i*8,j*8)))getMap().server_SetTile(Vec2f(i*8,j*8), 48);
				}
				if(TribePlan[i][j] == 3){
					if(getMap().isTileSolid(Vec2f(i*8,j*8)))getMap().server_SetTile(Vec2f(i*8,j*8), 196);
					else getMap().server_SetTile(Vec2f(i*8,j*8), 196); //platform
				}
				if(TribePlan[i][j] == 4){
					if(getMap().isTileSolid(Vec2f(i*8,j*8)))getMap().server_SetTile(Vec2f(i*8,j*8), 196);
				}
				if(TribePlan[i][j] == 5){
					getMap().server_SetTile(Vec2f(i*8,j*8), 144);
				}
				if(TribePlan[i][j] == 6){
					if(getMap().isTileBackground(getMap().getTile(Vec2f(i*8,j*8))) || getMap().isTileSolid(Vec2f(i*8,j*8)))if(getMap().isTileSolid(Vec2f(i*8,j*8)))getMap().server_SetTile(Vec2f(i*8,j*8), 64);
					else getMap().server_SetTile(Vec2f(i*8,j*8), 205);
				}
				if(TribePlan[i][j] == 7){
					getMap().server_SetTile(Vec2f(i*8,j*8), 205);
				}
			}
		}*/
	}
};