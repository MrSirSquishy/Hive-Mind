extends Node

# Global signals go here

signal world_clicked(global_position : Vector2)

#nothing spawned yet
signal wave_started(wave_number: int)
#every enemy in the wave is dead
signal wave_cleared(wave_number: int)
#ran out of waves
signal all_waves_cleared()
#player lost
signal wave_failed()

#Game_Manager counts these, so die() must emit before queue_free
signal entity_died(entity: Entity)
