unit WvN.DelphiShader.FX.LeadLight2;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TLeadLight2 = class(TShader)
    position: Vec2;
    constructor Create; override;
    procedure PrepareFrame;
    procedure PrepareLine(y: Integer);
    function RenderPixel(var gl_FragCoord: Vec2): TColor32; inline;
  end;

var
  LeadLight2: TShader;

implementation

uses SysUtils, Math;

constructor TLeadLight2.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := RenderPixel;
  LineProc  := PrepareLine;
end;

procedure TLeadLight2.PrepareFrame;
begin
end;

procedure TLeadLight2.PrepareLine(y: Integer);
begin
  position.y := (y / Resolution.x) - 0.5;
end;

function TLeadLight2.RenderPixel(var gl_FragCoord: Vec2): TColor32;
var
  r, a, light: Double;
  color      : vec3;
  t          : Float;
  sl:double;
begin
  position.x := (gl_FragCoord.x / Resolution.x) - 0.5;

  r := length(position);
  a := atan(position.y, position.x);
  t := time + 50.0 / (r + 1.0);

  light   := 15.0 * System.abs(0.05 / (sinLarge(time + a * 8)));
  sl := sinLarge(r + t);
  color.x := -sinLarge(r * 5 - a - time + sl);
  color.y := System.sin(r * 3 + a - cosLarge(time) + sl);
  color.z := System.cos(r + a * 2 + log(5.001 - (a / 4)) - time) + sl;
  color.NormalizeSelf;
  Result  := TColor32((color + 0.9) * light);
end;

initialization

LeadLight2 := TLeadLight2.Create;
Shaders.Add('LeadLight2', LeadLight2);

finalization

FreeandNil(LeadLight2);

end.
