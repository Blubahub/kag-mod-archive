//i just need to send note numbers when the key is pressed, and some enums and arrays for that

//so, i can form packets of all notes, or only 1 note

//also later you will need to stop player from acting while you play

//#include "Flute_layout.as";

namespace Layout
{
    enum LayoutNumbers
    {
    	piano = 0,
    	bayan,
    	guitar,
    	wicki
    }

}
namespace Instr
{
    enum InstrNumbers
    {
    	harp = 0,
    	banjo
    }

}

string[] instrument_names = {"harp","banjo"};
bool V = true;
bool X = false;
bool[][] soundfiles = { 
{V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V},//37 files, starting with 0
//{V,X,V,X,V,X,V,X,V,X,V,X,V,X,V,X,V,X,V,X,V,X,V,X,V,X,V,X,V,X,V,X,V,X,V,X,V}, //test
{V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V},

};


f32 half_step_F=1.059460646483;

/*u8[] layout_keys = 
{1,2,3,4,5,6,7,8,9,0,-,=,\,backspace,  //merge \ and backspace
Q,W,E,R,T,Y,U,I,O,P,{,},
A,S,D,F,G,H,J,K,L,:,'',
Z,X,C,V,B,N,M,<,>,?};
*/



u8[][] layout_keys = {
{KEY_KEY_1,KEY_KEY_2,KEY_KEY_3,KEY_KEY_4,KEY_KEY_5,KEY_KEY_6,KEY_KEY_7,KEY_KEY_8,KEY_KEY_9,KEY_KEY_0,189,187,220,
KEY_KEY_Q,KEY_KEY_W,KEY_KEY_E,KEY_KEY_R,KEY_KEY_T,KEY_KEY_Y,KEY_KEY_U,KEY_KEY_I,KEY_KEY_O,KEY_KEY_P,219,221,
KEY_KEY_A,KEY_KEY_S,KEY_KEY_D,KEY_KEY_F,KEY_KEY_G,KEY_KEY_H,KEY_KEY_J,KEY_KEY_K,KEY_KEY_L,186,222,
KEY_KEY_Z,KEY_KEY_X,KEY_KEY_C,KEY_KEY_V,KEY_KEY_B,KEY_KEY_N,KEY_KEY_M,188,190,191},

{0,0,0,0,0,0,0,0,0,0,0,0,8,
 0,0,0,0,0,0,0,0,0,0,0,0,
 0,0,0,0,0,0,0,0,0,0,0,
 0,0,0,0,0,0,0,0,0,0},

};

/*
'1'=0,'2'=1,'3'=2,'4'=3,'5'=4,'6'=5,'7'=6,'8'=7,'9'=8,'0'=9,'-'=10,'='=11,'\+backspace=12',
'Q'=13,'W'=14,'E'=15,'R'=16,'T'=17,'Y'=18,'U'=19,'I'=20,'O'=21,'P'=22,'{'=23,'}'=24,
'A'=25,'S'=26,'D'=27,'F'=28,'G'=29,'H'=30,'J'=31,'K'=32,'L'=33,':'=34,'''=35,
'Z'=36,'X'=37,'C'=38,'V'=39,'B'=40,'N'=41,'M'=42,'<'=43,'>'=44,'?'=45
*/


/*u8[] key_notes_piano = 
{KEY_KEY_Q,KEY_KEY_2,KEY_KEY_W,KEY_KEY_3,KEY_KEY_E,KEY_KEY_R,KEY_KEY_5,KEY_KEY_T,KEY_KEY_6,KEY_KEY_Y,KEY_KEY_7,KEY_KEY_U,
  KEY_KEY_I,KEY_KEY_9,KEY_KEY_O,KEY_KEY_0,KEY_KEY_P,219,187,221,220,KEY_KEY_Z,KEY_KEY_S,KEY_KEY_X,    //I,9,O,0,P,[,+,],|};
  KEY_KEY_C,KEY_KEY_F,KEY_KEY_V,KEY_KEY_G,KEY_KEY_B,KEY_KEY_N,KEY_KEY_J,KEY_KEY_M,KEY_KEY_K,188,KEY_KEY_L,190};*/

u8[] keys_piano_white = 
{14,15,16,17,18,19,20,21,22,23,24,25,
 37,38,39,40,41,42,43,44,45,46};

u8[] keys_piano_black = 
{1,2,3,4,5,6,7,8,9,10,11,12,13,
 26,27,28,29,30,31,32,33,34,35,36};
//0 will resemble no key from now on

/*u8[] keys_bayan = 
{KEY_KEY_Q,KEY_KEY_A,KEY_KEY_Z,KEY_KEY_W,KEY_KEY_S,KEY_KEY_X,KEY_KEY_E,KEY_KEY_D,KEY_KEY_C,KEY_KEY_R,KEY_KEY_F,KEY_KEY_V,
KEY_KEY_T,KEY_KEY_G,KEY_KEY_B,KEY_KEY_Y,KEY_KEY_H,KEY_KEY_N,KEY_KEY_U,KEY_KEY_J,KEY_KEY_M,KEY_KEY_I,KEY_KEY_K,188};
*/

u8[] keys_bayan = 
{1,14,26,2,15,27,3,16,28,4,17,29,5,18,30,7,19,31,8,20,32,9,21,33,10,22,34,11,23,35,12,23,36};


//after testing make it for guitar and wicki

/*
u8[][] key_notes_wicki = 
{{KEY_KEY_Q, KEY_KEY_5,KEY_KEY_W,KEY_KEY_6,KEY_KEY_E,KEY_KEY_7,KEY_KEY_R,KEY_KEY_2,KEY_KEY_T,KEY_KEY_3,KEY_KEY_Y,KEY_KEY_4,KEY_KEY_U,
  KEY_KEY_G,KEY_KEY_X,KEY_KEY_H,KEY_KEY_C,KEY_KEY_J,KEY_KEY_V,KEY_KEY_S,KEY_KEY_B,KEY_KEY_D,KEY_KEY_N,KEY_KEY_F,KEY_KEY_M},
 {0, 0,KEY_KEY_I,0,KEY_KEY_O,0,KEY_KEY_P,KEY_KEY_8,0,KEY_KEY_9,0,KEY_KEY_0,KEY_KEY_Z,
  0,188,0,190,0,191,KEY_KEY_K,0,KEY_KEY_L,0,186,0},

};*/

/*
u8[][] key_notes_wicki = 
{{2,0,3,0,4,Q,
  5,W,6,E,7,R,8,T,9,Y,KEY_KEY_0,U,
  G,I,H,O,J,P,K,B,L,N,:,M,
  0,<,0,>,0,?},
 {0,0,0,0,0,0,
  0,0,0,0,0,V,S,0,D,0,F,Z,
  0,X,0,C,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0},
  

 },

};
*/

u8[][] key_notes_wicki = 
{{KEY_KEY_2,0,KEY_KEY_3,0,KEY_KEY_4,KEY_KEY_Q,
  KEY_KEY_5,KEY_KEY_W,KEY_KEY_6,KEY_KEY_E,KEY_KEY_7,KEY_KEY_R,KEY_KEY_8,KEY_KEY_T,KEY_KEY_9,KEY_KEY_Y,KEY_KEY_0,KEY_KEY_U,
  KEY_KEY_G,KEY_KEY_I,KEY_KEY_H,KEY_KEY_O,KEY_KEY_J,KEY_KEY_P,KEY_KEY_K,KEY_KEY_B,KEY_KEY_L,KEY_KEY_N,186,KEY_KEY_M,
  0,188,0,190,0,191},
 {0,0,0,0,0,0,
  0,0,0,0,0,0,KEY_KEY_S,0,KEY_KEY_D,0,KEY_KEY_F,KEY_KEY_Z,
  0,KEY_KEY_X,0,KEY_KEY_C,0,KEY_KEY_V,0,0,0,0,0,0,
  0,0,0,0,0,0},
  

};

// Z,X,C,V,B,N,M,<,>,?
//           A,S,D,F,G,H,J,K,L,:,"
//                     Q,W,E,R,T,Y,U,I,O,P,{,}
//                               1,2,3,4,5,6,7,8,9,0,-,=, \+backspace



/*
u8[][] key_notes_guitar =    //Z = E1  ,A = A1, Q = D2, 1 = G2
{{ Z,X,C,V,B,N,M,<,
   >,?,H,J,K,L,:,'',U,I,O,P,
   {,},8,9,0,-,=,\ },   //  / = C#1, K = E2  
 { 0,0,0,0,0,A,S,D,
   F,G,Q,W,E,R,T,Y,2,3,4,5,
   6,7,0,0,0,0,0,8},
 { 0,0,0,0,0,0,0,0,
   0,0,0,0,0,0,0,Y,0,0,0,0,
   0,0,0,0,0,0,0,0,0},

};    */

u8[][] key_notes_guitar =    //Z = E1  ,A = A1, Q = D2, 1 = G2
{{ KEY_KEY_Z,KEY_KEY_X,KEY_KEY_C,KEY_KEY_V,KEY_KEY_B,KEY_KEY_N,KEY_KEY_M,188,
   190,191,KEY_KEY_H,KEY_KEY_J,KEY_KEY_K,KEY_KEY_L,186,222,KEY_KEY_U,KEY_KEY_I,KEY_KEY_O,KEY_KEY_P,
   219,221,KEY_KEY_8,KEY_KEY_9,KEY_KEY_0,189,187,220 },   //  / = C#1, K = E2  
 { 0,0,0,0,0,KEY_KEY_A,KEY_KEY_S,KEY_KEY_D,
   KEY_KEY_F,KEY_KEY_G,KEY_KEY_Q,KEY_KEY_W,KEY_KEY_E,KEY_KEY_R,KEY_KEY_T,KEY_KEY_Y,KEY_KEY_2,KEY_KEY_3,KEY_KEY_4,KEY_KEY_5,
   KEY_KEY_6,KEY_KEY_7,0,0,0,0,0,8},
 { 0,0,0,0,0,0,0,0,
   0,0,0,0,0,0,0,KEY_KEY_1,0,0,0,0,
   0,0,0,0,0,0,0,0,0},

};    


//[ - 219
//bool music_mode = false;
u8 music_mode_key = 192; //= KEY_; // 192 is tilde
//logic
void onInit(CBlob@ this)
{
	//AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");
	//if (ap !is null)
	//{
	//	ap.SetKeysToTake(key_action1 | key_action2 | key_action3);
	//}

    //u8[] keyboard = {KEY_KEY_Q,KEY_KEY_2,KEY_KEY_W,KEY_KEY_3,KEY_KEY_E};//continue later
    //key_notes_piano = keyboard;
    this.set_bool("music_mode", false);
    this.set_u8("layout_number", 0);
    this.set_u8("instr_number", 0);
    this.set_s8("octave_mod", 0);
    this.set_s8("key_shift", 0);
    this.set_u8("note", 0);
    this.set_u8("note_display_timer", 0);

	this.addCommandID("_note");

	this.getCurrentScript().runFlags |= Script::tick_attached;
}

shared void sendNote(CBlob@ this, u8 note, u8 instr_number)
{
	CBitStream stream;
	stream.write_u8(note);
	stream.write_u8(instr_number);
	this.SendCommand(this.getCommandID("_note"), stream);
}


void onTick(CBlob@ this)
{

	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	CBlob@ playerblob = point.getOccupied();
    if(playerblob is null)
	{ return; }

    CControls@ controls = playerblob.getControls();
    if(controls is null)
	{ return; }

    bool music_mode = this.hasTag("music_mode");
    if(controls.isKeyJustPressed(music_mode_key) || (controls.isKeyJustPressed(KEY_SPACE)/*&& !flute*/)) //|| controls.isKeyJustPressed(113)) //113 - F2
	{
			
		music_mode = !music_mode;
		if(music_mode)
            this.Tag("music_mode");
        else
            this.Untag("music_mode");
    } 

    if(music_mode)
        point.SetKeysToTake(0xFFFF);//key_up | key_down | key_left | key_right | key_action1 | key_action2 | key_action3 | key_use | key_inventory | key_pickup |);
    else
        point.SetKeysToTake(key_action1 | key_action2 | key_action3);


	if(!playerblob.isMyPlayer())
	{ return; }
	
	//bool music_mode = this.get_bool("music_mode");
	
	u8 layout_number = this.get_u8("layout_number");
	u8 instr_number = this.get_u8("instr_number");
	s8 octave_mod = this.get_s8("octave_mod");
	s8 key_shift = this.get_s8("key_shift");
	
    

    if(controls.isKeyJustPressed(163)) //163 - right CTRL
	{
        instr_number = (instr_number + 1)%(instrument_names.size());
        this.set_u8("instr_number", instr_number);
        print("instr_number = "+instr_number);
	}
        
    if(controls.isKeyJustPressed(162)) //162 - left CTRL
	{
        layout_number = (layout_number + 1)%(Layout::wicki+1);
        this.set_u8("layout_number", layout_number);
        this.set_s8("octave_mod", 0);
        this.set_s8("key_shift", 0);
        octave_mod = 0;
        key_shift = 0;
        print("layout_number = "+layout_number);
	}

    //debug:
        
    for(u8 i = 0; i <= KEY_OEM_CLEAR; i++)
    {
        if(controls.isKeyJustPressed(i))
            print("key_code = "+i ); // so tilde is 192
    }
        
	if(!music_mode)
	{  return; }

    if(layout_number == Layout::piano)
    {
    	if(controls.isKeyJustPressed(164)) //164 - left ALT
		{
			octave_mod = Maths::Max(octave_mod - 1, 0);
		}
		if(controls.isKeyJustPressed(165)) //165 - right ALT
		{
			octave_mod = Maths::Min(octave_mod + 1, 1);
		}
		this.set_s8("octave_mod", octave_mod);

		if(controls.isKeyJustPressed(120)) //120 - F9
		{
			key_shift = Maths::Max(key_shift - 1, -13);
		}
		if(controls.isKeyJustPressed(121)) //121 - F10
		{
			key_shift = Maths::Min(key_shift + 1, 13);
		}
        this.set_s8("key_shift", key_shift);

        s8 note_decrease = 0;//key_shift/7+(key_shift-3)/7;
        for(s8 i = 1; i <= key_shift; i++)
        {
            if(((i-1)%7==0 || (i-4)%7==0 )) note_decrease++;
        }
        //for(s8 i = -1; i > key_shift; i--)
        //{
        //    if(((i)%7==0 || (i-3)%7==0 )) note_decrease--;
        //}
        //if(key_shift > 0) note_decrease++;
        //else if(key_shift < 0) note_decrease--;
        //if((key_shift-3) > 0) note_decrease++;
        //else if((key_shift-3) < 0) note_decrease--;
		for(s8 i = 0; i < keys_piano_white.size(); i++)
		{

            s8 modified_key = i + key_shift;
            if( /*modified_key!=0 &&*/i >= -key_shift && ((modified_key)%7==0 || (modified_key-3)%7==0 )) note_decrease++;
            u8 j = 0;
		    for(;j<layout_keys.size()-1 && (!controls.isKeyJustPressed(layout_keys[j][keys_piano_white[i]-1]) || layout_keys[j][keys_piano_white[i]-1] == 0);j++){}
		    if(j == layout_keys.size() - 1) continue;
		    //s8 note_decrease = (i-key_shift)/7+(i-key_shift-3)/7;
		    s8 supposed_note = ((modified_key*2)+2-note_decrease)+octave_mod*12;
		    print("note_decrease = "+note_decrease);
		    //supposed_note = supposed_note - ((supposed_note)/7 + (supposed_note-3)/7);
		    if(supposed_note < 0) continue;
		    sendNote(this, supposed_note, instr_number);
		    playNote(this, instr_number, supposed_note, 1.0f);
		    //print("key_shift/7 = "+key_shift/7+" (key_shift-3)/7 = "+(key_shift-3)/7);
		}
		note_decrease = 0;
        for(s8 i = 1; i <= key_shift; i++)
        {
            if(((i-1)%7==0 || (i-4)%7==0 )) note_decrease++;
        }


		s8 merge_supp = 0;
		for(s8 i = 0; i < keys_piano_black.size(); i++)
		{
			s8 modified_key = i + key_shift;
			if(i == 13) merge_supp = 1;
			//s8 key_calc = ;
			if( i >= -key_shift && (modified_key-merge_supp)%7==0 || (modified_key-merge_supp-3)%7==0 ) 
			{
				note_decrease++;
			    continue;
		    }
            u8 j = 0;
		    for(;j<layout_keys.size()-1 && (!controls.isKeyJustPressed(layout_keys[j][keys_piano_black[i]-1]) || layout_keys[j][keys_piano_black[i]-1] == 0);j++){}
		    if(j == layout_keys.size() - 1) continue;
		    s8 supposed_note = (modified_key*2+1-note_decrease-merge_supp*2)+octave_mod*12;
		    if(supposed_note < 0) continue;
		    sendNote(this, supposed_note, instr_number);
		    playNote(this, instr_number, supposed_note, 1.0f);
		    //this.getSprite().PlaySound("note"+(i+1), 100);
		    //print("note = "+i);
		    //print("KEY_NUMPAD0 = "+KEY_NUMPAD0 + "KEY_NUMPAD1 = "+KEY_NUMPAD1);	
		}
	}
	else if(layout_number == Layout::bayan)
    {
    	if(controls.isKeyJustPressed(164)) //164 - left ALT
		{
			octave_mod = Maths::Max(octave_mod - 1, 0);
		}
		if(controls.isKeyJustPressed(165)) //165 - right ALT
		{
			octave_mod = Maths::Min(octave_mod + 1, 1);
		}
		this.set_s8("octave_mod", octave_mod);


        for(u8 i = 0; i < keys_bayan.size(); i++)
		{
			u8 j = 0;
		    for(;j<layout_keys.size()-1 && (!controls.isKeyJustPressed(layout_keys[j][keys_bayan[i]-1]) || layout_keys[j][keys_bayan[i]-1] == 0);j++){}
		    if(j == layout_keys.size() - 1) continue;
		    s8 supposed_note = i+1+octave_mod*12;
		    if(supposed_note < 0) continue;
		    sendNote(this, supposed_note, instr_number);
		    playNote(this, instr_number, supposed_note, 1.0f);
		}

        
	}
	else if(layout_number == Layout::guitar)
    {    	
    	if(controls.isKeyJustPressed(164)) //164 - left ALT
		{
			octave_mod = Maths::Max(octave_mod - 1, -2);
		}
		if(controls.isKeyJustPressed(165)) //165 - right ALT
		{
			octave_mod = Maths::Min(octave_mod + 1, 2);
		}
		this.set_s8("octave_mod", octave_mod);

		if(controls.isKeyJustPressed(120)) //120 - F9
		{
			key_shift = Maths::Max(key_shift - 1, 0);
		}
		if(controls.isKeyJustPressed(121)) //121 - F10
		{
			key_shift = Maths::Min(key_shift + 1, 3);
		}
        this.set_s8("key_shift", key_shift);

        for(u8 i = 0; i < key_notes_guitar[0].size(); i++)
		{
			for(u8 j = 0; j < 3 && key_notes_guitar[j][i] != 0; j++)
			{
				//print("i = "+i+" j = "+j);
		    	if(controls.isKeyJustPressed(key_notes_guitar[j][i]))
		    	{
		    		s8 supposed_note = i+5+(octave_mod*12)+key_shift*5;
		    		if(supposed_note < 0) continue;
		    		sendNote(this, supposed_note, instr_number);		    			        	
		        	playNote(this, instr_number, supposed_note, 1.0f);
                    break;
		    	}	
		    }
		}

        
	}
	else if(layout_number == Layout::wicki)
    {
    	if(controls.isKeyJustPressed(189)) //189 - -
		{
			octave_mod = Maths::Max(octave_mod - 1, 0);
		}
	    if(controls.isKeyJustPressed(219)) // {
		{
			octave_mod = 0;
		}
		if(controls.isKeyJustPressed(222)) // "
		{
			octave_mod = Maths::Min(octave_mod + 1, 1);
		}
		this.set_s8("octave_mod", octave_mod);


        for(u8 i = 0; i < key_notes_wicki[0].size(); i++)
		{
			for(u8 j = 0; j < 2 && key_notes_wicki[j][i] != 0; j++)
			{
				//print("i = "+i+" j = "+j);
		    	if(controls.isKeyJustPressed(key_notes_wicki[j][i]))
		    	{
		    		s8 supposed_note = i+(octave_mod*12)-5;
		    		if(0 <= supposed_note) //&& supposed_note <= 36)
		    		{
		        		sendNote(this, supposed_note, instr_number);
		        		playNote(this, instr_number, supposed_note, 1.0f);
                    	break;
                    }
		    	}	
		    }
		}
        
	}
	/*
	else if(layout_number == Layout::flute)
    {
    	if(controls.isKeyJustPressed(164)) 
		{
			octave_mod = Maths::Max(octave_mod - 1, 0);
		}
		if(controls.isKeyJustPressed(165)) // "
		{
			octave_mod = Maths::Min(octave_mod + 1, 1);
		}
		this.set_u8("octave_mod", octave_mod);

        if(!controls.isKeyJustPressed(flute_keys[0]) && !controls.isKeyJustPressed(flute_keys[1])) return;

        //bool to_play = false;
        for(u8 i = 0; i < key_notes_flute.size()-1; i++)
		{
			//print("i = "+ i +" size = "+key_notes_flute.size());
			if(!(key_notes_flute[i][0] && controls.isKeyJustPressed(flute_keys[0])) && !(key_notes_flute[i][1] && controls.isKeyJustPressed(flute_keys[1]))) continue;
            //print("yesh");
            u8 j = 2;
            for(; j < key_notes_flute[i].size() && (controls.isKeyPressed(flute_keys[j]) == key_notes_flute[i][j]); j++){}//print("j = "+j);}
            if(j == key_notes_flute[i].size())
            {
                u8 supposed_note = i+(octave_mod*12);
		       	sendNote(this, supposed_note, instr_number);
		       	playNote(this, instr_number, supposed_note, 1.0f);
                break;
            }
		}
        
	}*/

}


void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	if(point !is null)
	{
	    CBlob@ playerblob = point.getOccupied();
		if(cmd == this.getCommandID("_note") && playerblob !is null && !playerblob.isMyPlayer())
		{
			u8 note;
			u8 instr_number;
			if(!params.saferead_u8(note)) return;
			if(!params.saferead_u8(instr_number)) return;
        	//play sound
        	f32 distance = 0;
        	if(getLocalPlayerBlob() !is null)
        	{
        		Vec2f bucketpos = this.getPosition();
                Vec2f playerpos = getLocalPlayerBlob().getPosition();
        	    distance = Vec2f(bucketpos.x-playerpos.x,bucketpos.y-playerpos.y).Length();
        	}
        	f32 reduction = (distance/430);
            
        	playNote(this, instr_number, note, 1.0f-reduction);
		}
	}
}


void playNote(CBlob@ this, u8 instr_number, u8 note, f32 volume)
{
	this.set_u8("note",note);
    this.set_u8("note_display_timer",40);
    if(volume < 0.5f) return;
 
    f32 pitch = 1.0f;
    u8 supposed_note = note;
    if(supposed_note >= soundfiles[instr_number].size() || !soundfiles[instr_number][supposed_note])
	{
        u8 file_num = Maths::Min(supposed_note,soundfiles[instr_number].size() - 1);
        for(;!soundfiles[instr_number][file_num];file_num--){}
		u8 diff = supposed_note - file_num;
		for(u8 k = diff; k > 0; k--)
		    pitch = pitch*half_step_F;
		supposed_note = file_num;
	}	
    this.getSprite().PlaySound(instrument_names[instr_number]+(supposed_note), volume, pitch);
    //print("size = "+key_notes_wicki.size());//debug

}


//sprite

/*
void onInit(CSprite@ this)
{
	this.SetAnimation("empty");
	if (this.getBlob().get_u8("filled") > 0)
	{
		this.SetAnimation("full");
	}
}