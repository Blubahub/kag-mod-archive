
void onTick( CSprite@ this )
{
	CCamera@ camera = getCamera();
	if (camera !is null)
	{
		ShapeVars@ vars = this.getBlob().getShape().getVars();
		Vec2f campos = camera.getPosition();

		if (vars.pos.x > campos.x && vars.oldpos.x < campos.x){
			this.PlayRandomSound("BulletWhizLeftRight");
		}
		else if (vars.pos.x < campos.x && vars.oldpos.x > campos.x){
			this.PlayRandomSound("BulletWhizRightLeft");
		}
	}
}