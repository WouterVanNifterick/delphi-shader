unit WvN.DelphiShader.FX.FlagNL;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TFlagNL = class(TShader)
  const
    cRed   : vec3 = (x: 1; y: 0.2; z: 0.2);
    cWhite : vec3 = (x: 1; y: 1; z: 1);
    cBlue  : vec3 = (x: 0.2; y: 0.2; z: 1.0);

    function Main(var gl_FragCoord: Vec2): TColor32;

    constructor Create; override;
    procedure PrepareFrame;
  end;

var
  FlagNL: TShader;

implementation

uses SysUtils, Math;

constructor TFlagNL.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;

procedure TFlagNL.PrepareFrame;
begin
end;

function TFlagNL.Main;
var
  p: Vec2;
  c: vec3;
begin
  p := (gl_FragCoord.xy / resolution.xy);
  if p.y < 0.3333333333333333333333 then
    c := cBlue
  else
    if (p.y < 0.666666666666666666666666) then
      c := cWhite
    else
      c    := cRed;
  Result := TColor32(c);
end;

initialization

FlagNL := TFlagNL.Create;
Shaders.Add('FlagNL', FlagNL);

finalization

FreeandNil(FlagNL);

end.
