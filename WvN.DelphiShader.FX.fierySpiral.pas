unit WvN.DelphiShader.FX.fierySpiral;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
TfierySpiral = class(TShader)

type
  TMapRec=record
    turn_sub: double;
    radius: double;
    pr: Double;
    pr_01:double;
    pc : double;
  end;

  const M_TAU= 2*pi;
  const
    c:array[0..4] of vec3=(
  (x:1;y:1;z:1),
  (x:0;y:0;z:0),
  (x:1;y:0;z:0),
  (x:1;y:0.5;z:0),
  (x:1;y:1;z:0));
  var
   k_sine :float;
   rotation :float;
   map : array of array of TMapRec;

  function Main(var gl_FragCoord: Vec2): TColor32;

  constructor Create; override;
  procedure PrepareFrame;
end;

var
  fierySpiral: TShader;

implementation

uses SysUtils, Math;

constructor TfierySpiral.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;

procedure TfierySpiral.PrepareFrame;
var x,y:integer;
  p: Vec2;
  turn: Float;
  turn_rot: Float;
  n_sub: int;
  angle: Float;

begin
	rotation  := 0.04 * M_TAU * iGlobalTime;
  if system.length(map)<>Image.Bitmap.Width then
  begin
    SetLength(map,image.Bitmap.width,Image.Bitmap.Height);
    for y := 0 to high(map) do
      for x := 0 to High(map[0]) do
      begin
        p.x := 2 * (x - 0.5 * resolution.x) / resolution.x;
        p.y := 2 * (y - 0.5 * resolution.y) / resolution.x;
        angle := atan(-p.y, -p.x);
        turn := (angle + pi) / M_TAU;
        map[x,y].radius := system.sqrt(p.x * p.x + p.y * p.y);
        turn_rot := turn + rotation;
        n_sub := 2;
        map[x,y].turn_sub := &mod(n_sub * turn_rot, n_sub);
        map[x,y].pr_01 := pow(map[x,y].radius, 0.1);
        map[x,y].pr := pow(map[x,y].radius, 0.6);
        map[x,y].pc := 1-pow(map[x,y].radius*0.8, 2)

      end;
  end;
	k_sine  := 0.1 * system.sin(3 * iGlobalTime);

end;


function TfierySpiral.Main(var gl_FragCoord: Vec2): TColor32;
var
  x,y:integer;
  sine :float;
  pr:float;
  turn_sine :float;
  n_colors :int;
  i_turn :int;
  i_radius :int;
  i_color :int;
  color:vec3;

begin
  x := trunc(gl_FragCoord.x);
  y := trunc(gl_FragCoord.y);
	sine  := k_sine * system.sin(50 * (map[x,y].pr_01 - 0.4 * iGlobalTime));
	turn_sine  := map[x,y].turn_sub + sine;

	n_colors  := 5;
	i_turn  := trunc(&mod(n_colors * turn_sine, n_colors));

  pr := map[x,y].pr;
  if pr=0 then
    i_Radius := 0
  else
  	i_radius  := trunc(1.5/pr + 5 * iGlobalTime);

	i_color  := trunc(&mod(i_turn + i_radius, n_colors));
  color := c[i_color];
	color  := color  * map[x,y].pc;
	Result  := TColor32(color);
end;





initialization

fierySpiral := TfierySpiral.Create;
Shaders.Add('fierySpiral', fierySpiral);

finalization

FreeandNil(fierySpiral);

end.

