// main menu skin

namespace UI
{
	namespace Toggle
	{
		void Render( Proxy@ proxy )
		{
		}

		void RenderCaption( Proxy@ proxy )
		{
			string caption = proxy.caption;
			if (proxy.control !is null)
			{
				bool toggle;
				proxy.control.vars.get( "toggle", toggle );
				if (toggle)
					caption = "[X] " + caption;
				else
					caption = "[ ] " + caption;
			}

	        Vec2f dim;
	        GUI::GetTextDimensions( caption, dim );
	        Vec2f pos = proxy.ul;
	        pos += Vec2f( proxy.align.x*(proxy.lr.x - proxy.ul.x), proxy.align.y*(proxy.lr.y - proxy.ul.y) - 0.3*dim.y );

	        GUI::DrawText( caption, pos, CAPTION_COLOR );
		}
	}
}