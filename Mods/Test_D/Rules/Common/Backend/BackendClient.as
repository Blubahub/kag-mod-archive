#include "BackendCommon.as"

string _reconnectAddress = "";

void onInit(CRules@ this)
{
	this.addCommandID("redirect");
}

void onTick(CRules@ this)
{
	if (_reconnectAddress != "")
	{
		CNet@ net = getNet();
		string temp = _reconnectAddress;
		_reconnectAddress = "";
		printf("Client: SafeConnect by backend");
		net.SafeConnect(temp);
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream @params)
{
	//printf("backendclient cmd: " + cmd + " " + this.getCommandID("redirect") + " " + getNet().isClient());
	if (getNet().isClient() && cmd == this.getCommandID("redirect"))
	{
		string address = params.read_string();
		CPlayer@ player = getPlayerByNetworkId(params.read_netid());
		if (player !is null && player.isMyPlayer())
		{
			print("Backend redirecting to " + address);
			_reconnectAddress = address;
		}
	}
}
