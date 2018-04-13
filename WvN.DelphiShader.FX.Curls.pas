unit WvN.DelphiShader.FX.Curls;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TCurls = class(TShader)
  const
    vec2_1: vec2 = (x: 0; y: 0);
    vec2_2: vec2 = (x: 0; y: 0);

  var
    m    : mat2;
    theta: float;
    function Main(var gl_FragCoord: vec2): TColor32;

    constructor Create; override;
    procedure PrepareFrame;
  end;

var
  Curls: TShader;

implementation

uses SysUtils, Math;

constructor TCurls.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
  theta     := pi / 0.1;
end;

procedure TCurls.PrepareFrame;
begin
  m := mat2.Create(System.cos(theta), -System.sin(theta), System.sin(theta), System.cos(theta));
end;

function TCurls.Main(var gl_FragCoord: vec2): TColor32;
var
  p   : vec2;
  f   : vec2;
  df  : float;
  dp  : float;
  from: float;
  &to : float;
  d   : float;
begin
  p    := (gl_FragCoord.xy / resolution.xy);
  time := time + atan(p.x, p.y) * 2;
  p    := p * 2 - 1;
  p.x  := p.x * (resolution.x / resolution.y);
  p    := m * p;
  f    := fract(p * 5);
  f    := 2 * f - 1;

  df     := distance(f, vec2_1);
  df     := 3 * df * df - 2 * df * df * df;
  dp     := max(1.5 - distance(p, vec2_2), 0);
  dp     := 3 * dp * dp - 2 * dp * df * df;
  from   := 0.3 + System.sin(dp * pi * 0.5 + time * 0.5) * 0.75;
  &to    := from + 2.00;
  d      := smoothstep(from, &to, df);
  Result := TColor32(vec3(d));
end;

initialization

Curls := TCurls.Create;
Shaders.Add('Curls', Curls);

finalization

FreeandNil(Curls);

end.
