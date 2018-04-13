unit WvN.DelphiShader.FX.Nautilus;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TNautilus=class(TShader)
  var ct4,ct7,t5,t6,t7:double;
      tm:double;

  n:array[0..99] of vec3;
  const
    m = 1.0-1.5;
    vec3_1: vec3  = (x: 0.4; y: 0.7; z: 1.0);

    constructor Create;override;
    procedure PrepareFrame;
    function RenderPixel(var gl_FragCoord:Vec2): TColor32;
    function e(const c:vec3):Double;
  end;

var
  Nautilus:TShader;

implementation

uses SysUtils, Math;


const
  half:single=0.5;

constructor TNautilus.Create;
var i:integer;
begin
  inherited;
  FrameProc := prepareFrame;
  PixelProc := RenderPixel;
  for i :=0 to 99 do
  begin
    n[i].r := System.cos(1.1*i);
    n[i].g := System.cos(1.6*i);
    n[i].b := System.cos(1.4*i);
  end;
end;

function TNautilus.e(const c: vec3): Double;
var t:Vec3;
begin
  {$EXCESSPRECISION OFF}

  t.x := System.Cos(
           System.Cos(c.r  +t6) * c.r -
           System.Cos(c.g*3+t5) * c.g );

  t.y := System.Cos( ct4*c.b/3 * c.r -
                     ct7*c.g          );

  t.z := System.Cos( c.r+c.g+c.b+tm );

  t := t * t;
  result := t.x + t.y + t.z -1;
end;

procedure TNautilus.PrepareFrame;
begin
  tm := &mod(time,1000);
  t5 := tm/5;
  t6 := tm/6;
  t7 := tm/7;
  ct4 := System.cos(tm/4);
  ct7 := System.cos(t7);
end;


function TNautilus.RenderPixel(var gl_FragCoord: Vec2): TColor32;
var
  c, v, g: vec3;
  a      : TVecType;
  o      : vec3;
  r, q   : integer;
  l, h   : double;
const
  Iterations=80;
  IterationsMult=1/(Iterations-1);
begin
  c.x := -1 + 2 * gl_FragCoord.x / Resolution.x;
  c.y := -1 + 2 * gl_FragCoord.y / Resolution.y;
  o   := vec3.Create(c.x, c.y, 0);
  g   := vec3.Create(c.x, c.y, 1) * (1 / 64);
  v   := vec3Gray;

  for r := 1 to Iterations do
  begin
    h := e(o) - m;
    if h < 0 then
      break;
    o := o + h * 10 * g;
    v := v + h * 0.02;
  end;

  // light (who needs a normal?)
  v := v + e(o + 0.1) * vec3_1;

  // ambient occlusion
  a     := 0;
  for q := 1 to Iterations do
  begin
    l := e(o + 0.5 * n[q]) - m;
    a := a + clamp(l);
  end;
//  v      := v * a * (1 / 99);
  v.x := v.x * a * IterationsMult;
  v.y := v.y * a * IterationsMult;
  v.z := v.z * a * IterationsMult;

  result := TColor32(v);
end;


initialization
  Nautilus := TNautilus.Create;
  Shaders.Add('Nautilus',Nautilus);

finalization
  FreeandNil(Nautilus);
end.
