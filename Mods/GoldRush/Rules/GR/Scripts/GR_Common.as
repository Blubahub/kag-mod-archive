shared f32 gold_radius() { return 200.0f; };
shared f32 gold_percentage() { return 16.0f; }; //16%
shared int gold_timer_start_secs() { return 300*30; };
shared int gold_timer_enemy_secs() { return 15*30; };
shared int max_gold_needed() { return 10000; };
shared int max_gold_in_sack() { return 140; }; //if sacks_count < sacks_limit()
shared int sacks_limit() { return 10; };
shared int gold_to_show_icon() { return 200; };
shared f32 sack_enemy_radius() { return 32.0f; };

shared int meteor_spawn_interval() { return 300*30; }; //every 5 mins
shared int meteor_necro() { return 3; }; //how many necromancers will be spawned
shared int necro_drop() { return 100; }; //how many gold necromancers will drop