#include "UI.as"
#include "UICommonUpdates.as"

namespace UI
{
	namespace Button
	{
		Control@ Add(string caption, SELECT_FUNCTION@ select, PROXY_RENDER_FUNCTION@ renderFunc, 
			PROXY_RENDER_FUNCTION@ renderCaptionFunc, bool disabled = false, const f32 Z = 0.5f, const int iconFrame = -1)
		{
			Data@ data = getData();
			Control@ control = AddControl(caption);
			control.selectable = true;
			Proxy@ proxyButton = AddProxy(data, renderFunc, TransitionUpdate, data.activeGroup, control, Z);
			proxyButton.image = data.activeGroup.iconFilename;
			proxyButton.imageSize = data.activeGroup.iconSize;
			if (iconFrame > -1){
				proxyButton.frames.clear();
				proxyButton.frames.push_back(iconFrame);
			}
			proxyButton.disabled = disabled;


			Proxy@ proxy = AddProxy(data, renderCaptionFunc, TransitionUpdate, data.activeGroup, control, Z + 0.5f);
			proxy.align.Set(0.0f, 0.5f);
			proxy.disabled = disabled;
			@control.select = select;
			return control;
		}

		Control@ Add(string caption, SELECT_FUNCTION@ select, bool disabled = false, const f32 Z = 0.5f)
		{
			return Add(caption, select, Render, RenderCaption, disabled, Z);
		}

		Control@ AddIcon(string caption, SELECT_FUNCTION@ select, int iconFrame, bool disabled = false, const f32 Z = 0.5f)
		{
			return Add(caption, select, Render, RenderCaption, disabled, Z, iconFrame);
		}		
	}
}