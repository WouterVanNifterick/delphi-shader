unit WvN.DelphiShader.FX.SubterraneanFlyThrough;

interface

uses GR32,Types,WvN.DelphiShader.Shader;

type
TSubterraneanFlyThrough = class(TShader)
const
  vec3_1:vec3 = (x:7;y:157;z:113);
  vec3_2:vec3 = (x:2097152;y:262144;z:32768);
  vec3_3:vec3 = (x:0.444;y:0.444;z:0.444);
  vec3_4:vec3 = (x:0.222;y:0.222;z:0.222);
  vec3_5:vec3 = (x:0.666;y:0.666;z:0.666);
  vec3_6:vec3 = (x:0.333;y:0.333;z:0.333);
  vec3_7:vec3 = (x:0.333;y:0.333;z:0.333);
  vec2_8:vec2 = (x:-1;y:1);
  vec3_9:vec3 = (x:0;y:0;z:-0.1);
  vec3_10:vec3 = (x:0;y:0.125;z:-0.25);
  vec3_11:vec3 = (x:0;y:0;z:6);
  vec3_12:vec3 = (x:0;y:0;z:0);
  vec3_13:vec3 = (x:1;y:0.96;z:0.92);
  vec3_14:vec3 = (x:1;y:0.96;z:0.92);


var
  freqA, freqB, ampA, ampB:float


  constructor  Create;override;
  procedure  PrepareFrame;
  function  getGrey(const p:vec3):float;
  function  hash33(const p:vec3):vec3;
  function  tex3D(const p, n :vec3):vec3;
  function  tri(const x:vec3):vec3;
  function  triSmooth(const x:vec3):vec3;
  function  surfFunc(const p:vec3):float;
  function  smoothMinP( a, b, smoothing :float):float;
  function  path(const z:float):vec2;
  function  path2(const z:float):vec2;
  function  map(const p:vec3):float;
  function  doBumpMap(const p, nor:vec3; bumpfactor:float):vec3;
  function  getNormal(const p:vec3):vec3;
  function  softShadow(const ro, rd:vec3; start, end, k:float):float;
  function  calculateAO(const p, n:vec3):float;
  function  curve(const p:vec3;const w:float):float;
  function  mainImage(var fragCoord:vec2):TColor32;
end;

var
    SubterraneanFlyThrough:TShader
;

implementation

uses SysUtils, Math;

constructor TSubterraneanFlyThrough.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := mainImage;
end;


procedure TSubterraneanFlyThrough.PrepareFrame;
begin
end;


function TSubterraneanFlyThrough.getGrey(const p:vec3):float;
begin
 Exit( p.x*0.299 + p.y*0.587 + p.z*0.114 );
end;
// Non-standard vec3-to-vec3 hash function.
end;


function TSubterraneanFlyThrough.hash33(const p:vec3):vec3;
var
  n:float;
begin
    n  := sinLarge(dot(p, vec3_1));
    Exit( fract(vec3_2*n) );
end;
// Tri-Planar blending function. Based on an old Nvidia tutorial.
end;


function TSubterraneanFlyThrough.tex3D(const p, n :vec3):vec3;
begin
    n  := max((abs(n) - 0.2)*7, 0.001);
   // n := max(abs(n), 0.001), etc.
    n  := n  / ((n.x + n.y + n.z ));
	Exit( (texture2D(tex, p.yz)*n.x + texture2D(tex, p.zx)*n.y + texture2D(tex, p.xy)*n.z).xyz );
end;
// The triangle function that Shadertoy user Nimitz has used in various triangle noise demonstrations.
// See Xyptonjtroz - Very cool. Anyway, it's not really being used to its full potential here.
end;


function TSubterraneanFlyThrough.tri(const x:vec3):vec3;
begin
Exit( abs(x-floor(x)-0.5) );
end;
 // Triangle function.
end;


function TSubterraneanFlyThrough.triSmooth(const x:vec3):vec3;
begin
Exit( cos(x*6.2831853)*0.25+0.25 );
end;
 // Smooth version. Not used here.
// The function used to perturb the walls of the cavern: There are infinite possibities, but this one is
// just a cheap...ish routine - based on the triangle function - to give a subtle jaggedness. Not very fancy,
// but it does a surprizingly good job at laying the foundations for a sharpish rock face. Obviously, more
// layers would be more convincing. However, this is a GPU-draining distance function, so the finer details
// are bump mapped.
end;


function TSubterraneanFlyThrough.surfFunc(const p:vec3):float;
var
  n, n, n:float;
begin
    n  := dot(tri(p*0.48 + tri(p*0.24).yzx), vec3_3);
    p.xz  := Vec2.Create(p.x + p.z,p.z - p.x) * 0.7071;
    Exit( dot(tri(p*0.72 + tri(p*0.36).yzx), vec3_4) + n );
   // Range [0, 1]
    // Other variations to try. All have range: [0, 1]
    {
	Exit( dot(tri(p*0.5 + tri(p*0.25).yzx), vec3_5) );
	}
    {
    return dot(tri(p*0.5 + tri(p*0.25).yzx), vec3_6) +
           sin(p.x*1.5+sin(p.y*2.+sin(p.z*2.5)))*0.25+0.25;
	}
    {
    return dot(tri(p*0.6 + tri(p*0.3).yzx), vec3_7) +
           sin(p.x*1.75+sin(p.y*2.+sin(p.z*2.25)))*0.25+0.25;
   // Range [0, 1]
    }
    {
    p  := p  * (0.5);
    n  := dot(tri(p + tri(p*0.5).yzx), vec3(0.666*0.66));
    p  := p  * (1.5);
    p.xz  := Vec2.Create(p.x + p.z,p.z - p.x) * 1.7321*0.5;
    n  := n  + (dot(tri(p + tri(p*0.5).yzx), vec3(0.666*0.34)));
    Exit( n );
    }
    {
    p  := p  * (1.5);
    n  := sin(p.x+sin(p.y+sin(p.z)))*0.57;
    p  := p  * (1.5773);
    p.xy  := Vec2.Create(p.x + p.y,p.y - p.x) * 1.7321*0.5;
    n  := n  + (sin(p.x+sin(p.y+sin(p.z)))*0.28);
    p  := p  * (1.5773);
    p.xy  := Vec2.Create(p.x + p.y,p.y - p.x) * 1.7321*0.5;
    n  := n  + (sin(p.x+sin(p.y+sin(p.z)))*0.15);
    Exit( n*0.4+0.6 );
    }
end;
// Cheap...ish smooth minimum function.
end;


function TSubterraneanFlyThrough.smoothMinP( a, b, smoothing :float):float;
var
  h:float;
begin
    h  := clamp((b-a)*0.5/smoothing + 0.5, 0, 1 );
    Exit( mix(b, a, h) - smoothing*h*(1-h) );
end;
// The path is a 2D sinusoid that varies over time, depending upon the frequencies, and amplitudes.
end;


function TSubterraneanFlyThrough.path(const z:float):vec2;
begin
 Exit( Vec2.Create(ampA*sin(z * freqA),ampB*cos(z * freqB)) );
end;


function TSubterraneanFlyThrough.path2(const z:float):vec2;
begin
 Exit( Vec2.Create(ampB*sin(z * freqB*1.5),ampA*cos(z * freqA*1.3)) );
end;
// Standard double tunnel distance function with a bit of perturbation thrown into the mix. A winding
// tunnel is just a cylinder with a smoothly shifting center as you traverse lengthwise. Each tunnel
// follows one of two paths, which occasionally intertwine. The tunnels are combined using a smooth
// minimum, which looks a little nicer. The walls of the tunnels are perturbed by some kind of 3D
// surface function... preferably a cheap one with decent visual impact.
end;


function TSubterraneanFlyThrough.map(const p:vec3):float;
var
  tun, tun2:vec2;
begin
     tun  := p.xy - path(p.z);
     tun2  := p.xy - path2(p.z);
     Exit( 1- smoothMinP(length(tun), length(tun2), 4) + (0.5-surfFunc(p)) );
end;
// Texture bump mapping. Four tri-planar lookups, or 12 texture lookups in total.
end;


function TSubterraneanFlyThrough.doBumpMap(const p, nor:vec3; bumpfactor:float):vec3;
var
  eps, ref:float;
begin
 eps   := 0.001;
    ref  := getGrey(tex3D(tex,  p , nor));
    vec3 grad := Vec3.Create( getGrey(tex3D(tex, Vec3.Create(p.x-eps, p.y,p.z),nor))-ref,
                      getGrey(tex3D(tex, Vec3.Create(p.x, p.y-eps,p.z),nor))-ref,
                      getGrey(tex3D(tex, Vec3.Create(p.x, p.y,p.z-eps),nor))-ref )/eps;
    grad  := grad  - (nor*dot(nor, grad));
    Exit( normalize( nor + grad*bumpfactor ) );
end;
// Surface normal.
end;


function TSubterraneanFlyThrough.getNormal(const p:vec3):vec3;
var
  eps:float;
begin
 eps   := 0.001;
	return normalize(vec3(
		map(Vec3.Create(p.x+eps,p.y,p.z))-map(Vec3.Create(p.x-eps,p.y,p.z)),
		map(Vec3.Create(p.x,p.y+eps,p.z))-map(Vec3.Create(p.x,p.y-eps,p.z)),
		map(Vec3.Create(p.x,p.y,p.z+eps))-map(Vec3.Create(p.x,p.y,p.z-eps))
	));
end;
// The shadows were a bit of a disappointment, so they didn't get used.
{
end;


function TSubterraneanFlyThrough.softShadow(const ro, rd:vec3; start, end, k:float):float;
var
  shade:float;
  maxIterationsShad:int;
  dist, stepDist:float;
  i:int;
  h:float;
begin
    shade  := 1.0;
 maxIterationsShad   := 24;
    dist  := start;
    stepDist  := end/maxIterationsShad;
    // Max shadow iterations - More iterations make nicer shadows, but slow things down.
    for i := 0 to maxIterationsShad-1 do
begin
        h  := map(ro + rd*dist);
        shade  := min(shade, k*h/dist);
        // +=h, +=clamp( h, 0.01, 0.25 ), +=min( h, 0.1 ), +=stepDist, +=min(h, stepDist*2.), etc.
        dist  := dist  + (min(h, stepDist*2.));
        // Early exits from accumulative distance function calls tend to be a good thing.
        if h<0.001  or  dist > end then
     break;
end;
    // Shadow value.
    Exit( min(max(shade, 0.) + 0.3, 1.0) );
end;
}
// Based on original by IQ.
end;


function TSubterraneanFlyThrough.calculateAO(const p, n:vec3):float;
var
  AO_SAMPLES, r = 0, w, i:float;
begin
 AO_SAMPLES   := 5;
    r := 0, w  := 1, d;
i := 1; i<AO_SAMPLES+1.1;
begin
        d  := i/AO_SAMPLES;
        r  := r  + (w*(d - map(p + n*d)));
        w  := w  * (0.5);
end;
    Exit( 1-clamp(r,0,1) );
end;
// Cool curve function, by Shadertoy user, Nimitz.
//
// I think it's based on a discrete finite difference approximation to the continuous
// Laplace differential operator? Either way, it gives you the curvature of a surface,
// which is pretty handy. I used it to do a bit of fake shadowing.
end;


function TSubterraneanFlyThrough.curve(const p:vec3;const w:float):float;
var
  e:vec2;
  t1 = map(p + e.yxx), t2, t3 = map(p + e.xyx), t4:float;
begin
    t1 := map(p + e.yxx), t2  := map(p + e.xxy);
    t3 := map(p + e.xyx), t4  := map(p + e.
);
    Exit( 0.125/(w*w) *(t1 + t2 + t3 + t4 - 4*map(p)) );
end;


function TSubterraneanFlyThrough.mainImage(var fragCoord:vec2):TColor32;
var
  uv:vec2;
  lookAt, camPos, light_pos, light_pos2:vec3;
  FOV:float;
  forward, right, up, rd:vec3;
  t:float;
  i:int;
  sceneCol, sp, sn:vec3;
  tSize0, ao:float;
  ld, ld2:vec3;
  distlpsp, distlpsp2, atten, atten2, ambience, diff, diff2, spec, spec2, crv, fre:float;
  texCol:vec3;
  shading:float;
begin
	// Screen coordinates.
	uv  := (fragCoord - resolution.xy*0.5)/resolution.y;
	// Camera Setup.
	lookAt  := Vec3.Create(0,0,iGlobalTime*4);
    // "Look At" position.
	camPos  := lookAt + vec3_9;
   // Camera position, doubling as the ray origin.
    // Light positioning. One is a little behind the camera, and the other is further down the tunnel.
 	light_pos  := camPos + vec3_10;
  // Put it a bit in front of the camera.
	light_pos2  := camPos + vec3_11;
  // Put it a bit in front of the camera.
	// Using the Z-value to perturb the XY-plane.
	// Sending the camera, "look at," and two light vectors down the tunnel. The "path" function is
	// synchronized with the distance function. Change to "path2" to traverse the other tunnel.
	lookAt.xy  := lookAt.xy  + (path(lookAt.z));
	camPos.xy  := camPos.xy  + (path(camPos.z));
	light_pos.xy  := light_pos.xy  + (path(light_pos.z));
	light_pos2.xy  := light_pos2.xy  + (path(light_pos2.z));
    // Using the above to produce the unit ray-direction vector.
    FOV  := PI/3;
   // FOV - Field of view.
    forward  := normalize(lookAt-camPos);
    right  := normalize(Vec3.Create(forward.z,0,-forward.x ));
    up  := cross(forward, right);
    // rd - Ray direction.
    rd  := normalize(forward + FOV*uv.x*right + FOV*uv.y*up);
    // Standard ray marching routine. I find that some system setups don't like anything other than
    // a "break" statement (by itself) to exit.
	t  := 0, dt;
	for i := 0 to 127 do
begin
		dt  := map(camPos + rd*t);
		if dt<0.005  or  t>150 then
begin
 break;
end;
		t  := t  + (dt*0.75);
end;
	sceneCol  := vec3_12;
	// The ray has effectively hit the surface, so light it up.
	if dt<0.005 then
begin
	    // The ray marching loop (above) exits when "dt" is less than a certain threshold, which in this
        // case, is hardcoded to "0.005." However, the distance is still "dt" from the surface? By my logic,
	    // adding the extra "dt" after breaking would gain a little more accuracy and effectively reduce
	    // surface popping? Would that be correct? I tend to do this, but could be completely wrong, so if
	    // someone could set me straight, it'd be appreciated.
	    t  := t  + (dt);
    	// Surface position and surface normal.
	    sp  := t * rd+camPos;
	    sn  := getNormal(sp);
        // Texture scale factor.
 tSize0   := 1/4;
    	// Texture-based bump mapping. Comment this line out to spoil the illusion.
	    sn  := doBumpMap(tex[0], sp*tSize0, sn, 0.04);
	    // Ambient occlusion.
	    ao  := calculateAO(sp, sn);
    	// Light direction vectors.
	    ld  := light_pos-sp;
	    ld2  := light_pos2-sp;
        // Distance from respective lights to the surface point.
	    distlpsp  := max(length(ld), 0.001);
	    distlpsp2  := max(length(ld2), 0.001);
    	// Normalize the light direction vectors.
	    ld  := ld  / (distlpsp);
	    ld2  := ld2  / (distlpsp2);
	    // Light attenuation, based on the distances above.
	    atten  := 1/(1 + distlpsp*0.2 + distlpsp*distlpsp*0.02);
        atten2  := 1/(1 + distlpsp2*0.2 + distlpsp2*distlpsp2*0.02);
    	// Ambient light.
	    ambience  := 0.125;
    	// Diffuse lighting.
	    diff  := max( dot(sn, ld), 0);
	    diff2  := max( dot(sn, ld2), 0);
    	// Specular lighting.
	    spec  := pow(max( dot( reflect(-ld, sn), -rd ), 0 ), 8);
	    spec2  := pow(max( dot( reflect(-ld2, sn), -rd ), 0 ), 8);
    	// Curvature.
	    crv  := clamp(curve(sp, 0.125)*0.5+0.5, 0, 1);
	    // Fresnel term. Good for giving a surface a bit of a reflective glow.
        fre  := pow( clamp(dot(sn, rd) + 1, 0, 1), 1);
        // Obtaining the texel color.
	    texCol  := tex3D(tex[0], sp*tSize0, sn);
   // Sandstone.
        // Shadertoy doesn't appear to have anisotropic filtering turned on... although,
        // I could be wrong. Texture-bumped objects don't appear to look as crisp. Anyway,
        // this is just a very lame, and not particularly well though out, way to sparkle
        // up the blurry bits. It's not really that necessary.
        //vec3 aniso := (0.5-hash33(sp))*fre*0.35;
	    //texCol := clamp(texCol + aniso, 0., 1.);
    	// Darkening the crevices. Otherwise known as cheap, scientifically-incorrect shadowing.
	    shading  := crv*0.5+0.5;
        // Shadows - They didn't add enough aesthetic value to justify the GPU drain, so they
        // didn't make the cut. There are two lights, so technically there should be two
        // of these but one is far enough away not to worry about.
        //shading *= softShadow(sp, ld, 0.005*4., distlpsp, 16.);
    	// Combining the above terms to produce the final color. It was based more on acheiving a
        // certain aesthetic than science.
        sceneCol  := sceneCol  + ((texCol*(diff*vec3_13 + ambience) + spec + fre*texCol*0.25)*atten);
        sceneCol  := sceneCol  + ((texCol*(diff2*vec3_14 + ambience) + spec2 + fre*texCol*0.25)*atten2);
        // Other combinations:
        //
        // Cold.
        //sceneCol += (getGrey(texCol)*(diff*0.75 + ambience*0.25) + spec*texCol*2. + fre*crv*texCol.zyx/2.)*atten;
        //sceneCol += (getGrey(texCol)*(diff2*0.75 + ambience*0.25) + spec2*texCol*2. + fre*crv*texCol.zyx/2.)*atten2;
        // Damp.
        //sceneCol += (texCol*(diff*vec3(0.7, 0.6, 0.5) + ambience*.25) + spec*1.25 + fre*fre*texCol.yxz*texCol.yxz)*atten;
        ///sceneCol += (texCol*(diff2*vec3(0.6, 0.6, 0.5) + ambience*.25) + spec2*1.25 + fre*fre*texCol.yxz*texCol.yxz)*atten2;
        // Shading.
        sceneCol  := sceneCol  * (shading*ao);
end;
	fragColor  := vec4.Create(clamp(sceneCol,0,1),1);
end;




initialization
  SubterraneanFlyThrough := TSubterraneanFlyThrough.Create;
  Shaders.Add('SubterraneanFlyThrough', SubterraneanFlyThrough);

finalization
  FreeandNil(SubterraneanFlyThrough);

end.
