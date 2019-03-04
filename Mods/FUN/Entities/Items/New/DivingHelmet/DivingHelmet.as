void onTick(CBlob@ this)
{
  CBlob@ carries = this.getCarriedBlob();
  if (carries is null) return;
  carries.set_u8("air_count", 180);
}