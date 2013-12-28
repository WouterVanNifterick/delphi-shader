unit WvN.DelphiShader.FX.Julia;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TJulia = class(TShader)
    cc: vec2;
    constructor Create; override;
    procedure PrepareFrame;
    function RenderPixel(var gl_FragCoord: Vec2): TColor32;
  end;

var
  Julia: TShader;

implementation

uses SysUtils, Math;

constructor TJulia.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := RenderPixel;
end;

procedure TJulia.PrepareFrame;
begin
  cc := Vec2.create(System.cos(0.23 * System.cos(iGlobalTime * 0.03) * 50) / 1.6, System.sin(0.25 * iGlobalTime * 1.423) / 1.6);
end;

function TJulia.RenderPixel(var gl_FragCoord: Vec2): TColor32;
var
  p, z           : vec2;
  Color, m2, dmin: TVecType;
  i              : Integer;
  zy2:double;
begin
  p.x := -1.0 + 2.0 * gl_FragCoord.x / Resolution.x;
  p.y := -1.0 + 2.0 * gl_FragCoord.y / Resolution.y;

  zy2 := 0;
  dmin  := 1000;
  z.x   := p.x;
  z.y   := p.y;
  for i := 0 to 31 do
  begin
    zy2 := zy2 * zy2;
    z  := cc + Vec2.create(z.x * z.x - z.y * z.y, 2 * z.x * z.y);
    m2 := z.x * z.x + z.y * z.y;
    if m2 > 10.0 then
      break;

    dmin := Math.min(dmin, m2);
  end;
  Color  := System.sqrt(System.sqrt(dmin));
  Result := TColor32(vec3(Color));
end;

initialization

Julia := TJulia.Create;
Shaders.Add('Julia', Julia);

finalization

FreeandNil(Julia);

end.
