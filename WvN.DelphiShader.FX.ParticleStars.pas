unit WvN.DelphiShader.FX.ParticleStars;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
TParticle=record
  alpha:float;
  Threshold,
  period: Float;
  time,p,r:Float;
  color:Vec4;
  Speed:vec2;
  radius,
  angle_speed,
  angle_speed_time :Float;
  pos:vec2;

end;

TParticleStars = class(TShader)
const
  ParticleCount=16;
  vec2_1:vec2=(x:0;y:-0.3);
  vec2_2:vec2=(x:12.9898;y:78.233);
  BackgroundColor:vec4=(x:0;y:0;z:0;w:0.6);

  function rand( const co:vec2 ):float;overload;inline;
//  function rand(  from, &to:float;const co:vec2 ):float;overload;inline;
  function rand( r, from:float;const co:vec2 ):float;overload;inline;
  function Main(var gl_FragCoord: Vec2): TColor32;

var
  scale :float;
  gravity  :vec2;
  origin :vec2;
  particles:array[0..ParticleCount-1] of TParticle;

  constructor Create; override;
  procedure PrepareFrame;
end;

var
  ParticleStars: TShader;
implementation

uses SysUtils, Math;

constructor TParticleStars.Create;
var
  I: Integer;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;

  for I := 0 to ParticleCount-1 do
  begin
    Particles[i].p := rand(1,1.5, Vec2.Create(i,0));
    Particles[i].r := rand(Vec2.Create(i,1));
  end;
end;

procedure TParticleStars.PrepareFrame;
var i:integer;
  t: Double;
  index: Integer;
begin
  gravity   := vec2_1;
	scale  := 1/Math.max(resolution.x, resolution.y);
 	origin := Vec2.Create(0.5*resolution.x*scale,0);

  for I := 0 to ParticleCount-1 do
  begin
		Particles[i].period  := Particles[i].p;
		Particles[i].threshold  := 0.7*Particles[i].p;
		t  := time - Particles[i].period* Particles[i].r;
		Particles[i].time := &mod(t, Particles[i].period);
		index  := ceil(t/Particles[i].period);

		Particles[i].speed := Vec2.Create(
                  rand(1,-0.5, Vec2.Create(index*i,3)),
                  rand(0.5, 0.5, Vec2.Create(index*i,4))
                );

    Particles[i].color.r := rand(Vec2.Create(i*index, 4));
    Particles[i].color.g := rand(Vec2.Create(i*index, 5));
    Particles[i].color.b := rand(Vec2.Create(i*index, 6));
    Particles[i].color.w := 1;

 		Particles[i].angle_speed  := rand(8,-4, Vec2.Create(index*i,5));
		Particles[i].radius  := rand(0.04,0.01, Vec2.Create(index*i,2));

		if Particles[I].time > Particles[I].threshold then
			Particles[i].alpha  := 1 - (Particles[I].time - Particles[I].threshold)/(Particles[i].p - Particles[I].threshold)
		else
			Particles[i].alpha  := 1;

    Particles[i].pos := origin + particles[I].time * particles[I].Speed + gravity * particles[I].time * particles[I].time;
    Particles[i].angle_speed_time := Particles[i].angle_speed * Particles[i].time;
  end;
end;

// thank you for this function, anonymous person on the interwebs
// http://glslsandbox.com/e#19611.0
function TParticleStars.rand( const co:vec2 ):float;
begin
// 	Result := fract(System.sin(dot(co.xy, vec2_2))*43758.5453);
{$EXCESSPRECISION OFF}

  Result := Frac(system.sin(co.x * 12.9898 + co.y * 78.233)*43758.5453)
end;

function TParticleStars.rand( r, from:float;const co:vec2 ):float;
begin
	Result := from + rand(co) * r;
end;

function TParticleStars.Main(var gl_FragCoord: Vec2): TColor32;
var
  coord :vec2;
  i :integer;
  angle :float;
  dist :float;
begin
	scale  := 1/Math.max(resolution.x, resolution.y);
	coord  := gl_FragCoord.xy*scale;
	origin := Vec2.Create(0.5*resolution.x*scale,0);
	// Result := TColor32(BackgroundColor);

	for i  :=  0 to ParticleCount-1 do
  begin
    angle  := atan(particles[I].pos.y - coord.y,
                   particles[I].pos.x - coord.x) +
                   particles[I].angle_speed_time;
    dist   := particles[I].radius + 0.3 *
              system.sin(5 * angle) *
              particles[I].radius;

    Result := TColor32(
                      (particles[I].alpha * (1 - smoothstep(dist, dist + 0.01,
                       distance(coord, particles[I].pos))) *
                       particles[I].color));
    if Result > 0 then
      break;
  end;
end;


initialization

ParticleStars := TParticleStars.Create;
Shaders.Add('ParticleStars', ParticleStars);

finalization

FreeandNil(ParticleStars);

end.
