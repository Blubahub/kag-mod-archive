//Mana Obelisk code
#include "WizardCommon.as";

const s8 MAX_MANA = 60;
const s8 MANA_REGEN_RATE = 2;
const s8 MANA_GIVE_RATE = 10;

void onInit( CBlob@ this )
{
	this.Tag("mana obelisk");
	this.getSprite().SetZ(-100.0f);
	
	this.getShape().SetStatic(true);
	
	this.set_s8("mana", MAX_MANA);
	this.set_bool("give mana", false);
}

void onTick( CBlob@ this )
{
	s8 storedMana = this.get_s8("mana");

	// regen mana of wizards touching
	if (getGameTime() % getTicksASecond() == 0)
	{
		bool hasGivenManaThisFrame = false;		//to prevent multiple wizards from draining mana and causing bugs
		const uint count = this.getTouchingCount();
		for (uint step = 0; step < count; ++step)
		{
			if ( hasGivenManaThisFrame == true )
				break;
				
			CBlob@ touchBlob = this.getTouchingByIndex(step);
			if ( touchBlob !is null )
			{
				WizardInfo@ wiz;
				if ( touchBlob.get("wizardInfo", @wiz) )
				{
					this.set_bool("give mana", true);
					this.Sync("give mana", true);
					if ( this.get_bool("give mana") == true )
					{
						s32 wizMana = wiz.mana;
						s32 wizMaxMana = wiz.maxMana;
						if ( storedMana >= MANA_GIVE_RATE && wizMana < (wizMaxMana-MANA_GIVE_RATE) )
						{
							storedMana -= MANA_GIVE_RATE;
							wiz.mana = wizMana + MANA_GIVE_RATE;
							
							touchBlob.getSprite().PlaySound("ManaGain.ogg", 1.0f, 1.0f + XORRandom(2)/10.0f);
							
							if ( storedMana < MANA_GIVE_RATE )
								touchBlob.getSprite().PlaySound("ManaEmpty.ogg", 0.5f, 1.0f + XORRandom(2)/10.0f);
								
							hasGivenManaThisFrame = true;
						}
						this.set_bool("give mana", false);
					}
				}				
			}
		}
		
		if ( storedMana < MAX_MANA )
			storedMana += MANA_REGEN_RATE;
			
		this.set_s8("mana", storedMana);		
		this.Sync("mana", true);
	}
}

void onTick( CSprite@ this )
{
	f32 storedMana = this.getBlob().get_s8("mana");
	//print("obelisk mana: " + storedMana);
	
	f32 manaFraction = storedMana/MAX_MANA;
	if ( manaFraction > (5.0f/6.0f) )
		this.SetFrame(0);
	else if ( manaFraction > (4.0f/6.0f) )
		this.SetFrame(1);
	else if ( manaFraction > (3.0f/6.0f) )
		this.SetFrame(2);
	else if ( manaFraction > (2.0f/6.0f) )
		this.SetFrame(3);
	else if ( manaFraction > (1.0f/6.0f) )
		this.SetFrame(4);
	else
		this.SetFrame(5);
}