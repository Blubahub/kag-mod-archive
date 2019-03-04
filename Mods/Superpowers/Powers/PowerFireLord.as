#include "Logging.as";
#include "RunnerCommon.as";
#include "FireCommon.as";
#include "Hitters.as";

// See HOTHOTHOT, IsFlammable, FireAnim

void onInit(CBlob@ this) {
	this.SetLight(true);
	this.Tag("fire source");
    this.Tag(spread_fire_tag);
    this.Tag(burning_tag);
    this.set_s16(burn_duration, 30000);
    this.set_s16(burn_timer, 30000);
	this.set_Vec2f("last burn pos", Vec2f(0,0));
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1) {
	if (blob !is null && blob.getShape().getConsts().isFlammable) {
		if (blob.getTeamNum() == this.getTeamNum())
			return;

		this.server_Hit(blob, point1, Vec2f(0,0), 0.01, Hitters::fire);
	}

	Vec2f lastBurnPos = this.get_Vec2f("last burn pos");
	getMap().server_setFireWorldspace(lastBurnPos, false);
	getMap().server_setFireWorldspace(this.getPosition(), true);
	this.set_Vec2f("last burn pos", this.getPosition());
}
