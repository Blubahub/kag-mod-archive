#include "UI.as"
#include "UICommonUpdates.as"

namespace UI
{
	namespace Image
	{
		Proxy@ AddDefault(string filename)
		{
			Data@ data = getData();
			Control@ control = AddControl(filename);
			Proxy@ proxy = AddProxy(data, Render, NoTransitionUpdate, data.activeGroup, control, 1.5f);
			control.selectable = false;
			proxy.image = filename;		
			return proxy;	
		}

		Control@ Add(string filename)
		{
			Data@ data = getData();
			Proxy@ proxy = AddDefault(filename);
			GUI::GetImageDimensions(filename, proxy.imageSize);
			return proxy.control;
		}

		Control@ AddFramed(string filename, Vec2f imageSize, u8 frame)
		{
			Proxy@ proxy = AddDefault(filename);
			proxy.imageSize = imageSize;
			proxy.frames.clear();
			proxy.frames.push_back(frame);
			return proxy.control;
		}

		Control@ AddAnimated(string filename, Vec2f imageSize, array<u8> frames, u8 frameTime)
		{
			Proxy@ proxy = AddDefault(filename);
			proxy.imageSize = imageSize;
			proxy.frames = frames;
			proxy.frameTime = frameTime;
			return proxy.control;
		}

	}
}