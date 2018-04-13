unit WvN.DelphiShader.FX.EscherDepth;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

// http://glsl.heroku.com/e#3111.5
// inspired by Escher's "Depth", still needs some work not
// https://www.google.co.uk/search?q=escher+depth
// simon green 26/01/2011

{$define USE_TEXTURE}
{$EXCESSPRECISION OFF}
type
  TEscherDepth = class(TShader)
  public const
    vec3_1: vec3  = (x: 1.5; y: 1.5; z: 1.5);
    vec3_2: vec3  = (x: 1.5; y: 1.5; z: 1.5);
    vec3_3: vec3  = (x: 4; y: 4; z: 1);
    vec3_4: vec3  = (x: 0.2; y: 0.01; z: 0.2);
    vec3_5: vec3  = (x: 0; y: 0; z: 1);
    vec3_6: vec3  = (x: 0; y: 0; z: 0.95);
    vec3_7: vec3  = (x: 1; y: 10; z: 1);
    vec3_8: vec3  = (x: 0.08; y: 0.08; z: 0.85);
    vec3_9: vec3  = (x: - 0.08; y: 0.08; z: 0.85);
    vec3_10: vec3 = (x: 0.08; y: 0.1; z: 0.88);
    vec3_11: vec3 = (x: - 0.08; y: 0.1; z: 0.88);
    vec3_12: vec3 = (x: 1.2; y: 0.02; z: 0.2);
    vec3_13: vec3 = (x: 0.02; y: 1.2; z: 0.2);
    vec3_14: vec3 = (x: 0; y: 0; z: - 1.8);
    vec3_15: vec3 = (x: 0.02; y: 0.25; z: 0.25);
    vec3_16: vec3 = (x: 0; y: 0; z: 1);
    vec3_17: vec3 = (x: 0; y: 0; z: 1.25);
    vec3_18: vec3 = (x: 4; y: 10; z: 4);
    vec3_19: vec3 = (x: 0.643; y: 0.776; z: 0.223);
    vec3_20: vec3 = (x: 1.0; y: 0.3; z: 0.0);
    vec3_21: vec3 = (x: 1; y: 0.3; z: 0);
    vec3_22: vec3 = (x: 0.9; y: 0.25; z: 0);
    vec3_23: vec3 = (x: 0.0; y: 0.0; z: 0.0);
    BGColor1: vec3 = (x: 0; y: 0; z: 0);
    BGColor2: vec3 = (x: 0; y: 0; z: 0);
    vec3_25: vec3 = (x: 0.0; y: 0.0; z: 0.0);
    vec3_26: vec3 = (x: 0; y: 0; z: 4);
    vec3_27: vec3 = (x: 1; y: 0.9; z: 0.7);

  var
    crx,cry,
    srx,sry,
    rx, ry: float;
    ro    : vec3;
    asp   : float;

    function _union(a, b: float): float; inline;
    function intersect(a, b: float): float; inline;
    function difference(a, b: float): float; inline;
    function plane(const p, planeN, planePos: vec3): float; overload; inline;
    function plane(const p, n: vec3; d: float): float; overload; inline;
    function box(const p, b: vec3): float;
    function sphere(const p: vec3; r: float): float; inline;
    function rotateX(const p: vec3; a: float): vec3;    overload;
    function rotateY(const p: vec3; a: float): vec3;    overload;
    function rotateX(const p: vec3; sa,ca: float): vec3;    overload;
    function rotateY(const p: vec3; sa,ca: float): vec3;    overload;


    function scene(const ap: vec3): float;
    function sceneNormal(const pos: vec3): vec3;
    function ambientOcclusion(const p, n: vec3): float;
    function pulse(a, b, w, x: float): float;
    function shade(const pos, n, eyePos: vec3): vec3;
    function trace(const ro, rd: vec3; out hit: bool): vec3;
    function background(const rd: vec3): vec3;
    function Main(var gl_FragCoord: Vec2): TColor32;

    procedure PrepareFrame;
    constructor Create; override;
  end;

var
  EscherDepth: TShader;

implementation

uses SysUtils, Math;

{ CSG operations }

function TEscherDepth._union(a, b: float): float;
begin
  if a < b then
    Result := a
  else
    Result := b;
end;

function TEscherDepth.intersect(a, b: float): float;
begin
  if a > b then
    Result := a
  else
    Result := b;
end;

function TEscherDepth.difference(a, b: float): float;
begin
  b := -b;
  if a > b then
    Result := a
  else
    Result := b;
end;


// primitive functions
// these all return the distance to the surface from a given point

function TEscherDepth.plane(const p, planeN, planePos: vec3): float;
begin
  Result := dot(p - planePos, planeN);
end;

function TEscherDepth.plane(const p, n: vec3; d: float): float;
begin
  Result := dot(p, n) - d;
end;

function TEscherDepth.box(const p, b: vec3): float;
var
  di: vec3;
  mc: float;
begin
  di     := abs(p) - b;
  mc     := Math.max(di.x, Math.max(di.y, di.z));
  Result := Math.min(mc, length(max(di, 0)));
end;

function TEscherDepth.sphere(const p: vec3; r: float): float;
begin
  Result := length(p) - r;
end;

// transforms
function TEscherDepth.rotateX(const p: vec3; a: float): vec3;
var
  sa, ca: float;
begin
  sa       := system.sin(a);
  ca       := system.cos(a);
  Result.x := p.x;
  Result.y := ca * p.y - sa * p.z;
  Result.z := sa * p.y + ca * p.z;
end;

function TEscherDepth.rotateX(const p: vec3; sa,ca: float): vec3;
begin
  Result.x := p.x;
  Result.y := ca * p.y - sa * p.z;
  Result.z := sa * p.y + ca * p.z;
end;

function TEscherDepth.rotateY(const p: vec3; a: float): vec3;
var
  sa, ca: float;
begin
  sa := system.sin(a);
  ca := system.cos(a);

  Result.x := ca * p.x + sa * p.z;
  Result.y := p.y;
  Result.z := -sa * p.x + ca * p.z;
end;

function TEscherDepth.rotateY(const p: vec3; sa, ca: float): vec3;
begin
  Result.x := ca * p.x + sa * p.z;
  Result.y := p.y;
  Result.z := -sa * p.x + ca * p.z;
end;

// distance to scene
function TEscherDepth.scene(const ap: vec3): float;
var
  d, f: float;
  p   : vec3;
begin
  // d := 1E10;

  p := ap + vec3_1;
  p := &mod(p, 3);
  p := p - vec3_2;

  // body
  // d  := sphere(p, 1.0);
  d := sphere(p * vec3_3, 1) * 0.25;

  // mouth
  d := difference(d, box(p - vec3_5, vec3_4));
  // d  := difference(d, sphere(p*vec3_7 - vec3_6, 0.15)*0.1);

  // eyes
  d := _union(d, sphere(p - vec3_8, 0.06));
  d := _union(d, sphere(p - vec3_9, 0.06));

  d := _union(d, sphere(p - vec3_10, 0.04));
  d := _union(d, sphere(p - vec3_11, 0.04));

  // fins
  f := box(p, vec3_12);
  f := _union(f, box(p, vec3_13));
  f := intersect(f, sphere(p - vec3_14, 2));
  d := _union(f, d);

  // tail
  d := _union(d, box(p + vec3_16, vec3_15));
  d := difference(d, sphere(p + vec3_17, 0.25));

  Result := d;
end;

// calculate scene normal
function TEscherDepth.sceneNormal(const pos: vec3): vec3;
const
  eps = 0.0001;
var
  n: vec3;
begin
  n.x    := scene(vec3.Create(pos.x + eps, pos.y      , pos.z      )) -
            scene(vec3.Create(pos.x - eps, pos.y      , pos.z      ));
  n.y    := scene(vec3.Create(pos.x      , pos.y + eps, pos.z      )) -
            scene(vec3.Create(pos.x      , pos.y - eps, pos.z      ));
  n.z    := scene(vec3.Create(pos.x      , pos.y      , pos.z + eps)) -
            scene(vec3.Create(pos.x      , pos.y      , pos.z - eps));
  Result := n;
  Result.NormalizeSelf;
end;

// ambient occlusion approximation
function TEscherDepth.ambientOcclusion(const p, n: vec3): float;
var
  steps : int;
  delta : float;
  a     : float;
  weight: float;
  i     : integer;
  d     : float;
begin
  steps := 3;
  delta := 0.5;

  a      := 0;
  weight := 1;
  for i  := 1 to steps do
  begin
    d      := (i / steps) * delta;
    a      := a + (weight * (d - scene(p + n * d)));
    weight := weight * (0.5);
  end;

  Result := clamp(1 - a, 0, 1);
end;

// smooth pulse
function TEscherDepth.pulse(a, b, w, x: float): float;
begin
  Exit(smoothstep(a, a + w, x) - smoothstep(b - w, b, x));
end;

// lighting
function TEscherDepth.shade(const pos, n, eyePos: vec3): vec3;
var
  lightPos : vec3;
  color    : vec3;
  shininess: float;
  l        : vec3;
  v        : vec3;
  h        : vec3;
  ndotl    : float;
  spec     : float;
  diff     : float;
  fresnel  : float;
  ao       : float;
  sx       : float;
  w        : float;
  sz       : float;

begin
  lightPos := vec3_18;
  // color   := vec3_19;
  // color   := vec3_20;
  shininess := 100;

  l     := normalize(lightPos - pos);
  v     := normalize(eyePos - pos);
  h     := normalize(v + l);
  ndotl := dot(n, l);
  spec  := Math.max(0, pow(dot(n, h), shininess)) * ifthen(ndotl > 0, 0, 1);
  // diff  := max(0.0, ndotl);
  diff := 0.5 + 0.5 * ndotl;

  fresnel := pow(1 - dot(n, v), 5);
  ao      := ambientOcclusion(pos, n);

{$IFDEF USE_TEXTURE}
  // stripes
  sx := pulse(0, 0.5, 0.1, fract( { pos.t } pos.y * 15));
  //a  := arctan2(pos.y, pos.x) / 3.1415;
  // a  := //a  - (0.1);
  //sx := pulse(0.0, 0.5, 0.1, frac(a * 8.0));

  w  := 0.5;
  //w  := 1.1 - diff;
  //w  := smoothstep(0.25, -0.25, pos.y);
  //w  := 1.0 - (pos.y + 0.25) * 2.0;
  sz := pulse(0, w, 0.1, fract(pos.z * 20)) * (ifthen((w > 0.1), 1, 0));

  color := mix(vec3White, vec3_21, sx) * vec3(1 - sz);
{$ELSE }
  color := vec3_22;
{$ENDIF }
  Exit(vec3(diff * ao) * color + vec3(spec + fresnel * 0.5));
  // return vec3(diff*ao) * color + vec3(spec);
  // return vec3(diff) * color + vec3(spec);
  // return vec3(diff);
  // return vec3(ao);
  // return vec3(fresnel);
end;

// trace ray using sphere tracing
function TEscherDepth.trace(const ro, rd: vec3; out hit: bool): vec3;
var
  maxSteps    : int;
  hitThreshold: float;
  pos         : vec3;
  i           : integer;
  d           : float;

begin
  maxSteps     := 128;
  hitThreshold := 0.001;
  hit          := false;
  pos          := ro;

  for i := 0 to maxSteps - 1 do
  begin
    d := scene(pos);
    if d < hitThreshold then
    begin
      hit := true;
      Exit(pos);
      // return pos;
    end;

    pos := pos + (d * rd);
  end;

  Exit(pos);
end;

function TEscherDepth.background(const rd: vec3): vec3;
begin
  // return mix(Vec3.Create(1.0),vec3_23,rd.y);
  //Exit(mix(BGColor1, BGColor2, abs(rd.y)));
  // return vec3_25;
end;

constructor TEscherDepth.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;

procedure TEscherDepth.PrepareFrame;
begin
  asp := resolution.x / resolution.y;

  rx := -0.4;
  ry := &mod(time * 0.1,2000);

  srx := sinLarge(rx);
  sry := sinLarge(ry);
  crx := cosLarge(rx);
  cry := cosLarge(ry);

  ro := vec3_26;
  ro := rotateX(ro, srx,crx);
  ro := rotateY(ro, sry,cry);
end;

function TEscherDepth.Main(var gl_FragCoord: Vec2): TColor32;
var
  pixel: Vec2;
  rd   : vec3;
  hit  : bool;
  pos  : vec3;
  rgb  : vec3;
  n    : vec3;
  d    : float;
  f    : float;
begin
  pixel := -1 + 2 * gl_FragCoord.xy / resolution.xy;

  // compute ray origin and direction
  rd := normalize(vec3.Create(asp * pixel.x, pixel.y, -3));
  rd := rotateX(rd, srx,crx);
  rd := rotateY(rd, sry,cry);

  // trace ray
  pos := trace(ro, rd, hit);

  if hit then
  begin
    // calc normal
    n := sceneNormal(pos);
    // shade
    rgb := shade(pos, n, ro);
  end
  else
    rgb := {background(rd)}BGColor1;

  // fog
  d := length(pos) * 0.07;
  f := system.exp(-d * d);

  // vignetting
  rgb := rgb * (0.5 + 0.5 * smoothstep(2, 0.5, dot(pixel, pixel)));

  // Result=vec4(rgb, 1.0);
  Result := TColor32(mix(vec3_27, rgb, f));
end;

initialization

EscherDepth := TEscherDepth.Create;
Shaders.Add('EscherDepth', EscherDepth);

finalization

FreeandNil(EscherDepth);

end.
