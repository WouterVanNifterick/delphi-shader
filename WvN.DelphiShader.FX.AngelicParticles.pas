unit WvN.DelphiShader.FX.AngelicParticles;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TAngelicParticles=class(TShader)
  const
    vec12 :vec3=(x:1.2;y:1.2;z:1.2);
  var
    ray:Vec3;
    constructor Create;override;
    procedure PrepareFrame;
    function RenderPixel(var gl_FragCoord:Vec2): TColor32;
    const
  	  STEPS=30;
      VEC3_NUL:Vec3=(x:0;y:0;z:0);
  end;

var
  AngelicParticles:TShader;

implementation

uses SysUtils, Math;

// by srtuss, 2013
// did some research on kali's "comsos" and came up with this.
// as always, not optimized, just pretty :)
//
// name & inspiration was taken from here:
// http://www.youtube.com/watch?v=BzQmeeXcDwQ


function rotate(p:Vec2; a:float):Vec2;
begin
	Result := vec2.Create(p.x * system.cos(a) - p.y * system.sin(a),
                        p.x * system.sin(a) + p.y * system.cos(a));
end;


constructor TAngelicParticles.Create;
begin
  inherited;
  Image.FrameProc := prepareFrame;
  Image.PixelProc := RenderPixel;
end;

procedure TAngelicParticles.PrepareFrame;
begin
	ray.x := sinLarge(iGlobalTime * 0.10) * 0.2;
	ray.y := cosLarge(iGlobalTime * 0.13) * 0.2;
	ray.z := 1.5;

end;


function TAngelicParticles.RenderPixel(var gl_FragCoord:Vec2): TColor32;
var
  uv:Vec2;
  dp,v,it,br:Float;

  r,dir,acc,p,col:Vec3;
  inc:Float; i,j:Integer;
begin
	uv.x := 2 * gl_FragCoord.x/ Resolution.x - 1;
	uv.y := 2 * gl_FragCoord.y/ Resolution.y - 1;
 //	uv.x := uv.x * (iResolution.x / iResolution.y);

	v := 0;
  r := ray;
	dir := normalize(vec3.create(uv, 1.0));

	r.z := r.z + iGlobalTime * 0.1 - 20;
	dir.xz := rotate(dir.xz, sinLarge(iGlobalTime * 0.1) * 2);
	dir.xy := rotate(dir.xy, iGlobalTime * 0.2);

	// very little steps for the sake of a good framerate

	inc := 0.35 / STEPS;

	acc := VEC3_NUL;

  for j := 0 to STEPS-1 do
  begin
		p := r * 0.1;

		// do you like cubes?
		// p := floor(r * 20.0) / 20.0;

		// fractal from "cosmos"
    for I := 0 to 13 do
    begin
      dp := dot(p, p);
//  	p := (abs(p) / dot(p, p)) * 2.0 - 1.0;
    	p.x := (abs(p.x) / dp) * 2 - 1;
    	p.y := (abs(p.y) / dp) * 2 - 1;
    	p.z := (abs(p.z) / dp) * 2 - 1;
    end;

		it := 0.001 * length(p * p);
		v :=  v + it;

		// cheap coloring
		acc := acc + (System.sqrt(it) * texture2D(tex[2], r.xy * 0.1 + r.z * 0.1).xyz);

		r := r + (dir * inc);
  end;

	// old blueish colorset
  // Exit(Tcolor32(256*pow(vec3(v), 4.0 * vec3.create(0.9, 0.3, 0.1))));

	br  := pow(v * 4, 3) * 0.1;
	col := pow(acc * 0.3, vec12) + br;

	Result := TColor32(col*4);
end;


initialization
  AngelicParticles := TAngelicParticles.Create;
  Shaders.Add('AngelicParticles',AngelicParticles);
finalization
  FreeandNil(AngelicParticles);
end.
