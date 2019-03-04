#include "GR_Common.as";

void onInit(CBlob@ this)
{
    this.addCommandID("put_gold");
}
void onTick(CBlob@ this)
{
    CMap@ map = getMap();

    CBlob@[] blobsInRadius;
    CRules@ rules = getRules();
    int goldTimer = rules.get_u32("gold_timer") - getGameTime();
    if (map.getBlobsInRadius( this.getPosition(), sack_enemy_radius(), @blobsInRadius ))
    {
        for (int i = 0; i < blobsInRadius.length; i++)
        {
            CBlob @b = blobsInRadius[i];
            if (b.getTeamNum() != this.getTeamNum() && b.hasTag("player") && b !is null && gold_timer_enemy_secs() >= goldTimer)
            {   
                rules.set_u32("gold_timer", getGameTime() + gold_timer_enemy_secs());
            }
        }
    }
}
void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
    CBitStream params;
    params.write_u16(caller.getNetworkID());

    const int goldCount = this.getBlobCount("mat_gold");
    const bool hasGold = caller.getBlobCount("mat_gold") > 0;
    const int maxGold = getRules().get_u32("max_gold_in_sack");
    const bool hasSpace = goldCount < maxGold;
    if (this.getTeamNum() == caller.getTeamNum())
    {
        if (hasGold && hasSpace)
        {
            caller.CreateGenericButton( 28, Vec2f(0,0), this, this.getCommandID("put_gold"), "Put gold", params );
        }
        else if (!hasSpace)
        {
            CButton@ button = caller.CreateGenericButton( 28, Vec2f(0,0), this, 0, "Not enough space");
            if (button !is null) button.SetEnabled( false );
        }
        else if (!hasGold)
        {
            CButton@ button = caller.CreateGenericButton( 28, Vec2f(0,0), this, 0, "You have not gold" );
            if (button !is null) button.SetEnabled( false );
        }
    }
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
    CRules@ rules = getRules();
    CBlob@ caller = getBlobByNetworkID( params.read_netid() );
    if (cmd == this.getCommandID("put_gold") && caller !is null)
    {
        rules.set_bool("force_timer", true);
        const int callerGoldCount = caller.getBlobCount("mat_gold");
        const int goldCount = this.getBlobCount("mat_gold");
        const int goldNeed =  rules.get_u32("max_gold_in_sack") - goldCount;
        int quantity = 0;
        if (callerGoldCount < goldNeed)
            quantity = callerGoldCount;
        else 
            quantity = goldNeed;

        caller.TakeBlob("mat_gold", goldNeed);
        if (getNet().isServer())
        {
            CBlob@ gold = server_CreateBlob( "mat_gold", this.getTeamNum(), this.getPosition());
            if (gold !is null)
            {
                gold.server_SetQuantity(quantity);
                this.server_PutInInventory(gold);
            } 
        }
    }
}

bool isInventoryAccessible( CBlob@ this, CBlob@ forBlob )
{
    return false;
}

void onRender(CSprite@ this)
{
    CBlob@ blob = this.getBlob();
    CPlayer@ p = getLocalPlayer();
    if (p !is null && p.isMyPlayer() && !blob.isInInventory())
    {
        CBlob@ pblob = p.getBlob();
        if (pblob !is null && getControls().ActionKeyPressed(AK_PARTY) && blob.getTeamNum() == pblob.getTeamNum())
        {
            Vec2f pos2d = blob.getScreenPos();
            Vec2f center(pos2d.x - 5, pos2d.y - 5.0f);
            GUI::DrawText("" + blob.getBlobCount("mat_gold"), center, 0xffFFC64B);
        }
        
    }
       
}