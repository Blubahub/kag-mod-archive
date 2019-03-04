/* EditorConfig.as
 * original editor author: Aphelion3371
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
	    return getSecurity().checkAccess_Feature(player, "editor");
	else
	    return false;
}
