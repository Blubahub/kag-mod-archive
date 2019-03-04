
//common colours from the game palette
namespace Colours
{
    const uint YELLOW = 0xffffff80;
    const uint GOLD = 0xffffc519;
	const uint RED = 0xffff501e;
    const uint BLUE = 0xff00c0ff;
    const uint PURPLE = 0xffbb37ff;
    const uint GREEN = 0xffa9ff37;
    const uint WHITE = 0xffffffff;
	const uint DARK = 0xff3a3a3a;
    const uint GREY = 0xff8e8e8e;
	const uint BLACK = 0xff000000;

    const uint SKY = 0xff80c8ff;

    const uint TEAM1 = GOLD;
    const uint TEAM2 = PURPLE;
    const uint TEAM3 = BLUE;
    const uint TEAM4 = RED;
};

SColor getPlayerColor( CPlayer@ player )
{
    if (player is null){
        return Colours::WHITE;
    }
    return getTeamColor(player.getTeamNum());
}

SColor getBlobColor( CBlob@ blob )
{
    if (blob is null){
        return Colours::WHITE;
    }
    return getTeamColor(blob.getTeamNum());
}

SColor getTeamColor( const int team )
{
    switch (team)
    {
        case 0: return Colours::TEAM1;
        case 1: return Colours::TEAM2;
        case 2: return Colours::TEAM3;
        case 3: return Colours::TEAM4;
    }
    return Colours::WHITE;
}

void DrawTRGuiFrame(Vec2f upper, Vec2f lower)
{
    GUI::DrawRectangle(upper - Vec2f(2, 2), lower + Vec2f(2, 2), Colours::BLACK);
    GUI::DrawRectangle(upper - Vec2f(1, 1), lower + Vec2f(1, 1), Colours::DARK);
    GUI::DrawRectangle(upper, lower, Colours::BLACK);
}
