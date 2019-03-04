// Bill Blaster animation

namespace BillBlaster
{
	enum State
	{
    	folded = 0,
    	idle,
    	bounce,
    	unpack
	}
}	

void onTick( CSprite@ this )
{
	u8 state = this.getBlob().get_u8("billBlasterState");	
	
   //let the current anim finish
   if (this.isAnimationEnded())
   {
	   if (state == BillBlaster::unpack)
	   {
			if (!this.isAnimation("unpack"))
				this.SetAnimation("unpack");
			else
				this.getBlob().set_u8("billBlasterState", BillBlaster::idle);	
	   }
	   else if (state == BillBlaster::folded)
	   {
			if (!this.isAnimation("pack"))
				this.SetAnimation("pack");
	   }
	   else if (state == BillBlaster::bounce)
	   {
		   this.SetAnimation("bounce");
	   }
	   else if (state == BillBlaster::idle)
	   {
			if (this.isAnimation("bounce")) 
				this.SetAnimation("default");
			else
				if (!this.isAnimation("default"))
					this.SetAnimation("default");	
	   }
	}
}
