unit WvN.DelphiShader.FX.Flame;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type

  TFlame = class(TShader)
  const
    Iterations = 32;
    c1: Vec3 = (x: 1; y: 0.5; z: 1);
    c2: Vec4 = (x: 0; y: - 1; z: 0; w: 1);
    c3: Vec4 = (x: 0; y: 57; z: 21; w: 78);
    c4: Vec3 = (x: 1; y: 57.5; z: 21);
    c5: Vec4 = ();
    c6: Vec4 = (x: 1; y: 0.5; z: 0.1; w: 1);
    c7: Vec4 = (x: 0.1; y: 0.5; z: 1; w: 1);
  var
    org : Vec3;
    FireP:Float;
    t:Vec3;
    res:double;
    function noise(const p: Vec3): float;
    function sphere(const p: Vec3; const spr: Vec4): float; inline;
    function fire(const p: Vec3): float; inline;
    function scene(const p: Vec3): float;
    function Raymarche(const org: Vec3; const dir: Vec3): Vec4;
    constructor Create; override;
    procedure PrepareFrame;
    function RenderPixel(var gl_FragCoord: Vec2): TColor32;
  end;

var
  Flame: TShader;

implementation

uses SysUtils, Math;


constructor TFlame.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := RenderPixel;
end;

procedure TFlame.PrepareFrame;
begin
  t   := Vec3.Create(0, iGlobalTime * 2, 0);
  org := Vec3.Create(0, -2, 4);
  res := Resolution.x / Resolution.y;
end;

// Thx to Las^Mercury


function TFlame.noise(const p: Vec3): float;
var
  i: Vec3;
  a,a1: Vec4;
  f: Vec3;
  ppii:vec3;
begin
  Exit(Random);

  i      := floor(p);
  a.xyz  := dot(i, c4);
  a.y    := a.y + 57;
  a.z    := a.z + 21;
  a.w    := a.w + 78;
  ppii   := p - i;
  f.x := system.cos(ppii.x*pi) * -0.5 + 0.5;
  f.y := system.cos(ppii.y*pi) * -0.5 + 0.5;
  f.z := system.cos(ppii.z*pi) * -0.5 + 0.5;

  a1     := 1 + a;
  a      := mix(sin(cos(a) * a), sin(cos(a1) * a1), f.x);
  a.xy   := mix(a.xz, a.yw, f.y);
  Result := mix(a.x, a.y, f.z);
end;

// -----------------------------------------------------------------------------
// Scene/Objects
// -----------------------------------------------------------------------------
function TFlame.sphere(const p: Vec3; const spr: Vec4): float;
begin
  Result := length(spr.xyz - p) - spr.w;
end;

function TFlame.fire(const p: Vec3): float;
var
  d: float;
begin
  d      := sphere(p * c1, c2);
  Result := d + (noise(p + t) + noise(p * 3) * 0.5) * 0.25 * p.y;
end;

// -----------------------------------------------------------------------------
// Raymarching tools
// -----------------------------------------------------------------------------
function TFlame.scene(const p: Vec3): float;
begin
  Result := Math.min(100 - length(p), abs(FireP));
end;

function TFlame.Raymarche(const org: Vec3; const dir: Vec3): Vec4;
var
  d     : float;
  p     : Vec3;
  glow  : float;
  eps   : float;
  glowed: boolean;
  i     : integer;
begin
  d      := 0.0;
  p      := org;
  glow   := 0.0;
  eps    := 0.02;
  glowed := false;
  for i  := 0 to Iterations - 1 do
  begin
    FireP := Fire(P);
    d := scene(p) + eps;
    p := p + (d * dir);
    if d > eps then
    begin
      if FireP < 0 then
        glowed := true;
      if glowed then
        glow := i / Iterations;
    end;
  end;
  Result := Vec4.Create(p, glow);
end;


// -----------------------------------------------------------------------------
// Main functions
// -----------------------------------------------------------------------------

function TFlame.RenderPixel(var gl_FragCoord: Vec2): TColor32;
var
  v   : Vec2;
  dir : Vec3;
  p   : Vec4;
  glow: float;
begin
  v      := -1.0 + 2.0 * gl_FragCoord.xy / Resolution.xy;
  v.x    := v.x * res;
  dir    := normalize(Vec3.Create(v.x * 1.6, -v.y, -1.5));
  p      := Raymarche(org, dir);
  glow   := p.w;
  Result := TColor32((mix(c5, mix(c6, c7, p.y * 0.02 + 0.4), pow(glow * 2, 4))));
end;

initialization

Flame := TFlame.Create;
Shaders.Add('Flame', Flame);

finalization

FreeandNil(Flame);

end.
