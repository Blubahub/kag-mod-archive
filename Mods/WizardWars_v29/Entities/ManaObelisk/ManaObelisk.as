//Mana Obelisk code
#include "MagicCommon.as";

const s8 MAX_MANA = 60;
const s8 MANA_REGEN_RATE = 1;
const s8 MANA_GIVE_RATE = 10;

void onInit( CBlob@ this )
{
	this.Tag("mana obelisk");
	this.getSprite().SetZ(-100.0f);
	
	this.getShape().SetStatic(true);
	
	this.set_s8("mana", MAX_MANA);
	
	this.addCommandID("sync mana");
}

void onTick( CBlob@ this )
{
	// regen mana of wizards touching
	if (getGameTime() % getTicksASecond() == 0)
	{
		if (getNet().isServer())
		{
			SyncMana( this );
		}

		s8 storedMana = this.get_s8("mana");
	
		bool hasGivenManaThisFrame = false;		//to prevent multiple wizards from draining mana and causing bugs
		const uint count = this.getTouchingCount();
		for (uint step = 0; step < count; ++step)
		{
			if ( hasGivenManaThisFrame == true )
				break;
				
			CBlob@ touchBlob = this.getTouchingByIndex(step);
			if ( touchBlob !is null )
			{
				ManaInfo@ manaInfo;
				if ( touchBlob.get("manaInfo", @manaInfo) )
				{
					s32 wizMana = manaInfo.mana;
					s32 wizMaxMana = manaInfo.maxMana;
					if ( storedMana >= MANA_GIVE_RATE && wizMana < (wizMaxMana-MANA_GIVE_RATE) )
					{
						storedMana -= MANA_GIVE_RATE;
						manaInfo.mana = wizMana + MANA_GIVE_RATE;
						
						touchBlob.getSprite().PlaySound("ManaGain.ogg", 1.0f, 1.0f + XORRandom(2)/10.0f);
						
						if ( storedMana < MANA_GIVE_RATE )
							touchBlob.getSprite().PlaySound("ManaEmpty.ogg", 0.5f, 1.0f + XORRandom(2)/10.0f);
							
						hasGivenManaThisFrame = true;
					}
				}				
			}
		}
		
		if ( storedMana < MAX_MANA )
			storedMana += MANA_REGEN_RATE;
			
		this.set_s8("mana", storedMana);	
	}
}

void SyncMana( CBlob@ this )
{
	s8 mana = this.get_s8("mana");
	CBitStream bt;
	bt.write_s8( mana );	
	this.SendCommand( this.getCommandID("sync mana"), bt );
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if( cmd == this.getCommandID("sync mana") )
    {
		s8 mana;	
		mana = params.read_s8();	
		this.set_s8("mana", mana);
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