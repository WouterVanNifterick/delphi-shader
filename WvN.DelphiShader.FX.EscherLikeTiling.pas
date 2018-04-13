unit WvN.DelphiShader.FX.EscherLikeTiling;

interface

uses GR32,Types,WvN.DelphiShader.Shader;

type
TEscherLikeTiling = class(TShader)
  constructor  Create;override;
  procedure  PrepareFrame;
  function  mainImage(var fragCoord:vec2):TColor32;
  function  mainImage(var fragCoord:vec2):TColor32;
end;

var
    EscherLikeTiling:TShader
;

implementation

uses SysUtils, Math;

constructor TEscherLikeTiling.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := mainImage;
end;


procedure TEscherLikeTiling.PrepareFrame;
begin
end;


function TEscherLikeTiling.mainImage(var fragCoord:vec2):TColor32;
var
  f = floor(U), u:vec2;
  b:float;
  i:int;
begin
	U  := U  * (12/resolution.y);
    O := O - (O);
    f := floor(U), u  := 2*fract(U)-1;
    // ceil cause line on some OS
    b  := &mod(f.x+f.y,2), y;
    for i := 0 to 3 do
        u *= mat2(0,-1,1,0),
        y := 2*fract(0.2*iDate.w+U.x*0.01)-1,
	    O  := O  + (smoothstep(0.55,0.45, length(u-Vec2.Create(0.5,1.5*y))));
    if b>0 then
     O  := 1-O;
   // try also without :-)
end;
{}
{ // shorter version: 212 chars
end;


function TEscherLikeTiling.mainImage(var fragCoord:vec2):TColor32;
var
  f = ceil(U := vec2 f = ceil(U * (12./resolution.y), u:vec2;
begin
    O := O - (O);
    f := ceil(U := vec2 f := ceil(U * (12./resolution.y), u  := 2.*fract(U)-1.);
#define q   u := u.yx, u.x*=-1., O += step(length( u - Vec2.Create(.5, 3.*fract(.2*iDate.w+U.x*.01)-1.5) ),.5)
    q;
   q;
   q;
   q;
    f.x+f.y,2.>0. ? O  := 1.-O : O;
     // golfed by 834144373
end;
{}
end;




initialization
  EscherLikeTiling := TEscherLikeTiling.Create;
  Shaders.Add('EscherLikeTiling', EscherLikeTiling);

finalization
  FreeandNil(EscherLikeTiling);

end.
