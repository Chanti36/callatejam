//https://godotshaders.com/shader/old-movie-shader/
shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float projector_power : hint_range(0,1) = 0.5;
uniform sampler2D distortionTexture;
uniform float vignette_param: hint_range(1,10)=20.0;

uniform float saturation : hint_range(0.0, 1.0) = 1.0; // 0 = grayscale, 1 = full color

uniform float noise_intensity : hint_range(0.0, 1.0) = 0.05; 

//vars related to the passing lines

//noise for the projector flickering
float noise(vec2 input){
	return fract(sin(dot(input,vec2(3.1415,8952.37)*12.29))*93.116);
}

//random for noise
float randomnoise(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}


void fragment() {
	//vignette-related:
	float vignette_param2 =vignette_param+0.5*(noise(vec2(TIME/60.0,TIME/59.0)));
	float vig=-vignette_param2*((UV.x-0.5)*(UV.x-0.5)+(UV.y-0.5)*(UV.y-0.5));
	vec4 vignette=vec4(vig,vig,vig,1.0);

	//grayscale-related:
	vec4 pixelcolor = texture(SCREEN_TEXTURE, SCREEN_UV);
	float brightness = (.299*pixelcolor.r + 0.487*pixelcolor.g + 0.114*pixelcolor.b);
	vec3 result = mix(vec3(brightness), pixelcolor.rgb, saturation);
	vec4 grayscale= vec4(result, pixelcolor.a);
	
	//random-fluctuation:
	vec4 random = texture(distortionTexture,UV);
	
	//Small speckles:
	float RTIME1=round(TIME*20.0);
	vec2 position1=vec2(noise(vec2(RTIME1,RTIME1)),noise(vec2(RTIME1/2.0,RTIME1/2.0)));
	float energy= 1000000.0*(1.0+0.5*noise(vec2(RTIME1,RTIME1)));
	float xdev1=(UV.x-position1.x);
	float ydev1=(UV.y-position1.y);
	float spec=energy*(xdev1*xdev1+0.5*ydev1*ydev1)+.1*noise(vec2(UV.x,UV.y));
	vec4 speckle=vec4(max(0.0,20.0-spec),max(0.0,20.0-spec),max(0.0,20.0-spec),1.0);
	
	//lines:
	float RTIME2=round(TIME*5.0);
	vec2 positionline=vec2(noise(vec2(RTIME2,RTIME2))/4.0,noise(vec2(RTIME2/3.0,RTIME2/3.0)));
	float xline=(UV.x-positionline.x);
	float yline=(UV.y-positionline.y);
	float lin=energy*(xline*xline+0.00001*yline*yline)+.1*noise(vec2(UV.x,UV.y));
	vec4 line=vec4(max(0.0,8.0-lin),max(0.0,8.0-lin),max(0.0,8.0-lin),1.0);
	
	//noise addon
	 vec2 uv = SCREEN_UV;
	vec4 color = texture(SCREEN_TEXTURE, uv);
	float textureNoise = randomnoise(uv + TIME) * 2.0 - 1.0;
	grayscale.rgb += textureNoise * noise_intensity;
	
	//combining-the parts:
	vec4 dirt=mix(speckle,line,0.5);
	vec4 grayscale2=mix(random,vignette,0.7);
	vec4 grayscale3=mix(dirt,grayscale2,0.7);
	COLOR = mix(grayscale, grayscale3, projector_power);
}