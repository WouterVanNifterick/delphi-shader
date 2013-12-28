unit WvN.DelphiShader.FX.FracTraps2;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
TFracTraps2 = class(TShader)
const
  vec3_1:vec3=(x:1.00;y:0.40;z:0.10);
  vec3_2:vec3=(x:0.35;y:0.25;z:1.00);
  vec3_3:vec3=(x:1.2;y:1.15;z:1);
  vec3_1000:vec3=(x:1000;y:1000;z:1000);
  zoom = 0.45;
  zoo = 1/zoom;
  offset:vec2 = (x:1;y:1.1);

  iterations = 5;
  minscale = 0.4;

  orbittraps  : Vec3=(x:3.0;y:2.0;z:1.0);
  trapswidths : Vec3=(x:1.5;y:1.0;z:0.5);

  trap1color : vec3=(x:1.00;y:0.40;z:0.10);
  trap2color : vec3=(x:0.35;y:0.25;z:1.00);
  trap3color : Vec3=(r:1;g:1;b:0.05);

  trapsbright : Vec3=(r:1.2;g:1.5;b:1);
  trapscontrast : vec3=(r:10;g:10;b:10);

  rotspeed = 0.2;

  saturation = 0.5;
  brightness = 2;
  contrast = 1.5;
  antialias = 2
  ; //max 4;

  var
  scale :double;// 1.3+iMouse.y/resolution.y;
  trans :double;// 0.75-iMouse.x/resolution.x;
  aspect:float;
  pixsize:vec2;

  function rotate( const p:vec2; angle:float ):vec2;
  function Main(var gl_FragCoord: Vec2): TColor32;

  constructor Create; override;
  procedure PrepareFrame;
end;

var
  FracTraps2: TShader;

implementation

uses SysUtils, Math;

constructor TFracTraps2.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
	aspect := resolution.x/resolution.y;
end;

procedure TFracTraps2.PrepareFrame;
begin
  scale := 1.3+iMouse.y/resolution.y;
  trans := 0.75-iMouse.x/resolution.x;
	pixsize := 1/resolution.xy*zoo;
	pixsize.x := pixsize.x * (aspect);
end;



function TFracTraps2.rotate( const p:vec2; angle:float ):vec2;
begin
  Exit( p*mat2.Create(
               system.cos(angle),
               system.sin(angle),
               -system.sin(angle),
               system.cos(angle)) );
end;


function TFracTraps2.Main(var gl_FragCoord: Vec2): TColor32;
var
  aacolor:vec3;
  uv:vec2;
  pos:vec2;
  av:float;
  its:vec3;
  t:float;
  otrap:vec3;
  aacoord:vec2;
  z:vec2;
  aa,i:integer; // loop variable
  l:float;
  ot:vec3;
  otcol1:vec3;
  otcol2:vec3;
  otcol3:vec3;
  color:vec3;

begin
	aacolor := vec3Black;
	uv := gl_FragCoord.xy / resolution.xy - 0.5;
	pos := uv;
	pos.x := pos.x * aspect;
	pos := pos + (offset);
	pos := pos * (zoo);
	av := 0;
	its := vec3Black;
	t := iGlobalTime*rotspeed;
  for aa := 0 to 15 do
  begin
		otrap := vec3_1000;
		if aa<antialias*antialias then
    begin
			aacoord := floor(Vec2.Create(aa/antialias,aa mod antialias));
			z := pos+aacoord*pixsize/antialias;
			for i := 0 to iterations do
      begin
				z := abs(z)-aspect*trans;
				z := rotate(z,-t+3.3);
				l := dot(z,z);
				z := z / (clamp(l,minscale,1));
				z := z*scale-1;
				ot := abs(vec3(l)-orbittraps);
				if ot.x<otrap.x then
        begin
					otrap.x := ot.x;
					its.x:=iterations-i;
				end;

				if ot.y<otrap.y then
        begin
					otrap.y := ot.y;
					its.y:=iterations-i;
				end;

				if ot.z<otrap.z then
        begin
					otrap.z := ot.z;
					its.z:=iterations-i;
				end;
			end;
		end;

		otrap := pow(max(vec3Black,trapswidths-otrap)/trapswidths,trapscontrast);
		its := its/iterations;
		otcol1 := otrap.x*pow(trap1color,3.5-vec3(its.x*3))*trapsbright.x;
		otcol2 := otrap.y*pow(trap2color,3.5-vec3(its.y*3))*trapsbright.y;
		otcol3 := otrap.z*pow(trap3color,3.5-vec3(its.z*3))*trapsbright.z;
		aacolor := aacolor + ((otcol1+otcol2+otcol3)/3);
	end;

	aacolor := aacolor/(antialias*antialias);
	color := mix(Vec3.Create(length(aacolor)),aacolor,saturation)*brightness;
	color :=pow(color,vec3(contrast));
	color := color * (vec3_3);
	color := color * (1-pow(max(0,math.max(abs(uv.x),abs(uv.y))-0.4)/0.1,8));
	Result  := TColor32(color);
end;

initialization

FracTraps2 := TFracTraps2.Create;
Shaders.Add('FracTraps2', FracTraps2);

finalization

FreeandNil(FracTraps2);

end.

