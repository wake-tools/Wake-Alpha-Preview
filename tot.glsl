/* quad vertex shader */
@vs vs
in vec4 position;
in vec4 color0;
out vec4 color;

///////////////////
///== UNIFORM ==///
uniform vs_params {
   vec4 iMouse;      // mouse pixel coords .xy: current (if MLB down), zw: click
   vec3 iResolution; // viewport resolution (in pixels)
   float iTime;      // shader playback time (in seconds)
   float iTimeDelta; // render time (in seconds)
   float iFrameRate; // shader frame rate
   //int   iFrame;   // shader playback frame
   //float iChannelTime[4];
   //vec3  iChannelResolution[4];
   //samplerXX iChannel0..3;
   //vec4 iDate        //(year, month, day, time in seconds)
};

void main() {
    gl_Position = position;
    color = color0;
}
@end

/* quad fragment shader */
@fs fs
///////////////////
///== UNIFORM ==///
uniform fs_params {
   vec4 iMouse;      // mouse pixel coords .xy: current (if MLB down), zw: click
   vec3 iResolution; // viewport resolution (in pixels)
   float iTime;      // shader playback time (in seconds)
   float iTimeDelta; // render time (in seconds)
   float iFrameRate; // shader frame rate
   //int   iFrame;   // shader playback frame
   //float iChannelTime[4];
   //vec3  iChannelResolution[4];
   //samplerXX iChannel0..3;
   //vec4 iDate        //(year, month, day, time in seconds)
};

in vec4 color;
out vec4 frag_color;


/////////////////////////////
/////////////////////////////
/////////////////////////////
/////////////////////////////
/////////////////////////////
/////////////////////////////
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
    p = PUV(p);
    
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



void main() {
    frag_color = color;
    frag_color.x += iTime;

    vec4 o;
    vec2 fragCoord = color.xy * iResolution.xy ;
   // fragCoord.y *=-1; 
    //////////////////
    //////////////////
   vec2 uv = (fragCoord-0.5*iResolution.xy)/iResolution.y * vec2(1,-1);

    vec3 col = vec3(0.);
    //col = bg(uv,col);
    col = drawTex(uv,col);
    /////
    col.rgb*=vec3(0.9,0.7,0.5);
    
    frag_color = vec4(col,col);
   
    /////////////////
    /////////////////
   // frag_color.xy=color.xy; 
 //  frag_color.rgb *= (vec3){0.9,0.7,0.5};
   //frag_color.a = 1;
    
}
@end

/* quad shader program */
@program quad vs fs

