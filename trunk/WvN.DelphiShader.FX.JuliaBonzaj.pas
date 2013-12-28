unit WvN.DelphiShader.FX.JuliaBonzaj;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TJuliaBonzaj=class(TShader)
  const
    V4_1000:Vec4=(x:1000;y:1000;z:1000;w:1000);
    Z_Init:Vec2=(x:0.6;y:0.3);
    c1:Vec3=(x:0.80;y:0.40;z:0.20);
    c2:Vec3=(x:0.12;y:0.70;z:0.60);
    c3:Vec3=(x:0.90;y:0.40;z:0.20);
  var
    cc:Vec2;
    constructor Create;override;
    procedure PrepareFrame;
    function RenderPixel(var gl_FragCoord:Vec2): TColor32;
  end;

var
  JuliaBonzaj:TShader;

implementation

uses SysUtils, Math;


const
  half:single=0.5;

constructor TJuliaBonzaj.Create;
begin
  inherited;
  FrameProc := prepareFrame;
  PixelProc := RenderPixel;
end;

procedure TJuliaBonzaj.PrepareFrame;
begin
  cc := 1.1*vec2.create( 0.5*system.cos(0.1*iGlobalTime) - 0.25*system.cos(0.2*iGlobalTime),
        	               0.5*system.sin(0.1*iGlobalTime) - 0.25*system.sin(0.2*iGlobalTime) );

end;


function TJuliaBonzaj.RenderPixel(var gl_FragCoord:Vec2): TColor32;
var
  p, z: Vec2;

  i : Integer;
  d,m2,dmin,color:TVecType;
begin
  p.x := -1.0 + 2.0 * gl_FragCoord.x / Resolution.x ;
  p.y := -1.0 + 2.0 * gl_FragCoord.y / Resolution.y ;


//	p := gl_FragCoord.xy / iResolution.xy + iMouse.xy/ iResolution.xy;
   dmin := 1000;
  z := (-1.0 + 1.0*p)*Z_Init;
  for i:=0 to 63 do
  begin
    z := cc + vec2.create( z.x * z.x - z.y * z.y, 2.0 * z.x * z.y );
		z := z + (0.15*system.sin(i));
    m2 := z.x * z.x + z.y * z.y;
    if m2 > 10.0 then
      break;

    dmin := Math.min(dmin, m2);
  end;
  d := round(dmin);
  Color  := system.sqrt(system.sqrt(dmin));

//  color := mix( color, c1,     min(1.0,pow(dmin*0.25,0.20)) );
//  color := mix( color, c2,     min(1.0,pow(dmin*0.50,0.50)) );
//	color := mix( color, c3, 1.0-min(1.0,pow(dmin*1.00,0.15) ));
//  color := color / 1000;
// color := 1.25*color*color;
//	color := color * (0.5 + 0.5*pow(4.0*p.x*(1.0-p.y)*p.y*(1.0-p.y),0.15));

  Result := HSLtoRGB(-iGlobalTime/30+Color*0.3,0.6,system.Sin(Color)){ MakeColor(Color,Color,Color)};
end;


initialization
  JuliaBonzaj := TJuliaBonzaj.Create;
  Shaders.Add('JuliaBonzaj',JuliaBonzaj);
finalization
  FreeandNil(JuliaBonzaj);
end.
