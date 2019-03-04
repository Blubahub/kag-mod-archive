/*
MOD name: Ranks
Author: SnIcKeRs
*/

const string STATS_DIR = "../Cache/Stats/";
Stats@[] allStats;// array of online player's stats

SColor COLOR(51,167, 108, 0);

class Stats
{
    CPlayer@ player;
    u32 kills, deaths;
    string username = "";
    Stats(CPlayer@ player, u32 kills, u32 deaths)
    {
        @this.player = @player;
        this.kills = kills;
        this.deaths = deaths;
    }
}

Stats@ getStats(CPlayer@ player)
{
    for(uint i = 0; i < allStats.length(); i++)
    {
        if(allStats[i].player is player)
        {
            return allStats[i];
        }
    }

    return null;
}

void saveStats(Stats@ stats)
{
    print("Saving "+ stats.player.getUsername()+" stats.");
    writeStats(stats);
}

void saveAllStats()
{
    for(uint i = 0; i < allStats.length(); i++)
    {
        saveStats(allStats[i]);
    }
}

void writeStats(Stats@ stats)
{
    u32 deaths, kills;
    string userName = stats.player.getUsername(); 
    
    ConfigFile file;
    
    file.loadFile(STATS_DIR + userName);
    file.add_u32("kills", stats.kills);
    file.add_u32("deaths", stats.deaths);
    
    if(!file.saveFile("Stats/" + userName))
    {
        print("Cant save file " + userName +".cfg");
    }
}

Stats@ readStats(CPlayer@ player)
{
    u32 deaths, kills;

    string userName = player.getUsername(); 
    ConfigFile file;

    if(!file.loadFile( STATS_DIR + userName))
    {
        print("ERR: Cant read stats file: "+userName+".cfg" );
        writeStats(Stats(player, 0, 0));//create clean stats file
    }

    kills = file.read_u32("kills",0);
    deaths = file.read_u32("deaths",0);

    return Stats(player, kills, deaths);
}

Stats@ readStatsByName(string username)
{
    u32 deaths, kills;

    ConfigFile file;

    if(!file.loadFile( STATS_DIR + username))
    {
       return null;//null if there is no stats file
    }

    kills = file.read_u32("kills",0);
    deaths = file.read_u32("deaths",0);

    Stats@ stats = Stats(null, kills, deaths);
    stats.username = username;
    return stats;
}

void swapStats(Stats@[] &inout arr, uint i, uint j)
{
    Stats@ tmpStats = arr[i];
    @arr[i] = @arr[j];
    @arr[j] = @tmpStats;
}

f32 getKD(uint kills, uint deaths)
{
    f32 k = kills, d = deaths;
    f32 kd = deaths != 0 ? k/d  : k;
    return kd;
}

int getPoints(uint kills, uint deaths)
{
    return (int(kills)-int(deaths))*getKD(kills,deaths)+ int(kills/2) ;
}

string getTop(string f_list)
{
    ConfigFile file;
    string[] list;
    Stats@[] arr_stats;
    
    if(!file.loadFile(f_list))
    {
        print("ERR: Cant read players.cfg file" );
        return "Top function isn't active";
    }
    if(!file.readIntoArray_string(list,"files")){ 
        print("Cant read array");
        return ""; }
    
    for(uint i = 0; i < list.length(); i++)
    {
        Stats@ stats = readStatsByName(list[i]);
        if(stats !is null)
        {
            arr_stats.insertLast(@stats);
        }
    }

    //sorting
    for(uint j = 0; j < arr_stats.length(); j++)
    {
        for(uint i = 0; i < arr_stats.length() - j - 1; i++)
        {
            int points1 = getPoints(arr_stats[i].kills, arr_stats[i].deaths);
            int points2 = getPoints(arr_stats[i+1].kills, arr_stats[i+1].deaths);
            
            if(points1<points2)
            {
                swapStats(arr_stats, i, i+1);
            }
        }
    }

    //result string top 10
    string result = "----------Top10----------\n";

    for(uint i = 0; i < arr_stats.length() && i < 10; i++)
    {
        int points = getPoints(arr_stats[i].kills, arr_stats[i].deaths);
        result += (i+1) + ") " + arr_stats[i].username +" "+arr_stats[i].kills+"/"+arr_stats[i].deaths + " Points: "+ points +"\n"; 
    }

    return result;
}
