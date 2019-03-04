#include "UI.as"

namespace UI
{
	funcdef void PROXY_RENDER_FUNCTION(Proxy@);
	funcdef void PROXY_UPDATE_FUNCTION(Proxy@);

	shared class Proxy
	{
		Vec2f ul;
		Vec2f lr;
		f32 Z;
		bool selected;
		string caption;
		string image;
		Vec2f imageSize;
		u8 frameTime;
		array<u8> frames;
		Vec2f align;
		string font;

		bool disabled;

		bool dead;
		int timeOut;

		PROXY_RENDER_FUNCTION@ renderFunc;
		PROXY_UPDATE_FUNCTION@ updateFunc;

		Group@ group;
		Control@ control;
		Data@ data;

		Vec2f transitionOffset;
		Vec2f transition_ul;
		Vec2f transition_lr;

		Proxy(PROXY_RENDER_FUNCTION@ _renderFunc, PROXY_UPDATE_FUNCTION@ _updateFunc,
		      Data@ _data, Group@ _group, Control@ _control, const f32 _Z)
		{
			@renderFunc = _renderFunc;
			@updateFunc = _updateFunc;
			@group = _group;
			@control = _control;
			@data = _data;
			Z = _Z;

			dead = false;
			timeOut = 0;

			frameTime = 0;
			frames.clear();
			frames.push_back(0);

			disabled = false;
			selected = false;
			font = data.font;
		}

		int opCmp(const Proxy &in other) const
		{
			return other.Z > Z ? -1 : 0;
		}
	};

	// add

	Proxy@ AddProxy(Data@ data, PROXY_RENDER_FUNCTION@ _renderFunc, PROXY_UPDATE_FUNCTION@ _updateFunc,
	                Group@ _group, Control@ _control, const f32 _Z)
	{
		Proxy proxy(_renderFunc, _updateFunc, _group.data, _group, _control, _Z);
		data.proxies.push_back(proxy);
		return data.proxies[ data.proxies.length - 1 ];
	}

	void RemoveProxies(Data@ data, Group@ group = null)
	{
		// remove proxy
		for (uint pIt = 0; pIt < data.proxies.length; pIt++)
		{
			Proxy@ proxy = data.proxies[ pIt ];

			if (group is null || group is proxy.group)
			{
				@proxy.group = null;
				@proxy.control = null;
			}
		}
	}

	void RemoveProxies(Data@ data, Control@ control)
	{
		// remove proxy
		for (uint pIt = 0; pIt < data.proxies.length; pIt++)
		{
			Proxy@ proxy = data.proxies[ pIt ];

			if (proxy.control is control)
			{
				@proxy.group = null;
				@proxy.control = null;
			}
		}
	}

	// helpers


	void CalcGroupPosition(Group@ group, Vec2f &out absoluteLeft, Vec2f &out absoluteRight)
	{
		if (group is null)
			return;

		absoluteLeft = getAbsolutePosition(group.upperLeft, group.data.screenSize);
		absoluteRight = getAbsolutePosition(group.lowerRight, group.data.screenSize);
	}

	void SetupTransition(Proxy@ proxy, Vec2f offset)
	{
		offset.Normalize();
		proxy.transitionOffset.Set(-offset.x * proxy.data.screenSize.x, -offset.y * proxy.data.screenSize.y);
	}


	void CalcGroupPosition(Group@ group, Proxy@ proxy)
	{
		if (group is null || proxy is null)
			return;

		CalcGroupPosition(group, proxy.ul, proxy.lr);
	}

	void CalcControlPosition(Group@ group, Proxy@ proxy, const int x, const int y)
	{
		if (group is null || group.columns == 0 || group.rows == 0 || proxy is null || group.proxy is null)
			return;

		Vec2f groupSize(group.proxy.lr.x - group.proxy.ul.x, group.proxy.lr.y - group.proxy.ul.y);
		Vec2f controlsize(groupSize.x / float(group.columns), groupSize.y / float(group.rows));
		Vec2f controlPos(group.proxy.ul.x + x * controlsize.x, group.proxy.ul.y + y * controlsize.y);
		proxy.ul = controlPos;
		proxy.lr = controlPos + controlsize;
	}

	// temp:
	// default group render

	void UpdateGroup(Proxy@ proxy)
	{
		if (proxy.group is null)
		{
			proxy.dead = true;
		}

		else
		{
			CalcGroupPosition(proxy.group, proxy);
		}
	}

	void RenderGroup(Proxy@ proxy)
	{
		DrawGroup(proxy.ul, proxy.lr);
	}
}