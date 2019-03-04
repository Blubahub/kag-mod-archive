namespace UI
{
	void NoTransitionUpdate(Proxy@ proxy)
	{
		if (proxy.group is null)
		{
			proxy.dead = true;
		}
		else
		{
			CalcControlPosition(proxy.group, proxy, proxy.control.x, proxy.control.y);
		}
	}

	void TransitionUpdate(Proxy@ proxy)
	{
		if (proxy.group is null)
		{
			if (proxy.timeOut++ >= 10)
			{
				proxy.dead = true;
			}
			else
			{
				proxy.Z -= 1.0f;
				proxy.transitionOffset.Normalize();
				proxy.transitionOffset *= 0.1f * proxy.timeOut * proxy.data.screenSize.getLength();
			}
		}
		else
		{
			CalcControlPosition(proxy.group, proxy, proxy.control.x, proxy.control.y);

			proxy.selected = proxy.group.data.activeGroup is proxy.group && proxy.group.activeControl is proxy.control;
			proxy.caption = proxy.control.caption;
			proxy.transition_lr = proxy.lr;
			proxy.transition_ul = proxy.ul;

			const f32 len = proxy.transitionOffset.getLength();

			if (len > 3)
			{
				proxy.transitionOffset *= 0.8f + len / 10000.0f;
			}
		}

		proxy.ul = proxy.transition_ul + proxy.transitionOffset;
		proxy.lr = proxy.transition_lr + proxy.transitionOffset;
	}

	void RenderCaption(Proxy@ proxy)
	{
		Vec2f dim;
		GUI::GetTextDimensions(proxy.caption, dim);
		Vec2f pos = proxy.ul;
		pos += Vec2f(proxy.align.x * (proxy.lr.x - proxy.ul.x), proxy.align.y * (proxy.lr.y - proxy.ul.y) - dim.y * 0.3f);

		GUI::DrawText(proxy.caption, pos, proxy.disabled ? CAPTION_DISABLE_COLOUR : proxy.selected ? CAPTION_HOVER_COLOR : CAPTION_COLOR);
	}
}