unit WvN.DelphiShader.FX.LensflareMusk;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
TLensflareMusk = class(TShader)
  function noise(  t:float ):float;  overload;
  function noise( const t:vec2 ):float; overload;
  function lensflare( const uv, pos:vec2 ):vec3;
  function cc( const color:vec3; factor, factor2:float ):vec3;
  function Main(var gl_FragCoord: Vec2): TColor32;

  constructor Create; override;
  procedure PrepareFrame;
end;

var
  LensflareMusk: TShader;

implementation

uses SysUtils, Math;

constructor TLensflareMusk.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;

procedure TLensflareMusk.PrepareFrame;
begin
end;

function TLensflareMusk.noise(  t:float ):float;
begin
	Exit( texture2D(tex[0],Vec2.Create(t,0.0)/vec2.create(tex[0].Width,tex[0].Height)).x/256 );
end;

function TLensflareMusk.noise( const t:vec2 ):float;
begin
	Exit( texture2D(tex[0],t/vec2.create(tex[0].Width,tex[0].Height)).x/256 );
end;


function TLensflareMusk.lensflare( const uv, pos:vec2 ):vec3;
var
  main :vec2;
  uvd :vec2;
  ang :float;
  dist :float;
//  n :float;
  f0 :float;
 // f1 :float;
  f2 :float;
  f22 :float;
  f23 :float;
  uvx :vec2;
  f4 :float;
  f42 :float;
  f43 :float;
  f5 :float;
  f52 :float;
  f53 :float;
  f6 :float;
  f62 :float;
  f63 :float;
  c :vec3;

begin
	main  := uv-pos;
	uvd  := uv*length(uv);

	ang  := atan(main.x,main.y);
	dist := length(main);
  dist  := pow(dist,0.1);
//	n  := noise(Vec2.Create(ang*16.0,dist*32.0));

	f0  := 1.0 / (length(uv-pos*16.0+1.0));

	f0  := f0+f0*(system.sin(noise(pos.x+pos.y*2.2+ang*4.0+5.954*16.0*0.1+dist*0.1+0.8)));

//	f1  := max(0.01-pow(length(uv+1.2*pos),1.9),0.0)*7.0;

	f2   := max(1.0-(1.0+32.0*pow(length(uvd+0.8*pos),2.0)),0.0)*00.25;
	f22  := max(1.0-(1.0+32.0*pow(length(uvd+0.85*pos),2.0)),0.0)*00.23;
	f23  := max(1.0-(1.0+32.0*pow(length(uvd+0.9*pos),2.0)),0.0)*00.21;

	uvx  := mix(uv,uvd,-0.5);

	f4   := max(0.01-pow(length(uvx+0.4*pos),2.4),0.0)*6.0;
	f42  := max(0.01-pow(length(uvx+0.45*pos),2.4),0.0)*5.0;
	f43  := max(0.01-pow(length(uvx+0.5*pos),2.4),0.0)*3.0;

	uvx  := mix(uv,uvd,-0.4);

	f5  := max(0.01-pow(length(uvx+0.2*pos),5.5),0.0)*2.0;
	f52  := max(0.01-pow(length(uvx+0.4*pos),5.5),0.0)*2.0;
	f53  := max(0.01-pow(length(uvx+0.6*pos),5.5),0.0)*2.0;

	uvx  := mix(uv,uvd,-0.5);

	f6   := max(0.01-pow(length(uvx-0.300*pos),1.6),0.0)*6.0;
	f62  := max(0.01-pow(length(uvx-0.325*pos),1.6),0.0)*3.0;
	f63  := max(0.01-pow(length(uvx-0.350*pos),1.6),0.0)*5.0;

	c  := vec3Black;

	c.r := c.r + (f2+f4+f5+f6);
  c.g := c.g + (f22+f42+f52+f62);
  c.b := c.b + (f23+f43+f53+f63);
	c  := c * 1.3 - vec3(length(uvd*0.05));
	c := c + vec3(f0);

	Exit( c );
end;


function TLensflareMusk.cc( const color:vec3; factor, factor2:float ):vec3; // color modifier
var
  w :float;
begin
	w  := color.x+color.y+color.z;
	Exit( mix(color,vec3(w)*factor,w*factor2) );
end;


function TLensflareMusk.Main(var gl_FragCoord: Vec2): TColor32;
var
  uv :vec2;
  mouse :vec3;
  color :vec3;
const
  col:vec3=(x:1.4;y:1.2;z:1);
begin
	uv  := gl_FragCoord.xy / resolution.xy - 0.5;
	uv.x  := uv.x  * (resolution.x/resolution.y);
	mouse  := vec3.create(iMouse.xy/resolution.xy - 0.5,iMouse.z-0.5);
	mouse.x  := mouse.x  * (resolution.x/resolution.y);
	if iMouse.z<0.5 then
	begin
		mouse.x := system.sin(iGlobalTime*0.5);
		mouse.y := system.sin(iGlobalTime*0.913*0.5);
	end;


	color  := col*lensflare(uv,mouse.xy);
	// color  := color  - noise(gl_FragCoord.xy*0.015);
	color  := cc(color,0.5,0.1);
	Result  := TColor32(color*2);
end;

initialization

LensflareMusk := TLensflareMusk.Create;
Shaders.Add('LensflareMusk', LensflareMusk);

finalization

FreeandNil(LensflareMusk);

end.

