unit WvN.DelphiShader.FX.RibbonTunnel;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TRibbonTunnel = class(TShader)
    ratio:double;
  const
    vec3_1: vec3 = (x: 0.01; y: 0; z: 0);
    vec3_2: vec3 = (x: 0.1; y: 0.1; z: 0);
    vec3_3: vec3 = (x: 1; y: 0.8; z: 0.7);
    vec3_0: vec3 = (x: 1; y: 1; z: 1);

    vec3_xyy: vec3 = (x: 0.01; y: 0.00; z: 0.00);
    vec3_yxy: vec3 = (x: 0.00; y: 0.01; z: 0.01);
    vec3_yyx: vec3 = (x: 0.01; y: 0.01; z: 0.00);
  var
    vsc,vt,org,rc:vec3;
    ct,st:double;

    function oa(const q: vec3): float;
    function ob(const q: vec3): float;
    function o(const q: vec3): float;
    function gn(const q: vec3): vec3;
    function Main(var gl_FragCoord: Vec2): TColor32;

    constructor Create; override;
    procedure PrepareFrame;
  end;

var
  RibbonTunnel: TShader;

implementation

uses SysUtils, Math;

constructor TRibbonTunnel.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;

// by TX95

// Object A (tunnel)
function TRibbonTunnel.oa(const q: vec3): float;
begin
  Result := system.cos(q.x) +
            system.cos(q.y * 0.1) +
            system.cos(q.z) +
            system.cos(q.y * 20) * 0.05;
end;

// Object B (ribbon)
function TRibbonTunnel.ob(const q: vec3): float;
begin
  Result := length(
              max(abs(q - vec3.Create(
                            system.sin(q.z * 3.0) * 0.3,
                            -0.1 + system.cos(q.z      ) * 0.1,
                            0.0)) - vt,
              vec3Black)
            );
end;

// Scene
function TRibbonTunnel.o(const q: vec3): float;
begin
  Result := Math.min(oa(q), ob(q));
end;

// Get Normal
function TRibbonTunnel.gn(const q: vec3): vec3;
begin
  Result.x := o(q + vec3_xyy);
  Result.y := o(q + vec3_yxy);
  Result.z := o(q + vec3_yyx);
  Result.NormalizeSelf;
end;

procedure TRibbonTunnel.PrepareFrame;
begin
  ratio := (resolution.x / resolution.y);
  org := vec3.Create(system.sin(time) * 0.5, system.cos(time * 0.5) * 0.25 + 0.25, time);
  vt := vec3.Create(0.125, 0.02, time + 3);

  ct :=system.cos(time * 0.5) * 0.5 + 0.5;
  st :=system.sin(time * 0.5) * 0.5 + 0.5;
  rc := vec3.Create(system.cos(time * 0.3) * 0.5 + 0.5,
                            system.cos(time * 0.2) * 0.5 + 0.5,
                            system.sin(time * 0.3) * 0.5 + 0.5);
  vsc := vec3.Create(0.3, ct, st);
end;

function TRibbonTunnel.Main;
var
  i              : integer;
  p              : Vec2;
  dir, pp, q     : Vec3;
  d, f           : float;
  fcolor,c       : vec3;
begin
  p   := -1 + 2 * gl_FragCoord.xy / resolution.xy;
  p.x := p.x * ratio;

  c   := vec3_0;
  dir := normalize(vec3.Create(p.x * 1.6, p.y, 1));
  q   := org;

  // First raymarching
  for i := 0 to 35{9} do
  begin
    d := o(q);
    q := q + (d * dir);
  end;

  pp := q;
  f  := length(q - org) * 0.02;

  // Second raymarching (reflection)
  dir   := reflect(dir, gn(q));
  q     := q + (dir);
  for i := 0 to {6}3 do
  begin
    d := o(q);
    q := q + (d * dir);
  end;

  c := Math.max(dot(gn(q), vec3_2), 0) + vsc * min(length(q - org) * 0.04,1);

  // Ribbon Color
  if oa(pp) > ob(pp) then
    c := mix(c, rc, 0.3);

  // Final Color
  fcolor := ((c + f) + (1 - min(pp.y + 1.9, 1)) * vec3_3) * min(time * 0.5, 1);
  Result := TColor32(fcolor);
end;

initialization

RibbonTunnel := TRibbonTunnel.Create;
Shaders.Add('RibbonTunnel', RibbonTunnel);

finalization

FreeandNil(RibbonTunnel);

end.
