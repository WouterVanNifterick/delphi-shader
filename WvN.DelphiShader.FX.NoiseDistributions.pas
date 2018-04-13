unit WvN.DelphiShader.FX.NoiseDistributions;

interface

uses GR32,Types,WvN.DelphiShader.Shader;

type
TNoiseDistributions = class(TShader)
const
  vec2_1:vec2 = (x:12.9898;y:78.233);


var
  NUM_BUCKETS, ITER_PER_BUCKET:int;
  HIST_SCALE, NUM_BUCKETS_F, ITER_PER_BUCKET_F:float


  constructor  Create;override;
  procedure  PrepareFrame;
  function  nrand(const n :vec2):float;
  function  remap( a, b, v :float):float;
  function  trunc( a, l :float):float;
  function  n1rand(const n :vec2):float;
  function  n2rand(const n :vec2):float;
  function  n3rand(const n :vec2):float;
  function  n4rand(const n :vec2):float;
  function  n8rand(const n :vec2):float;
  function  n4rand_inv(const n :vec2):float;
  function  n4rand_ss(const n :vec2):float;
  function  n4rand(const n :vec2):float;
  function  histogram( iter:int;const uv, interval:vec2; height, scale :float):float;
  function  mainImage(var fragCoord:vec2):TColor32;
end;

var
    NoiseDistributions:TShader
;

implementation

uses SysUtils, Math;

constructor TNoiseDistributions.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := mainImage;
end;


procedure TNoiseDistributions.PrepareFrame;
begin
end;


function TNoiseDistributions.nrand(const n :vec2):float;
begin
end;
//note: remaps v to [0;
  1] in interval [a;
  b]
end;


function TNoiseDistributions.remap( a, b, v :float):float;
begin
	Exit( clamp( (v-a) / (b-a), 0, 1 ) );
end;
//note: quantizes in l levels
end;


function TNoiseDistributions.trunc( a, l :float):float;
begin
	Exit( floor(a*l)/l );
end;


function TNoiseDistributions.n1rand(const n :vec2):float;
var
  t, nrnd0:float;
begin
	t  := fract( iGlobalTime );
	nrnd0  := nrand( n + 0.07*t );
	Exit( nrnd0 );
end;


function TNoiseDistributions.n2rand(const n :vec2):float;
var
  t, nrnd0, nrnd1:float;
begin
	t  := fract( iGlobalTime );
	nrnd0  := nrand( n + 0.07*t );
	nrnd1  := nrand( n + 0.11*t );
	Exit( (nrnd0+nrnd1) / 2 );
end;


function TNoiseDistributions.n3rand(const n :vec2):float;
var
  t, nrnd0, nrnd1, nrnd2:float;
begin
	t  := fract( iGlobalTime );
	nrnd0  := nrand( n + 0.07*t );
	nrnd1  := nrand( n + 0.11*t );
	nrnd2  := nrand( n + 0.13*t );
	Exit( (nrnd0+nrnd1+nrnd2) / 3 );
end;


function TNoiseDistributions.n4rand(const n :vec2):float;
var
  t, nrnd0, nrnd1, nrnd2, nrnd3:float;
begin
	t  := fract( iGlobalTime );
	nrnd0  := nrand( n + 0.07*t );
	nrnd1  := nrand( n + 0.11*t );
	nrnd2  := nrand( n + 0.13*t );
	nrnd3  := nrand( n + 0.17*t );
	Exit( (nrnd0+nrnd1+nrnd2+nrnd3) / 4 );
end;


function TNoiseDistributions.n8rand(const n :vec2):float;
var
  t, nrnd0, nrnd1, nrnd2, nrnd3, nrnd4, nrnd5, nrnd6, nrnd7:float;
begin
	t  := fract( iGlobalTime );
	nrnd0  := nrand( n + 0.07*t );
	nrnd1  := nrand( n + 0.11*t );
	nrnd2  := nrand( n + 0.13*t );
	nrnd3  := nrand( n + 0.17*t );
    nrnd4  := nrand( n + 0.19*t );
    nrnd5  := nrand( n + 0.23*t );
    nrnd6  := nrand( n + 0.29*t );
    nrnd7  := nrand( n + 0.31*t );
	Exit( (nrnd0+nrnd1+nrnd2+nrnd3 +nrnd4+nrnd5+nrnd6+nrnd7) / 8 );
end;


function TNoiseDistributions.n4rand_inv(const n :vec2):float;
var
  t, nrnd0, nrnd1, nrnd2, nrnd3, nrnd4, v1, v2, v3:float;
begin
	t  := fract( iGlobalTime );
	nrnd0  := nrand( n + 0.07*t );
	nrnd1  := nrand( n + 0.11*t );
	nrnd2  := nrand( n + 0.13*t );
	nrnd3  := nrand( n + 0.17*t );
    nrnd4  := nrand( n + 0.19*t );
	v1  := (nrnd0+nrnd1+nrnd2+nrnd3) / 4;
    v2  := 0.5 * remap( 0, 0.5, v1 ) + 0.5;
    v3  := 0.5 * remap( 0.5, 1, v1 );
    Exit( (nrnd4<0.5) ? v2 : v3 );
end;
//alternative Gaussian,
//thanks to @self_shadow
//see http://www.dspguide.com/ch2/6.htm
end;


function TNoiseDistributions.n4rand_ss(const n :vec2):float;
var
  nrnd0, nrnd1:float;
begin
	nrnd0  := nrand( n + 0.07*fract( iGlobalTime ) );
	nrnd1  := nrand( n + 0.11*fract( iGlobalTime + 0.573953 ) );
	Exit( 0.23*sqrt(-log(nrnd0+0.00001))*cos(2*3.141592*nrnd1)+0.5 );
end;
{
//Mouse Y give you a curve distribution of ^1 to ^8
//thanks to Trisomie21
end;


function TNoiseDistributions.n4rand(const n :vec2):float;
var
  t, nrnd0, p:float;
begin
	t  := fract( iGlobalTime );
	nrnd0  := nrand( n + 0.07*t );
	p  := 1. / (1. + iMouse.y * 8. / resolution.y);
	nrnd0  := nrnd0  - (.5);
	nrnd0  := nrnd0  * (2.);
	if nrnd0<0. then
		nrnd0  := pow(1.+nrnd0, p)*.5;
	else
		nrnd0  := 1.-pow(nrnd0, p)*.5;
	Exit( nrnd0 );
end;
}
end;


function TNoiseDistributions.histogram( iter:int;const uv, interval:vec2; height, scale :float):float;
var
  t:float;
  bucket:vec2;
  bucketval:float;
  i:int;
  seed, r, v0, v1, v2:float;
begin
	t  := remap( interval.x, interval.y, uv.x );
	bucket  := Vec2.Create( trunc(t,NUM_BUCKETS_F), trunc(t,NUM_BUCKETS_F)+1/NUM_BUCKETS_F);
	bucketval  := 0;
	for i := 0 to ITER_PER_BUCKET-1 do
begin
		seed  := i/ITER_PER_BUCKET_F;
		if  iter < 2  then
			r  := n1rand( Vec2.Create(uv.x,0.5) + seed );
 if  iter<3  then
			r  := n2rand( Vec2.Create(uv.x,0.5) + seed );
 if  iter<4  then
			r  := n4rand( Vec2.Create(uv.x,0.5) + seed );
		else
			r  := n8rand( Vec2.Create(uv.x,0.5) + seed );
		bucketval  := bucketval  + (step(bucket.x,r) * step(r,bucket.y));
end;
	bucketval  := bucketval  / (ITER_PER_BUCKET_F);
	bucketval  := bucketval  * (scale);
    v0  := step( uv.y / height, bucketval );
    v1  := step( (uv.y-1/resolution.y) / height, bucketval );
    v2  := step( (uv.y+1/resolution.y) / height, bucketval );
	Exit( 0.5 * v0 + v1-v2 );
end;


function TNoiseDistributions.mainImage(var fragCoord:vec2):TColor32;
var
  uv:vec2;
  o:float;
  idx:int;
  uvrange:vec2;
begin
	uv  := fragCoord.xy / resolution.xy;
	if  uv.x < 1/4  then
begin
		o  := n1rand( uv );
        idx  := 1;
        uvrange  := Vec2.Create( 0/4,1/4 );
end;
 if  uv.x < 2 / 4  then
begin
		o  := n2rand( uv );
        idx  := 2;
        uvrange  := Vec2.Create( 1/4,2/4 );
end;
 if  uv.x < 3 / 4  then
begin
		o  := n4rand( uv );
        idx  := 3;
        uvrange  := Vec2.Create( 2/4,3/4 );
end;
	else
begin
		o  := n8rand( uv );
        idx  := 4;
        uvrange  := Vec2.Create( 3/4,4/4 );
end;
    //display histogram
    if  uv.y < 1 / 4  then
		o  := 0.125 + histogram( idx, uv, uvrange, 1/4, HIST_SCALE );
	//display lines
	if  abs(uv.x - 1/4) < 0.002  then
     o  := 0;
	if  abs(uv.x - 2/4) < 0.002  then
     o  := 0;
	if  abs(uv.x - 3/4) < 0.002  then
     o  := 0;
	if  abs(uv.y - 1/4) < 0.002  then
     o  := 0;
	fragColor  := vec4( vec3(o), 1 );
end;




initialization
  NoiseDistributions := TNoiseDistributions.Create;
  Shaders.Add('NoiseDistributions', NoiseDistributions);

finalization
  FreeandNil(NoiseDistributions);

end.
