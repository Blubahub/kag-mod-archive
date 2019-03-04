//ss
//the frames for the factory/crate icons

namespace FactoryFrame {
	enum Frame {
		unknown = 0,
		
		longboat = 1,
		warboat = 2,
		
		bomber = 3, //NEW
		
		catapult = 4,
		ballista = 5,
		mounted_bow = 6,
		
		submarine = 7, //NEW
		saw = 8,
		drill = 9,
		dinghy = 10,
		
		shotgun_bow = 11,
		
		military_basics = 12,
		explosives = 13,
		pyro = 14,
		water_ammo = 15,
		
		boulder = 16,
		expl_ammo = 17,
		
		cannon = 19,
		
		wizard = 20, //NEW
		bison = 21, //NEW
		shark = 22, //NEW
		
		factory = 24,
		healing = 25,
		kitchen = 26,
		nursery = 27,
		tunnel = 28,
		storage = 29,
		
		//end of actual factory/crate icons
		count,
		
		//hack: these share above icons
		//but are used for scroll frame instead.
		magic_gib = 24,
		magic_midas,
		magic_drought,
		magic_flood,
	};
};
