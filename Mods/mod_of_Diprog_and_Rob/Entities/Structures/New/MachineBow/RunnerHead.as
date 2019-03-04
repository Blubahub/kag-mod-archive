const s32 NUM_HEADFRAMES = 4;
s32 NUM_UNIQUEHEADS = 30;
const int FRAMES_WIDTH = 8 * NUM_HEADFRAMES;

int getHeadFrame( CBlob@ blob, int headIndex )
{
	return (((headIndex-NUM_UNIQUEHEADS/2) * 2) + ( blob.getSexNum() == 0 ? 0 : 1))*NUM_HEADFRAMES;
}

CSpriteLayer@ LoadHead( CSprite@ this, u8 headIndex, string texname )
{
    this.RemoveSpriteLayer( "head" );
    // add head
	
    CSpriteLayer@ head = this.addSpriteLayer( "head", texname, 16, 16,
                         this.getBlob().getTeamNum(),
                         this.getBlob().getSkinNum() );
    CBlob@ blob = this.getBlob();
	
	if (texname == "GUI/NewHeads.png") NUM_UNIQUEHEADS = 100;
	else NUM_UNIQUEHEADS = 30;
    // set defaults
    if (headIndex == 255)
    {
        if (blob.getConfig() == "builder") {
            headIndex = NUM_UNIQUEHEADS;
        }
        else if (blob.getConfig() == "knight") {
            headIndex = NUM_UNIQUEHEADS+1;
        }
        else if (blob.getConfig() == "archer") {
            headIndex = NUM_UNIQUEHEADS+2;
        }
        if (blob.getConfig() == "migrant") {
            headIndex = 69+XORRandom(2); //head scarf or old
        }
        else { //default to builder head
            headIndex = NUM_UNIQUEHEADS;
        }
    }									 
	s32 headFrame = getHeadFrame(blob, headIndex);
    if(headIndex < NUM_UNIQUEHEADS)
		headFrame = headIndex * NUM_HEADFRAMES;

	if (blob.hasTag("custom_head")) blob.set_s32("head index", blob.get_u32("new_head"));	 
	else blob.set_s32("head index", headFrame );	
    if (head !is null)
    {
        Animation@ anim = head.addAnimation( "default", 0, false );
        anim.AddFrame(headFrame);
        anim.AddFrame(headFrame+1);
        anim.AddFrame(headFrame+2);
        head.SetAnimation( anim );

		head.SetFacingLeft(blob.isFacingLeft());
    }
	return head;
}

void onGib( CSprite@ this )
{
    if (g_kidssafe) {
        return;
    }

    CBlob@ blob = this.getBlob();
	if ( blob !is null && blob.getName() != "bed" )
    {
		int frame = blob.get_s32("head index");
        int framex = frame % FRAMES_WIDTH;
        int framey = frame / FRAMES_WIDTH;
		
		Vec2f pos = blob.getPosition();
		Vec2f vel = blob.getVelocity();
		f32 hp = Maths::Min(Maths::Abs(blob.getHealth()),2.0f) + 1.5;
		if (blob.hasTag("custom_head")) makeGibParticle( "GUI/NewHeads.png",
										 pos, vel + getRandomVelocity( 90, hp , 30 ),
										 framex, framey, Vec2f (16,16),
										 2.0f, 20, "/BodyGibFall", blob.getTeamNum() );
		else makeGibParticle( "Heads.png",
			 pos, vel + getRandomVelocity( 90, hp , 30 ),
			 framex, framey, Vec2f (16,16),
			 2.0f, 20, "/BodyGibFall", blob.getTeamNum() );
    }
}

void onTick( CSprite@ this )
{
    CBlob@ blob = this.getBlob();
    
	ScriptData@ script = this.getCurrentScript();
	if (script is null)
		return;

    if(blob.getShape().isStatic())
    {
		script.tickFrequency = 60;
	}
	else
	{
		script.tickFrequency = 1;
	}

    
    // head animations
    CSpriteLayer@ head = this.getSpriteLayer( "head" );	 
	// load head when player is set or it is AI
	const u16 divinghelmet = blob.getBlobCount("divinghelmet");
	if (head is null && blob.getPlayer() !is null && divinghelmet > 0)
		  @head = LoadHead( this, 13, "Head.png"  );	
	else if (head is null && blob.getPlayer() !is null && blob.getPlayer().getUsername() == "Diprog")
	{
		  @head = LoadHead( this, 46, "GUI/NewHeads.png"  );
		  blob.set_u32("new_head", 46);
		  blob.Tag("custom_head");
	}
    else if (head is null && blob.getPlayer() !is null && blob.getPlayer().getUsername() == "RichardSTF")
    {
          @head = LoadHead( this, 43, "GUI/NewHeads.png"  );
          blob.set_u32("new_head", 43);
          blob.Tag("custom_head");
    }
	else if (head is null && blob.getPlayer() !is null && blob.getPlayer().getUsername() == "RaptorAnton")
	{
		@head = LoadHead( this, 47, "GUI/NewHeads.png"  );
		blob.set_u32("new_head", 47);
		blob.Tag("custom_head");
	}
	else if (head is null && (blob.getPlayer() !is null || (blob.getBrain() !is null && blob.getBrain().isActive()) || blob.getTickSinceCreated() > 3)){
		  @head = LoadHead( this, blob.getHeadNum(), "Head.png"  );		  
	}

	if (blob !is null && blob.hasTag("custom_head"))
		@head = LoadHead( blob.getSprite(), blob.get_u32("new_head"), "GUI/NewHeads.png");
	
    if (head !is null)
    {
        // set the head offset and Z value according to the pink/yellow pixels
        PixelOffset @po = getDriver().getPixelOffset( this.getFilename(), this.getFrame() );

        if (po !is null)
        {
            // behind, in front or not drawn
            if (po.level == 0)
            {
                head.SetVisible( false );
            }
            else
            {
                head.SetVisible( this.isVisible() );
                head.SetRelativeZ( po.level * 0.25f );
            }

            // set the proper offset
            Vec2f headoffset( this.getFrameWidth()/2, -this.getFrameHeight()/2 );
            headoffset += this.getOffset();
            headoffset += Vec2f( -po.x, po.y );
            headoffset += Vec2f( 0, -2 );
            head.SetOffset( headoffset );
			
			Vec2f pos = blob.getPosition();
			Vec2f aimpos = blob.getAimPos();
			
			Vec2f vec = aimpos - pos;
			if(this.isFacingLeft()) vec.x = -vec.x;
			else vec.Set(vec.x, -vec.y);
			
			f32 angle = vec.Angle();
			angle = (angle < 150) && (angle > 15) ? angle = 15 : (angle > 150) && (angle < 345) ? angle = 345 : angle = angle;

            if (blob.hasTag("dead") || blob.hasTag("dead head"))
            {
                head.animation.frame = 2;

				// sparkle blood if cut throat
				if (getNet().isClient() && getGameTime() % 2 == 0 && blob.hasTag("cutthroat"))
				{
					Vec2f vel = getRandomVelocity(90.0f, 1.3f * 0.1f*XORRandom(40), 2.0f);
					ParticleBlood( blob.getPosition()+Vec2f(this.isFacingLeft() ? headoffset.x : -headoffset.x, headoffset.y), vel, SColor(255, 126,0,0) );
					if (XORRandom(100) == 0)
						blob.Untag("cutthroat");
				}
            }
            else if (blob.hasTag("attack head"))
            {
                head.animation.frame = 1;
				head.ResetTransform( );
				head.RotateBy( angle, Vec2f(headoffset.x, headoffset.y + 10) );
            }
            else
            {
                head.animation.frame = 0;
				head.ResetTransform( );
				head.RotateBy( angle, Vec2f(headoffset.x, headoffset.y + 11) );
            }
        }
        else {
            head.SetVisible( false );
        }
    }
}
