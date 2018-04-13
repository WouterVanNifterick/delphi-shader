unit WvN.DelphiShader.FX.FractTree2d;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TFractTree2d = class(TShader)
    function Main(var gl_FragCoord: Vec2): TColor32;

    constructor Create; override;
    procedure PrepareFrame;
  end;

var
  FractTree2d: TShader;

implementation

uses SysUtils, Math;

constructor TFractTree2d.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;

procedure TFractTree2d.PrepareFrame;
begin
  // http://glslsandbox.com/e#19513.1

end;

function TFractTree2d.Main(var gl_FragCoord: Vec2): TColor32;
var
  uv   : Vec2;
  scale: float;
  z    : Vec2;
  c    : Vec2;
  p    : float;
  i    : integer;
  rho  : float;
  arg  : float;
  pw, v: float;
begin
  uv    := gl_FragCoord.xy / resolution.xy;
  scale := resolution.y / resolution.x;
  uv    := ((uv - 0.5) * 5.5);
  uv.y  := uv.y * (scale);
  uv.y  := uv.y + (0);
  uv.x  := uv.x - (0.5);
  v := 0;

  z     := uv;
  p     := 0;
  for i := 0 to 60 - 1 do
  begin
    if System.abs(z.x) > 100000 then
      continue;
    if System.Abs(z.y) > 100000 then
      continue;
    if IsNan(z.x) then
      continue;
    if IsNan(z.y) then
      continue;

    rho := length(z);
    arg := atan(z.x, z.y);
    pw  := 2 * pow(System.sin(time / 5), 2) + 1;

    if (System.Abs(z.y) <= 0.2) and (System.Abs(z.x) <= 0.7) then
      break;

    // z  := Vec2.Create(System.Abs(z.x)/m,System.Abs(z.y)/m) + c;
    z := pow(rho, pw) * Vec2.Create(System.cos(pw * arg), System.sin(pw * arg)) + c;
    v := WvN.DelphiShader.Shader.fmod(i, 5) / 5;
    if i = 0 then
    begin
      v := 0;
      p := 1;
    end;
  end;

  Result := TColor32(vec4.Create(v, v, p, 1));
end;

initialization

FractTree2d := TFractTree2d.Create;
Shaders.Add('FractTree2d', FractTree2d);

finalization

FreeandNil(FractTree2d);

end.
