void DrawOverlay(const string file, const SColor color = SColor(255, 255, 255, 255))
{
    CFileImage@ image = CFileImage(file);
    f32 width = image.getWidth();
    f32 height = image.getHeight();
   
    f32 s_width = getScreenWidth() * 0.50f;
    f32 s_height = getScreenHeight() * 0.50f;
   
    GUI::DrawIcon(file, 0, Vec2f(width, height), Vec2f(0, 0), s_width/width, s_height/height, color);
}