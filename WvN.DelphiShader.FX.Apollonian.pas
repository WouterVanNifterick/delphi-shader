unit WvN.DelphiShader.FX.Apollonian;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

// https://www.shadertoy.com/view/4ds3zn

// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
//
// I can't recall where I learnt about this fractal.
//
// Coloring and fake occlusions are done by orbit trapping, as usual (unless somebody has invented
// something new in the last 4 years that i'm unaware of, that is)

type

  TApollonian = class(TShader)
  public const
    maxd   = 100;
    precis = 0.001;
    precis2 = precis * 2;
    iterations = 199;
    vec1000: Vec4 = (x: 1000; y: 1000; z: 1000; w: 1000);
    vec3_1: Vec3  = (x: 1; y: 1; z: 1);
    vec3_2: Vec3  = (x: 0.4; y: 0.4; z: 0.4);
    vec3_3: Vec3  = (x: 1; y: 0.80; z: 0.2);
    vec3_4: Vec3  = (x: 1; y: 0.55; z: 0);

    Vec3_1Xyy:vec3 = (x:0.001; y:0; z:0);
    Vec3_1yXy:vec3 = (x:0; y:0.001; z:0);
    Vec3_1yyX:vec3 = (x:0; y:0; z:0.001);


  var
    time  : float;
    orb   : Vec4;
    ss    : float;
    ro    : Vec3;
    ta    : Vec3;
    light1: Vec3;
    light2: Vec3;
    roll  : float;
    cw    : Vec3;
    cp    : Vec3;
    cu    : Vec3;
    cv    : Vec3;

    constructor Create; override;
    procedure PrepareFrame;
    function RenderPixel(var gl_FragCoord: Vec2): TColor32;

    function map(p: Vec3): float;
    function trace(const ro, rd: Vec3): float;
    function calcNormal(const pos: Vec3): Vec3;
  end;

var
  Apollonian: TShader;

implementation

uses SysUtils, Math;

function TApollonian.map(p: Vec3): float;
var
  i           : Integer;
  r2, scale, k: float;
begin
  scale := 1;
  orb := vec1000;
  for i := 0 to 7 do
  begin
    p     := -1 + 2 * fract(0.5 * p + 0.5);
    r2    := dot(p, p);
    orb   := min(orb, Vec4.Create(abs(p), r2));
    k     := max(ss / r2, 0.1);
    p     := p * k;
    scale := scale * k;
  end;
  Result := 0.25 * System.abs(p.y) / scale;
end;

function TApollonian.trace(const ro, rd: Vec3): float;
var
  h, t: float;
  i                 : Integer;
begin
  h      := precis2;
  t      := 0;
  for i  := 0 to Iterations do
  begin
    if (System.abs(h) < precis) or (t > maxd) then
      break;
    t := t + h;
    h := map(ro + rd * t);
  end;

  if t > maxd then
    t    := -1.0;
  Result := t;
end;

function TApollonian.calcNormal(const pos: Vec3): Vec3;
begin
  Result.x  := map(pos + Vec3_1Xyy) - map(pos - Vec3_1Xyy );
  Result.y  := map(pos + Vec3_1yXy) - map(pos - Vec3_1yXy );
  Result.z  := map(pos + Vec3_1yyX) - map(pos - Vec3_1yyX );
  Result.NormalizeSelf;
end;

constructor TApollonian.Create;
begin
  inherited;
  Image.FrameProc := PrepareFrame;
  Image.PixelProc := RenderPixel;

  light1 := Vec3.Create(0.577, 0.577, -0.577);
  light2 := Vec3.Create(-0.707, 0.000, 0.707);

end;

procedure TApollonian.PrepareFrame;
begin

  time := iGlobalTime * 0.25 + 0.01 * iMouse.x;
  ss   := 1.1 + 0.5 * smoothstep(-0.3, 0.3, system.cos(0.1 * iGlobalTime));

  // camera
  ro := Vec3.Create(2.8 * cosLarge(0.1 + 0.33 * time), 0.4 + 0.30 * cosLarge(0.37 * time), 2.8 * cosLarge(0.5 + 0.35 * time));

  ta   := Vec3.Create(1.9 * cosLarge(1.2 + 0.41 * time), 0.4 + 0.10 * cosLarge(0.27 * time), 1.9 * cosLarge(2.0 + 0.38 * time));
  roll := 0.2 * cosLarge(0.1 * time);
  cw   := normalize(ta - ro);
  cp   := Vec3.Create(
            system.sin(roll),
            system.cos(roll),
            0.0);
  cu   := normalize(cross(cw, cp));
  cv   := normalize(cross(cu, cw));
end;

function TApollonian.RenderPixel(var gl_FragCoord: Vec2): TColor32;
var
  rd : Vec3;
  col: Vec3;
  p  : Vec2;
  t  : float;

  tra: Vec4;
  pos: Vec3;
  nor: Vec3;

  key: float;
  bac: float;
  amb: float;
  ao : float;

  brdf: Vec3;
  rgb : Vec3;

begin
  p   := -1.0 + 2.0 * gl_FragCoord.xy / Resolution.xy;
  p.x := p.x * (Resolution.x / Resolution.y);
  rd := normalize(p.x * cu + p.y * cv + 2.0 * cw);

  // trace
  col := Vec3Black;
  t   := trace(ro, rd);
  if (t > 0) then
  begin
    tra := orb;
    pos := ro + t * rd;
    nor := calcNormal(pos);

    // lighting
    key := clamp(dot(light1, nor));
    bac := clamp(0.2 + 0.8 * dot(light2, nor));
    amb := (0.7 + 0.3 * nor.y);
    ao  := pow(clamp(tra.w * 2.0), 1.2);

    brdf := vec3_2 * amb * ao;
    brdf := brdf + (vec3_1 * key * ao);
    brdf := brdf + (vec3_2 * bac * ao);

    // material
    rgb := vec3White;
    rgb := mix(rgb, vec3_3, clamp(16 * tra.y));
    rgb := mix(rgb, vec3_4, pow(clamp(1 - 2 * tra.z), 8));

    // color
    col := rgb * brdf * exp(-0.2 * t);
  end;

  col    := sqrt(col);
  col    := mix(col, smoothstep(0, 1, col), 0.25);
  Result := TColor32(col);
end;

initialization

Apollonian := TApollonian.Create;
Shaders.Add('Apollonian', Apollonian);

finalization

FreeandNil(Apollonian);

end.
