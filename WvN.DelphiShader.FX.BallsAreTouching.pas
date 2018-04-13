unit WvN.DelphiShader.FX.BallsAreTouching;

interface

uses GR32, Types, WvN.DelphiShader.Shader;


const
  TRACE_STEPS = 256;
  TRACE_EPSILON = 0.001;
  REFLECT_EPSILON = 0.1;
  TRACE_DISTANCE= 30;
  NORMAL_EPSILON =0.01;
  REFLECT_DEPTH =4;
  NUM_BALLS= 7;
//  CUBEMAP_SIZE =128;

type
  TBallsAreTouching=class(TShader)
  public const
    	e:vec2=(x:0; y:NORMAL_EPSILON);
      e_yxx:vec3 =(x:NORMAL_EPSILON; y:0; z:0);
      e_xyx:vec3 =(x:0; y:NORMAL_EPSILON; z:0);
      e_xxy:vec3 =(x:0; y:0; z:NORMAL_EPSILON);
  var

    t:Double;
    p:vec3;
    balls:array[0..pred(NUM_BALLS)] of Vec3;
    function touching_balls(const at:vec3):TVecType;
    procedure UpdateBalls;
    function World(const at:Vec3):TVecType;
    function raymarch(const pos,dir:Vec3; maxL:TVecType):vec4 ;
    function cube(v:vec3):Vec3;
    function normal(const at:vec3):vec3;
    constructor Create;override;
    procedure PrepareFrame;
    function RenderPixel(var gl_FragCoord:Vec2): TColor32;
  end;

var
  BallsAreTouching:TShader;

implementation

uses SysUtils, Math;


constructor TBallsAreTouching.Create;
begin
  inherited;
  Image.FrameProc := prepareFrame;
  Image.PixelProc := RenderPixel;
end;

// http://the-witness.net/news/2012/02/seamless-cube-map-filtering/
function TBallsAreTouching.cube(v: vec3): Vec3;
var M,scale:Float;
begin
   M := Math.Max(Math.Max(System.abs(v.x), System.abs(v.y)), System.abs(v.z));
   scale := (TShader.cubes[4].Faces[POSITIVE_X].Width - 1) /
             TShader.cubes[4].Faces[POSITIVE_X].Width;
   if (System.abs(v.x) <> M) then v.x := v.x * scale;
   if (System.abs(v.y) <> M) then v.y := v.y * scale;
   if (System.abs(v.z) <> M) then v.z := v.z * scale;

   Result := textureCube(TShader.cubes[4], v).rgb;
end;




procedure TBallsAreTouching.PrepareFrame;
begin
  t := iGlobalTime * 0.11;
  p:= Vec3.Create(
           system.cos(2 + 4 * system.cos(t)) * 10,
           2 + 8 * system.cos(t * 0.8),
           10 * system.sin(2 + 3 * system.cos(t))
         );

  UpdateBalls;
end;

function TBallsAreTouching.raymarch(const pos, dir: Vec3; maxL: TVecType): vec4;
var i:integer;l,d:Float;
begin
	l := 0;
  for I := 0 to TRACE_STEPS-1 do
  begin
		d := world(pos + dir * l);
		if (d < TRACE_EPSILON*l) then
      break;
		l := l + d;
		if l > maxL then
      break;
  end;
	Result := vec4.Create(pos + dir * l, l);
end;

function lookAtDir(const dir,Pos,at:Vec3):vec3;
var f,r,u:Vec3;
const v:Vec3=(x:0;y:1;z:0);
begin
	f := normalize(at - pos);
	r := cross(f, v);
	u := cross(r, f);
	Result := normalize(dir.x * r + dir.y * u + dir.z * f);
end;


function TBallsAreTouching.touching_balls(const at:vec3):TVecType;
var sum:float;i:Integer;r:Float;
begin
	sum := 0;
  for I := Low(balls) to High(Balls) do
  begin
		r := length(balls[i] - at);
		sum := sum + (1 / (r * r));
  end;

	Result := 1 - sum;
end;


procedure TBallsAreTouching.UpdateBalls;
var i:Integer;
begin
  for I := Low(balls) to High(Balls) do
  begin
		balls[i] := 3 * vec3.create(
			system.sin(0.3+(i+1)*t),
			system.cos(1.7+(i-5)*t),
			1.1*system.sin(2.3+(i+7)*t)
      );
  end;
end;

function TBallsAreTouching.World(const at: Vec3): TVecType;
begin
  Result := touching_balls(at)
end;

function TBallsAreTouching.normal(const at:vec3):vec3;
begin
	Result := normalize(vec3.create(world(at+e_yxx)-world(at),
						world(at+e_xyx)-world(at),
						world(at+e_xxy)-world(at)));
end;

function TBallsAreTouching.RenderPixel(var gl_FragCoord:Vec2): TColor32;
var
  uv : Vec2;
  pos,dir,color:Vec3;
  tpos:Vec4;

  k:TVecType;
  reflections:Integer;
begin
  uv.x := -1.0 + 2.0 * gl_FragCoord.x / Resolution.x ;
  uv.y := -1.0 + 2.0 * gl_FragCoord.y / Resolution.y ;

  pos := p;
  dir := lookAtDir(normalize(Vec3.Create(uv, 2)), pos, balls[0]);

	color := vec3Black;
	k := 1;
  for reflections := 0 to REFLECT_DEPTH-1 do
  begin
		tpos := raymarch(pos, dir, TRACE_DISTANCE);
		if (tpos.w >= TRACE_DISTANCE) then
    begin
			color := color + cube(dir);
			break;
    end;
		color := color + (k*0.1);
		k := k * 0.6;
		dir := normalize(reflect(dir, normal(tpos.xyz)));
		pos := tpos.xyz + dir * REFLECT_EPSILON;
  end;

	Result := TColor32(color);
end;


initialization
  BallsAreTouching := TBallsAreTouching.Create;
  Shaders.Add('BallsAreTouching',BallsAreTouching);
finalization
  FreeandNil(BallsAreTouching);
end.
