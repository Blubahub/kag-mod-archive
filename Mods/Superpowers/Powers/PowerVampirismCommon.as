void DoVampirismHeal(CBlob@ this, float amount) {
    float maxHP = this.getInitialHealth();
    float HP = this.getHealth();

    if (amount > 0 && HP < maxHP) {
        float healAmount = Maths::Min(amount, maxHP - HP);
        this.server_Heal(healAmount);

        if (getNet().isClient())
            this.getSprite().PlaySound("/Heart.ogg");
    }
}
