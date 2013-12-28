unit WvN.DelphiShader.FX.ZInvert;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TZInvert = class(TShader)
    constructor Create; override;
    procedure PrepareFrame;
    function RenderPixel(var gl_FragCoord: Vec2): TColor32;
  end;

var
  ZInvert: TShader;

implementation

uses SysUtils, Math;

constructor TZInvert.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := RenderPixel;
end;

procedure TZInvert.PrepareFrame;
begin

end;

function TZInvert.RenderPixel(var gl_FragCoord: Vec2): TColor32;
var
  p, uv: Vec2;

  col : Vec4;
  a, r: Double;
begin
  p.x := -1.0 + 2.0 * gl_FragCoord.x / Resolution.x;
  p.y := -1.0 + 2.0 * gl_FragCoord.y / Resolution.y;

  a := arctan2(p.y, p.x);
  r := System.sqrt(dot(p, p));

  if r > 0 then
  begin
    uv.x := System.cos(0.6 + iGlobalTime) + System.cos(System.cos(1.2 + iGlobalTime) + a) / r;
    uv.y := System.cos(0.3 + iGlobalTime) + System.sin(System.cos(2.0 + iGlobalTime) + a) / r;
  end;

  col := texture2D(tex[0], uv * 0.25);

  Result := TColor32(Vec4(col * r * r));
end;

initialization

ZInvert := TZInvert.Create;
Shaders.Add('ZInvert', ZInvert);

finalization

FreeandNil(ZInvert);

end.
