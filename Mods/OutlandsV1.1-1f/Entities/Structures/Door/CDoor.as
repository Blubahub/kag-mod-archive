#include "modname.as";

void onInit(CSprite@ this)
{
	int team = this.getBlob().getTeamNum();
	string tex = this.getBlob().getSexNum() == 0 ?
					"../Mods/"+mod_name+"/Entities/Structures/Door/CDoor.png" :
					"../Mods/"+mod_name+"/Entities/Structures/Door/CDoor.png";
	if (team >= 8 && team <= 15)
		tex = this.getBlob().getSexNum() == 0 ?
				"../Mods/"+mod_name+"/Entities/Structures/Door/CDoorB.png" :
				"../Mods/"+mod_name+"/Entities/Structures/Door/CDoorB.png";
	else if (team >= 16 && team <= 23)
		tex = this.getBlob().getSexNum() == 0 ?
				"../Mods/"+mod_name+"/Entities/Structures/Door/CDoorS.png" :
				"../Mods/"+mod_name+"/Entities/Structures/Door/CDoorS.png";
	else if (team >= 24 && team <= 31)
		tex = this.getBlob().getSexNum() == 0 ?
				"../Mods/"+mod_name+"/Entities/Structures/Door/CDoorW.png" :
				"../Mods/"+mod_name+"/Entities/Structures/Door/CDoorW.png";
	const string texname = tex;
	
	this.ReloadSprite(texname, this.getConsts().frameWidth, this.getConsts().frameHeight, team-int(team/8)*8, this.getBlob().getSkinNum());
}