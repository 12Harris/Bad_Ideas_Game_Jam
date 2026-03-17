shader_type canvas_item;

uniform sampler2D tex_a;
uniform sampler2D tex_b;

void fragment() {
    vec4 a = texture(TEXTURE, UV);
    vec4 b = texture(tex_b, UV);
	//COLOR = a;
   	COLOR = mix(a, b, b.a);
}
