unit WvN.DelphiShader.FX.LeadLight;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TLeadLight=class(TShader)
    cc:TPointF;
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
  cc := PointF(
          system.cos(0.23 * system.cos(iGlobalTime * 0.03) * 50) / 1.6,
          system.sin(0.25 * iGlobalTime * 1.423) / 1.6
  );
end;


function TLeadLight.RenderPixel(var gl_FragCoord:Vec2): TColor32;
var
  Position:Vec2;
  color:Vec3;
  r,a,t,light:Float;
begin
	position.x := gl_FragCoord.x / Resolution.x - 0.5;
	position.y := gl_FragCoord.y / Resolution.y - 0.5;

	r := length(position);
	a := atan(position.y, position.x);
	t := Time + 100.0/(r+1.0);

  light   := 15.0 * system.abs(0.05 * (system.sin(t) + system.sin(Time + a * 8.0)));
  color.r := -system.sin(r * 5.0 - a - Time + system.sin(r + t));
  color.g := system.sin(r * 3.0 + a - system.cos(Time) + system.sin(r + t));
  color.b := system.cos(r + a * 2.0 + log(5.001 - (a / 4.0)) + Time) - system.sin(r + t);

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
