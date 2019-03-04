/* ForceNoTeam.as
 * author: Aphelion
 *
 * Forces the blob team to Neutral
 */

void onInit(CBlob@ this)
{
	this.server_setTeamNum(-1);
}