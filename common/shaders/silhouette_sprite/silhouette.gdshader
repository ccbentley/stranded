shader_type canvas_item;

// Screen texture to check if the sprite is behind something
uniform sampler2D screen_texture: hint_screen_texture;

// The color to use for the silhouette
uniform vec4 silhouette_color: source_color = vec4(0.0, 0.0, 0.0, 0.5);

// Called for every pixel the material is visible on
void fragment() {
	// Sample the screen color
	vec4 screen_color = texture(screen_texture, SCREEN_UV);
	// Sample the sprite color
	vec4 sprite_color = texture(TEXTURE, UV);
	//Check if the sprite and the screen color match
	if(all(lessThan(abs(sprite_color - screen_color), vec4(0.01)))) {
		// This means the character is visible
		COLOR = sprite_color;
	} else {
		// This means the character is behind an object
		COLOR = vec4(silhouette_color.rgb, silhouette_color.a * sprite_color.a);
	}
}
