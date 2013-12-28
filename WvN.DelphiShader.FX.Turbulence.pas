unit WvN.DelphiShader.FX.Turbulence;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TTurbulence = class(TShader)
  const
    MAX_ITER = 16;
  var
    pulse, pulse2, pulse3 : float;

    function Main(var gl_FragCoord: Vec2): TColor32;

    constructor Create; override;
    procedure PrepareFrame;
  end;

var
  Turbulence: TShader;

implementation

uses SysUtils, Math;

constructor TTurbulence.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;

procedure TTurbulence.PrepareFrame;
begin
  // water turbulence effect by joltz0r 2013-07-04, improved 2013-07-07
  // Altered

  pulse  := abs(system.sin(time * 5));
  pulse2 := pow(system.sin(time * 3), 0.25);
  pulse3 := pow(system.sin(time * 2), 2);
end;

function TTurbulence.Main(var gl_FragCoord: Vec2): TColor32;
var
  n                     : integer;
  c, t                  : float;
  p, i, surfacePosition : Vec2;
  l, ctix, stiy, stix, ctiy: double;
begin
  surfacePosition   := gl_FragCoord / Resolution;
  surfacePosition.x := surfacePosition.x * Resolution.x / Resolution.y;
  surfacePosition   := surfacePosition - 0.5;

  p := surfacePosition * 8;
  i := p;
  c := 2;

  for n := 1 to MAX_ITER do
  begin
    t    := time * (1 - 1/n);
    ctix := system.cos(t + i.x);
    stiy := system.sin(t + i.y);
    stix := system.sin(t + i.x);
    ctiy := system.cos(t + i.y);
    i    := p + Vec2.Create(system.cos(t - i.x) + stiy, system.sin(t - i.y) + ctix);
    if stix=0 then
      continue;

    if ctiy=0 then
      continue;

    l := length(Vec2.Create(p.x / stix, p.y / ctiy));
    if IsZero(l) then
      l := 1;
    c := c + 1 / l;
  end;

  c      := c / (MAX_ITER);

  Result := TColor32(Vec3.Create(pow(c, 1.5 + pulse / 2)) * Vec3.Create(1 + pulse2, 2 - pulse, 1.5 + pulse3) * (1 + pulse) / 2);
end;

initialization

Turbulence := TTurbulence.Create;
Shaders.Add('Turbulence', Turbulence);

finalization

FreeandNil(Turbulence);

end.
