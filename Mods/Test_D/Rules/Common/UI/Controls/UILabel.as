#include "UI.as"
#include "UICommonUpdates.as"

namespace UI
{
  namespace Label
  {
    Control@ Add( string caption, bool disabled = false, const f32 Z = 1.0f )
    {
      Data@ data = getData();
      Control@ control = AddControl( caption );
      control.selectable = false;
      Proxy@ proxy = AddProxy( data, Render, TransitionUpdate, data.activeGroup, control, Z );
      proxy.align.Set(0.0f, 0.5f);
      proxy.disabled = disabled;
      return control;
    }
  }
}