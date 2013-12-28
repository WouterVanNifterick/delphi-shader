unit WvN.DelphiShader.FX.Circles;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
TCircles = class(TShader)
const
  vec3_1:vec3=(x:0.7;y:0.2;z:0.8);
  vec2_2:vec2=(x:0.30;y:0.70);
  vec2_3:vec2=(x:0.6;y:0.6);
  vec3_4:vec3=(x:0.7;y:0.9;z:0.6);
  vec2_5:vec2=(x:0.02;y:0.20);
  vec2_6:vec2=(x:0.1;y:0.1);
  vec3_7:vec3=(x:0.3;y:0.4;z:0.1);
  vec2_8:vec2=(x:0.10;y:0.04);
  vec2_9:vec2=(x:0.1;y:0.1);
  vec3_10:vec3=(x:0.2;y:0.5;z:0.1);
  vec2_11:vec2=(x:0.10;y:0.20);
  vec2_12:vec2=(x:0.3;y:0.3);
  vec3_13:vec3=(x:0.1;y:0.3;z:0.7);
  vec2_14:vec2=(x:0.40;y:0.25);
  vec2_15:vec2=(x:0.2;y:0.2);
  vec3_16:vec3=(x:0.9;y:0.4;z:0.2);
  vec2_17:vec2=(x:0.15;y:0.20);
  vec2_18:vec2=(x:0;y:0);
var
	pos  : vec2;
  aspect :float;
  color:vec3;
  c_ar: array[0..5] of vec2;
  function center ( const border , offset , vel :vec2 ):vec2;
  procedure circle ( index:integer; r :float;const col :vec3 );
  function Main(var gl_FragCoord: Vec2): TColor32;

  constructor Create; override;
  procedure PrepareFrame;
end;

var
  Circles: TShader;

implementation

uses SysUtils, Math;

constructor TCircles.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;

procedure TCircles.PrepareFrame;
const r_ar:array[0..5] of double=(0.03,0.05,0.07,0.10,0.20,0.30);
begin
  aspect := resolution.x / resolution.y;
  c_ar[0] := center( vec2.create( r_ar[0] / aspect , r_ar[0]  ) , vec2_3  , vec2_2 );  c_ar[0].x := c_ar[0].x * aspect;
  c_ar[1] := center( vec2.create( r_ar[1] / aspect , r_ar[1]  ) , vec2_6  , vec2_5 );  c_ar[1].x := c_ar[1].x * aspect;
  c_ar[2] := center( vec2.create( r_ar[2] / aspect , r_ar[2]  ) , vec2_9  , vec2_8 );  c_ar[2].x := c_ar[2].x * aspect;
  c_ar[3] := center( vec2.create( r_ar[3] / aspect , r_ar[3]  ) , vec2_12 , vec2_11);  c_ar[3].x := c_ar[3].x * aspect;
  c_ar[4] := center( vec2.create( r_ar[4] / aspect , r_ar[4]  ) , vec2_15 , vec2_14);  c_ar[4].x := c_ar[4].x * aspect;
  c_ar[5] := center( vec2.create( r_ar[5] / aspect , r_ar[5]  ) , vec2_18 , vec2_17);  c_ar[5].x := c_ar[5].x * aspect;

end;

function TCircles.center ( const border , offset , vel :vec2 ):vec2;
var
  c :vec2;
begin
	c  := offset + vel * time;
	c  := &mod ( c , 2 - 4 * border );
	if  c.x > 1 - border.x  then  c.x  := 2 - c.x - 2 * border.x;
	if  c.x <     border.x  then  c.x  := 2 * border.x - c.x;
	if  c.y > 1 - border.y  then  c.y  := 2 - c.y - 2 * border.y;
	if  c.y <     border.y  then  c.y  := 2 * border.y - c.y;
	Result := c;
end;


procedure TCircles.circle ( index:integer; r :float;const col :vec3 );
var
  c :vec2;
  d :float;
begin
	c  := c_ar[index];
	d  := distance ( pos , c );
	color  := color  + col * ( ifthen( d < r , 0.5 , max( 0.8 - min( pow ( d - r , 0.3 ) , 0.9 ) , -0.2 )) );
end;


function TCircles.Main(var gl_FragCoord: Vec2): TColor32;
begin
  color := vec3Black;
	pos  := gl_FragCoord.xy / resolution.y;

	circle (0, 0.03 , vec3_1  );
	circle (1, 0.05 , vec3_4  );
	circle (2, 0.07 , vec3_7  );
	circle (3, 0.10 , vec3_10 );
	circle (4, 0.20 , vec3_13 );
	circle (5, 0.30 , vec3_16 );

	Result := TColor32( color );

end;


initialization

Circles := TCircles.Create;
Shaders.Add('Circles', Circles);

finalization

FreeandNil(Circles);

end.

