/* vertex shader */
@vs vs
in vec4 position;
//
out vec4 pos;
//
///--------------------------------------------------------------------------------------------
///--------------------------------------------------------------------------------------------
///==!VERTEX!== IMPL
///============================================================================================
///--------------------------------------------------------------------------------------------

void main() {
    gl_Position = position;
    pos = position;
    pos.x +=0.30;
}
@end

/* fragment shader */
@fs fs
///////////////////
///== UNIFORM ==///
uniform fs_params {
   vec4 iMouse;      // mouse pixel coords .xy: current (if MLB down), zw: click
   vec3 iResolution; // viewport resolution (in pixels)
   float iTime;      // shader playback time (in seconds)
   float iTimeDelta; // render time (in seconds)
   float iFrameRate; // shader frame rate
};
//
in vec4 pos;
//
out vec4 frag_color;

///--------------------------------------------------------------------------------------------
///--------------------------------------------------------------------------------------------
///==!FRAGEMENT!== SHADERTOY IMPL
///============================================================================================
///--------------------------------------------------------------------------------------------
   /*
#define cor(a) (cos(a * 6.3 + vec4(0, 23, 21, 0)) * 0.5 + 0.5)
#define rot(a) mat2(cos(a + vec4(0, 11, 33, 0)))

#define t iTime
float torus(vec3 q) {
    return length(
        vec2(
            length(q.xy) - 0.6                       
            - tanh(cos(atan(q.x, q.y) * 5.0) * 2.0)  
            * 0.08,                                  
            q.z                                      
        )
    ) - 0.09;                                        
}
//
void rotObj(inout vec3 p) {
    p.yz *= rot(tanh(cos(t * 1.3) * 4.0 - 3.0)); 
    p.xy *= rot(tanh(cos(t * 1.2) * 3.0) * 0.7);
}
//
float map(vec3 p) {
    rotObj(p); 
    vec3 q; 
    float s = 1.0, j = 0.0, d = 0.0;
    while(j++ < 5.0) {
        q = p;
        q.xy *= rot(j * 6.28 / 5.0);
        q.xz *= rot(6.28 / 6.0); 
        d = torus(q); 
        d = j < 4.0 ? d : abs(d); 
        s = min(s, d);
    }
    return s;
}
//
void mainImage(out vec4 frag_color, vec2 frag_coord) {
    float t = iTime;
    vec2 r = iResolution.xy;
    vec2 u = frag_coord.xy ;
    u = (u - r * 0.5) / r.y; 
    vec4 o;
    float d = 0.0, layers, s = 0.0, i = 0.0, b = 0.0;
    vec3 D = normalize(vec3(u, 1.0)), p;
    o *= 0.0;
    while(i++ < 55.0) {
        s = map(p);
        d += max(s, 0.002) * 0.6;  
        p = d * D;
        p.z += -1.8; 
       
        if (s < 0.02) {
            o += (0.01 - s) / d * i / 41.0 + cor(i / 25.0) / 75.0;
        }
    }
    frag_color=o;
}*/
/*
//https://www.shadertoy.com/view/wtSBzz
mat2 rot(float a) {
	float s=sin(a),c=cos(a);
    return mat2(c,s,-s,c);
}

float sdTorus( vec3 p, vec2 t )
{
  vec2 q = vec2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
}

float de(vec3 p) {
    float t=-sdTorus(p,vec2(2.3,2.));
    p.y+=1.;
    float d=100.,s=2.;
    p*=.5;
    for (int i=0; i<6; i++) {
        p.xz*=rot(iTime);
        p.xz=abs(p.xz);
        float inv=1./clamp(dot(p,p),0.,1.);
        p=p*inv-1.;
        s*=inv;
        d=min(d,length(p.xz)+fract(p.y*.05+iTime*.2)-.1);
    }
    return min(d/s,t);
}

float march(vec3 from, vec3 dir) {
    float td=0., g=0.;
    vec3 p;
    for (int i=0; i<100; i++) {
    	p=from+dir*td;
        float d=de(p);
        if (d<.002) break;
        g++;
        td+=d;
    }
    return smoothstep(.3,0.,abs(.5-fract(p.y*15.)))*exp(-.07*td*td)*sin(p.y*10.+iTime*10.)+g*g*.00008;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv=fragCoord/iResolution.xy-.5;
    uv.x*=iResolution.x/iResolution.y;
    float t=iTime*.5;
	vec3 from=vec3(cos(t),0.,-3.3);
    vec3 dir=normalize(vec3(uv,.7));
	dir.xy*=rot(.5*sin(t));    
    float col=march(from,dir);
    fragColor=vec4(col);
}

*/


/*
//https://www.shadertoy.com/view/llsBRH

float 	t;

#define I_MAX		200
#define E			0.001
#define FAR			10.

#define	FUDGE
// artifactus disparatus !! (fudge needed cuz of high curvature distorsion)
#define PHONG

vec4	march(vec3 pos, vec3 dir);
vec3	camera(vec2 uv);
vec3	calcNormal(in vec3 pos, float e, vec3 dir);
void	rotate(inout vec2 v, float angle);
float	mylength(vec2 p);
float	mylength(vec3 p);

vec3	base;
vec3	h;
vec3	volumetric;

void mainImage(out vec4 c_out, in vec2 f)
{
    h *= 0.;
    volumetric *= 0.;
    t = iTime;
    vec3	col = vec3(0., 0., 0.);
	vec2	uv  = vec2((f.x-.5*iResolution.x)/iResolution.x, (f.y-.5*iResolution.y)/iResolution.y);
	vec3	dir = camera(uv);
    vec3	pos = vec3(-.0, .0, 25.0-sin(iTime*.125)*25.*0.-21.+2.);

    vec4	inter = (march(pos, dir));

    if (inter.y == 1.)
    {
    	base = vec3(.4, .5, .2);
	    #ifdef PHONG
        // substracting a bit from the ray to get a better normal
		vec3	v = pos+(inter.w-E*10.)*dir;
        vec3	n = calcNormal(v, E, dir);
        vec3	ev = normalize(v - pos);
		vec3	ref_ev = reflect(ev, n);
        vec3	light_pos   = vec3(0.0, -100.0, 1000.0);
		vec3	light_color = vec3(1.8, .5, .2);
        vec3	vl = normalize( (light_pos - v) );
		float	diffuse  = max(0., dot(vl, n));
		float	specular = pow(max(0., dot(vl, ref_ev)), 10.8 );
        col.xyz = light_color * (specular) + diffuse * base;
        float	dt = 1. - dot(n, normalize(-ev) );
        col += smoothstep(.0, 1.0, dt)*vec3(.2, .7, .90);
	#else
    	col.xyz = 1.*( +vec3(.65, .4, .2)*inter.w * .3-inter.x*.1 * vec3(.3, .2, .15) );
	#endif
    	col  -= -.25 + h;
    }
    col += volumetric;
    c_out =  vec4(col, h.x);
}

float	scene(vec3 p)
{
    p.z+=sin(t*1.5)*2.;
    float	balls = 1e5;
    float	lumos = 1e5;
	vec3	pr;

    vec2	q;
    
    pr = p;
    
    rotate(pr.xz , iTime*1.);
        
    float	ata = atan(pr.x, pr.y)*1.+0.;
    
    q = vec2(length(pr.xy)-2., pr.z);
    
    rotate(q.xy, +iTime*2.+ata*3.);
    
    q.xy = abs(q.xy)-.25;
    
    rotate(q.xy, -iTime*2.+ata*8. );
    q.xy = abs(q.xy)-.1; // .25 == butterflys
    rotate(q.xy, +iTime*2.+ata*4. );
    q.xy = abs(q.xy)-.051;
    balls = mylength(q)+(-.0305-.011*(abs(ata)-3.00));//sin(6.28*ata+iTime)*1.;
    p.y -= 2.;
    rotate(p.xz , iTime*1.);
    float	light = dot(p,p);
    balls = max(balls, -(light-.65) ); // Cut the extremities

	#ifdef	FUDGE
    balls *= .5;
    #endif
    rotate(p.yx, iTime*.5);
    #ifdef	FUDGE
    lumos = length(p.y-18.)-10.1;
    h += .251/(lumos + 10.1)*vec3(.0,.0,.5);
    lumos = length(p.y+18.)-10.1;
    h += .251/(lumos + 10.1)*vec3(.0, .5, .0);
    balls = min(balls, light);
    volumetric += .0251/(light+.01)*vec3(.085,.105,.505);
    #else
    lumos = length(p.y-18.)-10.1;
    h += .51/(lumos + 10.1)*vec3(.0,.0,.5);
    lumos = length(p.y+18.)-10.1;
    h += .51/(lumos + 10.1)*vec3(.0, .5, .0);
    balls = min(balls, light);
    volumetric += .051/(light+.01)*vec3(.085,.105,.505);
    #endif
	
    return(balls);
}

vec4	march(vec3 pos, vec3 dir)
{
    vec2	dist = vec2(0.0, 0.0);
    vec3	p = vec3(0.0, 0.0, 0.0);
    vec4	step = vec4(0.0, 0.0, 0.0, 0.0);

    for (int i = -1; i < I_MAX; ++i)
    {
    	p = pos + dir * dist.y;
        dist.x = scene(p);
        dist.y += dist.x*1.;
        // log trick by aiekick
        if (log(dist.y*dist.y/dist.x/1e5)>0. || dist.x < E || dist.y >= FAR)
        {
            if (dist.x < E)
	            step.y = 1.;
            break;
        }
        step.x++;
    }
    step.w = dist.y;
    return (step);
}

// Utilities

float	mylength(vec3 p)
{
	float	ret = 1e5;
    
    p = p*p;
    p = p*p;
    p = p*p;
    
    ret = p.x + p.y + p.z;
    ret = pow(ret, 1./8.);
    
    return ret;
}

float	mylength(vec2 p)
{
	float	ret = 1e5;
    
    p = p*p;
    p = p*p;
    p = p*p;
    
    ret = p.x + p.y;
    ret = pow(ret, 1./8.);
    
    return ret;
}

void rotate(inout vec2 v, float angle)
{
	v = vec2(cos(angle)*v.x+sin(angle)*v.y,-sin(angle)*v.x+cos(angle)*v.y);
}

vec3 calcNormal( in vec3 pos, float e, vec3 dir)
{
    vec3 eps = vec3(e,0.0,0.0);

	return normalize(vec3(
           march(pos+eps.xyy, dir).w - march(pos-eps.xyy, dir).w,
           march(pos+eps.yxy, dir).w - march(pos-eps.yxy, dir).w,
           march(pos+eps.yyx, dir).w - march(pos-eps.yyx, dir).w ));
}

vec3	camera(vec2 uv)
{
    float		fov = 1.;
	vec3		forw  = vec3(0.0, 0.0, -1.0);
	vec3    	right = vec3(1.0, 0.0, 0.0);
	vec3    	up    = vec3(0.0, 1.0, 0.0);

    return (normalize((uv.x) * right + (uv.y) * up + fov * forw));
}

*/

/*


//     License : Copyright (C) 2011 Ashima Arts. All rights reserved.
//               Distributed under the MIT License. See LICENSE file.
//               https://github.com/ashima/webgl-noise
//               https://github.com/stegu/webgl-noise

vec4 mod289(vec4 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0; }

float mod289(float x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0; }

vec4 permute(vec4 x) {
     return mod289(((x*34.0)+1.0)*x);
}

float permute(float x) {
     return mod289(((x*34.0)+1.0)*x);
}

vec4 taylorInvSqrt(vec4 r)
{
  return 1.79284291400159 - 0.85373472095314 * r;
}

float taylorInvSqrt(float r)
{
  return 1.79284291400159 - 0.85373472095314 * r;
}

vec4 grad4(float j, vec4 ip)
  {
  const vec4 ones = vec4(1.0, 1.0, 1.0, -1.0);
  vec4 p,s;

  p.xyz = floor( fract (vec3(j) * ip.xyz) * 7.0) * ip.z - 1.0;
  p.w = 1.5 - dot(abs(p.xyz), ones.xyz);
  s = vec4(lessThan(p, vec4(0.0)));
  p.xyz = p.xyz + (s.xyz*2.0 - 1.0) * s.www; 

  return p;
  }
						
// (sqrt(5) - 1)/4 = F4, used once below
#define F4 0.309016994374947451

float snoise(vec4 v)
  {
  const vec4  C = vec4( 0.138196601125011,  // (5 - sqrt(5))/20  G4
                        0.276393202250021,  // 2 * G4
                        0.414589803375032,  // 3 * G4
                       -0.447213595499958); // -1 + 4 * G4

// First corner
  vec4 i  = floor(v + dot(v, vec4(F4)) );
  vec4 x0 = v -   i + dot(i, C.xxxx);

// Other corners

// Rank sorting originally contributed by Bill Licea-Kane, AMD (formerly ATI)
  vec4 i0;
  vec3 isX = step( x0.yzw, x0.xxx );
  vec3 isYZ = step( x0.zww, x0.yyz );
//  i0.x = dot( isX, vec3( 1.0 ) );
  i0.x = isX.x + isX.y + isX.z;
  i0.yzw = 1.0 - isX;
//  i0.y += dot( isYZ.xy, vec2( 1.0 ) );
  i0.y += isYZ.x + isYZ.y;
  i0.zw += 1.0 - isYZ.xy;
  i0.z += isYZ.z;
  i0.w += 1.0 - isYZ.z;

  // i0 now contains the unique values 0,1,2,3 in each channel
  vec4 i3 = clamp( i0, 0.0, 1.0 );
  vec4 i2 = clamp( i0-1.0, 0.0, 1.0 );
  vec4 i1 = clamp( i0-2.0, 0.0, 1.0 );

  //  x0 = x0 - 0.0 + 0.0 * C.xxxx
  //  x1 = x0 - i1  + 1.0 * C.xxxx
  //  x2 = x0 - i2  + 2.0 * C.xxxx
  //  x3 = x0 - i3  + 3.0 * C.xxxx
  //  x4 = x0 - 1.0 + 4.0 * C.xxxx
  vec4 x1 = x0 - i1 + C.xxxx;
  vec4 x2 = x0 - i2 + C.yyyy;
  vec4 x3 = x0 - i3 + C.zzzz;
  vec4 x4 = x0 + C.wwww;

// Permutations
  i = mod289(i); 
  float j0 = permute( permute( permute( permute(i.w) + i.z) + i.y) + i.x);
  vec4 j1 = permute( permute( permute( permute (
             i.w + vec4(i1.w, i2.w, i3.w, 1.0 ))
           + i.z + vec4(i1.z, i2.z, i3.z, 1.0 ))
           + i.y + vec4(i1.y, i2.y, i3.y, 1.0 ))
           + i.x + vec4(i1.x, i2.x, i3.x, 1.0 ));

// Gradients: 7x7x6 points over a cube, mapped onto a 4-cross polytope
// 7*7*6 = 294, which is close to the ring size 17*17 = 289.
  vec4 ip = vec4(1.0/294.0, 1.0/49.0, 1.0/7.0, 0.0) ;

  vec4 p0 = grad4(j0,   ip);
  vec4 p1 = grad4(j1.x, ip);
  vec4 p2 = grad4(j1.y, ip);
  vec4 p3 = grad4(j1.z, ip);
  vec4 p4 = grad4(j1.w, ip);

// Normalise gradients
  vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
  p0 *= norm.x;
  p1 *= norm.y;
  p2 *= norm.z;
  p3 *= norm.w;
  p4 *= taylorInvSqrt(dot(p4,p4));

// Mix contributions from the five corners
  vec3 m0 = max(0.6 - vec3(dot(x0,x0), dot(x1,x1), dot(x2,x2)), 0.0);
  vec2 m1 = max(0.6 - vec2(dot(x3,x3), dot(x4,x4)            ), 0.0);
  m0 = m0 * m0;
  m1 = m1 * m1;
  return 49.0 * ( dot(m0*m0, vec3( dot( p0, x0 ), dot( p1, x1 ), dot( p2, x2 )))
               + dot(m1*m1, vec2( dot( p3, x3 ), dot( p4, x4 ) ) ) ) ;

  }

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord/iResolution.xy;

    float s = 30.0+cos(iTime*0.1+uv.x)*10.;
    float s2 = 30.0+cos(iTime*0.1+uv.x)*10.;
    float s3 = 30.0+cos(iTime*0.1+uv.x)*10.;
    
    float ox = iTime*10.5;
    float oy = -iTime*1.0;
    
    float zz = cos(uv.y*5.*cos(iTime*0.1))*sin(uv.x*sin(iTime*0.1));
    
    // torus mapping: 2d periodic tiling texture by embedding a 4d torus
    float noise = snoise(vec4(sin(ox+uv.x*s+zz), cos(ox+uv.x*s-zz), sin(oy+uv.y*s-zz), cos(oy+uv.y*s+zz)));
	float noise2 = snoise(vec4(sin(ox+uv.x*s2+zz), cos(ox+uv.x*s2-zz), sin(oy+uv.y*s2-zz), cos(oy+uv.y*s2+zz)));
	float noise3 = snoise(vec4(sin(ox+uv.x*s3+zz), cos(ox+uv.x*s3-zz), sin(oy+uv.y*s3-zz), cos(oy+uv.y*s3+zz)));

    vec3 col = vec3(noise,noise2*2., noise3*3.);

    fragColor = vec4(col,1.0);
}

*/



/*

//https://www.shadertoy.com/view/fsdyzj

// "Borromean Rings" by dr2 - 2019
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

vec2	march(vec3 pos, vec3 dir);
vec3	camera(vec2 uv);
void	rotate(inout vec2 v, float angle);
vec3	calcNormal( in vec3 pos, float e, vec3 dir);
float	loop_circle(vec3 p);
float	circle(vec3 p, float phase);
float	sdTorus( vec3 p, vec2 t, float phase );
float	mylength(vec2 p);
float	nrand( vec2 n );

float 	t;			// time
vec3	ret_col;	// torus color
vec3	h; 			// light amount

#define I_MAX		200.
#define E			0.0001
#define FAR			10.
#define PI			3.14

void mainImage(out vec4 c_out, in vec2 f)
{
    t  = iTime*.125;
    vec3	col = vec3(0., 0., 0.);
	vec2 R = iResolution.xy,
          uv  = vec2(f-R/2.) / R.y;
	vec3	dir = camera(uv);
    vec3	pos = vec3(.0, .0, 0.0);

    pos.z = 4.5+1.5*sin(t*10.);    
    h*=0.;
    vec2	inter = (march(pos, dir));
    if (inter.y <= FAR)
        col.xyz = ret_col*(1.-inter.x*.0025);
    else
        col *= 0.;
    col += h*.005125;
    c_out =  vec4(col,1.0);
}

float	scene(vec3 p)
{  
    float	var;
    float	mind = 1e5;
    rotate(p.xz, 1.57-.5*iTime);
    rotate(p.yz, 1.57-.5*iTime);
    vec2 q = vec2(length(p.xy)-2.,p.z);
    
    var =
        step(cos(floor( (atan(p.x,p.y))*10.)/1.+iTime*1.)*3.14, atan(q.x, p.z ))
        *
        step(atan(q.x, p.z )-2., cos(floor( (atan(p.x,p.y))*10.)/1.+iTime*1.)*3.14)
        ;
    
    ret_col = 1.-vec3(.5-var*.5, .5, .3+var*.5);
    mind = mylength(q)-.5-.1*var;
    h += vec3(.5,.8,.5)*(var!=0.?0.:1.)*vec3(1.)*.0125/(.01+(mind-var*.1)*(mind-var*.1) );
    h += vec3(.5,.8,.5)*(var!=0.?1.:0.)*vec3(1.)*.0125/(.01+mind*mind);
    
    return (mind);
}

vec2	march(vec3 pos, vec3 dir)
{
    vec2	dist = vec2(0.0, 0.0);
    vec3	p = vec3(0.0, 0.0, 0.0);
    vec2	s = vec2(0.0, 0.0);

	    for (float i = -1.; i < I_MAX; ++i)
	    {
	    	p = pos + dir * dist.y;
	        dist.x = scene(p);
	        dist.y += dist.x*.2; // makes artefacts disappear
	        if (dist.x < E || dist.y > FAR)
            {
                break;
            }
	        s.x++;
    }
    s.y = dist.y;
    return (s);
}

float	mylength(vec2 p)
{
	float	ret;
    
    p = p*p*p*p;
    p = p*p;
    ret = (p.x+p.y);
    ret = pow(ret, 1./8.);
    
    return ret;
}

// Utilities

void rotate(inout vec2 v, float angle)
{
	v = vec2(cos(angle)*v.x+sin(angle)*v.y,-sin(angle)*v.x+cos(angle)*v.y);
}

vec2	rot(vec2 p, vec2 ang)
{
	float	c = cos(ang.x);
    float	s = sin(ang.y);
    mat2	m = mat2(c, -s, s, c);
    
    return (p * m);
}

vec3	camera(vec2 uv)
{
    float		fov = 1.;
	vec3		forw  = vec3(0.0, 0.0, -1.0);
	vec3    	right = vec3(1.0, 0.0, 0.0);
	vec3    	up    = vec3(0.0, 1.0, 0.0);

    return (normalize((uv.x) * right + (uv.y) * up + fov * forw));
}

vec3 calcNormal( in vec3 pos, float e, vec3 dir)
{
    vec3 eps = vec3(e,0.0,0.0);

    return normalize(vec3(
           march(pos+eps.xyy, dir).y - march(pos-eps.xyy, dir).y,
           march(pos+eps.yxy, dir).y - march(pos-eps.yxy, dir).y,
           march(pos+eps.yyx, dir).y - march(pos-eps.yyx, dir).y ));
}
*/


/*
//https://www.shadertoy.com/view/wddXDX

vec4 mod289(vec4 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0; }

float mod289(float x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0; }

vec4 permute(vec4 x) {
     return mod289(((x*34.0)+1.0)*x);
}

float permute(float x) {
     return mod289(((x*34.0)+1.0)*x);
}

vec4 taylorInvSqrt(vec4 r)
{
  return 1.79284291400159 - 0.85373472095314 * r;
}

float taylorInvSqrt(float r)
{
  return 1.79284291400159 - 0.85373472095314 * r;
}

vec4 grad4(float j, vec4 ip)
  {
  const vec4 ones = vec4(1.0, 1.0, 1.0, -1.0);
  vec4 p,s;

  p.xyz = floor( fract (vec3(j) * ip.xyz) * 7.0) * ip.z - 1.0;
  p.w = 1.5 - dot(abs(p.xyz), ones.xyz);
  s = vec4(lessThan(p, vec4(0.0)));
  p.xyz = p.xyz + (s.xyz*2.0 - 1.0) * s.www; 

  return p;
  }
						
// (sqrt(5) - 1)/4 = F4, used once below
#define F4 0.309016994374947451

float snoise(vec4 v)
  {
  const vec4  C = vec4( 0.138196601125011,  // (5 - sqrt(5))/20  G4
                        0.276393202250021,  // 2 * G4
                        0.414589803375032,  // 3 * G4
                       -0.447213595499958); // -1 + 4 * G4

// First corner
  vec4 i  = floor(v + dot(v, vec4(F4)) );
  vec4 x0 = v -   i + dot(i, C.xxxx);

// Other corners

// Rank sorting originally contributed by Bill Licea-Kane, AMD (formerly ATI)
  vec4 i0;
  vec3 isX = step( x0.yzw, x0.xxx );
  vec3 isYZ = step( x0.zww, x0.yyz );
//  i0.x = dot( isX, vec3( 1.0 ) );
  i0.x = isX.x + isX.y + isX.z;
  i0.yzw = 1.0 - isX;
//  i0.y += dot( isYZ.xy, vec2( 1.0 ) );
  i0.y += isYZ.x + isYZ.y;
  i0.zw += 1.0 - isYZ.xy;
  i0.z += isYZ.z;
  i0.w += 1.0 - isYZ.z;

  // i0 now contains the unique values 0,1,2,3 in each channel
  vec4 i3 = clamp( i0, 0.0, 1.0 );
  vec4 i2 = clamp( i0-1.0, 0.0, 1.0 );
  vec4 i1 = clamp( i0-2.0, 0.0, 1.0 );

  //  x0 = x0 - 0.0 + 0.0 * C.xxxx
  //  x1 = x0 - i1  + 1.0 * C.xxxx
  //  x2 = x0 - i2  + 2.0 * C.xxxx
  //  x3 = x0 - i3  + 3.0 * C.xxxx
  //  x4 = x0 - 1.0 + 4.0 * C.xxxx
  vec4 x1 = x0 - i1 + C.xxxx;
  vec4 x2 = x0 - i2 + C.yyyy;
  vec4 x3 = x0 - i3 + C.zzzz;
  vec4 x4 = x0 + C.wwww;

// Permutations
  i = mod289(i); 
  float j0 = permute( permute( permute( permute(i.w) + i.z) + i.y) + i.x);
  vec4 j1 = permute( permute( permute( permute (
             i.w + vec4(i1.w, i2.w, i3.w, 1.0 ))
           + i.z + vec4(i1.z, i2.z, i3.z, 1.0 ))
           + i.y + vec4(i1.y, i2.y, i3.y, 1.0 ))
           + i.x + vec4(i1.x, i2.x, i3.x, 1.0 ));

// Gradients: 7x7x6 points over a cube, mapped onto a 4-cross polytope
// 7*7*6 = 294, which is close to the ring size 17*17 = 289.
  vec4 ip = vec4(1.0/294.0, 1.0/49.0, 1.0/7.0, 0.0) ;

  vec4 p0 = grad4(j0,   ip);
  vec4 p1 = grad4(j1.x, ip);
  vec4 p2 = grad4(j1.y, ip);
  vec4 p3 = grad4(j1.z, ip);
  vec4 p4 = grad4(j1.w, ip);

// Normalise gradients
  vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
  p0 *= norm.x;
  p1 *= norm.y;
  p2 *= norm.z;
  p3 *= norm.w;
  p4 *= taylorInvSqrt(dot(p4,p4));

// Mix contributions from the five corners
  vec3 m0 = max(0.6 - vec3(dot(x0,x0), dot(x1,x1), dot(x2,x2)), 0.0);
  vec2 m1 = max(0.6 - vec2(dot(x3,x3), dot(x4,x4)            ), 0.0);
  m0 = m0 * m0;
  m1 = m1 * m1;
  return 49.0 * ( dot(m0*m0, vec3( dot( p0, x0 ), dot( p1, x1 ), dot( p2, x2 )))
               + dot(m1*m1, vec2( dot( p3, x3 ), dot( p4, x4 ) ) ) ) ;

  }

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord/iResolution.xy;

    float s = 30.0+cos(iTime*0.1+uv.x)*10.;
    float s2 = 30.0+cos(iTime*0.1+uv.x)*10.;
    float s3 = 30.0+cos(iTime*0.1+uv.x)*10.;
    
    float ox = iTime*10.5;
    float oy = -iTime*1.0;
    
    float zz = cos(uv.y*5.*cos(iTime*0.1))*sin(uv.x*sin(iTime*0.1));
    
    // torus mapping: 2d periodic tiling texture by embedding a 4d torus
    float noise = snoise(vec4(sin(ox+uv.x*s+zz), cos(ox+uv.x*s-zz), sin(oy+uv.y*s-zz), cos(oy+uv.y*s+zz)));
	float noise2 = snoise(vec4(sin(ox+uv.x*s2+zz), cos(ox+uv.x*s2-zz), sin(oy+uv.y*s2-zz), cos(oy+uv.y*s2+zz)));
	float noise3 = snoise(vec4(sin(ox+uv.x*s3+zz), cos(ox+uv.x*s3-zz), sin(oy+uv.y*s3-zz), cos(oy+uv.y*s3+zz)));

    vec3 col = vec3(noise,noise2*2., noise3*3.);

    fragColor = vec4(col,1.0);
}
*/


/*
//https://www.shadertoy.com/view/dslXDl
#define TIME            iTime
#define RESOLUTION      iResolution

#define PI              3.141592654
#define PI_2            (0.5*PI)
#define TAU             (2.0*PI)
#define ROT(a)          mat2(cos(a), sin(a), -sin(a), cos(a))

// License: WTFPL, author: sam hocevar, found: https://stackoverflow.com/a/17897228/418488
const vec4 hsv2rgb_K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
vec3 hsv2rgb(vec3 c) {
  vec3 p = abs(fract(c.xxx + hsv2rgb_K.xyz) * 6.0 - hsv2rgb_K.www);
  return c.z * mix(hsv2rgb_K.xxx, clamp(p - hsv2rgb_K.xxx, 0.0, 1.0), c.y);
}
// License: WTFPL, author: sam hocevar, found: https://stackoverflow.com/a/17897228/418488
//  Macro version of above to enable compile-time constants
#define HSV2RGB(c)  (c.z * mix(hsv2rgb_K.xxx, clamp(abs(fract(c.xxx + hsv2rgb_K.xyz) * 6.0 - hsv2rgb_K.www) - hsv2rgb_K.xxx, 0.0, 1.0), c.y))

// License: MIT, author: Pascal Gilcher, found: https://www.shadertoy.com/view/flSXRV
float atan_approx(float y, float x) {
  float cosatan2 = x / (abs(x) + abs(y));
  float t = PI_2 - cosatan2 * PI_2;
  return y < 0.0 ? -t : t;
}

// License: MIT, author: Inigo Quilez, found: https://www.iquilezles.org/www/articles/smin/smin.htm
float pmin(float a, float b, float k) {
  float h = clamp(0.5+0.5*(b-a)/k, 0.0, 1.0);
  return mix(b, a, h) - k*h*(1.0-h);
}

// License: CC0, author: Mårten Rånge, found: https://github.com/mrange/glsl-snippets
float pabs(float a, float k) {
  return -pmin(a, -a, k);
}

float starN(vec2 p, float r) {
  const float n = 6.0;
  const float m = 4.0;

  // next 4 lines can be precomputed for a given shape
  const float an = 3.141593/float(n);
  const float en = 3.141593/m;  // m is between 2 and n
  const vec2  acs = vec2(cos(an),sin(an));
  const vec2  ecs = vec2(cos(en),sin(en)); // ecs=vec2(0,1) for regular polygon

    float bn = mod(atan_approx(p.x,p.y),2.0*an) - an;
    p = length(p)*vec2(cos(bn),pabs(sin(bn), 0.5));
    p -= r*acs;
    p += ecs*clamp( -dot(p,ecs), 0.0, r*acs.y/ecs.y);
    return length(p)*sign(p.x);
}

float weirdTorus(vec3 p, vec3 d) {
  vec2 q = vec2(length(p.xz) - d.x, p.y);
  float a = atan_approx(p.x, p.z);
  const float off = PI*0.875;
  a = abs(a);
  float b = a;
  b -= off;
  b = -pabs(b, 1.0);
  b += off;
  a *= b;
  mat2 r = ROT(-4.0*a/6.0);
  return starN(r*q, d.y)-d.z;
}

float dd(vec3 p) {
  const float z = 0.25;
  return weirdTorus(p/z, vec3(2.0, 0.65, 0.025))*z;
}

vec3 nn(vec3 pos, float aa) {
  vec2  eps = vec2(aa,0.0);
  vec3 nor;
  nor.x = dd(pos+eps.xyy) - dd(pos-eps.xyy);
  nor.y = dd(pos+eps.yxy) - dd(pos-eps.yxy);
  nor.z = dd(pos+eps.yyx) - dd(pos-eps.yyx);
  return normalize(nor);
}

vec3 effect2(vec2 p) {
#ifdef ORIGINAL
  const vec3 gcol0 = HSV2RGB(vec3(0.8, 0.95, 1.0));
  const vec3 gcol1 = HSV2RGB(vec3(0.2, 0.95, 1.0));
  const vec3 gcol2 = HSV2RGB(vec3(0.5, 0.95, 1.0));
  const vec3 gcol3 = HSV2RGB(vec3(0.95, 0.9, 0.01));
  const vec3 scol0 = HSV2RGB(vec3(0.95, 0.9, 1.0));
  const vec3 scol1 = HSV2RGB(vec3(0.55, 0.8, 0.1));
  const vec3 white = vec3(1.0);
  
  float aa = 2.0/RESOLUTION.y;
  vec3 p3 = vec3(p.x, -0.15*cos(0.1*TIME), p.y);
  float d = dd(p3);
  vec3 n = nn(p3, aa);
#else
  float hoff = fract(0.05*p.y+0.1*p.x+0.02*TIME);
  vec3 gcol0 = hsv2rgb(vec3(hoff+0.8, 0.95, 1.0));
  vec3 gcol1 = hsv2rgb(vec3(hoff+0.2, 0.95, 1.0));
  vec3 gcol2 = hsv2rgb(vec3(hoff+0.5, 0.95, 1.0));
  vec3 gcol3 = hsv2rgb(vec3(hoff+0.95, 0.9, 0.01));
  vec3 scol0 = hsv2rgb(vec3(0.95, 0.9, 1.0));
  vec3 scol1 = hsv2rgb(vec3(0.55, 0.8, 0.1));
  const vec3 white = vec3(1.0);
  
  
  float aa = 2.0/RESOLUTION.y;
  vec3 p3 = vec3(p.x, -0.15*cos(0.1*TIME), p.y);
  float d = dd(p3);
  p3.y = -0.15*cos(0.1*TIME-PI*smoothstep(0.55, 1.5, length(p)));
  vec3 n = nn(p3, aa);
#endif

  d /= length(n.xz);
  
  vec3 col = vec3(0.05);
  
  vec3 gcol = vec3(0.0);
  gcol += gcol0*abs(n.x);
  gcol += gcol1*(n.y);
  gcol += gcol2*(n.z);
  
  col += gcol;
  vec3 bcol = col;
  col *= mix(white, scol0, exp(-8.0*max(d-0.025, 0.0)));
  col = mix(col, white, smoothstep(aa, -aa, d-0.01));
  col = mix(col, scol1*bcol, smoothstep(aa, -aa, d));
  col = max(col, 0.0);
  col += gcol3*mix(1.0, 2.0, smoothstep(0.0, 1.0, sin((0.5*125.0/60.0)*TAU*TIME)))/dot(p, p);
  return col;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec2 q = fragCoord/RESOLUTION.xy;
  vec2 p = -1. + 2. * q;
  vec2 pp = p;
  p.x *= RESOLUTION.x/RESOLUTION.y;
  vec3 col = vec3(0.0);
  col = effect2(p);
  col *= smoothstep(1.5, 0.5, length(pp));
  col = sqrt(col);
  fragColor = vec4(col, 1.0);
}
*/

/*
//https://www.shadertoy.com/view/3lBBWG

float random(vec2 v) {
    return fract(sin(v.x * 32.1231 - v.y * 2.334 + 13399.2312) * 2412.32312);
}
float random(float x, float y) {
    return fract(sin(x * 32.1231 - y * 2.334 + 13399.2312) * 2412.32312);
}
float random(float x) {
    return fract(sin(x * 32.1231 + 13399.2312) * 2412.32312);
}

float hue2rgb(float f1, float f2, float hue) {
    if (hue < 0.0)
        hue += 1.0;
    else if (hue > 1.0)
        hue -= 1.0;
    float res;
    if ((6.0 * hue) < 1.0)
        res = f1 + (f2 - f1) * 6.0 * hue;
    else if ((2.0 * hue) < 1.0)
        res = f2;
    else if ((3.0 * hue) < 2.0)
        res = f1 + (f2 - f1) * ((2.0 / 3.0) - hue) * 6.0;
    else
        res = f1;
    return res;
}
vec3 hsl2rgb(vec3 hsl) {
    vec3 rgb;
    
    if (hsl.y == 0.0) {
        rgb = vec3(hsl.z); // Luminance
    } else {
        float f2;
        
        if (hsl.z < 0.5)
            f2 = hsl.z * (1.0 + hsl.y);
        else
            f2 = hsl.z + hsl.y - hsl.y * hsl.z;
            
        float f1 = 2.0 * hsl.z - f2;
        
        rgb.r = hue2rgb(f1, f2, hsl.x + (1.0/3.0));
        rgb.g = hue2rgb(f1, f2, hsl.x);
        rgb.b = hue2rgb(f1, f2, hsl.x - (1.0/3.0));
    }   
    return rgb;
}

int character(float i) {
    if (i == 0.) return 0x7b6f; // 0
    if (i == 1.) return 0x4d24; // 1
    if (i == 2.) return 0x79cf; // 2
    if (i == 3.) return 0x79e7; // 3
    if (i == 4.) return 0x5be4; // 4
    if (i == 5.) return 0x73e7; // 5
    if (i == 6.) return 0x73ef; // 6
    if (i == 7.) return 0x7924; // 7
    if (i == 8.) return 0x7bef; // 8
    if (i == 9.) return 0x7be7; // 9
    if (i == 10.) return 0x7bed; // A
    if (i == 11.) return 0x3beb; // B
    if (i == 12.) return 0x724f; // C
    if (i == 13.) return 0x3b6b; // D
    if (i == 14.) return 0x73cf; // E
    if (i == 15.) return 0x73c9; // F
    return 0;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 S = 15. * vec2(3., 2.);
    vec2 coord = vec2(
        fragCoord.x / iResolution.y,
        fragCoord.y / iResolution.y + (iResolution.y - iResolution.x) / (2. * iResolution.y)
    );
    vec2 c = floor(coord * S);

    float offset = random(c.x) * S.x;
    float speed = (random(c.x * 3.) * 1. + 0.5) * .7;
    float len = random(c.x) * 15. + 10.;
    float X = c.y / len + iTime * speed + offset, _X = mod(X, 1.);
    float u = 1. - 2. * 1.23 * _X * (1.45 * _X) * (1. - pow(_X, 9.));

    float padding = 2.;
    vec2 smS = vec2(3., 5.);
    vec2 sm = floor(fract(coord * S) * (smS + vec2(padding))) - vec2(padding);
    int symbol = character(floor(random(c + floor(iTime * speed)) * 15.));
    bool s = sm.x < 0. || sm.x > smS.x || sm.y < 0. || sm.y > smS.y ? false
             : mod(floor(float(symbol) / pow(2., sm.x + sm.y * smS.x)), 2.) == 1.;

    fragColor = vec4(s ? hsl2rgb(vec3(c.x / S.x, 1., 0.5)) * u : vec3(0.), 1.);
}
*/

/*
//https://www.shadertoy.com/view/dd2XDw

int STEPS = 30;
const float FAR = 30.;

// Taken from vgs
// https://www.shadertoy.com/view/Ml3Gz8
// Polynomial smooth min (for copying and pasting into your shaders)
float smin(float a, float b, float k) {
    float h = clamp(0.5 + 0.5*(a-b)/k, 0.0, 1.0);
    return mix(a, b, h) - k*h*(1.0-h);
}
// Hash function from Dave_Hoskins
// https://www.shadertoy.com/view/4djSRW
float hash12(vec2 p) {
	vec3 p3  = fract(vec3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}
float hash13(vec3 p3)
{
	p3  = fract(p3 * .1031);
    p3 += dot(p3, p3.zyx + 31.32);
    return fract((p3.x + p3.y) * p3.z);
}

vec2 position(float z) {
    return vec2(cos(z-1.5*iTime),sin(.7*z+iTime));
}

float sdBall(vec3 p, out vec3 color) {
    vec2 id = floor((p.xy)/6.);
    p.xy = mod(p.xy,6.)-3.;

    float shift = dot(vec2(3.45,12.8),id);
    p.z += shift;
        
    color = vec3(1);

    float speed = 6.*hash12(id+35.156)+4.;
    float direction = 2.*step(.5,hash12(id+315.81))-1.;
    
    shift = direction*speed*iTime;
    vec3 iid = vec3(id,round((p.z-shift)/8.));
    vec3 c;
    float h1 = .24*hash13(iid);
    float h2 = hash13(iid+153.42);
    c.z = 8.*iid.z+direction*speed*mix(iTime,floor(iTime)+smoothstep(h1,1.-h1,fract(iTime)),h2);
    
    c.xy = position(c.z).xy;
    return length(p-c)-1.;
}

float sdTube(vec3 p, out vec3 color) {
    vec2 id = floor((p.xy)/6.);
    p.xy = mod(p.xy,6.)-3.;

    float shift = dot(vec2(3.45,12.8),id);
    p.z += shift;
    
    // Tube
    vec2 pos = position(p.z);
    float tubes = .4*(length(p.xy-pos)-.5+.2*cos(p.z));
    
    // Balls
    float speed = 6.*hash12(id+35.156)+4.;
    float direction = 2.*step(.5,hash12(id+315.81))-1.;
    
    shift = direction*speed*iTime;
    vec3 iid = vec3(id,round((p.z-shift)/8.));
    vec3 c;
    float h1 = .24*hash13(iid);
    float h2 = hash13(iid+153.42);
    c.z = 8.*iid.z+direction*speed*mix(iTime,floor(iTime)+smoothstep(h1,1.-h1,fract(iTime)),h2);
    
    c.xy = position(c.z).xy;
    float balls = length(p-c)-1.;
    
    float k = .05+.95*smoothstep(1.,.1,balls);
    color = k*(.5+.5*cos(vec3(2,3,3)+.8*cos(id.xyx)));

    return smin(tubes,balls,1.);
}

float sd(vec3 p, out vec3 color) {
    float d = 1e3;
    
    for(float i=-1.; i<=1.; i++) {
        vec3 q = p;
        q.z = .5*(round(2.*p.z)+i);
        d = min(d,length(max(vec2(abs(sdTube(q,color)),abs(q.z-p.z)),0.))-.1);
    }
    vec3 c;
    float ball = sdBall(p,c);
    color = ball<d ? c : color;
    
    return min(d,ball);
}
vec3 rayColor(vec3 ro, vec3 rd) {
    float e = .2/iResolution.y;
    float t;
    vec3 glow;
    for(int i=0; i<STEPS; i++) {
        vec3 p = ro+t*rd;
        vec3 c;
        float d = sd(p,c);
        glow += c/(1.+100.*d*d)*exp(-.005*t*t);
        if(d<e) break;
        t += d;
        if(t>FAR) break;
    }
    return glow;
}
mat3 viewMatrix(vec3 forward, vec3 up) {
 	vec3 w = -normalize(forward);
    vec3 u = normalize(cross(up, w));
    vec3 v = cross(w, u);
    
    return mat3(u,v,w);
}
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float t = .5*iTime;
    vec3 ro = vec3(-8.*t,.5,2.5*iTime);
    vec3 rd = normalize(vec3(.6*(2.*fragCoord-iResolution.xy)/iResolution.y,-1.));
    
    vec2 uv = fragCoord/iResolution.xy;
    STEPS = int(10.+100.*16.*uv.x*(1.-uv.x)*uv.y*(1.-uv.y));
    vec3 forward = vec3(-1,.8,.5*cos(2.*t));
    vec3 up = vec3(0,1,0);
    mat3 m = viewMatrix(forward,up);
    rd = m*rd;
    
    vec3 col = rayColor(ro,rd);

    col = min(col,1.);
    col = pow(col,vec3(.45));
    fragColor = vec4(col,1.0);
}
*/

//https://www.shadertoy.com/view/l3sfzs

#define Rot(a) mat2(cos(a),-sin(a),sin(a),cos(a))
#define antialiasing(n) n/min(iResolution.y,iResolution.x)
#define S2(d,b) smoothstep(1.,-1., (d - b) / fwidth(d) )
#define S(d,b) smoothstep(antialiasing(2.),-antialiasing(2.),d - b)
#define B(p,s) max(abs(p).x-s.x,abs(p).y-s.y)
#define deg45 .707
#define R45(p) (( p + vec2(p.y,-p.x) ) *deg45)
#define Tri(p,s) max(R45(p).x,max(R45(p).y,B(p,s)))
#define DF(a,b) length(a) * cos( mod( atan(a.y,a.x)+6.28/(b*8.0), 6.28/((b*8.0)*0.5))+(b-1.)*6.28/(b*8.0) + vec2(0,11) )
#define SkewX(a) mat2(1.0,tan(a),0.0,1.0)
#define SkewY(a) mat2(1.0,0.0,tan(a),1.0)
// https://en.wikipedia.org/wiki/Log-polar_coordinates
#define PUV(p)vec2(log(length(p)),atan(p.y/p.x))

float Hash(vec2 p){
    vec2 randP = fract(sin(p*123.456)*567.89);
    randP += dot(randP,randP*34.56);
    float n = fract(randP.x*randP.y); 
    return n;
}


// thx iq! https://iquilezles.org/articles/distfunctions/
float smin( float d1, float d2, float k )
{
    float h = clamp( 0.5 + 0.5*(d2-d1)/k, 0.0, 1.0 );
    return mix( d2, d1, h ) - k*h*(1.0-h);
}

float bat(vec2 p){
    p.x*=1.+sin(iTime*5.)*0.05;
    vec2 prevP = p;

    p.x*=1.2;
    p.y*=-0.8;
    p-=vec2(0.,0.1);
    
    float d = Tri(p,vec2(0.1));
    p = prevP;
    p.x*=1.2;
    p.y*=-1.;
    p-=vec2(0.,0.03);
    float m = Tri(p,vec2(0.1));
    d = max(-m,d);
    p = prevP;
    p.x = abs(p.x)-0.11;
    p.y-=0.01;
    p.y*=0.7;
    p*=Rot(radians(-2.));
    float d2 = Tri(p,vec2(0.1));
    d = min(d,d2);
    
    p = prevP;
    p.x = abs(p.x)-0.11;
    p.y+=0.05;
    p.y*=0.7;
    p*=Rot(radians(-2.));
    m = Tri(p,vec2(0.1));
    d = max(-m,d);
    
    p = prevP;
    p.x = abs(p.x)-0.23;
    p.y*=-1.0;
    p-=vec2(0.,0.12);
    p*=SkewY(radians(35.));
    p*=Rot(radians(-12.));
    p*=vec2(0.7,0.55);
    d2 = Tri(p,vec2(0.1));
    d = min(d,d2);
    
    p = prevP;
    p.x = abs(p.x)-0.21;
    p.y*=-1.0;
    p-=vec2(0.015,0.07);
    p*=SkewY(radians(35.));
    p*=Rot(radians(-12.));
    p*=vec2(0.7,0.55);
    p*=1.8;
    m = Tri(p,vec2(0.1));
    d = max(-m,d);
    
    p = prevP;
    p.x = abs(p.x)-0.35;
    p-=vec2(0.035,0.041);
    p*=Rot(radians(-237.));
    p.x*=0.75;
    d2 = Tri(p,vec2(0.05));
    d = min(d,d2);
    
    p = prevP;
    p.x = abs(p.x)-0.35;
    p-=vec2(-0.025,-0.06);
    p*=Rot(radians(-237.));
    p.x*=0.75;
    d2 = Tri(p,vec2(0.05));
    d = min(d,d2);    
    
    p = prevP;
    p.x = abs(p.x)-0.045;
    p.x*=2.5;
    p.y*=0.9;
    p*=SkewX(radians(-60.));
    p-=vec2(0.,0.098);
    d2 = Tri(p,vec2(0.08));
    d = min(d,d2);
    
    p = prevP;
    p*=-1.;
    p.x*=1.8;
    p-=vec2(0.,0.235);
    d2 = Tri(p,vec2(0.08));
    d = min(d,d2);
    
    return d;
}

float punpkinBody(vec2 p){
    p.y*=1.15;
    vec2 prevP = p;
    float d = B(p,vec2(0.08));
    p.y = abs(p.y)-0.14;
    
    float d2 = B(p,vec2(0.08));
    float a = radians(10.);
    p.x = abs(p.x)-0.07;
    d2 = max(dot(p,vec2(cos(a),sin(a))),d2);
    d = min(d,d2);
    
    p = prevP;
    p.x = abs(p.x)-0.165;
    d2 = B(p,vec2(0.07,0.08));
    d = min(d,d2);
    p.y = abs(p.y)-0.15;
    p.y*=1.1;
    p.x+=0.012;
    p*=SkewX(radians(9.));
    d2 = B(p,vec2(0.07,0.08));
    a = radians(30.);
    p.x-=0.045;
    d2 = max(dot(p,vec2(cos(a),sin(a))),d2);
    d = min(d,d2);
    
    p = prevP;
    p.y = abs(p.y)-0.09;
    d = max(-B(p,vec2(10.,0.01)),d);
    return d;
}

float punpkin(vec2 p){
    vec2 prevP = p;
    float d = punpkinBody(p);
    p.x = abs(p.x)-0.1;
    p.x*=1.2;
    p.y-=0.14;
    p.y*=0.8;
    float m = Tri(p,vec2(0.08));
    d = max(-m,d);
    
    p = prevP;
    p.x*=1.5;
    p.y-=0.04;
    m = Tri(p,vec2(0.06));
    d = max(-m,d);
    
    p = prevP;
    p.y+=0.12;
    m = B(p,vec2(0.038,0.026));
    d = max(-m,d);
    p.x = abs(p.x)-0.1;
    p.y-=0.023;
    p*=Rot(radians(-20.));
    p*=SkewX(radians(-50.));
    
    m = B(p,vec2(0.1,0.025));
    
    p = prevP;
    m = max(-(p.y+0.145),m);
    d = max(-m,d);
    
    p.x = abs(p.x)-0.035;
    p.y+=0.06;
    p*=Rot(radians(-20.));
    m = Tri(p,vec2(0.04));
    d = max(-m,d);
    
    p = prevP;
    p.x = abs(p.x)-0.11;
    p.y+=0.03;
    p*=Rot(radians(-20.));
    m = Tri(p,vec2(0.04));
    d = max(-m,d);    
    
    p = prevP;
    p.x = abs(p.x)-0.11;
    p.y+=0.15;
    p.y*=-1.;
    p*=Rot(radians(20.));
    m = Tri(p,vec2(0.04));
    d = max(-m,d);   
    
    p = prevP;
    
    p.y-=0.25;
    p*=SkewX(radians(-15.));
    p.x -=0.01;
    float d2 = B(p,vec2(0.05,0.04));
    float a = radians(10.);
    p.x = abs(p.x)-0.03;
    d2 = max(dot(p,vec2(cos(a),sin(a))),d2);
    d = min(d,d2);
    
    return d;
}

float stripes(vec2 p, float dir){
    vec2 prevP = p;
    
    p*=Rot(radians(30.));
    p.x+=iTime*0.03*dir;
    p.x = mod(p.x,0.02)-0.01;
    
    float d = B(p,vec2(0.003,10.));
    return d;
}

float dots(vec2 p, float dir){
    p*=Rot(radians(30.));
    p.x+=iTime*0.03*dir;
    p = mod(p,0.04)-0.02;
    
    float d = length(p)-0.012;
    return d;
}

float candyParts(vec2 p){
    vec2 prevP = p;
    p.x = abs(p.x)-0.08;
    p.y*=1.3;
    p*=Rot(radians(-90.));
    float d = Tri(p,vec2(0.1));
    p.x*=0.3;
    p.y+=0.07;
    float m = Tri(p,vec2(0.1));
    d = max(-m,d);
    p = prevP;
    p.x = abs(p.x)-0.18;
    p.y*=1.3;
    p*=Rot(radians(90.));
    float d2 = Tri(p,vec2(0.05));
    d = min(d,d2);
    return d;
}

float candy(vec2 p){
    vec2 prevP = p;
    p.x*=0.7;
    float d = length(p)-0.08;
    p = prevP;
    float d2 = candyParts(p);
    d = min(d,d2);
    d = abs(d)-0.002;
    
    p.x*=0.7;
    d2 = max(min(d2,length(p)-0.08),stripes(p,1.));
    d = min(d,d2);
    
    return d;
}

float candy2(vec2 p){
    vec2 prevP = p;
    float d = abs(length(p-vec2(0.0,0.05))-0.05)-0.02;
    d = max(-p.y+0.05,d);
    float d2 = B(p-vec2(-0.05,-0.045),vec2(0.02,0.1));
    d = min(d,d2);
    
    return min(abs(d)-0.002,max(stripes(p,-1.),d));
}

float coffin(vec2 p){
    p*=Rot(radians(sin(iTime*5.)*5.));
    vec2 prevP = p;
    float d = B(p,vec2(0.1,0.2));
    float a = radians(15.);
    p.x = abs(p.x)-0.1;
    p.y-=0.05;
    d = max(dot(p,vec2(cos(a),sin(a))),d);
    p = prevP;
    
    a = radians(-10.);
    p.x = abs(p.x)-0.1;
    p.y-=0.04;
    d = abs(abs(max(dot(p,vec2(cos(a),sin(a))),d))-0.012)-0.005;
    
    p = prevP;
    p*=Rot(radians(sin(iTime*4.)*5.));
    p.y-=0.075;
    float d2 = B(p,vec2(0.05,0.01));
    d = min(d,d2);
    
    p = prevP;
    p*=Rot(radians(sin(iTime*4.)*5.));
    p.y-=0.025;
    d2 = B(p,vec2(0.01,0.1));
    d = min(d,d2);
    
    return d;
}

float spiderNetParts(vec2 p){
    vec2 prevP = p;
    p.x = abs(p.x)-0.06;
    p*=Rot(radians(30.));
    float d = B(p,vec2(0.005,0.13));
    
    float k = 10.0;
    
    p = prevP;
    p.y+=0.05;
    
    float c = cos(k*p.x);
    float s = sin(k*p.x);
    mat2  m = mat2(c,s,-s,c);
    p*=m;
    float d2 = B(p,vec2(0.04,0.004));
    d = min(d,d2);
    
    p = prevP;
    p.x*=0.45;
    p*=m;
    
    d2 = B(p,vec2(0.06,0.004));
    d = min(d,d2);
    
    p = prevP;
    p.y-=0.049;
    p.x*=0.18;
    p*=m;
    
    d2 = B(p,vec2(0.05,0.004));
    d = min(d,d2);    
    
    return d;
}

float spiderNet(vec2 p){
    vec2 prevP = p;
    p*=1.+sin(iTime*5.)*0.05;
    p = DF(p,vec2(1.5));
    p-=0.07;
    p*=Rot(radians(45.));
    float d = spiderNetParts(p);
    return d;
}

float ghostBase(vec2 p){
    vec2 prevP2 = p;
    p.x = abs(p.x);
    p*=SkewX(radians(10.));
    vec2 prevP = p;
    p.y-=0.05;
    float d = length(p)-0.1;
    p = prevP;
    p.y+=0.03;
    float d2 = B(p,vec2(0.1,0.08));
    d = min(d,d2);
    d = max(-p.x,d);
    p = prevP2;
    d2 = length(p-vec2(0.,0.07))-0.085;
    d = smin(d,d2,0.01);
    d2 = B(p-vec2(0.,-0.03),vec2(0.05,0.08));
    d = min(d,d2);
    return d;
}

float ghost(vec2 p){
    p.y*=1.+sin(iTime*5.)*0.05;
    vec2 prevP = p;
    float d = ghostBase(p);
    p.x-=iTime*0.05;
    p.x = mod(p.x,0.08)-0.04;
    p.y+=0.125;
    float d2 = length(p)-0.04;
    d = max(-d2,d);
    
    p = prevP;
    p.x*=1.8;
    p.x = abs(p.x)-0.045;
    p.y-=0.05;
    d2 = length(p)-0.03;
    d = max(-d2,d);
    
    p = prevP;
    p.x = abs(p.x)-0.11;
    p.y-=0.04;
    p*=Rot(radians(40.));
    p*=SkewY(radians(40.));
    p.x*=1.8;
    d2 = length(p)-0.04;
    d = min(d,d2);
    
    p = prevP;
    return max(stripes(p,-1.),d);
}

float hatBase(vec2 p){
    vec2 prevP = p;
    p-=vec2(0.,0.23);
    p.y*=0.5;
    float d = Tri(p,vec2(0.1));
    p = prevP;
    float d2 = B(p,vec2(0.1,0.03));
    d = min(d,d2);
    p-=vec2(0.,0.07);
    p.x*=0.7;
    d2 = Tri(p,vec2(0.15));
    d = abs(min(d,d2))-0.005;
    
    p = prevP;
    p-=vec2(0.,0.22);
    p.y*=0.5;
    d = max(-Tri(p,vec2(0.1)),d);
    
    p = prevP;
    p-=vec2(0.,0.015);
    d2 = abs(B(p,vec2(0.098,0.017)))-0.005;
    d = min(d,d2);
    
    p = prevP;
    
    p-=vec2(0.116,0.262);
    p*=Rot(radians(63.));
    p.x*=1.5;
    p.y*=0.4;
    d2 = abs(Tri(p,vec2(0.05)))-0.006;
    d2 = max(-p.y-0.045,d2);
    d = min(d,d2);
    
    p = prevP;
    p-=vec2(0.,0.23);
    p.y*=0.5;
    d2 = Tri(p,vec2(0.1));
    d = min(d,max(dots(prevP,1.),d2));
    
    p = prevP;
    p-=vec2(0.,0.07);
    p.x*=0.7;
    d2 = Tri(p,vec2(0.15));
    d2 = max(p.y+0.075,d2);
    d = min(d,max(stripes(prevP,-1.),d2));
    return d;
}

float hat(vec2 p){
    vec2 prevP = p;
    float d = hatBase(p);
    return d;
}

float star(vec2 p){
    vec2 prevP = p;
    p*=Rot(radians(-18.));
    p = DF(p,vec2(1.25));
    p-=0.1;
    p*=Rot(radians(45.));
    p.x*=1.5;
    
    float d = Tri(p,vec2(0.15));
    return d;
}

float moon(vec2 p){
    vec2 prevP = p;
    float d = length(p)-0.15;
    float d2 = length(p-vec2(-0.08,0.))-0.15;
    d = max(-d2,d);
    return d;
}

float centerGraphics(vec2 p){
    vec2 prevP = p;
    
    p*=Rot(radians(10.*iTime));
    p = DF(p,vec2(4.));
    p-=0.2;
    p*=Rot(radians(45.));
    p*=3.;
    float d = moon(p);
    p = prevP;
    
    p*=2.;
    float d2 = bat(p);
    d = min(d,d2);
    p = prevP;
    
    p*=Rot(radians(-5.*iTime));
    p = DF(p,vec2(5.));
    p-=0.26;
    p*=Rot(radians(50.));
    p*=5.;
    d2 = star(p);
    d = min(d,d2);
    p = prevP;
    
    p*=Rot(radians(7.*iTime));
    p = DF(p,vec2(5.));
    p-=0.3;
    p*=Rot(radians(135.));
    p*=-3.;
    d2 = candy2(p);
    d = min(d,d2);
    
    p = prevP;
    p*=Rot(radians(-10.*iTime));
    p = DF(p,vec2(4.));
    p-=0.14;
    p*=Rot(radians(50.));
    p*=7.;
    d2 = abs(star(p))-0.01;
    d = min(d,d2);
    
    p = prevP;
    p*=Rot(radians(-120.*sin(iTime*0.2)));
    p = DF(p,vec2(8.));
    p-=0.335;
    p*=Rot(radians(50.));
    p*=5.;
    d2 = abs(length(p)-0.06)-0.01;
    d2 = min(length(p)-0.02,d2);
    d = min(d,d2);
    
    p = prevP;
    p.x = abs(p.x)-0.5;
    p.y = abs(p.y)-0.37;
    p*=Rot(radians(80.));
    p*=2.;
    d2 = spiderNet(p);
    d = min(d,d2);
    
    return d;
}

vec3 bg(vec2 p, vec3 col){
    p*=Rot(radians(10.*iTime));
    p = PUV(p);
    
    p.x-=iTime*0.25;
    
    p*=2.54;
    vec2 id = floor(p);
    
    p = fract(p)-0.5;
    
    float n = Hash(id);
    
    p = mod(p,0.1)-0.05;
    float d = length(p)-0.005;
    col = mix(col,vec3(0.95,1.,0.95)*0.6,S2(d,0.0));
    
    return col;
}

vec3 drawTex(vec2 p, vec3 col) {
    vec2 prevP = p;
    p*=Rot(radians(10.*iTime));
   // p = PUV(p);
    
    p.x-=iTime*0.2;
    
    p*=2.54;
    vec2 id = floor(p);
    
    p = fract(p)-0.5;
    
    float n = Hash(id);
    
    float d = 10.;
    p*=Rot(radians(90.));
    p*=0.5+(min(n,0.2));
    if(n<0.2){
        p*=1.6;
        d = bat(p);
    } else if(n>=0.2 && n<0.4) {
        d = punpkin(p);
    } else if(n>=0.4 && n<0.5) {
        d = candy(p);
    } else if(n>=0.5 && n<0.6) {
        d = coffin(p);
    } else if(n>=0.6 && n<0.8) {
        p*=0.7;
        d = spiderNet(p);
    } else if(n>=0.8 && n<0.9) {
        p*=0.5;
        d = ghost(p);
    } else if(n>=0.9 && n<1.) {
        d = hat(p);
    }
    
    col = mix(col,vec3(0.95,1.,0.95)*0.6,S(d,0.0));
    
    p = prevP;
    d = length(p)-0.01;
    col = mix(col,vec3(0.0),1.-smoothstep(0.,1.,d));
    
    //d = centerGraphics(p);
    //col = mix(col,vec3(0.95,1.,0.95),S(d,0.0));
    
    return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord-0.5*iResolution.xy)/iResolution.y;

    vec3 col = vec3(0.);
    //col = bg(uv,col);
    col = drawTex(uv,col);
    fragColor = vec4(col,1.0);
}

//
///--------------------------------------------------------------------------------------------
///--------------------------------------------------------------------------------------------
///==!MAIN!== FRAMGMENT
///============================================================================================
///--------------------------------------------------------------------------------------------
//
void main() {
    vec2 fragCoord = (pos.xy*0.5+0.5) * iResolution.xy ;
    mainImage(frag_color, fragCoord);
    
    frag_color.a = length(frag_color.xyz);
    //if(pos.x > 0.8){frag_color=vec4(0);}
    
    frag_color.b*=0; 
    frag_color.g*=0.3; 
}
@end
//   
 
/* quad shader program */
@program quad vs fs

