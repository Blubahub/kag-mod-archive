#include "Logging.as"
#include "Hitters.as"

const float DAMAGE_GOALTENDER_DISTANCE = 32.0;
const float DAMAGE_GOALTENDER_AMOUNT = 0.25;
const int DAMAGE_GOALTENDER_FREQ = 20;

void onInit(CBlob @ this)
{
    printf("Basketball Hoop onInit");
    this.getShape().SetStatic(true);
    float x = this.getPosition().x;
    float mapWidth = getMap().tilemapwidth * 8;
    if (x < mapWidth/2.0)
        this.Tag("basket1");
    else {
        this.Tag("basket2");
        this.SetFacingLeft(true);
        this.getShape().SetPosition(Vec2f(x + 16.0, this.getPosition().y));
    }

    // Add basket rim to shape
    {
        Vec2f[] shape = {
            Vec2f(15.0, -2.0),
            Vec2f(18.0, -2.0),
            Vec2f(18.0, 4.0),
            Vec2f(15.0, 4.0)
        };
        this.getShape().AddShape(shape);
    }

    // Add backboard
    {
        Vec2f[] shape = {
            Vec2f(-4.0, -15.0),
            Vec2f(-2.0, -15.0),
            Vec2f(-2.0, 4.0),
            Vec2f(-4.0, 4.0)
        };
        this.getShape().AddShape(shape);
    }
}

void onTick(CBlob@ this)
{
    //printf("Basketball Hoop onTick");
    CBlob@ basketball = getBlobByName("basketball"); 
    //log("onTick", "facing left: " + this.isFacingLeft());
    if (basketball !is null) {
        checkForBasket(this, basketball);
    }
    else {
        log("onTick", "No basketball found!");
    }

    if (getRules().getCurrentState() == GAME && getGameTime() % DAMAGE_GOALTENDER_FREQ == 0) {
        damageNearbyPlayers(this);
    }
}

void checkForBasket(CBlob@ this, CBlob@ basketball) {
    u32 lastBasketTime = getRules().get_u32("last basket time");
    if (getGameTime() - lastBasketTime < 30)
        return;

    float dist = this.getDistanceTo(basketball);

    if (dist < 32.0) {
        float x = this.getPosition().x;
        float y = this.getPosition().y;
        float width = this.getShape().getWidth();
        //log("onTick", "Ball is near");
        Vec2f[] aboveRegion = {Vec2f(0,0), Vec2f(0,0)};
        Vec2f[] belowRegion = {Vec2f(0,0), Vec2f(0,0)};
        if (!this.isFacingLeft()) { 
            aboveRegion[0] = Vec2f(x,y-8);
            aboveRegion[1] = Vec2f(x+width, y);
            belowRegion[0] = Vec2f(x,y);
            belowRegion[1] = Vec2f(x+width, y+8);
        }
        else {
            aboveRegion[0] = Vec2f(x-width,y-8);
            aboveRegion[1] = Vec2f(x, y);
            belowRegion[0] = Vec2f(x-width,y);
            belowRegion[1] = Vec2f(x, y+8);
        }

        Vec2f ballPos = basketball.getPosition();
        if (doesRegionContainPoint(belowRegion, ballPos)) {
            //log("onTick", "Ball is in below region");

            // Check if the basketball passed from above to below
            if (basketball.hasTag("above basket")) {
                ScoreBasket(this, basketball);
            }
        }

        if (doesRegionContainPoint(aboveRegion, ballPos)) {
            //log("onTick", "Ball is in above region");
            basketball.Tag("above basket");
        }
        else {
            basketball.Untag("above basket");
        }
    }
}

void damageNearbyPlayers(CBlob@ this) {
    // Prevent goal-tending
    CBlob@[] players;
    getBlobsByTag("player", players);
    
    for (int i=0; i < players.length; i++) {
        CBlob@ player = players[i];
        float dist = this.getDistanceTo(player);

        if (dist < DAMAGE_GOALTENDER_DISTANCE) {
            this.server_Hit(player, this.getPosition(), Vec2f(0,0), DAMAGE_GOALTENDER_AMOUNT, Hitters::bite);
        }
    }
}

bool doesRegionContainPoint(Vec2f[] region, Vec2f point) {
    // Region should be in format [top left, bottom right]
    float top = region[0].y;
    float left = region[0].x;
    float bot = region[1].y;
    float right = region[1].x;

    float x = point.x;
    float y = point.y;
    /*
    log("doesRegionContainPoint", "top: " + top +
            ", bot: " + bot + 
            ", left: " + left + 
            ", right: " + right + 
            ", x: " + x + 
            ", y: " + y); 
            */
    return left < x && x < right && top < y && y < bot;
}

void ScoreBasket(CBlob@ this, CBlob@ basketball) {
    log("ScoreBasket", "Function called");
    CBitStream params;
    u8 basketNum = this.hasTag("basket1") ? 1 : 2;
    u8 points = 2;
    params.write_u8(basketNum);
    params.write_u8(points);
	if (basketball.getDamageOwnerPlayer() !is null) {
		params.write_string(basketball.getDamageOwnerPlayer().getUsername());
	}
	else {
		params.write_string("__noplayer__");
	}

    getRules().SendCommand(getRules().getCommandID("score basket"), params);
    CBlob@[] princesses; 
    getBlobsByName("princess", princesses);
    for (int i=0; i < princesses.length; i++) {
        CBlob@ princess = princesses[i];
        princess.SendCommand(princess.getCommandID("score basket"), params);
    }
    this.getSprite().PlaySound("crowd_cheer.ogg");
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
    printf("Basketball Hoop onCollision");
	if (solid && blob !is null)
	{
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
    printf("Basketball Hoop onHit");
	return 0; // invincible
}
