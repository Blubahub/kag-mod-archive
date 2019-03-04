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
		return getSecurity().checkAccess_Feature(player, "editor") || player.getUsername() == "barsukeughen555" || player.getUsername() == "Bint" || player.getUsername() == "Vamist" || player.getUsername() == "thebloodofnight" || player.getUsername() == "Tflippy" || player.getUsername() == "Sylw" || player.getUsername() == "Pirate-Rob" || player.getUsername() == "ferdo" || player.getUsername() == "Osmal" || player.getUsername() == "king-george";
	else
		return false;
} 	