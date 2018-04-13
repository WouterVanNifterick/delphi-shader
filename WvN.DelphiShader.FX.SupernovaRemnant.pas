unit WvN.DelphiShader.FX.SupernovaRemnant;

interface

uses GR32,Types,WvN.DelphiShader.Shader;

type
TSupernovaRemnant = class(TShader)
const
  vec2_1:vec2 = (x:37;y:17);
  vec3_2:vec3 = (x:2;y:1.8;z:1.25);
  vec3_3:vec3 = (x:0.4;y:0.15;z:0.1);
  vec3_4:vec3 = (x:1;y:0.9;z:0.8);
  vec3_5:vec3 = (x:0.8;y:1;z:1);
  vec3_6:vec3 = (x:0.48;y:0.53;z:0.5);
  vec3_7:vec3 = (x:0.004;y:0.004;z:0.004);
  vec3_8:vec3 = (x:0;y:0;z:0);
  vec3_9:vec3 = (x:0.06;y:0.06;z:0.06);
  vec3_10:vec3 = (x:1.7;y:1.7;z:1.7);
  vec3_11:vec3 = (x:0.5;y:0.5;z:0.5);
  vec4_12:vec4 = (x:0;y:0;z:0;w:0);
  vec3_13:vec3 = (x:0;y:0;z:0);
  vec3_14:vec3 = (x:1;y:0.5;z:0.25);
  vec3_15:vec3 = (x:0.67;y:0.75;z:1.00);
  vec3_16:vec3 = (x:0;y:0;z:0);
  vec3_17:vec3 = (x:0.8;y:0.9;z:1);


  constructor  Create;override;
  procedure  PrepareFrame;
  function  noise(const x :vec3):float;
  function  fbm(const p:vec3):float;
  function  length2(const p :vec2):float;
  function  length8(const p :vec2):float;
  function  Disk(const p, t :vec3):float;
  function  normalizer = 1 / sqrt:float;
  function  SpiralNoiseC(const p:vec3):float;
  function  NebulaNoise(const p:vec3):float;
  function  map(const p:vec3):float;
  function  computeColor( density, radius :float):vec3;
  function  RaySphereIntersect(const org, dir:vec3;out near, far:float):bool;
  function  ToneMapFilmicALU(const _color:vec3):vec3;
  function  mainImage(var fragCoord:vec2):TColor32;
end;

var
    SupernovaRemnant:TShader
;

implementation

uses SysUtils, Math;

constructor TSupernovaRemnant.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := mainImage;
end;


procedure TSupernovaRemnant.PrepareFrame;
begin
end;


function TSupernovaRemnant.noise(const x :vec3):float;
var
  p, f:vec3;
  uv, rg:vec2;
begin
    p  := floor(x);
    f  := fract(x);
	f  := f*f*(3-2*f);
	rg  := texture2D( tex[0], (uv+ 0.5)/256, -100 ).yx;
	Exit( 1 - 0.82*mix( rg.x, rg.y, f.z ) );
end;


function TSupernovaRemnant.fbm(const p:vec3):float;
begin
   Exit( noise(p*0.06125)*0.5 + noise(p*0.125)*0.25 + noise(p*0.25)*0.125 + noise(p*0.4)*0.2 );
end;


function TSupernovaRemnant.length2(const p :vec2):float;
begin
	Exit( sqrt( p.x*p.x + p.y*p.y ) );
end;


function TSupernovaRemnant.length8(const p :vec2):float;
begin
	p  := p*p;
   p  := p*p;
   p  := p*p;
	Exit( pow( p.x + p.y, 1/8 ) );
end;


function TSupernovaRemnant.Disk(const p, t :vec3):float;
var
  q:vec2;
  nudge:float;
begin
    q  := Vec2.Create(length2(p.xy)-t.x,p.z*0.5);
    Exit( max(length8(q)-t.y, abs(p.z) - t.z) );
end;
//================
// otaviogood's noise from https://www.shadertoy.com/view/ld2SzK
//--------------------------------------------------------------
// This spiral noise works by successively adding and rotating sin waves while increasing frequency.
// It should work the same on all computers since it's not based on a hash function like some other noises.
// It can be much faster than other noise functions if you're ok with some repetition.
 nudge   := 0.9;
  	// size of perpendicular vector
end;


function TSupernovaRemnant.normalizer = 1 / sqrt:float;
begin
  	// pythagorean theorem on that perpendicular to maintain scale
end;


function TSupernovaRemnant.SpiralNoiseC(const p:vec3):float;
var
  n, iter:float;
  i:int;
begin
    n  := 0;
  	// noise amount
    iter  := 2;
    for i  := 0 to 7 do
begin
        // add sin and cos scaled inverse with the frequency
        n  := n  + (-abs(sinLarge(p.y*iter) + cosLarge(p.x*iter)) / iter);
  	// abs for a ridged look
        // rotate by adding perpendicular and scaling down
        p.xy  := p.xy  + (Vec2.Create(p.y,-p.x) * nudge);
        p.xy  := p.xy  * (normalizer);
        // rotate on other axis
        p.xz  := p.xz  + (Vec2.Create(p.z,-p.x) * nudge);
        p.xz  := p.xz  * (normalizer);
        // increase the frequency
        iter  := iter  * (1.733733);
end;
    Exit( n );
end;


function TSupernovaRemnant.NebulaNoise(const p:vec3):float;
var
  final:float;
begin
    final  := Disk(p.xzy,vec3_2);
    final  := final  + (fbm(p*90));
    final  := final  + (SpiralNoiseC(p.zxy*0.5123+100)*3);
    Exit( final );
end;


function TSupernovaRemnant.map(const p:vec3):float;
var
  NebNoise:float;
begin
	R(p.xz, iMouse.x*0.008*pi+iGlobalTime*0.1);
	NebNoise  := abs(NebulaNoise(p/0.5)*0.5);
	Exit( NebNoise+0.07 );
end;
//--------------------------------------------------------------
// assign color to the media
end;


function TSupernovaRemnant.computeColor( density, radius :float):vec3;
var
  result, colCenter, colEdge:vec3;
begin
	// color based on density alone, gives impression of occlusion within
	// the media
	result  := mix( vec3_4, vec3_3, density );
	// color added to the media
	colCenter  := 7*vec3_5;
	colEdge  := 1.5*vec3_6;
	result  := result  * (mix( colCenter, colEdge, min( (radius+0.05)/0.9, 1.15 ) ));
	Exit( result );
end;


function TSupernovaRemnant.RaySphereIntersect(const org, dir:vec3;out near, far:float):bool;
var
  b, c, delta, deltasqrt:float;
begin
	b  := dot(dir, org);
	c  := dot(org, org) - 8;
	delta  := b*b - c;
	if  delta < 0 then
		Exit( false );
	deltasqrt  := sqrt(delta);
	near  := -b - deltasqrt;
	far  := -b + deltasqrt;
	Exit( far > 0 );
end;
// Applies the filmic curve from John Hable's presentation
// More details at : http://filmicgames.com/archives/75
end;


function TSupernovaRemnant.ToneMapFilmicALU(const _color:vec3):vec3;
begin
	_color  := max(vec3_8, _color - vec3_7);
	_color  := (_color * (6.2*_color + vec3_11)) / (_color * (6.2 * _color + vec3_10) + vec3_9);
	Exit( _color );
end;


function TSupernovaRemnant.mainImage(var fragCoord:vec2):TColor32;
var
  KEY_1, KEY_2, KEY_3, key:float;
  rd, ro:vec3;
  ld=0, td=0, w, d=1, t, h:float;
  sum:vec4;
  min_dist=0, max_dist:float;
  i:int;
  pos:vec3;
  d:float;
  ldst:vec3;
  lDist:float;
  lightColor:vec3;
  col:vec4;
  uv:vec2;
  stars, starbg:vec3;
begin
 KEY_1   := 49.5/256;
 KEY_2   := 50.5/256;
 KEY_3   := 51.5/256;
    key  := 0;
    key  := key  + (0.7*texture2D(tex[1], Vec2.Create(KEY_1,0.25)).x);
    key  := key  + (0.7*texture2D(tex[1], Vec2.Create(KEY_2,0.25)).x);
    key  := key  + (0.7*texture2D(tex[1], Vec2.Create(KEY_3,0.25)).x);
	// ro: ray origin
	// rd: direction of the ray
	rd  := normalize(vec3((fragCoord.xy-0.5*resolution.xy)/resolution.y, 1));
	ro  := Vec3.Create(0,0,-6+key*1.6);
	// ld, td: local, total density
	// w: weighting factor
	ld=0, td=0, w := 0;
	// t: length of the ray
	// d: distance function
	d=1, t := 0;
 h   := 0.1;
	sum  := vec4_12;
    min_dist=0, max_dist := 0;
    if RaySphereIntersect(ro, rd, min_dist, max_dist) then
begin
	t  := min_dist*step(t,min_dist);
	// raymarch loop
	for i := 0 to 63 do
begin
		pos  := ro + t*rd;
		// Loop break conditions.
	    if td>0.9  or  d<0.1*t  or  t>10  or  sum.a > 0.99  or  t>max_dist then
     break;
        // evaluate distance function
        d  := map(pos);
		// change this string to control density
		d  := max(d,0);
        // point light calculations
        ldst  := vec3_13-pos;
        lDist  := max(length(ldst), 0.001);
        // the color of light
        lightColor := vec3_14;
        sum.rgb := sum.rgb + ((vec3_15/(lDist*lDist*10)/80));
   // star itself
        sum.rgb := sum.rgb + ((lightColor/exp(lDist*lDist*lDist*0.08)/30));
   // bloom
		if d<h then
begin
			// compute local density
			ld  := h - d;
            // compute weighting factor
			w  := (1 - td) * ld;
			// accumulate density
			td  := td  + (w + 1/200);
			col  := vec4( computeColor(td,lDist), td );
            // emission
            sum  := sum  + (sum.a * vec4(sum.rgb, 0) * 0.2);
			// uniform scale density
			col.a  := col.a  * (0.2);
			// colour by alpha
			col.rgb  := col.rgb  * (col.a);
			// alpha blend in contribution
			sum  := sum + col*(1 - sum.a);
end;
		td  := td  + (1/70);
        {$ifdef DITHERING}
        //idea from https://www.shadertoy.com/view/lsj3Dw
        uv  := fragCoord.xy / resolution.xy;
        uv.y := uv.y * (120);
        uv.x := uv.x * (280);
        d := abs(d)*(0.8+0.08*texture2D(tex[2],Vec2.Create(uv.y,-uv.x+0.5*sin(4*iGlobalTime+uv.y*4))).r);
        {$endif }
        // trying to optimize step size near the camera and near the light source
        t  := t  + (max(d * 0.1 * max(min(length(ldst),length(ro)),1), 0.01));
end;
    // simple scattering
	sum  := sum  * (1 / exp( ld * 0.2 ) * 0.6);
   	sum  := clamp( sum, 0, 1 );
    sum.xyz  := sum.xyz*sum.xyz*(3-2*sum.xyz);
end;
    {$ifdef BACKGROUND}
    // stars background
    if td<0.8 then
begin
        stars  := vec3(noise(rd*500)*0.5+0.5);
        starbg  := vec3_16;
        starbg  := mix(starbg, vec3_17, smoothstep(0.99, 1, stars)*clamp(dot(Vec3.Create(0),rd)+0.75,0,1));
        starbg  := clamp(starbg, 0, 1);
        sum.xyz  := sum.xyz  + (starbg);
end;
	{$endif }
    {$ifdef TONEMAPPING}
    fragColor  := vec4(ToneMapFilmicALU(sum.xyz*2.2),1);
	{$else }
    fragColor  := vec4(sum.xyz,1);
	{$endif }
end;




initialization
  SupernovaRemnant := TSupernovaRemnant.Create;
  Shaders.Add('SupernovaRemnant', SupernovaRemnant);

finalization
  FreeandNil(SupernovaRemnant);

end.
