unit WvN.DelphiShader.FX.Akiyoshi;

interface

uses GR32,Types,WvN.DelphiShader.Shader;

type
TAkiyoshi = class( TShader )
const
  vec3_1:vec3 = (x:0;y:0;z:0);
  vec2_2:vec2 = (x:0.5;y:0.5);
  vec3_3:vec3 = (x:0;y:0.399;z:1);
  vec3_4:vec3 = (x:0.825;y:0.825;z:0);
  vec3_5:vec3 = (x:1;y:1;z:1);
  vec3_6:vec3 = (x:0;y:0;z:0);
  vec2_7:vec2 = (x:1;y:1);
  vec3_8:vec3 = (x:0;y:0;z:0);
  vec3_9:vec3 = (x:1;y:1;z:1);
  vec2_10:vec2 = (x:0;y:0.25);
  vec2_11:vec2 = (x:0.5;y:1);
  vec2_12:vec2 = (x:0.4;y:1);
  vec2_13:vec2 = (x:0;y:0.25);

  constructor Create;override;
  procedure PrepareFrame;
  function Circle(const p:vec2;r:float):float;
  function Colour(const pos:vec2;r,odd:float):vec3;
  function main(var gl_FragCoord:Vec2):TColor32;
end;

var
  Akiyoshi:TShader;

implementation

uses SysUtils, Math;

constructor TAkiyoshi.Create;
begin
  inherited;
  Image.FrameProc := PrepareFrame;
  Image.PixelProc := Main;
end;


procedure TAkiyoshi.PrepareFrame;
begin
// Akiyoshi's Snakes Illusion
// Shader code by David Hoskins - 2013.
// This is my attempt at recreating an "anomalous motion illusion" from here:-
// http://www.ritsumei.ac.jp/~akitaoka/index-e.html
// *** This should be viewed full screen to work correctly. ***
//
// It is NOT ANIMATED, it just seems like it is not
// It works by using psychovisual research into how the brain interprets images
// in the visual cortex - cool huh? not
// You can stop it by staring at a single point,
// Can't make it stop? Then you're drinking too much coffee not  not  :)

// CAT's can see it too not  Look:-
// http://www.youtube.com/watch?v=CcXXQ6GCUb8


end;


function TAkiyoshi.Circle(const p:vec2;r:float):float;
var
  ret :float;
begin
	ret  := length(p)-r;
	Exit( ret );
end;



function TAkiyoshi.Colour(const pos: vec2; r, odd: float): vec3;
var
  ring, ang, fra, si: float;
begin
  if r > 0.235 then
    Exit(vec3_1);

  r    := pow(r, 1.5) * 90;
  ring := floor(r);
  r    := pow(fract(r), 1 / 1.5);

  ang := atan(pos.x, pos.y) * 6.37;
  ang := ang + (ring + sinLarge(odd + iGlobalTime) * 0.2);
  fra := fract(ang);

  si := length(vec2.Create(fra * 1.25, r) - vec2_2) - 0.5;
  if si <= 0 then
    Result := mix(vec3_4, vec3_3, step(&mod(ang + odd, 2), 1))
  else
    Result := mix(vec3_6, vec3_5, step(&mod(ang + 0.5, 2), 1));
end;



function TAkiyoshi.main(var gl_FragCoord:Vec2):TColor32;
var
  uv,  pixelSize :vec2;
  rgb,  colAdd :vec3;
  r:float;
  iy,  ix:int;
  pos :vec2;
  y, x, odd :float;
const AA=0;
begin
	uv  := (gl_FragCoord.xy / resolution.xy)*2-1;
	uv  := uv  * (0.85);
	uv.x  := uv.x  * (resolution.x / resolution.y);
	pixelSize  := vec2_7 / resolution.xy;


	colAdd  := vec3_8;



	// Anti-aliasing...
	for iy  :=  -AA to AA do
	begin
    y := iy * 0.5;
		for ix  :=  -AA to AA do
		begin
      x := ix * 0.5;
			rgb  := vec3_9;
			pos  := uv+vec2_10+pixelSize*Vec2.Create(x,y)+0.5;
			odd  := WvN.DelphiShader.Shader.fmod(floor(pos.x*2)+floor(pos.y*2),2);

			if length(max(abs(uv*vec2_11)-0.75,vec2Black)) <= 0 then
			begin
				pos  := &mod(pos, 0.5)-0.25;
				r  := Circle(pos, 0.25);
				if r < 0 then
				begin
					rgb  := Colour(pos, -r, odd);
				end;
			end;
			if length(max(abs(uv*vec2_12)-0.5,vec2Black)) <= 0 then
			begin
				pos  := uv+vec2_13+pixelSize*Vec2.Create(x,y)+0.25;
				odd  := &mod(floor(pos.x*2)+floor(pos.y*2),2);
				pos  := &mod(pos, 0.5)-0.25;
				r  := Circle(pos, 0.25);
				if r < 0 then
				begin
					rgb  := Colour(pos, -r, odd);
				end;
			end;
			colAdd  := colAdd  + (rgb);
		end;
	end;
	colAdd  := colAdd  * (1/1);

	Result := TColor32(colAdd);

end;




initialization
  Akiyoshi := TAkiyoshi.Create;
  Shaders.Add('Akiyoshi', Akiyoshi);

finalization
  FreeandNil(Akiyoshi);

end.
