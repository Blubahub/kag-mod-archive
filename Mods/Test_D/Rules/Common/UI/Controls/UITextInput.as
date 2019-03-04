#include "UI.as"
#include "UICommonUpdates.as"
#include "KeysHelper.as"

namespace UI
{
	namespace TextInput
	{
		funcdef string SET_FUNC( const string &in );

		Control@ Add( const string &in caption, SET_FUNC@ setFunc, PROXY_RENDER_FUNCTION@ renderFunc, PROXY_RENDER_FUNCTION@ renderCaptionFunc,
					  const bool password = false, const uint maxChars = 0 )
	    {
	    	Data@ data = getData();
	    	Control@ control = AddControl( caption );
	    	control.selectable = true;
	    	@control.input = Input;
	    	@control.select = Select;
	    	control.vars.set( "set func", @setFunc );
	    	control.vars.set( "old caption", caption );
	    	control.vars.set( "password", password );
	    	control.vars.set( "max chars", maxChars );
	    	control.vars.set( "end input", 0 );
	    	control.vars.set( "end choice", 0 );
	   		AddProxy( data, Render, TransitionUpdate, data.activeGroup, control, 0.5f );
	   		Proxy@ proxy = AddProxy( data, RenderCaption, Update, data.activeGroup, control, 1.0f );
	   		proxy.align.Set(0.0f, 0.5f);
	   		return control;
	    }

		Control@ Add( const string &in caption, SET_FUNC@ setFunc, const bool password = false, const uint maxChars = 0 )
	    {
	    	return Add( caption, setFunc, Render, RenderCaption, password, maxChars );
	    }	    

		// TextInput Proxy callbacks

		void Update( Proxy@ proxy  )
		{
			TransitionUpdate( proxy );

			if (proxy.group !is null)
			{
				bool password;
				proxy.control.vars.get( "password", password );
				if (password){
					proxy.caption = "";
					for (uint i=0; i < proxy.control.caption.size(); i++)
						proxy.caption += "*";
				}
			}
		}

		void Input( Control@ control, const s32 key, bool &out ok, bool &out cancel )
		{
			ok = false;
			cancel = false;
			CControls@ controls = getControls();
			const bool shift = controls.isKeyPressed( KEY_LSHIFT ) || controls.isKeyPressed( KEY_RSHIFT ) || controls.isKeyPressed( KEY_SHIFT );
			const bool ctrl = controls.isKeyPressed( KEY_LCONTROL ) || controls.isKeyPressed( KEY_RCONTROL ) || controls.isKeyPressed( KEY_CONTROL )
							  || controls.isKeyPressed( 0x37 ) || controls.isKeyPressed( 0x55 ); // command on mac?
			const u32 time = getGameTime();
			u32 lastTime;
			s32 lastKey;
			s32 maxChars;
			s32 endInputTimer;
			control.vars.get("last key time", lastTime);
			control.vars.get("last key", lastKey);
			control.vars.get("max chars", maxChars);
			control.vars.get("end input", endInputTimer);
			controls.externalControl = true;

			// getFromClipboard
			
			if (endInputTimer > 0){
				endInputTimer--;
				control.vars.set( "end input", endInputTimer );
				if (endInputTimer == 0){
					controls.externalControl = false;
					int endChoice;
					control.vars.get("end choice", endChoice);
					endChoice == 1 ? ok = true : cancel = true;
				}
			}
			else if (lastKey != key || lastTime + 10 < time)
			{
				if (key == KEY_RETURN){
					SET_FUNC@ setFunc;
					control.vars.get("set func", @setFunc );
					if (setFunc !is null){
						control.caption = setFunc( control.caption );
					}
					Sound::Play("menuclick" );
					control.vars.set( "end input", 5 );
					control.vars.set( "end choice", 1 );
					controls.externalControl = false;
				}
				else if (key == KEY_ESCAPE){
					string oldCaption;
					control.vars.get( "old caption", oldCaption );
					control.caption = oldCaption;
					Sound::Play("back");
					control.vars.set( "end input", 5 );
					control.vars.set( "end choice", 2 );
				}
				else if (key == KEY_TAB){
					SET_FUNC@ setFunc;
					control.vars.get("set func", @setFunc );
					if (setFunc !is null){
						control.caption = setFunc( control.caption );
					}
					Sound::Play("menuclick" );
					control.vars.set( "end input", 5 );
					control.vars.set( "end choice", 1 );
					controls.externalControl = false;
					UI::SetNextSelection();
					
					Group@ activeGroup = control.group.data.activeGroup;
					if (activeGroup.activeControl !is null && activeGroup.activeControl.input !is null) // select text input
					{
						Select( getRules(), activeGroup, activeGroup.activeControl );
						activeGroup.editControl.vars.set("last key", KEY_TAB);	
						activeGroup.editControl.vars.set("last key time", lastTime + 100);			
					}
				}
				else if (key == KEY_BACK)
				{
					if (!control.caption.isEmpty()){
						control.caption.resize( control.caption.length()-1 );
					}
				}
				else if ((ctrl && (controls.isKeyPressed( KEY_KEY_V ) || controls.isKeyPressed( KEY_INSERT ))) // paste
						|| (shift && controls.isKeyPressed( KEY_INSERT ))
						)
				{
					if (maxChars == 0 || control.caption.size() + getFromClipboard().size() < maxChars) {
						control.caption += getFromClipboard();
					}
				}				
				else{
					if (maxChars == 0 || control.caption.size() < maxChars){
						control.caption += getCharFromKey(key, shift);
					}
				}
			}

			if (lastKey != key){
				control.vars.set("last key", key);
				control.vars.set("last key time", time);
			}
		}

		void Select( CRules@ this, UI::Group@ group, UI::Control@ control )
		{
			@group.editControl = control;
			// delete contents if dummy password
			bool password;
			control.vars.get( "password", password );
			if (password && control.caption.size() > 0) {
				control.caption = "";
			}			
		}
	}
}