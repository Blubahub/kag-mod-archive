// main menu skin

namespace UI
{
	namespace Slider
	{
		void RenderSlider( Proxy@ proxy )
		{
		/*	if (proxy.control !is null)
			{
				float value, min, max;
				proxy.control.vars.get( "value", value );
				proxy.control.vars.get( "min", min );
				proxy.control.vars.get( "max", max );
				value = (value - min) / (max-min);


				Vec2f margin(12,12);

				if (proxy.selected){
					GUI::DrawRectangle( proxy.ul + Vec2f(5, 25),
					 Vec2f( proxy.ul.x + (proxy.lr.x-proxy.ul.x), proxy.lr.y ) - Vec2f(5,5),
					 CONTROL_EDIT_COLOR );
				}

				GUI::DrawRectangle( proxy.ul + Vec2f(5, 20),
				 Vec2f( proxy.ul.x + value * (proxy.lr.x-proxy.ul.x), proxy.lr.y ) - Vec2f(5,5),
				 proxy.selected ? CONTROL_HOVER_COLOR : CONTROL_EDIT_COLOR );
			}	*/		
		}

		void Render( Proxy@ proxy )
		{
			RenderSlider(proxy);
		}

		void SmallRender( Proxy@ proxy )
		{
			RenderSlider(proxy);
		}		
	}
}