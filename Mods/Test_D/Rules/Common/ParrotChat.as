#include "Pets.as"
#include "HoverMessage.as"

Random _pr(0x477);

u8 randomVowel()
{
	//biased towards front
	string[] vowels = {"a", "e", "o", "u", "i"};
	f32 chance = _pr.NextFloat() * _pr.NextFloat();
	return vowels[u32(chance * vowels.length)][0];
}

int FindRandomElement(string s, string[] elements)
{
	s = s.toLower();
	int start = _pr.NextRanged(elements.length);
	for (int i = 0; i < elements.length; i++)
	{
		int index = (i + start) % elements.length;
		int pos = ((i % 2) == 0) ? s.findFirst(elements[index]) : s.findLast(elements[index]);
		if (pos != -1)
			return pos;
	}
	return -1;
}

int FindRandomVowel(string s)
{
	string[] vowels = {"a", "e", "i", "o", "u"};
	return FindRandomElement(s, vowels);
}

int FindRandomCons(string s)
{
	string[] consonants = {"s", "l", "r", "n", "m", "d", "t", "w"};
	return FindRandomElement(s, consonants);
}

string Slur(string s, int amount)
{
	while (amount-- > 0)
	{
		//high chance to not modify anything per round
		//things get interesting once you've had lots
		if (_pr.NextFloat() < 0.85f)
			continue;

		f32 chance = _pr.NextFloat();

		//small chance that the entire word is replaced with a hiccup
		if(chance < 0.02f && amount >= 8)
		{
			int len = s.size();
			s = "";
			while (len > 0)
			{
				string hic = "*hic*";
				len -= hic.size();
				s += (s == "" ? "" : " ") + hic;
			}

			return s;
		}
		//vowels drawl and slur
		else if(chance < 0.85f)
		{
			int vpos = FindRandomVowel(s);
			if (vpos != -1)
			{
				chance = _pr.NextFloat();

				if (chance < 0.05f)
				{
					//swap with random vowel
					s[vpos] = randomVowel();
				}
				else if (chance < 0.80f || s.size() == 1)
				{
					//extend this vowel
					s = s.substr(0, vpos + 1) + s.substr(vpos, s.size() - vpos);
				}
				else
				{
					//drop vowel
					s = s.substr(0, vpos) + s.substr(vpos + 1, s.size() - vpos - 1);
				}
			}
		}
		else
		//some consonants repeat or drop (lisp and chatter and slur)
		{
			int cpos = FindRandomCons(s);
			if(cpos != -1)
			{
				chance = _pr.NextFloat();

				if (chance < 0.5f || s.size() == 1)
				{
					//repeat
					s = s.substr(0, cpos + 1) + s.substr(cpos, s.size() - cpos);
				}
				else
				{
					//drop
					s = s.substr(0, cpos) + s.substr(cpos + 1, s.size() - cpos - 1);
				}
			}
		}
	}
	return s;
}

bool onServerProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	// drunken chat

	CBlob@ blob = player.getBlob();
	if (blob !is null)
	{
		// if drunk

		int drunk_amount = blob.get_u8("drunk_amount");
		if (drunk_amount > 2)
		{
			int slur_amount = drunk_amount - 2;
			text_out = "";
			string[] words = text_in.split(" ");
			for (u32 i = 0; i < words.length; i++)
			{
				words[i] = Slur(words[i], slur_amount);
			}
			text_out = join(words, " ");
		}
	}

	return true;
}

// PARROT

string[] lines = {"%c's mother was a %n",
,"%c, your mother was a %n"
,"I kindly approve of your demise."
,"Not bad… for a village pillock."
,"%c, you have the charm of a dead %n."
,"%c, you have a smile of a simpleton."
,"I've known tables smarter than %c."
,"You don't frighten me, you donkey-faced pig %n."
,"%c smells like a %n in the rain."
,"Go and boil your bottoms, you sons of a silly person."
,"%c, you don't frighten me, you %n-brained plonker!"
,"Is there no beginning to your talents?"
,"%c is a spineless lumpsucker."
,"You probably think Sinai is the plural of sinus."
,"%c looks like a %n that's just been shown a card trick."
,"Thy tongue outvenoms all the worms of Nile."
,"I'll tickle your catastrophe!"
,"%c's wife's a hobby %n!"
,"Thine face is not worth sunburning."
,"%c's brain is as dry as a biscuit."
,"%c fights like a Dairy Farmer!"
,"%c, I've spoken with %n's more polite than you!"
,"%c, I once owned a %n that was smarter than you."
,"%c, every word you say to me is stupid."
,"%c, if your sister is like you, better to marry a %n."
};

string[] nouns = {"dog",
"hamster",
"rabbit",
"donkey",
"pig",
"baboon",
"horse",
"frog",
"sloth",
"pinguin"
};

int _lastSaidTime = 0;

CBlob@ getPlayerBlobNearby(CBlob@ parrot)
{
	CBlob@[] blobsInRadius;
	if (getMap().getBlobsInRadius(parrot.getPosition(), 100, @blobsInRadius))
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob @blob = blobsInRadius[i];
			if (blob.getName() == "soldier" && getPetOwner(parrot) !is blob)
			{
				return blob;
			}	
		}
	}
	return null;
}


bool onClientProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	// parrot chat

	if (getGameTime() -_lastSaidTime < 190)
		return true;

	CBlob@[] pets;
	getBlobsByName("pet", @pets);

	for (u32 i = 0; i < pets.length; i++)
	{
		CBlob@ parrot = pets[i];
		if (getPetType(parrot) == PARROT)
		{
			CBlob@ owner = getPetOwner(parrot);
			if (owner is player.getBlob())
			{
				string[] words = text_out.split(" ");
				if (words.length > 0)
				{
					parrot.getSprite().PlayRandomSound("ParrotSay");
					string say = words.length > 1 ? (words[ XORRandom(words.length - 1) ] + " " + words[words.length - 1]) : words[ XORRandom(words.length) ];
					AddMessageTimed(parrot, say, 150);
				}
			}
			else
			{
				CBlob@ playerBlob = getPlayerBlobNearby(parrot);
				if (playerBlob !is null)
				{
					parrot.getSprite().PlayRandomSound("ParrotSay");
					string say = lines[ XORRandom(lines.length) ];
					say = say.replace("%n", nouns[ XORRandom(nouns.length) ] );
					say = say.replace("%c", playerBlob.getPlayer() !is null ? playerBlob.getPlayer().getCharacterName() : "yo" );

					AddMessageTimed(parrot, say, 175);
				}
			}

			_lastSaidTime = getGameTime();
		}
	}


	return true;
}
