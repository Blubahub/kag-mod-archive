#include "SeatsCommon.as"
#include "VehicleAttachmentCommon.as"
#include "VehicleCommon.as"

void Vehicle_SimulateControl( CBlob@ this, VehicleInfo@ v, string buttonPressed )
{
    v.move_direction = 0;   
    AttachmentPoint@[] aps;      
    if (this.getAttachmentPoints( @aps ))
    {
        for (uint i = 0; i < aps.length; i++)
        {
            AttachmentPoint@ ap = aps[i];
            CBlob@ blob = ap.getOccupied();

            if (blob !is null && ap.socket)
            {
                // GET OUT
                if (blob.isMyPlayer() && ap.isKeyJustPressed( key_up))
                {
                    CBitStream params;
                    params.write_u16( blob.getNetworkID() );
                    this.SendCommand( this.getCommandID("vehicle getout"), params );
                    return;
                } // get out

                // DRIVER

                if (!this.hasTag("immobile"))
                {
                    bool left;
                    bool right;
                    bool moveUp = false;
                    const f32 angle = this.getAngleDegrees();
                    // set facing
                    blob.SetFacingLeft( this.isFacingLeft() );
                    if (buttonPressed == "left") left = true;
                    else left = false;
                    
                    if (buttonPressed == "right") right = true;
                    else right = false;
                    
                    const bool onground = this.isOnGround();
                    const bool onwall = this.isOnWall();
                    
                    // left / right
                    if (angle < 80 || angle > 290)
                    {
                        f32 moveForce = v.move_speed;
                        f32 turnSpeed = v.turn_speed;
                        Vec2f groundNormal = this.getGroundNormal();
                        Vec2f vel = this.getVelocity();
                        Vec2f force;

                        // more force when starting
                        if (this.getShape().vellen < 0.1f) {
                            moveForce *= 10.0f;
                        }

                        // more force on boat
                        if (!this.isOnMap() && this.isOnGround()) {
                            moveForce *= 1.5f;
                        }

                        bool slopeangle = (angle > 15 && angle < 345 && this.isOnMap());

                        Vec2f pos = this.getPosition();

                        if (left)
                        {
                            if (onground && groundNormal.y < -0.4f && groundNormal.x > 0.05f && vel.x < 1.0f && slopeangle) { // put more force when going up
                                force.x -= 6.0f * moveForce;
                            }
                            else {
                                force.x -= moveForce;
                            }

                            if (vel.x < -turnSpeed) {
                                this.SetFacingLeft( true );
                            }

                            if (onwall) {
                                moveUp = true;
                            }
                        }

                        if (right)
                        {
                            if (onground && groundNormal.y < -0.4f && groundNormal.x < -0.05f && vel.x > -1.0f && slopeangle) { // put more force when going up
                                force.x += 6.0f * moveForce;
                            }
                            else {
                                force.x += moveForce;
                            }

                            if (vel.x > turnSpeed) {
                                this.SetFacingLeft( false );
                            }

                            if (onwall)
                                moveUp = true;
                        }

                        force.RotateBy(this.getShape().getAngleDegrees());
                                    
                        if ((onwall /*|| (angle < 351 && angle > 9)*/) && (right || left))
                        {
                            Vec2f end;
                            Vec2f forceoffset( (this.isFacingLeft() ? this.getRadius() : -this.getRadius()) * 0.5f, 0.0f);
                            Vec2f forcepos = pos + forceoffset;
                            bool rearHasGround = this.getMap().rayCastSolid( pos, forcepos +Vec2f(0.0f, this.getMap().tilesize * 3.0f), end );
                            if (rearHasGround) {
                                this.AddForceAtPosition(Vec2f(0.0f, -290.0f), pos + Vec2f(-forceoffset.x, forceoffset.y)*0.2f);
                            }
                        }

                        this.AddForce(force);
                    }
                    else
                        if (left || right) {
                            moveUp = true;
                        }

                    // climb uphills

                    const bool down = ap.isKeyPressed( key_down ) || ap.isKeyPressed( key_action3 );
                    if (onground && (down || moveUp))
                    {
                        const bool faceleft = this.isFacingLeft();
                        if (angle > 330 || angle < 30)
                        {
                            f32 wallMultiplier = (this.isOnWall() && (angle > 350 || angle < 10)) ? 1.5f : 1.0f;
                            f32 torque = 150.0f * wallMultiplier;
                            if (down)
                                this.AddTorque( faceleft ? torque : -torque );
                            else
                                this.AddTorque( ((faceleft && left) || (!faceleft && right)) ? torque : -torque );
                            this.AddForce(Vec2f(0.0f,-200.0f * wallMultiplier));
                        }

                        if (isFlipped(this))
                        {
                            f32 angle = this.getAngleDegrees();
                            if (!left && !right)
                                this.AddTorque(angle < 180 ? -500:500);
                            else
                                this.AddTorque( ((faceleft && left) || (!faceleft && right)) ? 500 : -500 );
                            this.AddForce(Vec2f(0,-400));
                        }
                    }
                }  // driver

                if (blob.isMyPlayer() && ap.name == "GUNNER")
                {
                    // set facing
                    blob.SetFacingLeft( this.isFacingLeft() );
                    
                    const u8 style = v.fire_style;
                    switch (style)
                    {
                        case Vehicle_Fire_Style::normal:
                        if ( ap.isKeyPressed( key_action1 ) )
                        {
                            if (canFire(this, v))
                            {
                                CBitStream fireParams;
                                fireParams.write_u16( blob.getNetworkID() );
                                fireParams.write_u8( 0 );
                                this.SendCommand( this.getCommandID("fire"), fireParams );
                            }
                        }
                        break;
                        
                        case Vehicle_Fire_Style::custom:
                        {
                        u8 charge = 0;
                        if (canFire(this, v) && Vehicle_canFire(this, v, ap.isKeyPressed( key_action1 ), ap.wasKeyPressed( key_action1 ), charge))
                        {
                            CBitStream fireParams;
                            fireParams.write_u16( blob.getNetworkID() );
                            fireParams.write_u8( charge );
                            this.SendCommand( this.getCommandID("fire"), fireParams );
                        }
                        }
                        
                        break;
                    }
                } // gunner

                // FLYER

                if (ap.name == "FLYER")
                {
                    f32 moveForce = v.move_speed;
                    
                    f32 flyAmount = v.fly_amount;
                    
                    f32 turnSpeed = v.turn_speed;
                    s8 direction = v.move_direction;
                    
                    Vec2f force;
                    bool moving = false;
                    const bool up = ap.isKeyPressed( key_action1 );
                    const bool down = ap.isKeyPressed( key_action2 ) || ap.isKeyPressed( key_down );
                    
                    const Vec2f vel = this.getVelocity();

                    bool backwards = false;

                    // fly up/down
                    if (up||down)
                    {
                        if (up)
                        {
                            direction -= 1;
                            
                            flyAmount += 0.3f/getTicksASecond();
                            if(flyAmount > 1.0f)
                                flyAmount = 1.0f;
                        }
                        else
                        {
                            direction += 1;
                            
                            flyAmount -= 0.3f/getTicksASecond();
                            if(flyAmount < 0.5f)
                                flyAmount = 0.5f;
                        }
                        v.fly_amount = flyAmount;
                        v.move_direction = direction;
                    }

                    // fly left/right   
                    const bool left = ap.isKeyPressed( key_left );
                    const bool right = ap.isKeyPressed( key_right );
                    if (left)
                    {
                        force.x -= moveForce;

                        if (vel.x < -turnSpeed)
                        {
                            this.SetFacingLeft( true );
                        }
                        else
                        {
                            backwards = true;
                        }

                        moving = true;
                    }

                    if (right)
                    {
                        force.x += moveForce;

                        if (vel.x > turnSpeed)
                        {
                            this.SetFacingLeft( false );
                        }
                        else
                        {
                            backwards = true;
                        }

                        moving = true;
                    }

                   
                    if (moving)
                    {
                       // this.AddForceAtPosition( force, ap.getPosition());
                         this.AddForce( force );
                    }
                } // flyer


                // ROWER

                if ( (ap.name == "ROWER" && this.isInWater()) || (ap.name == "SAIL" && !this.hasTag("no sail") ))
                {
                    const f32 moveForce = v.move_speed;
                    const f32 turnSpeed = v.turn_speed;
                    Vec2f force;
                    bool moving = false;
                    const bool left = ap.isKeyPressed( key_left );
                    const bool right = ap.isKeyPressed( key_right );
                    const Vec2f vel = this.getVelocity();

                    bool backwards = false;

                    // row left/right

                    if (left)
                    {
                        force.x -= moveForce;

                        if (vel.x < -turnSpeed)
                        {
                            this.SetFacingLeft( true );
                        }
                        else
                        {
                            backwards = true;
                        }

                        moving = true;
                    }

                    if (right)
                    {
                        force.x += moveForce;

                        if (vel.x > turnSpeed)
                        {
                            this.SetFacingLeft( false );
                        }
                        else
                        {
                            backwards = true;
                        }

                        moving = true;
                    }

                    if (moving)
                    {
                        this.AddForce(force);
                    }
                } // flyer
            }  // ap.occupied
        }   // for
    }
    
    if(this.hasTag("airship"))
    {
        f32 flyForce = v.fly_speed;
        f32 flyAmount = v.fly_amount;
        this.AddForce( Vec2f(0,flyForce*flyAmount) );
    }
    
}
