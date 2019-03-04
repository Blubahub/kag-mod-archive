

class ControlRod{

	int Temperature;
	int Coolent;
	f32 RodIntegrity;
	int RodPower;
	
	ControlRod(){
		this.Temperature = 0;
		this.Coolent = 0;
		this.RodIntegrity = 0.0f;
		this.RodPower = 0;
	}
	
	void AddRod(){
		this.RodIntegrity = 100.0f;
		this.RodPower = 10000;
	}

}