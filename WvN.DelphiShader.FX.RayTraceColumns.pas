unit WvN.DelphiShader.FX.RayTraceColumns;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TRayTraceColumns = class(TShader)
  const
    eps    = 0.01;
    vec4_1: vec3  = (x:  0; y:  15; z: 1.5);
    vec4_2: vec3  = (x: -8; y:  20; z: 2  );
    vec4_3: vec3  = (x: -5; y:  15; z: 0.5);
    vec4_4: vec3  = (x: -1; y:  15; z: 2  );
    vec4_5: vec3  = (x:  2; y:  15; z: 0.5);
    vec4_6: vec3  = (x: 10; y:  20; z: 1  );
    vec4_7: vec3  = (x:  4; y:  15; z: 1  );
    vec4_8: vec3  = (x:  0; y:  20; z: 1  );
    vec4_9: vec3  = (x: -2; y:  25; z: 1  );
    vec4_10: vec3 = (x: -6; y:  30; z: 1  );
    vec4_11: vec3 = (x:-12; y:  35; z: 2);
    vec3_12: vec3 = (x: 0; y: 0; z: 0);
    vec4_13: vec4 = (x: 0; y: 0; z: 0; w: 1);
    vec3_14: vec3 = (x: 0; y: 0; z: 0);
    vec3_15: vec3 = (x: - 4; y: 0; z: 4);
    vec3_16: vec3 = (x: 2; y: 0; z: 8);
    vec3_17: vec3 = (x: 4; y: - 2; z: 24);
    vec3_18: vec3 = (x: 1; y: 0.5; z: 0.4);
    vec3_19: vec3 = (x: 0.4; y: 0.5; z: 1);
    vec3_20: vec3 = (x: 0.2; y: 1; z: 0.5);

    eps100: vec3 = (x: eps ; y: 0.00; z: 0.00);
    eps010: vec3 = (x: 0.00; y:  eps; z: 0.00);
    eps001: vec3 = (x: 0.00; y: 0.00; z: eps);

  const
    cols:array[0..11] of vec4=(
      (x: 0; y: - 2; z: 15; w: 1.5),
      (x: -8; y: 0; z: 20; w: 2),
      (x: -5; y: 4; z: 15; w: 0.5),
      (x: -1; y: 3; z: 15; w: 2),
      (x: 2; y: - 3; z: 15; w: 0.5),
      (x: 10; y: 0; z: 20; w: 1),
      (x: 4; y: 0; z: 15; w: 1),
      (x: 0; y: 0; z: 20; w: 1),
      (x: - 2; y: 0; z: 25; w: 1),
      (x: - 6; y: 0; z: 30; w: 1),
      (x: - 12; y: 0; z: 35; w: 2),
      (x: 0; y: 0; z: 0; w: 0)
    );

    cols3:array[0..11] of vec3=(
      (x: 0;  y: - 2; z: 15),
      (x: -8; y: 0; z: 20),
      (x: -5; y: 4; z: 15),
      (x: -1; y: 3; z: 15),
      (x: 2;  y: - 3; z: 15),
      (x: 10; y: 0; z: 20),
      (x: 4;  y: 0; z: 15),
      (x: 0;  y: 0; z: 20),
      (x: - 2; y: 0; z: 25),
      (x: - 6; y: 0; z: 30),
      (x: - 12; y: 0; z: 35),
      (x: 0; y: 0; z: 0)
    );

  var
    org     : vec3;
    lp: array [0 .. 2] of vec3;
    lc: array [0 .. 2] of vec3;
    res: double;



    function flr(p,f: float): float;inline;
    function sph(const p: vec3; spr: integer): float;//inline;
    function cly(const p:vec3;cld: integer): float;//inline;
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

  org      := vec3_12;
  org.x    := org.x + sinLarge(iGlobalTime);

end;

// Distance Field ray marcher / sphere marcher

// FragmentProgram
// based on iq/rgba 's seminar
// "Rendering Worlds with Two Triangles with raytracing on the GPU in 4096 bytes"
// at NVSCENE 08
// I have watched this great seminar, I have coded the below test program. ;)
// [http://www.rgba.org/iq/]

function TRayTraceColumns.flr(p,f: float): float;
begin
  Result := System.abs(f - p);
end;
{
function TRayTraceColumns.sph(const p: vec3; spr: integer): float;
begin
  Result := length(cols3[spr] - p) - cols[spr].w;
end;
}
function TRayTraceColumns.sph(const p: vec3; spr: integer): float;
begin
  Result := length(cols3[spr] - p) - cols[spr].w;
 end;


function TRayTraceColumns.cly(const p:vec3;cld: integer): float;
var v2:Vec2;
begin
  v2.x := (cols[cld].x + 0.5 * system.sin(p.y + p.z * 2))-p.x;
  v2.y := cols[cld].z-p.z;

  Result := length(v2) - cols[cld].w;

end;

function TRayTraceColumns.scene(const p: vec3): float;
var
  d: float;
begin
  d := abs(p.y + 5);
  d := Math.min(d, abs(p.y - 5));
  d := Math.min(d, sph(p, 1));
  d := Math.min(d, sph(p, 2));
  d := Math.min(d, sph(p, 3));
  d := Math.min(d, sph(p, 4));
  d := Math.min(d, sph(p, 5));
  d := Math.min(d, cly(p, 6));
  d := Math.min(d, cly(p, 7));
  d := Math.min(d, cly(p, 8));
  d := Math.min(d, cly(p, 9));
  d := Math.min(d, cly(p, 10));
  d := Math.min(d, cly(p, 11));

  Result := Math.min(100000,d);
end;

function TRayTraceColumns.getN(const p: vec3): vec3;
begin
  Result.x := scene(p + eps100) - scene(p - eps100);
  Result.y := scene(p + eps010) - scene(p - eps010);
  Result.z := scene(p + eps001) - scene(p - eps001);
  Result.NormalizeSelf;
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

  Result := 1 - oc;
end;

function TRayTraceColumns.Main(var gl_FragCoord: Vec2): TColor32;
var
//  position: Vec2;
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
  dir.x := 0.5*(gl_FragCoord.x / resolution.x - 0.5) * res;
  dir.y := 0.5*(gl_FragCoord.y / resolution.y - 0.5);
  dir.z := 0.9;

  p := org;

  for i := 0 to 23 do
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
    l  := lv;
    l.NormalizeSelf;
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
