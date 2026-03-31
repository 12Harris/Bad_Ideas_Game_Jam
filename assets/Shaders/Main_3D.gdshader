shader_type canvas_item;

uniform sampler2D tex_a;
uniform sampler2D tex_b;
//uniform sampler2D tex_c;

void fragment() {
    vec4 a = texture(TEXTURE, UV);
    vec4 b = texture(tex_b, UV);
	//vec4 c = texture(tex_c, UV);

	//COLOR = a;
   	//COLOR = mix(a, b, b.a);
	
	vec4 temp = mix(a, b, b.a);
	float mask = texture(tex_a, UV).a;
	//COLOR = vec4(temp.rgb, mask);
	vec4 temp2 = vec4(temp.rgb, mask);
	COLOR = mix(a, b, b.a);
}
