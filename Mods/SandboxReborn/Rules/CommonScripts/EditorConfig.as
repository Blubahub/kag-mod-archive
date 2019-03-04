/* EditorConfig.as
 * original editor author: Aphelion
 *
 * Loads the editor configuration file to determine who is permitted to use the editor.
 */

bool MayUseEditor( CBlob@ blob )
{
    if (blob !is null)
	    return MayUseEditor(blob.getPlayer());
	else
	    return false;
}

bool MayUseEditor( CPlayer@ player )
{
    if (player !is null)
	    return getSecurity().checkAccess_Feature(player, "editor") || player.getUsername() == "JaytleBee";
	else
	    return false;
}

bool MaySpawnBlobs(CPlayer@ player)
{
	if (player !is null)
		return getSecurity().checkAccess_Feature(player, "editor_spawnblobs") || player.getUsername() == "JaytleBee";
	else
		return false;
}