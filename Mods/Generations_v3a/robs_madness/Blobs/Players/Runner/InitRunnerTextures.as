#include "PixelOffsets.as"
#include "RunnerTextures.as"


void onInit(CSprite@ this)
{
	string name = this.getBlob().getName();
	string CapsName = toUpper(name.substr(0, 1))+name.substr(1, name.length()-1);
	addRunnerTextures(this, name, CapsName);
}

void onPlayerInfoChanged(CSprite@ this)
{
	string name = this.getBlob().getName();
	string CapsName = toUpper(name.substr(0, 1))+name.substr(1, name.length()-1);
	ensureCorrectRunnerTexture(this, name, CapsName);
}

string toUpper(string char)
{
    if(char == "a")return "A";
	if(char == "b")return "B";
	if(char == "c")return "C";
	if(char == "d")return "D";
	if(char == "e")return "E";
	if(char == "f")return "F";
	if(char == "g")return "G";
	if(char == "h")return "H";
	if(char == "i")return "I";
	if(char == "j")return "J";
	if(char == "k")return "K";
	if(char == "l")return "L";
	if(char == "m")return "M";
	if(char == "n")return "N";
	if(char == "o")return "O";
	if(char == "p")return "P";
	if(char == "q")return "Q";
	if(char == "r")return "R";
	if(char == "s")return "S";
	if(char == "t")return "T";
	if(char == "u")return "U";
	if(char == "v")return "V";
	if(char == "w")return "W";
	if(char == "x")return "X";
	if(char == "y")return "Y";
	if(char == "z")return "Z";
    return char;
}