unit WvN.DelphiShader.FX.AttackOfTheFuz;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  // https://www.shadertoy.com/view/Mss3RM
  TAttackOfTheFuz = class(TShader)
  const
    q1: vec3 = (x: 0.00; y: - 0.15; z: 0.00);
    q2: vec3 = (x: 0.00; y: - 0.50; z: 0.05);
    q3: vec3 = (x: - 0.08; y: - 0.15; z: 0.00);
    q4: vec3 = (x: 0.08; y: - 0.15; z: 0.00);
    q5: vec3 = (x: - 0.05; y: - 0.50; z: 0.05);
    q6: vec3 = (x: 0.05; y: - 0.50; z: 0.05);
    q7: vec3 = (x: 1.00; y: 0.00; z: 0.00);
    q8: vec3 = (x: 0.10; y: - 0.25; z: - 3.00);
    v: vec3  = (x: 12.9898; y: 78.233; z: 112.166);
    v_1_0: Vec2 = (x: 1; y: 0);
    v3_xxx: Vec3 = (x: 1; y: 1; z:1);
    v3_xxy: Vec3 = (x: 1; y: 1; z:0);
    v3_xyy: Vec3 = (x: 1; y: 0; z:0);
    v3_yxy: Vec3 = (x: 0; y: 1; z:0);
    v3_xyx: Vec3 = (x: 1; y: 0; z:1);
    v3_yxx: Vec3 = (x: 0; y: 1; z:1);
    v3_yyx: Vec3 = (x: 0; y: 0; z:1);
    c1: vec3 = (x: 1.5; y: 1.0; z: 1.25);
    c2: vec3 = (x: 0.3; y: 0.1; z: 1.00);

  var
    p1, p2, p3, p6, p9, p12, rt, ro: vec3;
    Ratio: Vec2;
    constructor Create; override;

    function rand(const co: vec3): float; inline;
    function noyz(co: vec3): float; inline;
    function Segment(const p, p0, p1: vec3; r: float): float; // connect 2 points

    procedure PrepareFrame;
    function RenderPixel(var gl_FragCoord: Vec2): TColor32;

    function DE(const aZ: vec3): float;
    function scene(const ro, rd: vec3): vec3;

  end;

var
  AttackOfTheFuz: TShader;

implementation

uses SysUtils, Math;

const
  half: single = 0.5;

constructor TAttackOfTheFuz.Create;
begin
  inherited;
  Image.FrameProc := PrepareFrame;
  Image.PixelProc := RenderPixel;
end;


procedure TAttackOfTheFuz.PrepareFrame;
begin
  p1    := q1;
  p2    := q2;
  p3    := q3;
  p6    := q4;
  p9    := q5;
  p12   := q6;
  rt    := q7;
  ro    := q8;
  Ratio := Vec2.Create(1.0, Resolution.y / Resolution.x)

end;

function TAttackOfTheFuz.rand(const co: vec3): float;
begin
  // implementation found at: lumina.sourceforge.net/Tutorials/Noise.html
  exit(random);
  Result := fract(system.sin(dot(co * 0.123, v)) * 43758.5453);
end;

function TAttackOfTheFuz.noyz(co: vec3): float;
var
  d: vec3;
begin
//  exit(system.Random);
  d      := smoothstep(0.0, 1.0, fract(co));
  co     := floor(co);
  Result := mix(
            mix(
            mix(
            rand(co), rand(co + v3_xyy), d.x),
                  mix(rand(co + v3_yxy),
                      rand(co + v3_xxy), d.x), d.y),
            mix(mix(rand(co + v3_yyx),
            rand(co + v3_xyx), d.x),
            mix(rand(co + v3_yxx),
                rand(co + v3_xxx),
                d.x),
                d.y),
                d.z);
end;

function Limb2(const p, p0, p2, rt: vec3; d, r: float): float;
var
  p1, v, v2: vec3;
begin
  p1     := (p2 - p0) * 0.5; // a simple joint solver
  p1     := p1 + (p0 + normalize(cross(p1, rt)) * (d * d - dot(p1, p1)));
  v      := p1 - p0;
  v      := v * clamp(dot(p - p0, v) / dot(v, v));
  v2     := p1 - p2;
  v2     := v2 * clamp(dot(p - p2, v2) / dot(v2, v2));
  Result := Math.min(distance(p - p0, v), distance(p - p2, v2)) - r;
end;

function TAttackOfTheFuz.Segment(const p, p0, p1: vec3; r: float): float; // connect 2 points
var
  v: vec3;
begin
  v      := p1 - p0;
  v      := v * clamp(dot(p - p0, v) / dot(v, v));
  Result := distance(p - p0, v) - r;
end;

function TAttackOfTheFuz.scene(const ro, rd: vec3): vec3;
var
  rayLen, dist, atm: double;
  i                : integer;
begin
  rayLen := 0;
  atm    := 0;
  for i  := 0 to 47 do
  begin
    dist   := min(DE(ro + rayLen * rd) * 0.55, 0.125);
    rayLen := rayLen + dist;
    atm    := atm + (noyz(ro + rayLen * rd - vec3(iGlobalTime)) * 0.03);
    if (rayLen > 6) or (dist < 0.01) then
      break;
  end;
  rayLen := rayLen / 6;
  Result := vec3.Create(rayLen * rayLen + atm) * pow(dot(rd, c2), 3);
end;

function TAttackOfTheFuz.DE(const aZ: vec3): float;
var
  i               : integer;
  d, tim, arm     : double;
  p5, p8, p11, p14: vec3;
  si, st, ct      : double;
  z : vec3;
begin
  z.x := math.max(0,aZ.x);
  z.y := math.max(0,aZ.y);
  z.z := math.max(0,aZ.z) + (iGlobalTime * 0.1);
  i   := trunc(Math.floor(z.z) + Math.floor(z.x));
  si  := system.sin(i);
  // z.xz:=abs(vec2(1.0)-&mod(z.xz,2.0))-vec2(0.5)+0.25*vec2(sin(i));//for moon walking
  z.xz   := &mod(z.xz, 1) - vec2Gray + 0.25 * Vec2.Create(si);
  tim    := iGlobalTime + i;
  arm    := si * 0.2;
  st     := system.sin(tim);
  ct     := system.cos(tim);
  p5     := vec3.Create(-0.38 + System.abs(arm), arm - 0.1 - System.abs(-st * 0.05), -0.1 - ct * 0.1);
  p8     := vec3.Create(0.38 - System.abs(arm), arm - 0.1 - System.abs(system.sin(tim + pi) * 0.05), -0.1 + ct * 0.1);
  p11    := vec3.Create(-0.075, -0.975 + max(0.0, system.cos(tim + pi) * 0.05), st * 0.2);
  p14    := vec3.Create(0.075, -0.975 + max(0.0, ct * 0.05), -st * 0.2);
  d      := Math.min(z.y + 1.0, min(length(z * c1) - 0.1, Segment(z, p1, p2, 0.065)));
  d      := Math.min(d, Math.min(Limb2(z, p3, p5, rt, 0.30, 0.025), Limb2(z, p6, p8, rt, 0.30, 0.025)));
  Result := Math.min(d, Math.min(Limb2(z, p9, p11, -rt, 0.33, 0.025), Limb2(z, p12, p14, -rt, 0.33, 0.025))) - noyz(z * 100.0) * 0.02;
end;

function TAttackOfTheFuz.RenderPixel(var gl_FragCoord: Vec2): TColor32;
var
  uv       : Vec2;
  rd, color: vec3;
begin
  uv     := (gl_FragCoord.xy / Resolution.xy - Vec2(0.5)) * Ratio;
  rd     := normalize(vec3.Create(uv, 0.2));
  color  := scene(ro, rd);
  Result := TColor32(color);
end;

initialization

AttackOfTheFuz := TAttackOfTheFuz.Create;
Shaders.Add('AttackOfTheFuz', AttackOfTheFuz);

finalization

FreeandNil(AttackOfTheFuz);

end.
