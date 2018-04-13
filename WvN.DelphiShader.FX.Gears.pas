unit WvN.DelphiShader.FX.Gears;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TGear = record
    pos: vec2;
    tn, ts, r, ang: float;
    constructor Create(aPos: vec2; aTn, aTs, aR, aAng: float);
  end;


type
  TGears = class(TShader)

  const
    vec2_1: vec2 = (x: -0.4;   y: 0.0);
    vec2_2: vec2 = (x: -0.4;   y: 0.34);
    vec2_3: vec2 = (x: -0.4;   y: -0.34);
    vec2_4: vec2 = (x: -0.06;  y: 0.0);
    vec2_5: vec2 = (x:  0.12;  y: 0.0);
    vec2_6: vec2 = (x:  0.595; y: 0.0);

    vec3_1: vec3 = (x: 0.8; y: 0.0; z: 0.0);
    vec3_2: vec3 = (x: 1.0; y: 1.0; z: 0.0);
    vec3_3: vec3 = (x: 1.0; y: 0.0; z: 1.0);
    vec3_4: vec3 = (x: 0.0; y: 0.0; z: 1.0);
    vec3_5: vec3 = (x: 1.0; y: 1.0; z: 1.0);
    vec3_6: vec3 = (x: 0.0; y: 1.0; z: 1.0);

  var
    drive: TGear;
    f, g: Array [1 .. 5] of TGear;
    procedure gearAngle(const p: TGear; var c: TGear);
    function cnorm(const v: vec2): vec2;
    function inGear(const g: TGear; p: vec2): float;
    function Main(var gl_FragCoord: vec2): TColor32;

  var
    res           : vec2;
    pi            : float;
    pos           : vec2;
    tn, ts, r, ang: float;

    constructor Create; override;
    procedure PrepareFrame;
  end;

var
  Gears: TShader;

implementation

uses SysUtils, Math;

{ Gear }

constructor TGear.Create(aPos: vec2; aTn, aTs, aR, aAng: float);
begin
  pos := aPos;
  tn  := aTn;
  ts  := aTs;
  r   := aR;
  ang := aAng;
end;

{ Gears }

constructor TGears.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
  pi        := arctan(1) * 4;
end;

procedure TGears.PrepareFrame;
begin
  drive := TGear.Create(vec2_1, 16,  0.03, 0.20, time);
  f[1]  := TGear.Create(vec2_2,  8, 0.025, 0.10, 0);  gearAngle(drive, f[1]);
  f[2]  := TGear.Create(vec2_3,  8, 0.025, 0.10, 0);  gearAngle(drive, f[2]);
  f[3]  := TGear.Create(vec2_4,  8, 0.025, 0.10, 0);  gearAngle(drive, f[3]);
  f[4]  := TGear.Create(vec2_5,  4, 0.025, 0.04, 0);  gearAngle( f[3], f[4]);
  f[5]  := TGear.Create(vec2_6, 32, 0.025, 0.40, 0);  gearAngle( f[4], f[5]);

  drive := TGear.Create(vec2_1, 16, 0.03, 0.20, time);
  Move(f, g, SizeOf(f));

  gearAngle(drive, g[1]);
  gearAngle(drive, g[2]);
  gearAngle(drive, g[3]);
  gearAngle( g[3], g[4]);
  gearAngle( g[4], g[5]);
  res := vec2.Create(resolution.x / resolution.y, 1) / 2;
end;

procedure TGears.gearAngle(const p: TGear; var c: TGear);
var
  ratio: float;
  off  : float;
begin
  ratio := p.tn / c.tn;
  off   := pi / c.tn;
  c.ang := -p.ang * ratio + off;
end;

function TGears.cnorm(const v: vec2): vec2;
begin
  Result := v / max(System.abs(v.x), System.abs(v.y));
end;

function TGears.inGear(const g: TGear; p: vec2): float;
var
  an: float;
  ra: float;
  csx:float;
//  mcs:float;
  angtn:Float;
begin
  p  := p - (g.pos);
  an := atan(p.x, p.y) + g.ang;
  ra := length(p);
  {
  cs.x := System.cos(an * g.tn);
  cs.y := System.sin(an * g.tn);
  cs := cnorm(cs);
  }

  angtn := an * g.tn;
  csx := System.cos(angtn);
{
  csy := System.sin(angtn);
  mcs := Math.Max(System.abs(csx),System.abs(csy));
  csx := csx / mcs;
}
  Result :=
  smoothstep(
    0.018,
    0.02,
    length(p)
  )
  *
  smoothstep(
    g.r + 0.005,
    g.r,
    ra - (csx * 0.5 + 0.5) * g.ts
  );

end;

function TGears.Main;
var
  p: vec2;
  f: float;
begin
  p := (gl_FragCoord.xy / resolution.y) - res;

  f := inGear(drive,p);  if f>0 then Exit(TColor32(f * vec3_1));
  f := inGear(g[1], p);  if f>0 then Exit(TColor32(f * vec3_2));
  f := inGear(g[2], p);  if f>0 then Exit(TColor32(f * vec3_3));
  f := inGear(g[3], p);  if f>0 then Exit(TColor32(f * vec3_4));
  f := inGear(g[4], p);  if f>0 then Exit(TColor32(f * vec3_5));
  f := inGear(g[5], p);  if f>0 then Exit(TColor32(f * vec3_6));
  exit(0);
end;

initialization

Gears := TGears.Create;
Shaders.Add('Gears', Gears);

finalization

FreeandNil(Gears);

end.
