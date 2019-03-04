CBlob@ SpawnMook( Vec2f pos, const u8 teamNum = 255, const u8 classIndex = 0 )
{
    const u8 team = teamNum;
    CBlob @newBlob = server_CreateBlobNoInit( "soldier" );
    if (newBlob !is null) 
    {
        newBlob.Tag("mook");
        newBlob.server_setTeamNum( team );
        newBlob.setPosition( pos );
        newBlob.set_u8("class", classIndex );
    	newBlob.Init();
        newBlob.getBrain().server_SetActive( true );
    }
    return newBlob;
}