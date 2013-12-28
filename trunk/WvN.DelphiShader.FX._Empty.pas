unit WvN.DelphiShader.FX._Empty;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TEmpty = class(TShader)
    constructor Create; override;
    procedure PrepareFrame;
    function RenderPixel(var gl_FragCoord: Vec2): TColor32;
  end;

var
  Empty: TShader;

implementation

uses SysUtils, Math;

constructor TEmpty.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := RenderPixel;
end;

procedure TEmpty.PrepareFrame;
begin
end;

function TEmpty.RenderPixel(var gl_FragCoord: Vec2): TColor32;
begin
  Result := clBlack32
end;

initialization

Empty := TEmpty.Create;
Shaders.Add('Empty', Empty);

finalization

FreeandNil(Empty);

end.
