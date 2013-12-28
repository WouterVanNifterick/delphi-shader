unit WvN.DelphiShader.FX.Portal;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

// https://www.shadertoy.com/view/lsSGRz

// Comment to turn off for faster rendering not
{$DEFINE SHADOWS}
{$DEFINE GLOW}
{$DEFINE SPECULAR}

type
  TPortal = class(TShader)
  public const
    // Increase for bigger glow effect (which also gets a little bugged...) not
    GLOW_AMOUNT = 4.0;

    // Reduce for accuracy-performance trade-off not
    RAYMARCH_ITERATIONS = {40}20;
    SHADOW_ITERATIONS   = {60}15;

    // Increase for accuracy-performance trade-off not
    SHADOW_STEP = 2.0;

    vec3_1: vec3  = (x: 24; y: 22; z: 4);
    vec3_2: vec3  = (x: 4; y: 4; z: 11);
    vec3_3: vec3  = (x: 6; y: -35; z: 4);
    vec3_4: vec3  = (x: 4; y: 4; z: 15);
    vec3_5: vec3  = (x: 19; y: -15; z: 0);
    vec3_6: vec3  = (x: 7; y: 7; z: 7);
    vec3_7: vec3  = (x: -12; y: 20; z: 12);
    vec3_8: vec3  = (x: 4; y: 12; z: 9);
    vec3_9: vec3  = (x: 15; y: 35; z: 6);
    vec3_10: vec3 = (x: 15; y: 3; z: 5);
    vec3_11: vec3 = (x: -10; y: 35; z: 10);
    vec3_12: vec3 = (x: 12; y: 6; z: 15);
    vec3_13: vec3 = (x: 15; y: -35; z: 6);
    vec2_14: vec2 = (x: 12; y: 1);
    vec3_15: vec3 = (x: 24; y: 22; z: 4);
    vec3_16: vec3 = (x: 4; y: 4; z: 11);
    vec3_17: vec3 = (x: 6; y: -35; z: 4);
    vec3_18: vec3 = (x: 4; y: 4; z: 15);
    vec3_19: vec3 = (x: 19; y: -15; z: 0);
    vec3_20: vec3 = (x: 7; y: 7; z: 7);
    vec3_21: vec3 = (x: -12; y: 20; z: 12);
    vec3_22: vec3 = (x: 4; y: 12; z: 9);
    vec3_23: vec3 = (x: 15; y: 35; z: 6);
    vec3_24: vec3 = (x: 15; y: 3; z: 5);
    vec3_25: vec3 = (x: -10; y: 35; z: 10);
    vec3_26: vec3 = (x: 12; y: 6; z: 15);
    vec3_27: vec3 = (x: 15; y: -35; z: 6);
    vec3_28: vec3 = (x: 0; y: 0; z: -4);
    vec4_29: vec4 = (x: 0; y: 0; z: 0; w: 1);
    vec4_30: vec4 = (x: 1; y: 0.3; z: 0.6; w: 1);
    vec4_31: vec4 = (x: 1; y: 0.1; z: 0.2; w: 1);
    vec4_32: vec4 = (x: 0.5; y: 0.5; z: 1; w: 1);
    vec4_33: vec4 = (x: 0.1; y: 0.2; z: 1; w: 1);
    vec4_34: vec4 = (x: 1; y: 1; z: 1; w: 1);
    vec4_35: vec4 = (x: 1; y: 0.3; z: 0.6; w: 1);
    vec4_36: vec4 = (x: 1; y: 0.1; z: 0.2; w: 1);
    vec4_37: vec4 = (x: 0.4; y: 0.6; z: 1; w: 1);
    vec4_38: vec4 = (x: 0.1; y: 0.4; z: 1; w: 1);
    vec4_39: vec4 = (x: 1; y: 1; z: 1; w: 1);
    vec4_40: vec4 = (x: 1; y: 1; z: 1; w: 1);
  var
    res: double;
    mo   : vec2;
    dist : float;
    ta   : vec3;
    ro   : vec3;
    cw   : vec3;
    cp   : vec3;
    cu   : vec3;
    cv   : vec3;


    procedure fUnionMat(var curDist, curMat: float; dist: float; const mat: float);
    procedure fUnionMat2(var curDist: float; dist: float; const mat: float);
    function fSubtraction(a, b: float): float;
    function fIntersection(d1, d2: float): float;
    function fUnion(d1, d2: float): float;
    function pSphere(const p: vec3; s: float): float;
    function pRoundBox(const p, b: vec3; r: float): float;
    function pTorus(const p: vec3; const t: vec2): float;
    function distf(world: int; const p: vec3; var m: float): float;
    function distf2(world: int; const p: vec3; var m: float): float;
    function distf3(world: int; const p: vec3): float;
    function normalFunction(world: int; const p: vec3): vec3;
    function raymarch(world: float; const from, increment: vec3): vec4;
    function shadow(world: float; const from, increment: vec3): float;
    function getPixel(world: float; const from, &to, increment: vec3): vec4;
    function Main(var gl_FragCoord: vec2): TColor32;

    constructor Create; override;
    procedure PrepareFrame;
  end;

var
  Portal: TShader;

implementation

uses SysUtils, Math;

constructor TPortal.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;


procedure TPortal.fUnionMat(var curDist, curMat: float; dist: float; const mat: float);
begin
  if dist < curDist then
  begin
    curMat  := mat;
    curDist := dist;
  end;
end;

procedure TPortal.fUnionMat2(var curDist: float; dist: float; const mat: float);
begin
  if dist < curDist then
    curDist := dist;
end;

function TPortal.fSubtraction(a, b: float): float;
begin
  Result := Math.max(-a, b);
end;

function TPortal.fIntersection(d1, d2: float): float;
begin
  Result := Math.max(d1, d2);
end;

function TPortal.fUnion(d1, d2: float): float;
begin
  Result := Math.min(d1, d2);
end;

function TPortal.pSphere(const p: vec3; s: float): float;
begin
  Exit(length(p) - s);
end;

function TPortal.pRoundBox(const p, b: vec3; r: float): float;
begin
  Exit(length(max(abs(p) - b, 0)) - r);
end;

function TPortal.pTorus(const p: vec3; const t: vec2): float;
var
  q: vec2;

begin
  q := vec2.Create(length(p.xz) - t.x, p.y);
  Exit(length(q) - t.y);
end;

function TPortal.distf(world: int; const p: vec3; var m: float): float;
var
  d     : float;
  Portal: float;

begin
  d := 0;
  m := 0;

  if world = 0 then
  begin
    d := 16 + p.z;
    m := 1;

    fUnionMat(d, m, pSphere(vec3_1 + p, 12), 4);
    fUnionMat(d, m, pRoundBox(vec3_3 + p, vec3_2, 1), 4);
    fUnionMat(d, m, pRoundBox(vec3_5 + p, vec3_4, 1), 4);
    fUnionMat(d, m, pRoundBox(vec3_7 + p, vec3_6, 1), 4);
  end
  else
  begin
    d := 16 + p.z;
    m := 2;

    fUnionMat(d, m, pRoundBox(vec3_9 + p, vec3_8, 1), 5);
    fUnionMat(d, m, pRoundBox(vec3_11 + p, vec3_10, 1), 5);
    fUnionMat(d, m, pRoundBox(vec3_13 + p, vec3_12, 1), 5);
  end;

  Portal := pTorus(p, vec2_14);
  fUnionMat(d, m, Portal, 3);
  Result := d;
end;

function TPortal.distf2(world: int; const p: vec3; var m: float): float;
var
  d: float;
begin
  d := 0;
  m := 0;

  if world = 0 then
  begin
    d := 16 + p.z;
    m := 1;

    fUnionMat(d, m, pSphere(vec3_15 + p, 12), 4);
    fUnionMat(d, m, pRoundBox(vec3_17 + p, vec3_16, 1), 4);
    fUnionMat(d, m, pRoundBox(vec3_19 + p, vec3_18, 1), 4);
    fUnionMat(d, m, pRoundBox(vec3_21 + p, vec3_20, 1), 4);
  end
  else
  begin
    d := 16 + p.z;
    m := 2;

    fUnionMat(d, m, pRoundBox(vec3_23 + p, vec3_22, 1), 5);
    fUnionMat(d, m, pRoundBox(vec3_25 + p, vec3_24, 1), 5);
    fUnionMat(d, m, pRoundBox(vec3_27 + p, vec3_26, 1), 5);
  end;

  Result := d;
end;

function TPortal.distf3(world: int; const p: vec3): float;
var
  d: float;
begin
  d := 0;

  if world = 0 then
  begin
    d := 16 + p.z;
    fUnionMat2(d, pSphere(vec3_15 + p, 12), 4);
    fUnionMat2(d, pRoundBox(vec3_17 + p, vec3_16, 1), 4);
    fUnionMat2(d, pRoundBox(vec3_19 + p, vec3_18, 1), 4);
    fUnionMat2(d, pRoundBox(vec3_21 + p, vec3_20, 1), 4);
  end
  else
  begin
    d := 16 + p.z;
    fUnionMat2(d, pRoundBox(vec3_23 + p, vec3_22, 1), 5);
    fUnionMat2(d, pRoundBox(vec3_25 + p, vec3_24, 1), 5);
    fUnionMat2(d, pRoundBox(vec3_27 + p, vec3_26, 1), 5);
  end;
  Exit(d);
end;

function TPortal.normalFunction(world: int; const p: vec3): vec3;
var
  eps: float;
  m  : float;
begin
  eps := 0.01;

  Result.x := distf(world, vec3.Create(p.x - eps, p.y, p.z), m) - distf(world, vec3.Create(p.x + eps, p.y, p.z), m);
  Result.y := distf(world, vec3.Create(p.x, p.y - eps, p.z), m) - distf(world, vec3.Create(p.x, p.y + eps, p.z), m);
  Result.z := distf(world, vec3.Create(p.x, p.y, p.z - eps), m) - distf(world, vec3.Create(p.x, p.y, p.z + eps), m);
  Result.NormalizeSelf;
end;

function TPortal.raymarch(world: float; const from, increment: vec3): vec4;
var
  dist    : float;
  material: float;
  glow    : float;
  i       : integer;
  pos     : vec3;
  distEval: float;
const
  maxDist = 200;
  minDist = 0.1;
  maxIter = RAYMARCH_ITERATIONS;
begin
  dist     := 0;
  material := 0;
  glow     := 1000;

  for i := 0 to maxIter - 1 do
  begin
    pos      := (from + increment * dist);
    distEval := distf(trunc(world), pos, material);

    if distEval < minDist then
      break;

{$IFDEF GLOW}
    if material = 3 then
      glow := Math.min(glow, distEval);

{$ENDIF }
    if    (length(pos.xz) < 12)
      and (pos.y > 0)
      and ((from + increment * (dist + distEval)).y <= 0) then
    begin
      if world = 0 then
        world := 1
      else
        world := 0;
    end;
    dist := dist + distEval;
  end;

  if dist >= maxDist then
    material := 0;

  Exit(vec4.Create(dist, material, world, glow));
end;

function TPortal.shadow(world: float; const from, increment: vec3): float;
var
  minDist: float;
  res    : float;
  t      : float;
  i      : integer;
  h      : float;
begin
  minDist := 1;

  res   := 1;
  t     := 1;
  for i := 0 to SHADOW_ITERATIONS - 1 do
  begin

    h := distf3(trunc(world), from + increment * t);
    if h < minDist then
      Exit(0);

    res := min(res, 4 * h / t);
    t   := t + SHADOW_STEP;
  end;

  Exit(res);
end;

function TPortal.getPixel(world: float; const from, &to, increment: vec3): vec4;
var
  c                       : vec4;
  hitPos, normal, lightPos: vec3;
  shade, diffuse          : float;
  specular                : float;
  m                       : vec4;
begin
  c := raymarch(world, from, increment);

  hitPos   := from + increment * c.x;
  normal   := normalFunction(trunc(c.z), hitPos);
  lightPos := -normalize(hitPos + vec3_28);

  diffuse := Math.max(0, dot(normal, -lightPos)) * 0.5 + 0.5;
  shade   :=
{$IFDEF SHADOWS}
    shadow(c.z, hitPos, lightPos) * 0.5 + 0.5;
{$ELSE}
    1;
{$ENDIF}
  specular := 0;
{$IFDEF SPECULAR}
  if dot(normal, -lightPos) < 0 then
    specular := 0
  else
    specular := pow(Math.max(0, dot(reflect(-lightPos, normal), normalize(from - hitPos))), 5);
{$ENDIF }
  case trunc(c.y) of
    1: m := mix(vec4_31, vec4_30, sin(hitPos.x) * sin(hitPos.y)) * clamp((100 - length(hitPos.xy)) / 100, 0, 1);
    2: m := mix(vec4_33, vec4_32, sin(hitPos.x)) * clamp((100 - length(hitPos.xy)) / 100, 0, 1);
    3: m := vec4_34;
    4: m := ifthen(fract(hitPos.x / 3) < 0.5, vec4_36, vec4_35);
    5: m := ifthen(fract(hitPos.x / 3) < 0.5, vec4_38, vec4_37);
  else
    m := vec4_29;
  end;

  Result := mix(vec4_40, (m * diffuse + vec4_39 * specular) * shade, clamp(c.w / GLOW_AMOUNT, 0, 1));

end;

procedure TPortal.PrepareFrame;
begin
  res := (-resolution.x / resolution.y);
  mo  := iMouse.xy / resolution.xy;
  // camera
  dist := 50;
  ta := vec3.Create(system.cos(iGlobalTime / 2) * 8, system.sin(iGlobalTime / 2 + 2) * 12, 4);
  ro := vec3.Create(50 + system.cos(iGlobalTime / 2) * dist, system.sin(iGlobalTime / 2) * dist * 1.5, 4);

  // camera tx
  cw := normalize(ta - ro);
  cp := vec3.Create(0, 0, 1);
  cu := normalize(cross(cw, cp));
  cv := normalize(cross(cu, cw));
end;

function TPortal.Main(var gl_FragCoord: vec2): TColor32;
var
  q    : vec2;
  p    : vec2;
  rd   : vec3;
  world: float;

begin
  // Camera
  q   := gl_FragCoord.xy / resolution.xy;
  p   := -1 + 2 * q;
  p.x := p.x * res;
  rd := normalize(p.x * cu + p.y * cv + 2.5 * cw);

  if system.cos(-iGlobalTime / 4) > 0 then
    world := 0
  else
    world := 1;

  Result := TColor32(getPixel(world, ro, ta, rd));
end;

initialization

Portal := TPortal.Create;
Shaders.Add('Portal', Portal);

finalization

FreeandNil(Portal);

end.
