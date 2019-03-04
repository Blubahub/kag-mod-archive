E_ACTIONKEYS getActionKeyFromString( const string &in name )
{
    if (name == "ACTION 1"){
		return AK_ACTION1;
	} else if (name == "ACTION 2"){
		return AK_ACTION2;
	} else if (name == "LEFT"){
		return AK_MOVE_LEFT;
	} else if (name == "RIGHT"){
		return AK_MOVE_RIGHT;
	} else if (name == "UP"){
		return AK_MOVE_UP;
	} else if (name == "DOWN"){
		return AK_MOVE_DOWN;
	} else if (name == "JUMP"){
		return AK_JUMP;
	} else if (name == "CROUCH"){
		return AK_CROUCH;
	}
	return AK_NUM;
}