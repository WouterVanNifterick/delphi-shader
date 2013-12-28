unit WvN.DelphiShader.FX.SinusLines;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TSinusLines = class(TShader)
    constructor Create; override;
    procedure PrepareFrame;
    function RenderPixel(var gl_FragCoord: Vec2): TColor32;
  end;

var
  SinusLines: TShader;

implementation

uses SysUtils, Math;


constructor TSinusLines.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := RenderPixel;
end;

procedure TSinusLines.PrepareFrame;
begin
end;

function TSinusLines.RenderPixel(var gl_FragCoord: Vec2): TColor32;
var
 uPos:Vec2;color:vec3;
ftemp, vertColor:float;
  i: Integer;
begin
	uPos := ( gl_FragCoord.xy / resolution.xy ) - 0.5;//normalize wrt y axis
	//suPos -= vec2((resolution.x/resolution.y)/2.0, 0.0);//shift origin to center

	color := vec3Black;
	vertColor := 0;
  for i := 0 to 9 do
  begin
//		t := time * 0.9;
		uPos.y := uPos.y + (system.sin( uPos.x*(i+1) + time+i/5 ) * 0.1);
		fTemp := abs(1 / uPos.y / 190);
		vertColor := vertColor + fTemp;
		color := color + vec3.create( fTemp*(15-i)/10, fTemp*i/10, pow(fTemp,0.99)*1.5 );
  end;
	Result := TColor32(color);
end;

initialization

SinusLines := TSinusLines.Create;
Shaders.Add('SinusLines', SinusLines);

finalization

FreeandNil(SinusLines);

end.
