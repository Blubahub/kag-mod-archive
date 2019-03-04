
#include "AbilityCommon.as"

#include "GenericAbilities.as"
#include "da.as"
#include "fa.as"
#include "ba.as"
#include "la.as"
#include "lta.as"
#include "dra.as"

Ability[] abilities = {
	
	//Ability order doesn't really matter, it just changes the position in the list.
	//HOWEVER, emote has to be first for reasons.
	Ability("Emote", @EatScript, @EmoteIcon, "emote_ability", "", false, "This will reset your hotbar slot to it's original emote.\n!!!"),
	Ability("Eat", @EatScript, @EatIcon, "eat_ability", "eat_cd", true, "Will attempt to eat anything you are holding."),
	
	//Current Ability orders:
	// Life
	// Death
	// Heat
	// Flow
	// Blood
	// Nature
	// Light
	// Dark
	
	
	///Life Abilities
	Ability("Life Link", @life_link, @life_link_icon, "life_link_ability", "link_cd", false,
	"Link your soul to a target near the mouse cursor.\nCast again to break the link.\nWarning: If you are soul linked to anything, you will both be able to see what the other sees.\nOnly you, your target and other life users will be aware of the link.\n\nTarget must have or be a soul, whether dead or alive."),
	Ability("Life Flow", @life_flow, @life_flow_icon, "life_flow_ability", "flow_cd", false,
	"This ability either extracts or injects life into your life link.\nToggle Order: Off -> Extract -> Off -> Inject -> Repeat"),
	Ability("'Wisp's Kiss'", @life_kiss, @life_kiss_icon, "life_kiss_ability", "kiss_cd", false,
	"Creates a small particle of life energy that homes to a nearby target and damages them, but also gives them 1 life energy.\n\nCosts 1 life energy."),
	
	Ability("Unnerving Burst", @life_burst, @life_burst_icon, "life_burst_ability", "burst_cd", false,
	"Shoots forward an orb of life that bursts into 8 smaller ones after a set distance.\n\nCosts 5 life energy."),
	Ability("Unnerving Falter", @life_falter, @life_falter_icon, "life_falter_ability", "falter_cd", false,
	"Shoots out 8 small life orbs, and causes all other life orbs to reverse direction.\n\nCosts 2 life energy."),
	Ability("Unnerving Force", @life_force_orb, @life_force_orb_icon, "life_force_orb_ability", "force_cd", false,
	"Shoots forward a large orb of life that pushes any other orbs that it passes near.\n\nCosts 1 life energy."),
	Ability("Unnerving Parting", @life_parting, @life_parting_icon, "life_parting_ability", "parting_cd", false,
	"Fires two large orbs upwards and causes all orbs of life to split into smaller ones.\n\nCosts 20 life energy."),
	Ability("Unnerving Globe", @life_globe, @life_globe_icon, "life_globe_ability", "globe_cd", false,
	"Shoots out a huge orb of life energy.\n\nCosts 5 life energy."),
	Ability("Unnerving Cage", @life_cage, @life_cage_icon, "life_cage_ability", "cage_cd", false,
	"Shoots out two large orbs of life energy which spawn smaller ones.\n\nCosts 50 life energy."),
	
	
	///Death abilities
	Ability("Ethereal Manifest", @deathly_manifest, @deathly_manifest_icon, "deathly_manifest_ability", "manifest_cd", false,
	"Your ghostly limbs gain form in the physical realm.\nReactivate to toggle off.\n\nThis ability drains ectoplasma quickly."),
	Ability("Ethereal Possession", @deathly_possess, @deathly_possess_icon, "deathly_possess_ability", "possess_cd", false,
	"This ability possesses a nearby vessel if you are ethereal, or vacates your current vessel otherwise."),
	Ability("Ethereal Sowing", @ethereal_sowing, @ethereal_sowing_icon, "ethereal_sowing_ability", "sow_cd", false,
	"Creates a seed of death, which attaches to an object with life. It will slowly siphon life and convert it into death.\nThe seed can be harvested with Ethereal Reap.\n\nRequires 10 ectoplasma."),
	Ability("Ethereal Reap", @ethereal_reap, @ethereal_reap_icon, "ethereal_reap_ability", "reap_cd", false,
	"Throws out an ethereal scythe which harvests all ectoplasma and seeds of death.\nThe scythe will return to you and persist afterwards, allowing you to cast this ability on a shorter cooldown.\n\nWhen manifested, this ability instead spawns a manifested scythe in your main hand.\nIf you manifest while you have an ethereal scythe, the scythe will manifest and immediatlly fly to your hand, damaging anything in it's path.\nIf you stop manifesting, your scythe will become ethereal again.\n\nRequires 100 ectoplasma to summon the scythe the first time, free use after that."),
	Ability("Ethereal Illusion", @ethereal_illusion, @ethereal_illusion_icon, "ethereal_illusion_ability", "illusion_cd", false,
	"Creates a temporary illusion of you. Recasting this ability will switch place with your illusion.\n\nRequires 10 ectoplasma to spawn the illusion."),
	
	
	
	///Searing abilities
	Ability("Searing Intake", @searing_intake, @searing_intake_icon, "searing_intake_ability", "transfuse_cd", false,
	"Draw in heat from nearby sources.\n\nHeat can only be held in your body for a short period before it begins pouring out, damaging you."),
	Ability("Searing Bolt", @searing_bolt, @searing_bolt_icon, "searing_bolt_ability", "fire_bolt_cd", false,
	"Shoots out an orb of flame.\n\nRequires 10 heat."),
	Ability("Searing Vent", @searing_vent, @searing_vent_icon, "searing_vent_ability", "vent_cd", false,
	"Slowly vent out heat in a control manner.\nStops heat escaping your body from harming you."),
	Ability("Searing Discharge", @searing_discharge, @searing_discharge_icon, "searing_discharge_ability", "discharge_cd", false,
	"Cause nearby fire to explode."),
	Ability("Searing Nova", @searing_nova, @searing_nova_icon, "searing_nova_ability", "nova_cd", false,
	"Expell all heat in nova around yourself."),
	//Blazing Abilities
	Ability("Blazing Trail", @blazing_trail, @blazing_trail_icon, "blazing_trail_ability", "trail_cd", false,
	"Leave a trail of fire as you walk."),

	
	
	///Blood abilities
	Ability("Hemoric Yank", @hemoric_yank, @hemoric_yank_icon, "hemoric_yank_ability", "yank_cd", false,
	"Yanks blood out of nearby bleeding targets.\n\nRequires a nearby 'donor'."),
	Ability("Hemoric Healing", @hemoric_healing, @hemoric_healing_icon, "hemoric_healing_ability", "healing_cd", true,
	"Rapidly heals your body using blood.\n\nRequires minimum 50 blood."),
	Ability("Hemoric Growth", @hemoric_growth, @hemoric_growth_icon, "hemoric_growth_ability", "restore_cd", true,
	"Fully restores a missing limb.\n\nRequires minimum 100 blood, 50 blood and a missing limb."),
	Ability("Hemoric Strengthening", @hemoric_strength, @hemoric_strength_icon, "hemoric_strength_ability", "strength_cd", true,
	"Strengthens your limbs, allowing you to hit harder.\nMelee attacks deal 150% damage.\n\nRequires minimum 50 blood."),
	Ability("Hemoric Congealing", @hemoric_armour, @hemoric_armour_icon, "hemoric_armour_ability", "armour_cd", true,
	"Forms and hardens blood around your waist and torso, forming a sturdy armour.\n\nRequires a free torso or legs slot.\nRequires 50 blood per armour made."),
	Ability("Hemoric Adaption", @hemoric_wings, @hemoric_wings_icon, "hemoric_wings_ability", "armour_cd", true,
	"Grows a pair of wings on your back, allowing flight.\nThis cannot be undone and prevents you from wearing anything on your back.\n\nRequires 200 blood."),
	Ability("'Pins and Needles'", @hemoric_spikes, @hemoric_spikes_icon, "hemoric_spikes_ability", "spikes_cd", false,
	"Creates a spike at cursor location. Can be recast to create multiple spikes.\nOne second after the last spike is created, this ability can be cast again to fire the spikes in the cursor's direction.\n\nRequires 5 blood per spike, increased by 1 for each extra spike created."),
	
	
	///Light abilities
	Ability("Bright Restoration", @light_heal, @light_heal_icon, "light_heal_ability", "heal_cd", false,
	"Restores user.\nRestoration will attempt to restore things to it's original state.\nThis generally results in healing, but can have other unintended side effects.\n\nRequires 50 light."),
	Ability("Bright Beacon", @light_orb, @light_orb_icon, "light_orb_ability", "orb_cd", false,
	"Creates a small orb which lights the area around it.\n\nRequires 50 light."),
	Ability("'Heavensward'", @light_recall, @light_recall_icon, "light_recall_ability", "recall_cd", false,
	"An emergency recall.\n\nRequires 100 light."),
	Ability("'Plain Sight'", @light_invis, @light_invis_icon, "light_invis_ability", "illusion_cd", true,
	"Allows you to bend light around yourself, cloaking you from the sight of others.\nBeware those who can see more than just light.\n\nRequires 5 light a second."),
	Ability("Dim Redemption", @light_redemption, @light_redemption_icon, "light_redemption_ability", "redemption_cd", false,
	"Creates redeeming halo which disperses the first spirit it comes into contact with.\nIf the player controlling the spirit has no lives left, they shall be granted one so they may respawn immediatly.\n\nRequires 100 light."),
	
	///Dark Abilities
	Ability("Shadow Blade", @dark_blade, @dark_blade_icon, "dark_blade_ability", "blade_cd", false,
	"Form an incredibly strong sword.\n\nCosts 100 darkness."),
	Ability("Dark Growth", @dark_growth, @dark_growth_icon, "dark_growth_ability", "restore_cd", true,
	"Creates a weak shadow copy of a missing limb.\n\nCosts 50 darkness."),
	Ability("'Nothing to Fear'", @dark_recall, @dark_recall_icon, "dark_recall_ability", "recall_cd", false,
	"Immediatly teleports you to a dark area.\n\nCosts 20 darkness."),
	Ability("'Punching Shadows'", @dark_fade, @dark_fade_icon, "dark_fade_ability", "fade_cd", true,
	"Enter the shadows for a short while.\nAllows you to fly and move through walls.\n\nCosts 10 darkness."),
	Ability("Shadow Pearl", @dark_pearl, @dark_pearl_icon, "dark_pearl_ability", "orb_cd", false,
	"Forms a pearl of pure darkness.\nThe pearl can be used to gain 80-90 darkness.\n\nCosts 100 darkness."),
	
	///Forms
	Ability("Form: Pyromaniac", @form_pyro, @form_pyro_icon, "form_pyro_ability", "", false,
	"Set your body permanantly on fire, causing your body to become extremely hot providing you with ample heat.\nThis will kill you.\n\nRequires 50 heat."),
	//Ability("Form: Mouse", @hemoric_morph, @hemoric_morph_icon, "hemoric_morph_ability", "morph_cd",
	//"Transform into a small mouse.\nIf you have wings, instead transform into a bat."),
	Ability("Form: Wisp", @form_wisp, @form_wisp_icon, "form_wisp_ability", "wisp_cd", false,
	"Your soul exits your body in the form of a wisp."),
	
	///Summons
	Ability("Summon: Wisp", @summon_wisp, @summon_wisp_icon, "summon_wisp_ability", "wisp_cd", false,
	"Summon a wisp born of your own soul.\nHuman-born wisps will behave differently to nature-born wisps, in that they are inherent and innate allies to humans.\n\nCosts 50 life energy."),
	Ability("Summon: Spirit", @summon_spirit, @summon_spirit_icon, "summon_spirit_ability", "spirit_cd", false,
	"Creates a small spirit who guards an area for you, providing sight and draining life from intruders.\n\nRequires 50 ectoplasma."),
	Ability("Summon: Sun", @summon_sun, @summon_sun_icon, "summon_sun_ability", "sun_cd", false,
	"Collects heat above the atmosphere and drops it as a massive star to earth.\n\nRequires 100 heat."),
	Ability("Summon: Seeker", @light_wisp, @light_wisp_icon, "light_wisp_ability", "seeker_cd", false,
	"Creates a wisp of pure light which seeks out the nearest evil thing.\n\nRequires 100 light."),
	Ability("Summon: Golden Fish", @light_fish, @light_fish_icon, "light_fish_ability", "fish_cd", false,
	"Creates a small golden fish that follows you.\nWarning: do not let humans eat or touch golden fishes.\n\nRequires 100 light."),
	
	
	///Infusions
	Ability("Infuse: Soul", @soul_infuse, @soul_infuse_icon, "soul_infuse_ability", "transfuse_cd", false,
	"Transfers your soul and life energy to whatever you are life linked to, allowing you to control it.\nYou cannot soul transfer to something that has a soul already."),
	Ability("Infuse: Life", @life_infuse, @life_infuse_icon, "life_infuse_ability", "transfuse_cd", false,
	"Store some life into a held object.\nThis causes the object to float and allows you to life link to it.\n\nRequires 10 life energy."),
	Ability("Infuse: Ectoplasm", @deathly_infuse, @deathly_infuse_icon, "deathly_infuse_ability", "transfuse_cd", false,
	"Infuse ectoplasma into the object you're currently holding.\nInfused items gain ethereal properties, allowing them to affect ethereal targets, or deal more damage to manifested ones.\nInfused items will become ethereal with ghosts, allowing them to stay equipped in ghost form.\n\nRequires 50 ectoplasma."),
	Ability("Infuse: Heat", @searing_infuse, @searing_infuse_icon, "searing_infuse_ability", "transfuse_cd", false,
	"Infuse heat into the object you're currently holding, allowing it to be retrieved later.\nThis will most likely set the object on fire and/or melt it.\n\nRequires at least 1 heat, will attempt to infuse as much heat as the object can hold."),
	Ability("Infuse: Blood", @hemoric_infuse, @hemoric_infuse_icon, "hemoric_infuse_ability", "transfuse_cd", false,
	"Put a blood curse on the item you're holding.\nCursed items cannot be unequipped.\n\nRequires 20 blood."),
	Ability("Infuse: Light", @light_infuse, @light_infuse_icon, "light_infuse_ability", "transfuse_cd", false,
	"Bless an object with light.\nThis causes gold to float and makes any damage the item deals 'restore' the target instead.\n\nRequires 100 light."),
	Ability("Infuse: Darkness", @dark_infuse, @dark_infuse_icon, "dark_infuse_ability", "transfuse_cd", false,
	"Curse an object with darkness.\nCursed items corrupt wielders and nearby victims.\n\nRequires 100 light."),
};
