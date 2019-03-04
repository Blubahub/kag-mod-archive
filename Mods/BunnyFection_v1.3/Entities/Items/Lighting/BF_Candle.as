// BF_Candle script

namespace Light
{
enum State
{
    off = 0,
    on
}
}

const u8 candleLength = 60;

void onInit(CBlob@ this)
{
    CSprite@ sprite = this.getSprite();
    sprite.SetZ(2.0f);
    CSpriteLayer@ fire = sprite.addSpriteLayer("fire", "BF_Candle.png", 2, 8);
    if(fire !is null)
    {
        fire.addAnimation("fire", 3, true);
        int[] frames = {12,13,14};
        fire.animation.AddFrames(frames);
        fire.SetRelativeZ(4.0f);
        fire.SetVisible(true);
    }
    CSpriteLayer@ candle = sprite.addSpriteLayer("candle", "BF_Candle.png", 4, 8);
    if(candle !is null)
    {
        candle.addAnimation("candle", 0, false);
        int[] frames = {2,3,4};
        candle.animation.AddFrames(frames);
        candle.SetRelativeZ(3.0f);
        candle.SetVisible(true);
    }
    this.SetLightRadius(48.0f);
    this.SetLightColor(SColor(255, 255, 240, 171 ));
    this.SetLight(true);
    this.set_u8("LightState", Light::on);
    sprite.PlaySound("SparkleShort.ogg");
    this.Tag("dont deactivate");
    this.getCurrentScript().tickFrequency = 30;
    this.set_u8("candleTimer", 0);
    this.set_u8("candleMelt", 0);
}

void onTick(CBlob@ this)
{
    u8 candleTimer = this.get_u8("candleTimer");
    if (candleTimer < candleLength)
    {
        candleTimer++;
        this.set_u8("candleTimer", candleTimer);
        if (candleTimer == candleLength)
        {
            u8 candleMelt = this.get_u8("candleMelt") + 1;
            this.set_u8("candleMelt", candleMelt);
            CSprite@ sprite = this.getSprite();
            CSpriteLayer@ fire = sprite.getSpriteLayer("fire");
            CSpriteLayer@ candle = sprite.getSpriteLayer("candle");
            fire.SetOffset(Vec2f(0, candleMelt));
            candle.SetFrameIndex(candle.getFrameIndex() + 1);
            if (this.get_u8("candleMelt") > 2)
            {
                this.server_Die();
                this.getSprite().PlaySound("SparkleShort.ogg");
            }
            this.set_u8("candleTimer", 0);
        }
    }
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
    if (cmd == this.getCommandID("activate"))
    {
		CSprite@ sprite = this.getSprite();
		CSpriteLayer@ fire = sprite.getSpriteLayer("fire");
		u8 state = this.get_u8("LightState");

        if (state == Light::off)
        {
            fire.SetVisible(true);
            this.SetLight(true);
            this.set_u8("LightState", Light::on);
            this.getCurrentScript().tickFrequency = 30;
        }
        else
        {
            fire.SetVisible(false);
            this.SetLight(false);
            this.set_u8("LightState", Light::off);
            this.getCurrentScript().tickFrequency = 0;
        }
		sprite.PlaySound( "SparkleShort.ogg" );
    }
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return (byBlob.getTeamNum() == this.getTeamNum());
}