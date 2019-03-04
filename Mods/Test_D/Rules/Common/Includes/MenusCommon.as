namespace Menus
{
	const int SCALE = 1;
    const SColor SELECT_COLOR = SColor(255, 55, 255, 55);
    string CMD_STRING = "button selected";

    Vec2f getMenuSize( Group@ group )
    {
    	return group.horizontal ? Vec2f( group.buttons.length * group.buttonSize.x + 2.0f*group.buttonSize.x, group.buttonSize.y )
    			: Vec2f( group.buttonSize.x, group.buttons.length * group.buttonSize.y + group.buttonSize.y );
    }

    Vec2f getMenuOffset( Group@ group )
    {
    	Vec2f menusize = getMenuSize( group );
		return Vec2f(menusize.x / 2.0f, menusize.y / 2.0f);
    }

    Vec2f getButtonOffset( Group@ group, const uint buttonIndex = 1 )
    {
    	return group.horizontal ? Vec2f(buttonIndex * group.buttonSize.x, 0) 
    			: Vec2f(0, buttonIndex * group.buttonSize.y);
    }

	Vec2f getButtonCaptionOffset( Group@ group, Button@ button, const uint buttonIndex = 0 )
    {
    	Vec2f textDim;
    	GUI::GetTextDimensions( button.caption, textDim );
    	return group.horizontal ? Vec2f((buttonIndex * group.buttonSize.x + 0.5f*group.buttonSize.x - SCALE) - textDim.x*0.5f,
                                             button.iconIndex >= 0 ? (group.buttonSize.y - textDim.y*0.25f - SCALE)
                                             : (0.5f*group.buttonSize.y - textDim.y*0.5f))
    			: Vec2f(group.buttonSize.x*0.5f - textDim.x*0.5f - SCALE,
    					button.iconIndex >= 0 ? (buttonIndex * group.buttonSize.y + 1.0f*group.buttonSize.y) - textDim.y*1.0f - SCALE
    					: (buttonIndex * group.buttonSize.y + 0.5f*group.buttonSize.y) - textDim.y*0.25f - SCALE
    					 );
    }

    bool isPrevPressed( CControls@ controls, Group@ group )
    {
    	return controls.ActionKeyPressed(AK_MOVE_LEFT) || controls.ActionKeyPressed(AK_MOVE_UP);
    }

    bool isNextPressed( CControls@ controls, Group@ group )
    {
    	return controls.ActionKeyPressed(AK_MOVE_RIGHT) || controls.ActionKeyPressed(AK_MOVE_DOWN);
    }

    void DoNextSelection( Group@ group )
    {
        group.selection = (group.selection + 1) % group.buttons.length;
    }

    void DoPrevSelection( Group@ group )
    {
        group.selection--;
        if (group.selection < 0)
	        group.selection = group.buttons.length-1;
    }

    bool isButtonSeparator( Button@ button )
    {
    	return button.caption == "";
    }
}