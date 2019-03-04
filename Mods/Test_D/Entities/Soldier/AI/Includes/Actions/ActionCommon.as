namespace Brain
{

	bool JustGo( CBlob@ blob, Vec2f point, const float horiz_thresh = 7.5f )
	{
		Vec2f mypos = blob.getPosition();
		const f32 horiz_distance = Maths::Abs(point.x - mypos.x);

		if (horiz_distance > horiz_thresh)
		{
			if (point.x < mypos.x) {
				blob.setKeyPressed( key_left, true );
			}
			else {
				blob.setKeyPressed( key_right, true );
			}

			if (blob.isOnWall()) {
				blob.setKeyPressed( key_jump, true );
			}

			return true;
		}

		return false;
	}

	void Face( CBlob@ blob, Vec2f pos )
	{
		// turn side
		Vec2f mypos = blob.getPosition();
		bool facingleft = blob.isFacingLeft();
		if (pos.x > mypos.x && facingleft){
			blob.setKeyPressed( key_left, false );
			blob.setKeyPressed( key_right, true );
		}
		else if (pos.x < mypos.x && !facingleft){
			blob.setKeyPressed( key_right, false );
			blob.setKeyPressed( key_left, true );
		}
	}

}