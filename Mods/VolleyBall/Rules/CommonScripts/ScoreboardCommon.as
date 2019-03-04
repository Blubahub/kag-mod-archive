f32 getKDR(CPlayer@ p)
{
	return p.getKills() / Maths::Max(f32(p.getDeaths()), 1.0f);
}

SColor getNameColour(CPlayer@ p)
{
    SColor c;

    if (p.isDev()) {
        c = SColor(0xffb400ff); //dev
    } else if (p.isGuard()) {
        c = SColor(0xffa0ffa0); //guard
    } else if (getSecurity().checkAccess_Feature(p, "admin_color") || p.isRCON()) {
        c = SColor(0xfffa5a00); //admin
    } else if (p.isMyPlayer()) {
        c = SColor(0xffffEE44); //my player
    } else {
        c = SColor(0xffffffff); //normal
    }

    if(p.getBlob() is null && p.getTeamNum() != getRules().getSpectatorTeamNum())
    {
        uint b = c.getBlue();
        uint g = c.getGreen();
        uint r = c.getRed();

        b -= 75;
        g -= 75;
        r -= 75;

        b = Maths::Max(b, 25);
        g = Maths::Max(g, 25);
        r = Maths::Max(r, 25);

        c.setBlue(b);
        c.setGreen(g);
        c.setRed(r);
    }
	return c;
}

void setSpectatePlayer(string username)
{
    CPlayer@ player = getLocalPlayer();
    CPlayer@ target = getPlayerByUsername(username);
    if((player.getBlob() is null || player.getBlob().hasTag("dead")) && player !is target && target !is null)
    {
        CRules@ rules = getRules();
        rules.set_bool("set new target", true);
        rules.set_string("new target", username);
    }
}

float drawServerInfo(float y)
{
	GUI::SetFont("menu");

    Vec2f pos(getScreenWidth()/2, y);
    float width = 200;


    CNet@ net = getNet();
    CRules@ rules = getRules();

    string info = getTranslatedString(rules.gamemode_name) + " " + getTranslatedString("Mod");
    Vec2f dim;
    GUI::GetTextDimensions(info, dim);
    if(dim.x + 15 > width)
        width = dim.x + 15;

    GUI::GetTextDimensions(net.joined_servername, dim);
    if(dim.x + 15 > width)
        width = dim.x + 15;


    pos.x -= width/2;
    Vec2f bot = pos;
    bot.x += width;
    bot.y += 100;

    Vec2f mid(getScreenWidth()/2, y);


    GUI::DrawFramedPane(pos, bot);

    SColor white(0xffffffff);

    mid.y += 15;
    GUI::DrawTextCentered(net.joined_servername, mid, white);
    mid.y += 15;
    GUI::DrawTextCentered(net.joined_ip, mid, white);
    mid.y += 22;
    GUI::DrawTextCentered(info, mid, white); 
    mid.y += 15;
    GUI::DrawTextCentered("Made By:", mid, white);
    mid.y += 15; 

    string ModDev = "Monkey_Feats";

    SColor first = SColor(0xffffb3ba); // find cool palettes color-hex.com, or similar.
    SColor second = SColor(0xffffdfba); // copy each color hex without the #.
    SColor third = SColor(0xffffffba);  // paste it after the 0xff.
    SColor fourth = SColor(0xffbaffc9);
    SColor fifth = SColor(0xffbae1ff);
    
    for (int i = 0; i < ModDev.length; i++)
    {
        string letter = ModDev.substr(i,1);

        float time = -(getGameTime()*0.1);
        f32 wave = (Maths::Sin(2*3.14159*(time*0.35)+i*0.35)) * 1.5; // what a mess ;)
        int s = (Maths::Max(Maths::Abs(Maths::Ceil(-3.5+wave*1.4)), 0));   
        SColor col;

        switch (s) 
        {
            case 0: col = first; break;
            case 1: col = second; break;
            case 2: col = third; break;
            case 3: col = fourth; break;
            case 4: col = fifth; break;
        }

        GUI::DrawTextCentered(letter, mid+Vec2f(-(ModDev.length*8.5)/2+(i*9), -wave), col);
    }
    return bot.y;
}

string timestamp(uint s)
{
    string ret;
    int hours = s/60/60;
    if (hours > 0)
        ret += hours + getTranslatedString("h ");

    int minutes = s/60%60;
    if (minutes < 10)
        ret += "0";

    ret += minutes + getTranslatedString("m ");

    int seconds = s%60;
    if (seconds < 10)
        ret += "0";

    ret += seconds + getTranslatedString("s ");

    return ret;
}

void drawPlayerCard(CPlayer@ player, Vec2f pos)
{
	/*
    if(player!is null)
    {
        GUI::SetFont("menu");

        f32 stepheight = 8;
        Vec2f atopleft = pos;
        atopleft.x -= stepheight;
        atopleft.y -= stepheight*2;
        Vec2f abottomright = atopleft;
        abottomright.y += 96 + 16 + 48;
        abottomright.x += 96 + 16;

        //int namecolour = getNameColour(player);
        GUI::DrawIconDirect("playercard.png", atopleft, Vec2f(0, 0), Vec2f(60, 94));
        GUI::DrawText(player.getUsername(), Vec2f(pos.x + 2, atopleft.y+10), SColor(0xffffffff));
        player.drawAvatar(Vec2f(atopleft.x+6*2, atopleft.y+16*2), 1.0f);
        atopleft.y += 96 + 30;
        atopleft.x += 8;
        GUI::DrawIconDirect("playercardicons.png", Vec2f(atopleft.x, atopleft.y), Vec2f(16*2, 0), Vec2f(16, 16));
        GUI::DrawText("9600", Vec2f(atopleft.x+32, atopleft.y+6), SColor(0xffffffff));
        atopleft.y += 23;
        GUI::DrawIconDirect("playercardicons", Vec2f(atopleft.x, atopleft.y), Vec2f(16*3, 0), Vec2f(16, 16));
        GUI::DrawText("450", Vec2f(atopleft.x+32, atopleft.y+6), SColor(0xffffffff));

    }
    */

}
