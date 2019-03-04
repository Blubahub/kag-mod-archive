#include "UI.as"

namespace UI
{
	namespace Debug
	{
		Control@ AddButton( string caption, SELECT_FUNCTION@ select )
	    {
	    	Data@ data = getData();
	    	Control@ control = AddControl( caption );
	    	control.selectable = true;
	    	@control.select = select;
	   		AddProxy( data, RenderButton, UpdateButton, data.activeGroup, control, 0.5f );
	   		AddProxy( data, RenderButtonCaption, UpdateButton, data.activeGroup, control, 1.0f );
	   		return control;
	    }

		// Button Proxy callbacks

		void UpdateButton( Proxy@ proxy  )
		{
			if (proxy.group is null){
				proxy.dead = true;
			}
			else
			{
				CalcControlPosition( proxy.group, proxy, proxy.control.x, proxy.control.y );
				proxy.selected = proxy.group.data.activeGroup is proxy.group && proxy.group.activeControl is proxy.control;
				proxy.caption = proxy.control.caption;
			}
		}

		void RenderButton( Proxy@ proxy )
		{
			GUI::DrawRectangle( proxy.ul, proxy.lr, proxy.selected ? CONTROL_HOVER_COLOR : CONTROL_COLOR );
		}

		void RenderButtonCaption( Proxy@ proxy )
		{
			UI::SetFont("gui");
	        Vec2f dim;
	        GUI::GetTextDimensions( proxy.caption, dim );
	        Vec2f pos = proxy.ul;
	        pos += Vec2f( (proxy.lr.x - proxy.ul.x - dim.x) * 0.5f, (proxy.lr.y - proxy.ul.y - dim.y) * 0.5f);
	        pos.x = Maths::Min( proxy.lr.x - dim.x, pos.x );
	        pos.y = Maths::Min( proxy.lr.y - dim.y, pos.y );
	        GUI::DrawText( proxy.caption, pos, CAPTION_COLOR );
		}
	}
}