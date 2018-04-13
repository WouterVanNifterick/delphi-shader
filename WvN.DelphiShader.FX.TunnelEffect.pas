unit WvN.DelphiShader.FX.TunnelEffect;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TTunnelEffect = class(TShader)
    cameraPinch :float; cameraZPinch :float; cameraZFactor :float; zoomFactor :float;
    texCoordUScale :float; texCoordVScale :float;
    texCoordUMoveSpeed :float; texCoordVMoveSpeed :float;
    cameraRotationSpeed :float; tunnelPinch :float; spikeCount :float; spikeFactor :float;
    fogColor :vec3; fogPower :float;
    camAng :float;
    cx :vec3; cy :vec3; cz :vec3;
    cameraRot:Mat3;
    Texture:array[0..7,0..7] of vec3;
    constructor Create; override;
    procedure PrepareFrame;
    function RenderPixel(var gl_FragCoord: Vec2): TColor32;
  end;

var
  TunnelEffect: TShader;


implementation

uses SysUtils, Math;

constructor TTunnelEffect.Create;
var x,y:integer;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := RenderPixel;
  for x := low(Texture) to high(Texture) do
    for y := low(Texture[x]) to high(Texture[x]) do
      Texture[x,y] := Vec3(random*1);
end;

procedure TTunnelEffect.PrepareFrame;
const
  scale=8;
begin
	texCoordUScale  := 0.125*scale;
	texCoordVScale  := 1.0*scale;

	texCoordUMoveSpeed  := 0.20*scale;
	texCoordVMoveSpeed  := -0.125*scale;

	cameraPinch  := 1.0;
	cameraZPinch  := 1.0;
	cameraZFactor  := 1.0;
	zoomFactor  := 1.0;
	cameraRotationSpeed  := 0.5;

	tunnelPinch  := 2;

	spikeCount  := 5;

	spikeFactor  := System.sin(iGlobalTime) * 0.1;

	fogColor  := vec3Black;
	fogPower  := 5;

	// camera angles
	camAng  := iGlobalTime * cameraRotationSpeed;

	// camera rotation vectors
	cx  := Vec3.Create(System.cos(camAng),0.0,-System.sin(camAng));
	cy  := Vec3.Create(0,1,0);
	cz  := Vec3.Create(System.sin(camAng),0.0,System.cos(camAng));

	cameraRot :=
		mat3.Create(
			cx.x, cx.y, cx.z,
			cy.x, cy.y, cy.z,
			cz.x, cz.y, cz.z);

end;

function TTunnelEffect.RenderPixel(var gl_FragCoord: Vec2): TColor32;
var coord :vec2; aspectRatio :float; cameraDir :vec3; angle :float; cameraOrigin :vec3; l :float; d :float; hitPos :vec3; uv :vec2; color :vec3; alpha :float;

begin
  coord  := 2 * ((gl_FragCoord.xy / Resolution.xy) - Vec2.Create(0.5,0.5));
	aspectRatio  := Resolution.x / Resolution.y;
	coord.x  := coord.x  * (aspectRatio);
	coord  := coord  * (zoomFactor);

	coord  := Vec2.Create(Math.sign(coord.x) * pow(System.abs(coord.x), cameraPinch), Math.sign(coord.y) * pow(System.abs(coord.y),cameraPinch));

	cameraDir  := normalize(Vec3.Create(
                            System.sin(coord.x),
                            System.sin(coord.y),
                            System.cos(coord.x) * System.cos(coord.y)));
	cameraDir  := cameraRot * cameraDir;

	angle  := atan(cameraDir.x, cameraDir.y);
	cameraDir.z  := cameraDir.z  * (1 + System.sin(angle * spikeCount) * spikeFactor);
  cameraDir.z  := cameraZFactor * Math.sign(cameraDir.z) * pow(System.abs(cameraDir.z), cameraZPinch);

	cameraOrigin  := vec3Black;


	l  := System.sqrt(pow(cameraDir.x * cameraDir.x, tunnelPinch) + pow(cameraDir.y * cameraDir.y, tunnelPinch));
  assert(l<>0,'l is used to divide, and it is 0 now');
	d  := 1.0 / l;

	hitPos  := cameraOrigin + cameraDir * d;

	uv  := Vec2.Create(hitPos.z,angle / pi);
	uv.x  := uv.x * texCoordUScale + iGlobalTime * texCoordUMoveSpeed;
	uv.y  := uv.y * texCoordVScale + iGlobalTime * texCoordVMoveSpeed;

//	color  := texture2D(tex1, uv).xyz;
  color := texture[round(System.Abs(uv.x)) mod 8,(8+round(System.Abs(uv.y))) mod 8];

	alpha  := 1 - pow(math.min(1, System.abs(cameraDir.z)), fogPower);

	color  := fogColor * (1 - alpha) + color * alpha;
	Result  := TColor32(color);
end;


initialization

TunnelEffect := TTunnelEffect.Create;
Shaders.Add('TunnelEffect', TunnelEffect);

finalization

FreeandNil(TunnelEffect);

end.
