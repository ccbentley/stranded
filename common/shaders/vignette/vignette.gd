extends TextureRect

var vignette_displayed: bool = false
var vignette_displayed_color: Color
var vignette_pulsing: bool = false

func display_vignette(color: Color) -> void:
	material.set_shader_parameter("color", color)
	var vignette_tween: Tween
	vignette_tween = get_tree().create_tween()
	vignette_tween.tween_method(set_vignette_alpha, 0.0, 0.2, 0.3)
	vignette_displayed = true
	vignette_displayed_color = color


func remove_vignette() -> void:
	var vignette_tween: Tween
	vignette_tween = get_tree().create_tween()
	vignette_tween.tween_method(set_vignette_alpha, 0.2, 0.0, 0.3)
	vignette_displayed = false


func pulse_vignette(color: Color) -> void:
	if not vignette_pulsing:
		vignette_pulsing = true
		material.set_shader_parameter("color", color)
		var pulse_vignette_tween: Tween
		pulse_vignette_tween = get_tree().create_tween()
		pulse_vignette_tween.tween_method(set_vignette_alpha, 0.0, 0.2, 0.3)
		pulse_vignette_tween.tween_method(set_vignette_alpha, 0.2, 0.0, 0.3)
		await pulse_vignette_tween.finished
		vignette_pulsing = false
		if vignette_displayed:
			display_vignette(vignette_displayed_color)


func set_vignette_alpha(value: float) -> void:
	material.set_shader_parameter("alpha", value)
