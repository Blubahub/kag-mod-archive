#include "BackendCommon.as"

#define SERVER_ONLY

void onInit(CRules@ this)
{
	Backend::InitBackend(this);
}

void onTick(CRules@ this)
{
	if(!this.hasTag("use_backend"))
	{
		return;
	}

	Backend::Data@ backend = Backend::getBackend(this);
	if (backend is null || backend.requests.empty())
	{
		return;
	}

	u32 current_time = Time();
	for (uint i = 0; i < backend.requests.length; i++)
	{
		Backend::Request@ req = backend.requests[i];
		//check for a response
		string response = this.get_string(req.destination);
		if (response != "")
		{
			//parse the recieved data with the given parser
			if (req.parse !is null)
			{
				req.parse(req, response);
			}
			else
			{
				warn("Backend: parse function not found for : " + req.destination);
			}
			//call the registered callback
			if (req.callback !is null)
			{
				req.callback(this, req);
			}
			else
			{
				warn("Backend: callback function not found for : " + req.destination);
			}
			//remove the request. we're done with it
			backend.requests.removeAt(i--);
		}
		else if(current_time >= req.timeout_time)
		{
			//time is up
			//call the timeout callback and remove the request
			if (req.timeout !is null)
			{
				req.timeout(this, req);
			}
			backend.requests.removeAt(i--);
		}
	}
}