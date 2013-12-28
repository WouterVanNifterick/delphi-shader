unit WvN.DelphiShader.FX.FollowMouse;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type

TFollowMouse = class(TShader)
  constructor Create; override;
  procedure PrepareFrame;
  function RenderPixel(var gl_FragCoord: Vec2): TColor32;
end;

var
FollowMouse: TShader;

implementation

uses SysUtils, Math;

constructor TFollowMouse.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := RenderPixel;
end;

procedure TFollowMouse.PrepareFrame;
begin
end;

function maru( const pos:vec2;const me:vec2 ):float;
var dist :float; intensity :float; color :float;
begin
	dist  := length(pos - me);
  if dist=0 then
    Exit(0);

	intensity  := pow(10.0/dist, 2.0);
	color  := 0.0001;
	Result := color*intensity;
end;


function TFollowMouse.RenderPixel(var gl_FragCoord: Vec2): TColor32;
var texPos :vec2;
begin
	texPos := vec2(gl_FragCoord.xy/resolution);
	Result := TColor32(Vec3(maru(mouse.XY,texPos)));
end;


initialization

FollowMouse := TFollowMouse.Create;
Shaders.Add('FollowMouse', FollowMouse);

finalization

FreeandNil(FollowMouse);

end.

