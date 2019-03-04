#include "UI.as"
#include "UICommonUpdates.as"

namespace UI
{
	namespace Option
	{
		funcdef int OPTION_FUNC( int );

		Control@ Add( const string &in caption, OPTION_FUNC@ setFunc, PROXY_RENDER_FUNCTION@ renderFunc, PROXY_RENDER_FUNCTION@ renderCaptionFunc, int option )
	    {
	    	Data@ data = getData();
	    	Control@ control = AddControl( caption );
	    	control.selectable = true;
	    	@control.select = Select;
	    	@control.select2 = Select2;
	    	control.vars.set( "set func", @setFunc );
	    	control.vars.set( "option", option );
	    	string[] options = caption.split("|");
	    	control.vars.set( "options", options );
	   		AddProxy( data, renderFunc, TransitionUpdate, data.activeGroup, control, 0.5f );
	   		Proxy@ proxy = AddProxy( data, renderCaptionFunc, TransitionUpdate, data.activeGroup, control, 1.0f );
	   		proxy.align.Set(0.0f, 0.5f);

			if (option >= options.length)
				option = 0;
	   		control.caption = " * " + options[option];

	   		return control;
	    }

		Control@ Add( const string &in caption, OPTION_FUNC@ setFunc, int option )
	    {
	    	return Add( caption, setFunc, Render, RenderCaption, option );
	    }	    

		void Select( CRules@ this, UI::Group@ group, UI::Control@ control )	{
			MoveOption( this, group, control, 1 );
		}

		void Select2( CRules@ this, UI::Group@ group, UI::Control@ control )	{
			MoveOption( this, group, control, -1 );
		}

		void MoveOption( CRules@ this, UI::Group@ group, UI::Control@ control, int increment )
		{
			string[] options;
			int option;
			control.vars.get( "options", options );
			control.vars.get( "option", option );
			option += increment;
			if (option < 0)
				option = options.length-1;
			if (option >= options.length)
				option = 0;

			OPTION_FUNC@ setFunc;
			control.vars.get("set func", @setFunc );
			if (setFunc !is null){
				option = setFunc( option );

			}
			control.vars.set( "option", option );
			control.caption = " * " + options[option];
		}
	}
}