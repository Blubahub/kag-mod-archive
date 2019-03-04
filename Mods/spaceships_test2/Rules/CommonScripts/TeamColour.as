SColor getTeamColor( int team )
{
	SColor teamCol; //get the team colour of the attacker

	switch(team)
	{
	case 0: teamCol.set(0xff2cafde); break;

	case 1: teamCol.set(0xffd5543f); break;

	case 2: teamCol.set(0xff9dca22); break;

	case 3: teamCol.set(0xffd379e0); break;

	case 4: teamCol.set(0xfffea53d); break;

	case 5: teamCol.set(0xff2ee5a2); break;

	case 6: teamCol.set(0xff5f84ec); break;

	case 7: teamCol.set(0xffc4cfa1); break;

	case 8: teamCol.set(0xff2a2a2a); break;

	case 9: teamCol.set(0xfffefefe); break;

	case 10: teamCol.set(0xff4ffef8); break;

	case 11: teamCol.set(0xffd0fed9); break;

	case 12: teamCol.set(0xfffe2e96); break;

	case 13: teamCol.set(0xffbea3fe); break;

	case 14: teamCol.set(0xfffec1cb); break;

	case 15: teamCol.set(0xffacfe08); break;
	
	case 16: teamCol.set(0xff6b2951); break;

	case 17: teamCol.set(0xff186b58); break;

	case 18: teamCol.set(0xff656b2e); break;

	case 19: teamCol.set(0xff125f6b); break;

	case 20: teamCol.set(0xffeda094); break;

	case 21: teamCol.set(0xfffae9e6); break;

	case 22: teamCol.set(0xffffffff); break;

	case 23: teamCol.set(0xff00ff00); break;

	case 24: teamCol.set(0xff5937a8); break;

	default: teamCol.set(0xff888888);
	}
	return teamCol;
}
