unit WvN.DelphiShader.FX.Fly;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TFly=class(TShader)
    an,san,can:Double;
    constructor Create;override;
    procedure PrepareFrame;
    function RenderPixel(var gl_FragCoord:Vec2): TColor32;
  end;

var
  Fly:TShader;

implementation

uses SysUtils, Math;


constructor TFly.Create;
begin
  inherited;
//  LoadTexture(tex0,'C:\Users\Wouter\Documents\RAD Studio\Projects\tex2.jpg');
  FrameProc := prepareFrame;
  PixelProc := RenderPixel;
end;

procedure TFly.PrepareFrame;
begin
  an := iGlobalTime * 0.25;
  san := system.sin(an);
  can := system.cos(an)
end;


function TFly.RenderPixel(var gl_FragCoord:Vec2): TColor32;
var
  p           : Vec2;
  uv          : vec2;
  lx, ly   : TVecType;

begin
  p.x := -1.0 + 2.0 * gl_FragCoord.x / Resolution.x;
  p.y := -1.0 + 2.0 * gl_FragCoord.y / Resolution.y;

  lx := p.x * can - p.y * san;
  ly := p.x * san + p.y * can;

  if ly=0 then
    Exit(clBlack32);

  uv.x := 0.25 * lx / System.abs(ly);
  uv.y := 0.20 * iGlobalTime + 0.25 / System.abs(ly);

  Result := TColor32(vec4.Create(texture2D(tex[0], uv).xyz * ly * ly,1));
end;


initialization
  Fly := TFly.Create;
  Shaders.Add('Fly',Fly);
finalization
  FreeandNil(Fly);
end.
