unit WvN.DelphiShader.FX.Rosace;

interface

uses GR32,Types,WvN.DelphiShader.Shader;

type
TRosace = class(TShader)
const
     vec4_1:vec4 = (x:0;y:2.1;z:-2.1;w:0);

  var c:double;
  constructor  Create;override;
  procedure  PrepareFrame;
  function mainImage(var U :vec2):TColor32;
end;

var
       Rosace:TShader
;

implementation

uses SysUtils, Math;

constructor TRosace.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := mainImage;
  c := now;
end;


procedure TRosace.PrepareFrame;
begin
end;


function TRosace.mainImage(var U :vec2):TColor32;
var
     h :float;
 K :vec2;
 a, r, v, A_:float;
 i:int;
begin
  // https://www.shadertoy.com/view/Ms3SzB
    h  := Resolution.y;
    U := 4*(U+iMouse.xy)/h;                    // normalized coordinates
    K  := ceil(U);
    U := 2*fract(U)-1;  // or K := 1.+2.* floor(U) to avoid non-fractionals
    a  := arctan2(U.y,U.x);
    r := length(U);
    v := 0;
    for i := 0 to 6 do
    begin
        // if fractional, there is K.y turns to close the loop via K.x wings.
        A_ := K.x/K.y*a + iGlobalTime;
//        A_ := &mod(A_,2*pi);
        v := max(v, ( 1 + 0.8* cosLarge(A_) ) / 1.8  // 1+cos(A) := depth-shading
                   * smoothstep(1, 1-120/h, 8*abs(r-0.2*sinLarge(A_)-0.5))); // ribbon (antialiased)
        a  := a  + 2*pi;
    end;

  Result := TColor32(v*(0.5+0.5*sin(K.x+17*K.y+c+vec4_1)));           // random colors
end;




initialization
  Rosace := TRosace.Create;
  Shaders.Add('Rosace', Rosace);

finalization
  FreeandNil(Rosace);

end.
