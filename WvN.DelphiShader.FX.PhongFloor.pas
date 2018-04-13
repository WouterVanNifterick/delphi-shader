unit WvN.DelphiShader.FX.PhongFloor;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TPhongFloor = class(TShader)
  private const
    vec3_1: vec3 = (x: 0; y: 1; z: 1);
    vec3_2: vec3 = (x: 1; y: 1; z: 1);
    vec3_3: vec3 = (x: 1; y: 1; z: 1);
    vec3_4: vec3 = (x: 0; y: 1; z: 1);
    vec3_5: vec3 = (x: 0; y: - 5; z: 0);
    vec3_6: vec3 = (x: 0.1; y: 0; z: 0);
    e_xyy : vec3 = (x: 0.1; y: 0.0; z: 0.0);
    e_yxy : vec3 = (x: 0.0; y: 0.1; z: 0.0);
    e_yyx : vec3 = (x: 0.0; y: 0.0; z: 0.1);
    vec2_7: vec2 = (x: 0.1; y: 0);
    vec4_8: vec4 = (x: 0; y: 0; z: 0.1; w: 1);

  var
    vcv, vuv, prp, vrp, vpn, u, v: vec3;
    res: double;
  public
    function obj0(p: vec3): vec2;
    function obj0_c(const p: vec3): vec3;
    function Main(var gl_FragCoord: vec2): TColor32;

    procedure PrepareFrame;
    constructor Create; override;
  end;

var
  PhongFloor: TShader;

implementation

uses SysUtils, Math;

constructor TPhongFloor.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;

function TPhongFloor.obj0(p: vec3): vec2;
begin
  // obj deformation
  p.y := p.y + system.sin(system.sqrt(p.x * p.x + p.z * p.z) - time * 4) * 0.5;
  // plane
  Exit(vec2.Create(p.y + 3, 0));
end;

// Floor Color (checkerboard)
function TPhongFloor.obj0_c(const p: vec3): vec3;
begin
  if fract(p.x * 0.5) > 0.5 then
    if fract(p.z * 0.5) > 0.5 then
      Exit(vec3_1)
    else
      Exit(vec3_2)
  else if fract(p.z * 0.5) > 0.5 then
    Exit(vec3_3)
  else
    Exit(vec3_4)
end;

procedure TPhongFloor.PrepareFrame;
begin
  // Camera animation
  vuv := vec3.Create(0, 2, system.sin(time * 0.1));
  prp := vec3.Create(-system.sin(time * 0.6) * 8, 0, system.cos(time * 0.4) * 8);
  vrp := vec3_5;

  // Camera setup
  vpn := normalize(vrp - prp);
  u        := normalize(cross(vuv, vpn));
  v        := cross(vpn, u);
  vcv      := (prp + vpn);

  res      := resolution.x / resolution.y;
end;

function TPhongFloor.Main(var gl_FragCoord: vec2): TColor32;
var
  vPos         : vec2;
  scrCoord, scp: vec3;
  maxd         : float;
  s            : vec2;
  c, p, n      : vec3;
  f, b         : float;
  i            : integer;
begin
  Result := clBlack32; // background color

  vPos := -1 + 2 * gl_FragCoord.xy / resolution.xy;

  scrCoord := vcv + vPos.x * u * res + vPos.y * v;
  scp      := normalize(scrCoord - prp);

  // Raymarching
  maxd := 80;

  s := vec2_7;

  f     := 1;
  for i := 0 to 155 do
  begin
    if (System.abs(s.x) < 0.01) or (f > maxd) then
      break;
    f := f + s.x;
    p := prp + scp * f;
    s := obj0(p);
  end;

  if f < maxd then
  begin
    if IsZero(s.y) then
    begin
      c      := obj0_c(p);
      n      := normalize(vec3.Create(s.x - obj0(p - e_xyy).x, s.x - obj0(p - e_yxy).x, s.x - obj0(p - e_yyx).x));
      b      := dot(n, normalize(prp - p));
      Result := TColor32((b * c + pow(b, 8)) * (1 - f * 0.02)); // simple phong LightPosition=CameraPosition
    end
  end
end;

initialization

PhongFloor := TPhongFloor.Create;
Shaders.Add('PhongFloor', PhongFloor);

finalization

FreeandNil(PhongFloor);

end.
