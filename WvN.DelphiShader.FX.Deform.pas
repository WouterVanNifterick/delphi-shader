unit WvN.DelphiShader.FX.Deform;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TDeform=class(TShader)
    cc:TPointF;
    constructor Create;override;
    procedure PrepareFrame;
    function RenderPixel(var gl_FragCoord:Vec2): TColor32;
  end;

var
  Deform:TShader;

implementation

uses SysUtils, Math;


const
  half:single=0.5;

constructor TDeform.Create;
begin
  inherited;
  FrameProc := prepareFrame;
  PixelProc := RenderPixel;
end;

procedure TDeform.PrepareFrame;
begin
end;


function TDeform.RenderPixel(var gl_FragCoord:Vec2): TColor32;
var
  p, m, uv       : Vec2;
  a1,r1,a2,r2, w:TVecType;
  col:Vec3;
begin
  p := -1 + 2 * gl_FragCoord / Resolution;
  m := -1.0 + 2.0 * iMouse.XY / Resolution;

  a1 := arctan2(p.y-m.y,p.x-m.x);
  r1 := System.sqrt(dot(p-m,p-m));
  a2 := arctan2(p.y+m.y,p.x+m.x);
  r2 := System.sqrt(dot(p+m,p+m));

  uv.x := 0.2*iGlobalTime + (r1-r2)*0.25;
  uv.y := System.sin(2.0*(a1-a2));

  w := r1*r2*0.8;
  col := texture2D(tex[0],uv).xyz;
  Result := TColor32(col/(0.1+w));
end;


initialization
  Deform := TDeform.Create;
  Shaders.Add('Deform',Deform);
finalization
  FreeandNil(Deform);
end.
