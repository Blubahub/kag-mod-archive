// ShadowmanCommon.as

#include "PlacementCommon.as";
#include "CheckSpam.as";
#include "GameplayEvents.as";

const f32 allow_overlap = 2.0f;

shared class HitData
{
	u16 blobID;
	Vec2f tilepos;
};