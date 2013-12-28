unit WvN.DelphiShader.FX.Pulse;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TPulse=class(TShader)
    cc:TPointF;
    constructor Create;override;
    procedure PrepareFrame;
    function RenderPixel(var gl_FragCoord:Vec2): TColor32;
  end;

var
  Pulse:TShader;

implementation

uses SysUtils, Math;

constructor TPulse.Create;
begin
  inherited;
//  LoadTexture(tex0,'c:\Users\Wouter\Downloads\x\02.jpg');
  FrameProc := prepareFrame;
  PixelProc := RenderPixel;
end;

procedure TPulse.PrepareFrame;
begin

end;


function TPulse.RenderPixel(var gl_FragCoord:Vec2): TColor32;
var
  HalfRes,cPos, uv:Vec2;
  col:Vec3;
  cLength:single;
begin
    halfres := Resolution.xy/2.0;

    cPos.x := gl_FragCoord.x - (0.5*halfres.x*system.sin(iGlobalTime/2.0)+0.3*halfres.x*system.cos(iGlobalTime)+halfres.x);
    cPos.y := gl_FragCoord.y - (0.4*halfres.y*system.sin(iGlobalTime/5.0)+0.3*halfres.y*system.cos(iGlobalTime)+halfres.y);
    cLength := Length(cPos);

    uv := gl_FragCoord/Resolution.xy+(cPos/cLength)*system.sin(cLength/30.0-iGlobalTime*10.0)/25.0;
    col := texture2D(tex[0],uv).xyz*50.0/cLength;

    Result := TColor32(col);
end;


initialization
  Pulse := TPulse.Create;
  Shaders.Add('Pulse',Pulse);
finalization
  FreeandNil(Pulse);
end.
