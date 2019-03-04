//Unnecessary?
void onInit(CBlob@ this)
{
	CShape@ shape = this.getShape();
	shape.SetGravityScale(0.08f);
	shape.setDrag(shape.getDrag() + 0.3f);
}