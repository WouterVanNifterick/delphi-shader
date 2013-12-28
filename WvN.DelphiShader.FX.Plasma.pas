unit WvN.DelphiShader.FX.Plasma;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TPlasma=class(TShader)
    constructor Create;override;
    procedure PrepareFrame;
    function RenderPixel(var gl_FragCoord:Vec2): TColor32;
  end;

var
  Plasma:TShader;

implementation

uses SysUtils, Math;


const
  half:single=0.5;

constructor TPlasma.Create;
begin
  inherited;
  FrameProc := prepareFrame;
  PixelProc := RenderPixel;
end;

procedure TPlasma.PrepareFrame;
begin

end;


function TPlasma.RenderPixel(var gl_FragCoord:Vec2): TColor32;
var
  mov0, mov1, mov2, c1, c2, c3: TVecType;
begin
  mov0   := gl_FragCoord.x + gl_FragCoord.y + System.cos(System.sin(iGlobalTime) * 2) * 100. + System.sin(gl_FragCoord.x / 100) * 1000;
  mov1   := gl_FragCoord.y / Resolution.y / 0.2 + iGlobalTime;
  mov2   := gl_FragCoord.x / Resolution.x / 0.2;
  c1     := abs(System.sin(mov1 + iGlobalTime) / 2. + mov2 / 2. - mov1 - mov2 + iGlobalTime);
  c2     := abs(System.sin(c1 + System.sin(mov0 / 1000 + iGlobalTime) + System.sin(gl_FragCoord.y / 40 + iGlobalTime) + System.sin((gl_FragCoord.x + gl_FragCoord.y) / 100) * 3));
  c3     := abs(System.sin(c2 + System.cos(mov1 + mov2 + c2) + System.cos(mov2) + System.sin(gl_FragCoord.x / 1000)));
  Result := TColor32(vec4.Create(c1, c2, c3, 1));
end;


initialization
  Plasma := TPlasma.Create;
  Shaders.Add('Plasma',Plasma);

finalization
  FreeandNil(Plasma);
end.
