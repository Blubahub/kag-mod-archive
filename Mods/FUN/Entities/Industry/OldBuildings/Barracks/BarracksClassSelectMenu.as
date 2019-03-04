//stuff for building repspawn menus

#include "RespawnCommandCommon.as"

//class for getting everything needed for swapping to a class at a building

shared class NewPlayerClass
{
    string name;
    string iconFilename;
    string iconName;
    string configFilename;
    string description;
    string item;
    string itemsDesc;
};

const f32 CLASS_BUTTON_SIZE = 2;

//adding a class to a blobs list of classes

void addBarracksPlayerClass( CBlob@ this, string name, string iconName, string configFilename, string description, string ITEM, string ITEMDESC )
{
    if (!this.exists("barracksplayerclasses"))
    {
        NewPlayerClass[] classes;
        this.set( "barracksplayerclasses", classes );
    }

    NewPlayerClass p;
    p.name = name;
    p.iconName = iconName;
    p.configFilename = configFilename;
    p.description = description;
    p.item = ITEM;
    p.itemsDesc = ITEMDESC;
    this.push("barracksplayerclasses", p);
}

//helper for building menus of classes

void addBarracksClassesToMenu(CBlob@ this, CGridMenu@ menu, u16 callerID)
{
    NewPlayerClass[]@ classes;

    if (this.get( "barracksplayerclasses", @classes ))
    {
        for (uint i = 0 ; i < classes.length; i++)
        {
            NewPlayerClass @pclass = classes[i];
            CBlob@ caller = getBlobByNetworkID(callerID);
            CBitStream params;
            write_classchange(params, callerID, pclass.configFilename);
            bool hasItem = caller.getBlobCount(pclass.item) > 0;

            string description, items;
            if (!hasItem)
                description = pclass.name + "\nRequers: " + pclass.itemsDesc;
            else 
                description = pclass.name + ": " + pclass.description;

            CGridButton@ button = menu.AddButton( pclass.iconName, description, SpawnCmd::changeClass, Vec2f(CLASS_BUTTON_SIZE,CLASS_BUTTON_SIZE), params );
            if (button !is null)
                button.SetEnabled(hasItem);
        }
    }
}

NewPlayerClass@ getbarracksDefaultClass(CBlob@ this)
{
    NewPlayerClass[]@ classes;

    if (this.get( "barracksplayerclasses", @classes )) {
        return classes[0];
    }
    else {
        return null;
    }
}
