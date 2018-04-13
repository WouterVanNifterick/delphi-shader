unit WvN.DelphiShader.FX.GasExplosion;

interface

uses GR32,Types,WvN.DelphiShader.Shader;

type
TGasExplosion = class(TShader)
const
  vec3_1:vec3 = (x:0.22;y:0.16;z:0.046);
  vec3_2:vec3 = (x:0.403;y:0.291;z:0.216);
  vec3_3:vec3 = (x:0.305;y:0.49;z:0.616);
  vec3_4:vec3 = (x:0.918;y:0.796;z:0.495);
  vec3_5:vec3 = (x:0.2;y:0.4;z:0.6);
  vec3_6:vec3 = (x:0;y:0.1;z:0.3);
  vec3_7:vec3 = (x:0.8;y:0.9;z:1);
  vec3_8:vec3 = (x:.1031;y:.1030;z:.0973);
  vec4_9:vec4 = (x:1031;y:.1030;z:.0973;w:.1099);
  vec2_10:vec2 = (x:37;y:17);
  vec3_11:vec3 = (x:0.004;y:0.004;z:0.004);
  vec3_12:vec3 = (x:0;y:0;z:0);
  vec3_13:vec3 = (x:0.5;y:0.5;z:0.5);
  vec3_14:vec3 = (x:0.06;y:0.06;z:0.06);
  vec3_15:vec3 = (x:1.7;y:1.7;z:1.7);
  vec4_16:vec4 = (x:0;y:1;z:57;w:58);
  vec3_17:vec3 = (x:1;y:57;z:113);
  vec3_18:vec3 = (x:0;y:0;z:0);
  vec3_19:vec3 = (x:0;y:1;z:0);
  vec4_20:vec4 = (x:0;y:0;z:0;w:0);
  vec3_21:vec3 = (x:0;y:0;z:-6);
  vec4_22:vec4 = (x:0;y:0;z:0;w:0);
  vec3_23:vec3 = (x:0;y:0;z:0);
  vec3_24:vec3 = (x:1;y:0.5;z:0.25);
  vec3_25:vec3 = (x:0;y:1;z:0);


var
  veDensityBeg, veDensityEnd, veMediaCenter, veMediaEdge, veColSkyHigh, veColSkyLow, veColStars:vec3;
  accuscale, scalestar, subdiv, variable, variable2:float;
  veBOTH, veLEFT, veLOW_QUALITY, veDITHERING, veTONEMAPPING, veBackground:bool;
  veBackgroundCutoff, veBackgroundCutoffStart:float


  constructor  Create;override;
  procedure  PrepareFrame;
  function  veProgress = &mod:float;
  function  texture(const p:vec2):vec4;
  function  texture(const p:vec2; b:float):vec4;
  procedure  veR(out p:vec2;const a:float);
  function  veNoise(const x:vec3):float;
  function  veFBM(const p:vec3):float;
  function  veSphere(const p:vec3; r:float):float;
  function  veNormalizer = 1 / sqrt:float;
  function  veSpiralNoiseC(const p:vec3):float;
  function  veVolumetricExplosion(const p:vec3):float;
  function  veMap(const p:vec3):float;
  function  veComputeColor( density, radius:float):vec3;
  function  veRaySphereIntersect(const org, dir:vec3;out near, far:float):bool;
  function  veToneMapFilmicALU(const _color:vec3):vec3;
  function  veAddZoom(const rd, ro:vec3):vec3;
  function  veHashv4f( p:float):vec4;
  function  veNoisefv2(const p:vec2):float;
  function  veNoisefv3(const p:vec3):float;
  function  veFbm3(const p:vec3):float;
  function  veFbmn(const p, n:vec3):float;
  function  veSpaceCol(const ro, rd:vec3):vec3;
  function  hash11( p:float):float;
  function  hash12(const p:vec2):float;
  function  hash13(const p3:vec3):float;
  function  hash21( p:float):vec2;
  function  hash22(const p:vec2):vec2;
  function  hash23(const p3:vec3):vec2;
  function  hash31( p:float):vec3;
  function  hash32(const p:vec2):vec3;
  function  hash33(const p3:vec3):vec3;
  function  hash41( p:float):vec4;
  function  hash42(const p:vec2):vec4;
  function  hash43(const p:vec3):vec4;
  function  hash44(const p4:vec4):vec4;
  function  sdCapsule(const p, a, b:vec3; r:float):float;
  function  parabola( x, k:float):float;
  function  parabola(const x:vec4; k:float):vec4;
  function  parabola(const x:vec3; k:float):vec3;
  function  pcurve( x, a, b:float):float;
  function  veStars(const ro, rd:vec3):vec3;
  function  mainImage(var fragCoord:vec2):TColor32;
end;

var
    GasExplosion:TShader
;

implementation

uses SysUtils, Math;

constructor TGasExplosion.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := mainImage;
end;


procedure TGasExplosion.PrepareFrame;
begin
end;


function TGasExplosion.veProgress = &mod:float;
begin
//-------------------
#define HASHSCALE1 .1031
#define HASHSCALE3 vec3_8
#define HASHSCALE4 vec4_9
#define pi 3.14159265
end;


function TGasExplosion.texture(const p:vec2):vec4;
begin
    Exit( texture2D(s, p) );
end;


function TGasExplosion.texture(const p:vec2; b:float):vec4;
begin
    Exit( texture2D(s, p, b) );
end;


procedure TGasExplosion.veR(out p:vec2;const a:float);
begin
	p  := cos(a) * p + sin(a) * Vec2.Create(p.y,-p.x);
end;
// iq's noise
end;


function TGasExplosion.veNoise(const x:vec3):float;
var
  p, f:vec3;
  uv, rg:vec2;
begin
	p  := floor(x);
	f  := fract(x);
	f  := f * f * (3 - 2 * f);
	rg  := texture(tex[0], (uv + 0.5) / 256, -100).yx;
	Exit( 1 - 0.82 * mix(rg.x, rg.y, f.z) );
end;


function TGasExplosion.veFBM(const p:vec3):float;
begin
	return veNoise(p * 0.06125) * 0.5 + veNoise(p * 0.125) * 0.25
			+ veNoise(p * 0.25) * 0.125 + veNoise(p * 0.4) * 0.2;
end;


function TGasExplosion.veSphere(const p:vec3; r:float):float;
var
  veNudge:float;
begin
	Exit( length(p) - r * 1.92 * veProgress );
end;
//================
// otaviogood's noise from https://www.shadertoy.com/view/ld2SzK
//--------------------------------------------------------------
// This spiral noise works by successively adding and rotating sin waves while increasing frequency.
// It should work the same on all computers since it's not based on a hash function like some other noises.
// It can be much faster than other noise functions if you're ok with some repetition.
 veNudge   := 100.3 * 4;
  	// size of perpendicular vector
end;


function TGasExplosion.veNormalizer = 1 / sqrt:float;
begin
  	// pythagorean theorem on that perpendicular to maintain scale
end;


function TGasExplosion.veSpiralNoiseC(const p:vec3):float;
var
  n, iter:float;
  i:int;
begin
	n  := 1.5 - 6 * veProgress;
   // noise amount
	iter  := 2;
	for i  := 0 to 7 do
begin
		// add sin and cos scaled inverse with the frequency
		n  := n  + (-abs(sinLarge(p.y * iter) + cosLarge(p.x * iter)) / iter);
   // abs for a ridged look
		// rotate by adding perpendicular and scaling down
		p.xy  := p.xy  + (Vec2.Create(p.y,-p.x) * veNudge);
		p.xy  := p.xy  * (veNormalizer);
		// rotate on other axis
		p.xz  := p.xz  + (Vec2.Create(p.z,-p.x) * veNudge);
		p.xz  := p.xz  * (veNormalizer);
		// increase the frequency
		iter  := iter  * (1.733733);
end;
	Exit( n );
end;


function TGasExplosion.veVolumetricExplosion(const p:vec3):float;
var
  fin:float;
begin
	fin  := veSphere(p, 4);
	if veLOW_QUALITY then
begin
		fin  := fin  + (veNoise(p * 12.5) * 0.2);
end;
 else
begin
		fin  := fin  + (veFBM(p * 50));
end;
	fin  := fin  + (veSpiralNoiseC(p.zxy * 0.4132 + 333 * floor(iMouse.y * 0.1)) * 1.25);
   //1.25;
	Exit( fin );
end;


function TGasExplosion.veMap(const p:vec3):float;
var
  VolExplosion:float;
begin
	//veR(p.yz, iMouse.x * 0.008 * pi + 4. * veProgress);
	veR(p.yz, 4 * veProgress);
	VolExplosion  := veVolumetricExplosion(p * 2) * 0.5;
   // scale
	Exit( VolExplosion );
end;
//--------------------------------------------------------------
// assign color to the media
end;


function TGasExplosion.veComputeColor( density, radius:float):vec3;
var
  result, colCenter, colEdge:vec3;
begin
	// color based on density alone, gives impression of occlusion within
	// the media
	result  := mix(veDensityBeg, veDensityEnd, 1 - density);
	// color added to the media
	colCenter  := 7 * veMediaCenter;
	colEdge  := 1.5 * veMediaEdge;
	result  := result  * (mix(colCenter, colEdge, min((radius + 0.05) / 0.9, 1.15)));
	Exit( result );
end;


function TGasExplosion.veRaySphereIntersect(const org, dir:vec3;out near, far:float):bool;
var
  b, c, delta, deltasqrt:float;
begin
	b  := dot(dir, org);
	c  := dot(org, org) - 8 * 4 * veProgress;
	delta  := b * b - c;
	if delta < 0 then
		Exit( false );
	deltasqrt  := sqrt(delta);
	near  := -b - deltasqrt;
	far  := -b + deltasqrt;
	Exit( far > 0 );
end;
// Applies the filmic curve from John Hable's presentation
// More details at : http://filmicgames.com/archives/75
end;


function TGasExplosion.veToneMapFilmicALU(const _color:vec3):vec3;
begin
	_color  := max(vec3_12, _color - vec3_11);
	_color := (_color * (6.2 * _color + vec3_13))
			/ (_color * (6.2 * _color + vec3_15) + vec3_14);
	Exit( _color );
end;


function TGasExplosion.veAddZoom(const rd, ro:vec3):vec3;
var
  KEY_1, KEY_2, KEY_3, key:float;
  vecHashA4:vec4;
  vecHashA3:vec3;
  vecHashM:float;
begin
 KEY_1   := 49.5 / 256;
 KEY_2   := 50.5 / 256;
 KEY_3   := 51.5 / 256;
	key  := 0;
	key  := key  + (0.7 * texture(tex[1], Vec2.Create(KEY_1,0.25)).x);
	key  := key  + (1.4 * texture(tex[1], Vec2.Create(KEY_2,0.25)).x);
	key  := key  + (2.1 * texture(tex[1], Vec2.Create(KEY_3,0.25)).x);
	Exit( ro - (ro - rd) * key * 1.6 / 6 );
end;
 vecHashA4   := vec4_16;
 vecHashA3   := vec3_17;
 vecHashM   := 43758.54;
end;


function TGasExplosion.veHashv4f( p:float):vec4;
begin
	Exit( fract(sin(p + vecHashA4) * vecHashM) );
end;


function TGasExplosion.veNoisefv2(const p:vec2):float;
var
  t:vec4;
  ip, fp:vec2;
begin
	ip  := floor(p);
	fp  := fract(p);
	fp  := fp * fp * (3 - 2 * fp);
	t  := veHashv4f(dot(ip, vecHashA3.xy));
	Exit( mix(mix(t.x, t.y, fp.x), mix(t.z, t.w, fp.x), fp.y) );
end;


function TGasExplosion.veNoisefv3(const p:vec3):float;
var
  t1, t2:vec4;
  ip, fp:vec3;
  q:float;
begin
	ip  := floor(p);
	fp  := fract(p);
	fp  := fp * fp * (3 - 2 * fp);
	q  := dot(ip, vecHashA3);
	t1  := veHashv4f(q);
	t2  := veHashv4f(q + vecHashA3.z);
	return mix(mix(mix(t1.x, t1.y, fp.x), mix(t1.z, t1.w, fp.x), fp.y),
			mix(mix(t2.x, t2.y, fp.x), mix(t2.z, t2.w, fp.x), fp.y), fp.z);
end;


function TGasExplosion.veFbm3(const p:vec3):float;
var
  f, a:float;
  i:int;
begin
	f  := 0;
	a  := 1;
	for i  := 0 to 4 do
begin
		f  := f  + (a * veNoisefv3(p));
		a  := a  * (0.5);
		p  := p  * (2);
end;
	Exit( f );
end;


function TGasExplosion.veFbmn(const p, n:vec3):float;
var
  s:vec3;
  a:float;
  i:int;
begin
	s  := vec3_18;
	a  := 1;
	for i  := 0 to 4 do
begin
		s  := s  + (a * Vec3.Create(veNoisefv2(p.yz),veNoisefv2(p.zx),veNoisefv2(p.xy)));
		a  := a  * (0.5);
		p  := p  * (2);
end;
	Exit( dot(s, abs(n)) );
end;


function TGasExplosion.veSpaceCol(const ro, rd:vec3):vec3;
var
  rds, col:vec3;
  j:int;
  s:float;
begin
	rds  := floor(2000 * rd);
	rds  := 0.00015 * rds + 0.1 * veNoisefv3(0.0005 * rds.yzx);
	for j  := 0 to 18 do
		rds  := abs(rds) / dot(rds, rds) - 0.9;
	col  := veColStars * min(1, 0.5e-3 * pow(min(6, length(rds)), 5));
	s  := pow(max(0, abs(dot(rd, vec3_19))), 1.60);
	col  := veColSkyLow + col * (1 - smoothstep(0.9, 1, s));
	s  := pow(s, 128);
	col  := col  + (veColSkyHigh * (0.2 * s + 0.9 * pow(s, 8)));
	Exit( col );
end;
//----------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------
//  1 out, 1 in...
end;


function TGasExplosion.hash11( p:float):float;
var
  p3:vec3;
begin
	p3  := fract(vec3(p) * HASHSCALE1);
	p3  := p3  + (dot(p3, p3.yzx + 19.19));
	Exit( fract((p3.x + p3.y) * p3.z) );
end;
//----------------------------------------------------------------------------------------
//  1 out, 2 in...
end;


function TGasExplosion.hash12(const p:vec2):float;
var
  p3:vec3;
begin
	p3  := fract(vec3(p.xyx) * HASHSCALE1);
	p3  := p3  + (dot(p3, p3.yzx + 19.19));
	Exit( fract((p3.x + p3.y) * p3.z) );
end;
//----------------------------------------------------------------------------------------
//  1 out, 3 in...
end;


function TGasExplosion.hash13(const p3:vec3):float;
begin
	p3  := fract(p3 * HASHSCALE1);
	p3  := p3  + (dot(p3, p3.yzx + 19.19));
	Exit( fract((p3.x + p3.y) * p3.z) );
end;
//----------------------------------------------------------------------------------------
//  2 out, 1 in...
end;


function TGasExplosion.hash21( p:float):vec2;
var
  p3:vec3;
begin
	p3  := fract(vec3(p) * HASHSCALE3);
	p3  := p3  + (dot(p3, p3.yzx + 19.19));
	Exit( fract(Vec2.Create((p3.x + p3.y) * p3.z,(p3.x + p3.z) * p3.y)) );
end;
//----------------------------------------------------------------------------------------
///  2 out, 2 in...
end;


function TGasExplosion.hash22(const p:vec2):vec2;
var
  p3:vec3;
begin
	p3  := fract(vec3(p.xyx) * HASHSCALE3);
	p3  := p3  + (dot(p3, p3.yzx + 19.19));
	Exit( fract(Vec2.Create((p3.x + p3.y) * p3.z,(p3.x + p3.z) * p3.y)) );
end;
//----------------------------------------------------------------------------------------
///  2 out, 3 in...
end;


function TGasExplosion.hash23(const p3:vec3):vec2;
begin
	p3  := fract(p3 * HASHSCALE3);
	p3  := p3  + (dot(p3, p3.yzx + 19.19));
	Exit( fract(Vec2.Create((p3.x + p3.y) * p3.z,(p3.x + p3.z) * p3.y)) );
end;
//----------------------------------------------------------------------------------------
//  3 out, 1 in...
end;


function TGasExplosion.hash31( p:float):vec3;
var
  p3, ((p3.x + p3.y) * p3.z, (p3.x + p3.z) * p3.y, (p3.y + p3.z) * p3.x)):vec3;
begin
	p3  := fract(vec3(p) * HASHSCALE3);
	p3  := p3  + (dot(p3, p3.yzx + 19.19));
	return fract(
end;
//----------------------------------------------------------------------------------------
///  3 out, 2 in...
end;


function TGasExplosion.hash32(const p:vec2):vec3;
var
  p3, ((p3.x + p3.y) * p3.z, (p3.x + p3.z) * p3.y, (p3.y + p3.z) * p3.x)):vec3;
begin
	p3  := fract(vec3(p.xyx) * HASHSCALE3);
	p3  := p3  + (dot(p3, p3.yxz + 19.19));
	return fract(
end;
//----------------------------------------------------------------------------------------
///  3 out, 3 in...
end;


function TGasExplosion.hash33(const p3:vec3):vec3;
var
  ((p3.x + p3.y) * p3.z, (p3.x + p3.z) * p3.y, (p3.y + p3.z) * p3.x)):vec3;
begin
	p3  := fract(p3 * HASHSCALE3);
	p3  := p3  + (dot(p3, p3.yxz + 19.19));
	return fract(
end;
//----------------------------------------------------------------------------------------
// 4 out, 1 in...
end;


function TGasExplosion.hash41( p:float):vec4;
var
  p4:vec4;
begin
	p4  := fract(vec4(p) * HASHSCALE4);
	p4  := p4  + (dot(p4, p4.wzxy + 19.19));
	return fract(
			vec4((p4.x + p4.y) * p4.z, (p4.x + p4.z) * p4.y, (p4.y + p4.z) * p4.w,
					(p4.z + p4.w) * p4.x));
end;
//----------------------------------------------------------------------------------------
// 4 out, 2 in...
end;


function TGasExplosion.hash42(const p:vec2):vec4;
var
  p4:vec4;
begin
	p4  := fract(vec4(p.xyxy) * HASHSCALE4);
	p4  := p4  + (dot(p4, p4.wzxy + 19.19));
	return fract(
			vec4((p4.x + p4.y) * p4.z, (p4.x + p4.z) * p4.y, (p4.y + p4.z) * p4.w,
					(p4.z + p4.w) * p4.x));
end;
//----------------------------------------------------------------------------------------
// 4 out, 3 in...
end;


function TGasExplosion.hash43(const p:vec3):vec4;
var
  p4:vec4;
begin
	p4  := fract(vec4(p.xyzx) * HASHSCALE4);
	p4  := p4  + (dot(p4, p4.wzxy + 19.19));
	return fract(
			vec4((p4.x + p4.y) * p4.z, (p4.x + p4.z) * p4.y, (p4.y + p4.z) * p4.w,
					(p4.z + p4.w) * p4.x));
end;
//----------------------------------------------------------------------------------------
// 4 out, 4 in...
end;


function TGasExplosion.hash44(const p4:vec4):vec4;
begin
	p4  := fract(p4 * HASHSCALE4);
	p4  := p4  + (dot(p4, p4.wzxy + 19.19));
	return fract(
			vec4((p4.x + p4.y) * p4.z, (p4.x + p4.z) * p4.y, (p4.y + p4.z) * p4.w,
					(p4.z + p4.w) * p4.x));
end;
// From iq's website
end;


function TGasExplosion.sdCapsule(const p, a, b:vec3; r:float):float;
var
  pa = p - a, ba:vec3;
  h:float;
begin
	pa := p - a, ba  := b - a;
	h  := clamp(dot(pa, ba) / dot(ba, ba), 0, 1);
	Exit( length(pa - ba * h) - r );
end;


function TGasExplosion.parabola( x, k:float):float;
begin
	Exit( pow(4 * x * (1 - x), k) );
end;


function TGasExplosion.parabola(const x:vec4; k:float):vec4;
begin
	Exit( pow(4 * x * (1 - x), vec4(k)) );
end;


function TGasExplosion.parabola(const x:vec3; k:float):vec3;
begin
	Exit( pow(4 * x * (1 - x), vec3(k)) );
end;


function TGasExplosion.pcurve( x, a, b:float):float;
var
  k:float;
begin
	k  := pow(a + b, a + b) / (pow(a, a) * pow(b, b));
	Exit( k * pow(x, a) * pow(1 - x, b) );
end;


function TGasExplosion.veStars(const ro, rd:vec3):vec3;
var
  k:float;
  bs[8], srd:vec3;
  size:float;
  lower, point, ba, nba:vec3;
  ilba:float;
  nbatilba:vec3;
  d:float;
  xi, yi, zi, i:int;
  box:vec3;
  a:vec4;
  t:int;
  v:float;
  pos, local:vec3;
begin
	srd  := rd;
	size  := floor(subdiv);
	rd  := rd  * (length(rd) / max(abs(rd.x), max(abs(rd.y), abs(rd.z))));
	rd  := rd  * (size);
	lower  := floor(rd + 0.5);
	point  := rd - lower;
	ba  := rd - ro;
	nba  := normalize(ba);
	ilba  := 1 / dot(ba, ba);
	nbatilba  := nba * ilba;
	d  := 99999999;
	for xi  := -1 to  1 do
begin
		for yi  := -1 to  1 do
begin
			for zi  := -1 to  1 do
begin
				for i  := 0 to 4 do
begin
					box  := lower + Vec3.Create(float(xi),float(yi),zi);
					a  := vec4_20;
					for t  := 0 to 3 do
begin
						v  := t + 1 * 0.152;
						pos  := (box * v + 5 * i);
						a  := a  + (hash43(pos));
end;
					local  := a.xyz / 4 - 0.5;
					float dist := sdCapsule(ro + srd, ro, ro + box + local,
							a.w * accuscale);
					d  := min(d, dist);
end;
end;
end;
end;
	vec3 result := pow(
			clamp(pcurve(d * scalestar, 0, 1 + 31 * variable), 0, 1),
			variable2) * veColStars;
	Exit( result );
end;


function TGasExplosion.mainImage(var fragCoord:vec2):TColor32;
var
  uv:vec2;
  ((fragCoord.xy - 0.5 * resolution.xy) / resolution.y, 1)), ro:vec3;
  ld = 0, td = 0, w, density = 1, t, h:float;
  sum:vec4;
  min_dist = 0, max_dist:float;
  i:int;
  pos:vec3;
  d:float;
  ldst:vec3;
  lDist:float;
  lightColor, halo:vec3;
  col:vec4;
  uvd:vec2;
  sine:float;
  texUV:vec2;
  tex:vec4;
  stars:vec3;
  pass:float;
begin
	uv  := fragCoord / resolution.xy;
	// ro: ray origin
	// rd: direction of the ray
	vec3 rd := normalize(
	ro  := vec3_21;
	ro  := veAddZoom(rd, ro);
	veR(rd.yz, iMouse.x * 0.008 * pi);
	// ld, td: local, total density
	// w: weighting factor
	ld := 0, td := 0, w  := 0;
	// t: length of the ray
	// d: distance function
	density := 1, t  := 0;
 h   := 0.1;
	sum  := vec4_22;
	min_dist := 0, max_dist  := 0;
	if veRaySphereIntersect(ro, rd, min_dist, max_dist) then
begin
		t  := min_dist * step(t, min_dist);
		// raymarch loop
		for i  := 0 to 85 do
begin
			if veLOW_QUALITY  and  i >= 56 then
begin
				break;
end;
			pos  := ro + t * rd;
			// Loop break conditions.
			if td > 0.99  or  t > max_dist then
				break;
			// evaluate distance function
			d  := veMap(pos);
			if veBOTH then
begin
				if uv.y < 0.5 then
begin
					d  := abs(d) + 0.07;
end;
end;
 if veLEFT then
begin
				d  := abs(d) + 0.07;
end;
			// change this string to control density
			d  := max(d, 0.0000003);
  	//0.03
			// point light calculations
			ldst  := vec3_23 - pos;
			lDist  := max(length(ldst), 0.000000000001);
			// the color of light
			lightColor  := vec3_24;
			// bloom
			halo  := lightColor / exp(pow(lDist, 3) * 0.108);
			sum.rgb  := sum.rgb  + ((halo * 0.0333 * smoothstep(0.5, 0.1, veProgress)));
			if d < h then
begin
				// compute local density
				ld  := h - d;
				// compute weighting factor
				w  := (1 - td) * ld;
				// accumulate density
				td  := td  + (w + 1 / 20000);
				col  := vec4(veComputeColor(td, lDist), td);
				// emission
				sum  := sum  + (sum.a * vec4(sum.rgb, 0) * 0.2 / lDist);
				// uniform scale density
				col.a  := col.a  * (0.2);
				// colour by alpha
				col.rgb  := col.rgb  * (col.a);
				// alpha blend in contribution
				sum  := sum + col * (1 - sum.a);
end;
			td  := td  + (1 / 70);
			if veDITHERING then
begin
				// idea from https://www.shadertoy.com/view/lsj3Dw
				uvd  := uv;
				uvd.y  := uvd.y  * (120);
				uvd.x  := uvd.x  * (280);
				sine  := sin(4 * veProgress + uvd.y * 4);
				texUV  := Vec2.Create(uvd.y,-uvd.x + 0.5 * sine);
				tex  := texture(tex[2], texUV);
				d  := abs(d) * (0.8 + 0.08 * tex.r);
end;
			// trying to optimize step size
			if veLOW_QUALITY then
begin
				t  := t  + (max(d * 0.25, 0.01));
end;
 else
begin
				t  := t  + (max(d * 0.08 * max(min(length(ldst), d), 2), 0.01));
end;
end;
		// simple scattering
		if veLOW_QUALITY then
begin
			sum  := sum  * (1 / exp(ld * 0.2) * 0.9);
end;
 else
begin
			sum  := sum  * (1 / exp(ld * 0.2) * 0.8);
end;
		sum  := clamp(sum, 0, 1);
		sum.xyz  := sum.xyz * sum.xyz * (3 - 2 * sum.xyz);
end;
	if veBackground then
begin
		// stars background
		//vec3 stars := vec3(veNoise(rd * 200.0) * 0.5 + 0.5);
		stars  := veStars(ro, rd);
		vec3 starbg := mix(veColSkyHigh, veColSkyLow,
				abs(1.5 * dot(normalize(rd), vec3_25)));
		//vec3 starbg := mix(veColSkyHigh, veColSkyLow, uv.y);
		//vec3 brightness := smoothstep(0.95, 1.0, stars);
		//float limits := dot(vec3(0.0), rd) + 0.75;
		//starbg += veColStars * brightness * limits;
//		if (td < veBackgroundCutoff)
begin
//
end;
		pass  := smoothstep(veBackgroundCutoff, veBackgroundCutoffStart, td);
		//starbg *= pass;
		sum.xyz  := sum.xyz  + ((starbg + stars) * pass * (1 - sum.a));
		//sum.xyz += (veSpaceCol(ro, rd) * pass + starbg) * (1.0 - sum.a);
		//sum.xyz += veSpaceCol(ro, rd) * (1 - sum.a);
end;
	if veTONEMAPPING then
begin
		fragColor  := vec4(veToneMapFilmicALU(sum.xyz * 2.2), 1);
end;
 else
begin
		fragColor  := vec4(sum.xyz, 1);
end;
    Result  := fragColor;
end;




initialization
  GasExplosion := TGasExplosion.Create;
  Shaders.Add('GasExplosion', GasExplosion);

finalization
  FreeandNil(GasExplosion);

end.
