unit WvN.DelphiShader.FX.WaterTurbulence;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TWaterTurbulence = class(TShader)
  const
    MAX_ITER     = 8;
    vec2_1: vec2 = (x: 15; y: 15);

    function Main(var gl_FragCoord: vec2): TColor32;

    constructor Create; override;
    procedure PrepareFrame;
  end;

var
  WaterTurbulence: TShader;

implementation

uses SysUtils, Math;

constructor TWaterTurbulence.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;

procedure TWaterTurbulence.PrepareFrame;
begin
end;

function TWaterTurbulence.Main(var gl_FragCoord: vec2): TColor32;
var
  p, i                 : vec2;
  c, inten             : float;
  n                    : integer;
  t                    : float;
  surfacePosition, m,q : vec2;
  c4                   : Double;

begin
  surfacePosition   := gl_FragCoord / Resolution;
  surfacePosition.x := surfacePosition.x * Resolution.x / Resolution.y;
  surfacePosition   := surfacePosition - 0.5;
  p     := surfacePosition * 3 - vec2_1;


  i     := p;
  c     := 1;
  inten := 0.05;
  for n := 1 to MAX_ITER do
  begin
    t   := time * (1 - (3 / n));
    m.x := system.cos(t - i.x) + system.sin(t + i.y);
    m.y := system.sin(t - i.y) + system.cos(t + i.x);
    i   := p + m;
    q.x := p.x / (2 * system.sin(i.x + t) / inten);
    q.y := p.y / (system.cos(i.y + t) / inten);
    c   := c + (1 / length(q));
  end;

  c      := c / MAX_ITER;
  c      := 1.5 - system.sqrt(pow(c, 3 + mouse.x * 0.5));
  c4     := c * c * c * c;
  Result := TColor32(Vec3.Create(c4 * 0.3, c4 * 0.5, c4 * 0.925));

end;

initialization

WaterTurbulence := TWaterTurbulence.Create;
Shaders.Add('WaterTurbulence', WaterTurbulence);

finalization

FreeandNil(WaterTurbulence);

end.
