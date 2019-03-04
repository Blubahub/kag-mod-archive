// main menu skin

namespace UI
{
  namespace Label
  {
      void Render( Proxy@ proxy )
      {
            GUI::SetFont("hud");
            Vec2f dim;
            GUI::GetTextDimensions( proxy.caption, dim );
            Vec2f pos = proxy.ul;
            pos += Vec2f( proxy.align.x*(proxy.lr.x - proxy.ul.x), proxy.align.y*(proxy.lr.y - proxy.ul.y) - dim.y * 0.3f );
            GUI::DrawText( proxy.caption, pos, proxy.disabled ? CAPTION_DISABLE_COLOUR : CAPTION_COLOR );
      }
  }
}