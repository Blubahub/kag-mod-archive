#include "UI.as"
#include "UILabel.as"
#include "UIButton.as"
#include "UIImage.as"
#include "UICommonUpdates.as"
#include "Timers.as"

int _dialogCount = 0;

namespace UI
{
	namespace Dialog
	{
		Control@ Add( const string &in caption, bool disabled = false )
	    {
	    	Data@ data = UI::getData();

	   		// save current selection
	   		Group@ oldGroup = data.activeGroup;

	    	Group@ group = UI::AddGroup("dialog#"+_dialogCount++, Vec2f(0.05f,0.35), Vec2f(0.95,0.75));
	    	group.modal = true;
			UI::Grid( 1, 1 );
			UI::SetFont("hud");
		//	Control@ control = UI::Label::Add( caption, disabled, 2.0f );
			Control@ ok = UI::Button::Add( caption, Select, disabled, 2.0f );
			UI::AddProxy( data, RenderBackground, NoTransitionUpdate, group, ok, 1.0f );

	    	ok.vars.set( "activeGroup", oldGroup );

	    	UI::SetSelection(-1);

	   		return ok;
	    }

		Control@ AddYesNo( const string &in captionYes, SELECT_FUNCTION@ selectYes, const string &in captionNo, SELECT_FUNCTION@ selectNo, bool bottom = false )
	    {
	    	Data@ data = UI::getData();

	   		// save current selection
	   		Group@ oldGroup = data.activeGroup;

	    	Group@ group;
			bool disabled = false;
			Control@ ok;
			Control@ no;

			if (bottom)
			{
				@group = UI::AddGroup("dialog#"+_dialogCount++, Vec2f(0.3f,0.85f), Vec2f(0.9f,0.95f));
				UI::Grid( 2, 1 );
				@ok = UI::Button::Add(captionYes, selectYes, UI::Button::SmallRender, UI::Button::RenderCaption, disabled, 2.0f );
				@no = UI::Button::Add(captionNo, selectNo, UI::Button::SmallRender, UI::Button::RenderCaption, disabled, 2.0f );
				SetSmallSelector();
			}
			else
			{
				@group = UI::AddGroup("dialog#"+_dialogCount++, Vec2f(0.25f,0.05f), Vec2f(0.75f,0.45f));
				UI::Grid( 1, 2 );
				@ok = UI::Button::Add(captionYes, selectYes, UI::Button::SmallRender, UI::Button::RenderCaption, disabled, 2.0f );
				@no = UI::Button::Add(captionNo, selectNo, UI::Button::SmallRender, UI::Button::RenderCaption, disabled, 2.0f );
			}

			group.modal = true;
			UI::AddProxy( data, RenderBackground, NoTransitionUpdate, group, ok, 1.0f );
			ok.vars.set( "activeGroup", oldGroup );
	    	no.vars.set( "activeGroup", oldGroup );

	    	UI::SetSelection(0);

	   		return ok;
	    }	    

		Control@ AddImage( const string &in filename, bool disabled = false )
	    {
	    	Data@ data = UI::getData();

	   		// save current selection
	   		Group@ oldGroup = data.activeGroup;

	    	Group@ group = UI::AddGroup("dialog#"+_dialogCount++, Vec2f(0.0f,0.0), Vec2f(1.0,1.0));
	    	group.modal = true;
			UI::Grid( 1, 2 );
			Control@ control = UI::Image::Add( filename );
			Control@ ok = UI::Button::Add("OK", Select, UI::Button::SmallRender, UI::Button::RenderCaption, disabled, 2.0f );
			UI::AddProxy( data, RenderBackground, NoTransitionUpdate, group, ok, 1.0f );

	    	ok.vars.set( "activeGroup", oldGroup );

	    	UI::SetSelection(-1);

	   		return ok;
	    }

	    Control@ AddImageFramed( const string &in filename, Vec2f imageSize, u8 frame = 0, bool disabled = false )
	    {
	    	Data@ data = UI::getData();

	   		// save current selection
	   		Group@ oldGroup = data.activeGroup;

	    	Group@ group = UI::AddGroup("dialog#"+_dialogCount++, Vec2f(0.0f,0.0), Vec2f(1.0,1.0));
	    	group.modal = true;
			UI::Grid( 1, 3 );
			Control@ buy = UI::Button::Add("Buy", Buy, UI::Button::SmallRender, UI::Button::RenderCaption, disabled, 2.0f );
			Control@ control = UI::Image::AddFramed( filename, imageSize, frame );
			Control@ ok = UI::Button::Add("Later", Select, UI::Button::SmallRender, UI::Button::RenderCaption, disabled, 2.0f );
			UI::AddProxy( data, RenderBackground, NoTransitionUpdate, group, ok, 1.0f );
	    	ok.vars.set( "activeGroup", oldGroup );
	    	buy.vars.set( "activeGroup", oldGroup );

	    	UI::SetSelection(-1);
	    	UI::SetThinSelector();
	    	
	   		return control;
	    }

	    Control@ AddImageAnimated( const string &in filename, Vec2f imageSize, u8[] frames, u8 frametime, bool disabled = false )
	    {
	    	Data@ data = UI::getData();

	   		// save current selection
	   		Group@ oldGroup = data.activeGroup;

	    	Group@ group = UI::AddGroup("dialog#"+_dialogCount++, Vec2f(0.0f,0.0), Vec2f(1.0,1.0));
	    	group.modal = true;
			UI::Grid( 1, 3 );
			Control@ buy = UI::Button::Add("Buy", Buy, UI::Button::SmallRender, UI::Button::RenderCaption, disabled, 2.0f );
			Control@ control = UI::Image::AddAnimated( filename, imageSize, frames, frametime );
			Control@ ok = UI::Button::Add("OK", Select, UI::Button::SmallRender, UI::Button::RenderCaption, disabled, 2.0f );
			UI::AddProxy( data, RenderBackground, NoTransitionUpdate, group, ok, 1.0f );

	    	ok.vars.set( "activeGroup", oldGroup );
	    	buy.vars.set( "activeGroup", oldGroup );

	    	UI::SetSelection(-1);
	    	UI::SetThinSelector();

	   		return ok;
	    }

		void Select( CRules@ this, UI::Group@ group, UI::Control@ control )
		{
			Group@ oldGroup;
			control.vars.get( "activeGroup", @oldGroup );
			if (oldGroup !is null)
			{
				UI::Clear( group.name );
				@group.data.activeGroup = UI::getGroup( group.data, oldGroup.name ); // we get by name because somehow pointer changes (Angelscript WTF!?)
				UI::SetFont("menu");
			}
		}

		void RenderBackground( Proxy@ proxy )
		{
			GUI::DrawRectangle( Vec2f_zero, proxy.data.screenSize, color_black );
		}

		void Buy( CRules@ this, UI::Group@ group, UI::Control@ control )
		{
			Select( this, group, control );
			Game::CreateTimer("website", 0.5f, @Website, false);
		}		
	}
}

void Website(Game::Timer@ this)
{
	//getHUD().ShowCursor();
	OpenWebsite("https://trenchrun.thd.vg/");
}