unit WvN.DelphiShader.FX.WaterTurbulence3;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TWaterTurbulence3 = class(TShader)
  const
    MAX_ITER     = 10;
    vec3_1: vec3 = (x: 0.5; y: 0.5; z: 1);

  var
    surfaceP: Vec2;
    constructor Create; override;
    procedure PrepareFrame;
    function main(var gl_FragCoord: Vec2): TColor32;
  end;

var
  WaterTurbulence3: TShader;

implementation

uses SysUtils, Math;

constructor TWaterTurbulence3.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := main;
end;

procedure TWaterTurbulence3.PrepareFrame;
begin
  // water turbulence effect by joltz0r 2013-07-04, improved 2013-07-07
end;

function TWaterTurbulence3.main(var gl_FragCoord: Vec2): TColor32;
var
  p, i        : Vec2;
  c, inten, t : float;
  n           : int;
begin
  surfaceP := (gl_FragCoord / Resolution) - 0.5;
  p        := surfaceP * 8;
  i        := p;
  c        := 0;
  inten    := 0.5;

  for n := 0 to MAX_ITER - 1 do
  begin
    t := time * (1 - (1 / (n + 1)));
    i := p + Vec2.Create(
               system.cos(t - i.x) + system.sin(t + i.y),
               system.sin(t - i.y) + system.cos(t + i.x));

    c := c + (1 / length(Vec2.Create(
                           system.sin(i.x + t) / inten,
                           system.cos(i.y + t) / inten)));
  end;

  c      := c / MAX_ITER;

  Result := TColor32(c * vec3_1);
end;

initialization

WaterTurbulence3 := TWaterTurbulence3.Create;
Shaders.Add('WaterTurbulence3', WaterTurbulence3);

finalization

FreeandNil(WaterTurbulence3);

end.
