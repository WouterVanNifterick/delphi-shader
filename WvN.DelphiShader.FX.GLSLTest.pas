unit WvN.DelphiShader.FX.GLSLTest;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TGLSLTest = class(TShader)
    constructor Create; override;
    procedure PrepareFrame;
    function main(var gl_FragCoord: Vec2): TColor32;
  end;

var
  GLSLTest: TShader;

implementation

uses SysUtils, Math;

constructor TGLSLTest.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := main;
end;

procedure TGLSLTest.PrepareFrame;
begin
end;

function TGLSLTest.main(var gl_FragCoord: Vec2): TColor32;
var
  uv        : Vec2;
  x, h, y, v: float;
  col       : vec3;
begin
  uv := 2 * (gl_FragCoord.xy / resolution.xy - 0.5);
  x  := uv.x;
  h  := 0.05;
  y  := -1 - h;
  v  := -1;

{00}  y  := y + (h);  if (uv.y > y) and (uv.y < y + h) then v := x;
{01}  y   := y + (h);  if (uv.y > y) and (uv.y < y + h) then v := -x;
{02}  y   := y + (h);  if (uv.y > y) and (uv.y < y + h) then v := x * 2;
{03}  y   := y + (h);  if (uv.y > y) and (uv.y < y + h) then v := abs(x);
{04}  y   := y + (h);  if (uv.y > y) and (uv.y < y + h) then v := Math.sign(x);
{05}  y   := y + (h);  if (uv.y > y) and (uv.y < y + h) then v := sqrts(x); // SQRT
{06}  y   := y + (h);  if (uv.y > y) and (uv.y < y + h) then v := pow(x, 1);
{07}  y   := y + (h);  if (uv.y > y) and (uv.y < y + h) then v := pow(x, 2);
{08}  y   := y + (h);  if (uv.y > y) and (uv.y < y + h) then v := exp(x) - 1;
{09}  y   := y + (h);  if (uv.y > y) and (uv.y < y + h) then v := exp2(x * 2) - 1;
{10}  y   := y + (h);  if (uv.y > y) and (uv.y < y + h) then v := WvN.DelphiShader.Shader.log(x * 5);
{11}  y   := y + (h);  if (uv.y > y) and (uv.y < y + h) then v := WvN.DelphiShader.Shader.log2(x * 5);
{12}  y   := y + (h);  if (uv.y > y) and (uv.y < y + h) then v := inversesqrt(x * 0.000005) * 0.001;
{13}  y   := y + (h);  if (uv.y > y) and (uv.y < y + h) then v := &mod(x, 0.5);
{14}  y   := y + (h);  if (uv.y > y) and (uv.y < y + h) then v := step(x, 0.5);
{15}  y   := y + (h);  if (uv.y > y) and (uv.y < y + h) then v := smoothstep(x, -0.5, 0.5) * 5;
{16}  y   := y + (h);  if (uv.y > y) and (uv.y < y + h) then v := floor(x * 2);
{17}  y   := y + (h);  if (uv.y > y) and (uv.y < y + h) then v := ceil(x * 2);
{18}  y   := y + (h);  if (uv.y > y) and (uv.y < y + h) then v := fract(x * 2);
{19}  y   := y + (h);  if (uv.y > y) and (uv.y < y + h) then v := sin(x * 2 * 3.14);
{20}  y   := y + (h);  if (uv.y > y) and (uv.y < y + h) then v := cos(x * 2 * 3.14);
{21}  y   := y + (h);  if (uv.y > y) and (uv.y < y + h) then v := tan(x * 2 * 3.14);
{22}  y   := y + (h);  if (uv.y > y) and (uv.y < y + h) then v := asin(x * 2 * 3.14);
{23}  y   := y + (h);  if (uv.y > y) and (uv.y < y + h) then v := acos(x * 2 * 3.14);
{24}  y   := y + (h);  if (uv.y > y) and (uv.y < y + h) then v := atan(x * 2 * 3.14);
{25}  y   := y + (h);  if (uv.y > y) and (uv.y < y + h) then v := pow(x, 1);
{26}  y   := y + (h);  if (uv.y > y) and (uv.y < y + h) then v := pow(x, 2);
{27}  y   := y + (h);  if (uv.y > y) and (uv.y < y + h) then v := pow(x, 3);
{28}  y   := y + (h);  if (uv.y > y) and (uv.y < y + h) then v := radians(x * 90);
{29}  y   := y + (h);  if (uv.y > y) and (uv.y < y + h) then v := degrees(x) / 30;
{30}  y   := y + (h);  if (uv.y > y) and (uv.y < y + h) then v := clamp(x, -0.5, 0.5);
{31}  y   := y + (h);  if (uv.y > y) and (uv.y < y + h) then v := mix(x, -0.2, 0.2);
{32}  y   := y + (h);  if (uv.y > y) and (uv.y < y + h) then v := dot(x, 2);
{33}  y   := y + (h);  if (uv.y > y) and (uv.y < y + h) then v := dot(x, -2);
{34}  y   := y + (h);  if (uv.y > y) and (uv.y < y + h) then v := length(x * 2);
{35}  y   := y + (h);  if (uv.y > y) and (uv.y < y + h) then v := length(-x * 2);
{36}  y   := y + (h);  if (uv.y > y) and (uv.y < y + h) then v := normalize(x);
{37}  y   := y + (h);  if (uv.y > y) and (uv.y < y + h) then v := faceforward(x, 0, 0);
{38}  y   := y + (h);  if (uv.y > y) and (uv.y < y + h) then v := reflect(x, 0);
{39}  y   := y + (h);  if (uv.y > y) and (uv.y < y + h) then v := distance(x, 0);

  // scale value range -1..1 to 0..1
  v   := 0.5 + v * 0.5;
  col := vec3(v);
  // show 0 x line
  if (abs(x) < 0.003) then
    col  := vec3Red;
  Result := TColor32(col);
end;

initialization

GLSLTest := TGLSLTest.Create;
Shaders.Add('GLSLTest', GLSLTest);

finalization

FreeandNil(GLSLTest);

end.
