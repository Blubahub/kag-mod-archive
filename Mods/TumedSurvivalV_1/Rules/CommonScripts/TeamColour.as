// KAG rp standard "www.tiny.cc/bkforum" // Version: "..\Scripts\rp.as" //

SColor getTeamColor( int team )
{
	SColor teamCol;

	switch(team)
	{
	case 0: teamCol.set(0xff2cafde); break; // Blue Race

	case 1: teamCol.set(0xffd5543f); break; // Red Race

	case 2: teamCol.set(0xff9dca22); break; // Green Race

	case 3: teamCol.set(0xffd379e0); break; // Violet Race

	default: teamCol.set(0xff888888);
	}
	return teamCol;
}