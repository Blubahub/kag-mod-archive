// main menu skin

namespace UI
{
	namespace Button
	{
		void Render( Proxy@ proxy )
		{
			if (proxy.frames.length > 0){
				GUI::DrawIcon( proxy.image, proxy.frames[0], proxy.imageSize, (proxy.ul + proxy.lr)/2 - proxy.imageSize/2, 0.5f );
			}
		}

		void SmallRender( Proxy@ proxy )
		{
		}		
	}
}