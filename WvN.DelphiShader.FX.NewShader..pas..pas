unit WvN.DelphiShader.FX.NewShader;

interface

uses GR32,Types,WvN.DelphiShader.Shader;

type
TNewShader = class(TShader)
const
     vec3_1:vec3 = (x:0;y:0;z:0);


  constructor  Create;override;
  procedure  PrepareFrame;
  procedure  main;
end;

var
       NewShader:TShader
;

implementation

uses SysUtils, Math;

constructor TNewShader.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;


procedure TNewShader.PrepareFrame;
begin
end;


function TNewShader.Main(var gl_FragCoord: Vec2): TColor32;var
     offset:float;
 uv :vec2;
 s, v, speed2, speed :float;
 col, init :vec3;
 r :int;
 p :vec3;
 i:int;
begin
// from Mr Hoskins ST;
	offset := 0;
uv  := gl_FragCoord.xy / resolution.xy *2-1;
    s  := 0;
    v  := 0;
        offset  := time*time/200;
	speed2  := (cos(offset)+1)*2;
	speed  := speed2+0.1;
	offset  := offset  + (sin(offset)*0.96);
	offset  := offset  * (2);
 	col  := vec3_1;
    init  := Vec3.Create(sin(offset * 0.002)*0.3,0.35 + cos(offset * 0.005)*0.3,offset * 0.2);
	for r  :=  0 to 89 do 
	begin
		p  := init + s * vec3(uv, 0.05);
		p.z  := fract(p.z);
        // Thanks to Kali's little chaotic loop...
		for i := 0 to 8 do  - 0.9;
		v  := v  + (pow(dot(p, p), 0.7) * 0.06);
		col  := col  + (Vec3.Create(v * 0.2+0.4,12-s*2,0.1 + v * 1) * v * 0.00003);
		s  := s  + (0.025);
	end;
	Result  := vec4.Create(clamp(col,0,1),1);
end;




initialization
  NewShader := TNewShader.Create;
  Shaders.Add('NewShader', NewShader);

finalization
  FreeandNil(NewShader);

end.
