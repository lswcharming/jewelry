// Based on http://blog.shayanjaved.com/2011/03/13/shaders-android/
// from Shayan Javed
// And dEngine source from Fabien Sanglard

precision highp float;
//precision mediump float; // [c] test original -> mediump

// The position of the light in eye space.
uniform vec3 uLightPos;

// Texture variables: depth texture
uniform sampler2D uShadowTexture;

// This define the value to move one pixel left or right
uniform float uxPixelOffset;
// This define the value to move one pixel up or down
uniform float uyPixelOffset;

// from vertex shader - values get interpolated
varying vec3 vPosition;
varying vec4 vColor;
varying vec3 vNormal;

// shadow coordinates
varying vec4 vShadowCoord;


/*
"Diamond test" by Emmanuel Keller aka Tambako - January 2016
License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
Contact: tamby@tambako.ch https://www.shadertoy.com/view/ltfXDM
*/

// [c] test [[
const vec4 iMouse = vec4(0.0, 0.0, 0.0, 0.0);
const vec3 iResolution = vec3(1080.0/1.0, 2342.0/1.0, 0.0);
float iTime = 0.0;
// [c] test ]]

// Rendering parameters
#define RAY_LENGTH_MAX		20.0 // 20.0
#define RAY_BOUNCE_MAX		10 // 10 // 5
#define RAY_STEP_MAX		40 // 40 // 20
#define COLOR				vec3 (0.8, 0.8, 0.9) // 0.8, 0.8, 0.9
#define ALPHA				0.9 // 0.9
#define REFRACT_INDEX		vec3 (2.407, 2.426, 2.451)
#define LIGHT				vec3 (1.0, 1.0, -1.0)
#define AMBIENT				0.2 // 0.2 // 0.1
#define SPECULAR_POWER		3.0 // 3.0 // 30
#define SPECULAR_INTENSITY	10.5 // 0.5 // 60.5

// Math constants
#define DELTA	0.001 // 0.001 // 0.01
#define PI		3.14159265359

// Rotation matrix
mat3 mRotate (in vec3 angle) {
	float c = cos (angle.x);
	float s = sin (angle.x);
	mat3 rx = mat3 (1.0, 0.0, 0.0, 0.0, c, s, 0.0, -s, c);

	c = cos (angle.y);
	s = sin (angle.y);
	mat3 ry = mat3 (c, 0.0, -s, 0.0, 1.0, 0.0, s, 0.0, c);

	c = cos (angle.z);
	s = sin (angle.z);
	mat3 rz = mat3 (c, s, 0.0, -s, c, 0.0, 0.0, 0.0, 1.0);

	return rz * ry * rx;
}

// Rotation matrix (rotation on the Y axis)
vec3 vRotateY (in vec3 p, in float angle) {
	float c = cos (angle);
	float s = sin (angle);
	return vec3 (c * p.x - s * p.z, p.y, c * p.z + s * p.x);
}

// Distance to the scene
vec3 normalTopA = normalize (vec3 (0.0, 1.0, 1.4));
vec3 normalTopB = normalize (vec3 (0.0, 1.0, 1.0));
vec3 normalTopC = normalize (vec3 (0.0, 1.0, 0.5));
vec3 normalBottomA = normalize (vec3 (0.0, -1.0, 1.0));
vec3 normalBottomB = normalize (vec3 (0.0, -1.0, 1.6));
float getDistance (in vec3 p) {
	p = mRotate (vec3 (iTime)) * p;

	float topCut = p.y - 1.0;
	float angleStep = PI / (iMouse.z < 0.5 ? 8.0 : 2.0 + floor (18.0 * iMouse.x / iResolution.x));
	float angle = angleStep * (0.5 + floor (atan (p.x, p.z) / angleStep));
	vec3 q = vRotateY (p, angle);
	float topA = dot (q, normalTopA) - 2.0;
	float topC = dot (q, normalTopC) - 1.5;
	float bottomA = dot (q, normalBottomA) - 1.7;
	q = vRotateY (p, -angleStep * 0.5);
	angle = angleStep * floor (atan (q.x, q.z) / angleStep);
	q = vRotateY (p, angle);
	float topB = dot (q, normalTopB) - 1.85;
	float bottomB = dot (q, normalBottomB) - 1.9;

	return max (topCut, max (topA, max (topB, max (topC, max (bottomA, bottomB)))));
}

/*// Distance to the scene
vec3 normalTopA = normalize (vec3 (0.0, 1.0, 1.4));
vec3 normalTopB = normalize (vec3 (0.0, 1.0, 1.0));
vec3 normalTopC = normalize (vec3 (0.0, 1.0, 0.5));
vec3 normalBottomA = normalize (vec3 (0.0, -1.0, 1.4));
vec3 normalBottomB = normalize (vec3 (0.0, -1.0, 1.0));
vec3 normalBottomC = normalize (vec3 (0.0, -1.0, 0.5));
float getDistance (in vec3 p) {
	p = mRotate (vec3 (iTime)) * p;

	float topCut = p.y - 1.0;
	float angleStep = PI / (iMouse.z < 0.5 ? 8.0 : 2.0 + floor (18.0 * iMouse.x / iResolution.x));
	float angle = angleStep * (0.5 + floor (atan (p.x, p.z) / angleStep));
	vec3 q = vRotateY (p, angle);
	float topA = dot (q, normalTopA) - 2.0;
	float topC = dot (q, normalTopC) - 1.5;
	float bottomA = dot (q, normalBottomA) - 2.0;
	float bottomC = dot (q, normalBottomC) - 1.5;
	q = vRotateY (p, -angleStep * 0.5);
	angle = angleStep * floor (atan (q.x, q.z) / angleStep);
	q = vRotateY (p, angle);
	float topB = dot (q, normalTopB) - 1.85;
	float bottomB = dot (q, normalBottomB) - 1.85;
	float bottomCut = p.y + 1.0;

	return max (topCut, max (topA, max (topB, max (topC, max (bottomA, max (bottomB, bottomC))))));
}*/

// Normal at a given point
vec3 getNormal (in vec3 p) {
	const vec2 h = vec2 (DELTA, -DELTA);
	return normalize (
		h.xxx * getDistance (p + h.xxx) +
		h.xyy * getDistance (p + h.xyy) +
		h.yxy * getDistance (p + h.yxy) +
		h.yyx * getDistance (p + h.yyx)
	);
}

// Cast a ray for a given color channel (and its corresponding refraction index)
vec3 lightDirection = normalize (LIGHT);
float raycast (in vec3 origin, in vec3 direction, in vec4 normal, in float color, in vec3 channel) {

	// The ray continues...
	color *= 1.0 - ALPHA;
	float intensity = ALPHA;
	float distanceFactor = 1.0;
	float refractIndex = dot (REFRACT_INDEX, channel);
	for (int rayBounce = 1; rayBounce < RAY_BOUNCE_MAX; ++rayBounce) {

		// Interface with the material
		vec3 refraction = refract (direction, normal.xyz, distanceFactor > 0.0 ? 1.0 / refractIndex : refractIndex);
		if (dot (refraction, refraction) < DELTA) {
			direction = reflect (direction, normal.xyz);
			origin += direction * DELTA * 2.0;
		} else {
			direction = refraction;
			distanceFactor = -distanceFactor;
		}

		// Ray marching
		float dist = RAY_LENGTH_MAX;
		for (int rayStep = 0; rayStep < RAY_STEP_MAX; ++rayStep) {
			dist = distanceFactor * getDistance (origin);
			float distMin = max (dist, DELTA);
			normal.w += distMin;
			if (dist < 0.0 || normal.w > RAY_LENGTH_MAX) {
				break;
			}
			origin += direction * distMin;
		}

		// Check whether we hit something
		if (dist >= 0.0) {
			break;
		}

		// Get the normal
		normal.xyz = distanceFactor * getNormal (origin);

		// Basic lighting
		if (distanceFactor > 0.0) {
			float relfectionDiffuse = max (0.0, dot (normal.xyz, lightDirection));
			float relfectionSpecular = pow (max (0.0, dot (reflect (direction, normal.xyz), lightDirection)), SPECULAR_POWER) * SPECULAR_INTENSITY;
			float localColor = (AMBIENT + relfectionDiffuse) * dot (COLOR, channel) + relfectionSpecular;
			color += localColor * (1.0 - ALPHA) * intensity;
			intensity *= ALPHA;
		}
	}

	// Get the background color
//	float backColor = dot (texture (iChannel0, direction).rgb, channel);
	float backColor = dot (texture2D(uShadowTexture, direction.yz/1.0).rgb, channel); // [c] test
//	float backColor = dot (vec3(1.0, 0.0, 0.0), channel); // [c] test

	// Return the intensity of this color channel
	return color + backColor * intensity;
}

// Main function
void mainImage (out vec4 fragColor, in vec2 fragCoord) {

	// Define the ray corresponding to this fragment
//	vec2 frag = (2.0 * fragCoord.xy - iResolution.xy) / iResolution.y;
	vec2 frag = (2.0 * fragCoord.xy - iResolution.xy) / iResolution.y;
	vec3 direction = normalize (vec3 (frag, 0.5)); // [c] test 2.0 -> 0.5 scale

    iTime = uxPixelOffset; // [c] test
	// Set the camera
	vec3 origin = 7.0 * vec3 ((cos (iTime * 0.1)), sin (iTime * 0.2), sin (iTime * 0.1));
	vec3 forward = -origin;
	vec3 up = vec3 (sin (iTime * 0.3), 2.0, 0.0);
	mat3 rotation;
	rotation [2] = normalize (forward);
	rotation [0] = normalize (cross (up, forward));
	rotation [1] = cross (rotation [2], rotation [0]);
	direction = rotation * direction;

	// Cast the initial ray
	vec4 normal = vec4 (0.0);
	float dist = RAY_LENGTH_MAX;
	for (int rayStep = 0; rayStep < RAY_STEP_MAX; ++rayStep) {
		dist = getDistance (origin);
		float distMin = max (dist, DELTA);
		normal.w += distMin;
		if (dist < 0.0 || normal.w > RAY_LENGTH_MAX) {
			break;
		}
		origin += direction * distMin;
	}

	// Check whether we hit something
	if (dist >= 0.0) {
//		fragColor.rgb = texture (iChannel0, direction).rgb;
		fragColor.rgb = texture2D(uShadowTexture, direction.yz*0.5 + 0.5).rgb; // [c] test
	} else {

		// Get the normal
		normal.xyz = getNormal (origin);

		// Basic lighting
		float relfectionDiffuse = max (0.0, dot (normal.xyz, lightDirection));
		float relfectionSpecular = pow (max (0.0, dot (reflect (direction, normal.xyz), lightDirection)), SPECULAR_POWER) * SPECULAR_INTENSITY;
		fragColor.rgb = (AMBIENT + relfectionDiffuse) * COLOR + relfectionSpecular;

		// Cast a ray for each color channel
		fragColor.r = raycast (origin, direction, normal, fragColor.r, vec3 (1.0, 0.0, 0.0));
		fragColor.g = raycast (origin, direction, normal, fragColor.g, vec3 (0.0, 1.0, 0.0));
		fragColor.b = raycast (origin, direction, normal, fragColor.b, vec3 (0.0, 0.0, 1.0));
	}

	// Set the alpha channel
	fragColor.a = 1.0;
}

//////////////////////////////////////////////////////////////////////////////////////////// ori

//Simple shadow mapping
float shadowSimple() 
{ 
	vec4 shadowMapPosition = vShadowCoord / vShadowCoord.w;
	
	float distanceFromLight = texture2D(uShadowTexture, shadowMapPosition.st).z;

	//add bias to reduce shadow acne (error margin)
	float bias = 0.0005;

	//1.0 = not in shadow (fragmant is closer to light than the value stored in shadow map)
	//0.0 = in shadow
	return float(distanceFromLight > shadowMapPosition.z - bias);
}
  
void main()                    		
{        
	vec3 lightVec = uLightPos - vPosition;
	lightVec = normalize(lightVec);
   	
   	// Phong shading with diffuse and ambient component
	float diffuseComponent = max(0.0,dot(lightVec, vNormal) );
	float ambientComponent = 0.3;
 		
 	// Shadow
   	float shadow = 1.0;
	
	//if (diffuseComponent < 0.01)
	//{
	//	shadow = 1.0;
	//}
	//else
	//{
//		//if the fragment is not behind light view frustum
//		if (vShadowCoord.w > 0.0) {
//
//			shadow = shadowSimple();
//
//			//scale 0.0-1.0 to 0.2-1.0
//			//otherways everything in shadow would be black
//			shadow = (shadow * 0.8) + 0.2;
//		}
	//}

	// Final output color with shadow and lighting
    //gl_FragColor = (vColor * (diffuseComponent + ambientComponent * shadow));
//    gl_FragColor = (vColor * (diffuseComponent + ambientComponent) * shadow);


//    gl_FragColor = render_aa(vPosition.xy*30.0, campos);
//    gl_FragColor = render_aa(vPosition.xy*10.0, campos);
//    gl_FragColor = texture2D(uShadowTexture, vPosition.xy*0.5 + 0.5);
      vec2 uv = vec2((vPosition.x*0.5 + 0.5)*iResolution.x, (vPosition.y*0.5 + 0.5)*iResolution.y);
      mainImage(gl_FragColor, uv);
}
