unit WvN.DelphiShader.FX.Water;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type

  // http://glsl.heroku.com/e#13679.0

  TWater = class(TShader)
  var
    res: double;
    sc : vec2;

    function check(const p: vec2; size: float): float;
    function Main(var gl_FragCoord: vec2): TColor32;

    constructor Create; override;
    procedure PrepareFrame;
  end;

var
  Water: TShader;

implementation

uses SysUtils, Math;

constructor TWater.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;

procedure TWater.PrepareFrame;
begin
  // drip test --joltz0r
  res := resolution.x / resolution.y;
  sc  := vec2.Create(system.sin(time * 0.54), system.cos(time * 0.56));
end;



function TWater.check(const p: vec2; size: float): float;
var c : Double;
begin
  c := int(floor(system.cos(p.x / size) * 10000) * ceil(system.cos(p.y / size) * 10000)) * 0.0001;
  Exit(clamp(c, 0.3, 0.7));
end;

function TWater.Main(var gl_FragCoord: vec2): TColor32;
var
  p     : vec2;
  f     : float;
  d     : float;
  len   : float;
  dist  : float;
  pc, ic: float;
begin
  p   := ((gl_FragCoord.xy / resolution.xy) - 0.5) * 2.5;
  p.x := p.x * res;
  d     := length(p) * 10;
  len   := (1 - length(p * 0.5));
  dist  := len * (1 - system.sin(pow(d, 1.25) + (system.cos(d - time * 2.5) * 4)));
  pc    := check(p, 0.125);
  p     := p + (vec2(dist * 0.05) * len);
  ic    := check(p, 0.125);

  f      := 1 / ((length(p + sc) * pc) + ((length(p + sc) * ic * 8)));
  Result := TColor32(Vec3(f));
end;

initialization

Water := TWater.Create;
Shaders.Add('Water', Water);

finalization

FreeandNil(Water);

end.
