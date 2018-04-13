unit WvN.DelphiShader.FX.LeadLight;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TLeadLight=class(TShader)
    constructor Create;override;
    procedure PrepareFrame;
    function RenderPixel(var gl_FragCoord:Vec2): TColor32;
  end;

var
  LeadLight:TShader;

implementation

uses SysUtils, Math;


const
  half:single=0.5;

constructor TLeadLight.Create;
begin
  inherited;
  FrameProc := prepareFrame;
  PixelProc := RenderPixel;
end;

procedure TLeadLight.PrepareFrame;
begin
end;


function TLeadLight.RenderPixel(var gl_FragCoord:Vec2): TColor32;
var
  Position:Vec2;
  color:Vec3;
  r,a,t,light:Float;
  sl:Double;
begin
	position.x := gl_FragCoord.x / Resolution.x - 0.5;
	position.y := gl_FragCoord.y / Resolution.y - 0.5;

	r := length(position);
	a := atan(position.y, position.x);
	t := Time + 100/(r+1);

  light   := 15 * system.abs(0.05 * (sinLarge(t) + sinLarge(Time + a * 8)));
  sl := sinLarge(r + t);

  color.r := -sinLarge(r * 5 - a - Time + sl);
  color.g := sin(r * 3 + a - cosLarge(Time) + sl);
  color.b := cos(r + a * 2 + log(5.001 - (a / 4)) + Time) - sl;

//	Result := (normalize(color)+0.9) * light;
  Color := clamp(color,0,1);
	Result := TColor32((color+0.9) * light);
end;


initialization
  LeadLight := TLeadLight.Create;
  Shaders.Add('LeadLight',LeadLight);
finalization
  FreeandNil(LeadLight);
end.
