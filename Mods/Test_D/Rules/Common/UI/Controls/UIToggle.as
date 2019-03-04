#include "UI.as"
#include "UICommonUpdates.as"

namespace UI
{
	namespace Toggle
	{
		funcdef bool TOGGLE_FUNC( bool );

		Control@ Add( const string &in caption, TOGGLE_FUNC@ setFunc, PROXY_RENDER_FUNCTION@ renderFunc, PROXY_RENDER_FUNCTION@ renderCaptionFunc, bool defaultOn )
	    {
	    	Data@ data = getData();
	    	Control@ control = AddControl( caption );
	    	control.selectable = true;
	    	@control.select = Select;
	    	control.vars.set( "set func", @setFunc );
	    	control.vars.set( "toggle", defaultOn );
	   		AddProxy( data, renderFunc, TransitionUpdate, data.activeGroup, control, 0.5f );
	   		Proxy@ proxy = AddProxy( data, renderCaptionFunc, TransitionUpdate, data.activeGroup, control, 1.0f );
	   		proxy.align.Set(0.0f, 0.5f);
	   		return control;
	    }

		Control@ Add( const string &in caption, TOGGLE_FUNC@ setFunc, bool defaultOn )
	    {
	    	return Add( caption, setFunc, Render, RenderCaption, defaultOn );
	    }	    

		void Select( CRules@ this, UI::Group@ group, UI::Control@ control )
		{
			bool toggle;
			control.vars.get( "toggle", toggle );
			toggle = !toggle;

			TOGGLE_FUNC@ setFunc;
			control.vars.get("set func", @setFunc );
			if (setFunc !is null){
				toggle = setFunc( toggle );
			}

			control.vars.set( "toggle", toggle );
		}
	}
}