namespace UI
{
	void SetNoSelector()
	{
		UI::SetSelector("none", Vec2f( 0, 0 ));
	}

	void SetSmallSelector()
	{
		UI::SetSelector("Sprites/UI/mainmenu_selector_small.png", Vec2f( 74, 10 ));
	}

	void SetThinSelector()
	{
		UI::SetSelector("Sprites/UI/mainmenu_selector_thin.png", Vec2f( 124, 10 ));
	}

	void SetBigSelector()
	{
		UI::SetSelector("Sprites/UI/mainmenu_selector_big.png", Vec2f( 124, 25 ));
	}
}
