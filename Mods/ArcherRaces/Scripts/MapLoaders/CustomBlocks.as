const SColor color_start_gate(        0xFF2A0B47); // ARGB(255, 42,  11, 71);

void HandleCustomTile(CMap@ map, int offset, SColor pixel)
{
    if (pixel == color_start_gate)
    {
        server_CreateBlob("start_gate", 0, getSpawnPosition(map, offset));
    }
}
