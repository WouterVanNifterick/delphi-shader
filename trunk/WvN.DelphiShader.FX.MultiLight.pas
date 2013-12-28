unit WvN.DelphiShader.FX.MultiLight;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TMultiLight = class(TShader)
    ViewDirection: vec3;
    screen_center: vec2;
    LightPosition: array [0 .. 2] of vec3;
    cursorPos: vec2;
    Sphere_radius: float;
    mov_radius: float;
    SpecularLightColor: array [0 .. 2] of vec3;
    DiffuseLightColor: array [0 .. 2] of vec3;

  const
    vec3_1: vec3  = (x: 0.0; y: 0.0; z: 0.5);
    vec3_2: vec3  = (x: 0.8; y: 0.5; z: 0.2);
    vec3_3: vec3  = (x: 0.5; y: 0.3; z: 0.3);
    vec3_4: vec3  = (x: 0.2; y: 0.2; z: 0.8);
    vec3_5: vec3  = (x: 0.3; y: 0.2; z: 0.5);
    vec3_6: vec3  = (x: 0.6; y: 0.8; z: 0.2);
    vec3_7: vec3  = (x: 0.2; y: 0.5; z: 0.3);
    vec3_8: vec3  = (x: 0.05; y: 0.2; z: 0.05);
    vec3_9: vec3  = (x: 0.0; y: 0.0; z: 0.0);
    vec3_10: vec3 = (x: 0.0; y: 0.0; z: - 1);

    function Main(var gl_FragCoord: vec2): TColor32;
    constructor Create; override;
    procedure PrepareFrame;
  end;

var
  MultiLight: TShader;

implementation

uses SysUtils, Math;

constructor TMultiLight.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;

end;

procedure TMultiLight.PrepareFrame;
begin
  Sphere_radius := Math.min(resolution.x, resolution.y) * 0.15;
  screen_center := resolution * 0.5;
  mov_radius    := Math.min(resolution.x, resolution.y) * 0.5;
  cursorPos     := imouse.xy ;

  LightPosition[0] := vec3.Create(cursorPos, Sphere_radius * 3);
  LightPosition[1] := vec3.Create(screen_center.x + system.cos(time * 1.020) * mov_radius, screen_center.y - system.cos(time * 1.020) * mov_radius, Sphere_radius * 8);
  LightPosition[2] := vec3.Create(screen_center.x - system.sin(time * 0.999) * mov_radius, screen_center.y + system.sin(time * 1.021) * mov_radius, Sphere_radius * (1 + system.cos(time)));


  DiffuseLightColor[0]  := vec3_2;
  SpecularLightColor[0] := vec3_3;

  DiffuseLightColor[1]  := vec3_4;
  SpecularLightColor[1] := vec3_5;

  DiffuseLightColor[2]  := vec3_6;
  SpecularLightColor[2] := vec3_7;

  ViewDirection := vec3_10;

end;

function TMultiLight.Main;
var
  AmbientLightColor : vec3;
  LightColor        : vec3;

  SurfaceNormal         : vec3;
  SurfacePosition       : vec3;
  Sphere_center         : vec3;
  tmpv2                 : vec2;
  dist_from_center      : float;
  surfaceZ              : float;
  DiffuseLightIntensity : float;
  SpecularLightIntensity: float;
  AmbientLightIntensity : float;
  LightDirection        : vec3;
  SpecularDirection     : vec3;
  i                     : integer; // loop variable
begin

  AmbientLightIntensity := 0;

  AmbientLightColor := vec3_8;
  LightColor        := vec3_9;

  // ***********************************************************/
  // * Geometry                                                */
  // ***********************************************************/

  Sphere_center.x := screen_center.x + mov_radius * 0.5 * system.sin(time);
  Sphere_center.y := screen_center.y + mov_radius * 0.5 * system.cos(time);
  Sphere_center.z := 0;

  tmpv2 := Sphere_center.xy - gl_FragCoord.xy;
  dist_from_center := length(tmpv2);
  if dist_from_center < Sphere_radius then
  begin
    surfaceZ := System.sqrt(Math.max(0, Sphere_radius * Sphere_radius - dist_from_center * dist_from_center));
    SurfacePosition := vec3.Create(gl_FragCoord.xy, surfaceZ);
    SurfaceNormal   := (SurfacePosition - Sphere_center) / Sphere_radius;
  end
  else
  begin
    SurfacePosition := vec3.Create(gl_FragCoord.xy, 0);
    SurfaceNormal   := vec3_1;
  end;

  // ***********************************************************/
  // * Lighting                                                */
  // ***********************************************************/
  for i := 0 to 2 do
  begin
    LightDirection := normalize(LightPosition[i] - SurfacePosition);

    // ***********************************************************/
    // * Diffuse Light                                           */
    // ***********************************************************/
    DiffuseLightIntensity := dot(LightDirection, SurfaceNormal);

    // ***********************************************************/
    // * Specular Light                                          */
    // ***********************************************************/
    SpecularDirection := LightDirection - 2.0 * SurfaceNormal * dot(LightDirection, SurfaceNormal);

    SpecularLightIntensity := dot(ViewDirection, SpecularDirection);
    SpecularLightIntensity := Math.Power(SpecularLightIntensity,5); // specularity

    LightColor := LightColor + (DiffuseLightColor[i]  * DiffuseLightIntensity +
                                SpecularLightColor[i] * SpecularLightIntensity);

    AmbientLightIntensity := AmbientLightIntensity + DiffuseLightIntensity;
  end;

  // ***********************************************************/
  // * Ambient Light                                           */
  // ***********************************************************/
  AmbientLightIntensity := 1.0 - AmbientLightIntensity;

  if AmbientLightIntensity < 0 then
    AmbientLightIntensity := 0
  else
    AmbientLightIntensity := AmbientLightIntensity * AmbientLightIntensity;

  // ***********************************************************/
  // * Lighting Finalizing                                     */
  // ***********************************************************/
  LightColor := LightColor + (AmbientLightIntensity * AmbientLightColor);

  Result := TColor32(LightColor);

end;

initialization

MultiLight := TMultiLight.Create;
Shaders.Add('MultiLight', MultiLight);

finalization

FreeandNil(MultiLight);

end.
