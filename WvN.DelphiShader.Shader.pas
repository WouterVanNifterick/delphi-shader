unit WvN.DelphiShader.Shader;

interface

uses Classes, SysUtils, GR32, Generics.Collections, Diagnostics, types, Math, Forms;

const ThreadCount=8;

/// http://glslsandbox.com/e#31522.0
/// http://glslsandbox.com/e#31191.1
/// http://glslsandbox.com/e#31171.0
///

{$R-}

{$IFDEF DEBUG}
  {x$DEFINE DO_INLINE}
{$ENDIF}

const
  M_LN2 = 0.693147180559945309417;

type
  TTextureCube=record
	  type
      TFace=(
        POSITIVE_X,
        NEGATIVE_X,
        POSITIVE_Y,
        NEGATIVE_Y,
        POSITIVE_Z,
        NEGATIVE_Z,
        FACE_MAX
	   );
    var
      Empty:Boolean;
      Faces:Array[TFace] of TBitmap32;
    procedure Load(Mask:string);
  end;

type
{$IFDEF CPUx64}
  TVecType = type Double;
{$ELSE}
  TVecType = type Single;
{$ENDIF}


  int      = type Integer;
  bool     = type Boolean;
  Float    = type Double;
  PVec2    = ^Vec2;
  PVec3    = ^Vec3;
  PVec4    = ^Vec4;

  Vec1     = TVecType;

  IVec2 = record
    x, y: integer;
    class operator Add(const a: iVec2; b: TVecType): iVec2;{$IFDEF DO_INLINE} inline;{$ENDIF}
  end;
  Vec2 = record
    function Length: TVecType;{$IFDEF DO_INLINE} inline;{$ENDIF}
    function Normalize: PVec2;{$IFDEF DO_INLINE} inline;{$ENDIF}
    function Cross(const b: Vec2): Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}
    function Dot(const b: Vec2): TVecType; overload;{$IFDEF DO_INLINE} inline;{$ENDIF}
    procedure LoadTextures;
    constructor create(ax, ay: TVecType);overload;
    constructor create(ax: TVecType);overload;
    class operator explicit(const b:TVecType):Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}
    class operator Add(const a, b: Vec2): Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}
    class operator Add(const a: Vec2; b: TVecType): Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}
    class operator Add(a: TVecType; const b: Vec2): Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}
    class operator Subtract(const a, b: Vec2): Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}
    class operator Subtract(const a: Vec2; b: TVecType): Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}
    class operator Subtract(a: TVecType; const b: Vec2): Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}
    class operator Multiply(const a: Vec2; const b: Vec2): Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}
    class operator Multiply(const a: Vec2; b: TVecType): Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}
    class operator Multiply(a: TVecType; const b: Vec2): Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}
    class operator Divide(const a: Vec2; const b: Vec2): Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}
    class operator Divide(const a: Vec2; b: TVecType): Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}
    class operator Divide(a: TVecType; const b: Vec2): Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}
    class operator Negative(const a: Vec2): Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}
    class operator Explicit(const a: Vec2): TPoint;{$IFDEF DO_INLINE} inline;{$ENDIF}
    class operator Explicit(const a: Vec2): TPointF;{$IFDEF DO_INLINE} inline;{$ENDIF}
    class operator Explicit(const a: TPoint): Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}
    class operator Explicit(const a: TPointF): Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}

    function rg:vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}
    function xy:vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}
    function yx:vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}
    function xx:vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}
    function yy:vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}
    function yxx:PVec3;{$IFDEF DO_INLINE} inline;{$ENDIF}
    function xyx:PVec3;{$IFDEF DO_INLINE} inline;{$ENDIF}
    function xxy:PVec3;{$IFDEF DO_INLINE} inline;{$ENDIF}
    function xyy:PVec3;{$IFDEF DO_INLINE} inline;{$ENDIF}
    function yxy:PVec3;{$IFDEF DO_INLINE} inline;{$ENDIF}
    function yyx:PVec3;{$IFDEF DO_INLINE} inline;{$ENDIF}
    function xxx:PVec3;{$IFDEF DO_INLINE} inline;{$ENDIF}
    function yyy:PVec3;{$IFDEF DO_INLINE} inline;{$ENDIF}

    var
    x, y: TVecType;
    property r:TVecType read x write x;
    property g:TVecType read y write y;

{
    case RecType: Byte of
      0:(x, y: TVecType);
      1:(r, g: TVecType);
 }
  end;

  Vec3 = record
    function Length: TVecType;{$IFDEF DO_INLINE} inline;{$ENDIF}
    function Normalize: PVec3;{$IFDEF DO_INLINE} inline;{$ENDIF}
    procedure NormalizeSelf;{$IFDEF DO_INLINE} inline;{$ENDIF}
    function Abs: Vec3; {$IFDEF DO_INLINE} inline;{$ENDIF}
    function Cross(const b: Vec3): Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}
    function Dot(const b: Vec3): TVecType; overload;{$IFDEF DO_INLINE} inline;{$ENDIF}
    constructor create(ax, ay, az: TVecType);overload;
    constructor create(ax: TVecType);overload;
    constructor create(const xy:Vec2;az: TVecType);overload;
    constructor create(aX:TVecType;const yz:Vec2);overload;
    class operator Subtract(const a, b: Vec3): Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}
    class operator Subtract(const a: Vec3; const b: Vec2): Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}
    class operator Subtract(const a:Vec2; const b: Vec3): Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}

    class operator Add(const a, b: Vec3): Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}
    class operator Add(const a: Vec3; b: TVecType): Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}
    class operator Negative(const a: Vec3): Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}
    class operator Multiply(const a: Vec3; const b: Vec3): Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}
    class operator Multiply(const a: Vec3; b: TVecType): Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}
    class operator Multiply(a: TVecType; const b: Vec3): Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}
    class operator Divide(const a: Vec3; const b: Vec3): Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}
    class operator Divide(const a: Vec3; b: TVecType): Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}
    class operator Implicit(a: TVecType): Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}
    class operator Explicit(const a: Vec3): TColor32;{$IFDEF DO_INLINE} inline;{$ENDIF}

    class operator Equal(const a,b:Vec3):Boolean;{$IFDEF DO_INLINE} inline;{$ENDIF}

    function getxx: Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setxx(const a:Vec2);property xx:Vec2 read getxx write setxx;
    function getxy: Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setxy(const a:Vec2);property xy:Vec2 read getxy write setxy;
    function getxz: Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setxz(const a:Vec2);property xz:Vec2 read getxz write setxz;
    function getyx: Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setyx(const a:Vec2);property yx:Vec2 read getyx write setyx;
    function getyy: Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setyy(const a:Vec2);property yy:Vec2 read getyy write setyy;
    function getyz: Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setyz(const a:Vec2);property yz:Vec2 read getyz write setyz;
    function getzx: Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setzx(const a:Vec2);property zx:Vec2 read getzx write setzx;
    function getzy: Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setzy(const a:Vec2);property zy:Vec2 read getzy write setzy;
    function getzz: Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setzz(const a:Vec2);property zz:Vec2 read getzz write setzz;
    function getxxx: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setxxx(const a:Vec3);property xxx:Vec3 read getxxx write setxxx;
    function getxxy: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setxxy(const a:Vec3);property xxy:Vec3 read getxxy write setxxy;
    function getxxz: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setxxz(const a:Vec3);property xxz:Vec3 read getxxz write setxxz;
    function getxyx: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setxyx(const a:Vec3);property xyx:Vec3 read getxyx write setxyx;
    function getxyy: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setxyy(const a:Vec3);property xyy:Vec3 read getxyy write setxyy;
    function getxyz: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setxyz(const a:Vec3);property xyz:Vec3 read getxyz write setxyz;
    function getxzx: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setxzx(const a:Vec3);property xzx:Vec3 read getxzx write setxzx;
    function getxzy: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setxzy(const a:Vec3);property xzy:Vec3 read getxzy write setxzy;
    function getxzz: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setxzz(const a:Vec3);property xzz:Vec3 read getxzz write setxzz;
    function getyxx: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setyxx(const a:Vec3);property yxx:Vec3 read getyxx write setyxx;
    function getyxy: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setyxy(const a:Vec3);property yxy:Vec3 read getyxy write setyxy;
    function getyxz: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setyxz(const a:Vec3);property yxz:Vec3 read getyxz write setyxz;
    function getyyx: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setyyx(const a:Vec3);property yyx:Vec3 read getyyx write setyyx;
    function getyyy: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setyyy(const a:Vec3);property yyy:Vec3 read getyyy write setyyy;
    function getyyz: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setyyz(const a:Vec3);property yyz:Vec3 read getyyz write setyyz;
    function getyzx: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setyzx(const a:Vec3);property yzx:Vec3 read getyzx write setyzx;
    function getyzy: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setyzy(const a:Vec3);property yzy:Vec3 read getyzy write setyzy;
    function getyzz: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setyzz(const a:Vec3);property yzz:Vec3 read getyzz write setyzz;
    function getzxx: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setzxx(const a:Vec3);property zxx:Vec3 read getzxx write setzxx;
    function getzxy: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setzxy(const a:Vec3);property zxy:Vec3 read getzxy write setzxy;
    function getzxz: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setzxz(const a:Vec3);property zxz:Vec3 read getzxz write setzxz;
    function getzyx: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setzyx(const a:Vec3);property zyx:Vec3 read getzyx write setzyx;
    function getzyy: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setzyy(const a:Vec3);property zyy:Vec3 read getzyy write setzyy;
    function getzyz: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setzyz(const a:Vec3);property zyz:Vec3 read getzyz write setzyz;
    function getzzx: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setzzx(const a:Vec3);property zzx:Vec3 read getzzx write setzzx;
    function getzzy: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setzzy(const a:Vec3);property zzy:Vec3 read getzzy write setzzy;
    function getzzz: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setzzz(const a:Vec3);property zzz:Vec3 read getzzz write setzzz;


    function getbb: Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setbb(const a:Vec2);property bb:Vec2 read getbb write setbb;
    function getbg: Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setbg(const a:Vec2);property bg:Vec2 read getbg write setbg;
    function getbr: Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setbr(const a:Vec2);property br:Vec2 read getbr write setbr;
    function getgb: Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setgb(const a:Vec2);property gb:Vec2 read getgb write setgb;
    function getgg: Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setgg(const a:Vec2);property gg:Vec2 read getgg write setgg;
    function getgr: Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setgr(const a:Vec2);property gr:Vec2 read getgr write setgr;
    function getrb: Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setrb(const a:Vec2);property rb:Vec2 read getrb write setrb;
    function getrg: Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setrg(const a:Vec2);property rg:Vec2 read getrg write setrg;
    function getrr: Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setrr(const a:Vec2);property rr:Vec2 read getrr write setrr;
    function getbbb: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setbbb(const a:Vec3);property bbb:Vec3 read getbbb write setbbb;
    function getbbg: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setbbg(const a:Vec3);property bbg:Vec3 read getbbg write setbbg;
    function getbbr: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setbbr(const a:Vec3);property bbr:Vec3 read getbbr write setbbr;
    function getbgb: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setbgb(const a:Vec3);property bgb:Vec3 read getbgb write setbgb;
    function getbgg: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setbgg(const a:Vec3);property bgg:Vec3 read getbgg write setbgg;
    function getbgr: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setbgr(const a:Vec3);property bgr:Vec3 read getbgr write setbgr;
    function getbrb: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setbrb(const a:Vec3);property brb:Vec3 read getbrb write setbrb;
    function getbrg: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setbrg(const a:Vec3);property brg:Vec3 read getbrg write setbrg;
    function getbrr: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setbrr(const a:Vec3);property brr:Vec3 read getbrr write setbrr;
    function getgbb: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setgbb(const a:Vec3);property gbb:Vec3 read getgbb write setgbb;
    function getgbg: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setgbg(const a:Vec3);property gbg:Vec3 read getgbg write setgbg;
    function getgbr: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setgbr(const a:Vec3);property gbr:Vec3 read getgbr write setgbr;
    function getggb: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setggb(const a:Vec3);property ggb:Vec3 read getggb write setggb;
    function getggg: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setggg(const a:Vec3);property ggg:Vec3 read getggg write setggg;
    function getggr: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setggr(const a:Vec3);property ggr:Vec3 read getggr write setggr;
    function getgrb: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setgrb(const a:Vec3);property grb:Vec3 read getgrb write setgrb;
    function getgrg: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setgrg(const a:Vec3);property grg:Vec3 read getgrg write setgrg;
    function getgrr: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setgrr(const a:Vec3);property grr:Vec3 read getgrr write setgrr;
    function getrbb: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setrbb(const a:Vec3);property rbb:Vec3 read getrbb write setrbb;
    function getrbg: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setrbg(const a:Vec3);property rbg:Vec3 read getrbg write setrbg;
    function getrbr: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setrbr(const a:Vec3);property rbr:Vec3 read getrbr write setrbr;
    function getrgb: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setrgb(const a:Vec3);property rgb:Vec3 read getrgb write setrgb;
    function getrgg: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setrgg(const a:Vec3);property rgg:Vec3 read getrgg write setrgg;
    function getrgr: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setrgr(const a:Vec3);property rgr:Vec3 read getrgr write setrgr;
    function getrrb: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setrrb(const a:Vec3);property rrb:Vec3 read getrrb write setrrb;
    function getrrg: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setrrg(const a:Vec3);property rrg:Vec3 read getrrg write setrrg;
    function getrrr: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setrrr(const a:Vec3);property rrr:Vec3 read getrrr write setrrr;
    function getyzzz:pvec4;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setyzzz(const a:pVec4);property yzzz:pVec4 read getyzzz write setyzzz;

    {
    case RecType: Byte of
      0:(x, y, z: TVecType);
      1:(r, g, b: TVecType);
  //    2:(rgb:array[0..2] of TVecType);
    }

    var
      x, y, z: TVecType;
    property r:TVecType read x write x;
    property g:TVecType read y write y;
    property b:TVecType read z write z;

  end;

  Vec4 = record
    function Dot(const b: Vec4): TVecType; overload;{$IFDEF DO_INLINE} inline;{$ENDIF}
    constructor create(x: TVecType); overload;
    constructor create(x, y, z, w: TVecType); overload;
    constructor create(const x: Vec3; w: TVecType); overload;
    constructor create(w: TVecType;const ax: Vec3 ); overload;
    class operator Implicit(const a: Vec3): Vec4;{$IFDEF DO_INLINE} inline;{$ENDIF}
    class operator Explicit(const a: Vec4): TColor32;{$IFDEF DO_INLINE} inline;{$ENDIF}
    class operator Multiply(const a: Vec4; b: TVecType): Vec4;{$IFDEF DO_INLINE} inline;{$ENDIF}
    class operator Multiply(const a: TVecType; const b: Vec4): Vec4;{$IFDEF DO_INLINE} inline;{$ENDIF}
    class operator Multiply(const a,b: Vec4): Vec4;{$IFDEF DO_INLINE} inline;{$ENDIF}
    class operator Multiply(const a:vec3;const b: Vec4): Vec4;{$IFDEF DO_INLINE} inline;{$ENDIF}
    class operator Multiply(const a:vec4;const b: Vec3): Vec4;{$IFDEF DO_INLINE} inline;{$ENDIF}
    class operator Divide(const a:vec4;b: TVecType): Vec4;{$IFDEF DO_INLINE} inline;{$ENDIF}
    class operator Divide(const a:vec4;b: int64): Vec4;{$IFDEF DO_INLINE} inline;{$ENDIF}
    class operator Add(const a, b: Vec4): Vec4;{$IFDEF DO_INLINE} inline;{$ENDIF}
    class operator Add(a:TVecType; const b: Vec4): Vec4;{$IFDEF DO_INLINE} inline;{$ENDIF}
    class operator Add(const a:Vec4; b: TVecType): Vec4;{$IFDEF DO_INLINE} inline;{$ENDIF}
    class operator Subtract(const a,b: Vec4): Vec4;{$IFDEF DO_INLINE} inline;{$ENDIF}
    class operator Negative(const a: Vec4): Vec4;{$IFDEF DO_INLINE} inline;{$ENDIF}

    function getww: Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setww(const a:Vec2);property ww:Vec2 read getww write setww;
    function getwx: Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setwx(const a:Vec2);property wx:Vec2 read getwx write setwx;
    function getwy: Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setwy(const a:Vec2);property wy:Vec2 read getwy write setwy;
    function getwz: Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setwz(const a:Vec2);property wz:Vec2 read getwz write setwz;
    function getxw: Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setxw(const a:Vec2);property xw:Vec2 read getxw write setxw;
    function getxx: Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setxx(const a:Vec2);property xx:Vec2 read getxx write setxx;
    function getxy: Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setxy(const a:Vec2);property xy:Vec2 read getxy write setxy;
    function getxz: Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setxz(const a:Vec2);property xz:Vec2 read getxz write setxz;
    function getyw: Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setyw(const a:Vec2);property yw:Vec2 read getyw write setyw;
    function getyx: Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setyx(const a:Vec2);property yx:Vec2 read getyx write setyx;
    function getyy: Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setyy(const a:Vec2);property yy:Vec2 read getyy write setyy;
    function getyz: Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setyz(const a:Vec2);property yz:Vec2 read getyz write setyz;
    function getzw: Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setzw(const a:Vec2);property zw:Vec2 read getzw write setzw;
    function getzx: Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setzx(const a:Vec2);property zx:Vec2 read getzx write setzx;
    function getzy: Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setzy(const a:Vec2);property zy:Vec2 read getzy write setzy;
    function getzz: Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setzz(const a:Vec2);property zz:Vec2 read getzz write setzz;
    function getwww: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setwww(const a:Vec3);property www:Vec3 read getwww write setwww;
    function getwwx: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setwwx(const a:Vec3);property wwx:Vec3 read getwwx write setwwx;
    function getwwy: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setwwy(const a:Vec3);property wwy:Vec3 read getwwy write setwwy;
    function getwwz: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setwwz(const a:Vec3);property wwz:Vec3 read getwwz write setwwz;
    function getwxw: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setwxw(const a:Vec3);property wxw:Vec3 read getwxw write setwxw;
    function getwxx: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setwxx(const a:Vec3);property wxx:Vec3 read getwxx write setwxx;
    function getwxy: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setwxy(const a:Vec3);property wxy:Vec3 read getwxy write setwxy;
    function getwxz: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setwxz(const a:Vec3);property wxz:Vec3 read getwxz write setwxz;
    function getwyw: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setwyw(const a:Vec3);property wyw:Vec3 read getwyw write setwyw;
    function getwyx: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setwyx(const a:Vec3);property wyx:Vec3 read getwyx write setwyx;
    function getwyy: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setwyy(const a:Vec3);property wyy:Vec3 read getwyy write setwyy;
    function getwyz: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setwyz(const a:Vec3);property wyz:Vec3 read getwyz write setwyz;
    function getwzw: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setwzw(const a:Vec3);property wzw:Vec3 read getwzw write setwzw;
    function getwzx: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setwzx(const a:Vec3);property wzx:Vec3 read getwzx write setwzx;
    function getwzy: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setwzy(const a:Vec3);property wzy:Vec3 read getwzy write setwzy;
    function getwzz: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setwzz(const a:Vec3);property wzz:Vec3 read getwzz write setwzz;
    function getxww: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setxww(const a:Vec3);property xww:Vec3 read getxww write setxww;
    function getxwx: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setxwx(const a:Vec3);property xwx:Vec3 read getxwx write setxwx;
    function getxwy: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setxwy(const a:Vec3);property xwy:Vec3 read getxwy write setxwy;
    function getxwz: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setxwz(const a:Vec3);property xwz:Vec3 read getxwz write setxwz;
    function getxxw: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setxxw(const a:Vec3);property xxw:Vec3 read getxxw write setxxw;
    function getxxx: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setxxx(const a:Vec3);property xxx:Vec3 read getxxx write setxxx;
    function getxxy: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setxxy(const a:Vec3);property xxy:Vec3 read getxxy write setxxy;
    function getxxz: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setxxz(const a:Vec3);property xxz:Vec3 read getxxz write setxxz;
    function getxyw: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setxyw(const a:Vec3);property xyw:Vec3 read getxyw write setxyw;
    function getxyx: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setxyx(const a:Vec3);property xyx:Vec3 read getxyx write setxyx;
    function getxyy: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setxyy(const a:Vec3);property xyy:Vec3 read getxyy write setxyy;
    function getxyz: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setxyz(const a:Vec3);property xyz:Vec3 read getxyz write setxyz;
    function getxzw: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setxzw(const a:Vec3);property xzw:Vec3 read getxzw write setxzw;
    function getxzx: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setxzx(const a:Vec3);property xzx:Vec3 read getxzx write setxzx;
    function getxzy: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setxzy(const a:Vec3);property xzy:Vec3 read getxzy write setxzy;
    function getxzz: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setxzz(const a:Vec3);property xzz:Vec3 read getxzz write setxzz;
    function getyww: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setyww(const a:Vec3);property yww:Vec3 read getyww write setyww;
    function getywx: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setywx(const a:Vec3);property ywx:Vec3 read getywx write setywx;
    function getywy: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setywy(const a:Vec3);property ywy:Vec3 read getywy write setywy;
    function getywz: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setywz(const a:Vec3);property ywz:Vec3 read getywz write setywz;
    function getyxw: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setyxw(const a:Vec3);property yxw:Vec3 read getyxw write setyxw;
    function getyxx: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setyxx(const a:Vec3);property yxx:Vec3 read getyxx write setyxx;
    function getyxy: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setyxy(const a:Vec3);property yxy:Vec3 read getyxy write setyxy;
    function getyxz: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setyxz(const a:Vec3);property yxz:Vec3 read getyxz write setyxz;
    function getyyw: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setyyw(const a:Vec3);property yyw:Vec3 read getyyw write setyyw;
    function getyyx: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setyyx(const a:Vec3);property yyx:Vec3 read getyyx write setyyx;
    function getyyy: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setyyy(const a:Vec3);property yyy:Vec3 read getyyy write setyyy;
    function getyyz: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setyyz(const a:Vec3);property yyz:Vec3 read getyyz write setyyz;
    function getyzw: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setyzw(const a:Vec3);property yzw:Vec3 read getyzw write setyzw;
    function getyzx: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setyzx(const a:Vec3);property yzx:Vec3 read getyzx write setyzx;
    function getyzy: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setyzy(const a:Vec3);property yzy:Vec3 read getyzy write setyzy;
    function getyzz: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setyzz(const a:Vec3);property yzz:Vec3 read getyzz write setyzz;
    function getzww: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setzww(const a:Vec3);property zww:Vec3 read getzww write setzww;
    function getzwx: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setzwx(const a:Vec3);property zwx:Vec3 read getzwx write setzwx;
    function getzwy: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setzwy(const a:Vec3);property zwy:Vec3 read getzwy write setzwy;
    function getzwz: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setzwz(const a:Vec3);property zwz:Vec3 read getzwz write setzwz;
    function getzxw: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setzxw(const a:Vec3);property zxw:Vec3 read getzxw write setzxw;
    function getzxx: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setzxx(const a:Vec3);property zxx:Vec3 read getzxx write setzxx;
    function getzxy: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setzxy(const a:Vec3);property zxy:Vec3 read getzxy write setzxy;
    function getzxz: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setzxz(const a:Vec3);property zxz:Vec3 read getzxz write setzxz;
    function getzyw: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setzyw(const a:Vec3);property zyw:Vec3 read getzyw write setzyw;
    function getzyx: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setzyx(const a:Vec3);property zyx:Vec3 read getzyx write setzyx;
    function getzyy: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setzyy(const a:Vec3);property zyy:Vec3 read getzyy write setzyy;
    function getzyz: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setzyz(const a:Vec3);property zyz:Vec3 read getzyz write setzyz;
    function getzzw: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setzzw(const a:Vec3);property zzw:Vec3 read getzzw write setzzw;
    function getzzx: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setzzx(const a:Vec3);property zzx:Vec3 read getzzx write setzzx;
    function getzzy: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setzzy(const a:Vec3);property zzy:Vec3 read getzzy write setzzy;
    function getzzz: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setzzz(const a:Vec3);property zzz:Vec3 read getzzz write setzzz;


    function getaa: Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setaa(const a:Vec2);property aa:Vec2 read getaa write setaa;
    function getab: Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setab(const a:Vec2);property ab:Vec2 read getab write setab;
    function getag: Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setag(const a:Vec2);property ag:Vec2 read getag write setag;
    function getar: Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setar(const a:Vec2);property ar:Vec2 read getar write setar;
    function getba: Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setba(const a:Vec2);property ba:Vec2 read getba write setba;
    function getbb: Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setbb(const a:Vec2);property bb:Vec2 read getbb write setbb;
    function getbg: Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setbg(const a:Vec2);property bg:Vec2 read getbg write setbg;
    function getbr: Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setbr(const a:Vec2);property br:Vec2 read getbr write setbr;
    function getga: Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setga(const a:Vec2);property ga:Vec2 read getga write setga;
    function getgb: Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setgb(const a:Vec2);property gb:Vec2 read getgb write setgb;
    function getgg: Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setgg(const a:Vec2);property gg:Vec2 read getgg write setgg;
    function getgr: Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setgr(const a:Vec2);property gr:Vec2 read getgr write setgr;
    function getra: Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setra(const a:Vec2);property ra:Vec2 read getra write setra;
    function getrb: Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setrb(const a:Vec2);property rb:Vec2 read getrb write setrb;
    function getrg: Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setrg(const a:Vec2);property rg:Vec2 read getrg write setrg;
    function getrr: Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setrr(const a:Vec2);property rr:Vec2 read getrr write setrr;
    function getaaa: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setaaa(const a:Vec3);property aaa:Vec3 read getaaa write setaaa;
    function getaab: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setaab(const a:Vec3);property aab:Vec3 read getaab write setaab;
    function getaag: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setaag(const a:Vec3);property aag:Vec3 read getaag write setaag;
    function getaar: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setaar(const a:Vec3);property aar:Vec3 read getaar write setaar;
    function getaba: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setaba(const a:Vec3);property aba:Vec3 read getaba write setaba;
    function getabb: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setabb(const a:Vec3);property abb:Vec3 read getabb write setabb;
    function getabg: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setabg(const a:Vec3);property abg:Vec3 read getabg write setabg;
    function getabr: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setabr(const a:Vec3);property abr:Vec3 read getabr write setabr;
    function getaga: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setaga(const a:Vec3);property aga:Vec3 read getaga write setaga;
    function getagb: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setagb(const a:Vec3);property agb:Vec3 read getagb write setagb;
    function getagg: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setagg(const a:Vec3);property agg:Vec3 read getagg write setagg;
    function getagr: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setagr(const a:Vec3);property agr:Vec3 read getagr write setagr;
    function getara: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setara(const a:Vec3);property ara:Vec3 read getara write setara;
    function getarb: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setarb(const a:Vec3);property arb:Vec3 read getarb write setarb;
    function getarg: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setarg(const a:Vec3);property arg:Vec3 read getarg write setarg;
    function getarr: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setarr(const a:Vec3);property arr:Vec3 read getarr write setarr;
    function getbaa: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setbaa(const a:Vec3);property baa:Vec3 read getbaa write setbaa;
    function getbab: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setbab(const a:Vec3);property bab:Vec3 read getbab write setbab;
    function getbag: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setbag(const a:Vec3);property bag:Vec3 read getbag write setbag;
    function getbar: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setbar(const a:Vec3);property bar:Vec3 read getbar write setbar;
    function getbba: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setbba(const a:Vec3);property bba:Vec3 read getbba write setbba;
    function getbbb: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setbbb(const a:Vec3);property bbb:Vec3 read getbbb write setbbb;
    function getbbg: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setbbg(const a:Vec3);property bbg:Vec3 read getbbg write setbbg;
    function getbbr: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setbbr(const a:Vec3);property bbr:Vec3 read getbbr write setbbr;
    function getbga: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setbga(const a:Vec3);property bga:Vec3 read getbga write setbga;
    function getbgb: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setbgb(const a:Vec3);property bgb:Vec3 read getbgb write setbgb;
    function getbgg: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setbgg(const a:Vec3);property bgg:Vec3 read getbgg write setbgg;
    function getbgr: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setbgr(const a:Vec3);property bgr:Vec3 read getbgr write setbgr;
    function getbra: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setbra(const a:Vec3);property bra:Vec3 read getbra write setbra;
    function getbrb: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setbrb(const a:Vec3);property brb:Vec3 read getbrb write setbrb;
    function getbrg: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setbrg(const a:Vec3);property brg:Vec3 read getbrg write setbrg;
    function getbrr: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setbrr(const a:Vec3);property brr:Vec3 read getbrr write setbrr;
    function getgaa: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setgaa(const a:Vec3);property gaa:Vec3 read getgaa write setgaa;
    function getgab: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setgab(const a:Vec3);property gab:Vec3 read getgab write setgab;
    function getgag: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setgag(const a:Vec3);property gag:Vec3 read getgag write setgag;
    function getgar: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setgar(const a:Vec3);property gar:Vec3 read getgar write setgar;
    function getgba: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setgba(const a:Vec3);property gba:Vec3 read getgba write setgba;
    function getgbb: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setgbb(const a:Vec3);property gbb:Vec3 read getgbb write setgbb;
    function getgbg: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setgbg(const a:Vec3);property gbg:Vec3 read getgbg write setgbg;
    function getgbr: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setgbr(const a:Vec3);property gbr:Vec3 read getgbr write setgbr;
    function getgga: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setgga(const a:Vec3);property gga:Vec3 read getgga write setgga;
    function getggb: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setggb(const a:Vec3);property ggb:Vec3 read getggb write setggb;
    function getggg: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setggg(const a:Vec3);property ggg:Vec3 read getggg write setggg;
    function getggr: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setggr(const a:Vec3);property ggr:Vec3 read getggr write setggr;
    function getgra: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setgra(const a:Vec3);property gra:Vec3 read getgra write setgra;
    function getgrb: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setgrb(const a:Vec3);property grb:Vec3 read getgrb write setgrb;
    function getgrg: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setgrg(const a:Vec3);property grg:Vec3 read getgrg write setgrg;
    function getgrr: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setgrr(const a:Vec3);property grr:Vec3 read getgrr write setgrr;
    function getraa: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setraa(const a:Vec3);property raa:Vec3 read getraa write setraa;
    function getrab: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setrab(const a:Vec3);property rab:Vec3 read getrab write setrab;
    function getrag: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setrag(const a:Vec3);property rag:Vec3 read getrag write setrag;
    function getrar: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setrar(const a:Vec3);property rar:Vec3 read getrar write setrar;
    function getrba: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setrba(const a:Vec3);property rba:Vec3 read getrba write setrba;
    function getrbb: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setrbb(const a:Vec3);property rbb:Vec3 read getrbb write setrbb;
    function getrbg: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setrbg(const a:Vec3);property rbg:Vec3 read getrbg write setrbg;
    function getrbr: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setrbr(const a:Vec3);property rbr:Vec3 read getrbr write setrbr;
    function getrga: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setrga(const a:Vec3);property rga:Vec3 read getrga write setrga;
    function getrgb: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setrgb(const a:Vec3);property rgb:Vec3 read getrgb write setrgb;
    function getrgg: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setrgg(const a:Vec3);property rgg:Vec3 read getrgg write setrgg;
    function getrgr: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setrgr(const a:Vec3);property rgr:Vec3 read getrgr write setrgr;
    function getrra: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setrra(const a:Vec3);property rra:Vec3 read getrra write setrra;
    function getrrb: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setrrb(const a:Vec3);property rrb:Vec3 read getrrb write setrrb;
    function getrrg: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setrrg(const a:Vec3);property rrg:Vec3 read getrrg write setrrg;
    function getrrr: Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}procedure setrrr(const a:Vec3);property rrr:Vec3 read getrrr write setrrr;

{
    case RecType: byte of
      0:(x, y, z, w: TVecType);
      1:(r, g, b, a: TVecType);
}

    var
      x, y, z, w: TVecType;
    property r:TVecType read x write x;
    property g:TVecType read y write y;
    property b:TVecType read z write z;
    property a:TVecType read w write w;

  end;

  Mat2 = record
    r1,r2:Vec2;
    constructor Create(a1,a2,b1,b2:TVecType);
    class operator Multiply(const a:Mat2;const b:Vec2):Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}
    class operator Multiply(const b:Vec2;const a:Mat2):Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}
  end;

  Mat3 = record
    r1,r2,r3:Vec3;
    constructor Create(a1,a2,a3,b1,b2,b3,c1,c2,c3:TVecType);overload;
    constructor Create(const a,b,c:Vec3);overload;
    class operator Multiply(const a:Mat3;const b:Vec3):Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}
    class operator Multiply(const a:Vec3;const b:Mat3):Vec3;
    class operator Multiply(const a:Mat3;const b:Mat3):Mat3;{$IFDEF DO_INLINE} inline;{$ENDIF}
    class operator Add(const a:Mat3;const b:Vec3):Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}
    class operator Negative(const a: Mat3): Mat3;{$IFDEF DO_INLINE} inline;{$ENDIF}
  end;

  Mat4 = record
    r1,r2,r3,r4:Vec4;
    constructor Create(a1,a2,a3,a4,b1,b2,b3,b4,c1,c2,c3,c4,d1,d2,d3,d4:TVecType);
    class operator Multiply(const a,b:Mat4):Mat4;{$IFDEF DO_INLINE} inline;{$ENDIF}
    class operator Multiply(const a:Mat4;const b:Vec4):Vec4;{$IFDEF DO_INLINE} inline;{$ENDIF}
  end;

function abs(x: Single) : Single;inline;overload;
function abs(x: Double) : Double;inline;overload;
// function abs(x: Extended) : Extended;inline;overload;


function pow(x, y: Double): Double;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;
function radians(degrees: Double): Double;{$IFDEF DO_INLINE} inline;{$ENDIF} overload; { return T(M_PI/180)*degrees; }
function degrees(radians: Double): Double;{$IFDEF DO_INLINE} inline;{$ENDIF} overload; { return T(180/M_PI)*radians; }
function exp2(x: Double): Double;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;        { return T(cmath::exp(x * M_LN2)); }
function log(x: Double): Double;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;        { return T(cmath::log(x) / M_LN2); }
function log(x: vec2): vec2;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;        { return T(cmath::log(x) / M_LN2); }
function log(x: vec3): vec3;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;        { return T(cmath::log(x) / M_LN2); }
function log2(x: single): single;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;        { return T(cmath::log2(x) / M_LN2); }
function log2(x: Double): Double;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;        { return T(cmath::log2(x) / M_LN2); }

function inversesqrt(x: Single): Single;{$IFDEF DO_INLINE} inline;{$ENDIF} overload; { return 1/cmath::sqrt(x); }
function inversesqrt(x: Double): Double;{$IFDEF DO_INLINE} inline;{$ENDIF} overload; { return 1/cmath::sqrt(x); }

function sign(x: Double): Double;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;        { return T((x>0) ? T(1) : ((x<0) ? T(-1):T(0))); }
function fract(x: Double): Double;inline;overload;       { return x - cmath::floor(x); }
function fract(const a: Vec2): Vec2;inline;overload;       { return x - cmath::floor(x); }
function fract(const a: Vec3): Vec3;inline;overload;       { return x - cmath::floor(x); }
function fract(const a: Vec4): Vec4;inline;overload;       { return x - cmath::floor(x); }

//function floor(x: Double): Double;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;       { return x - cmath::floor(x); }
function floor(const a: Vec2): Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;       { return x - cmath::floor(x); }
function floor(const a: Vec3): Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;       { return x - cmath::floor(x); }
function floor(const a: Vec4): Vec4;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;       { return x - cmath::floor(x); }


function clamp(x:Double; minVal:Double; maxVal: Double): Double;inline; overload; { return glsl::min(glsl::max(x,minVal),maxVal); }
function clamp(x:Double): Double;inline; overload;
function distance(p0, p1: Double): Double;{$IFDEF DO_INLINE} inline;{$ENDIF} overload; { return length(p0-p1); }
function Dot(x, y: Single): Single;{$IFDEF DO_INLINE} inline;{$ENDIF} overload; { return x*y; }
function Dot(x, y: Double): Double;{$IFDEF DO_INLINE} inline;{$ENDIF} overload; { return x*y; }
function Dot(const x, y: Vec2): Double; overload;{$IFDEF DO_INLINE} inline;{$ENDIF}   { return x*y; }
function Dot(const x, y: Vec3): Double; overload;{$IFDEF DO_INLINE} inline;{$ENDIF}   { return x*y; }
function Dot(const x, y: Vec4): Double; overload;{$IFDEF DO_INLINE} inline;{$ENDIF}   { return x*y; }

// function ceil(x: Double): Double;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;
function ceil(const a: Vec2): Vec2; overload;{$IFDEF DO_INLINE} inline;{$ENDIF}
function ceil(const a: Vec3): Vec3; overload;{$IFDEF DO_INLINE} inline;{$ENDIF}
function ceil(const a: Vec4): Vec4; overload;{$IFDEF DO_INLINE} inline;{$ENDIF}



function Reflect(I, n: Double): Double;{$IFDEF DO_INLINE} inline;{$ENDIF} overload; { return I - T(2)*N*I*N; }
function Reflect(const I, n: Vec3): Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF} overload; { return I - T(2)*N*I*N; }

function FaceForward(const N,I,NRef:TVecType): TVecType;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;
function FaceForward(const N,I,NRef:Vec2): Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;
function FaceForward(const N,I,NRef:Vec3): Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;
function FaceForward(const N,I,NRef:Vec4): Vec4;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;

function Refract(const I, N:TVecType; eta:Double):TVecType;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;
function Refract(const I, N:vec2; eta:Double):vec2;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;
function Refract(const I, N:vec3; eta:Double):vec3;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;
function Refract(const I, N:vec4; eta:Double):vec4;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;



//function Abs(const x: TVecType): TVecType; overload;{$IFDEF DO_INLINE} inline;{$ENDIF}
function Abs(const x: Vec2): Vec2; overload;{$IFDEF DO_INLINE} inline;{$ENDIF}
function Abs(const x: Vec3): Vec3; overload;{$IFDEF DO_INLINE} inline;{$ENDIF}
function Abs(const x: Vec4): Vec4; overload;{$IFDEF DO_INLINE} inline;{$ENDIF}

function asin(x:Single):Single;overload;{$IFDEF DO_INLINE} inline;{$ENDIF}
function acos(x:Single):Single;overload;{$IFDEF DO_INLINE} inline;{$ENDIF}
function atan(x:Single):Single;overload;{$IFDEF DO_INLINE} inline;{$ENDIF}
function atan(x,y:Single):Single;overload;{$IFDEF DO_INLINE} inline;{$ENDIF}
function tan(x:Single):Single;overload;{$IFDEF DO_INLINE} inline;{$ENDIF}

function asin(x:Double):Double;overload;{$IFDEF DO_INLINE} inline;{$ENDIF}
function acos(x:Double):Double;overload;{$IFDEF DO_INLINE} inline;{$ENDIF}
function atan(x:Double):Double;overload;{$IFDEF DO_INLINE} inline;{$ENDIF}
function atan(x,y:Double):Double;overload;{$IFDEF DO_INLINE} inline;{$ENDIF}
function tan(x:Double):Double;overload;{$IFDEF DO_INLINE} inline;{$ENDIF}

//function acos(x:Extended):Extended;overload;{$IFDEF DO_INLINE} inline;{$ENDIF}
//function atan(x:Extended):Extended;overload;{$IFDEF DO_INLINE} inline;{$ENDIF}
//function atan(x,y:Extended):Extended;overload;{$IFDEF DO_INLINE} inline;{$ENDIF}
//function tan(x:Extended):Extended;overload;{$IFDEF DO_INLINE} inline;{$ENDIF}



function Cross(const a,b: Vec3): Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}

function smoothstep(edge0, edge1, x: Single): Single; {$IFDEF DO_INLINE} inline;{$ENDIF}  overload; { T t = clamp((x-edge0) / (edge1-edge0), T(0), T(1)); return t * t * (3 - 2*t); }
function smoothstep(edge0, edge1, x: Double): Double; {$IFDEF DO_INLINE} inline;{$ENDIF}  overload; { T t = clamp((x-edge0) / (edge1-edge0), T(0), T(1)); return t * t * (3 - 2*t); }
// function smoothstep(edge0, edge1, x: Extended): Extended; {$IFDEF DO_INLINE} inline;{$ENDIF}  overload; { T t = clamp((x-edge0) / (edge1-edge0), T(0), T(1)); return t * t * (3 - 2*t); }
function smoothstep(const edge0, edge1, x: Vec2): Vec2; overload;{$IFDEF DO_INLINE} inline;{$ENDIF} { T t = clamp((x-edge0) / (edge1-edge0), T(0), T(1)); return t * t * (3 - 2*t); }
function smoothstep(const edge0, edge1, x: Vec3): Vec3; overload;{$IFDEF DO_INLINE} inline;{$ENDIF}  { T t = clamp((x-edge0) / (edge1-edge0), T(0), T(1)); return t * t * (3 - 2*t); }
function smoothstep(const edge0, edge1, x: Vec4): Vec4; overload;{$IFDEF DO_INLINE} inline;{$ENDIF} { T t = clamp((x-edge0) / (edge1-edge0), T(0), T(1)); return t * t * (3 - 2*t); }


function distance(const a,b: Vec2): double;{$IFDEF DO_INLINE} inline;{$ENDIF} overload; { return length(p0-p1); }
function distance(const a,b: Vec3): double;{$IFDEF DO_INLINE} inline;{$ENDIF} overload; { return length(p0-p1); }
function distance(const a,b: Vec4): double;{$IFDEF DO_INLINE} inline;{$ENDIF} overload; { return length(p0-p1); }

// function &mod(a, b: single): single;  overload;
//function fmod(a, b: extended): Extended;overload;

{x$IF CompilerVersion < 17.0}
function fmod(a, b: single): Single;overload;
function fmod(a, b: double): Double;overload;
{x$ENDIF}
function fmods(a, b: double): Double;overload;
function &mod(a, b: Double): Double;{$IFDEF CPUx64}inline;{$ENDIF} overload;     { return T(cmath::fmod(x, y)); }

function &mod(const a, b: Vec2): Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;     { return T(cmath::fmod(x, y)); }
function &mod(const a, b: Vec3): Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;     { return T(cmath::fmod(x, y)); }
function &mod(const a, b: Vec4): Vec4;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;     { return T(cmath::fmod(x, y)); }

function &mod(const a: Vec2;b:TVecType): Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;     { return T(cmath::fmod(x, y)); }
function &mod(const a: Vec3;b:TVecType): Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;     { return T(cmath::fmod(x, y)); }
function &mod(const a: Vec4;b:TVecType): Vec4;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;     { return T(cmath::fmod(x, y)); }


function min(x, y: Double): Double;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;{$IFDEF DO_INLINE} inline;{$ENDIF}  { return y < x ? y : x; }
function min(const x, y: Vec2): Vec2; overload;{$IFDEF DO_INLINE} inline;{$ENDIF}        { return y < x ? y : x; }
function min(const x, y: Vec3): Vec3; overload;{$IFDEF DO_INLINE} inline;{$ENDIF}
function min(const x, y: Vec4): Vec4; overload;{$IFDEF DO_INLINE} inline;{$ENDIF}

function max(x, y: Double): Double;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;{$IFDEF DO_INLINE} inline;{$ENDIF}  { return x < y ? y : x; }
function max(const x, y: Vec2): Vec2; overload;{$IFDEF DO_INLINE} inline;{$ENDIF}        { return x < y ? y : x; }
function max(const x, y: Vec3): Vec3; overload;{$IFDEF DO_INLINE} inline;{$ENDIF}       { return x < y ? y : x; }
function max(const x, y: Vec4): Vec4; overload;{$IFDEF DO_INLINE} inline;{$ENDIF}       { return x < y ? y : x; }
function maxComp(const p: Vec3): Double; overload;{$IFDEF DO_INLINE} inline;{$ENDIF}

function pow(const x, y: Vec2): Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;
function pow(const a, b: Vec3): Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;
function pow(const x, y: Vec4): Vec4;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;


//function sqrt(const a: Single): Single;{$IFNDEF DEBUG} inline; {$ENDIF} overload;
function sqrt(const a: Double): Double;{$IFDEF DO_INLINE}inline{$ENDIF} overload;
function sqrt(const a: Vec2): Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;
function sqrt(const a: Vec3): Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;

function sqrt(const a: Vec4): Vec4;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;
function sqrts(const a: TVecType): TVecType;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;
function sqrts(const a: Vec2): Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;
function sqrts(const a: Vec3): Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;
function sqrts(const a: Vec4): Vec4;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;

function clamp(const x, minVal, maxVal: Vec2): Vec2; overload;{$IFDEF DO_INLINE} inline;{$ENDIF}  { return glsl::min(glsl::max(x,minVal),maxVal); }
function clamp(const x, minVal, maxVal: Vec3): Vec3; overload;{$IFDEF DO_INLINE} inline;{$ENDIF}  { return glsl::min(glsl::max(x,minVal),maxVal); }
function clamp(const x:Vec2; minVal, maxVal: Double): Vec2; overload;{$IFDEF DO_INLINE} inline;{$ENDIF}  { return glsl::min(glsl::max(x,minVal),maxVal); }
function clamp(const x:Vec3; minVal, maxVal: Double): Vec3; overload;{$IFDEF DO_INLINE} inline;{$ENDIF}  { return glsl::min(glsl::max(x,minVal),maxVal); }
function clamp(const x:Vec4; minVal, maxVal: Double): Vec4; overload;{$IFDEF DO_INLINE} inline;{$ENDIF}  { return glsl::min(glsl::max(x,minVal),maxVal); }

function mix(x, y, a: Double): Double;{$IFDEF DO_INLINE} inline;{$ENDIF} overload; { return x*(1-a) + y*a; }
function mix(const x, y, a: Vec2): Vec2; overload;{$IFDEF DO_INLINE} inline;{$ENDIF}  { return x*(1-a) + y*a; }
function mix(const x, y, a: Vec3): Vec3; overload;{$IFDEF DO_INLINE} inline;{$ENDIF}  { return x*(1-a) + y*a; }
function mix(const x, y, a: Vec4): Vec4; overload;{$IFDEF DO_INLINE} inline;{$ENDIF}  { return x*(1-a) + y*a; }

function mix(const x, y:Vec2; a: TVecType): Vec2; overload;{$IFDEF DO_INLINE} inline;{$ENDIF}  { return x*(1-a) + y*a; }
function mix(const x, y:Vec3; a: TVecType): Vec3; overload;{$IFDEF DO_INLINE} inline;{$ENDIF}  { return x*(1-a) + y*a; }
function mix(const x, y:Vec4; a: TVecType): Vec4; overload;{$IFDEF DO_INLINE} inline;{$ENDIF}  { return x*(1-a) + y*a; }

function step(edge, x: Double): Double;{$IFDEF DO_INLINE} inline;{$ENDIF} overload; { return x<=edge ? T(0) : T(1); }
function step(const edge, x: Vec2): Vec2; overload;{$IFDEF DO_INLINE} inline;{$ENDIF} { return x<=edge ? T(0) : T(1); }
function step(const edge, x: Vec3): Vec3; overload;{$IFDEF DO_INLINE} inline;{$ENDIF} { return x<=edge ? T(0) : T(1); }
function step(const edge, x: Vec4): Vec4; overload;{$IFDEF DO_INLINE} inline;{$ENDIF} { return x<=edge ? T(0) : T(1); }

function Length(x: Double): Double;{$IFDEF DO_INLINE} inline;{$ENDIF} overload; { return cmath::sqrt(x*x); }
function Length(const x: Vec2): Double; overload;{$IFDEF DO_INLINE} inline;{$ENDIF}    { return cmath::sqrt(x*x); }
function Length(const x: Vec3): Double; overload;{$IFDEF DO_INLINE} inline;{$ENDIF}    { return cmath::sqrt(x*x); }
function Length(const x: Vec4): Double; overload;{$IFDEF DO_INLINE} inline;{$ENDIF}    { return cmath::sqrt(x*x); }
function length_sq(const x: Vec2): Double; overload;{$IFDEF DO_INLINE} inline;{$ENDIF} { return cmath::sqrt(x*x); }
function length_sq(const x: Vec3): Double; overload;{$IFDEF DO_INLINE} inline;{$ENDIF} { return cmath::sqrt(x*x); }

function Normalize(x:double): Double; { return T(1); } inline; overload; // this is not the most useful function in the world
function Normalize(const v: Vec2): Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;
function Normalize(const v: Vec3): Vec3;{$IFDEF DO_INLINE} inline; {$ENDIF} overload;
function normalizeS(const v:Vec3) : vec3;inline;{$IFDEF DO_INLINE} inline; {$ENDIF} overload;

function Normalize(const v: Vec4): Vec4;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;

function texture2DLQ(tex:TBitmap32;const Coords:Vec2):Vec4;overload;{$IFDEF DO_INLINE} inline;{$ENDIF}
function texture2DHQ(tex:TBitmap32;const Coords:Vec2):Vec4;overload;{$IFDEF DO_INLINE} inline;{$ENDIF}
function texture2D(tex: TBitmap32; const Coords: Vec2): Vec4;overload;{$IFDEF DO_INLINE} inline;{$ENDIF}
function texture2D(tex: TBitmap32; const Coords: Vec2; Bias:Float): Vec4;overload;{$IFDEF DO_INLINE} inline;{$ENDIF}
function textureCube(tex: TBitmap32; const Coords: Vec3): Vec4;overload;{$IFDEF DO_INLINE} inline;{$ENDIF}
function textureCube(const tex: TTextureCube; const Coords: Vec3): Vec4;overload;{$IFDEF DO_INLINE} inline;{$ENDIF}


function sinLarge(const x: TVecType): TVecType; overload;{$IFDEF DO_INLINE} inline;{$ENDIF}
function sinLarge(const x: Vec2   ): Vec2   ; overload;{$IFDEF DO_INLINE} inline;{$ENDIF}
function sinLarge(const x: Vec3   ): Vec3   ; overload;{$IFDEF DO_INLINE} inline;{$ENDIF}
function sinLarge(const x: Vec4   ): Vec4   ; overload;{$IFDEF DO_INLINE} inline;{$ENDIF}

function cosLarge(const x: TVecType): TVecType; overload;{$IFDEF DO_INLINE} inline;{$ENDIF}
function cosLarge(const x: Vec2   ): Vec2   ; overload;{$IFDEF DO_INLINE} inline;{$ENDIF}
function cosLarge(const x: Vec3   ): Vec3   ; overload;{$IFDEF DO_INLINE} inline;{$ENDIF}
function cosLarge(const x: Vec4   ): Vec4   ; overload;{$IFDEF DO_INLINE} inline;{$ENDIF}

function sin(const x: Vec2): Vec2; overload;{$IFDEF DO_INLINE} inline;{$ENDIF}
function sin(const x: Vec3): Vec3; overload;{$IFDEF DO_INLINE} inline;{$ENDIF}
function sin(const x: Vec4): Vec4; overload;{$IFDEF DO_INLINE} inline;{$ENDIF}

function cos(const x: Vec2): Vec2; overload;{$IFDEF DO_INLINE} inline;{$ENDIF}
function cos(const x: Vec3): Vec3; overload;{$IFDEF DO_INLINE} inline;{$ENDIF}
function cos(const x: Vec4): Vec4; overload;{$IFDEF DO_INLINE} inline;{$ENDIF}

procedure cos(const x: Vec2;out Result:vec2); overload;{$IFDEF DO_INLINE} inline;{$ENDIF}
procedure cos(const x: Vec3;out Result:vec3); overload;{$IFDEF DO_INLINE} inline;{$ENDIF}
procedure cos(const x: Vec4;out Result:vec4); overload;{$IFDEF DO_INLINE} inline;{$ENDIF}

procedure Mult(const input: Vec3;out Result:vec3);inline;

function Ifthen(c:Boolean;const a,b:Vec2):Vec2;overload;{$IFDEF DO_INLINE} inline;{$ENDIF}
function Ifthen(c:Boolean;const a,b:Vec3):Vec3;overload;{$IFDEF DO_INLINE} inline;{$ENDIF}
function Ifthen(c:Boolean;const a,b:Vec4):Vec4;overload;{$IFDEF DO_INLINE} inline;{$ENDIF}

/// <summary>
///  Available only in the fragment shader, dFdx and dFdy return the partial derivative of expression p in x and y, respectively.
///  Deviatives are calculated using local differencing.
///  Expressions that imply higher order derivatives such as dFdx(dFdx(n)) have undefined results,
//   as do mixed-order derivatives such as dFdx(dFdy(n)).
//   It is assumed that the expression p is continuous and therefore,
//   expressions evaluated via non-uniform control flow may be undefined.
/// </summary>
//function dFdx(a:TVecType):TVecType;
//function dFdx(a:Vec2):Vec2;
//function dFdx(a:Vec3):Vec3;
//function dFdx(a:Vec4):Vec4;

function fwidth(const a: Vec2): TVecType;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;
function fwidth(const a: Vec3): TVecType;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;
function fwidth(const a: Vec4): TVecType;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;

// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
function hash(n:Double):Double;overload;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;
function hash(const n:vec2):vec2;overload;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;
function hash(const n:vec3):vec3;overload;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;
function hash(const n:vec4):vec4;overload;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;

type
  {$scopedenums on}
  TFrameProc   = procedure of object;
  TPixelProc   = function(var gl_FragCoord:Vec2): TColor32 of object;
  TLineProc    = procedure(y:Integer) of object;
  TProgressProc= procedure(Progress,Total:Integer) of object;

type
  TRenderMode = (Simple,Sections,Frames);

type
  TBuffer = record
    Bitmap     : TBitmap32;
    PixelProc  : TPixelProc;
    LineProc   : TLineProc;
    FrameProc  : TFrameProc;
    OnProgress : TProgressProc;
    procedure Render;
  end;

  TShader = class
  private
    LastFrame:Int64;
    FThreaded: TRenderMode;
    function GetFPS: Double;
    function GetName: string;virtual;
  protected
    UseBackBuffer:Boolean;
    StopWatch:TStopwatch;
    FrameTimer:TStopwatch;
  public
    iMouse:Vec4;
    Mouse:Vec3;
    Frame:Int64;
    Time: double;
    Resolution:Vec2;
    Buffers:TArray<TBuffer>;
    Image:TBuffer;

  class var
    tex : TArray<TBitmap32>;
    cubes:TArray<TTextureCube>;
  public
  var
    iGlobalTime:double;
    ThumbnailIndex:Integer;

    OnResize:TNotifyEvent;
    PixelsPerSecond : Double;
    class constructor Create;
    class destructor DestroyClass;
    class procedure LoadTexture(var bitmap:TBitmap32;const FileName:String);static;

    procedure SetTimeToSystemClock;
    constructor Create;virtual;
    destructor Destroy; override;
//    procedure RenderTo(aBitmap:TBitmap32);overload;virtual;
//    procedure RenderToBlocks(aBitmap:TBitmap32);virtual;
//    procedure RenderTo(bitmap:TBitmap32; const Rect:TRect);overload;
    property FPS:Double read GetFPS;
    property Mode:TRenderMode read FThreaded write FThreaded;
    procedure ResetFPS;
    procedure SetSize(aWidth,aHeight:integer);
    property Name:string read GetName;
    procedure SetBufferCount(n:integer);
    procedure Render;
    property PixelProc : TPixelProc read Image.PixelProc  write Image.PixelProc ;
    property LineProc  : TLineProc  read Image.LineProc   write Image.LineProc  ;
    property FrameProc : TFrameProc read Image.FrameProc  write Image.FrameProc ;
    property OnProgress:TProgressProc read Image.OnProgress write Image.OnProgress;
  end;
{
  TThreadedShader=class(TShader)
  public
    Shaders:array[0..3] of record
      Area:Vec4;
      Shader:TShader;
      Rect:TRect;
      Thread:TThread;
    end;
    procedure RenderThreads(bitmap:TBitmap32);
    constructor Create(aShader:TShader);reintroduce;
  end;
}
  TShaderList=class(TDictionary<string,TShader>)

  end;



procedure RegisterShader(name:String;c:TShader);
function GetShader(name:string):TShader;
function Shaders:TShaderList;

const
  vec2Black:Vec2=(x:0;y:0);
  vec2White:Vec2=(x:1;y:1);
  vec2Gray:Vec2=(x:0.5;y:0.5);
  vec2_3_3:Vec2=(x:3;y:3);

  vec3Black:Vec3=(x:0;y:0;z:0);
  vec3White:Vec3=(x:1;y:1;z:1);
  vec3Gray:Vec3=(x:0.5;y:0.5;z:0.5);
  vec3Green:Vec3=(x:0;y:1;z:0);
  vecBlack:Vec3=(x:0;y:0;z:0);
  vecWhite:Vec3=(x:1;y:1;z:1);
  vec3Red:Vec3=(x:1;y:0;z:0);

  vec4Black:Vec4=(x:0;y:0;z:0;w:0);
  vec4White:Vec4=(x:1;y:1;z:1;w:1);
  vec4Gray:Vec4=(x:0.5;y:0.5;z:0.5;w:0.5);

{
type
  TFrameThread=class(TThread)
  public
    IsDone:Boolean;
    Bitmap:TBitmap32;
    Time:Double;
    proc:TPixelProc;
    Width,Height:Integer;
  protected
    procedure Execute; override;
    procedure Resize;
  end;

type
  TFrames=record
    ItemIndex:Integer;
    Threads:Array[0..ThreadCount-1] of tframeThread;
    procedure Setproc(const Value: TPixelProc);
    property proc:TPixelProc write Setproc;
    procedure Init(p:TPixelProc;t:double);
    procedure SetSize(w,h:Integer);
    procedure Resume;
    procedure Suspend;
  end;
var
  Frames:TFrames;
 }

implementation

uses jpeg, pngimage, IoUtils;


var FShaders:TShaderList;

function Shaders:TShaderList;
begin
  if FShaders=nil then
    FShaders := TShaderList.Create;
  Result := FShaders;
end;

procedure RegisterShader(name:String;c:TShader);
begin
  c.ThumbnailIndex := Shaders.Count+1;
  Shaders.Add(name,c);
end;
function GetShader(name:string):TShader;
begin
  Shaders.TryGetValue(name,Result);
end;


function EnsureRange(const AValue, AMin, AMax: Single): Single;overload;{$IFDEF DO_INLINE} inline;{$ENDIF}
begin
  Result := AValue;
  assert(AMin <= AMax);
  if Result < AMin then
    Result := AMin;
  if Result > AMax then
    Result := AMax;
end;

function EnsureRange(const AValue, AMin, AMax: Double): Double;overload;{$IFDEF DO_INLINE} inline;{$ENDIF}
begin
  Result := AValue;
  assert(AMin <= AMax);
  if Result < AMin then
    Result := AMin;
  if Result > AMax then
    Result := AMax;
end;

constructor TShader.create;
begin
  inherited;
  Frame := 0;
//  UseBackBuffer := False;
  StopWatch := TStopwatch.StartNew;
  Image.Bitmap := TBitmap32.create;
  Image.Bitmap.ResamplerClassName := 'TLinearResampler';
  Image.Bitmap.ResamplerClassName := 'TNearestResampler';
  Image.Bitmap.SetSize(64, 64);
  SetBufferCount(0);

  Resolution.x := Image.Bitmap.Width;
  Resolution.y := Image.Bitmap.Height;
  //Frames.Proc := PixelProc;
  Mouse.x := 0.5;
  Mouse.y := 0.5;
  iMouse.x := Resolution.x * 0.5;
  iMouse.y := Resolution.y * 0.5;
end;

class constructor TShader.Create;
var s:String; c:integer; imgpath:string;
begin
  setlength(tex,0);
  SetCurrentDir( ExtractFilePath(ParamStr(0)));

  imgpath := 'images';

  if not TDirectory.Exists('images') then
  begin
    imgPath := '../images';
    if not TDirectory.Exists('images') then
    begin
      raise EFileNotFoundException.CreateFmt('Image folder not found. Expected images in %s or %s',[ExpandFileName('images/'), ExpandFileName('../images/')]);
    end;
  end;

  for s in TDirectory.GetFiles(imgpath,'tex*.jpg') do
  begin
    setlength(tex,System.Length(tex)+1);
    tex[high(tex)] := TBitmap32.create;
    LoadTexture(tex[high(tex)],s);
  end;
  for s in TDirectory.GetFiles(imgpath,'tex*.png') do
  begin
    setlength(tex,System.Length(tex)+1);
    tex[high(tex)] := TBitmap32.create;
    LoadTexture(tex[high(tex)],s);
  end;
  setlength(cubes,6);
  for c := 0 to 5 do
  begin
    if FileExists(format(imgpath+'/cube0%d_0.jpg',[c])) then
      cubes[c].Load(format(imgpath+'/cube0%d_?.jpg',[c]));
    if FileExists(format(imgpath+'/cube0%d_0.png',[c])) then
      cubes[c].Load(format(imgpath+'/cube0%d_?.png',[c]));
  end;
end;

destructor TShader.Destroy;
begin
//  Buffer.Free;
//  BackBuffer.Free;
  inherited;
end;

class destructor TShader.DestroyClass;
// var bmp:TBitmap32;c:TTextureCube;
begin
//  for bmp in tex do
//    bmp.free;
//
//  for c in cubes do
//    for bmp in c.Faces do
//      bmp.Free;

  inherited;
end;

function TShader.GetFPS: Double;
begin
  if StopWatch.ElapsedMilliseconds=0 then
    Result := 0
  else
    Result := (Frame - LastFrame)/StopWatch.ElapsedMilliseconds*1000;
end;



function TShader.GetName: string;
begin
  Result := self.ClassName.Substring(1)
end;

class procedure TShader.LoadTexture(var bitmap: TBitmap32; const FileName: String);
var
  jpg: tjpegImage;
  png: TPngImage;
begin
  if SameText(ExtractFileExt(filename),'.jpg') then
  begin
    jpg := tjpegImage.Create;
    try
      jpg.LoadFromFile(FileName);
      Bitmap.Assign(jpg);
    finally
      jpg.Free;
    end;
  end;


  if SameText(ExtractFileExt(filename),'.png') then
  begin
    png := tpngImage.Create;
    try
      png.LoadFromFile(FileName);
      Bitmap.Assign(png);
    finally
      png.Free;
    end;
  end;

end;

{
type
  TRenderThread=class(TThread)
  public
    Buffer:TBitmap32;
    x1,x2,y1,y2:Integer;
    proc:TPixelProc;
  protected
    procedure Execute; override;
  end;

  procedure TRenderThread.Execute;
  var x,y:Integer; fracCoord:Vec2;
  begin
    FreeOnTerminate := True;
    for y := y1 to y2 do
      for x := x1 to x2 do
      begin
        fracCoord.x := x;
        fracCoord.y := y;
        Buffer.Pixel[x,y] := proc(fracCoord);
      end;
    Terminate;
  end;


  procedure TFrameThread.Execute;
  var x,y:Integer; fracCoord:Vec2;
  begin
    FreeOnTerminate := True;
    while True do
    begin
      if Suspended then
        Continue;
      if assigned(proc) then
      begin
        self.Time := time + 0.4;
        Resize;
        for y := 0 to Bitmap.Height-1 do
          for x := 0 to Bitmap.Width-1 do
          begin
            fracCoord.x := x;
            fracCoord.y := y;
            Bitmap.Pixel[x,y] := proc(fracCoord);
          end;
        IsDone := True;
      end;

        repeat
          sleep(1);
        until (IsDone=false) or (not Assigned(proc));
    end;
    Terminate;
  end;
 }




{

procedure TShader.RenderTo(aBitmap: TBitmap32);
var
  px, py   : Integer;
  fracCoord: Vec2;
begin
//  updateFrame;
  Main.Render;
  if Assigned(FrameProc) then
    FrameProc;

  if not Assigned(PixelProc) then
    Exit;

    for py := 0 to Buffer.Height - 1 do
    begin
      if assigned(OnProgress) then
        OnProgress(py,Buffer.Height);

      if Assigned(LineProc) then
        LineProc(py);

      fracCoord.y := Buffer.Height - py - 1;
      for px := 0 to Buffer.Width - 1 do
      begin
        fracCoord.x := px;
        aBitmap.Pixel[px, py] := PixelProc(fracCoord);
//        Buffer.Pixel[px, py] := PixelProc(fracCoord);
      end;
    end;

//  Buffer.DrawTo(aBitmap);

  if UseBackBuffer then
    aBitmap.DrawTo(BackBuffer,0,0);

  inc(Frame);
end;


procedure TShader.RenderTo(bitmap: TBitmap32; const Rect: TRect);
var
  px, py   : Integer;
  fracCoord: Vec2;
begin
//  updateFrame;
  if Assigned(FrameProc) then
    FrameProc;

    for py := rect.Top to rect.Bottom-1 do
    begin
      if assigned(OnProgress) then
        OnProgress(py,rect.Height);

      if Assigned(LineProc) then
        LineProc(py);

      fracCoord.y := rect.Height - py - 1;
      for px := rect.Left to rect.Right-1 do
      begin
        fracCoord.x := px;
        Buffer.Pixel[px, py] := PixelProc(fracCoord);
      end;
    end;

  Buffer.DrawTo(bitmap);

  if UseBackBuffer then
    bitmap.DrawTo(BackBuffer,0,0);

  inc(Frame);
end;


procedure TShader.RenderToBlocks(aBitmap: TBitmap32);
var
  px, py   : Integer;
  fracCoord: Vec2;
  w, h: Integer;
  p: Integer;
  t: Integer;
  c: TColor32;
begin
//  updateFrame;
  if Assigned(FrameProc) then
    FrameProc;

  if not Assigned(PixelProc) then
    Exit;


  h := Buffer.Height;
  w := Buffer.Width;

//  updateFrame;
  p := 0;
  t := Buffer.Height * 4;

    for py := 0 to h - 1 do begin
      inc(p);
      if assigned(OnProgress) then  OnProgress(p,t);
      if Assigned(LineProc)   then  LineProc(py);

      if Odd(py) then begin
        fracCoord.y := h - py - 1;
        for px := 0 to w - 1 do begin
          if Odd(px) then begin
            fracCoord.x := px;
            c := PixelProc(fracCoord);
            aBitMap.FillRectS(px,py,px+2,py+2,c);
//            aBitmap.Pixel[px, py] := c;
          end;
        end;
      end;
    end;

    for py := 0 to h - 1 do begin
      inc(p);
      if assigned(OnProgress) then  OnProgress(p,t);
      if Assigned(LineProc)   then  LineProc(py);

      if not odd(py) then begin
        fracCoord.y := h - py - 1;
        for px := 0 to w - 1 do begin
          if Odd(px) then begin
            fracCoord.x := px;
            c := PixelProc(fracCoord);
            aBitmap.Pixel[px, py] := c;
          end;
        end;
      end;
    end;


    for py := 0 to h - 1 do begin
       inc(p);
      if assigned(OnProgress) then  OnProgress(p,t);
      if Assigned(LineProc)   then  LineProc(py);

     if Odd(py) then begin
        fracCoord.y := h - py - 1;
        for px := 0 to w - 1 do begin
          if not odd(px) then begin
            fracCoord.x := px;
            c := PixelProc(fracCoord);
            aBitmap.Pixel[px, py] := c;
          end;
        end;
      end;
    end;

    for py := 0 to h - 1 do begin
      inc(p);
      if assigned(OnProgress) then  OnProgress(p,t);
      if Assigned(LineProc)   then  LineProc(py);

      if not odd(py) then begin
        fracCoord.y := h - py - 1;
        for px := 0 to w - 1 do begin
          if not odd(px) then begin
            fracCoord.x := px;
            c := PixelProc(fracCoord);
            aBitmap.Pixel[px, py] := c;
          end;
        end;
      end;
    end;
//  Buffer.DrawTo(aBitmap);

  if UseBackBuffer then
    aBitmap.DrawTo(BackBuffer,0,0);

  inc(Frame);

end;

}


procedure TShader.Render;
var i:integer;
  tm:int64;
begin
  FrameTimer := TStopwatch.StartNew;

  for I := 0 to High(Buffers) do
    Buffers[I].Render;

  Image.Render;
  if UseBackBuffer then
    if System.Length(Buffers)>0 then
      Image.Bitmap.DrawTo(Buffers[0].Bitmap);

  inc(Frame);
  tm := FrameTimer.ElapsedMilliseconds;
  if tm>0 then
  begin
    PixelsPerSecond := PixelsPerSecond - (PixelsPerSecond/Frame);
    PixelsPerSecond := PixelsPerSecond + ((1000 * Image.Bitmap.Width * Image.Bitmap.Height / tm) / Frame);
  end;
  FrameTimer.Stop;
end;

procedure TShader.ResetFPS;
begin
  LastFrame := Frame;
  StopWatch.Reset;
  StopWatch.Start;
end;


procedure TShader.SetBufferCount(n: integer);
var i:integer;
begin
  SetLength(Buffers,n);
  for I := 0 to n-1 do
  begin
    Buffers[I].Bitmap := TBitmap32.create;
    Buffers[I].Bitmap.SetSize(Image.Bitmap.Width,Image.Bitmap.Height);
  end;
end;

procedure TShader.SetSize(aWidth, aHeight: integer);
var i:integer;
begin
  if (aWidth  = Resolution.x) and
     (aHeight = Resolution.y)
  then
    Exit;

  Resolution := Vec2.create(aWidth,aHeight);
  Image.Bitmap.SetSize(aWidth,aHeight);
  for I := Low(Buffers) to High(Buffers) do
    Buffers[I].Bitmap.SetSize(aWidth,aHeight);

  if Assigned(OnResize) then
    OnResize(self);
end;


procedure TShader.SetTimeToSystemClock;
begin
  iGlobalTime := StopWatch.GetTimeStamp/2500000;

//  Time := now*100000;
  Time := iGlobalTime;

end;



{
function fmod(a, b: extended): extended;
begin
  if IsZero(b) then
    Exit(0);

	Result := a - b * floor(a / b);
end;

function fmod(a, b: double): double;
begin
  if IsZero(b) then
    Exit(0);

	Result := a - b * floor(a / b);
end;
}

function fmod(a, b: single): single;overload;
{$IFDEF CPUx86}
asm
  fld dword ptr[b]
  fld dword ptr[a]
@r:
  fprem
  fstsw ax
  sahf
  jp @r
  fstp st(1)
end;
{$ELSE}
begin
  if IsZero(b) then
    Exit(0);

	Result := a - b * {math.floor}trunc(a / b);
end;
{$ENDIF}

function fmods(a, b: double): double;overload;
begin
  if IsZero(b) then
    Exit(0);
  if a>1e10 then
    Exit(0);
  if a<-1e10 then
    Exit(0);

	Result := a - b * math.floor(a / b);
end;


function fmod(a, b: double): double;overload;
{$IFDEF CPUx86}
asm
  fld qword ptr[b]
  fld qword ptr[a]
@r:
  fprem
  fstsw ax
  sahf
  jp @r
  fstp st(1)
end;
{$ELSE}
begin
  if IsZero(b) then
    Exit(0);
//  if a>1e10 then
//    Exit(0);
//  if a<-1e10 then
//    Exit(0);

	Result := a - b * {math.floor}trunc(a / b);
end;
{$ENDIF}


function fmod(a, b: extended): extended;overload;
begin
  if IsZero(b) then
    Exit(0);

	Result := a - b * {math.floor}trunc(a / b);
end;

/// <summary>
/// pow returns the value of x raised to the y power. i.e., xy. Results are undefined if x0 or if x0 and y0.
/// </summary>
function pow(x,y:double):double;
begin
  if IsNaN(x) then
    Exit(0.000001);

  if x<0 then
    x := -x;

  if (x=0) and (y<0) then
    Exit(0.000001);

  Result := Math.Power(x,y)
end;
function radians(degrees: double): double;
begin
  Result := (pi / 180) * degrees;
end;

function degrees(radians: double): double;
begin
  Result := (180 / pi) * radians;
end;

function exp2(x: double): double;
begin
  Result := Power(2,x);
end;

function log(x: double): double;overload;
begin
  if x<0 then
    x := -x
  else
    if x=0 then
      exit(0);

  Result := ln(x);
end;

function log(x: vec2): vec2;overload;
begin
  Result.x := ln(x.x);
  Result.y := ln(x.y);
end;
function log(x: vec3): vec3;overload;
begin
  Result.x := ln(x.x);
  Result.y := ln(x.y);
  Result.z := ln(x.z);
end;

function log2(x: single): single;
begin
  if x<0 then
    x := -x
  else
    if x=0 then
      exit(0);

  Result := Math.log2(x);
end;
function log2(x: double): double;
begin
  if x<0 then
    x := -x
  else
    if x=0 then
      exit(0);

  Result := Math.log2(x);
end;

function inversesqrt(x: single): single;
begin
  if x=0 then
    Exit(0)
  else
    if x<0 then
      x:=-x;

  Result := 1 / System.Sqrt(x);
end;

function inversesqrt(x: double): double;
begin
  if x=0 then
    Exit(0)
  else
    if x<0 then
      x:=-x;

  Result := 1 / System.Sqrt(x);
end;

(*
// taken from:
// http://delphigamedev.com/forums/viewtopic.php?f=11&t=130
// it actually contains a bug, because this only works for 32 bits floats
function inversesqrt(x: single): single;
var
   XHalf: Single;
   I: Integer Absolute X;
   X2: Single Absolute I;
   XB: Single;
begin
  XB:= X;
  XHalf:= 0.5 * X;
  I:= $5f3759df - (I SHR 1);
  X:= X2 * (1.5 - XHalf * X2 * X2);
  Result:= XB * X;
end;

function inversesqrt(x: double): double;
var
   XHalf: Double;
   I: Int64 Absolute X;
   X2: Double Absolute I;
   XB: Double;
begin
  XB:= X;
  XHalf:= 0.5 * X;
  I:= $5fe6eb50c7b537a9 - (I SHR 1);
  X:= X2 * (1.5 - XHalf * X2 * X2);
  Result:= XB * X;
end;
*)


function sign(x: double): double;
begin
  if x > 0 then
    Result := 1
  else if x < 0 then
    Result := -1
  else
    Result := 0;
end;

function fract(x: double): double;
begin
//  Result := x - Math.Floor(x);
//  if IsNan(x) then  Exit(0);
//  if x>1e30 then
//    exit(0);
//  if x<-1e30 then
//    exit(0);

  Result := Trunc(X);
  if (X < 0) and (X - Result <> 0) then
    Result := Result-1;
   Result := x - Result;
end;

function fract(const a: vec2): vec2;
begin
//  Result.x := x.x - Math.Floor(x.x);
//  Result.y := x.y - Math.Floor(x.y);

  Result.x := Trunc(a.x); if (a.x < 0) and (a.x - Result.x<>0) then Result.x := Result.x -1; Result.x := a.x - Result.x;
  Result.y := Trunc(a.y); if (a.y < 0) and (a.y - Result.y<>0) then Result.y := Result.y -1; Result.y := a.y - Result.y;
end;

function fract(const a: vec3): vec3;
begin
//  Result.x := x.x - Math.Floor(x.x);
//  Result.y := x.y - Math.Floor(x.y);
//  Result.z := x.z - Math.Floor(x.z);
  Result.x := Trunc(a.x); if (a.x < 0) and (a.x - Result.x<>0) then Result.x := Result.x -1; Result.x := a.x - Result.x;
  Result.y := Trunc(a.y); if (a.y < 0) and (a.y - Result.y<>0) then Result.y := Result.y -1; Result.y := a.y - Result.y;
  Result.z := Trunc(a.z); if (a.z < 0) and (a.z - Result.z<>0) then Result.z := Result.z -1; Result.z := a.z - Result.z;


end;


function fract(const a: vec4): vec4;
begin
//  Result.x := x.x - Math.Floor(x.x);
//  Result.y := x.y - Math.Floor(x.y);
//  Result.z := x.z - Math.Floor(x.z);
//  Result.w := x.w - Math.Floor(x.w);

  Result.x := Trunc(a.x); if (a.x < 0) and (a.x - Result.x<>0) then Result.x := Result.x -1; Result.x := a.x - Result.x;
  Result.y := Trunc(a.y); if (a.y < 0) and (a.y - Result.y<>0) then Result.y := Result.y -1; Result.y := a.y - Result.y;
  Result.z := Trunc(a.z); if (a.z < 0) and (a.z - Result.z<>0) then Result.z := Result.z -1; Result.z := a.z - Result.z;
  Result.w := Trunc(a.w); if (a.w < 0) and (a.w - Result.w<>0) then Result.w := Result.w -1; Result.w := a.w - Result.w;

end;


//function floor(x: Double): Double;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;       { return x - cmath::floor(x); }
//begin
//  Result := Math.Floor(x);
//end;

function floor(const a: Vec2): Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;       { return x - cmath::floor(x); }
begin
//  Result.x :=Math.Floor(x.x);
//  Result.y :=Math.Floor(x.y);

  Result.x := Trunc(a.x); if (a.x < 0) and (a.x-Result.x<>0) then Result.x := Result.x-1;
  Result.y := Trunc(a.y); if (a.y < 0) and (a.y-Result.y<>0) then Result.y := Result.y-1;
end;

function floor(const a: Vec3): Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;       { return x - cmath::floor(x); }
begin
{  Result.x := Math.Floor(x.x);
  Result.y := Math.Floor(x.y);
  Result.z := Math.Floor(x.z);
  }

//  Result.x := IntegerTrunc(X.x); if Frac(X.x) < 0 then Result.x := Result.x-1;
//  Result.y := IntegerTrunc(X.y); if Frac(X.y) < 0 then Result.y := Result.y-1;
//  Result.z := IntegerTrunc(X.z); if Frac(X.z) < 0 then Result.z := Result.z-1;

  Result.x := Trunc(a.x); if (a.x < 0) and (a.x-Result.x<>0) then Result.x := Result.x-1;
  Result.y := Trunc(a.y); if (a.y < 0) and (a.y-Result.y<>0) then Result.y := Result.y-1;
  Result.z := Trunc(a.z); if (a.z < 0) and (a.z-Result.z<>0) then Result.z := Result.z-1;
end;

function floor(const a: Vec4): Vec4;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;       { return x - cmath::floor(x); }
begin
{
  Result.x := Math.Floor(x.x);
  Result.y := Math.Floor(x.y);
  Result.z := Math.Floor(x.z);
  Result.w := Math.Floor(x.w);
}

//  Result.x := IntegerTrunc(X.x); if Frac(X.x) < 0 then Result.x := Result.x-1;
//  Result.y := IntegerTrunc(X.y); if Frac(X.y) < 0 then Result.y := Result.y-1;
//  Result.z := IntegerTrunc(X.z); if Frac(X.z) < 0 then Result.z := Result.z-1;
//  Result.w := IntegerTrunc(X.w); if Frac(X.w) < 0 then Result.w := Result.w-1;

  Result.x := Trunc(a.x); if (a.x < 0) and (a.x-Result.x<>0) then Result.x := Result.x-1;
  Result.y := Trunc(a.y); if (a.y < 0) and (a.y-Result.y<>0) then Result.y := Result.y-1;
  Result.z := Trunc(a.z); if (a.z < 0) and (a.z-Result.z<>0) then Result.z := Result.z-1;
  Result.w := Trunc(a.w); if (a.w < 0) and (a.w-Result.w<>0) then Result.w := Result.w-1;

end;


function &mod(a, b: double): double;
{$IFDEF CPUx86}
asm
  fld qword ptr[b]
  fld qword ptr[a]
@r:
  fprem
  fstsw ax
  sahf
  jp @r
  fstp st(1)
end;
{$ELSE}
begin
  if IsZero(b) then
    Exit(0);

	Result := a - b * math.Floor(a / b);
end;
{$ENDIF}

function &mod(const a, b: Vec2): Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;     { return T(cmath::fmod(x, y)); }
begin
  Result.x := WvN.DelphiShader.Shader.FMod(a.x, b.x);
  Result.y := WvN.DelphiShader.Shader.FMod(a.y, b.y);
end;

function &mod(const a, b: Vec3): Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;     { return T(cmath::fmod(x, y)); }
begin
  Result.x := WvN.DelphiShader.Shader.fmod(a.x, b.x);
  Result.y := WvN.DelphiShader.Shader.fmod(a.y, b.y);
  Result.z := WvN.DelphiShader.Shader.fmod(a.z, b.z);
end;

function &mod(const a, b: Vec4): Vec4;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;     { return T(cmath::fmod(x, y)); }
begin
  Result.x := WvN.DelphiShader.Shader.fmod(a.x, b.x);
  Result.y := WvN.DelphiShader.Shader.fmod(a.y, b.y);
  Result.z := WvN.DelphiShader.Shader.fmod(a.z, b.z);
  Result.w := WvN.DelphiShader.Shader.fmod(a.w, b.w);
end;

function &mod(const a: Vec2;b:TVecType): Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;     { return T(cmath::fmod(x, y)); }
begin
//  Result.x := fmod(a.x, b);
//  Result.y := fmod(a.y, b);
  Result.x := a.x - b * floor(a.x / b);
  Result.y := a.y - b * floor(a.y / b);
end;


function &mod(const a: Vec3;b:TVecType): Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;     { return T(cmath::fmod(x, y)); }
begin
  Result.x := WvN.DelphiShader.Shader.fmod(a.x, b);
  Result.y := WvN.DelphiShader.Shader.fmod(a.y, b);
  Result.z := WvN.DelphiShader.Shader.fmod(a.z, b);
end;

function &mod(const a: Vec4;b:TVecType): Vec4;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;     { return T(cmath::fmod(x, y)); }
begin
  Result.x := WvN.DelphiShader.Shader.fmod(a.x, b);
  Result.y := WvN.DelphiShader.Shader.fmod(a.y, b);
  Result.z := WvN.DelphiShader.Shader.fmod(a.z, b);
  Result.w := WvN.DelphiShader.Shader.fmod(a.w, b);
end;


function Cross(const a,b: Vec3): Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF}
begin
  Result := Vec3.create(
    a.y * b.z - a.z * b.y,
    a.z * b.x - a.x * b.z,
    a.x * b.y - a.y * b.x
  );

end;


function min(x, y: double): double;
begin
  if y < x then
    Result := y
  else
    Result := x;
end;

function max(x, y: double): double;
begin
  if x < y then
    Result := y
  else
    Result := x;
end;

function clamp(x:double): Double;
begin
  if x>1 then
    Result := 1
  else
    if x<0 then
      Result := 0
    else
      Result := x
end;

function clamp(x, minVal, maxVal: Double): Double;
begin
  //  Result := Math.min(Math.max(x, minVal), maxVal);
  if x>maxVal then
    Result := maxVal
  else
    if x<minVal then
      Result := minVal
    else
      Result := x
end;


function mix(x, y, a: Double): Double;
begin
  Result := x * (1 - a) + y * a;
end;

function step(edge, x: Double): Double;
begin
  if x <= edge then
    Result := 0
  else
    Result := 1;
end;



function distance(p0, p1: double): double;
begin
  Result := system.sqrt(system.Abs(p0) - System.abs(p1));
end;

function distance(const a,b: Vec2): double;
var dx,dy:double;
begin
  dx := a.x - b.x;
  dy := a.y - b.y;
  Result := system.sqrt(dx*dx + dy*dy);
end;

function distance(const a,b: Vec3): double;
var dx,dy,dz:double;
begin
  dx := a.x - b.x;
  dy := a.y - b.y;
  dz := a.z - b.z;
  Result := system.sqrt(dx*dx + dy*dy + dz*dz);
end;

function distance(const a,b: Vec4): double;{$IFDEF DO_INLINE} inline;{$ENDIF} overload; { return length(p0-p1); }
var dx,dy,dz,dw:double;
begin
  dx := a.x - b.x;
  dy := a.y - b.y;
  dz := a.z - b.z;
  dw := a.w - b.w;
  Result := system.sqrt(dx*dx + dy*dy + dz*dz + dw*dw);
end;

function Dot(x, y: Single): Single;
begin
  Result := x * y;
end;


function dot(x, y: double): double;
begin
  Result := x * y;
end;

function normalize(x:double): double;
begin
  if x<0 then
    Result := -1
  else
    Result := 1;
end;


function reflect(I, n: double): double;
begin
  Result := I - 2 * n * I * n;
end;

function reflect(const I, n: Vec3): Vec3;
begin
{  Result.x := I.x - 2 * n.x * I.x * n.x;
  Result.y := I.y - 2 * n.y * I.y * n.y;
  Result.z := I.z - 2 * n.z * I.z * n.z;
}
  Result.x := I.x - n.x * i.x * n.x * n.x;
  Result.y := I.y - n.y * i.y * n.y * n.y;
  Result.z := I.z - n.z * i.z * n.z * n.z;
end;



function FaceForward(const N,I,NRef:TVecType): TVecType;overload;
begin
  if dot(Nref, I) < 0 then
    Result := N
  else
    Result := -N
end;

function FaceForward(const N,I,NRef:Vec2): Vec2; overload;
begin
  if dot(Nref, I) < 0 then
    Result := N
  else
    Result := -N
end;

function FaceForward(const N,I,NRef:Vec3): Vec3; overload;
begin
  if dot(Nref, I) < 0 then
    Result := N
  else
    Result := -N
end;

function FaceForward(const N,I,NRef:Vec4): Vec4; overload;
begin
  if dot(Nref, I) < 0 then
    Result := N
  else
    Result := -N
end;


function Refract(const I, N:TVecType; eta:Double):TVecType;overload;
var k:double; d:TVecType;
begin
  d := N * I;
  k := 1.0 - eta * eta * (1.0 - d * d);
  if k < 0.0 then
    Result := 0.0
  else
    Result := eta * I - (eta * d + system.sqrt(k)) * N
end;

function Refract(const I, N:vec2; eta:Double):vec2;overload;
var k:double; d:float;
begin
  d := dot(N , I);
  k := 1.0 - eta * eta * (1.0 - d * d);
  if k < 0.0 then
    Result := vec2Black
  else
    Result := eta * I - (eta * d + system.sqrt(k)) * N
end;

function Refract(const I, N:vec3; eta:Double):vec3;overload;
var k:double; d:double;
begin
  d := dot(N , I);
  k := 1 - eta * eta * (1 - d * d);
  if k < 0 then
    Result := vec3Black
  else
    Result := eta * I - (eta * d + system.sqrt(k)) * N
end;

function Refract(const I, N:vec4; eta:Double):vec4;overload;
var k:double; d:double;
begin
  d := dot(N , I);
  k := 1.0 - eta * eta * (1.0 - d * d);
  if k < 0.0 then
    Result := vec4Black
  else
    Result := eta * I - (eta * d + system.sqrt(k)) * N
end;



{------------------------------------------------------------------------------}

function min(const x, y: vec2): vec2;
begin
  Result.x := Math.min(x.x,y.x);
  Result.y := Math.min(x.y,y.y);
end;

function min(const x, y: vec3) : vec3;
begin
  Result.x := Math.min(x.x,y.x);
  Result.y := Math.min(x.y,y.y);
  Result.z := Math.min(x.z,y.z);
end;

function min(const x, y: vec4) : vec4;
begin
  Result.x := Math.min(x.x,y.x);
  Result.y := Math.min(x.y,y.y);
  Result.z := Math.min(x.z,y.z);
  Result.w := Math.min(x.w,y.w);
end;

function max(const x, y: vec2): vec2;
begin
  Result.x := Math.max(x.x,y.x);
  Result.y := Math.max(x.y,y.y);
end;

function max(const x, y: vec3): vec3;
begin
  Result.x := Math.max(x.x,y.x);
  Result.y := Math.max(x.y,y.y);
  Result.z := Math.max(x.z,y.z);
end;

function max(const x, y: vec4): vec4;
begin
  Result.x := Math.max(x.x,y.x);
  Result.y := Math.max(x.y,y.y);
  Result.z := Math.max(x.z,y.z);
  Result.w := Math.max(x.w,y.w);
end;

function maxComp(const p: vec3) : double;
begin
  Result := Math.max(p.x,Math.max(p.y,p.z));
end;

function pow(const x, y: Vec2): Vec2;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;
begin
  Result.x := Power(x.x,y.x);
  Result.y := Power(x.y,y.y);
end;
function pow(const a, b: Vec3): Vec3;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;
begin
  Result.x := Power(a.x,b.x);
  Result.y := Power(a.y,b.y);
  Result.z := Power(a.z,b.z);
end;
function pow(const x, y: Vec4): Vec4;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;
begin
  Result.x := Power(x.x,y.x);
  Result.y := Power(x.y,y.y);
  Result.z := Power(x.z,y.z);
  Result.w := Power(x.w,y.w);
end;

{
function f_root(i:single;n:integer):single;
var l:longint;
begin
 l:=longint((@i)^);
 l:=l-$3F800000;l:=l shr (n-1);
 l:=l+$3F800000;
 result:=single((@l)^);
end;
}


//function sqrt(const a: Single): Single;
//begin
//  if a<=0 then
//    Exit(0)
//  else
//    Result := sqrtFast(a);
//end;

function sqrt(const a: Double): Double;
begin
//  if a<=0 then
//    Exit(0)
//  else

    Result := system.Sqrt(a);
end;

function sqrt(const a: Vec2): Vec2;
begin
  result.x := System.sqrt(a.x);
  result.y := System.sqrt(a.y);
end;

function sqrt(const a: Vec3): Vec3;
begin
  result.x := System.sqrt(a.x);
  result.y := System.sqrt(a.y);
  result.z := System.sqrt(a.z);
end;

function sqrt(const a: Vec4): Vec4;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;
begin
  result.x := System.sqrt(a.x);
  result.y := System.sqrt(a.y);
  result.z := System.sqrt(a.z);
  result.w := System.sqrt(a.w);
end;

function sqrts(const a: TVecType): TVecType;
begin
  if a<0 then result := -1 else result := System.sqrt(a);
//  if a<0 then result := 0 else result := System.sqrt(a);
end;


function sqrts(const a: Vec2): Vec2;
begin
  if a.x<0 then result.x := 0 else result.x := System.sqrt(a.x);
  if a.y<0 then result.y := 0 else result.y := System.sqrt(a.y);
end;


function sqrts(const a: Vec3): Vec3;
begin
  if a.x<0 then result.x := 0 else result.x := System.sqrt(a.x);
  if a.y<0 then result.y := 0 else result.y := System.sqrt(a.y);
  if a.z<0 then result.z := 0 else result.z := System.sqrt(a.z);
end;

function sqrts(const a: Vec4): Vec4;
begin
  if a.x<0 then result.x := 0 else result.x := System.sqrt(a.x);
  if a.y<0 then result.y := 0 else result.y := System.sqrt(a.y);
  if a.z<0 then result.z := 0 else result.z := System.sqrt(a.z);
  if a.w<0 then result.w := 0 else result.w := System.sqrt(a.w);
end;





function clamp(const x, minVal, maxVal: vec2): vec2;
begin
  Result.x := Math.min(Math.max(x.x, minVal.x), maxVal.x);
  Result.y := Math.min(Math.max(x.y, minVal.y), maxVal.y);
end;

function clamp(const x, minVal, maxVal: vec3): vec3;
begin
  Result.x := Math.min(Math.max(x.x, minVal.x), maxVal.x);
  Result.y := Math.min(Math.max(x.y, minVal.y), maxVal.y);
  Result.z := Math.min(Math.max(x.z, minVal.z), maxVal.z);
end;

function clamp(const x:Vec2; minVal, maxVal: Double): Vec2; overload;{$IFDEF DO_INLINE} inline;{$ENDIF}  { return glsl::min(glsl::max(x,minVal),maxVal); }
begin
  Result.x := Math.min(Math.max(x.x, minVal), maxVal);
  Result.y := Math.min(Math.max(x.y, minVal), maxVal);
end;


function clamp(const x:Vec3; minVal, maxVal: Double): Vec3; overload; inline; { return glsl::min(glsl::max(x,minVal),maxVal); }
begin

  Result.x := Math.min(Math.max(x.x, minVal), maxVal);
  Result.y := Math.min(Math.max(x.y, minVal), maxVal);
  Result.z := Math.min(Math.max(x.z, minVal), maxVal);

//  Result := x;
//  if x.x<minVal then Result.x := minVal else if x.x >maxVal then Result.x := maxVal;
//  if x.y<minVal then Result.y := minVal else if x.y >maxVal then Result.y := maxVal;
//  if x.z<minVal then Result.z := minVal else if x.z >maxVal then Result.z := maxVal;

//  Result.x := Math.EnsureRange(x.x,minVal,maxVal);
//  Result.y := Math.EnsureRange(x.y,minVal,maxVal);
//  Result.z := Math.EnsureRange(x.z,minVal,maxVal);
end;

function clamp(const x:Vec4; minVal, maxVal: Double): Vec4; overload;{$IFDEF DO_INLINE} inline;{$ENDIF}  { return glsl::min(glsl::max(x,minVal),maxVal); }
begin
  Result.x := Math.min(Math.max(x.x, minVal), maxVal);
  Result.y := Math.min(Math.max(x.y, minVal), maxVal);
  Result.z := Math.min(Math.max(x.z, minVal), maxVal);
  Result.w := Math.min(Math.max(x.w, minVal), maxVal);
end;


function mix(const x, y, a: vec2): vec2;
begin
  Result.x := x.x * (1 - a.x) + y.x * a.x;
  Result.y := x.y * (1 - a.y) + y.y * a.y;
end;

function mix(const x, y, a: vec3): vec3;
begin
  Result.x := x.x * (1 - a.x) + y.x * a.x;
  Result.y := x.y * (1 - a.y) + y.y * a.y;
  Result.z := x.z * (1 - a.z) + y.z * a.z;
end;

function mix(const x, y, a: vec4): vec4;
begin
  Result.x := x.x * (1 - a.x) + y.x * a.x;
  Result.y := x.y * (1 - a.y) + y.y * a.y;
  Result.z := x.z * (1 - a.z) + y.z * a.z;
  Result.w := x.w * (1 - a.w) + y.w * a.w;
end;

function mix(const x, y:Vec2; a: TVecType): Vec2;
begin
  Result.x := x.x * (1 - a) + y.x * a;
  Result.y := x.y * (1 - a) + y.y * a;
end;

function mix(const x, y:Vec3; a: TVecType): Vec3;
begin
  Result.x := x.x * (1 - a) + y.x * a;
  Result.y := x.y * (1 - a) + y.y * a;
  Result.z := x.z * (1 - a) + y.z * a;
end;


function mix(const x, y:Vec4; a: TVecType): Vec4;
begin
  Result.x := x.x * (1 - a) + y.x * a;
  Result.y := x.y * (1 - a) + y.y * a;
  Result.z := x.z * (1 - a) + y.z * a;
  Result.w := x.w * (1 - a) + y.w * a;
end;

function step(const edge, x: vec2): vec2;
begin
  if x.x<=edge.x then result.x := 0 else result.x := 1;
  if x.y<=edge.y then result.y := 0 else result.y := 1;
end;

function step(const edge, x: vec3): vec3;
begin
  if x.x<=edge.x then result.x := 0 else result.x := 1;
  if x.y<=edge.y then result.y := 0 else result.y := 1;
  if x.z<=edge.z then result.z := 0 else result.z := 1;
end;

function step(const edge, x: vec4): vec4;
begin
  if x.x<=edge.x then result.x := 0 else result.x := 1;
  if x.y<=edge.y then result.y := 0 else result.y := 1;
  if x.z<=edge.z then result.z := 0 else result.z := 1;
  if x.w<=edge.w then result.w := 0 else result.w := 1;
end;

function length(x: double): double;
begin
  Result := system.Abs(x)
end;

function length(const x: vec2): double;
begin
  Result := System.Sqrt( x.x * x.x
                       + x.y * x.y);
end;

function Length(const x: Vec3): Double;
begin
  Result := System.Sqrt(
                  x.x * x.x
                + x.y * x.y
                + x.z * x.z
                );
end;

function Length(const x: Vec4): Double;
begin
  Result := System.sqrt( x.x * x.x
                + x.y * x.y
                + x.z * x.z
                + x.w * x.w);
end;

function length_sq(const x: Vec2): Double;
begin
  Result := x.x * x.x
          + x.y * x.y;
end;


function length_sq(const x: Vec3): Double;
begin
  Result := x.x * x.x
          + x.y * x.y
          + x.z * x.z;
end;


{ Vec3 }

class operator Vec3.Add(const a, b: Vec3): Vec3;
begin
  Result.x := a.x + b.x;
  Result.y := a.y + b.y;
  Result.z := a.z + b.z;
end;

function Vec3.Abs: Vec3;
begin
  Result.x := system.Abs(x);
  Result.y := system.Abs(y);
  Result.z := system.Abs(z);
end;

class operator Vec3.Add(const a: Vec3; b: TVecType): Vec3;
begin
  Result.x := a.x + b;
  Result.y := a.y + b;
  Result.z := a.z + b;
end;

constructor Vec3.create(aX: TVecType; const yz: Vec2);
begin
  x := x;
  y := yz.x;
  z := yz.y;
end;

constructor Vec3.create(const xy: Vec2; az: TVecType);
begin
  x := xy.x;
  y := xy.y;
  z := az;
end;

constructor Vec3.create(ax: TVecType);
begin
  x := ax;
  y := ax;
  z := ax;
end;

constructor Vec3.create(ax, ay, az: TVecType);
begin
  x := ax;
  y := ay;
  z := az;
end;

function Vec3.getxx: Vec2; begin   Result.x := x;   Result.y := x;  end;
function Vec3.getxy: Vec2; begin   Result.x := x;   Result.y := y;  end;
function Vec3.getxz: Vec2; begin   Result.x := x;   Result.y := z;  end;
function Vec3.getyx: Vec2; begin   Result.x := y;   Result.y := x;  end;
function Vec3.getyy: Vec2; begin   Result.x := y;   Result.y := y;  end;
function Vec3.getyz: Vec2; begin   Result.x := y;   Result.y := z;  end;
function Vec3.getzx: Vec2; begin   Result.x := z;   Result.y := x;  end;
function Vec3.getzy: Vec2; begin   Result.x := z;   Result.y := y;  end;
function Vec3.getzz: Vec2; begin   Result.x := z;   Result.y := z;  end;
function Vec3.getxxx: Vec3; begin   Result.x := x;   Result.y := x;   Result.z := x;  end;
function Vec3.getxxy: Vec3; begin   Result.x := x;   Result.y := x;   Result.z := y;  end;
function Vec3.getxxz: Vec3; begin   Result.x := x;   Result.y := x;   Result.z := z;  end;
function Vec3.getxyx: Vec3; begin   Result.x := x;   Result.y := y;   Result.z := x;  end;
function Vec3.getxyy: Vec3; begin   Result.x := x;   Result.y := y;   Result.z := y;  end;
function Vec3.getxyz: Vec3; begin   Result.x := x;   Result.y := y;   Result.z := z;  end;
function Vec3.getxzx: Vec3; begin   Result.x := x;   Result.y := z;   Result.z := x;  end;
function Vec3.getxzy: Vec3; begin   Result.x := x;   Result.y := z;   Result.z := y;  end;
function Vec3.getxzz: Vec3; begin   Result.x := x;   Result.y := z;   Result.z := z;  end;
function Vec3.getyxx: Vec3; begin   Result.x := y;   Result.y := x;   Result.z := x;  end;
function Vec3.getyxy: Vec3; begin   Result.x := y;   Result.y := x;   Result.z := y;  end;
function Vec3.getyxz: Vec3; begin   Result.x := y;   Result.y := x;   Result.z := z;  end;
function Vec3.getyyx: Vec3; begin   Result.x := y;   Result.y := y;   Result.z := x;  end;
function Vec3.getyyy: Vec3; begin   Result.x := y;   Result.y := y;   Result.z := y;  end;
function Vec3.getyyz: Vec3; begin   Result.x := y;   Result.y := y;   Result.z := z;  end;
function Vec3.getyzx: Vec3; begin   Result.x := y;   Result.y := z;   Result.z := x;  end;
function Vec3.getyzy: Vec3; begin   Result.x := y;   Result.y := z;   Result.z := y;  end;
function Vec3.getyzz: Vec3; begin   Result.x := y;   Result.y := z;   Result.z := z;  end;
function Vec3.getyzzz:pVec4;begin   Result := @vec4Black;
                                    Result.x := y;   Result.y := z;   Result.z := z;  Result.w := z
end;

function Vec3.getzxx: Vec3; begin   Result.x := z;   Result.y := x;   Result.z := x;  end;
function Vec3.getzxy: Vec3; begin   Result.x := z;   Result.y := x;   Result.z := y;  end;
function Vec3.getzxz: Vec3; begin   Result.x := z;   Result.y := x;   Result.z := z;  end;
function Vec3.getzyx: Vec3; begin   Result.x := z;   Result.y := y;   Result.z := x;  end;
function Vec3.getzyy: Vec3; begin   Result.x := z;   Result.y := y;   Result.z := y;  end;
function Vec3.getzyz: Vec3; begin   Result.x := z;   Result.y := y;   Result.z := z;  end;
function Vec3.getzzx: Vec3; begin   Result.x := z;   Result.y := z;   Result.z := x;  end;
function Vec3.getzzy: Vec3; begin   Result.x := z;   Result.y := z;   Result.z := y;  end;
function Vec3.getzzz: Vec3; begin   Result.x := z;   Result.y := z;   Result.z := z;  end;

procedure Vec3.setxx (const a: Vec2); begin Self.x := a.x; Self.x := a.y; end;
procedure Vec3.setxy (const a: Vec2); begin Self.x := a.x; Self.y := a.y; end;
procedure Vec3.setxz (const a: Vec2); begin Self.x := a.x; Self.z := a.y; end;
procedure Vec3.setyx (const a: Vec2); begin Self.y := a.x; Self.x := a.y; end;
procedure Vec3.setyy (const a: Vec2); begin Self.y := a.x; Self.y := a.y; end;
procedure Vec3.setyz (const a: Vec2); begin Self.y := a.x; Self.z := a.y; end;
procedure Vec3.setzx (const a: Vec2); begin Self.z := a.x; Self.x := a.y; end;
procedure Vec3.setzy (const a: Vec2); begin Self.z := a.x; Self.y := a.y; end;
procedure Vec3.setzz (const a: Vec2); begin Self.z := a.x; Self.z := a.y; end;
procedure Vec3.setxxx(const a: Vec3); begin Self.x := a.x; Self.x := a.y; Self.x := a.z;  end;
procedure Vec3.setxxy(const a: Vec3); begin Self.x := a.x; Self.x := a.y; Self.y := a.z;  end;
procedure Vec3.setxxz(const a: Vec3); begin Self.x := a.x; Self.x := a.y; Self.z := a.z;  end;
procedure Vec3.setxyx(const a: Vec3); begin Self.x := a.x; Self.y := a.y; Self.x := a.z;  end;
procedure Vec3.setxyy(const a: Vec3); begin Self.x := a.x; Self.y := a.y; Self.y := a.z;  end;
procedure Vec3.setxyz(const a: Vec3); begin Self.x := a.x; Self.y := a.y; Self.z := a.z;  end;
procedure Vec3.setxzx(const a: Vec3); begin Self.x := a.x; Self.z := a.y; Self.x := a.z;  end;
procedure Vec3.setxzy(const a: Vec3); begin Self.x := a.x; Self.z := a.y; Self.y := a.z;  end;
procedure Vec3.setxzz(const a: Vec3); begin Self.x := a.x; Self.z := a.y; Self.z := a.z;  end;
procedure Vec3.setyxx(const a: Vec3); begin Self.y := a.x; Self.x := a.y; Self.x := a.z;  end;
procedure Vec3.setyxy(const a: Vec3); begin Self.y := a.x; Self.x := a.y; Self.y := a.z;  end;
procedure Vec3.setyxz(const a: Vec3); begin Self.y := a.x; Self.x := a.y; Self.z := a.z;  end;
procedure Vec3.setyyx(const a: Vec3); begin Self.y := a.x; Self.y := a.y; Self.x := a.z;  end;
procedure Vec3.setyyy(const a: Vec3); begin Self.y := a.x; Self.y := a.y; Self.y := a.z;  end;
procedure Vec3.setyyz(const a: Vec3); begin Self.y := a.x; Self.y := a.y; Self.z := a.z;  end;
procedure Vec3.setyzx(const a: Vec3); begin Self.y := a.x; Self.z := a.y; Self.x := a.z;  end;
procedure Vec3.setyzy(const a: Vec3); begin Self.y := a.x; Self.z := a.y; Self.y := a.z; end;
procedure Vec3.setyzz(const a: Vec3); begin Self.y := a.x; Self.z := a.y; Self.z := a.z; end;
procedure Vec3.setzxx(const a: Vec3); begin Self.z := a.x; Self.x := a.y; Self.x := a.z;  end;
procedure Vec3.setzxy(const a: Vec3); begin Self.z := a.x; Self.x := a.y; Self.y := a.z;  end;
procedure Vec3.setzxz(const a: Vec3); begin Self.z := a.x; Self.x := a.y; Self.z := a.z;  end;
procedure Vec3.setzyx(const a: Vec3); begin Self.z := a.x; Self.y := a.y; Self.x := a.z;  end;
procedure Vec3.setzyy(const a: Vec3); begin Self.z := a.x; Self.y := a.y; Self.y := a.z;  end;
procedure Vec3.setzyz(const a: Vec3); begin Self.z := a.x; Self.y := a.y; Self.z := a.z;  end;
procedure Vec3.setzzx(const a: Vec3); begin Self.z := a.x; Self.z := a.y; Self.x := a.z;  end;
procedure Vec3.setzzy(const a: Vec3); begin Self.z := a.x; Self.z := a.y; Self.y := a.z;  end;
procedure Vec3.setzzz(const a: Vec3); begin Self.z := a.x; Self.z := a.y; Self.z := a.z;  end;
procedure Vec3.setyzzz(const a: pVec4);begin self.y := a.x; self.z := a.y;  end;


function Vec3.getbb: Vec2; begin   Result.x:= b;   Result.y := b;  end;
function Vec3.getbg: Vec2; begin   Result.x:= b;   Result.y := g;  end;
function Vec3.getbr: Vec2; begin   Result.x:= b;   Result.y := r;  end;
function Vec3.getgb: Vec2; begin   Result.x:= g;   Result.y := b;  end;
function Vec3.getgg: Vec2; begin   Result.x:= g;   Result.y := g;  end;
function Vec3.getgr: Vec2; begin   Result.x:= g;   Result.y := r;  end;
function Vec3.getrb: Vec2; begin   Result.x:= r;   Result.y := b;  end;
function Vec3.getrg: Vec2; begin   Result.x:= r;   Result.y := g;  end;
function Vec3.getrr: Vec2; begin   Result.x:= r;   Result.y := r;  end;
function Vec3.getbbb: Vec3; begin   Result.r := b;   Result.g := b;   Result.b := b;  end;
function Vec3.getbbg: Vec3; begin   Result.r := b;   Result.g := b;   Result.b := g;  end;
function Vec3.getbbr: Vec3; begin   Result.r := b;   Result.g := b;   Result.b := r;  end;
function Vec3.getbgb: Vec3; begin   Result.r := b;   Result.g := g;   Result.b := b;  end;
function Vec3.getbgg: Vec3; begin   Result.r := b;   Result.g := g;   Result.b := g;  end;
function Vec3.getbgr: Vec3; begin   Result.r := b;   Result.g := g;   Result.b := r;  end;
function Vec3.getbrb: Vec3; begin   Result.r := b;   Result.g := r;   Result.b := b;  end;
function Vec3.getbrg: Vec3; begin   Result.r := b;   Result.g := r;   Result.b := g;  end;
function Vec3.getbrr: Vec3; begin   Result.r := b;   Result.g := r;   Result.b := r;  end;
function Vec3.getgbb: Vec3; begin   Result.r := g;   Result.g := b;   Result.b := b;  end;
function Vec3.getgbg: Vec3; begin   Result.r := g;   Result.g := b;   Result.b := g;  end;
function Vec3.getgbr: Vec3; begin   Result.r := g;   Result.g := b;   Result.b := r;  end;
function Vec3.getggb: Vec3; begin   Result.r := g;   Result.g := g;   Result.b := b;  end;
function Vec3.getggg: Vec3; begin   Result.r := g;   Result.g := g;   Result.b := g;  end;
function Vec3.getggr: Vec3; begin   Result.r := g;   Result.g := g;   Result.b := r;  end;
function Vec3.getgrb: Vec3; begin   Result.r := g;   Result.g := r;   Result.b := b;  end;
function Vec3.getgrg: Vec3; begin   Result.r := g;   Result.g := r;   Result.b := g;  end;
function Vec3.getgrr: Vec3; begin   Result.r := g;   Result.g := r;   Result.b := r;  end;
function Vec3.getrbb: Vec3; begin   Result.r := r;   Result.g := b;   Result.b := b;  end;
function Vec3.getrbg: Vec3; begin   Result.r := r;   Result.g := b;   Result.b := g;  end;
function Vec3.getrbr: Vec3; begin   Result.r := r;   Result.g := b;   Result.b := r;  end;
function Vec3.getrgb: Vec3; begin   Result.r := r;   Result.g := g;   Result.b := b;  end;
function Vec3.getrgg: Vec3; begin   Result.r := r;   Result.g := g;   Result.b := g;  end;
function Vec3.getrgr: Vec3; begin   Result.r := r;   Result.g := g;   Result.b := r;  end;
function Vec3.getrrb: Vec3; begin   Result.r := r;   Result.g := r;   Result.b := b;  end;
function Vec3.getrrg: Vec3; begin   Result.r := r;   Result.g := r;   Result.b := g;  end;
function Vec3.getrrr: Vec3; begin   Result.r := r;   Result.g := r;   Result.b := r;  end;

procedure Vec3.setbb(const a: Vec2); begin   Self.b := a.r;   Self.b := a.g;  end;
procedure Vec3.setbg(const a: Vec2); begin   Self.b := a.r;   Self.g := a.g;  end;
procedure Vec3.setbr(const a: Vec2); begin   Self.b := a.r;   Self.r := a.g;  end;
procedure Vec3.setgb(const a: Vec2); begin   Self.g := a.r;   Self.b := a.g;  end;
procedure Vec3.setgg(const a: Vec2); begin   Self.g := a.r;   Self.g := a.g;  end;
procedure Vec3.setgr(const a: Vec2); begin   Self.g := a.r;   Self.r := a.g;  end;
procedure Vec3.setrb(const a: Vec2); begin   Self.r := a.r;   Self.b := a.g;  end;
procedure Vec3.setrg(const a: Vec2); begin   Self.r := a.r;   Self.g := a.g;  end;
procedure Vec3.setrr(const a: Vec2); begin   Self.r := a.r;   Self.r := a.g;  end;
procedure Vec3.setbbb(const a: Vec3); begin   Self.b := a.r;   Self.b := a.g;   Self.b := a.b;  end;
procedure Vec3.setbbg(const a: Vec3); begin   Self.b := a.r;   Self.b := a.g;   Self.g := a.b;  end;
procedure Vec3.setbbr(const a: Vec3); begin   Self.b := a.r;   Self.b := a.g;   Self.r := a.b;  end;
procedure Vec3.setbgb(const a: Vec3); begin   Self.b := a.r;   Self.g := a.g;   Self.b := a.b;  end;
procedure Vec3.setbgg(const a: Vec3); begin   Self.b := a.r;   Self.g := a.g;   Self.g := a.b;  end;
procedure Vec3.setbgr(const a: Vec3); begin   Self.b := a.r;   Self.g := a.g;   Self.r := a.b;  end;
procedure Vec3.setbrb(const a: Vec3); begin   Self.b := a.r;   Self.r := a.g;   Self.b := a.b;  end;
procedure Vec3.setbrg(const a: Vec3); begin   Self.b := a.r;   Self.r := a.g;   Self.g := a.b;  end;
procedure Vec3.setbrr(const a: Vec3); begin   Self.b := a.r;   Self.r := a.g;   Self.r := a.b;  end;
procedure Vec3.setgbb(const a: Vec3); begin   Self.g := a.r;   Self.b := a.g;   Self.b := a.b;  end;
procedure Vec3.setgbg(const a: Vec3); begin   Self.g := a.r;   Self.b := a.g;   Self.g := a.b;  end;
procedure Vec3.setgbr(const a: Vec3); begin   Self.g := a.r;   Self.b := a.g;   Self.r := a.b;  end;
procedure Vec3.setggb(const a: Vec3); begin   Self.g := a.r;   Self.g := a.g;   Self.b := a.b;  end;
procedure Vec3.setggg(const a: Vec3); begin   Self.g := a.r;   Self.g := a.g;   Self.g := a.b;  end;
procedure Vec3.setggr(const a: Vec3); begin   Self.g := a.r;   Self.g := a.g;   Self.r := a.b;  end;
procedure Vec3.setgrb(const a: Vec3); begin   Self.g := a.r;   Self.r := a.g;   Self.b := a.b;  end;
procedure Vec3.setgrg(const a: Vec3); begin   Self.g := a.r;   Self.r := a.g;   Self.g := a.b;  end;
procedure Vec3.setgrr(const a: Vec3); begin   Self.g := a.r;   Self.r := a.g;   Self.r := a.b;  end;
procedure Vec3.setrbb(const a: Vec3); begin   Self.r := a.r;   Self.b := a.g;   Self.b := a.b;  end;
procedure Vec3.setrbg(const a: Vec3); begin   Self.r := a.r;   Self.b := a.g;   Self.g := a.b;  end;
procedure Vec3.setrbr(const a: Vec3); begin   Self.r := a.r;   Self.b := a.g;   Self.r := a.b;  end;
procedure Vec3.setrgb(const a: Vec3); begin   Self.r := a.r;   Self.g := a.g;   Self.b := a.b;  end;
procedure Vec3.setrgg(const a: Vec3); begin   Self.r := a.r;   Self.g := a.g;   Self.g := a.b;  end;
procedure Vec3.setrgr(const a: Vec3); begin   Self.r := a.r;   Self.g := a.g;   Self.r := a.b;  end;
procedure Vec3.setrrb(const a: Vec3); begin   Self.r := a.r;   Self.r := a.g;   Self.b := a.b;  end;
procedure Vec3.setrrg(const a: Vec3); begin   Self.r := a.r;   Self.r := a.g;   Self.g := a.b;  end;
procedure Vec3.setrrr(const a: Vec3); begin   Self.r := a.r;   Self.r := a.g;   Self.r := a.b;  end;




function Vec3.Cross(const b: Vec3): Vec3;
begin
  Result := Vec3.create(y * b.z - z * b.y, z * b.x - x * b.z, x * b.y - y * b.x);
end;

class operator Vec3.Divide(const a: Vec3; b: TVecType): Vec3;
begin
  Result.x := a.x / b;
  Result.y := a.y / b;
  Result.z := a.z / b;
end;

function Vec3.Dot(const b: Vec3): TVecType;
begin
  Result := x * b.x + y * b.y + z * b.z;
end;

class operator Vec3.Equal(const a, b: Vec3): Boolean;
begin
  Result := (a.x = b.x) and (a.y = b.y) and (a.z = b.z);
end;

class operator Vec3.Explicit(const a: Vec3): TColor32;
var R,G,B:Byte;
begin
//  Result := Color32(Min(255, round(a.x)),Min(255,round(a.y)),Min(255,round(a.z)))
{  Result := Color32(
              EnsureRange(round(a.x),0,255),
              EnsureRange(round(a.y),0,255),
              EnsureRange(round(a.z),0,255)
              )}

  if a.r > 1 then r := 255 else if a.r < 0 then R := 0 else R := trunc(a.r*255);
  if a.g > 1 then g := 255 else if a.g < 0 then G := 0 else G := trunc(a.g*255);
  if a.b > 1 then b := 255 else if a.b < 0 then B := 0 else B := trunc(a.b*255);

  Result := $ff000000 or (R shl 16) or (G shl 8) or B;
end;


//class operator Vec3.Explicit(a: Vec3): TColor32;
//var r,g,b:byte;
//begin
//  {$R-}
//  r := Trunc(a.x);
//  g := Trunc(a.y);
//  b := Trunc(a.z);
//  {$R+}
//  Result := Color32(r,g,b)
//end;
//
class operator Vec3.Implicit(a: TVecType): Vec3;
begin
  Result.x := a;
  REsult.y := a;
  Result.z := a;
end;

class operator Vec3.Divide(const a, b: Vec3): Vec3;
begin
  Result.x := a.x / b.x;
  Result.y := a.y / b.y;
  Result.z := a.z / b.z;
end;

function Vec3.Length: TVecType;
begin
  Result := System.sqrt(x * x + y * y + z * z)
end;

function abs(x: Single) : Single;
begin
  Result := System.Abs(x);
end;

function abs(x: Double) : Double;
begin
  Result := System.Abs(x);
end;
{
function abs(x: Extended) : Extended;
begin
  Result := System.Abs(x);
end;
}

function abs(const x: vec2) : vec2;
begin
  Result.x := System.abs(x.x);
  Result.y := System.abs(x.y);
end;

function abs(const x: vec3) : vec3;
begin
  Result.x := System.abs(x.x);
  Result.y := System.abs(x.y);
  Result.z := System.abs(x.z);
end;

function abs(const x: vec4) : vec4;
begin
  Result.x := System.abs(x.x);
  Result.y := System.abs(x.y);
  Result.z := System.abs(x.z);
  Result.w := System.abs(x.w);
end;

function asin(x:Single):Single;  begin Result := ArcSin(x) end;
function acos(x:Single):Single;  begin Result := ArcCos(x) end;
//function atan(x:Single):Single;  begin Result := x - (x * x * x * 0.333333333333) + (x * x * x * x * x * 0.2) - (x * x * x * x * x * x * x * 0.1428571429) + (x * x * x * x * x * x * x * x * x * 0.111111111111) - (x * x * x * x * x * x * x * x * x * x * x * 0.0909090909); end;
function atan(x:Single):Single;  begin Result := arctan(x) end;
function atan(x,y:Single):Single;begin Result := ArcTan2(x,y) end;
function tan(x:Single):Single;   begin if x=pi/2 then Exit(0); Result := System.Tangent(x); end;

function asin(x: Double): Double;
var
  t: Double;
begin
  t := (1 + x) * (1 - x);
  if t < 0 then
    Exit(0);
  Result := Math.ArcTan2(x, System.Sqrt(t));
end;

function acos(x: Double): Double;
var
  t: Double;
begin
  t := (1 + x) * (1 - x);
  if t < 0 then
    Exit(0);

  Result := Math.ArcTan2(System.sqrt(t), x);
end;

//function atan(x:Double):Double;  begin Result := x - (x * x * x * 0.333333333333) + (x * x * x * x * x * 0.2) - (x * x * x * x * x * x * x * 0.1428571429) + (x * x * x * x * x * x * x * x * x * 0.111111111111) - (x * x * x * x * x * x * x * x * x * x * x * 0.0909090909); end;
function atan(x:Double):Double;  begin Result := ArcTan(x) end;
function atan(x,y:Double):Double;begin Result := ArcTan2(x,y) end;
function tan(x:Double):Double;   begin if x=pi/2 then Exit(0); Result := System.Tangent(x); end;

//function acos(x:Extended):Extended;  begin Result := ArcCos(x) end;
//function atan(x:Extended):Extended;  begin Result := x - (x * x * x * 0.333333333333) + (x * x * x * x * x * 0.2) - (x * x * x * x * x * x * x * 0.1428571429) + (x * x * x * x * x * x * x * x * x * 0.111111111111) - (x * x * x * x * x * x * x * x * x * x * x * 0.0909090909); end;
//function atan(x,y:Extended):Extended;begin Result := ArcTan2(x,y) end;
//function tan(x:Extended):Extended;   begin if x=pi/2 then Exit(0); Result := System.Tangent(x); end;


class operator Vec3.Multiply(const a: Vec3; b: TVecType): Vec3;
begin
  Result.x := a.x * b;
  Result.y := a.y * b;
  Result.z := a.z * b;
end;

class operator Vec3.Multiply(const a, b: Vec3): Vec3;
begin
  Result.x := a.x * b.x;
  Result.y := a.y * b.y;
  Result.z := a.z * b.z;
end;

class operator Vec3.Negative(const a: Vec3): Vec3;
begin
  Result.X := -a.X;
  Result.Y := -a.Y;
  Result.Z := -a.Z;
end;

function Vec3.Normalize: PVec3;
var
  s, l: TVecType;
begin
  s := System.sqrt(x * x + y * y + z * z);
  if IsZero(s) then
    Exit(@self);

  l := 1 / s;
  x := x * l;
  y := y * l;
  z := z * l;
  Result := @Self;
end;



procedure Vec3.NormalizeSelf;
var
  s, l: TVecType;
begin
  s := x * x + y * y + z * z;

  if IsZero(s) then
    Exit;
  s := System.Sqrt(s);

  l := 1 / s;
  x := x * l;
  y := y * l;
  z := z * l;
end;


class operator Vec3.Subtract(const a: Vec2; const b: Vec3): Vec3;
begin
  result.x := a.x - b.x;
  result.y := a.y - b.y;
  result.z := 0   - b.z;
end;


class operator Vec3.Subtract(const a: Vec3; const b: Vec2): Vec3;
begin
  Result.x := a.x - b.x;
  Result.y := a.y - b.y;
  Result.z := a.z;
end;


class operator Vec3.Subtract(const a, b: Vec3): Vec3;
begin
  Result.x := a.x - b.x;
  Result.y := a.y - b.y;
  Result.z := a.z - b.z;
end;


class operator Vec3.Multiply(a: TVecType; const b: Vec3): Vec3;
begin
  Result.x := a * b.x;
  Result.y := a * b.y;
  Result.z := a * b.z;
end;

{ Vec2 }

class operator Vec2.Add(const a, b: Vec2): Vec2;
begin
  Result.x := a.x + b.x;
  Result.y := a.y + b.y;
end;

class operator Vec2.Add(const a: Vec2; b: TVecType): Vec2;
begin
  Result.x := a.x + b;
  Result.y := a.y + b;
end;

class operator Vec2.Add(a: TVecType; const b: Vec2): Vec2;
begin
  Result.x := a + b.x;
  Result.y := a + b.y;
end;

constructor Vec2.create(ax: TVecType);
begin
  x := ax;
  y := ax;
end;



constructor Vec2.create(ax, ay: TVecType);
begin
  x := ax;
  y := ay;
end;

function Vec2.Cross(const b: Vec2): Vec2;
begin
  Result := Vec2.create(y * b.x - x * b.y, x * b.y - y * b.x);
end;

class operator Vec2.Divide(const a, b: Vec2): Vec2;
begin
  Result.x := a.x / b.x;
  Result.y := a.y / b.y;
end;

class operator Vec2.Divide(const a: Vec2; b: TVecType): Vec2;
begin
  Result.x := a.x / b;
  Result.y := a.y / b;
end;

class operator Vec2.Divide(a: TVecType; const b: Vec2): Vec2;
begin
  Result.x := a / b.x;
  Result.y := a / b.y;
end;

function Vec2.Dot(const b: Vec2): TVecType;
begin
  Result := x * b.x + y * b.y;
end;

class operator Vec2.explicit(const a: Vec2): TPointF;
begin
  Result.X := a.x;
  Result.Y := a.y;
end;

class operator Vec2.explicit(const a: Vec2): TPoint;
begin
  result.X := round(a.x);
  result.Y := round(a.y);
end;

class operator Vec2.explicit(const b: TVecType): Vec2;
begin
  Result.x := b;
  Result.y := b;
end;

function Vec2.Length: TVecType;
begin
  Result := System.sqrt(x * x + y * y)
end;

procedure Vec2.LoadTextures;
begin
end;

class operator Vec2.Multiply(const a, b: Vec2): Vec2;
begin
  Result.x := a.x * b.x;
  Result.y := a.y * b.y;
end;

class operator Vec2.Multiply(const a: Vec2; b: TVecType): Vec2;
begin
  Result.x := a.x * b;
  Result.y := a.y * b;
end;

class operator Vec2.Multiply(a: TVecType; const b: Vec2): Vec2;
begin
  Result.x := a * b.x;
  Result.y := a * b.y;
end;

class operator Vec2.Negative(const a: Vec2): Vec2;
begin
  Result.x := -a.x;
  Result.y := -a.y;
end;

function Vec2.Normalize: PVec2;
var
  s, l: TVecType;
begin

    s := System.sqrt(x * x + y * y);
    if s = 0 then
      Exit(@self);

    l := 1.0 / s;
    x := x * l;
    y := y * l;

  Result := @Self;
end;

function Vec2.rg: vec2;
begin
  Result.x := x;
  Result.y := y;
end;

class operator Vec2.Subtract(const a: Vec2; b: TVecType): Vec2;
begin
  Result.x := a.x - b;
  Result.y := a.y - b;
end;

class operator Vec2.Subtract(a: TVecType; const b: Vec2): Vec2;
begin
  Result.x := a - b.x;
  Result.y := a - b.y;
end;

class operator Vec2.Subtract(const a, b: Vec2): Vec2;
begin
  Result.x := a.x - b.x;
  Result.y := a.y - b.y;
end;


function Vec2.xy: vec2;
begin
  result.x := x;
  Result.y := y;
end;

function Vec2.xx: vec2;
begin
  Result.x:=x;
  Result.y:=x;
end;

function Vec2.xxx: PVec3;
var v3:Vec3;
begin
  v3.x := x;
  v3.y := x;
  v3.z := x;
  Result := @v3;
end;


function Vec2.xxy: PVec3;
var v3:Vec3;
begin
  v3.x := x;
  v3.y := x;
  v3.z := y;
  Result := @v3;
end;


function Vec2.xyx: PVec3;
var v3:Vec3;
begin
  v3.x := x;
  v3.y := y;
  v3.z := x;
  Result := @v3;
end;

function Vec2.xyy: PVec3;
var v3:Vec3;
begin
  v3.x := x;
  v3.y := y;
  v3.z := y;
  Result := @v3;
end;

function Vec2.yx: vec2;
begin
  Result.x := y;
  result.y := x;
end;

function Vec2.yxx: PVec3;
var v3:Vec3;
begin
  v3.x := y;
  v3.y := x;
  v3.z := x;
  Result := @v3;
end;

function Vec2.yxy: PVec3;
var v3:Vec3;
begin
  v3.x := y;
  v3.y := x;
  v3.z := y;
  Result := @v3;
end;

function Vec2.yy: vec2;
begin
  Result.x := y;
  Result.y := y;
end;

function Vec2.yyx: PVec3;
var v3:Vec3;
begin
  v3.x := y;
  v3.y := y;
  v3.z := x;
  Result := @v3;
end;

function Vec2.yyy: PVec3;
var v3:Vec3;
begin
  v3.x := y;
  v3.y := y;
  v3.z := y;
  Result := @v3;
end;


function dot(const x, y: vec2) : double;     overload;
begin
  Result := x.x * y.x +
            x.y * y.y;
end;

function dot(const x, y: vec3) : double;     overload;
begin
  Result := x.x * y.x +
            x.y * y.y +
            x.z * y.z;
end;

function dot(const x, y: vec4) : double;     overload;
begin
  Result := x.x * y.x +
            x.y * y.y +
            x.z * y.z +
            x.w * y.w;
end;

      {
// @@@ just copied from texture2d.. need to figure out how to implement this one
function textureCube(tex:TBitmap32;Coords:Vec3):Vec4;
var
  x,y:Integer;
  c:TColor32;
begin
  x := round(abs(Coords.x) * tex.Width ) mod tex.Width;
  y := round(abs(Coords.y) * tex.Height) mod tex.Height;
  Assert(x>=0);
  Assert(y>=0);
  Assert(X<tex.Width);
  Assert(Y<tex.Height);
  c := tex.Pixel[x,y];
  Result.x := RedComponent(c);
  Result.y := GreenComponent(c);
  Result.z := BlueComponent(c);
  Result.m := AlphaComponent(c);
end;
}
(*
function ceil(x: Double): Double;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;
begin
  Result := math.Ceil(x)
end;
*)

function ceil(const a: Vec2): Vec2; overload;{$IFDEF DO_INLINE} inline;{$ENDIF}
begin
  Result.x := Math.Ceil(a.x);
  Result.y := Math.Ceil(a.y);
end;

function ceil(const a: Vec3): Vec3; overload;{$IFDEF DO_INLINE} inline;{$ENDIF}
begin
  Result.x := Math.Ceil(a.x);
  Result.y := Math.Ceil(a.y);
  Result.z := Math.Ceil(a.z);
end;

function ceil(const a: Vec4): Vec4; overload;{$IFDEF DO_INLINE} inline;{$ENDIF}
begin
  Result.x := Math.Ceil(a.x);
  Result.y := Math.Ceil(a.y);
  Result.z := Math.Ceil(a.z);
  Result.w := Math.Ceil(a.w);
end;


function texture2DHQ(tex:TBitmap32;const Coords:Vec2):Vec4;
var
  x,y:single;
  c:TColor32;
begin
  x := &mod(system.abs(Coords.x) * tex.Width ,tex.Width );
  y := &mod(system.abs(Coords.y) * tex.Height,tex.Height);
  c := tex.PixelXW[round(x*FixedOne),round((tex.Height - y -1)*FixedOne)];
  Result.r := ((c and $00FF0000) shr 16)/256;
  Result.g := ((c and $0000FF00) shr 8)/256;
  Result.b := (c and $000000FF)/256;
  Result.a := (c shr 24)/256;
end;


function texture2DLQ(tex:TBitmap32;const Coords:Vec2):Vec4;
var
  x,y:integer;
  c:TColor32;
begin
  x := round(system.abs(Coords.x) * tex.Width ) mod tex.Width;
  y := round(system.abs(Coords.y) * tex.Height) mod tex.Height;
  Assert(x>=0);
  Assert(y>=0);
  Assert(X<tex.Width);
  Assert(Y<tex.Height);
  c := tex.PixelS[x,tex.Height - y -1];
  Result.r := ((c and $00FF0000) shr 16)/256;
  Result.g := ((c and $0000FF00) shr 8)/256;
  Result.b := (c and $000000FF)/256;
  Result.a := (c shr 24)/256;
end;


function texture2D(tex:TBitmap32;const Coords:Vec2):Vec4;
var
  {$DEFINE ANTIALIASED}
  x,y:{$IFDEF ANTIALIASED}single{$ELSE}integer{$ENDIF};
  px,py:integer;
  c:TColor32;
begin
{$IFDEF ANTIALIASED}
  x := &mod(Coords.x * tex.Width ,tex.Width );
  y := &mod(Coords.y * tex.Height,tex.Height);
  px := round(x * FixedOne);
  py := round((tex.Height - y -1)* FixedOne);
  if px>1e8 then
    Exit(Default(Vec4));
  if py>1e8 then
    Exit(Default(Vec4));

  c := tex.PixelXW[px,py];
{$ELSE}
  x := round(abs(Coords.x) * tex.Width ) mod tex.Width;
  y := round(abs(Coords.y) * tex.Height) mod tex.Height;
  Assert(x>=0);
  Assert(y>=0);
  Assert(X<tex.Width);
  Assert(Y<tex.Height);
  c := tex.PixelS[x,tex.Height - y -1];
{$ENDIF}
  Result.r := ((c and $00FF0000) shr 16)/256;
  Result.g := ((c and $0000FF00) shr 8)/256;
  Result.b := (c and $000000FF)/256;
  Result.a := (c shr 24)/256;
end;

function texture2D(tex: TBitmap32; const Coords: Vec2; Bias:Float): Vec4;{$IFDEF DO_INLINE} inline;{$ENDIF}
begin
  Result := texture2DHQ(tex,Coords);
end;


     {

function textureCube(tex:TBitmap32;Coords:Vec3):Vec4;
begin
	Result.x  := texture2D( tex, Coords.yz ).x;
	Result.y  := texture2D( tex, Coords.zx ).y;
	Result.z  := texture2D( tex, Coords.xy ).z;

	Result.w  := 1;
end;

      }

function textureCube(tex:TBitmap32;const Coords:Vec3):Vec4;
var x,y,z :vec4;
begin

	x  := texture2D( tex, Coords.yz );
	y  := texture2D( tex, Coords.zx );
	z  := texture2D( tex, Coords.xy );

	Exit( (x + y + z) * 0.33 );
end;

function textureCube(const tex:TTextureCube;const Coords:Vec3):Vec4;
var
  MaxVal:Double;
  f:TTextureCube.TFace;
  c:vec2;
begin
//  Result := texture2D( tex.Faces[ ttexturecube.TFace.POSITIVE_X ], -coords.xy );

(*
  http://www.ozone3d.net/tutorials/glsl_texturing_p04.php

  the function to fetch cubemap texels is textureCube().
  The first parameter is a samplerCube and the second is a XYZ vector
  that allows the function textureCube() to select the right face of
  the cubemap and then to extract the texel.

  The functioning of textureCube() could be as follow:
    the coordinate with the largest magnitude selects the face.
    The remaining two coordinates are divided by the absolute value of the
    largest coordinate and are mapped to the range [0.0 - 1.0].

    Example: the vector R = {0.287, -0.944, 0.164}

    selects the NEG_Y face.
    The texture coordinates {s, t} are calculated as follow:
    s = (0.287/0.944*0.5) + 0.5 and
    t = (0.164/0.944*0.5) + 0.5 then
    {s, t} = {0.65, 0.58}.

    The vector R is the same as for the DPEM.
*)

   MaxVal := Math.Max(Math.Max(System.abs(Coords.x), System.abs(Coords.y)), System.abs(Coords.z));

   c := vec2Black;
   f := TTextureCube.TFace.POSITIVE_X;

   if (System.Abs(Coords.x) = maxVal) then
   begin
     if not IsZero(Coords.x) then
       if Coords.x > 0 then
       begin
         f := TTextureCube.TFace.POSITIVE_X;
         c.x := (coords.z / coords.x*0.5)+0.5;
         c.y := (coords.y / coords.x*0.5)+0.5;
       end
       else
       begin
         f := TTextureCube.TFace.NEGATIVE_X;
         c.x := (coords.z / -coords.x*0.5)+0.5;
         c.y := (coords.y / -coords.x*0.5)+0.5;
       end;
   end;

   if (System.Abs(Coords.y) = maxVal) then
   begin
     if not IsZero(Coords.y) then
       if Coords.y > 0 then
       begin
         f := TTextureCube.TFace.POSITIVE_Y;
         c.x := (coords.x / coords.y*0.5)+0.5;
         c.y := (coords.z / coords.y*0.5)+0.5;
       end
       else
       begin
         f := TTextureCube.TFace.NEGATIVE_Y;
         c.x := (coords.x / -coords.y*0.5)+0.5;
         c.y := (coords.z / -coords.y*0.5)+0.5;
       end;
   end;

   if (System.Abs(Coords.z) = maxVal) then
   begin
     if not IsZero(Coords.z) then
       if Coords.z > 0 then
       begin
         f := TTextureCube.TFace.POSITIVE_Z;
         c.x := (coords.x / coords.z*0.5)+0.5;
         c.y := (coords.y / coords.z*0.5)+0.5;
       end
       else
       begin
         f := TTextureCube.TFace.NEGATIVE_Z;
         c.x := (coords.x / -coords.z*0.5)+0.5;
         c.y := (coords.y / -coords.z*0.5)+0.5;
       end;
   end;

   // Result := texture2DHQ( tex.Faces[ f ], c );
   Result := texture2D( tex.Faces[ f ], c );
end;


function TexCube(  sam: TBitmap32; const p:vec3;const n :vec3 ):vec4;
var x,y,z :vec4;
begin
	x  := texture2D( sam, p.yz );
	y  := texture2D( sam, p.zx );
	z  := texture2D( sam, p.xy );
	Exit( x*System.abs(n.x) +
              y*System.abs(n.y) +
              z*System.abs(n.z) );
end;

function smoothstep(edge0, edge1, x: Single): Single;
var
  T: Double;
begin
  T := (x - edge0) / (edge1 - edge0);
  if T>1 then T := 1 else if T<0 then T := 0;
  Result := T * T * (3 - 2 * T);
end;

function smoothstep(edge0, edge1, x: Double): Double;
var
  d, T: Double;
begin

  d := edge1-edge0;
  if Iszero(d) then
    Exit(0);

  T := (x - edge0) / d;
  if T>1 then T := 1 else if T<0 then T := 0;
  Result := T * T * (3 - 2 * T);
end;

{
function smoothstep(edge0, edge1, x: Extended): Extended;
var
  T: Double;
begin
  T := (x - edge0) / (edge1 - edge0);
  if T>1 then T := 1 else if T<0 then T := 0;
  Result := T * T * (3 - 2 * T);
end;
}

function smoothstep(const edge0, edge1, x: vec2): vec2;
begin
  {method 1: most readable}
//  Result.x := smoothstep(edge0.x,edge1.x,x.x);
//  Result.y := smoothstep(edge0.y,edge1.y,x.y);


  {method 2}
//  T.x := clamp((x.x - edge0.x) / (edge1.x - edge0.x), 0, 1);
//  Result.x := T.x * T.x * (3 - 2 * T.x);
//  T.y := clamp((x.y - edge0.y) / (edge1.y - edge0.y), 0, 1);
//  Result.y := T.y * T.y * (3 - 2 * T.y);

  {method 3: least readable, but almost twice as fast as method 1}
  result.x := (x.x - edge0.x) / (edge1.x - edge0.x);
  if result.x>1 then result.x := 1 else if result.x<0 then result.x := 0;
  Result.x := result.x * result.x * (3 - 2 * result.x);

  result.y := (x.y - edge0.y) / (edge1.y - edge0.y);
  if result.y>1 then result.y := 1 else if result.y<0 then result.y := 0;
  Result.y := result.y * result.y * (3 - 2 * result.y);
end;


function smoothstep(const edge0, edge1, x: vec3) : vec3;overload;{ T t = clamp((x-edge0) / (edge1-edge0), T(0), T(1)); return t * t * (3 - 2*t); }
var T:vec3;
begin
{
  Result.x := smoothstep(edge0.x,edge1.x,x.x);
  Result.y := smoothstep(edge0.y,edge1.y,x.y);
  Result.z := smoothstep(edge0.z,edge1.z,x.z);
}
  T.x := (x.x - edge0.x) / (edge1.x - edge0.x);
  if T.x>1 then T.x := 1 else if T.x<0 then T.x := 0;
  Result.x := T.x * T.x * (3 - 2 * T.x);

  T.y := (x.y - edge0.y) / (edge1.y - edge0.y);
  if T.y>1 then T.y := 1 else if T.y<0 then T.y := 0;
  Result.y := T.y * T.y * (3 - 2 * T.y);

  T.z := (x.z - edge0.z) / (edge1.z - edge0.z);
  if T.z>1 then T.z := 1 else if T.z<0 then T.z := 0;
  Result.z := T.z * T.z * (3 - 2 * T.z);

end;


function smoothstep(const edge0, edge1, x: vec4) : vec4;overload;{ T t = clamp((x-edge0) / (edge1-edge0), T(0), T(1)); return t * t * (3 - 2*t); }
var T:vec4;
begin
{
  Result.x := smoothstep(edge0.x,edge1.x,x.x);
  Result.y := smoothstep(edge0.y,edge1.y,x.y);
  Result.z := smoothstep(edge0.z,edge1.z,x.z);
  Result.w := smoothstep(edge0.w,edge1.w,x.w);
  }
  T.x := (x.x - edge0.x) / (edge1.x - edge0.x);
  if T.x>1 then T.x := 1 else if T.x<0 then T.x := 0;
  Result.x := T.x * T.x * (3 - 2 * T.x);

  T.y := (x.y - edge0.y) / (edge1.y - edge0.y);
  if T.y>1 then T.y := 1 else if T.y<0 then T.y := 0;
  Result.y := T.y * T.y * (3 - 2 * T.y);

  T.z := (x.z - edge0.z) / (edge1.z - edge0.z);
  if T.z>1 then T.z := 1 else if T.z<0 then T.z := 0;
  Result.z := T.z * T.z * (3 - 2 * T.z);

  T.w := (x.w - edge0.w) / (edge1.w - edge0.w);
  if T.w>1 then T.w := 1 else if T.w<0 then T.w := 0;
  Result.w := T.w * T.w * (3 - 2 * T.w);
end;


function sinLarge(const x: TVecType): TVecType;
begin
  {$IFDEF CPUX64}
  Result := System.sin(Math.FMod(x,2*pi));
  {$ELSE}
  Result := System.sin(x);
  {$ENDIF}
end;

function sinLarge(const x: Vec2): Vec2;
begin
  {$IFDEF CPUX64}
  Result.x := System.sin(Math.FMod(x.x,2*pi));
  Result.y := System.sin(Math.FMod(x.y,2*pi));
  {$ELSE}
  Result.x := System.sin(x.x);
  Result.y := System.sin(x.y);
  {$ENDIF}
end;

function sinLarge(const x: Vec3): Vec3;
begin
  {$IFDEF CPUX64}
  Result.x := System.sin(Math.FMod(x.x,2*pi));
  Result.y := System.sin(Math.FMod(x.y,2*pi));
  Result.z := System.sin(Math.FMod(x.z,2*pi));
  {$ELSE}
  Result.x := System.sin(x.x);
  Result.y := System.sin(x.y);
  Result.z := System.sin(x.z);
  {$ENDIF}
end;

function sinLarge(const x: Vec4): Vec4;
begin
  {$IFDEF CPUX64}
  Result.x := System.sin(Math.FMod(x.x,2*pi));
  Result.y := System.sin(Math.FMod(x.y,2*pi));
  Result.z := System.sin(Math.FMod(x.z,2*pi));
  Result.w := System.sin(Math.FMod(x.w,2*pi));
  {$ELSE}
  Result.x := System.sin(x.x);
  Result.y := System.sin(x.y);
  Result.z := System.sin(x.z);
  Result.w := System.sin(x.w);
  {$ENDIF}
end;

function cosLarge(const x: TVecType): TVecType;
begin
  {$IFDEF CPUX64}
  Result := System.cos(Math.FMod(x,2*pi));
  {$ELSE}
  Result := System.cos(x);
  {$ENDIF}
end;

function cosLarge(const x: Vec2): Vec2;
begin
  {$IFDEF CPUX64}
  Result.x := System.cos(Math.FMod(x.x,2*pi));
  Result.y := System.cos(Math.FMod(x.y,2*pi));
  {$ELSE}
  Result.x := System.cos(x.x);
  Result.y := System.cos(x.y);
  {$ENDIF}
end;

function cosLarge(const x: Vec3): Vec3;
begin
  {$IFDEF CPUX64}
  Result.x := System.cos(Math.FMod(x.x,2*pi));
  Result.y := System.cos(Math.FMod(x.y,2*pi));
  Result.z := System.cos(Math.FMod(x.z,2*pi));
  {$ELSE}
  Result.x := System.cos(x.x);
  Result.y := System.cos(x.y);
  Result.z := System.cos(x.z);
  {$ENDIF}
end;

function cosLarge(const x: Vec4): Vec4;
begin
  {$IFDEF CPUX64}
  Result.x := System.cos(Math.FMod(x.x,2*pi));
  Result.y := System.cos(Math.FMod(x.y,2*pi));
  Result.z := System.cos(Math.FMod(x.z,2*pi));
  Result.w := System.cos(Math.FMod(x.w,2*pi));
  {$ELSE}
  Result.x := System.cos(x.x);
  Result.y := System.cos(x.y);
  Result.z := System.cos(x.z);
  Result.w := System.cos(x.w);
  {$ENDIF}
end;



function sin(const x: Vec2): Vec2;
begin
  result.x := System.sin(x.x);
  result.y := System.sin(x.y);
end;

function sin(const x: Vec3): Vec3;
begin
  result.x := System.sin(x.x);
  result.y := System.sin(x.y);
  result.z := System.sin(x.z);
end;

function sin(const x: Vec4): Vec4;
begin
  result.x := System.sin(x.x);
  result.y := System.sin(x.y);
  result.z := System.sin(x.z);
  result.w := System.sin(x.w);
end;

function cos(const x: Vec2): Vec2;
begin
  result.x := System.cos(x.x);
  result.y := System.cos(x.y);
end;

function cos(const x: Vec3): Vec3;
begin
  result.x := System.cos(x.x);
  result.y := System.cos(x.y);
  result.z := System.cos(x.z);
end;

function cos(const x: Vec4): Vec4;
begin
  result.x := System.cos(x.x);
  result.y := System.cos(x.y);
  result.z := System.cos(x.z);
  result.w := System.cos(x.w);
end;


procedure cos(const x: Vec2;out Result:vec2);
begin
  result.x := System.cos(x.x);
  result.y := System.cos(x.y);
end;

procedure cos(const x: Vec3;out Result:vec3);
begin
  result.x := System.cos(x.x);
  result.y := System.cos(x.y);
  result.z := System.cos(x.z);
end;

procedure cos(const x: Vec4;out Result:vec4);
begin
  result.x := System.cos(x.x);
  result.y := System.cos(x.y);
  result.z := System.cos(x.z);
  result.w := System.cos(x.w);
end;

procedure Mult(const input: Vec3;out Result:vec3);inline;
begin
  Result.x := input.x * input.x;
  REsult.y := input.y * input.y;
  Result.z := input.z * input.z;
end;


function normalize(const v:Vec2) : vec2;{$IFDEF DO_INLINE} inline;{$ENDIF}overload;
var
  m:TVecType;
begin
	m := System.sqrt(v.x * v.x + v.y * v.y);

	if(m >  0.000000001)then
		m := 1.0 / m
	else
		m := 0.0;

	Result := vec2.create(v.x * m, v.y * m);
end;

function normalizeS(const v:Vec3) : vec3;inline;
var
  m:TVecType;
begin
  if IsNan(v.x) then exit(vec3Black);
  if IsNan(v.y) then exit(vec3Black);
  if IsNan(v.z) then exit(vec3Black);

	m := System.sqrt(v.x * v.x + v.y * v.y + v.z * v.z);

	if(m >  0.000000001)then
		m := 1.0 / m
	else
		m := 0.0;

	Result.x := v.x * m;
  Result.y := v.y * m;
  Result.z := v.z * m;
end;


function normalize(const v:Vec3) : vec3;inline;
var
  m:TVecType;
begin
	m := System.sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
  if IsZero(m) then
    Exit(Vec3Black);

  m := 1.0 / m;
  Result.x := v.x * m;
  Result.y := v.y * m;
  Result.z := v.z * m;
end;

function Normalize(const v: Vec4): Vec4;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;
var
  a:TVecType;
begin
	a := System.sqrt(v.x * v.x + v.y * v.y + v.z * v.z + v.w * v.w);

	if(a >  0.000000001)then
		a := 1.0 / a
	else
		a := 0.0;

	Result.x := v.x * a;
  Result.y := v.y * a;
  Result.z := v.z * a;
  Result.w := v.w * a;
end;


constructor Vec4.Create(x, y, z, w: TVecType);
begin
  self.x := x;
  self.y := y;
  self.z := z;
  self.w := w;
end;

class operator Vec4.Add(const a, b: Vec4): Vec4;
begin
  Result.x := a.x + b.x;
  Result.y := a.y + b.y;
  Result.z := a.z + b.z;
  Result.w := a.w + b.w;
end;

class operator Vec4.Add(a: TVecType; const b: Vec4): Vec4;
begin
  Result.x := a + b.x;
  Result.y := a + b.y;
  Result.z := a + b.z;
  Result.w := a + b.w;
end;

class operator Vec4.Subtract(const a,b: Vec4): Vec4;
begin
  Result.x := a.x - b.x;
  Result.y := a.y - b.y;
  Result.z := a.z - b.z;
  Result.w := a.w - b.w;
end;


constructor Vec4.Create(const x: Vec3; w: TVecType);
begin
  Self.x := x.x;
  Self.y := x.y;
  Self.z := x.z;
  Self.w := w;
end;

constructor Vec4.create(x: TVecType);
begin
  self.x := x;
  self.y := x;
  self.z := x;
  self.w := x;
end;

class operator Vec4.Explicit(const a: Vec4): TColor32;
var r_,g_,b_{,w_}:byte;
begin
{
  Result := Color32(
              Math.Min(255,round(a.x)),
              Math.Min(255,round(a.y)),
              Math.Min(255,round(a.z)),
              round(a.m)
  )           }
  {
  Result := Color32(
              EnsureRange(round(a.r*256),0,255),
              EnsureRange(round(a.g*256),0,255),
              EnsureRange(round(a.b*256),0,255),
              EnsureRange(round(a.w*256),0,255)
              );
}
{
  Result := ((EnsureRange(round(a.w*256),0,255)) shl 24)
          or (EnsureRange(round(a.r*256),0,255) shl 16)
          or (EnsureRange(round(a.g*256),0,255) shl  8)
          or EnsureRange(round(a.w*256),0,255);
}

{
  including alpha channel
  if a.r < 0 then R_ := 0 else if a.r > 1 then r_ := 255 else R_ := trunc(a.r*255);
  if a.g < 0 then G_ := 0 else if a.g > 1 then g_ := 255 else G_ := trunc(a.g*255);
  if a.b < 0 then B_ := 0 else if a.b > 1 then b_ := 255 else B_ := trunc(a.b*255);
  if a.w < 0 then W_ := 0 else if a.w > 1 then w_ := 255 else W_ := trunc(a.w*255);
  Result := (W_ shl 24) or (R_ shl 16) or (G_ shl 8) or B_;
}
  if a.r < 0 then R_ := 0 else if a.r > 1 then r_ := 255 else R_ := trunc(a.r*255);
  if a.g < 0 then G_ := 0 else if a.g > 1 then g_ := 255 else G_ := trunc(a.g*255);
  if a.b < 0 then B_ := 0 else if a.b > 1 then b_ := 255 else B_ := trunc(a.b*255);
  Result := (R_ shl 16) or (G_ shl 8) or B_;
end;


class operator Vec4.Implicit(const a: Vec3): Vec4;
begin
  Result.x := a.x;
  Result.y := a.y;
  Result.z := a.z;
  Result.w := 0;
end;


class operator Vec4.Multiply(const a: vec3; const b: Vec4): Vec4;
begin
  Result.x := a.x*b.x;
  Result.y := a.y*b.y;
  Result.z := a.z*b.z;
  Result.w := 0;
end;

class operator Vec4.Multiply(const a, b: Vec4): Vec4;
begin
  Result.x := a.x * b.x;
  Result.y := a.y * b.y;
  Result.z := a.z * b.z;
  Result.w := a.w * b.w;
end;

class operator Vec4.Multiply(const a: Vec4; b: TVecType): Vec4;
begin
  Result.x := a.x * b;
  Result.y := a.y * b;
  Result.z := a.z * b;
  Result.w := a.w * b;
end;

class operator Vec4.Multiply(const a: vec4; const b: Vec3): Vec4;
begin
  Result.x := a.x*b.x;
  Result.y := a.y*b.y;
  Result.z := a.z*b.z;
  Result.w := 0;
end;

class operator Vec4.Negative(const a: Vec4): Vec4;
begin
  Result.x := -a.x;
  Result.y := -a.y;
  Result.z := -a.z;
  Result.w := -a.w;
end;


class operator Vec4.Multiply(const a: TVecType; const b: Vec4): Vec4;
begin
  Result.x := a*b.x;
  Result.y := a*b.y;
  Result.z := a*b.z;
  Result.w := a*b.w;
end;



function Vec4.getww: Vec2; begin   Result.x := w;   Result.y := w;  end;
function Vec4.getwx: Vec2; begin   Result.x := w;   Result.y := x;  end;
function Vec4.getwy: Vec2; begin   Result.x := w;   Result.y := y;  end;
function Vec4.getwz: Vec2; begin   Result.x := w;   Result.y := z;  end;
function Vec4.getxw: Vec2; begin   Result.x := x;   Result.y := w;  end;
function Vec4.getxx: Vec2; begin   Result.x := x;   Result.y := x;  end;
function Vec4.getxy: Vec2; begin   Result.x := x;   Result.y := y;  end;
function Vec4.getxz: Vec2; begin   Result.x := x;   Result.y := z;  end;
function Vec4.getyw: Vec2; begin   Result.x := y;   Result.y := w;  end;
function Vec4.getyx: Vec2; begin   Result.x := y;   Result.y := x;  end;
function Vec4.getyy: Vec2; begin   Result.x := y;   Result.y := y;  end;
function Vec4.getyz: Vec2; begin   Result.x := y;   Result.y := z;  end;
function Vec4.getzw: Vec2; begin   Result.x := z;   Result.y := w;  end;
function Vec4.getzx: Vec2; begin   Result.x := z;   Result.y := x;  end;
function Vec4.getzy: Vec2; begin   Result.x := z;   Result.y := y;  end;
function Vec4.getzz: Vec2; begin   Result.x := z;   Result.y := z;  end;
function Vec4.getwww: Vec3; begin   Result.x := w;   Result.y := w;   Result.z := w;  end;
function Vec4.getwwx: Vec3; begin   Result.x := w;   Result.y := w;   Result.z := x;  end;
function Vec4.getwwy: Vec3; begin   Result.x := w;   Result.y := w;   Result.z := y;  end;
function Vec4.getwwz: Vec3; begin   Result.x := w;   Result.y := w;   Result.z := z;  end;
function Vec4.getwxw: Vec3; begin   Result.x := w;   Result.y := x;   Result.z := w;  end;
function Vec4.getwxx: Vec3; begin   Result.x := w;   Result.y := x;   Result.z := x;  end;
function Vec4.getwxy: Vec3; begin   Result.x := w;   Result.y := x;   Result.z := y;  end;
function Vec4.getwxz: Vec3; begin   Result.x := w;   Result.y := x;   Result.z := z;  end;
function Vec4.getwyw: Vec3; begin   Result.x := w;   Result.y := y;   Result.z := w;  end;
function Vec4.getwyx: Vec3; begin   Result.x := w;   Result.y := y;   Result.z := x;  end;
function Vec4.getwyy: Vec3; begin   Result.x := w;   Result.y := y;   Result.z := y;  end;
function Vec4.getwyz: Vec3; begin   Result.x := w;   Result.y := y;   Result.z := z;  end;
function Vec4.getwzw: Vec3; begin   Result.x := w;   Result.y := z;   Result.z := w;  end;
function Vec4.getwzx: Vec3; begin   Result.x := w;   Result.y := z;   Result.z := x;  end;
function Vec4.getwzy: Vec3; begin   Result.x := w;   Result.y := z;   Result.z := y;  end;
function Vec4.getwzz: Vec3; begin   Result.x := w;   Result.y := z;   Result.z := z;  end;
function Vec4.getxww: Vec3; begin   Result.x := x;   Result.y := w;   Result.z := w;  end;
function Vec4.getxwx: Vec3; begin   Result.x := x;   Result.y := w;   Result.z := x;  end;
function Vec4.getxwy: Vec3; begin   Result.x := x;   Result.y := w;   Result.z := y;  end;
function Vec4.getxwz: Vec3; begin   Result.x := x;   Result.y := w;   Result.z := z;  end;
function Vec4.getxxw: Vec3; begin   Result.x := x;   Result.y := x;   Result.z := w;  end;
function Vec4.getxxx: Vec3; begin   Result.x := x;   Result.y := x;   Result.z := x;  end;
function Vec4.getxxy: Vec3; begin   Result.x := x;   Result.y := x;   Result.z := y;  end;
function Vec4.getxxz: Vec3; begin   Result.x := x;   Result.y := x;   Result.z := z;  end;
function Vec4.getxyw: Vec3; begin   Result.x := x;   Result.y := y;   Result.z := w;  end;
function Vec4.getxyx: Vec3; begin   Result.x := x;   Result.y := y;   Result.z := x;  end;
function Vec4.getxyy: Vec3; begin   Result.x := x;   Result.y := y;   Result.z := y;  end;
function Vec4.getxyz: Vec3; begin  { Result.x := x;   Result.y := y;   Result.z := z;} move(self,result,sizeof(tvectype)*3); end;
function Vec4.getxzw: Vec3; begin   Result.x := x;   Result.y := z;   Result.z := w;  end;
function Vec4.getxzx: Vec3; begin   Result.x := x;   Result.y := z;   Result.z := x;  end;
function Vec4.getxzy: Vec3; begin   Result.x := x;   Result.y := z;   Result.z := y;  end;
function Vec4.getxzz: Vec3; begin   Result.x := x;   Result.y := z;   Result.z := z;  end;
function Vec4.getyww: Vec3; begin   Result.x := y;   Result.y := w;   Result.z := w;  end;
function Vec4.getywx: Vec3; begin   Result.x := y;   Result.y := w;   Result.z := x;  end;
function Vec4.getywy: Vec3; begin   Result.x := y;   Result.y := w;   Result.z := y;  end;
function Vec4.getywz: Vec3; begin   Result.x := y;   Result.y := w;   Result.z := z;  end;
function Vec4.getyxw: Vec3; begin   Result.x := y;   Result.y := x;   Result.z := w;  end;
function Vec4.getyxx: Vec3; begin   Result.x := y;   Result.y := x;   Result.z := x;  end;
function Vec4.getyxy: Vec3; begin   Result.x := y;   Result.y := x;   Result.z := y;  end;
function Vec4.getyxz: Vec3; begin   Result.x := y;   Result.y := x;   Result.z := z;  end;
function Vec4.getyyw: Vec3; begin   Result.x := y;   Result.y := y;   Result.z := w;  end;
function Vec4.getyyx: Vec3; begin   Result.x := y;   Result.y := y;   Result.z := x;  end;
function Vec4.getyyy: Vec3; begin   Result.x := y;   Result.y := y;   Result.z := y;  end;
function Vec4.getyyz: Vec3; begin   Result.x := y;   Result.y := y;   Result.z := z;  end;
function Vec4.getyzw: Vec3; begin   Result.x := y;   Result.y := z;   Result.z := w;  end;
function Vec4.getyzx: Vec3; begin   Result.x := y;   Result.y := z;   Result.z := x;  end;
function Vec4.getyzy: Vec3; begin   Result.x := y;   Result.y := z;   Result.z := y;  end;
function Vec4.getyzz: Vec3; begin   Result.x := y;   Result.y := z;   Result.z := z;  end;
function Vec4.getzww: Vec3; begin   Result.x := z;   Result.y := w;   Result.z := w;  end;
function Vec4.getzwx: Vec3; begin   Result.x := z;   Result.y := w;   Result.z := x;  end;
function Vec4.getzwy: Vec3; begin   Result.x := z;   Result.y := w;   Result.z := y;  end;
function Vec4.getzwz: Vec3; begin   Result.x := z;   Result.y := w;   Result.z := z;  end;
function Vec4.getzxw: Vec3; begin   Result.x := z;   Result.y := x;   Result.z := w;  end;
function Vec4.getzxx: Vec3; begin   Result.x := z;   Result.y := x;   Result.z := x;  end;
function Vec4.getzxy: Vec3; begin   Result.x := z;   Result.y := x;   Result.z := y;  end;
function Vec4.getzxz: Vec3; begin   Result.x := z;   Result.y := x;   Result.z := z;  end;
function Vec4.getzyw: Vec3; begin   Result.x := z;   Result.y := y;   Result.z := w;  end;
function Vec4.getzyx: Vec3; begin   Result.x := z;   Result.y := y;   Result.z := x;  end;
function Vec4.getzyy: Vec3; begin   Result.x := z;   Result.y := y;   Result.z := y;  end;
function Vec4.getzyz: Vec3; begin   Result.x := z;   Result.y := y;   Result.z := z;  end;
function Vec4.getzzw: Vec3; begin   Result.x := z;   Result.y := z;   Result.z := w;  end;
function Vec4.getzzx: Vec3; begin   Result.x := z;   Result.y := z;   Result.z := x;  end;
function Vec4.getzzy: Vec3; begin   Result.x := z;   Result.y := z;   Result.z := y;  end;
function Vec4.getzzz: Vec3; begin   Result.x := z;   Result.y := z;   Result.z := z;  end;

procedure Vec4.setww(const a: Vec2); begin   Self.w := x;   Self.w := y;  end;
procedure Vec4.setwx(const a: Vec2); begin   Self.w := x;   Self.x := y;  end;
procedure Vec4.setwy(const a: Vec2); begin   Self.w := x;   Self.y := y;  end;
procedure Vec4.setwz(const a: Vec2); begin   Self.w := x;   Self.z := y;  end;
procedure Vec4.setxw(const a: Vec2); begin   Self.x := x;   Self.w := y;  end;
procedure Vec4.setxx(const a: Vec2); begin   Self.x := x;   Self.x := y;  end;
procedure Vec4.setxy(const a: Vec2); begin   Self.x := x;   Self.y := y;  end;
procedure Vec4.setxz(const a: Vec2); begin   Self.x := x;   Self.z := y;  end;
procedure Vec4.setyw(const a: Vec2); begin   Self.y := x;   Self.w := y;  end;
procedure Vec4.setyx(const a: Vec2); begin   Self.y := x;   Self.x := y;  end;
procedure Vec4.setyy(const a: Vec2); begin   Self.y := x;   Self.y := y;  end;
procedure Vec4.setyz(const a: Vec2); begin   Self.y := x;   Self.z := y;  end;
procedure Vec4.setzw(const a: Vec2); begin   Self.z := x;   Self.w := y;  end;
procedure Vec4.setzx(const a: Vec2); begin   Self.z := x;   Self.x := y;  end;
procedure Vec4.setzy(const a: Vec2); begin   Self.z := x;   Self.y := y;  end;
procedure Vec4.setzz(const a: Vec2); begin   Self.z := x;   Self.z := y;  end;
procedure Vec4.setwww(const a: Vec3); begin   Self.w := x;   Self.w := y;   Self.w := z;  end;
procedure Vec4.setwwx(const a: Vec3); begin   Self.w := x;   Self.w := y;   Self.x := z;  end;
procedure Vec4.setwwy(const a: Vec3); begin   Self.w := x;   Self.w := y;   Self.y := z;  end;
procedure Vec4.setwwz(const a: Vec3); begin   Self.w := x;   Self.w := y;   Self.z := z;  end;
procedure Vec4.setwxw(const a: Vec3); begin   Self.w := x;   Self.x := y;   Self.w := z;  end;
procedure Vec4.setwxx(const a: Vec3); begin   Self.w := x;   Self.x := y;   Self.x := z;  end;
procedure Vec4.setwxy(const a: Vec3); begin   Self.w := x;   Self.x := y;   Self.y := z;  end;
procedure Vec4.setwxz(const a: Vec3); begin   Self.w := x;   Self.x := y;   Self.z := z;  end;
procedure Vec4.setwyw(const a: Vec3); begin   Self.w := x;   Self.y := y;   Self.w := z;  end;
procedure Vec4.setwyx(const a: Vec3); begin   Self.w := x;   Self.y := y;   Self.x := z;  end;
procedure Vec4.setwyy(const a: Vec3); begin   Self.w := x;   Self.y := y;   Self.y := z;  end;
procedure Vec4.setwyz(const a: Vec3); begin   Self.w := x;   Self.y := y;   Self.z := z;  end;
procedure Vec4.setwzw(const a: Vec3); begin   Self.w := x;   Self.z := y;   Self.w := z;  end;
procedure Vec4.setwzx(const a: Vec3); begin   Self.w := x;   Self.z := y;   Self.x := z;  end;
procedure Vec4.setwzy(const a: Vec3); begin   Self.w := x;   Self.z := y;   Self.y := z;  end;
procedure Vec4.setwzz(const a: Vec3); begin   Self.w := x;   Self.z := y;   Self.z := z;  end;
procedure Vec4.setxww(const a: Vec3); begin   Self.x := x;   Self.w := y;   Self.w := z;  end;
procedure Vec4.setxwx(const a: Vec3); begin   Self.x := x;   Self.w := y;   Self.x := z;  end;
procedure Vec4.setxwy(const a: Vec3); begin   Self.x := x;   Self.w := y;   Self.y := z;  end;
procedure Vec4.setxwz(const a: Vec3); begin   Self.x := x;   Self.w := y;   Self.z := z;  end;
procedure Vec4.setxxw(const a: Vec3); begin   Self.x := x;   Self.x := y;   Self.w := z;  end;
procedure Vec4.setxxx(const a: Vec3); begin   Self.x := x;   Self.x := y;   Self.x := z;  end;
procedure Vec4.setxxy(const a: Vec3); begin   Self.x := x;   Self.x := y;   Self.y := z;  end;
procedure Vec4.setxxz(const a: Vec3); begin   Self.x := x;   Self.x := y;   Self.z := z;  end;
procedure Vec4.setxyw(const a: Vec3); begin   Self.x := x;   Self.y := y;   Self.w := z;  end;
procedure Vec4.setxyx(const a: Vec3); begin   Self.x := x;   Self.y := y;   Self.x := z;  end;
procedure Vec4.setxyy(const a: Vec3); begin   Self.x := x;   Self.y := y;   Self.y := z;  end;
procedure Vec4.setxyz(const a: Vec3); begin {  Self.x := x;   Self.y := y;   Self.z := z;} move(a,self,sizeof(tvectype)*3);z:=0;  end;
procedure Vec4.setxzw(const a: Vec3); begin   Self.x := x;   Self.z := y;   Self.w := z;  end;
procedure Vec4.setxzx(const a: Vec3); begin   Self.x := x;   Self.z := y;   Self.x := z;  end;
procedure Vec4.setxzy(const a: Vec3); begin   Self.x := x;   Self.z := y;   Self.y := z;  end;
procedure Vec4.setxzz(const a: Vec3); begin   Self.x := x;   Self.z := y;   Self.z := z;  end;
procedure Vec4.setyww(const a: Vec3); begin   Self.y := x;   Self.w := y;   Self.w := z;  end;
procedure Vec4.setywx(const a: Vec3); begin   Self.y := x;   Self.w := y;   Self.x := z;  end;
procedure Vec4.setywy(const a: Vec3); begin   Self.y := x;   Self.w := y;   Self.y := z;  end;
procedure Vec4.setywz(const a: Vec3); begin   Self.y := x;   Self.w := y;   Self.z := z;  end;
procedure Vec4.setyxw(const a: Vec3); begin   Self.y := x;   Self.x := y;   Self.w := z;  end;
procedure Vec4.setyxx(const a: Vec3); begin   Self.y := x;   Self.x := y;   Self.x := z;  end;
procedure Vec4.setyxy(const a: Vec3); begin   Self.y := x;   Self.x := y;   Self.y := z;  end;
procedure Vec4.setyxz(const a: Vec3); begin   Self.y := x;   Self.x := y;   Self.z := z;  end;
procedure Vec4.setyyw(const a: Vec3); begin   Self.y := x;   Self.y := y;   Self.w := z;  end;
procedure Vec4.setyyx(const a: Vec3); begin   Self.y := x;   Self.y := y;   Self.x := z;  end;
procedure Vec4.setyyy(const a: Vec3); begin   Self.y := x;   Self.y := y;   Self.y := z;  end;
procedure Vec4.setyyz(const a: Vec3); begin   Self.y := x;   Self.y := y;   Self.z := z;  end;
procedure Vec4.setyzw(const a: Vec3); begin   Self.y := x;   Self.z := y;   Self.w := z;  end;
procedure Vec4.setyzx(const a: Vec3); begin   Self.y := x;   Self.z := y;   Self.x := z;  end;
procedure Vec4.setyzy(const a: Vec3); begin   Self.y := x;   Self.z := y;   Self.y := z;  end;
procedure Vec4.setyzz(const a: Vec3); begin   Self.y := x;   Self.z := y;   Self.z := z;  end;
procedure Vec4.setzww(const a: Vec3); begin   Self.z := x;   Self.w := y;   Self.w := z;  end;
procedure Vec4.setzwx(const a: Vec3); begin   Self.z := x;   Self.w := y;   Self.x := z;  end;
procedure Vec4.setzwy(const a: Vec3); begin   Self.z := x;   Self.w := y;   Self.y := z;  end;
procedure Vec4.setzwz(const a: Vec3); begin   Self.z := x;   Self.w := y;   Self.z := z;  end;
procedure Vec4.setzxw(const a: Vec3); begin   Self.z := x;   Self.x := y;   Self.w := z;  end;
procedure Vec4.setzxx(const a: Vec3); begin   Self.z := x;   Self.x := y;   Self.x := z;  end;
procedure Vec4.setzxy(const a: Vec3); begin   Self.z := x;   Self.x := y;   Self.y := z;  end;
procedure Vec4.setzxz(const a: Vec3); begin   Self.z := x;   Self.x := y;   Self.z := z;  end;
procedure Vec4.setzyw(const a: Vec3); begin   Self.z := x;   Self.y := y;   Self.w := z;  end;
procedure Vec4.setzyx(const a: Vec3); begin   Self.z := x;   Self.y := y;   Self.x := z;  end;
procedure Vec4.setzyy(const a: Vec3); begin   Self.z := x;   Self.y := y;   Self.y := z;  end;
procedure Vec4.setzyz(const a: Vec3); begin   Self.z := x;   Self.y := y;   Self.z := z;  end;
procedure Vec4.setzzw(const a: Vec3); begin   Self.z := x;   Self.z := y;   Self.w := z;  end;
procedure Vec4.setzzx(const a: Vec3); begin   Self.z := x;   Self.z := y;   Self.x := z;  end;
procedure Vec4.setzzy(const a: Vec3); begin   Self.z := x;   Self.z := y;   Self.y := z;  end;
procedure Vec4.setzzz(const a: Vec3); begin   Self.z := x;   Self.z := y;   Self.z := z;  end;


function Vec4.getaa : Vec2; begin Result.x := a; Result.y := a; end;
function Vec4.getab : Vec2; begin Result.x := a; Result.y := b; end;
function Vec4.getag : Vec2; begin Result.x := a; Result.y := g; end;
function Vec4.getar : Vec2; begin Result.x := a; Result.y := r; end;
function Vec4.getba : Vec2; begin Result.x := b; Result.y := a; end;
function Vec4.getbb : Vec2; begin Result.x := b; Result.y := b; end;
function Vec4.getbg : Vec2; begin Result.x := b; Result.y := g; end;
function Vec4.getbr : Vec2; begin Result.x := b; Result.y := r; end;
function Vec4.getga : Vec2; begin Result.x := g; Result.y := a; end;
function Vec4.getgb : Vec2; begin Result.x := g; Result.y := b; end;
function Vec4.getgg : Vec2; begin Result.x := g; Result.y := g; end;
function Vec4.getgr : Vec2; begin Result.x := g; Result.y := r; end;
function Vec4.getra : Vec2; begin Result.x := r; Result.y := a; end;
function Vec4.getrb : Vec2; begin Result.x := r; Result.y := b; end;
function Vec4.getrg : Vec2; begin Result.x := r; Result.y := g; end;
function Vec4.getrr : Vec2; begin Result.x := r; Result.y := r; end;
function Vec4.getaaa: Vec3; begin Result.r := a; Result.g := a; Result.b := a; end;
function Vec4.getaab: Vec3; begin Result.r := a; Result.g := a; Result.b := b; end;
function Vec4.getaag: Vec3; begin Result.r := a; Result.g := a; Result.b := g; end;
function Vec4.getaar: Vec3; begin Result.r := a; Result.g := a; Result.b := r; end;
function Vec4.getaba: Vec3; begin Result.r := a; Result.g := b; Result.b := a; end;
function Vec4.getabb: Vec3; begin Result.r := a; Result.g := b; Result.b := b; end;
function Vec4.getabg: Vec3; begin Result.r := a; Result.g := b; Result.b := g; end;
function Vec4.getabr: Vec3; begin Result.r := a; Result.g := b; Result.b := r; end;
function Vec4.getaga: Vec3; begin Result.r := a; Result.g := g; Result.b := a; end;
function Vec4.getagb: Vec3; begin Result.r := a; Result.g := g; Result.b := b; end;
function Vec4.getagg: Vec3; begin Result.r := a; Result.g := g; Result.b := g; end;
function Vec4.getagr: Vec3; begin Result.r := a; Result.g := g; Result.b := r; end;
function Vec4.getara: Vec3; begin Result.r := a; Result.g := r; Result.b := a; end;
function Vec4.getarb: Vec3; begin Result.r := a; Result.g := r; Result.b := b; end;
function Vec4.getarg: Vec3; begin Result.r := a; Result.g := r; Result.b := g; end;
function Vec4.getarr: Vec3; begin Result.r := a; Result.g := r; Result.b := r; end;
function Vec4.getbaa: Vec3; begin Result.r := b; Result.g := a; Result.b := a; end;
function Vec4.getbab: Vec3; begin Result.r := b; Result.g := a; Result.b := b; end;
function Vec4.getbag: Vec3; begin Result.r := b; Result.g := a; Result.b := g; end;
function Vec4.getbar: Vec3; begin Result.r := b; Result.g := a; Result.b := r; end;
function Vec4.getbba: Vec3; begin Result.r := b; Result.g := b; Result.b := a; end;
function Vec4.getbbb: Vec3; begin Result.r := b; Result.g := b; Result.b := b; end;
function Vec4.getbbg: Vec3; begin Result.r := b; Result.g := b; Result.b := g; end;
function Vec4.getbbr: Vec3; begin Result.r := b; Result.g := b; Result.b := r; end;
function Vec4.getbga: Vec3; begin Result.r := b; Result.g := g; Result.b := a; end;
function Vec4.getbgb: Vec3; begin Result.r := b; Result.g := g; Result.b := b; end;
function Vec4.getbgg: Vec3; begin Result.r := b; Result.g := g; Result.b := g; end;
function Vec4.getbgr: Vec3; begin Result.r := b; Result.g := g; Result.b := r; end;
function Vec4.getbra: Vec3; begin Result.r := b; Result.g := r; Result.b := a; end;
function Vec4.getbrb: Vec3; begin Result.r := b; Result.g := r; Result.b := b; end;
function Vec4.getbrg: Vec3; begin Result.r := b; Result.g := r; Result.b := g; end;
function Vec4.getbrr: Vec3; begin Result.r := b; Result.g := r; Result.b := r; end;
function Vec4.getgaa: Vec3; begin Result.r := g; Result.g := a; Result.b := a; end;
function Vec4.getgab: Vec3; begin Result.r := g; Result.g := a; Result.b := b; end;
function Vec4.getgag: Vec3; begin Result.r := g; Result.g := a; Result.b := g; end;
function Vec4.getgar: Vec3; begin Result.r := g; Result.g := a; Result.b := r; end;
function Vec4.getgba: Vec3; begin Result.r := g; Result.g := b; Result.b := a; end;
function Vec4.getgbb: Vec3; begin Result.r := g; Result.g := b; Result.b := b; end;
function Vec4.getgbg: Vec3; begin Result.r := g; Result.g := b; Result.b := g; end;
function Vec4.getgbr: Vec3; begin Result.r := g; Result.g := b; Result.b := r; end;
function Vec4.getgga: Vec3; begin Result.r := g; Result.g := g; Result.b := a; end;
function Vec4.getggb: Vec3; begin Result.r := g; Result.g := g; Result.b := b; end;
function Vec4.getggg: Vec3; begin Result.r := g; Result.g := g; Result.b := g; end;
function Vec4.getggr: Vec3; begin Result.r := g; Result.g := g; Result.b := r; end;
function Vec4.getgra: Vec3; begin Result.r := g; Result.g := r; Result.b := a; end;
function Vec4.getgrb: Vec3; begin Result.r := g; Result.g := r; Result.b := b; end;
function Vec4.getgrg: Vec3; begin Result.r := g; Result.g := r; Result.b := g; end;
function Vec4.getgrr: Vec3; begin Result.r := g; Result.g := r; Result.b := r; end;
function Vec4.getraa: Vec3; begin Result.r := r; Result.g := a; Result.b := a; end;
function Vec4.getrab: Vec3; begin Result.r := r; Result.g := a; Result.b := b; end;
function Vec4.getrag: Vec3; begin Result.r := r; Result.g := a; Result.b := g; end;
function Vec4.getrar: Vec3; begin Result.r := r; Result.g := a; Result.b := r; end;
function Vec4.getrba: Vec3; begin Result.r := r; Result.g := b; Result.b := a; end;
function Vec4.getrbb: Vec3; begin Result.r := r; Result.g := b; Result.b := b; end;
function Vec4.getrbg: Vec3; begin Result.r := r; Result.g := b; Result.b := g; end;
function Vec4.getrbr: Vec3; begin Result.r := r; Result.g := b; Result.b := r; end;
function Vec4.getrga: Vec3; begin Result.r := r; Result.g := g; Result.b := a; end;
function Vec4.getrgb: Vec3; begin {Result.r := r; Result.g := g; Result.b := b;} move(self,Result,SizeOf(Result)) end;
function Vec4.getrgg: Vec3; begin Result.r := r; Result.g := g; Result.b := g; end;
function Vec4.getrgr: Vec3; begin Result.r := r; Result.g := g; Result.b := r; end;
function Vec4.getrra: Vec3; begin Result.r := r; Result.g := r; Result.b := a; end;
function Vec4.getrrb: Vec3; begin Result.r := r; Result.g := r; Result.b := b; end;
function Vec4.getrrg: Vec3; begin Result.r := r; Result.g := r; Result.b := g; end;
function Vec4.getrrr: Vec3; begin Result.r := r; Result.g := r; Result.b := r; end;

procedure Vec4.setaa (const a: Vec2); begin Self.a := r; Self.a := g; end;
procedure Vec4.setab (const a: Vec2); begin Self.a := r; Self.b := g; end;
procedure Vec4.setag (const a: Vec2); begin Self.a := r; Self.g := g; end;
procedure Vec4.setar (const a: Vec2); begin Self.a := r; Self.r := g; end;
procedure Vec4.setba (const a: Vec2); begin Self.b := r; Self.a := g; end;
procedure Vec4.setbb (const a: Vec2); begin Self.b := r; Self.b := g; end;
procedure Vec4.setbg (const a: Vec2); begin Self.b := r; Self.g := g; end;
procedure Vec4.setbr (const a: Vec2); begin Self.b := r; Self.r := g; end;
procedure Vec4.setga (const a: Vec2); begin Self.g := r; Self.a := g; end;
procedure Vec4.setgb (const a: Vec2); begin Self.g := r; Self.b := g; end;
procedure Vec4.setgg (const a: Vec2); begin Self.g := r; Self.g := g; end;
procedure Vec4.setgr (const a: Vec2); begin Self.g := r; Self.r := g; end;
procedure Vec4.setra (const a: Vec2); begin Self.r := r; Self.a := g; end;
procedure Vec4.setrb (const a: Vec2); begin Self.r := r; Self.b := g; end;
procedure Vec4.setrg (const a: Vec2); begin Self.r := r; Self.g := g; end;
procedure Vec4.setrr (const a: Vec2); begin Self.r := r; Self.r := g; end;
procedure Vec4.setaaa(const a: Vec3); begin Self.a := r; Self.a := g; Self.a := b;  end;
procedure Vec4.setaab(const a: Vec3); begin Self.a := r; Self.a := g; Self.b := b;  end;
procedure Vec4.setaag(const a: Vec3); begin Self.a := r; Self.a := g; Self.g := b;  end;
procedure Vec4.setaar(const a: Vec3); begin Self.a := r; Self.a := g; Self.r := b;  end;
procedure Vec4.setaba(const a: Vec3); begin Self.a := r; Self.b := g; Self.a := b;  end;
procedure Vec4.setabb(const a: Vec3); begin Self.a := r; Self.b := g; Self.b := b;  end;
procedure Vec4.setabg(const a: Vec3); begin Self.a := r; Self.b := g; Self.g := b;  end;
procedure Vec4.setabr(const a: Vec3); begin Self.a := r; Self.b := g; Self.r := b;  end;
procedure Vec4.setaga(const a: Vec3); begin Self.a := r; Self.g := g; Self.a := b;  end;
procedure Vec4.setagb(const a: Vec3); begin Self.a := r; Self.g := g; Self.b := b;  end;
procedure Vec4.setagg(const a: Vec3); begin Self.a := r; Self.g := g; Self.g := b;  end;
procedure Vec4.setagr(const a: Vec3); begin Self.a := r; Self.g := g; Self.r := b;  end;
procedure Vec4.setara(const a: Vec3); begin Self.a := r; Self.r := g; Self.a := b;  end;
procedure Vec4.setarb(const a: Vec3); begin Self.a := r; Self.r := g; Self.b := b;  end;
procedure Vec4.setarg(const a: Vec3); begin Self.a := r; Self.r := g; Self.g := b;  end;
procedure Vec4.setarr(const a: Vec3); begin Self.a := r; Self.r := g; Self.r := b;  end;
procedure Vec4.setbaa(const a: Vec3); begin Self.b := r; Self.a := g; Self.a := b;  end;
procedure Vec4.setbab(const a: Vec3); begin Self.b := r; Self.a := g; Self.b := b;  end;
procedure Vec4.setbag(const a: Vec3); begin Self.b := r; Self.a := g; Self.g := b;  end;
procedure Vec4.setbar(const a: Vec3); begin Self.b := r; Self.a := g; Self.r := b;  end;
procedure Vec4.setbba(const a: Vec3); begin Self.b := r; Self.b := g; Self.a := b;  end;
procedure Vec4.setbbb(const a: Vec3); begin Self.b := r; Self.b := g; Self.b := b;  end;
procedure Vec4.setbbg(const a: Vec3); begin Self.b := r; Self.b := g; Self.g := b;  end;
procedure Vec4.setbbr(const a: Vec3); begin Self.b := r; Self.b := g; Self.r := b;  end;
procedure Vec4.setbga(const a: Vec3); begin Self.b := r; Self.g := g; Self.a := b;  end;
procedure Vec4.setbgb(const a: Vec3); begin Self.b := r; Self.g := g; Self.b := b;  end;
procedure Vec4.setbgg(const a: Vec3); begin Self.b := r; Self.g := g; Self.g := b;  end;
procedure Vec4.setbgr(const a: Vec3); begin Self.b := r; Self.g := g; Self.r := b;  end;
procedure Vec4.setbra(const a: Vec3); begin Self.b := r; Self.r := g; Self.a := b;  end;
procedure Vec4.setbrb(const a: Vec3); begin Self.b := r; Self.r := g; Self.b := b;  end;
procedure Vec4.setbrg(const a: Vec3); begin Self.b := r; Self.r := g; Self.g := b;  end;
procedure Vec4.setbrr(const a: Vec3); begin Self.b := r; Self.r := g; Self.r := b;  end;
procedure Vec4.setgaa(const a: Vec3); begin Self.g := r; Self.a := g; Self.a := b;  end;
procedure Vec4.setgab(const a: Vec3); begin Self.g := r; Self.a := g; Self.b := b;  end;
procedure Vec4.setgag(const a: Vec3); begin Self.g := r; Self.a := g; Self.g := b;  end;
procedure Vec4.setgar(const a: Vec3); begin Self.g := r; Self.a := g; Self.r := b;  end;
procedure Vec4.setgba(const a: Vec3); begin Self.g := r; Self.b := g; Self.a := b;  end;
procedure Vec4.setgbb(const a: Vec3); begin Self.g := r; Self.b := g; Self.b := b;  end;
procedure Vec4.setgbg(const a: Vec3); begin Self.g := r; Self.b := g; Self.g := b;  end;
procedure Vec4.setgbr(const a: Vec3); begin Self.g := r; Self.b := g; Self.r := b;  end;
procedure Vec4.setgga(const a: Vec3); begin Self.g := r; Self.g := g; Self.a := b;  end;
procedure Vec4.setggb(const a: Vec3); begin Self.g := r; Self.g := g; Self.b := b;  end;
procedure Vec4.setggg(const a: Vec3); begin Self.g := r; Self.g := g; Self.g := b;  end;
procedure Vec4.setggr(const a: Vec3); begin Self.g := r; Self.g := g; Self.r := b;  end;
procedure Vec4.setgra(const a: Vec3); begin Self.g := r; Self.r := g; Self.a := b;  end;
procedure Vec4.setgrb(const a: Vec3); begin Self.g := r; Self.r := g; Self.b := b;  end;
procedure Vec4.setgrg(const a: Vec3); begin Self.g := r; Self.r := g; Self.g := b;  end;
procedure Vec4.setgrr(const a: Vec3); begin Self.g := r; Self.r := g; Self.r := b;  end;
procedure Vec4.setraa(const a: Vec3); begin Self.r := r; Self.a := g; Self.a := b;  end;
procedure Vec4.setrab(const a: Vec3); begin Self.r := r; Self.a := g; Self.b := b;  end;
procedure Vec4.setrag(const a: Vec3); begin Self.r := r; Self.a := g; Self.g := b;  end;
procedure Vec4.setrar(const a: Vec3); begin Self.r := r; Self.a := g; Self.r := b;  end;
procedure Vec4.setrba(const a: Vec3); begin Self.r := r; Self.b := g; Self.a := b;  end;
procedure Vec4.setrbb(const a: Vec3); begin Self.r := r; Self.b := g; Self.b := b;  end;
procedure Vec4.setrbg(const a: Vec3); begin Self.r := r; Self.b := g; Self.g := b;  end;
procedure Vec4.setrbr(const a: Vec3); begin Self.r := r; Self.b := g; Self.r := b;  end;
procedure Vec4.setrga(const a: Vec3); begin Self.r := r; Self.g := g; Self.a := b;  end;
procedure Vec4.setrgb(const a: Vec3); begin Self.r := r; Self.g := g; Self.b := b;  end;
procedure Vec4.setrgg(const a: Vec3); begin Self.r := r; Self.g := g; Self.g := b;  end;
procedure Vec4.setrgr(const a: Vec3); begin Self.r := r; Self.g := g; Self.r := b;  end;
procedure Vec4.setrra(const a: Vec3); begin Self.r := r; Self.r := g; Self.a := b;  end;
procedure Vec4.setrrb(const a: Vec3); begin Self.r := r; Self.r := g; Self.b := b;  end;
procedure Vec4.setrrg(const a: Vec3); begin Self.r := r; Self.r := g; Self.g := b;  end;
procedure Vec4.setrrr(const a: Vec3); begin Self.r := r; Self.r := g; Self.r := b;  end;


{ TFrames }
{
procedure TFrames.Init(p:TPixelProc;t:double);
var n:Integer;
begin
  Frames.ItemIndex := 0;

  for n := 0 to High(Frames.Threads) do
  begin
    Threads[n] := TFrameThread.Create(true);
    Threads[n].Bitmap := TBitmap32.Create;
    Threads[n].IsDone := False;
    Threads[n].proc := p;
    Threads[n].Time := 1+0.4*n;
    Frames.Threads[n].resume;
  end;
  Frames.SetSize(512, 512);

end;

procedure TFrames.Resume;
var n:Integer;
begin
  for n := 0 to High(Frames.Threads) do
    Frames.Threads[n].resume;
end;

procedure TFrames.Setproc(const Value: TPixelProc);
var n:Integer;
begin
  for n := 0 to High(Frames.Threads) do
    Frames.Threads[n].proc := Value;
end;

procedure TFrames.SetSize(w, h: Integer);
var n:Integer;
begin
  for n := 0 to High(Frames.Threads) do
  begin
    Frames.Threads[n].Width := w;
    Frames.Threads[n].Height := h;
//    repeat until Frames.Threads[n].IsDone;
    Frames.Threads[n].Synchronize(Frames.Threads[n].Resize);
  end;
end;

procedure TFrames.Suspend;
var n:Integer;
begin
  for n := 0 to High(Frames.Threads) do
    Frames.Threads[n].Suspend;
end;

procedure TFrameThread.Resize;
begin
  Bitmap.SetSize(Width,Height);
  isDone := False;
end;
}

function Ifthen(c:Boolean;const a,b:Vec2):Vec2;overload;{$IFDEF DO_INLINE} inline;{$ENDIF}
begin
  if c then
    Result := a
  else
    Result := b
end;

function Ifthen(c:Boolean;const a,b:Vec3):Vec3;overload;{$IFDEF DO_INLINE} inline;{$ENDIF}
begin
  if c then
    Result := a
  else
    Result := b
end;

function Ifthen(c:Boolean;const a,b:Vec4):Vec4;overload;{$IFDEF DO_INLINE} inline;{$ENDIF}
begin
  if c then
    Result := a
  else
    Result := b
end;


class operator Vec4.Add(const a: Vec4; b: TVecType): Vec4;
begin
  Result.x := a.x + b;
  Result.y := a.y + b;
  Result.z := a.z + b;
  Result.w := a.w + b;
end;

constructor Vec4.create(w: TVecType; const ax: Vec3);
begin
  x := w;
  y := ax.x;
  z := ax.y;
  self.w := ax.z;
end;

class operator Vec4.Divide(const a: vec4; b: TVecType): Vec4;
var n:TVecType;
begin
  if b=0 then
    exit(default(vec4));
  n := 1/b;
  Result.x := a.x*n;
  Result.y := a.y*n;
  Result.z := a.z*n;
  Result.w := a.w*n;
end;

class operator Vec4.Divide(const a: vec4; b: int64): Vec4;
var n:TVecType;
begin
  if b=0 then
    exit(default(vec4));
  n := 1/b;
  Result.x := a.x*n;
  Result.y := a.y*n;
  Result.z := a.z*n;
  Result.w := a.w*n;
end;

function Vec4.Dot(const b: Vec4): TVecType;
begin
  Result := x * b.x + y * b.y + z * b.z + w * b.w;
end;

class operator Vec2.explicit(const a: TPoint): Vec2;
begin
  result.x := a.X;
  result.y := a.Y;
end;

class operator Vec2.explicit(const a: TPointF): Vec2;
begin
  result.x := a.X;
  result.y := a.Y;
end;

{ Mat3 }

class operator Mat3.Add(const a: Mat3; const b: Vec3): Vec3;
begin
  Result.x := a.r1.x + b.x;
  Result.y := a.r2.y + b.y;
  Result.z := a.r3.z + b.z;
end;

constructor Mat3.Create(a1, a2, a3, b1, b2, b3, c1, c2, c3: TVecType);
begin
  r1.x := a1;  r1.y := a2;  r1.z := a3;
  r2.x := b1;  r2.y := b2;  r2.z := b3;
  r3.x := c1;  r3.y := c2;  r3.z := c3;
end;

class operator Mat3.Multiply(const a: Vec3; const b: Mat3): Vec3;
begin
//  works, but needs extra function calls
//  Result.x := b.r1.Dot(a);
//  Result.y := b.r2.Dot(a);
//  Result.z := b.r3.Dot(a);


  Result.x := b.r1.x * a.x + b.r1.y * a.y + b.r1.z * a.z;
  Result.y := b.r2.x * a.x + b.r2.y * a.y + b.r2.z * a.z;
  Result.z := b.r3.x * a.x + b.r3.y * a.y + b.r3.z * a.z;

end;

class operator Mat3.Multiply(const a: Mat3; const b: Vec3): Vec3;
begin
//  Result.x := a.r1.Dot(b);
//  Result.y := a.r2.Dot(b);
//  Result.z := a.r3.Dot(b);

  Result.x := a.r1.x * b.x + a.r1.y * b.y + a.r1.z * b.z;
  Result.y := a.r2.x * b.x + a.r2.y * b.y + a.r2.z * b.z;
  Result.z := a.r3.x * b.x + a.r3.y * b.y + a.r3.z * b.z;

end;

constructor Mat3.Create(const a, b, c: Vec3);
begin
  r1 := a;
  r2 := b;
  r3 := c;
end;

class operator Mat3.Multiply(const a, b: Mat3): Mat3;
begin
  Result.r1 := a.r1 * b.r1;
  Result.r2 := a.r2 * b.r2;
  Result.r3 := a.r3 * b.r3;
end;

class operator Mat3.Negative(const a: Mat3): Mat3;
begin
  Result.r1 := -a.r1;
  Result.r2 := -a.r2;
  Result.r3 := -a.r3;
end;

{ Mat4 }

constructor Mat4.Create(a1, a2, a3, a4, b1, b2, b3, b4, c1, c2, c3, c4, d1, d2,
  d3, d4: TVecType);
begin
  r1.x := a1;  r1.y := a2;  r1.z := a3; r1.w := a4;
  r2.x := b1;  r2.y := b2;  r2.z := b3; r2.w := b4;
  r3.x := c1;  r3.y := c2;  r3.z := c3; r3.w := c4;
  r4.x := d1;  r4.y := d2;  r4.z := d3; r4.w := d4;
end;

class operator Mat4.Multiply(const a: Mat4; const b: Vec4): Vec4;
begin
  Result.x := a.r1.Dot(b);
  Result.y := a.r2.Dot(b);
  Result.z := a.r3.Dot(b);
  Result.w := a.r4.Dot(b);
end;


function fwidth(const a: Vec2): TVecType;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;
begin
  Result := System.abs(a.x)+
            System.abs(a.y);
end;

function fwidth(const a: Vec3): TVecType;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;
begin
  Result := System.abs(a.x)+
            System.abs(a.y)+
            System.abs(a.z);
end;

function fwidth(const a: Vec4): TVecType;{$IFDEF DO_INLINE} inline;{$ENDIF} overload;
begin
  Result := System.abs(a.x)+
            System.abs(a.y)+
            System.abs(a.z)+
            System.abs(a.w);
end;






class operator Mat4.Multiply(const a, b: Mat4): Mat4;
begin
  Result.r1 := a.r1 * b.r1;
  Result.r2 := a.r2 * b.r2;
  Result.r3 := a.r3 * b.r3;
  Result.r4 := a.r4 * b.r4;
end;

{ Mat2 }

constructor Mat2.Create(a1, a2, b1, b2: TVecType);
begin
  r1.x := a1;  r1.y := a2;
  r2.x := b1;  r2.y := b2;
end;

class operator Mat2.Multiply(const a: Mat2; const b: Vec2): Vec2;
begin
  Result.x := a.r1.Dot(b);
  Result.y := a.r2.Dot(b);
end;

class operator Mat2.Multiply(const b: Vec2; const a: Mat2): Vec2;
begin
  Result.x := b.Dot(a.r1);
  Result.y := b.Dot(a.r2);
end;

function hash(n:Double):Double;overload;
begin
  Result := fract(sinLarge(n) * 43758.5453123);
end;

function hash(const n:vec2):vec2;overload;
begin
  Result := fract(sinLarge(n) * 43758.5453123);
end;

function hash(const n:vec3):vec3;overload;
begin
  Result := fract(sinLarge(n) * 43758.5453123);
end;

function hash(const n:vec4):vec4;overload;
begin
  Result := fract(sinLarge(n) * 43758.5453123);
end;


{ TTextureCube }

procedure TTextureCube.Load(Mask: string);
var
  f:TFace;
  fn:string;
begin
  for f in [POSITIVE_X..NEGATIVE_Z] do
  begin
    fn := StringReplace(Mask,'?',IntToStr(ord(f)),[  ]);
    if Faces[f]=nil then
      Faces[f] := tbitmap32.Create;
    TShader.LoadTexture(Faces[f], fn);
  end;
end;

procedure SelfTest;
  procedure TestFloor(x:double);
  var v2_1,v2_2:Vec2;
  begin
    v2_1.x := x;
    v2_1.y := x;
    v2_2 := floor(v2_1);
    Assert(v2_2.x = Math.Floor(v2_1.x));
    Assert(v2_2.y = Math.Floor(v2_1.y));
  end;

begin
  TestFloor( -100);
  TestFloor( -1.9);
  TestFloor( -1.1);
  TestFloor( -1  );
  TestFloor( -0.9);
  TestFloor( -0.1);
  TestFloor( -0.0);
  TestFloor(  0.0);
  TestFloor(  0.1);
  TestFloor(  0.9);
  TestFloor(  1  );
  TestFloor(  1.1);
  TestFloor(  1.9);
  TestFloor(  100);

  Assert(sin(Vec3.create(0,0,0)).x=0);
  Assert(sin(Vec3.create(0,0,0)).y=0);
  Assert(sin(Vec3.create(0,0,0)).z=0);
  Assert(cos(Vec3.create(0,0,0)).x=1);
  Assert(cos(Vec3.create(0,0,0)).y=1);
  Assert(cos(Vec3.create(0,0,0)).z=1);
end;


{ TThreadedShader }
(*
constructor TThreadedShader.Create(aShader: TShader);
var i:integer;
begin
  inherited Create;
  for I := 0 to 3 do
  begin
    Shaders[I].Shader := aShader.Create;
    Shaders[I].Shader.PixelProc := aShader.PixelProc;
    Shaders[I].Shader.LineProc := aShader.LineProc;
    Shaders[I].Shader.LastFrame := aShader.LastFrame;
    Shaders[I].Shader.UseBackBuffer := aShader.UseBackBuffer;
    Shaders[I].Shader.FrameProc := aShader.FrameProc;
    Shaders[I].Shader.iMouse := aShader.iMouse;
    Shaders[I].Shader.Mouse := aShader.Mouse;
    Shaders[I].Shader.Resolution := aShader.Resolution;
    Shaders[I].Shader.Frame := aShader.Frame;
    Shaders[I].Shader.Time := aShader.Time;
    Shaders[I].Shader.iGlobalTime := aShader.iGlobalTime;

  end;

  Shaders[0].Area   := Vec4.create(0.0,0.0,0.5,0.5);
  Shaders[1].Area   := Vec4.create(0.5,0.0,1.0,0.5);
  Shaders[2].Area   := Vec4.create(0.0,0.5,0.5,1.0);
  Shaders[3].Area   := Vec4.create(0.5,0.5,1.0,1.0);

  for I := 0 to 3 do
  begin
    Shaders[I].Rect.Left   := trunc(Shaders[I].Area.x * Buffer.Width);
    Shaders[I].Rect.Top    := trunc(Shaders[I].Area.y * Buffer.Height);
    Shaders[I].Rect.Right  := trunc(Shaders[I].Area.z * Buffer.Width);
    Shaders[I].Rect.Bottom := trunc(Shaders[I].Area.w * Buffer.Height);
  end;


end;

procedure TThreadedShader.RenderThreads(bitmap: TBitmap32);
var i:integer;
  b:TBitmap32;
begin
  for I := 0 to 3 do
  begin
        Shaders[I].Shader.OnProgress := self.OnProgress;
        Shaders[I].Shader.Mouse := self.Mouse;
        Shaders[I].Shader.iMouse := self.iMouse;
        Shaders[I].Shader.SetSize(trunc(Resolution.x),trunc(Resolution.y));
        Shaders[I].Shader.iGlobalTime := self.iGlobalTime;
        Shaders[I].Shader.Time        := self.iGlobalTime;

        Shaders[I].Rect.Left   := trunc(Shaders[I].Area.x * Buffer.Width);
        Shaders[I].Rect.Top    := trunc(Shaders[I].Area.y * Buffer.Height);
        Shaders[I].Rect.Right  := trunc(Shaders[I].Area.z * Buffer.Width);
        Shaders[I].Rect.Bottom := trunc(Shaders[I].Area.w * Buffer.Height);
  end;

{
    TThread.CreateAnonymousThread(
      procedure
      begin
        b := TBitmap32.Create;
        b.SetSize(trunc(Resolution.x),trunc(Resolution.y));
        Shaders[I].Shader.RenderTo(b,Shaders[I].Rect);

        TThread.Synchronize( TThread.CurrentThread, procedure
        begin
          b.DrawTo(bitmap, Shaders[I].Rect, Shaders[I].Rect);
        end);
        b.SaveToFile(format('%s_%d.bmp',[ Shaders[I].Shader.ClassName, i]));
        b.Free;
      end).Start;
}
  Shaders[0].Thread := TThread.CreateAnonymousThread(
      procedure
      begin
        TThread.Synchronize(TThread.CurrentThread, procedure
        begin
        b := TBitmap32.Create;
        b.SetSize(trunc(Resolution.x),trunc(Resolution.y));
        end );
        Shaders[0].Shader.RenderTo(b,Shaders[I].Rect);

        TThread.Synchronize( TThread.CurrentThread, procedure
        begin
          b.DrawTo(bitmap, Shaders[0].Rect, Shaders[0].Rect);

        b.SaveToFile(format('%s_%d.bmp',[ Shaders[0].Shader.ClassName, 0]));
        b.Free;
        end);
        TThread.CurrentThread.Terminate;
      end);

  Shaders[0].Thread.Start;

  repeat

  until (Shaders[0].Thread.Finished);


end;

*)


class operator IVec2.Add(const a: iVec2; b: TVecType): iVec2;
begin
  Result.x := trunc(Result.x + b);
  Result.y := trunc(Result.y + b);
end;

{ TBuffer }

procedure TBuffer.Render;
var
  px, py   : Integer;
  fracCoord: Vec2;
begin
  if Assigned(FrameProc) then
    FrameProc;

  if not Assigned(PixelProc) then
    Exit;

  for py := 0 to Bitmap.Height - 1 do
  begin
    if assigned(OnProgress) then
       OnProgress(py,Bitmap.Height);

    if Assigned(LineProc) then
      LineProc(py);

    fracCoord.y := Bitmap.Height - py - 1;
    for px := 0 to Bitmap.Width - 1 do
    begin
      fracCoord.x := px;
      Bitmap.Pixel[px, py] := PixelProc(fracCoord);
    end;
  end;
end;

initialization
//  Frames.Init(nil,0);
//  Frames.Resume;
 {$IFDEF DEBUG}
 SelfTest;
 {$ENDIF}
finalization
//  FreeAndNil(FShaders);

end.
