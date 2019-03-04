// Fog of war
#include "Consts.as"

//////////////////////////////////
// gathered out of  blobs
//  with tag occlude
//  - if occ radius prop exists
//    it's gathered as the radius
//    otherwise default is used.
//////////////////////////////////

const f32 DEFAULT_OCCLUDE_RADIUS = 100.0f;

shared class FogOccluder
{
	Vec2f pos;
	s32 team;
	f32 radius;

	FogOccluder(Vec2f _pos, s32 _team, f32 _radius = DEFAULT_OCCLUDE_RADIUS)
	{
		pos = _pos;
		team = _team;
		radius = _radius;
	}
};

////////////////////////////////////
// tick function stuff
////////////////////////////////////

void onTick(CRules@ this)
{
	CPlayer@ localplayer = getLocalPlayer();
	if (localplayer is null)
		return;

	const u8 localteam = localplayer.getTeamNum();
	CMap@ map = getMap();
	CBlob@[] blobs;
	if (getBlobs(@blobs))
	{
		CBlob@[] team;
		CBlob@[] otherteam;
		FogOccluder[] occluders;

		// clear visible tag
		for (uint i = 0; i < blobs.length; i++)
		{
			CBlob@ b = blobs[i];

			if (!this.get_bool("fog of war") ||
			        b.getTeamNum() >= 2 ||
			        b.hasTag("dead") ||
			        b.hasTag("visible") ||
			        localteam >= 2)
			{
				b.SetVisible(true);
				b.Tag("visible to team " + 0);
				b.Tag("visible to team " + 1);
				continue;
			}

			//gather occluders
			if (b.hasTag("occlude"))
			{
				if (b.exists("occ radius"))
				{
					occluders.push_back(FogOccluder(b.getPosition(), b.getTeamNum(), b.get_f32("occ radius")));
				}
				else
				{
					occluders.push_back(FogOccluder(b.getPosition(), b.getTeamNum()));
				}
			}

			b.SetVisible(false);
			b.Untag("visible to team " + 0);
			b.Untag("visible to team " + 1);

			if (b.getTeamNum() != localteam)
			{
				if (b.hasTag("player"))
				{
					otherteam.push_back(b);
				}
			}
			else
			{
				if (b.hasTag("player"))
				{
					team.push_back(b);
					b.getSprite().asLayer().SetColor(color_white);
					b.SetVisible(true);
				}
			}
		}

		// mark if visible by at least one team member

		CheckVisibility(team, blobs, occluders, localteam, true);
		CheckVisibility(otherteam, blobs, occluders, (localteam + 1) % 2, false);

		// set color and visibilty

		for (uint j = 0; j < blobs.length; j++)
		{
			CBlob@ o = blobs[j];

			const bool visible = o.getSprite().isVisible();
			o.SetVisible(true);
			CSpriteLayer@ as_layer = o.getSprite().asLayer();
			SColor color = as_layer.getColor();
			f32 f = 0.95f;
			as_layer.SetColor(visible ? color_white : SColor(255, color.getRed()*f, color.getGreen()*f, color.getBlue()*f));
			if (color.getRed() < 0.15f && !visible)
			{
				o.SetVisible(false);
			}
		}
	}
}

////////////////////////////////////
// check if something's within
// "screen distance"
////////////////////////////////////

bool isScreenDistance(Vec2f pos, Vec2f targetPos)
{
	return ((pos - targetPos).getLength() < Consts::SCREEN_DISTANCE + 30.0f);
}

////////////////////////////////////
//check if a given circle overlaps a given line segment
//TODO: move to some header :^)
//TODO: make faster version that avoids recalculating
//      tangent/normal each time
////////////////////////////////////
bool overlapsSegment(Vec2f circle, f32 radius,
                     Vec2f p1, Vec2f p2)
{
	Vec2f tangent = (p1 - p2); tangent.Normalize();

	Vec2f b = circle - p1;
	Vec2f c = circle - p2;

	f32 dot_ab = (tangent * b);
	f32 dot_ac = (tangent * c);

	bool result = false;

	//check if we're inside the segment
	s32 sign_ab = ((dot_ab > 0) ? 1 : -1);
	s32 sign_ac = ((dot_ac > 0) ? 1 : -1);
	if (sign_ab != sign_ac || dot_ab == 0.0f || dot_ac == 0.0f)
	{
		Vec2f normal = tangent.RotateBy(90.0f);

		f32 dot_bn = (normal * b);
		f32 abs_dot = Maths::Abs(dot_bn);

		result = (abs_dot < radius);
	}
	else
	{
		// we're outside the segment
		// so collide nearest point
		if (sign_ab < 0 && sign_ac < 0)
			result = ((circle - p2).LengthSquared() < (radius * radius));
		else
			result = ((circle - p1).LengthSquared() < (radius * radius));
	}
	return result;
}

////////////////////////////////////
// check if a line is occluded by
// given set of occluders
//
//	"expensive" - avoid calling too
//	often where possible.
////////////////////////////////////

bool IsOccluded(Vec2f start, Vec2f end, s32 ignoreteam, FogOccluder[]@ occluders)
{
	for (uint i = 0; i < occluders.length; i++)
	{
		FogOccluder@ occ = occluders[i];
		if (occ.team != ignoreteam &&
		        overlapsSegment(occ.pos, occ.radius, start, end))
		{
			return true;
		}
	}
	return false;
}

void CheckVisibility(CBlob@[]@ team, CBlob@[]@ other, FogOccluder[]@ occluders, const u8 myteam, const bool setvisible)
{
	CMap@ map = getMap();
	for (uint i = 0; i < team.length; i++)
	{
		CBlob@ teamie = team[i];
		Vec2f tpos = teamie.getPosition() + Vec2f(0.0f, teamie.hasTag("crouching") ? 0.0f : -teamie.getRadius());
		for (uint j = 0; j < other.length; j++)
		{
			CBlob@ o = other[j];
			if (o is teamie)
				continue;

			bool visible = isScreenDistance(tpos, o.getPosition());

			//bother checking?
			if (visible)
			{
				//check head position too if not crouching
				if (!o.hasTag("crouching"))
				{
					Vec2f endpos = o.getPosition() + Vec2f(0.0f, o.hasTag("crouching") ? 0.0f : -o.getRadius());

					visible =  !map.rayCastSolid(tpos, endpos) &&
					           !IsOccluded(tpos, endpos, myteam, occluders);
				}

				Vec2f endpos = o.getPosition();

				visible = visible || (!map.rayCastSolid(tpos, endpos) &&
				                      !IsOccluded(tpos, endpos, myteam, occluders));
			}

			if (visible)
			{
				if (setvisible)
				{
					o.SetVisible(true);
				}
				o.Tag("visible to team " + myteam);
			}
			else
			{
				o.Untag("visible to team " + myteam);
			}
		}
	}
}