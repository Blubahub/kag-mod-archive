/* CreatureLogic.as
 * author: Aphelion
 */

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
    return this.hasTag("dead") || this.getTeamNum() == byBlob.getTeamNum();
}