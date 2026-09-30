extends Button

func _ready():
	var tween = create_tween()
	tween.set_loops()

	tween.tween_property(self, "modulate:a", 0.4, 0.6)
	tween.tween_property(self, "modulate:a", 1.0, 0.6)
