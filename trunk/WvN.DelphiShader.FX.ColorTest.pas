unit WvN.DelphiShader.FX.ColorTest;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
TColorTest = class(TShader)
  function Main(var gl_FragCoord: Vec2): TColor32;

  constructor Create; override;
  procedure PrepareFrame;
end;

var
  ColorTest: TShader;

implementation

uses SysUtils, Math;

constructor TColorTest.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;

procedure TColorTest.PrepareFrame;
begin
end;

function TColorTest.Main(var gl_FragCoord: Vec2): TColor32;
var
  uv :vec2;
  col:vec3;

begin
	uv  := gl_FragCoord.xy / resolution.xy;

	col.r  := WvN.DelphiShader.Shader.sqrt(mix(-0.20,2,dot(uv.x*2,uv.y*0.5)))+0.2;
	col.g  := WvN.DelphiShader.Shader.sqrt(mix(-0.20,2,dot(1-uv.y,1-uv.x)))+0.2;
	col.b  := WvN.DelphiShader.Shader.sqrt(mix(-0.20,2,dot(1-uv.x,uv.y)))+0.2;
	Result := TColor32(col);
end;

initialization

ColorTest := TColorTest.Create;
Shaders.Add('ColorTest', ColorTest);

finalization

FreeandNil(ColorTest);

end.

