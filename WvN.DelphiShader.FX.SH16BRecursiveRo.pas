unit WvN.DelphiShader.FX.SH16BRecursiveRocket;

interface

uses GR32,Types,WvN.DelphiShader.Shader;

type
TSH16BRecursiveRocket = class(TShader)
const
  MARCH_STEPS = 30;
  vec3_2:vec3 = (x:1.0;y:0.9;z:0.65);
  vec3_3:vec3 = (x:1.0;y:0.3;z:0.0);
  vec2_4:vec2 = (x:37;y:17);
  vec3_5:vec3 = (x:0;y:0;z:+0.35);
  vec2_6:vec2 = (x:0.9701;y:0.2425);
  vec3_7:vec3 = (x:0;y:0;z:1.1);
  vec3_8:vec3 = (x:0;y:0;z:1);
  vec3_9:vec3 = (x:0;y:0;z:0);
  vec3_10:vec3 = (x:0;y:0;z:0);
  vec3_11:vec3 = (x:0;y:0;z:0);
  vec3_12:vec3 = (x:0;y:0;z:0);
  vec3_13:vec3 = (x:0.001;y:0;z:0);
  vec3_14:vec3 = (x:0;y:0;z:0);
  vec2_15:vec2 = (x:0.9801;y:0.1725);
  vec3_16:vec3 = (x:0.8;y:0.8;z:0.8);
  vec3_17:vec3 = (x:1;y:1;z:1);
  vec3_18:vec3 = (x:0.95;y:0.4;z:0);
  vec2_19:vec2 = (x:2.5;y:6);
  vec3_20:vec3 = (x:0.6;y:0.6;z:0.65);
  vec3_21:vec3 = (x:0.4;y:0.4;z:0.45);
  vec3_22:vec3 = (x:-1.4;y:3.7;z:1.1);
  vec3_23:vec3 = (x:0.5;y:0.6;z:0.7);
  vec3_24:vec3 = (x:0.2;y:0.3;z:0.4);
  vec2_25:vec2 = (x:0;y:0);
  vec3_26:vec3 = (x:0;y:0;z:0);
  vec3_27:vec3 = (x:0;y:0;z:0);
  vec3_28:vec3 = (x:0;y:0;z:0);
  vec3_29:vec3 = (x:0;y:0;z:0);
  vec3_30:vec3 = (x:0.5;y:0.3;z:0.1);
  vec3_31:vec3 = (x:0.05;y:0.05;z:0.05);


var
  fracSequence, fracFall, fracTotal, fracScale:float


  constructor  Create;override;
  procedure  PrepareFrame;
  function  nozzlePosition = vec3:vec3;
  function  altRot = mat2:mat2;
  function  altHeading = mat2:mat2;
  function  sunDir = vec3:vec3;
  function  backgroundColor = vec3:vec3;
  function  rot(const a :float):mat2;
  function  hash(const n :float):float;
  function  noise(const x :vec3):float;
  function  fog(const rgb:vec3;const dist:float;const rayOri, rayDir :vec3):vec3;
  function  fairingFunc(const x :float):float;
  procedure  rocketDE(const p:vec3;out d:float;out id:int;out texCoord :vec3);
  procedure  fractalRocketDE(const p:vec3;out d:float;out id:int;out texCoord :vec3);
  function  normal(const p:vec3; id:int;const texCoord:vec3):vec3;
  function  light(const p, n, c, dir:vec3;const rough:float;const doNoz :bool):vec3;
  function  density(const p :vec3):vec4;
  function  getBackground(const dir :vec3):vec3;
  function  getGroundColor(const dir :vec3):vec3;
  function  getFairingColor(const texCoord :vec3):vec3;
  function  mainImage(var fragCoord:vec2):TColor32;
end;

var
    SH16BRecursiveRocket:TShader
;

implementation

uses SysUtils, Math;

constructor TSH16BRecursiveRocket.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := mainImage;
end;


procedure TSH16BRecursiveRocket.PrepareFrame;
begin
end;


function TSH16BRecursiveRocket.nozzlePosition = vec3:vec3;
var
  nozzleStrength, altSpaceFrac:float;
begin
nozzleStrength  := 0;
altSpaceFrac  := 0;
end;


function TSH16BRecursiveRocket.altRot = mat2:mat2;
begin
end;


function TSH16BRecursiveRocket.altHeading = mat2:mat2;
var
  altAccel:float;
begin
altAccel  := 0;
end;


function TSH16BRecursiveRocket.sunDir = vec3:vec3;
var
  sunStrength:float;
begin
sunStrength  := 0;
end;


function TSH16BRecursiveRocket.backgroundColor = vec3:vec3;
begin
end;


function TSH16BRecursiveRocket.rot(const a :float):mat2;
var
  c, s:float;
begin
    c  := cos(a);
    s  := sin(a);
	Exit( mat2(c,s,-s,c) );
end;
// 1D noise
end;


function TSH16BRecursiveRocket.hash(const n :float):float;
begin
 Exit( fract(sin(n)*753.5453123) );
end;
// iq's 3D noise
end;


function TSH16BRecursiveRocket.noise(const x :vec3):float;
var
  f, p:vec3;
  uv, rg:vec2;
begin
    f  := fract(x);
    p  := x - f;
    f  := f*f*(3 - 2*f);
    rg  := texture2D(tex[0], (uv + 0.5)/256, -100).rg;
    Exit( mix(rg.y, rg.x, f.z) );
end;
// iq's fog
end;


function TSH16BRecursiveRocket.fog(const rgb:vec3;const dist:float;const rayOri, rayDir :vec3):vec3;
var
  c, b, fogAmount:float;
  fogColor:vec3;
begin
    c  := 0.01;
    b  := 0.3;
    rayOri  := rayOri  - (8);
    rayOri  := rayOri  + (altSpaceFrac*9);
    fogAmount  := c * exp(-rayOri.z*b) * (1-exp( -dist*rayDir.z*b ))/rayDir.z;
    fogAmount  := clamp(fogAmount, 0, 1);
    fogColor  := backgroundColor;
    Exit( mix( rgb, fogColor, fogAmount ) );
end;
// fairing shape, [0, 1] -> [0, 1]
end;


function TSH16BRecursiveRocket.fairingFunc(const x :float):float;
var
  v, xx:float;
begin
    #define MI 0.4
    if x < MI then
begin
        v  := 0.75 + x*1.5;
        Exit( clamp(v, 0.85, 1) );
end;
 else
begin
        xx  := (x - MI) / (1 - MI);
        xx  := xx  * (xx);
        Exit( max(0, 1 - xx) );
end;
end;
// rocket distance estimator, returns the distance to the rocket without fairings
end;


procedure TSH16BRecursiveRocket.rocketDE(const p:vec3;out d:float;out id:int;out texCoord :vec3);
var
  lenxy:float;
  ori:vec2;
  tank, engine:float;
  tubeOffset:vec2;
  tube, nozzle, gravity:float;
  tp, rp:vec3;
  randRot:float;
  i:int;
  ii, ss:float;
  origin, pp:vec3;
  randRot, randRot2:float;
  delt:vec3;
  fairDist:float;
begin
    lenxy  := length(p.xy);
    ori  := p.xy / lenxy;
    // main fuel tank
    tank  := lenxy - 0.3;
    tank  := max( tank, abs(p.z - 0.3) - 0.7 );
    // spherical combustion chamber
    engine  := length(p + vec3_5) - 0.27;
    // add tubes
    tubeOffset  := p.xy - sign(p.xy) * 0.07;
    tube  := length(tubeOffset) - 0.05;
    tube  := max( tube, abs(p.z + 0.6) - 0.1 );
    engine  := min(engine, tube);
    // engine nozzle
    nozzle  := nozzle  + (sin(p.z*114)*0.007);
   // add some ridges
    nozzle  := max(nozzle, abs(p.z + 0.85) - 0.15);
    nozzle  := max(nozzle, -(length(p + vec3_7) - 0.26));
    engine  := min(engine, nozzle);
    texCoord  := p;
    if tank < engine then
begin
        d  := tank;
        id  := 1;
end;
 else
begin
        d  := engine;
        id  := 2;
end;
end;
// falling rocket + falling fairings distance estimator
void rocketAndFairingDE( in vec3 p, in float frac, in float seed,
                         out float d, out int id, out vec3 texCoord )
begin
    gravity  := frac*frac;
    tp  := p;
    // randomize rotation of each rockets
    tp.xy  := tp.xy  * (rot( PI*sin(seed*4125.664) ));
    rp  := tp;
    if frac > 0 then
begin
        rp.z  := rp.z  + (gravity*88);
        randRot  := 1.1 * sin(seed*321.81);
        rp.xz  := rp.xz  * (rot(frac*2*randRot));
end;
    // get the distance to the rocket
    rocketDE(rp, d, id, texCoord);
    // for each parts of the fairings
    for i  := -1 to  1 do
begin
        ii  := i;
        ss  := sign(ii);
        origin  := vec3_8;
        // add horizontal velocity
        origin.y  := origin.y  + (ii*frac*18);
        // then gravity
        origin.z  := origin.z  - (gravity*72);
        pp  := tp - origin;
        if frac > 0 then
begin
            // randomize rotation of each fairing parts
            randRot  := 1 + sin(seed*391.81+ii*122.35+154.42)*0.2;
            randRot2  := sin(seed*458.91+ii*138.42+284.66);
            delt  := Vec3.Create(0,ss*0.1,-0.5);
            pp  := pp  + (delt);
   // change center of gravity
            pp.yz  := pp.yz  * (rot(frac*-ss*14*randRot));
            pp.xy  := pp.xy  * (rot(frac*randRot2*4));
            pp  := pp  - (delt);
end;
        fairDist  := length(pp.xy) - fairingFunc(pp.z/1.5)*0.32;
        fairDist  := abs(fairDist)-0.01;
        fairDist  := max(fairDist, -pp.z);
        fairDist  := max(fairDist, pp.z-1.5);
        fairDist  := max(fairDist, -pp.y*ss);
        if fairDist < d then
begin
            d  := fairDist;
            id  := 3;
            texCoord  := pp;
end;
end;
end;
// rocket inside a rocket
end;


procedure TSH16BRecursiveRocket.fractalRocketDE(const p:vec3;out d:float;out id:int;out texCoord :vec3);
var
  bottomP:vec3;
  bottomSeed, bottomDist:float;
  bottomID:int;
  bottomTexCoord:vec3;
  topScale:float;
  topP:vec3;
  topSeed, topDist:float;
  topID:int;
  topTexCoord:vec3;
begin
    p.yz  := p.yz  * (altRot);
    bottomP  := p/fracScale;
    bottomP.z  := bottomP.z  + (fracTotal * 1.45);
    bottomSeed  := fracSequence;
    bottomDist  := 0;
    bottomID  := 0;
    bottomTexCoord  := vec3_9;
    rocketAndFairingDE(bottomP, fracFall, bottomSeed, bottomDist, bottomID, bottomTexCoord);
    bottomID  := -bottomID;
   // invert the sign of the bottom rocket
    bottomDist  := bottomDist  * (fracScale);
    topScale  := fracScale / SCALE;
    topP  := p;
    topP.z  := topP.z  - ((1 - fracTotal) * 1.45);
    topP  := topP  / (topScale);
    topSeed  := fracSequence + 1;
    topDist  := 0;
    topID  := 0;
    topTexCoord  := vec3_10;
    rocketAndFairingDE(topP, 0, topSeed, topDist, topID, topTexCoord);
    topDist  := topDist  * (topScale);
    if bottomDist < topDist then
begin
        d  := bottomDist;
        id  := bottomID;
        texCoord  := bottomTexCoord;
end;
 else
begin
        d  := topDist;
        id  := topID;
        texCoord  := topTexCoord;
end;
end;
// normal function
end;


function TSH16BRecursiveRocket.normal(const p:vec3; id:int;const texCoord:vec3):vec3;
var
  dist:float;
  distV:vec3;
  tempID:int;
  tempTexCoord, e, n:vec3;
begin
    dist  := 0;
    distV  := vec3_11;
    tempID  := 0;
    tempTexCoord  := vec3_12;
	e  := vec3_13;
    fractalRocketDE(p, dist, tempID, tempTexCoord);
    fractalRocketDE(p-e.xyy, distV.x, tempID, tempTexCoord);
    fractalRocketDE(p-e.yxy, distV.y, tempID, tempTexCoord);
    fractalRocketDE(p-e.yyx, distV.z, tempID, tempTexCoord);
    n  := dist-distV;
    // do normal mapping on the surface of the tank
    if id := 1  or  id := -1 then
begin
        n.x  := n.x  + (noise(texCoord*80.12)*0.0002 - 0.0001);
        n.y  := n.y  + (noise(texCoord*79.14)*0.0002 - 0.0001);
        n.z  := n.z  + (noise(texCoord*81.19)*0.0002 - 0.0001);
end;
	Exit( normalize(n) );
end;
// light the scene
end;


function TSH16BRecursiveRocket.light(const p, n, c, dir:vec3;const rough:float;const doNoz :bool):vec3;
var
  pp:vec3;
  specScale, sun, sunSpec, noz:float;
  delt, deltN, nn:vec3;
  nozSpe, ao:float;
  id:int;
  texCoord, result:vec3;
begin
    pp  := p;
    p.yz  := p.yz  * (altRot);
    specScale  := (rough+1)*0.25;
    sun  := max(0, -dot(n, sunDir));
    sunSpec  := pow(max(0, -dot(dir, reflect(sunDir, n))), rough);
    sun  := sun  + (sunSpec*specScale);
    sun  := sun  * (sunStrength);
    noz  := 0;
    if doNoz then
begin
        delt  := (nozzlePosition - p) / fracScale;
        deltN  := normalize(delt);
        nn  := n;
        nn.yz  := nn.yz  * (altRot);
        noz  := max(0, dot(nn, deltN));
        nozSpe  := pow(max(0, dot(dir, reflect(deltN, nn))), rough);
        noz  := noz  + (nozSpe*specScale);
        noz  := noz  / (dot(delt, delt));
        noz  := noz  * (nozzleStrength);
end;
    ao  := 0;
    id  := 0;
    texCoord  := vec3_14;
    fractalRocketDE(pp+n*0.1, ao, id, texCoord);
  ;
    ao  := clamp(ao / 0.1, 0, 1);
    result  := c*ao*backgroundColor*0.2;
    result  := result  + (c*sun*sunColor);
    result  := result  + (c*noz*nozColor);
    Exit( result );
end;
// density function for the trail
end;


function TSH16BRecursiveRocket.density(const p :vec3):vec4;
var
  accel:vec3;
  grav:float;
  pp, ppp:vec3;
  cyl:vec2;
  nozzle, alphaNozzle, noiseValue, len, theta, randV, radius, fire:float;
  baseColor:vec3;
begin
    p.yz  := p.yz  * (altRot);
    // accelerate the smoke along the rocket trajectory
    accel  := Vec3.Create(0,0,iGlobalTime*16);
    grav  := (fracTotal*fracTotal)*-32;
    pp  := (p-nozzlePosition) / fracScale;
    ppp  := pp;
    pp.x  := pp.x  + (noise(p*1.2+accel)*0.2-0.1);
    pp.y  := pp.y  + (noise(p*1.3+accel)*0.2-0.1);
    pp.z  := pp.z  + (noise(p*1.6+accel)*0.2-0.1);
    cyl  := Vec2.Create(length(pp.xy),pp.z);
    // add smoke around the trail
    alphaNozzle  := 1 - smoothstep(0, 0.1, nozzle);
    alphaNozzle  := alphaNozzle  * (1 - smoothstep(0, 0.05, pp.z));
    alphaNozzle  := alphaNozzle  * (smoothstep(grav, grav+1, pp.z));
  ;
    alphaNozzle  := alphaNozzle  / (fracScale);
    alphaNozzle  := alphaNozzle  * (nozzleStrength);
    alphaNozzle  := clamp(alphaNozzle, 0, 1);
    // add some noise
    noiseValue  := 1;
    noiseValue  := noiseValue  + (noise(p*1.9+accel)*3);
    noiseValue  := noiseValue  + (noise(p*2.2+accel)*1);
    noiseValue  := noiseValue  + (noise(p*4.4+accel)*0.5);
    noiseValue  := noiseValue  * ((1-altSpaceFrac));
    noiseValue  := noiseValue  * (0.005);
    noiseValue  := clamp(noiseValue, 0, 1);
    // add a fire trail
    ppp.z  := ppp.z  + (0.05);
    len  := length(ppp);
    theta  := acos(-ppp.z / len) / (PI*0.5);
    randV  := noise(p*4+accel);
    radius  := 1 / (theta + 0.01 + randV*0.05);
    fire  := 1 - smoothstep(0, 0.1, len - radius * 0.04);
    fire  := fire  / (fracScale);
    fire  := fire  * (2);
    fire  := fire  * (nozzleStrength);
    fire  := fire  * (smoothstep(grav-2, grav-1, pp.z));
    fire  := clamp(fire, 0, 1);
    // base color of the smoke
    baseColor  := mix(Vec3.Create(0.5),vec3_16,noise(p*2+accel));
    baseColor  := baseColor  * (1 - alphaNozzle*0.9);
   // lighter outside the trail
    baseColor  := baseColor  * ((sunStrength*0.75+0.25));
   // darker during night
    baseColor  := mix(baseColor, nozColor, fire);
   // colored fire
    Exit( vec4.Create(baseColor,max(noiseValue,max(alphaNozzle,fire))) );
end;
// background color
end;


function TSH16BRecursiveRocket.getBackground(const dir :vec3):vec3;
var
  ddir:vec3;
  noiseValue, stars:float;
  starry:vec3;
  dsun, sun, factor:float;
begin
    // rotate stars
    ddir  := dir;
    ddir.yz  := ddir.yz  * (altHeading);
    // add stars
    noiseValue  := 1;
    noiseValue  := noiseValue  * (noise( ddir*161.58 ));
    noiseValue  := noiseValue  * (noise( ddir*323.94 ));
    stars  := noiseValue*1.08;
    stars  := stars  * (stars);
   stars  := stars  * (stars);
    stars  := stars  * (stars);
   stars  := stars  * (stars);
    starry  := mix(Vec3.Create(0),vec3_17,stars);
    // sun
    dsun  := max(0, -dot(sunDir, dir));
    sun  := smoothstep(0.9996, 0.999956, dsun);
    starry  := mix(starry, sunColor, sun);
    factor  := pow(dsun, 2000);
    starry  := starry  + (sunColor*sunStrength*0.4*factor);
    Exit( starry );
end;
// ground color
end;


function TSH16BRecursiveRocket.getGroundColor(const dir :vec3):vec3;
var
  texCoord:vec3;
  backColor:float;
  groundColor:vec3;
begin
    texCoord  := dir/(dir.z/(1+altSpaceFrac*5));
    texCoord  := texCoord  * (0.01);
    texCoord.y  := texCoord.y  + (altAccel*altSpaceFrac*0.18);
    texCoord.xy  := texCoord.xy  * (rot(5.0832));
    backColor  := smoothstep(-1+altSpaceFrac*0.75, 0, dir.z)*0.4+0.6;
    groundColor  := texture2D(tex[2], texCoord.xy).rgb;
    groundColor  := mix(groundColor, backgroundColor, (1-sunStrength)*0.7);
    Exit( mix(groundColor, backgroundColor, backColor) );
end;
// texture for the fairings
end;


function TSH16BRecursiveRocket.getFairingColor(const texCoord :vec3):vec3;
var
  grid:vec2;
  gridValue:float;
begin
    if texCoord.z < 0.1 then
     Exit( vec3_18 );
    grid  := Vec2.Create(texCoord.z, atan(texCoord.y,texCoord.x) / PI * 0.5 + 0.5);
    grid  := floor(grid);
    gridValue  := &mod(grid.x+grid.y, 2);
    if grid.x > 1.5 then
     gridValue  := 1;
    if abs(texCoord.y) < 0.01 then
     gridValue  := 0;
    Exit( mix(vec3_21, vec3_20, gridValue) );
end;


function TSH16BRecursiveRocket.mainImage(var fragCoord:vec2):TColor32;
var
  timeValue:float;
  uv:vec2;
  from, dir:vec3;
  mouse:vec2;
  shake:float;
  rotxz, rotxy:mat2;
  totdist:float;
  set:bool;
  norm:vec3;
  dist:float;
  id:int;
  texCoord:vec3;
  randVec:vec2;
  dither:float;
  steps:int;
  p, emiss, color:vec3;
  rough:float;
  bot:bool;
  iid:int;
  nozz, sunLook, totdistmarch:float;
  steps:int;
  p:vec3;
  col:vec4;
begin
    // initialize global variables once
    timeValue  := (iGlobalTime-10) * 0.05;
    fracSequence  := floor(timeValue);
	fracFall  := fract(timeValue);
	fracTotal  := smoothstep(0, 0.5, fracFall);
    fracScale  := mix(1, SCALE, fracTotal);
    nozzlePosition  := Vec3.Create(0,0,1.1 - fracTotal*2.1);
    nozzleStrength  := smoothstep(0, 0.02, fracTotal);
    nozzleStrength  := nozzleStrength  * (1 - smoothstep(0.8, 1, fracFall));
    altSpaceFrac  := 1 - pow(4.2, -iGlobalTime*0.01);
    altRot  := rot(PI*0.5*altSpaceFrac);
    altAccel  := iGlobalTime*0.07;
    altAccel  := altAccel  * (altAccel);
	altHeading  := rot(-altAccel*0.09*altSpaceFrac);
    sunDir  := normalize(vec3_22);
    sunDir.yz  := sunDir.yz  * (altHeading);
    sunDir.z  := sunDir.z  * (-1);
    sunStrength  := 1 - smoothstep(-0.15, 0.08, sunDir.z);
    backgroundColor  := mix(vec3_24, vec3_23, sunStrength);
    uv  := fragCoord.xy / resolution.xy * 2 - 1;
	uv.y  := uv.y  * (resolution.y / resolution.x);
	from  := Vec3.Create(-14 + smoothstep(0, 20, iGlobalTime)*4,0,0);
	dir  := Vec3.Create(uv.x*0.5,1,uv.y*0.5);
    dir.y  := dir.y  + (exp(length(uv)) * 0.15);
    dir  := normalize(dir);
	dir.xy  := dir.xy  * (rot(3.1415*0.5));
    mouse := (iMouse.xy / resolution.xy - 0.5) * 0.5;
	if iMouse.z < 1 then
     mouse  := vec2_25;
    shake  := smoothstep(0.1, 0.3, fracTotal);
    shake  := shake  * (1 - smoothstep(0.7, 0.9, fracFall));
    vec2 rand := Vec2.Create(noise(Vec3.Create(iGlobalTime*15.4,0,0)),
                     noise(Vec3.Create(iGlobalTime*17.2,9.9,9.9))) * shake;
    rotxz  := rot(-0.16-mouse.y*5 + sin(iGlobalTime*0.0645)*0.07 + rand.x*0.01);
	rotxy  := rot(0.2+mouse.x*8 + sin(iGlobalTime*0.0729)*1.1 + rand.y*0.01);
    from.xz  := from.xz  * (rotxz);
	from.xy  := from.xy  * (rotxy);
	dir.xz   := dir.xz   * (rotxz);
	dir.xy   := dir.xy   * (rotxy);
	totdist  := 0;
	set  := false;
	norm  := vec3_26;
    dist  := 0;
    id  := 0;
    texCoord  := vec3_27;
    // offset starting distance with a dithered value
    randVec  := Vec2.Create(hash(iGlobalTime),hash(iGlobalTime*1.61541));
    dither  := texture2D(tex[1], fragCoord.xy / 8 + randVec).r;
    fractalRocketDE(from, dist, id, texCoord);
    {$ifdef DITHER}
    totdist  := totdist  + (dist*dither);
    {$endif }
    // run sphere tracing to find the rocket surface
	for steps  := 0  to  50 -1 do
begin
		if set then
     continue;
		p  := from + totdist * dir;
        fractalRocketDE(p, dist, id, texCoord);
        dist  := dist  * (0.75);
		totdist  := totdist  + (max(0, dist));
		if dist < 0.01 then
begin
			set  := true;
			norm  := normal(p, id, texCoord);
end;
end;
    // do surface texture/light when an object is found
    if set then
begin
        emiss  := vec3_28;
        color  := vec3_29;
        rough  := 0;
        bot  := id < 0;
        iid  := bot ? -id : id;
        if iid := 1 then
begin
            color  := vec3_30;
            rough  := 8;
end;
 if iid := 2 then
begin
            color  := vec3_31;
            nozz  := smoothstep(0.6, 1.3, -texCoord.z);
            if id > 0 then
     nozz  := nozz  * (smoothstep(0, 0.7, fracTotal));
            emiss  := vec3(nozColor) * nozz * 0.4;
            rough  := 16;
end;
 if iid := 3 then
begin
            color  := getFairingColor(texCoord);
            rough  := 3;
end;
        fragColor.a  := 1;
        fragColor.rgb  := light( from+dir*totdist, norm, color, dir, rough, bot );
        fragColor.rgb  := fragColor.rgb  + (emiss);
end;
 else
begin
        // pass some landscape on the ground
    	backgroundColor  := getGroundColor(dir);
        // get the background otherwise
        fragColor.rgb  := getBackground(dir);
        totdist  := 99999.9;
end;
    // modify the background color when looking at the sun
    sunLook  := max(0, dot(dir, -sunDir))*sunStrength;
    sunLook  := sunLook  * (sunLook);
   sunLook  := sunLook  * (sunLook);
    backgroundColor  := mix(backgroundColor, sunColor, sunLook);
    // apply fog
    fragColor.rgb  := fog( fragColor.rgb, totdist, from, dir);
    // do volumetric rendering back to front
    totdistmarch  := MARCH_DIST*MARCH_STEPS;
    totdistmarch  := min(totdist, totdistmarch);
    {$ifdef DITHER}
    totdistmarch  := totdistmarch  - (dither*MARCH_DIST);
    {$endif }
    for steps  := 0  to  MARCH_STEPS -1 do
begin
        if totdistmarch < 0 then  continue;
        p  := from + totdistmarch * dir;
        col  := density(p);
        col.a  := col.a  * (MARCH_DIST);
       	// apply fog to the color
        col.rgb  := fog( col.rgb, totdistmarch, from, dir );
        // accumulate opacity
        fragColor.rgb  := fragColor.rgb*(1-col.a)+col.rgb*col.a;
        totdistmarch  := totdistmarch  - (MARCH_DIST);
end;
    fragColor.rgb  := pow( fragColor.rgb, vec3(1/2.2) );
    fragColor.a  := 1;
    // vignette
    fragColor.rgb  := fragColor.rgb  - (dot(uv, uv)*0.1);
end;




initialization
  SH16BRecursiveRocket := TSH16BRecursiveRocket.Create;
  Shaders.Add('SH16BRecursiveRocket', SH16BRecursiveRocket);

finalization
  FreeandNil(SH16BRecursiveRocket);

end.
