// item description

const string[] descriptionsOld = {
    /* 00  */               "",
    /* 01  */               "Bombs for KNIGHT only.",   // bomb
    /* 02  */               "Arrows for archer and mounted bow.",         // arrows
    /* 03  */               "Grow Bisons!",           			// 
    /* 04  */               "Highly explosive powder keg for KNIGHT only.",                  // keg
    /* 05  */               "A stone throwing, ridable siege engine, requiring a crew of two.", // catapult
    /* 06  */               "A bolt-firing pinpoint accurate siege engine, requiring a crew of two. Allows respawn and class change.",     //ballista
    /* 07  */               "Raw stone material.",                                        // stone
    /* 08  */               "Raw wood material.",                                           // wood
    /* 09  */               "Lanterns help with mining in the dark, and lighten the mood.",                         // lantern
    /* 10  */               "A small boat with two rowing positions and a large space for cargo.",     // dinghy
    /* 11  */               "A siege engine designed to break open walls and fortifications.",         // ram
    /* 12  */               "A mill saw turns tree logs into wood material.",                             // saw
    /* 13  */               "A trading post. Requires a trader to reside inside.", // tradingpost
    /* 14  */               "Grow Sharks!",  // excalibur
    /* 15  */               "Piercing bolts for ballista.", // mat_bolts
    /* 16  */               "A simple wooden ladder for climbing over defenses.", // ladder
    /* 17  */               "A stone boulder useful for crushing enemies.", // boulder
    /* 18  */               "An empty wooden crate for storing and transporting inventory.", // crate
    /* 19  */               "An explosive powder keg.", // keg
    /* 20  */               "A land or water mine. Explodes on contact with enemy.", // mine
    /* 21  */               "Fire satchel for KNIGHT only.", // satchel
    /* 22  */               "A health regenerating heart.", // heart
    /* 23  */               "A sack for storing more inventory on your back.", // sack
    /* 24  */               "A seedling of an oak tree ready for planting.", // tree_bushy
    /* 25  */               "A seedling of a pine tree ready for planting.", // tree_pine
    /* 26  */               "A decorative flower seedling.", // flower
    /* 27  */               "Grain used as food.", // grain
    /* 28  */               "Wooden swing door.", // wooden_door
    /* 29  */               "Stone spikes used as a defense around fortifications.", // spikes
    /* 30  */               "A trampoline used for bouncing and jumping over enemy walls.", // trampoline
    /* 31  */               "A stationary arrow-firing death machine.", // mounted_bow
    /* 32  */               "Fire arrows used to set wooden structures on fire.", // fire arrows
    /* 33  */               "A fast rowing boat used for quickly getting across water.", // longboat
    /* 34  */               "A tunnel for quick transportation.", // tunnel
    /* 35  */               "Offer 300 wood to rescue a trader, who offers stone and gold for wood.", //
    /* 36  */               "Bucket for storing water. Useful for fighting fires.", //bucket
	/* 37  */               "A slow armoured boat which acts also as a water base for respawn and class change.", // warboat
	/* 38  */               "A generic factory. Requires Research Room, technology upgrade and big enough population to produce items.", //
	/* 39  */               "Kitchen produces food which heal wounds. Requires food ingredients.", //  kitchen
	/* 40  */               "A plant nursery with grain, oak and pine tree seeds.", //  nursery
	/* 41  */               "Barracks allow changing class to Archer or Knight.", //  barracks
	/* 42  */               "A storage than can hold materials and items and share them with other storages.", //  storage
	/* 43  */               "A mining drill. Increases speed of digging and gathering stone immensely.", //  drill
	/* 44  */               "Bombs for knights & arrows for archers.\nAutomatically distributed on respawn.", //  military basics
	/* 45  */               "Items used for blowing stuff up.", //  explosives
	/* 46  */               "Items used for lighting stuff up.\nIncludes fire arrows, lantern for arrows and satchel for burning structures.", //  pyro
	/* 47  */               "Stone is refined here, yielding not only better quality of stone but also produces more stone as well.The stone refind here must be depleted so new stone can be made.", //  stone tech
	/* 48  */               "Gold is refined here, yielding not only better quality of gold but also produces more gold as well.The gold refined here must be depleted so new gold can be made.", //  dorm
	/* 49  */               "The fallen need to rest here.", //  research
	/* 50  */               "Water arrows for Archer. Can extinguish fires and stun enemies.",         // water arrows
	/* 51  */               "Bomb arrows for Archer.",         // bomb arrows
	/* 52  */               "Water bomb for KNIGHT. Can extinguish fires and stun enemies.",         // water bomb
	/* 53  */               "Water absorbing sponge. Useful for unflooding tunnels",         // sponge
	
	/* 54  */               "Builder workshop for building utilities and changing class to Builder",         // buildershop
	/* 55  */               "Knight workshop for building explosives and changing class to Knight",         // knightshop
	/* 56  */               "Archer workshop for building arrows and changing class to Archer",         // archershop
	/* 57  */               "Siege workshop for building wheeled siege engines",         // vehicleshop
	/* 58  */               "Naval workshop for building boats",         // boatshop
	/* 59  */               "Place of merriment and healing",         // quarters/inn
	/* 60  */               "When the village becomes a town a Town Center must be built.",         // quarters/inn
	/* 61  */               "No trees around and need wood? Well then, make a farm out of wood!",         // quarters/inn
	/* 62  */               "King's Hall only for kings!",         // quarters/inn
	/* 63  */               "Bomber factory for scouting and air warfare.",         // quarters/inn
};
