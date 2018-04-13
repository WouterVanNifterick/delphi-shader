unit WvN.DelphiShader.FX.RollingHills;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  // Rolling hills. By David Hoskins, November 2013.
  // https://www.shadertoy.com/view/Xsf3zX

  // v.2.00 Uses eiffie's 'Circle of Confusion' function
  // for blurred ray marching into the grass.
  // v.1.02 Camera aberrations.
  // v.1.01 Added better grass, with wind movement.


  TRollingHills = class(TShader)
  public const
    vec3_1: vec3  = (x: 1; y: 0.75; z: 0.6);
    vec2_2: vec2  = (x: 12.9898; y: 78.233);
    vec3_3: vec3  = (x: 0.32; y: 0.32; z: 0.32);
    vec3_4: vec3  = (x: 0.1; y: 0.2; z: 0.3);
    vec4_5: vec4  = (x: 0; y: 0.05; z: 0; w: 0);
    vec3_6: vec3  = (x: 0.1; y: 0.15; z: 0.05);
    vec3_7: vec3  = (x: 0.2; y: 0.3; z: 0);
    vec3_8: vec3  = (x: 0; y: 0.3; z: 0);
    vec3_9: vec3  = (x: 0.45; y: 0.45; z: 0.45);
    vec3_10: vec3 = (x: 0.2125; y: 0.7154; z: 0.0721);
    vec4_11: vec4 = (x: 0; y: 0; z: 0; w: 0);
    vec2_12: vec2 = (x: 0.1; y: 0);
    vec3_13: vec3 = (x: 1; y: 0; z: 0);
    vec3_14: vec3 = (x: 0; y: 1; z: 1);
    vec3_15: vec3 = (x: 1; y: 1; z: 0);
    vec3_16: vec3 = (x: 0.5; y: 1; z: 1);

    function Hash(n: float): float; overload;
    function Hash(const p: vec2): float; overload;
    function Noise(const x: vec2): float;
    function Voronoi(const x: vec2): vec2;
    function Terrain(const p: vec2): vec2;
    function Map(const p: vec3): vec2;
    function FractalNoise(xy: vec2): float;
    function GetSky(const rd: vec3): vec3;
    function ApplyFog(const rgb: vec3; const dis: float; const dir: vec3): vec3;
    function DE(const p: vec3): vec3;
    function CircleOfConfusion(t: float): float;
    function Linstep(a, b, t: float): float;
    function GrassBlades(const rO, rd, mat: vec3; const dist: float): vec3;
    procedure DoLighting(out mat: vec3; const pos, normal, eyeDir: vec3; const dis: float);
    function TerrainColour(const pos, dir, normal: vec3; dis, &type: float): vec3;
    function BinarySubdivision(const rO, rd: vec3; t, oldT: float): float;
    function Scene(const rO, rd: vec3; out resT, &type: float): bool;
    function CameraPath(t: float): vec3;
    function PostEffects(rgb: vec3; const xy: vec2): vec3;
    function Main(var gl_FragCoord: vec2): TColor32;

  var
    PI       : float;
    sunLight : vec3;
    sunColour: vec3;
    rotate2D : mat2;
    gTime    : float;
    cameraPos: vec3;
    constructor Create; override;
    procedure PrepareFrame;
  end;

var
  RollingHills: TShader;

implementation

uses SysUtils, Math;

constructor TRollingHills.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;

procedure TRollingHills.PrepareFrame;
begin
  PI := 4 * atan(1);

  sunLight  := normalize(vec3.Create(0.35, 0.2, 0.3));
  sunColour := vec3_1;
  rotate2D  := mat2.Create(1.932, 1.623, -1.623, 1.952);
  gTime     := 0;

  // --------------------------------------------------------------------------
  // Noise functions...

end;

function TRollingHills.Hash(n: float): float;
begin
  Exit(fract(system.sin(n) * 43758.5453123));
end;


// --------------------------------------------------------------------------

function TRollingHills.Hash(const p: vec2): float;
begin
  Exit(fract(system.sin(dot(p, vec2_2)) * 43758.5453));
end;


// --------------------------------------------------------------------------

function TRollingHills.Noise(const x: vec2): float;
var
  p  : vec2;
  f  : vec2;
  n  : float;
  res: float;

begin
  p   := floor(x);
  f   := fract(x);
  f   := f * f * (3 - 2 * f);
  n   := p.x + p.y * 57;
  res := mix(mix(Hash(n + 0), Hash(n + 1), f.x), mix(Hash(n + 57), Hash(n + 58), f.x), f.y);
  Exit(res);
end;

function TRollingHills.Voronoi(const x: vec2): vec2;
var
  p, f, b, r: vec2;
  d, id, res: float;
  i, j      : integer;
begin
  id := 0;
  if x.x<10000 then
   Exit(vec2Black)
  else if x.y<10000 then
   Exit(vec2Black)
  else if x.x>10000 then
   Exit(vec2Black)
  else if x.y>10000 then
   Exit(vec2Black);

  p       := floor(x);
  f       := fract(x);
  res     := 100;
  for j   := -1 to 1 do
    for i := -1 to 1 do
    begin
      b := vec2.Create(i, j);
      r := vec2(b) - f + Hash(p + b);
      d := dot(r, r);
      if d < res then
      begin
        res := d;
        id  := Hash(p + b);
      end;
    end;
  Exit(vec2.Create(Math.max(0.4 - system.Sqrt(res), 0), id));
end;



// --------------------------------------------------------------------------

function TRollingHills.Terrain(const p: vec2): vec2;
var
  &type: float;
  pos  : vec2;
  w, f : float;
  i    : integer;

begin
  &type := 0;
  pos   := p * 0.003;
  w     := 50;
  f     := 0;
  for i := 0 to 2 do
  begin
    f   := f + (Noise(pos) * w);
    w   := w * 0.62;
    pos := pos * (2.5);
  end;

  Exit(vec2.Create(f, &type));
end;


// --------------------------------------------------------------------------

function TRollingHills.Map(const p: vec3): vec2;
var
  h: vec2;

begin
  h := Terrain(p.xz);
  Exit(vec2.Create(p.y - h.x, h.y));
end;


// --------------------------------------------------------------------------

function TRollingHills.FractalNoise(xy: vec2): float;
var
  w: float;
  f: float;
  i: integer;

begin
  w := 0.7;
  f := 0;

  for i := 0 to 2 do
  begin
    f  := f + (Noise(xy) * w);
    w  := w * 0.6;
    xy := 2 * xy;
  end;
  Result := f;
end;

// --------------------------------------------------------------------------
// Grab all sky information for a given ray from camera
function TRollingHills.GetSky(const rd: vec3): vec3;
var
  sunAmount: float;
  v        : float;
  sky      : vec3;

begin
  sunAmount := Math.max(dot(rd, sunLight), 0);
  v         := pow(1 - Math.max(rd.y, 0), 6);
  sky       := mix(vec3_4, vec3_3, v);
  sky       := sky + sunColour * sunAmount * sunAmount * 0.25;
  sky       := sky + sunColour * min(pow(sunAmount, 350) * 1.5, 0.3);
  Exit(clamp(sky, 0, 1));
end;

// --------------------------------------------------------------------------
// Merge grass into the sky background for correct fog colouring...
function TRollingHills.ApplyFog(const rgb: vec3; const dis: float; const dir: vec3): vec3;
var
  fogAmount: float;

begin
  fogAmount := clamp(dis * dis * 0.0000012, 0, 1);
  Exit(mix(rgb, GetSky(dir), fogAmount));
end;


// --------------------------------------------------------------------------

function TRollingHills.DE(const p: vec3): vec3;
var
  base  : float;
  height: float;
  y     : float;
  ret   : vec2;
  f     : float;

begin
  base   := Terrain(p.xz).x - 1.9;
  height := Noise(p.xz * 2) * 0.75 + Noise(p.xz) * 0.35 + Noise(p.xz * 0.5) * 0.2;
  // p.y  := //p.y  + (height);
  y   := p.y - base - height;
  y   := y * y;
  ret := Voronoi((p.xz * 2.5 + sin(y * 4 + p.zx) * 0.12 + vec2.Create(system.sin(time * 2.3 + 0.5 * p.z), system.sin(time * 3.6 + 0.5 * p.x)) * y * 0.5));
  f   := ret.x * 0.6 + y * 0.58;
  Exit(vec3.Create(y - f * 1.4, clamp(f * 1.3, 0, 1), ret.y));
end;

// --------------------------------------------------------------------------
// eiffie's code for calculating the aperture size for a given distance...
function TRollingHills.CircleOfConfusion(t: float): float;
begin
  Exit(max(t * 0.04, (2 / resolution.y) * (1 + t)));
end;


// --------------------------------------------------------------------------

function TRollingHills.Linstep(a, b, t: float): float;
begin
  Exit(clamp((t - a) / (b - a), 0, 1));
end;


// --------------------------------------------------------------------------

function TRollingHills.GrassBlades(const rO, rd, mat: vec3; const dist: float): vec3;
var
  d    : float;
  rCoC : float;
  alpha: float;
  col  : vec4;
  i    : integer;
  p    : vec3;
  ret  : vec3;
  gra  : vec3;

begin
  d := 0;

  // Only calculate cCoC once is enough here...
  rCoC  := CircleOfConfusion(dist * 0.3);

  col := vec4_5;

  for i := 0 to 14 do
  begin
    if col.w > 0.99 then
      break;
    p := rO + rd * d;

    ret   := DE(p);
    ret.x := ret.x + (0.5 * rCoC);

    if ret.x < rCoC then
    begin
      alpha := (1 - col.y) * Linstep(-rCoC, rCoC, -ret.x); // calculate the mix like cloud density
      // Mix material with white tips for grass...
      gra := mix(mat, vec3.Create(0.35, 0.35, min(pow(ret.z, 4) * 35, 0.35)), pow(ret.y, 9) * 0.7) * ret.y;
      col := col + vec4.Create(gra * alpha, alpha);
    end;

    d := d + (max(ret.x * 0.7, 0.1));
  end;

  if col.w < 0.2 then
    col.xyz := vec3_6;
  Exit(col.xyz);
end;

// --------------------------------------------------------------------------
// Calculate sun light...
procedure TRollingHills.DoLighting(out mat: vec3; const pos, normal, eyeDir: vec3; const dis: float);
var
  h: float;
begin
  h   := dot(sunLight, normal);
  mat := mat * sunColour * (Math.max(h, 0) + 0.2);
end;


// --------------------------------------------------------------------------

function TRollingHills.TerrainColour(const pos, dir, normal: vec3; dis, &type: float): vec3;
var
  mat: vec3;
  t  : float;
begin

  if &type = 0 then
  begin
    // Random colour...
    mat := mix(vec3_8, vec3_7, Noise(pos.xz * 0.025));
    // Random shadows...
    t := FractalNoise(pos.xz * 0.1) + 0.5;
    // Do grass blade tracing...
    mat := GrassBlades(pos, dir, mat, dis) * t;
    DoLighting(mat, pos, normal, dir, dis);
  end;

  mat := ApplyFog(mat, dis, dir);
  Exit(mat);
end;

// --------------------------------------------------------------------------
// Home in on the surface by dividing by two and split...
function TRollingHills.BinarySubdivision(const rO, rd: vec3; t, oldT: float): float;
var
  halfwayT: float;
  n       : integer;
begin
  for n    := 0 to 4 do
  begin
    halfwayT := (oldT + t) * 0.5;
    if Map(rO + halfwayT * rd).x < 0.05 then
      t := halfwayT
    else
      oldT := halfwayT;
  end;
  Exit(t);
end;


// --------------------------------------------------------------------------

function TRollingHills.Scene(const rO, rd: vec3; out resT, &type: float): bool;
var
  t    : float;
  oldT : float;
  delta: float;
  j    : integer;
  p    : vec3;
  h    : vec2;

begin
  t     := 5;
  oldT  := 0;
  for j := 0 to 79 do
  begin
    p := rO + t * rd;
    if p.y > 105 then
      Exit(false); // ...Over highest peak

    h := Map(p);
    // Are we inside, and close enough to fudge a hit?...
    if h.x < 0.05 then
    begin
      // Yes not  So home in on height map...
      resT  := BinarySubdivision(rO, rd, t, oldT);
      &type := h.y;
      Exit(true);
    end;

    // Delta ray advance - a fudge between the height returned
    // and the distance already travelled.
    // Compromise between speed and accuracy...
    delta := Math.max(0.04, 0.35 * h.x) + (t * 0.04);
    oldT  := t;
    t     := t + delta;
  end;

  Exit(false);
end;


// --------------------------------------------------------------------------

function TRollingHills.CameraPath(t: float): vec3;
var
  p: vec2;
begin
  // t  := time + t;
  p := vec2.Create(200 * system.sin(3.54 * t), 200 * system.cos(2 * t));
  Exit(vec3.Create(p.x + 55, 12 + system.sin(t * 0.3) * 6.5, -94 + p.y));
end;


// --------------------------------------------------------------------------


function TRollingHills.PostEffects(rgb: vec3; const xy: vec2): vec3;
const
  CONTRAST = 1.1;
  SATURATION = 1.3;
  BRIGHTNESS = 1.3;
begin
  // Gamma first...
  rgb := pow(rgb, vec3_9);

  // Then...
  rgb := mix(vec3.Create(0.5), mix(vec3.Create(dot(vec3_10, rgb * BRIGHTNESS)), rgb * BRIGHTNESS, SATURATION), CONTRAST);
  // Vignette...
  rgb := rgb * (0.4 + 0.5 * pow(40 * xy.x * xy.y * (1 - xy.x) * (1 - xy.y), 0.2));
  Exit(rgb);
end;


// --------------------------------------------------------------------------

function TRollingHills.Main(var gl_FragCoord: vec2): TColor32;
var
  m     : float;
  gTime : float;
  xy    : vec2;
  uv    : vec2;
  camTar: vec3;
{$IFDEF STEREO}
  isCyan: float;
{$ENDIF}
  roll    : float;
  cw, cp, cu, cv : vec3;
  dir     : vec3;
  camMat  : mat3;
  col     : vec3;
  distance: float;
  &type   : float;
  pos     : vec3;
  p       : vec2;
  nor     : vec3;
  v2      : vec3;
  v3      : vec3;
  bri     : float;
  sunPos  : vec2;
  glare , glare2, glare3, glare4  : float;

begin
  m     := (mouse.x) * 300;
  gTime := (time * 5 + m + 2352) * 0.006;
  xy    := gl_FragCoord.xy / resolution.xy;
  uv    := (-1 + 2 * xy) * vec2.Create(resolution.x / resolution.y, 1);

  if (xy.y < 0.13) or (xy.y >= 0.87) then
  begin
    // Top and bottom cine-crop - what a waste not  :)
    Exit(TColor32(vec4_11));
  end;

{$IFDEF STEREO}
  isCyan := mod (gl_FragCoord.x + mod (gl_FragCoord.y, 2), 2);
{$ENDIF }
  cameraPos   := CameraPath(gTime + 0);
  camTar      := CameraPath(gTime + 0.009);
  cameraPos.y := cameraPos.y + (Terrain(CameraPath(gTime + 0.009).xz).x);
  camTar.y    := cameraPos.y;

  roll   := 0.4 * system.sin(gTime + 0.5);
  cw     := normalize(camTar - cameraPos);
  cp     := vec3.Create(system.sin(roll), system.cos(roll), 0);
  cu     := cross(cw, cp);
  cv     := cross(cu, cw);
  dir    := normalize(uv.x * cu + uv.y * cv + 1.3 * cw);
  camMat := mat3.Create(cu, cv, cw);

{$IFDEF STEREO}
  cameraPos := cameraPos + (0.85 * cu * isCyan);
{$ENDIF }
  if not Scene(cameraPos, dir, distance, &type) then
  begin
    // Missed scene, now just get the sky...
    col := GetSky(dir);
  end
  else
  begin
    // Get world coordinate of landscape...
    pos := cameraPos + distance * dir;
    // Get normal from sampling the high definition height map
    // Use the distance to sample larger gaps to help stop aliasing...
    p   := vec2_12;
    nor := vec3.Create(0, Terrain(pos.xz).x, 0);
    v2  := nor - vec3.Create(p.x, Terrain(pos.xz + p).x, 0);
    v3  := nor - vec3.Create(0, Terrain(pos.xz - p.yx).x, -p.x);
    nor := cross(v2, v3);
    nor := normalize(nor);

    // Get the colour using all available data...
    col := TerrainColour(pos, dir, nor, distance, &type);
  end;

  // bri is the brightness of sun at the centre of the camera direction.
  // Yeah, the lens flares is not exactly subtle, but it was good fun making it.
  bri := dot(cw, sunLight) * 0.75;
  if bri > 0 then
  begin
    // Rotate the sun to 2D, but backwards...
    sunPos := (-camMat * sunLight).xy;

    bri := pow(bri, 7) * 0.8;

    // glare = the red shifted blob...
    glare := Math.max(dot(normalize(vec3.Create(dir.x, dir.y + 0.3, dir.z)), sunLight), 0) * 1.4;

    // glare2 is the cyan ring...
    glare2 := Math.max(system.sin(smoothstep(0.4, 0.7, length(sunPos - uv * 0.5)) * PI), 0);

    // glare3 is the yellow dot...
    glare3 := Math.max(1 - length(sunPos - uv * 2.1), 0);

    // glare4 is the small white circle past centre point...
    glare4 := Math.max(system.sin(smoothstep(-0.05, 0.4, length(sunPos + uv * 2.5)) * PI), 0);

    col := col + (bri * vec3_13 * pow(glare, 12.5) * 0.07)
               + (bri * vec3_14 * pow(glare2, 3))
               + (bri * vec3_15 * pow(glare3, 3) * 4)
               + (bri * vec3_16 * pow(glare4, 33.9) * 0.7);
    // col  := //col  + (bri * pow(bri, 2.0)*30.0);
  end;

  col := PostEffects(col, xy);

{$IFDEF STEREO	}
  col := col * (vec3.Create(isCyan, 1 - isCyan, 1 - isCyan));
{$ENDIF }
  Result := TColor32(col);
end;

initialization

RollingHills := TRollingHills.Create;
Shaders.Add('RollingHills', RollingHills);

finalization

FreeandNil(RollingHills);

end.
