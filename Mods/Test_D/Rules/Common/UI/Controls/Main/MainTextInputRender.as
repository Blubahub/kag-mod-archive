// main menu skin

namespace UI
{
	namespace TextInput
	{
		void Render( Proxy@ proxy )
		{
		}

		void RenderCaption( Proxy@ proxy )
		{
	        Vec2f dim;
	        const bool editing = proxy.selected && proxy.group !is null && proxy.group.editControl is proxy.control;
	        string text = proxy.caption;
	        if (!editing && text == ""){
	        	text = "_______________";
	        }

	        GUI::GetTextDimensions( text, dim );
	        Vec2f pos = proxy.ul;
	        pos += Vec2f( proxy.align.x*(proxy.lr.x - proxy.ul.x), proxy.align.y*(proxy.lr.y - proxy.ul.y) - 0.3*dim.y );

	       	if (editing && getGameTime() % 15 > 7){
	       		GUI::DrawText( "|", Vec2f(pos.x + dim.x - dim.y*0.23, pos.y), CAPTION_COLOR );
	       	}

	        GUI::DrawText( text, pos, CAPTION_COLOR );

	        if (!editing && text.size() > 0)
	        {
		        string line = "_";
		        for (uint i=0; i < text.size()-1; i++)
		        	line += "_";

		        GUI::DrawText( line, pos, CAPTION_COLOR );
		    }
		}
	  
	}
}