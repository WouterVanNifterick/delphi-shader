unit WvN.DelphiShader.FX.Tissue;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TTissue = class(TShader)
  const
    HSAMPLES     = 128;
    MSAMPLES     = 4;
    vec2_3: vec2 = (x: 0.02; y: 0);
    vec3_4: vec3 = (x: 0.2; y: 0.1; z: 0.1);
    vec3_5: vec3 = (x: 0.6; y: 1; z: 1);

    constructor Create; override;
    procedure PrepareFrame;
    function main(var gl_FragCoord: vec2): TColor32;
  private
    t: Float;
  end;

var
  Tissue: TShader;

implementation

uses SysUtils, Math;

constructor TTissue.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := main;
end;

procedure TTissue.PrepareFrame;
begin
  // https://www.shadertoy.com/view/XdBSzd#
  // Created by inigo quilez - iq/2014
  // License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
  // Uploaded by iq in 2014-Oct-31Another experiment in stacking texture in a 2D plane deformation.

{$DEFINE DISABLE_MIPMAP} // slower, but if fixes errors in some systems
  t := iGlobalTime + 10 * iMouse.x / resolution.x;

end;

function TTissue.main(var gl_FragCoord: vec2): TColor32;
var
  dif, dof, lodbias, mnc, ran, tim: Float;
  i, j                            : int;
  off, p, q, r, uv2               : vec2;
  col, tot                        : vec3;

  uv                              : vec3;
  d                               : TVecType;
const tx=0;
begin
  p := (-resolution.xy + 2 * gl_FragCoord.xy) / resolution.y;

{$IFDEF DISABLE_MIPMAP}
  lodbias := -100;
{$ELSE }
  lodbias := 0;
{$ENDIF }
  ran     := texture2D(tex[15], gl_FragCoord.xy / resolution).x;
  dof     := dot(p, p);

  tot     := vec3Black;

  for j := 0 to MSAMPLES - 1 do
  begin
    mnc       := (j + ran) / MSAMPLES;
    tim       := t + 0.5 * (1 / 24) * (j + ran) / MSAMPLES;
    off       := vec2.Create(0.2 * tim, 0.2 * system.sin(tim * 0.2));

    q         := p + dof * 0.03 * mnc * vec2.Create(
                                          system.cos(15.7 * mnc),
                                          system.sin(15.7 * mnc));
    r         := vec2.Create(length(q), 0.5 + 0.5 * atan(q.y, q.x) / 3.1416);
    for i := 0 to HSAMPLES - 1 do
    begin
      uv.z := (i + ran) / HSAMPLES - 1;
      d    := r.x * (1 - 0.6 * uv.z);
      if not IsZero(d) then
        uv.xy := off + vec2.Create(0.2 / d, r.y);
      if texture2D(tex[tx], uv.xy, lodbias).x < uv.z then
        break;
    end;

    uv2  := uv.xy + vec2_3;
    dif  := clamp(8 * (texture2D(tex[tx], uv.xy, lodbias).x - texture2D(tex[tx], uv2.xy, lodbias).x), 0, 1);
    col  := vec3_4;
    col  := col * (1 - texture2D(tex[tx], 1 * uv.xy, lodbias).xyz);
    col  := mix(col * 1.2, 1.5 * texture2D(tex[tx], vec2.Create(uv.x * 0.4, 0.1 * system.sin(2 * uv.y * 3.1316)), lodbias).yzx, 1 - 0.7 * col);
    col  := mix(col, vec3_4, 0.5 - 0.5 * smoothstep(0, 0.3, 0.3 - 0.8 * uv.z + texture2D(tex[tx], 2 * uv.xy + uv.z, lodbias).x));
    col  := col * (1 - 1.3 * uv.z);
    col  := col * (1.3 - 0.2 * dif);
    col  := col * (exp(-0.35 / (0.0001 + r.x)));

    tot  := tot + (col);
  end;
  tot    := tot / (MSAMPLES);

  tot.x  := tot.x + (0.05);
  tot    := pow(tot, vec3_5);

  Result := TColor32(tot * smoothstep(0, 2, iGlobalTime));
end;

initialization

Tissue := TTissue.Create;
Shaders.Add('Tissue', Tissue);

finalization

FreeandNil(Tissue);

end.
