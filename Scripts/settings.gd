extends PanelContainer

@onready var master_volume_slider = %MasterVolumeSlider
@onready var music_volume_slider = %MusicVolumeSlider

@onready var master_bus_index = AudioServer.get_bus_index("Master")
@onready var music_bus_index = AudioServer.get_bus_index("Music")

func _ready():
	master_volume_slider.value_changed.connect(func(new_value):
		on_volume_changed(master_bus_index, new_value)
	)
	
	music_volume_slider.value_changed.connect(func(new_value):
		on_volume_changed(music_bus_index, new_value)
	)
	
	update_slider(master_bus_index, master_volume_slider)
	update_slider(music_bus_index, music_volume_slider)

func on_volume_changed(bus_idx: int, new_value: float):
	AudioServer.set_bus_mute(bus_idx, new_value == 0.0)
	AudioServer.set_bus_volume_db(bus_idx, (new_value - 1.0) * 40.0)

func update_slider(bus_idx: int, slider: HSlider):
	var volume = AudioServer.get_bus_volume_db(bus_idx)
	slider.value = 0.0 if volume < -40.0 else (volume / 40.0) + 1.0
