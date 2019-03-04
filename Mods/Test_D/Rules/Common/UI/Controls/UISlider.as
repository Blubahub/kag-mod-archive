#include "UI.as"
#include "UICommonUpdates.as"

namespace UI
{
	namespace Slider
	{
		funcdef float SLIDER_FUNC(float);

		Control@ Add(const string &in caption, SLIDER_FUNC@ setFunc, PROXY_RENDER_FUNCTION@ renderFunc, PROXY_RENDER_FUNCTION@ renderCaptionFunc,
		             float value, float increment, float min, float max, string currency = "")
		{
			Data@ data = getData();
			Control@ control = AddControl(caption);
			control.selectable = true;
			@control.select = Forward;
			@control.select2 = Backward;
			control.vars.set("set func", @setFunc);
			control.vars.set("value", value);
			control.vars.set("increment", increment);
			control.vars.set("min", min);
			control.vars.set("max", max);
			control.vars.set("currency", currency);
			AddProxy(data, renderFunc, TransitionUpdate, data.activeGroup, control, 0.5f);
			Proxy@ proxy = AddProxy(data, renderCaptionFunc, Update, data.activeGroup, control, 1.0f);
			proxy.align.Set(0.0f, 0.5f);
			return control;
		}

		Control@ Add(const string &in caption, SLIDER_FUNC@ setFunc, float value, float increment, float min, float max, string currency = "")
		{
			return Add(caption, setFunc, Render, RenderCaption, value, increment, min, max, currency);
		}

		void Update(Proxy@ proxy)
		{
			TransitionUpdate(proxy);

			if (proxy.control !is null)
			{
				float increment, value, min, max;
				string currency, caption;
				proxy.control.vars.get("value", value);
				proxy.control.vars.get("increment", increment);
				proxy.control.vars.get("min", min);
				proxy.control.vars.get("max", max);
				proxy.control.vars.get("currency", currency);
				proxy.caption = proxy.control.caption + ": " + Maths::Round(value) + "" + currency;

				if (currency == "/")
				{
					proxy.caption += max;
				}
			}
		}

		void Forward(CRules@ this, UI::Group@ group, UI::Control@ control)
		{
			Move(this, group, control, 1.0f);
		}

		void Backward(CRules@ this, UI::Group@ group, UI::Control@ control)
		{
			Move(this, group, control, -1.0f);
		}

		void Move(CRules@ this, UI::Group@ group, UI::Control@ control, const float direction)
		{
			float increment, value, min, max;
			control.vars.get("value", value);
			control.vars.get("increment", increment);
			control.vars.get("min", min);
			control.vars.get("max", max);
			value += direction * increment;

			if (value < min)
				value = max;

			if (value > max)
				value = min;

			SLIDER_FUNC@ setFunc;
			control.vars.get("set func", @setFunc);

			if (setFunc !is null)
			{
				value = setFunc(value);
			}

			control.vars.set("value", value);
		}
	}
}