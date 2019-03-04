// main menu skin

namespace UI
{
	namespace Image
	{
		void Render( Proxy@ proxy )
		{
			u8 frame = proxy.frameTime == 0 ? proxy.frames[0] : proxy.frames[(getGameTime() / proxy.frameTime) % proxy.frames.length];
			GUI::DrawIcon( proxy.image, frame, proxy.imageSize, (proxy.ul + proxy.lr)/2 - proxy.imageSize/2, 0.5f );
		}
	}
}