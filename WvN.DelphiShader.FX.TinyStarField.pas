unit WvN.DelphiShader.FX.TinyStarField;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TTinyStarField = class(TShader)
  var
    st, ft: double;
    function Main(var gl_FragCoord: Vec2): TColor32;
    procedure PrepareFrame;
    constructor Create; override;
  end;

var
  TinyStarField: TShader;

implementation

uses SysUtils, Math;

constructor TTinyStarField.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;

procedure TTinyStarField.PrepareFrame;
begin
  // http://glsl.heroku.com/e#12158.0
  st := system.sin(time) * 0.01;
  ft := floor(time * 25) * 0.01;
end;

function TTinyStarField.Main(var gl_FragCoord: Vec2): TColor32;
var
  s, v, t, d,a: float;
  f, p      : vec3;
  i, j      : integer;
begin
  v := 0.001;
  t := 0.001;
  f := vec3.create(gl_FragCoord.x, gl_FragCoord.y, gl_FragCoord.y);

  for j := 0 to 99 do
  begin
    s := j * 0.01;
    p := s * f * t + vec3.Create(0.1, 0.2, fract(s + ft));

    for i := 0 to 7 do
    begin
      // p   := abs(p) / dot(p, p) - 0.8;
      d   := p.x * p.x + p.y * p.y + p.z * p.z;
      p.x := System.abs(p.x) / d - 0.8;
      p.y := System.abs(p.y) / d - 0.8;
      p.z := System.abs(p.z) / d - 0.8;
    end;

    v := v + dot(p, p) * t;
  end;

  a := 1.5 - 0.5 * length(st * gl_FragCoord.xy);
  if a<0 then
    exit(clBlack32);

  v := v * system.Sqrt(a);

  Result := TColor32(vec3.Create(v, v, v * 5));
end;

initialization

TinyStarField := TTinyStarField.Create;
Shaders.Add('TinyStarField', TinyStarField);

finalization

FreeandNil(TinyStarField);

end.
