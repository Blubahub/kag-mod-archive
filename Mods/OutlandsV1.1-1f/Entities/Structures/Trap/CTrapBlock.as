#include "modname.as";

void onInit(CSprite@ this)
{
	int team = this.getBlob().getTeamNum();
	string tex = this.getBlob().getSexNum() == 0 ?
					"../Mods/"+mod_name+"/Entities/Structures/Trap/TrapBlock.png" :
					"../Mods/"+mod_name+"/Entities/Structures/Trap/TrapBlock.png";
	if (team >= 8 && team <= 15)
		tex = this.getBlob().getSexNum() == 0 ?
				"../Mods/"+mod_name+"/Entities/Structures/Trap/TrapBlockB.png" :
				"../Mods/"+mod_name+"/Entities/Structures/Trap/TrapBlockB.png";
	else if (team >= 16 && team <= 23)
		tex = this.getBlob().getSexNum() == 0 ?
				"../Mods/"+mod_name+"/Entities/Structures/Trap/TrapBlockS.png" :
				"../Mods/"+mod_name+"/Entities/Structures/Trap/TrapBlockS.png";
	else if (team >= 24 && team <= 31)
		tex = this.getBlob().getSexNum() == 0 ?
				"../Mods/"+mod_name+"/Entities/Structures/Trap/TrapBlockW.png" :
				"../Mods/"+mod_name+"/Entities/Structures/Trap/TrapBlockW.png";
	const string texname = tex;
	
	this.ReloadSprite(texname, this.getConsts().frameWidth, this.getConsts().frameHeight, team-int(team/8)*8, this.getBlob().getSkinNum());
}