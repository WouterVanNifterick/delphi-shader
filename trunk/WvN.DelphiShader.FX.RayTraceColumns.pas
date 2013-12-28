unit WvN.DelphiShader.FX.RayTraceColumns;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TRayTraceColumns = class(TShader)
  const
    vec4_1: vec4  = (x: 0; y: - 2; z: 15; w: 1.5);
    vec4_2: vec4  = (x: -8; y: 0; z: 20; w: 2);
    vec4_3: vec4  = (x: -5; y: 4; z: 15; w: 0.5);
    vec4_4: vec4  = (x: -1; y: 3; z: 15; w: 2);
    vec4_5: vec4  = (x: 2; y: - 3; z: 15; w: 0.5);
    vec4_6: vec4  = (x: 10; y: 0; z: 20; w: 1);
    vec4_7: vec4  = (x: 4; y: 0; z: 15; w: 1);
    vec4_8: vec4  = (x: 0; y: 0; z: 20; w: 1);
    vec4_9: vec4  = (x: - 2; y: 0; z: 25; w: 1);
    vec4_10: vec4 = (x: - 6; y: 0; z: 30; w: 1);
    vec4_11: vec4 = (x: - 12; y: 0; z: 35; w: 2);
    vec3_12: vec3 = (x: 0; y: 0; z: 0);
    vec4_13: vec4 = (x: 0; y: 0; z: 0; w: 1);
    vec3_14: vec3 = (x: 0; y: 0; z: 0);
    vec3_15: vec3 = (x: - 4; y: 0; z: 4);
    vec3_16: vec3 = (x: 2; y: 0; z: 8);
    vec3_17: vec3 = (x: 4; y: - 2; z: 24);
    vec3_18: vec3 = (x: 1; y: 0.5; z: 0.4);
    vec3_19: vec3 = (x: 0.4; y: 0.5; z: 1);
    vec3_20: vec3 = (x: 0.2; y: 1; z: 0.5);

  var
    lp: array [0 .. 2] of vec3;
    lc: array [0 .. 2] of vec3;
    res: double;

    function flr(const p: vec3; f: float): float;
    function sph(const p: vec3; const spr: vec4): float;
    function cly(const p: vec3; const cld: vec4): float;
    function scene(const p: vec3): float;
    function getN(const p: vec3): vec3;
    function AO(const p, n: vec3): float;
    function Main(var gl_FragCoord: Vec2): TColor32;

    constructor Create; override;
    procedure PrepareFrame;
  end;

var
  RayTraceColumns: TShader;

implementation

uses SysUtils, Math;

constructor TRayTraceColumns.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;

  lp[0] := vec3_15;
  lp[1] := vec3_16;
  lp[2] := vec3_17;
  lc[0] := vec3_18;
  lc[1] := vec3_19;
  lc[2] := vec3_20;

end;

procedure TRayTraceColumns.PrepareFrame;
begin
  res := resolution.x / resolution.y;
end;

// Distance Field ray marcher / sphere marcher

// FragmentProgram
// based on iq/rgba 's seminar
// "Rendering Worlds with Two Triangles with raytracing on the GPU in 4096 bytes"
// at NVSCENE 08
// I have watched this great seminar, I have coded the below test program. ;)
// [http://www.rgba.org/iq/]

function TRayTraceColumns.flr(const p: vec3; f: float): float;
begin
  Result := abs(f - p.y);
end;

function TRayTraceColumns.sph(const p: vec3; const spr: vec4): float;
begin
  Result := length(spr.xyz - p) - spr.w;
end;

function TRayTraceColumns.cly(const p: vec3; const cld: vec4): float;
begin
  Result := length(Vec2.Create(cld.x + 0.5 * system.sin(p.y + p.z * 2), cld.z) - p.xz) - cld.w;
end;

function TRayTraceColumns.scene(const p: vec3): float;
var
  d: float;
begin
  d := flr(p, -5);
  d := Math.min(d, flr(p, 5));
  d := Math.min(d, sph(p, vec4_1));
  d := Math.min(d, sph(p, vec4_2));
  d := Math.min(d, sph(p, vec4_3));
  d := Math.min(d, sph(p, vec4_4));
  d := Math.min(d, sph(p, vec4_5));
  d := Math.min(d, cly(p, vec4_6));
  d := Math.min(d, cly(p, vec4_7));
  d := Math.min(d, cly(p, vec4_8));
  d := Math.min(d, cly(p, vec4_9));
  d := Math.min(d, cly(p, vec4_10));
  d := Math.min(d, cly(p, vec4_11));

  Result := Math.min(100000,d);
end;

function TRayTraceColumns.getN(const p: vec3): vec3;
var
  eps: float;
begin
  eps    := 0.01;
  Result := normalizeS(
    vec3.Create(
      scene(p + vec3.Create(eps, 0, 0)) -
      scene(p - vec3.Create(eps, 0, 0)),
      scene(p + vec3.Create(0, eps, 0)) -
      scene(p - vec3.Create(0, eps, 0)),
      scene(p + vec3.Create(0, 0, eps)) -
      scene(p - vec3.Create(0, 0, eps)))
  );
end;

function TRayTraceColumns.AO(const p, n: vec3): float;
var
  dlt: float;
  oc : float;
  d  : float;
  i  : integer;
begin
  dlt := 0.5;
  oc  := 0;
  d   := 1;

  for i := 0 to 5 do
  begin
    oc := oc + ((i * dlt - scene(p + n * i) * dlt) / d);
    d  := d * 2;
  end;

  Exit(1 - oc);
end;

function TRayTraceColumns.Main(var gl_FragCoord: Vec2): TColor32;
var
  position: Vec2;
  org     : vec3;
  dir     : vec3;
  g, d    : float;
  p       : vec3;
  i       : integer;
  n       : vec3;
  a       : float;
  s       : vec3;
  l, lv   : vec3;
  fg      : float;
begin
  position := 0.5*(gl_FragCoord.xy / resolution.xy - 0.5);
  org      := vec3_12;
  org.x    := org.x + system.sin(iGlobalTime);
  dir      := vec3.Create(
                 position.x * res,
                 position.y,
                 0.9)
              + (Mouse-0.5);

  p := org;

  for i := 0 to 63 do
  begin
    d := scene(p);
    p := p + d * dir;
  end;

  if d > 1 then
    Exit(clBlack32);

  n := getN(p);
  a := AO(p, n);
  s := vec3_14;

  for i := 0 to 2 do
  begin
    lv := lp[i] - p;
    l  := normalize(lv);
    g  := length(lv);
    g  := Math.max(0, dot(l, n)) / g * 10;
    s  := s + (g * lc[i]);
  end;

  fg     := min(1, 20 / length(p - org));
  Result := TColor32(s * a * fg * fg);

end;

initialization

RayTraceColumns := TRayTraceColumns.Create;
Shaders.Add('RayTraceColumns', RayTraceColumns);

finalization

FreeandNil(RayTraceColumns);

end.
