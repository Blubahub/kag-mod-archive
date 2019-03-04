#include "modname.as";

void onInit(CSprite@ this)
{
	int team = this.getBlob().getTeamNum();
	string tex = this.getBlob().getSexNum() == 0 ?
					"../Mods/"+mod_name+"/Entities/Structures/Spikes/Spikes.png" :
					"../Mods/"+mod_name+"/Entities/Structures/Spikes/Spikes.png";
	if (team >= 8 && team <= 15)
		tex = this.getBlob().getSexNum() == 0 ?
				"../Mods/"+mod_name+"/Entities/Structures/Spikes/SpikesB.png" :
				"../Mods/"+mod_name+"/Entities/Structures/Spikes/SpikesB.png";
	else if (team >= 16 && team <= 23)
		tex = this.getBlob().getSexNum() == 0 ?
				"../Mods/"+mod_name+"/Entities/Structures/Spikes/SpikesS.png" :
				"../Mods/"+mod_name+"/Entities/Structures/Spikes/SpikesS.png";
	else if (team >= 24 && team <= 31)
		tex = this.getBlob().getSexNum() == 0 ?
				"../Mods/"+mod_name+"/Entities/Structures/Spikes/SpikesW.png" :
				"../Mods/"+mod_name+"/Entities/Structures/Spikes/SpikesW.png";
	const string texname = tex;
	
	this.ReloadSprite(texname, this.getConsts().frameWidth, this.getConsts().frameHeight, team-int(team/8)*8, this.getBlob().getSkinNum());
}