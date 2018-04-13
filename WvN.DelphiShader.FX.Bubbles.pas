unit WvN.DelphiShader.FX.Bubbles;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
TBubbles = class(TShader)
const
  vec3_1:vec3=(x:0;y:0;z:0);
  vec3_2:vec3=(x:0;y:0;z:0);
  vec3_3:vec3=(x:0;y:0;z:0);
var
  p:array[0..19] of vec3;

  radius_ar:array[0..2,0..19]of double;
  thickness_ar:array[0..2,0..19]of double;
  position_ar:array[0..2,0..19]of vec2;
  rt_ar:array[0..2,0..19]of double;
  r2t_ar:array[0..2,0..19]of double;
  function pos(  time:float ):float;
  function position(  time:float ):vec2;
  function Main(var gl_FragCoord: Vec2): TColor32;

  constructor Create; override;
  procedure PrepareFrame;
end;

var
  Bubbles: TShader;

implementation

uses SysUtils, Math;

constructor TBubbles.Create;
var i,b:integer;
begin
  inherited;
  Image.FrameProc := PrepareFrame;
  Image.PixelProc := Main;

  for b := 0 to 19 do
  begin
    p[b].x := 1+pos( b * 7 );
    p[b].y := 1+pos( b * 2 );
    p[b].z := 1+pos( b * 3 );
  end;

  for b := 0 to 19 do
  begin
    radius_ar[0,b]:=0.1 * (b + 10)/40;
    radius_ar[1,b]:=0.05 * (b + 10)/20;
    radius_ar[2,b]:=0.3 * (b + 10)/20;
    thickness_ar[0,b]:=0.002;
    thickness_ar[1,b]:=0.01 * (b*5+10)/10;
    thickness_ar[2,b]:=0.002{0.1};
  end;

  for i := 0 to 2 do
    for b := 0 to 19 do
    begin
      rt_ar[i,b]:=radius_ar[i,b]   +thickness_ar[i,b];
      r2t_ar[i,b]:=radius_ar[i,b]*2+thickness_ar[i,b];
    end;

end;

procedure TBubbles.PrepareFrame;
var i:integer;
begin
  for I := 0 to 19 do
  begin
    position_ar[0,I] := position(time+i*10);
    position_ar[1,I] := -position(23+time+i*17);
    position_ar[2,I] := -position(time/5+i*20);
  end;
end;

function TBubbles.position( time:float ):vec2;
begin
	time  := time  / (10);
	Result.x := (system.sin(time)-system.sin(time*3))/2;
  Result.y := (system.sin(time+22)-system.cos(time*3))/5;
end;

function TBubbles.pos( time:float ):float;
begin
	time  := time  / 10;
	Result := (system.sin(time)-system.sin(time*3))/2;
end;


function TBubbles.Main(var gl_FragCoord: Vec2): TColor32;
var
  uPos :vec2;
  i:integer;
  dist :float;
  color1 :vec3;
  color :float;
  color2 :vec3;
  color3 :vec3;
begin
	uPos  := gl_FragCoord.xy/resolution.y;
	uPos  := uPos  + (Vec2.Create(-resolution.x/resolution.y/2,-0.5));

	color1  := vec3_1;

	for i := 0 to 19 do
  begin
		dist  := distance(position_ar[0,I], uPos);
		color  := 1 - smoothstep(rt_ar[0,i], r2t_ar[0,i], dist) - smoothstep(rt_ar[0,i], radius_ar[0,i], dist)/1.2;
		color1  := color + color1  * p[i];
	end;


	color2  := vec3Black;
	for i := 0 to 19 do
  begin
		dist  := distance(position_ar[1,I], uPos);
		color  := 1 - smoothstep(rt_ar[1,i], r2t_ar[1,i], dist) - smoothstep(rt_ar[0,i], radius_ar[1,i], dist)/1.5;
		color2  := color + color2  * p[i];
	end;


	color3  := vec3_3;

	for i := 0 to 19 do
  begin
		dist  := distance(position_ar[2,I], uPos);
		color  := 1 - smoothstep(rt_ar[2,i], r2t_ar[2,i], dist) - smoothstep(rt_ar[0,i], radius_ar[2,i], dist)/1.5;
		color3  := color + color3  * p[i];
	end;


	Result := TColor32(color1 + color2/10 + color3/10 );
end;



initialization

Bubbles := TBubbles.Create;
Shaders.Add('Bubbles', Bubbles);

finalization

FreeandNil(Bubbles);

end.

