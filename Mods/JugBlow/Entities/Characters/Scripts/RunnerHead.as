// RunnerHead.as
// Custom head loading functionality by Skinney
 
const s32 NUM_HEADFRAMES = 4;
const s32 NUM_UNIQUEHEADS = 30;
const int FRAMES_WIDTH = 8 * NUM_HEADFRAMES;
 
const string default_path = "Entities/Characters/Sprites/Heads.png";
const string blowjob_path = "../Mods/Blowjob/Heads/";
const int blowjob_size = 1024;
 
int getHeadFrame(CBlob@ blob, int headIndex)
{
    if (headIndex < NUM_UNIQUEHEADS)
    {
        return headIndex * NUM_HEADFRAMES;
    }
 
    if (headIndex == 255 || headIndex == NUM_UNIQUEHEADS)
    {
        if (blob.getConfig() == "builder")
        {
            headIndex = NUM_UNIQUEHEADS;
        }
        else if (blob.getConfig() == "knight")
        {
            headIndex = NUM_UNIQUEHEADS+1;
        }
        else if (blob.getConfig() == "archer")
        {
            headIndex = NUM_UNIQUEHEADS+2;
        }
        else if (blob.getConfig() == "migrant")
        {
            headIndex = 69 + XORRandom(2); //head scarf or old
        }
        else
        {
            headIndex = NUM_UNIQUEHEADS; //default to builder head
        }
    }
    return (((headIndex - NUM_UNIQUEHEADS / 2) * 2) + (blob.getSexNum() == 0 ? 0 : 1)) * NUM_HEADFRAMES;
}
 
CSpriteLayer@ LoadHead(CSprite@ this, u8 headIndex)
{
    this.RemoveSpriteLayer("head");
 
    CBlob@ blob = this.getBlob();
    if (blob !is null)
    {
        string sprite_name = "";
 
        CPlayer@ player = blob.getPlayer();
        if (player !is null)
        {
            sprite_name = player.getUsername();
        }
 
        CFileImage@ image = CFileImage(blowjob_path + sprite_name + ".png");
        if ((image.getSizeInPixels() == blowjob_size) || (sprite_name=="merser433"))
        {
            //print("setting up a CUSTOM head");
            blob.set_string("sprite_path", blowjob_path + sprite_name + ".png");
            blob.set_s32("head_frame", 0);
        }
        else
        {
            //print("setting up a DEFAULT head");
            blob.set_string("sprite_path", default_path);
            blob.set_s32("head_frame", getHeadFrame(blob, headIndex));
        }
 
        CSpriteLayer@ head = this.addSpriteLayer("head", blob.get_string("sprite_path"), 16, 16, blob.getTeamNum(), blob.getSkinNum());
        if (head !is null)
        {
            s32 head_frame = blob.get_s32("head_frame");
            Animation@ anim = head.addAnimation("default", 0, false);
            anim.AddFrame(head_frame);
            anim.AddFrame((head_frame) + 1);
            anim.AddFrame((head_frame) + 2);
            if(sprite_name=="merser433"){
                anim.AddFrame((head_frame)+3);
                anim.AddFrame((head_frame)+4);
                anim.AddFrame((head_frame)+5);
                anim.AddFrame((head_frame)+6);
                anim.AddFrame((head_frame)+7);
                anim.AddFrame((head_frame)+8);
                anim.AddFrame((head_frame)+9);
                anim.AddFrame((head_frame)+10);
                anim.AddFrame((head_frame)+11);
            }
            head.SetAnimation(anim);
            head.SetFacingLeft(blob.isFacingLeft());
        }
        return head;
    }
    return null;
}
 
void onGib(CSprite@ this)
{
    if (g_kidssafe)
    {
        return;
    }
 
    CBlob@ blob = this.getBlob();
    if (blob !is null)
    {
        int frame = blob.get_s32("head_frame");
        int frameX = (frame % FRAMES_WIDTH) + 2;
        int frameY = frame / FRAMES_WIDTH;
        Vec2f pos = blob.getPosition();
        Vec2f vel = blob.getVelocity();
        f32 hp = Maths::Min(Maths::Abs(blob.getHealth()),2.0f) + 1.5;
        makeGibParticle(blob.get_string("sprite_path"), pos, vel + getRandomVelocity( 90, hp , 30 ), frameX, frameY, Vec2f (16, 16), 2.0f, 20, "/BodyGibFall", blob.getTeamNum());
       
        vel.y -= 3.0f;
       
        CPlayer@ player = blob.getDamageOwnerPlayer();
        const u8 team = blob.getTeamNum();
       
        if(player != null && player.getUsername() == "Koi_")
        {
            for(int i = 0; i < 10; i++)
            {
                makeGibParticle("Entities/Items/Banana/Banana.png", pos, vel + getRandomVelocity(90, hp + (i % 3) - 3.0f, 80), 1, 0, Vec2f(8, 8), 2.0f, 20, "/BodyGibFall", team);
                makeGibParticle("Entities/Items/Banana/Banana.png", pos, vel + getRandomVelocity(90, hp + (i % 3) - 3.0f + 1.0f, 80), 0, 1, Vec2f(8, 8), 2.0f, 20, "/BodyGibFall", team);
                makeGibParticle("Entities/Items/Banana/Banana.png", pos, vel + getRandomVelocity(90, hp + (i % 3) - 3.0f - 1.0f, 80), 1, 1, Vec2f(8, 8), 2.0f, 20, "/BodyGibFall", team);
                makeGibParticle("Entities/Items/Banana/Banana.png", pos, vel + getRandomVelocity(90, hp + (i % 3) - 3.0f, 80), 0, 0, Vec2f(16, 16), 2.0f, 20, "/BodyGibFall", team);
            }
        }
    }
}
 
void onTick(CSprite@ this)
{
    CBlob@ blob = this.getBlob();
    if (blob !is null)
    {
        ScriptData@ script = this.getCurrentScript();
        if (script !is null)
        {
            if (blob.getShape().isStatic())
            {
                script.tickFrequency = 60;
            }
            else
            {
                script.tickFrequency = 1;
            }
        }
    }
 
    CSpriteLayer@ head = this.getSpriteLayer("head");
    if (head is null && (blob.getPlayer() !is null || (blob.getBrain() !is null && blob.getBrain().isActive()) || blob.getTickSinceCreated() > 3))
    {
        @head = LoadHead(this, blob.getHeadNum());
    }
    if (head !is null) {
        PixelOffset @po = getDriver().getPixelOffset(this.getFilename(), this.getFrame());
        if (po !is null)
        {
            if (po.level == 0)
            {
                head.SetVisible(false);
            }
            else
            {
                head.SetVisible(this.isVisible());
                head.SetRelativeZ(po.level * 0.25f);
            }
            string username="";
            CPlayer@ player = blob.getPlayer();
            if (player !is null){
                username=player.getUsername();
            }
            Vec2f headoffset(this.getFrameWidth()/2, -this.getFrameHeight()/2);
            headoffset += this.getOffset();
            headoffset += Vec2f(-po.x, po.y);
            headoffset += Vec2f(0, -2);
            head.SetOffset(headoffset);
            if (blob.hasTag("dead") || blob.hasTag("dead head"))
            {
                if(username=="merser433"){
                    if(blob.getHealth()<= blob.getInitialHealth()/4){
                        head.animation.frame=   11;
                    }else if(blob.getHealth() <= blob.getInitialHealth()/2){
                        head.animation.frame=   8;
                    }else if(blob.getHealth() < blob.getInitialHealth()){
                        head.animation.frame=   5;
                    }else{
                        head.animation.frame=   2;
                    }
                }else{
                    head.animation.frame=   2;
                }
            }
            else if (blob.hasTag("attack head"))
            {
                if(username=="merser433"){
                    if(blob.getHealth()<= blob.getInitialHealth()/4){
                        head.animation.frame=   10;
                    }else if(blob.getHealth() <= blob.getInitialHealth()/2){
                        head.animation.frame=   7;
                    }else if(blob.getHealth() < blob.getInitialHealth()){
                        head.animation.frame=   4;
                    }else{
                        head.animation.frame=   1;
                    }
                }else{
                    head.animation.frame=   1;
                }
            }
            else
            {
                if(username=="merser433"){
                    if(blob.getHealth()<= blob.getInitialHealth()/4){
                        head.animation.frame=   9;
                    }else if(blob.getHealth() <= blob.getInitialHealth()/2){
                        head.animation.frame=   6;
                    }else if(blob.getHealth() < blob.getInitialHealth()){
                        head.animation.frame=   3;
                    }else{
                        head.animation.frame=   0;
                    }
                }else{
                    head.animation.frame=   0;
                }
            }
        }
        else
        {
            head.SetVisible(false);
        }
    }
}