unit WvN.DelphiShader.FX.RayMarchCam;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TRayMarchCam = class(TShader)
    vuv     : vec3;
    prp     : vec3;
    vrp     : vec3;
    vpn     : vec3;
    u       : vec3;
    v       : vec3;
    vcv     : vec3;
    function ObjUnion(const obj0: vec2; const obj1: vec2): vec2;
    function obj0(const p: vec3): vec2;inline;
    function obj0_c(const p: vec3): vec3;inline;
    function obj1(const p: vec3): vec2;inline;
    function obj1_c(const p: vec3): vec3;inline;
    function inObj(const p: vec3): vec2;inline;
    function inObj2(const p: vec3): float;
    function Main(var gl_FragCoord: vec2): TColor32;
    constructor Create; override;
    procedure PrepareFrame;
  end;

const
  vec3_1: vec3 = (x: 0; y: 0; z: 0);
  vec3_2: vec3 = (x: 2; y: 1; z: 1);
  vec3_3: vec3 = (x: 1; y: 1; z: 1);
  vec3_4: vec3 = (x: 0; y: 0; z: 0);
  vec3_5: vec3 = (x: 0.25; y: 0.25; z: 0.25);
  vec3_6: vec3 = (x: 0; y: 0; z: 0);
  vec3_7: vec3 = (x: 0.1; y: 0; z: 0);
  vec3_7_xyy: vec3 = (x: 0.1; y: 0.0; z: 0.0);
  vec3_7_yxy: vec3 = (x: 0.0; y: 0.1; z: 0.0);
  vec3_7_yyx: vec3 = (x: 0.0; y: 0.0; z: 0.1);

  vec2_8: vec2 = (x: 0.1; y: 0.0);

var
  RayMarchCam: TShader;

implementation

uses SysUtils, Math;

constructor TRayMarchCam.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;

procedure TRayMarchCam.PrepareFrame;
begin
  // Camera animation
  vuv := vec3.Create(0, 1, system.sin(time * 0.1));
  prp := vec3.Create(-system.sin(time * 0.6) * 8.0, -1, system.cos(time * 0.4) * 8.0);
  vrp := vec3_6;

  vpn      := normalize(vrp - prp);
  u        := normalize(cross(vuv, vpn));
  v        := cross(vpn, u);
  vcv      := (prp + vpn);

end;

// by @paulofalcao

// Simple raymarching sandbox with camera

// Raymarching Distance Fields
// About http://www.iquilezles.org/www/articles/raymarchingdf/raymarchingdf.htm
// Also known as Sphere Tracing

function TRayMarchCam.ObjUnion(const obj0: vec2; const obj1: vec2): vec2;
begin
  if obj0.x < obj1.x then
    Exit(obj0)
  else
    Exit(obj1);
end;

// Scene Start

// Floor
function TRayMarchCam.obj0(const p: vec3): vec2;
begin
  // plane
  Result.x := p.y + 3.0 + (system.sin(system.sqrt(p.x * p.x + p.z * p.z) - time * 4.0) * 0.5);
  Result.y := 0;
end;

// Floor Color (checkerboard)
function TRayMarchCam.obj0_c(const p: vec3): vec3;
begin
  if fract(p.x * 0.5) > 0.5 then
    if fract(p.z * 0.5) > 0.5 then
      Exit(vec3_1)
    else
      Exit(vec3_2)
  else
    if fract(p.z * 0.5) > 0.5 then
      Exit(vec3_3)
    else
      Exit(vec3_4);
end;

// IQs RoundBox (try other objects http://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm)
function TRayMarchCam.obj1(const p: vec3): vec2;
var t:vec3;
begin
  // obj deformation
  t.x := fract(p.x + 0.5) - 0.5;
  t.z := fract(p.z + 0.5) - 0.5;
  t.y := p.y - 1.0 + system.sin(time * 6.0);
  Result.x := length(max(abs(t) - vec3_5, 0.0)) - 0.05;
  Result.y := 1;
end;

// RoundBox with simple solid color
function TRayMarchCam.obj1_c(const p: vec3): vec3;
begin
  Result.x := 1;
  Result.y := system.sin(p.x * 0.2);
  Result.z := system.sin(p.z * 0.2);
end;

// Objects union
function TRayMarchCam.inObj(const p: vec3): vec2;
begin
  Result := ObjUnion(obj0(p), obj1(p));
end;


function TRayMarchCam.inObj2(const p: vec3): float;
begin
  Result := Math.Min(obj0(p).x, obj1(p).x);
end;

// Scene End

function TRayMarchCam.Main;
var
  vPos    : vec2;
  scrCoord: vec3;
  scp     : vec3;
  maxd    : float;
  s       : vec2;
  c, n : vec3;
  p,p1,p2,p3:Vec3;
  f       : float;
  i       : integer; // loop variable
  b       : float;
begin
  vPos := -1.0 + 2.0 * gl_FragCoord.xy / resolution.xy;

  // Camera setup
  scrCoord := vcv + vPos.x * u * resolution.x / resolution.y + vPos.y * v;
  scp      := normalize(scrCoord - prp);

  // Raymarching
  maxd := 60.0;

  s := vec2_8;

  f     := 1.0;
  for i := 0 to 255 do
  begin
    if (System.abs(s.x) < 0.01) or (f > maxd) then
      break;
    f := f + (s.x);
    p := prp + scp * f;
    s := inObj(p);
  end;

  if f < maxd then
  begin
    if s.y = 0.0 then
      c := obj0_c(p)
    else
      c    := obj1_c(p);

    p1.x := p.x - 0.1;
    p1.y := p.y;
    p1.z := p.z;

    p2.x := p.x;
    p2.y := p.y - 0.1;
    p2.z := p.z;

    p3.x := p.x;
    p3.y := p.y;
    p3.z := p.z - 0.1;

    n      := normalize(
                vec3.Create(
                  s.x - Math.Min(obj0(p1).x, obj1(p1).x),
                  s.x - Math.Min(obj0(p2).x, obj1(p2).x),
                  s.x - Math.Min(obj0(p3).x, obj1(p3).x)
                )
              );
    b      := dot(n, normalize(prp - p));
    Result := TColor32(((b * c + pow(b, 8)) * (1 - f * 0.02)) ); // simple phong LightPosition=CameraPosition
  end
  else
    Result := clBlack32; // background color
end;

initialization

RayMarchCam := TRayMarchCam.Create;
Shaders.Add('RayMarchCam', RayMarchCam);

finalization

FreeandNil(RayMarchCam);

end.
