void onInit(CRules@ this)
{
    particles_gravity.y = 0.4f;
    particles_material = EMT_TRANSPARENT_ALPHA_CHANNEL_REF;
    sv_gravity = 9.81;
    sv_maxplayers = 16;
    v_camera_ints = true;
    cc_halign = 1;
    cc_valign = 0;
    sv_visiblity_scale = 1.25f;
    sv_sendminimap = false;    

    this.map_water_layer_alpha = 255;
    this.map_water_render_style = 1;
    this.engine_floodlayer_updates = false;

    Sound::SetCutOff(650.0f);
    Sound::SetScale(5.0f);
    Sound::ResetListenerPositionOverride();

    SetupHighLevelMapChunkSize(4);

    physics_pos_iters = 20;
    physics_vel_iters = 8;

    getHUD().HideCursor();

    SetTeamChatColor( SColor(255, 225, 225, 255) );
}