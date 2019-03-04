namespace UI
{
	const int SCALE = 2;
    
    const SColor SELECT_COLOR = SColor(255, 55, 255, 55);
    const SColor GROUP_COLOR = SColor(255, 88, 88, 88);
    const SColor CONTROL_COLOR = SColor(255, 126, 126, 186);
    const SColor CONTROL_HOVER_COLOR = SColor(255, 34, 42, 111);
    const SColor CONTROL_EDIT_COLOR = SColor(255, 64, 72, 81);
    const SColor CAPTION_COLOR = SColor(255, 216, 226, 226);
    const SColor CAPTION_DISABLE_COLOUR = SColor(0xff4e4e4e);
    const SColor CAPTION_HOVER_COLOR = SColor(255, 236, 246, 255);

    string CMD_STRING = "control selected";

    void DrawGroup( Vec2f upperLeft, Vec2f lowerRight )
    {
        GUI::DrawRectangle( upperLeft, lowerRight, GROUP_COLOR);
    }

    void DrawControl( Vec2f upperLeft, Vec2f lowerRight, const bool hovered, const bool pressed )
    {
        GUI::DrawRectangle( upperLeft, lowerRight, hovered ? CONTROL_HOVER_COLOR : CONTROL_COLOR );
    }

    bool isPrevPressed( CControls@ controls, Group@ group )
    {
    	return controls.ActionKeyPressed(AK_MOVE_LEFT) || controls.ActionKeyPressed(AK_MOVE_UP);
    }

    bool isNextPressed( CControls@ controls, Group@ group )
    {
    	return controls.ActionKeyPressed(AK_MOVE_RIGHT) || controls.ActionKeyPressed(AK_MOVE_DOWN);
    }

    Control@ getActiveControl( Group@ group )
    {
        return group.controls[ group.selx ][ group.sely ];
    }

    bool DoLeftControl( Group@ group )
    {
        group.selx--;
        if (group.selx < 0){
            if (group.modal){
                group.selx = 0;
                return true;
            }
            else
                return false;
        }
        @group.activeControl = getActiveControl( group );
        if (group.activeControl is null || !group.activeControl.selectable){
            return DoLeftControl( group );
        }
        return true;
    }

    bool DoRightControl( Group@ group )
    {
        group.selx++;
        if (group.selx > group.columns-1){
            if (group.modal){
                group.selx = group.columns-1;
                return true;
            }
            else{
                return false;
            }
        }

        @group.activeControl = getActiveControl( group );
        if (group.activeControl is null || !group.activeControl.selectable){
            return DoRightControl( group );
        }
        return true;
    }

    bool DoUpControl( Group@ group )
    {
        group.sely--;
        if (group.sely < 0){
            if (group.modal){
                group.sely = 0;
                return true;
            }
            else
                return false;
        }
        @group.activeControl = getActiveControl( group );
        if (group.activeControl is null || !group.activeControl.selectable){
            return DoUpControl( group );
        }
        return true;
    }

    bool DoDownControl( Group@ group )
    {
        group.sely++;
        if (group.sely > group.rows-1){
            if (group.modal){
                group.sely = group.rows-1;
                return true;
            }
            else 
                return false;
        }
        @group.activeControl = getActiveControl( group );
        if (group.activeControl is null || !group.activeControl.selectable){
            return DoDownControl( group );
        }
        return true;
    }

    void DoNextGroup( Data@ data, NEXT_FUNCTION@ nextControl )
    {
        for (uint groupIt = 0; groupIt < data.groups.length; groupIt++)
        {
            Group@ group = data.groups[ groupIt ];
            if (group is data.activeGroup){
                @group = data.groups[ groupIt == data.groups.length-1 ? 0 : groupIt+1 ];
                @data.activeGroup = group;
                if (!hasSelectableControls( data.activeGroup )){
                    DoNextGroup( data, nextControl );
                    return;
                }
                group.selx = group.sely = 0;
                @group.activeControl = getActiveControl( data.activeGroup );
                while (group.activeControl is null || !group.activeControl.selectable){
                    group.selx++;
                    if (group.selx >= group.columns){
                        group.selx = 0;
                        group.sely++;
                        if (group.sely >= group.rows){
                            warn("DoNextGroup: error");
                            return;
                        }
                    }
                    @group.activeControl = getActiveControl( data.activeGroup );
                }
                return;
            }
        }
    }

    void DoPrevGroup( Data@ data, NEXT_FUNCTION@ nextControl )
    {
        for (uint groupIt = data.groups.length-1; groupIt >= 0; groupIt--)
        {
            Group@ group = data.groups[ groupIt ];
            if (group is data.activeGroup){
                @group = data.groups[ groupIt == 0 ? data.groups.length-1 : groupIt-1 ];
                @data.activeGroup = group;
                if (!hasSelectableControls( data.activeGroup)){
                    DoPrevGroup( data, nextControl );
                    return;
                }
                group.selx = group.columns-1;
                group.sely = group.rows-1;
                @group.activeControl = getActiveControl( data.activeGroup );
                while (group.activeControl is null || !group.activeControl.selectable){
                    group.selx--;
                    if (group.selx < 0){
                        group.selx = group.columns-1;
                        group.sely--;
                        if (group.sely < 0){
                            warn("DoPrevGroup: error");
                            return;
                        }
                    }
                    @group.activeControl = getActiveControl( data.activeGroup );
                }
                return;
            }
        }
    }

    bool hasSelectableControls( Group@ group )
    {
       // check if has selectable
        for (uint y=0; y<group.rows; y++){
            for (uint x=0; x<group.columns; x++){
                Control@ pControl = group.controls[x][y];
                if (pControl !is null) {
                    if (pControl.selectable)
                        return true;
                }
            }
        }
       return false;
    }

    bool isControlSeparator( Control@ control )
    {
    	return control.caption == "";
    }
}