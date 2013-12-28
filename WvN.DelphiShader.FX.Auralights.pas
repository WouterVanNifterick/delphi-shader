unit WvN.DelphiShader.FX.Auralights;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TAuralights = class(TShader)
    a:array[0..5] of vec2;
    const
      speed = 5.0;

    constructor Create; override;
    procedure PrepareFrame;
    function RenderPixel(var gl_FragCoord: Vec2): TColor32;

    function blob( const x:float;const y:float;i:integer ):float;
  end;

var
  Auralights: TShader;

implementation

uses SysUtils, Math;

constructor TAuralights.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := RenderPixel;
end;

function TAuralights.blob( const x:float;const y:float;i:integer ):float;
var xx :float; yy :float;
begin
   xx  := x+a[i].x;
   yy  := y+a[i].y;
   Result := 10.0/system.sqrt(xx*xx+yy*yy);
end;



procedure TAuralights.PrepareFrame;
begin
  a[0].x := system.sin(iGlobalTime*3.3/speed)*0.7;
  a[0].y := system.cos(iGlobalTime*3.2/speed)*0.7;

  a[1].x := system.sin(iGlobalTime*3.9/speed)*0.7;
  a[1].y := system.cos(iGlobalTime*3.0/speed)*0.7;

  a[2].x := system.sin(iGlobalTime*3.2/speed)*0.7;
  a[2].y := system.cos(iGlobalTime*2.9/speed)*0.7;

  a[3].x := system.sin(iGlobalTime*2.7/speed)*0.7;
  a[3].y := system.cos(iGlobalTime*2.7/speed)*0.7;

  a[4].x := system.sin(iGlobalTime*2.4/speed)*0.7;
  a[4].y := system.cos(iGlobalTime*3.3/speed)*0.7;

  a[5].x := system.sin(iGlobalTime*2.8/speed)*0.7;
  a[5].y := system.cos(iGlobalTime*2.3/speed)*0.7;
end;

function TAuralights.RenderPixel(var gl_FragCoord: Vec2): TColor32;
var position :vec2; x :float; y :float; d :vec3;
begin
   position  := ( gl_FragCoord / Resolution )-0.5;

   x  := position.x*2.0;
   y  := position.y*2.0;

   d.r := (blob(x,y,0) + blob(x,y,1))/60;
   d.g := (blob(x,y,2) + blob(x,y,3))/60;
   d.b := (blob(x,y,4) + blob(x,y,5))/60;

   Result := TColor32(d);
end;

initialization

Auralights := TAuralights.Create;
Shaders.Add('Auralights', Auralights);

finalization

FreeandNil(Auralights);

end.



