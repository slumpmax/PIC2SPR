unit XPRoutine;

interface

uses
  Vcl.Forms, Classes, Windows, Vcl.Controls, Vcl.ExtCtrls, SysUtils, DateUtils,
  Vcl.Graphics, Vcl.StdCtrls, Messages, Math, Variants, ShlObj, DB, Registry,
  ActiveX, Vcl.Grids, Vcl.Imaging.PNGImage, MMSystem, UITypes;

const
  MaxColor32ArrayIndex = 536870910;
  MaxColor32ArrayIndex2 = 23169;
//  MaxColor32ArrayIndex2 = 268435455;

type
  TPalFileHeader = packed record
    Signature: array[0..3] of AnsiChar; // "RIFF"
    Length: Cardinal; // file length in bytes (excluding "RIFF")
    PalSignature: array[0..3] of AnsiChar; // "PAL "
    procedure Initialize(APalCount: Word);
  end;
  PPalFileEntry = ^TPalFileEntry;
  TPalFileEntry = packed record
    Red, Green, Blue, Flags: Byte; // Flags always 0
    procedure Initialize(R, G, B, Flags: Byte);
  end;
  PPalFileChunk = ^TPalFileChunk;
  TPalFileChunk = packed record
    Signature: array[0..3] of AnsiChar; // "data", "offl", "tran", "unde"
    Length: Cardinal; // chunk size in bytes (excluding chunk signature)
    Version: Word; // always $0300
    PalCount: Word;
    procedure Initialize(APalCount: Word);
  end;

  PColor32 = ^TColor32;
  TColor32 = packed record
  private
    function GetColor: TColor;
    function GetHTML: string;
    function GetGrayScale: Byte;
  public
    function ChangeAlpha(AAlpha: Byte): TColor32;
    procedure SetRGBA(R, G, B, A: Byte);
    procedure SetGrayScale(AValue: Byte); overload;
    procedure SetGrayScale(AValue: Byte; AAlpha: Byte); overload;
    property Color: TColor read GetColor;
    property GrayScale: Byte read GetGrayScale write SetGrayScale;
    property HTML: string read GetHTML;
    class function Create(R, G, B, A: Byte): TColor32; overload; static;
    class function Create(AValue: Cardinal): TColor32; overload; static;
    class operator Equal(C1, C2: TColor32): Boolean;
    class operator NotEqual(C1, C2: TColor32): Boolean;
  case Integer of
    0: (B, G, R, A: Byte);
    1: (Value: Cardinal);
    2: (BGRA: Cardinal);
    3: (Planes: array[0..3] of Byte);
  end;

  PColor32Array = ^TColor32Array;
  TColor32Array = array[0..MaxColor32ArrayIndex] of TColor32;
  TArrayOfColor32 = array of TColor32;

  PColor32Surface = ^TColor32Surface;
  TColor32Surface = array[0..MaxColor32ArrayIndex2, 0..MaxColor32ArrayIndex2] of TColor32;
  TSurfaceOfColor32 = array of TArrayOfColor32;

  PColor15 = ^TColor15;
  TColor15 = packed record
  private
    function GetR: Byte;
    function GetB: Byte;
    function GetG: Byte;
    procedure SetB(AValue: Byte);
    procedure SetG(AValue: Byte);
    procedure SetR(AValue: Byte);
    function GetColor32: TColor32;
    procedure SetColor32(AValue: TColor32);
    function GetColor32A: TColor32;
    procedure SetColor32A(AValue: TColor32);
    function GetA: Byte;
    procedure SetA(AValue: Byte);
  public
    Value: Word;
    property Color32: TColor32 read GetColor32 write SetColor32;
    property Color32A: TColor32 read GetColor32A write SetColor32A;
    property R: Byte read GetR write SetR;
    property G: Byte read GetG write SetG;
    property B: Byte read GetB write SetB;
    property A: Byte read GetA write SetA;
  end;

  PColor16 = ^TColor16;
  TColor16 = packed record
  private
    function GetR: Byte;
    function GetB: Byte;
    function GetG: Byte;
    procedure SetB(AValue: Byte);
    procedure SetG(AValue: Byte);
    procedure SetR(AValue: Byte);
    function GetColor32: TColor32;
    procedure SetColor32(AValue: TColor32);
  public
    Value: Word;
    property Color32: TColor32 read GetColor32 write SetColor32;
    property R: Byte read GetR write SetR;
    property G: Byte read GetG write SetG;
    property B: Byte read GetB write SetB;
  end;

  PGRB332Color = ^TGRB332Color; // 1 byte = GGGRRRBB, MSX SCREEN 8
  TGRB332Color = packed record
  private
    function GetR: Byte;
    function GetB: Byte;
    function GetG: Byte;
    procedure SetB(AValue: Byte);
    procedure SetG(AValue: Byte);
    procedure SetR(AValue: Byte);
    function GetColor32: TColor32;
    procedure SetColor32(AValue: TColor32);
  public
    Value: Byte;
    class function Create(R, G, B: Byte): TGRB332Color; overload; static;
    class function Create(AColor16: TColor16): TGRB332Color; overload; static;
    class function Create(AColor32: TColor32): TGRB332Color; overload; static;
    property R: Byte read GetR write SetR;
    property G: Byte read GetG write SetG;
    property B: Byte read GetB write SetB;
    property Color32: TColor32 read GetColor32 write SetColor32;
  end;

  PBGRAColorEntry = PColor32;
  TBGRAColorEntry = TColor32;

  PRGBAColorEntry = ^TRGBAColorEntry;
  TRGBAColorEntry = packed record
  public
    function Color: TColor;
    function Color32: TColor32;
  case Integer of
    0: (R, G, B, A: Byte);
    1: (RGBA: Cardinal);
    3: (Planes: array[0..3] of Byte);
  end;

  PColorEntry = ^TColorEntry;
  TColorEntry = packed record
  private
    function GetHTML: string;
    function GetGrayScale: Byte;
    procedure SetGrayScale(const Value: Byte);
    function GetColor: TColor;
    procedure SetColor(const AValue: TColor);
    function GetColor32: TColor32;
    procedure SetColor32(const AValue: TColor32);
  public
    class operator Equal(A, B: TColorEntry): Boolean;
    function OppositeBW: TColor;
    function Difference(AColorEntry: TColorEntry): Integer;
    property Color: TColor read GetColor write SetColor;
    property Color32: TColor32 read GetColor32 write SetColor32;
    property GrayScale: Byte read GetGrayScale write SetGrayScale;
    property HTML: string read GetHTML;
  case Integer of
    0: (R, G, B, N: Byte);
    1: (RGBN: Cardinal);
    2: (Planes: array[0..3] of Byte);
  end;

  PRGBColorEntry = ^TRGBColorEntry;
  TRGBColorEntry = packed record
  private
    function GetColor32: TColor32;
    procedure SetColor32(AValue: TColor32);
  public
    procedure SetRGB(R, G, B: Byte);
    property Color32: TColor32 read GetColor32 write SetColor32;
  case Integer of
    0: (R, G, B: Byte);
    1: (Planes: array[0..2] of Byte);
  end;

  PBGRColorEntry = ^TBGRColorEntry;
  TBGRColorEntry = packed record
  private
    function GetColor32: TColor32;
    procedure SetColor32(AValue: TColor32);
  public
    procedure SetRGB(R, G, B: Byte);
    property Color32: TColor32 read GetColor32 write SetColor32;
  case Integer of
    0: (B, G, R: Byte);
    1: (Planes: array[0..2] of Byte);
  end;
  PColor24Entry = ^TColor24Entry;
  TColor24Entry = TBGRColorEntry;

  TCMYKEntry = packed record
  public
    function R: Byte;
    function G: Byte;
    function B: Byte;
    function Color: TColor;
    function Color32: TColor32;
  case Integer of
    0: (C, M, Y, K: Byte);
    1: (CMYK: Cardinal);
    2: (Planes: array[0..3] of Byte);
  end;

  PYJKColor = ^TYJKColor;
  TYJKColor = packed record
  private
    function GetY(AIndex: Integer): Integer;
    function GetJ: Integer;
    function GetK: Integer;
    procedure SetY(AIndex, AValue: Integer);
    procedure SetJ(AValue: Integer);
    procedure SetK(AValue: Integer);
    function GetColor32(AIndex: Integer): TColor32;
    procedure SetColor32(AIndex: Integer; AValue: TColor32);
  public
    procedure SetYJK(Y0, Y1, Y2, Y3, J, K: Integer);
    property Y[AIndex: Integer]: Integer read GetY write SetY;
    property J: Integer read GetJ write SetJ;
    property K: Integer read GetK write SetK;
    property Color32[AIndex: Integer]: TColor32 read GetColor32 write SetColor32;
    case Integer of
      0: (Planes: array[0..3] of Byte);
      1: (Value: Cardinal);
  end;

  PYJKAColor = ^TYJKAColor;
  TYJKAColor = packed record
  private
    function GetY(AIndex: Integer): Integer;
    function GetJ: Integer;
    function GetK: Integer;
    procedure SetY(AIndex, AValue: Integer);
    procedure SetJ(AValue: Integer);
    procedure SetK(AValue: Integer);
    function GetColor32(AIndex: Integer): TColor32;
    procedure SetColor32(AIndex: Integer; AValue: TColor32);
    function GetColor4(AIndex: Integer): Byte;
    procedure SetColor4(AIndex: Integer; AValue: Byte);
    function GetA(AIndex: Integer): Integer;
    procedure SetA(AIndex, AValue: Integer);
  public
    procedure SetYJK(Y0, Y1, Y2, Y3, J, K: Integer);
    procedure SetPlanes(P0, P1, P2, P3: Byte); overload;
    procedure SetPlanes(var Planes); overload;
    property Y[AIndex: Integer]: Integer read GetY write SetY;
    property J: Integer read GetJ write SetJ;
    property K: Integer read GetK write SetK;
    property A[AIndex: Integer]: Integer read GetA write SetA;
    property Color32[AIndex: Integer]: TColor32 read GetColor32 write SetColor32;
    property Color4[AIndex: Integer]: Byte read GetColor4 write SetColor4;
    case Integer of
      0: (Planes: array[0..3] of Byte);
      1: (Value: Cardinal);
  end;

  TYUVColor = packed record
  private
    function GetY(AIndex: Integer): Integer;
    function GetU: Integer;
    function GetV: Integer;
    procedure SetY(AIndex, AValue: Integer);
    procedure SetU(AValue: Integer);
    procedure SetV(AValue: Integer);
    function GetColor32(AIndex: Integer): TColor32;
    procedure SetColor32(AIndex: Integer; AValue: TColor32);
  public
    Planes: array[0..3] of Byte;
    procedure SetYUV(Y0, Y1, Y2, Y3, U, V: Integer);
    property Y[AIndex: Integer]: Integer read GetY write SetY;
    property U: Integer read GetU write SetU;
    property V: Integer read GetV write SetV;
    property Color32[AIndex: Integer]: TColor32 read GetColor32 write SetColor32;
  end;

  TFloatRect = record
  private
    function GetHeight: Double;
    function GetWidth: Double;
    procedure SetHeight(const Value: Double);
    procedure SetWidth(const Value: Double);
  public
    Left, Top, Right, Bottom: Double;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Double);
    procedure SetRect(ALeft, ATop, ARight, ABottom: Double);
    property Width: Double read GetWidth write SetWidth;
    property Height: Double read GetHeight write SetHeight;
  end;

  TMarginRect = record
  public
    Left, Top, Right, Bottom: Double;
    procedure SetMargin(ALeft, ATop, ARight, ABottom: Double);
  end;

const
  c32Clear:   TColor32 = (B: $00; G: $00; R: $00; A: $00);
  c32Red:     TColor32 = (B: $00; G: $00; R: $FF; A: $FF);
  c32Green:   TColor32 = (B: $00; G: $FF; R: $00; A: $FF);
  c32Blue:    TColor32 = (B: $FF; G: $00; R: $00; A: $FF);
  c32Black:   TColor32 = (B: $00; G: $00; R: $00; A: $FF);
  c32White:   TColor32 = (B: $FF; G: $FF; R: $FF; A: $FF);
  c32Yellow:  TColor32 = (B: $00; G: $FF; R: $FF; A: $FF);
  c32Cyan:    TColor32 = (B: $FF; G: $FF; R: $00; A: $FF);
  c32Magenta: TColor32 = (B: $FF; G: $00; R: $FF; A: $FF);
  c32Silver:  TColor32 = (B: $C0; G: $C0; R: $C0; A: $FF);
  c32Gray:    TColor32 = (B: $80; G: $80; R: $80; A: $FF);

type
  PArrayOfByte = ^TArrayOfByte;
  TArrayOfByte = array of Byte;
  TArrayOfWord = array of Word;
  TArrayOfSmallInt = array of SmallInt;
  TArrayOfInt = array of Integer;
  TArrayOfString = array of string;
  PSmallIntArray = ^TSMallIntArray;
  TSmallIntArray = array[0..255] of SmallInt;
  PCharArray = ^TCharArray;
  TCharArray = array[0..MaxInt div 2 - 1] of Char;
  PStringArray = ^TStringArray;
  TStringArray = array[0..32676] of string;

  PByteIndex = ^TByteIndex;
  TByteIndex = array[0..MaxInt - 1] of Byte;

  TInt64Entry = packed record
  public
    procedure ReverseOrder;
    procedure ReverseWord;
    procedure ReverseCardinal;
  case Integer of
    0: (Value: Int64);
    1: (Bytes: array[0..7] of Byte);
    2: (Words: array[0..3] of Word);
    3: (Cardinals: array[0..1] of Cardinal);
  end;
  TCardinalEntry = packed record
  public
    procedure ReverseOrder;
    procedure ReverseWord;
  case Integer of
    0: (Value: Cardinal);
    1: (Bytes: array[0..3] of Byte);
    2: (Words: array[0..1] of Word);
  end;
  TWordEntry = packed record
  public
    procedure ReverseOrder;
  case Integer of
    0: (Value: Word);
    1: (Bytes: array[0..1] of Byte);
  end;
  TUInt24 = packed record
  private
    function GetValue: Integer;
    procedure SetValue(AValue: Integer);
  public
    Datas: array[0..2] of Byte;
    property Value: Integer read GetValue write SetValue;
  end;

  TXPBoolean = (xpToggle = -1, xpFalse = 0, xpTrue = 1);

  TStreamHelperXP = class helper for TSTream
  public
    function ReadChar(var AChar: Char): Integer;
    function WriteChar(AChar: Char): Integer;
    function ReadString(AMaxLength: Integer = 0): string;
    function WriteString(AText: string): Integer;
    function Readln(var AText: string): Boolean;
    function Writeln(AText: string): Integer;
    function NextTextSection(var ASection: string): Boolean;
    function SeekTextSection(ASection: string): Boolean;
  end;

  TStringGridHelperXP = class helper for TStringGrid
  public
    procedure InsertRow(ARow: Integer; ATexts: array of string);
  end;

  TPNGImageHelper = class helper for TPNGImage
  public
    procedure LoadFromResourceType(AResourceName, AResourceType: string);
  end;

function IntInside(AValue, AMin, AMax: Integer): Integer;
procedure SwapInt(var a, b: Integer);
procedure SwapIntOrder(var a, b: Integer);
function MinInt(a, b: Integer): Integer;
function MaxInt(a, b: Integer): Integer;

function FloatRect(Left, Top, Right, Bottom: Double): TFloatRect;
function FloatBounds(ALeft, ATop, AWidth, AHeight: Double): TFloatRect;
function CompactRect(ARect: TRect; n: Integer): TRect; overload;
function CompactRect(ARect: TRect; AWidth, AHeight: Integer): TRect; overload;
function CompactRect(ARect: TRect; ALeft, ATop, ARight, ABottom: Integer): TRect; overload;
function CompactRect(ARect, AMargin: TRect): TRect; overload;
function ExpandRect(ARect: TRect; n: Integer): TRect; overload;
function ExpandRect(ARect: TRect; AWidth, AHeight: Integer): TRect; overload;
function ExpandRect(ARect: TRect; ALeft, ATop, ARight, ABottom: Integer): TRect; overload;
function ExpandRect(ARect, AMargin: TRect): TRect; overload;
function MoveRect(ARect: TRect; px, py: Integer): TRect;
function CrossRect(ARect1, ARect2: TRect): TRect;
function UnionRect(ARect1, ARect2: TRect): TRect;
function CropRange(var a1, a2: Integer; b1, b2: Integer): Boolean;
function CropRect(var srect: TRect; drect: TRect): Boolean; overload;
function CropRect(var srect: TRect; drect: TRect; var xoffs, yoffs: Integer; xflip, yflip: Boolean): Boolean; overload;
procedure CropMin(AMin: Integer; var AValue: Integer);
procedure CropMax(AMax: Integer; var AValue: Integer);
function InsideInt(n, a, b: Integer): Boolean;
function OutsideInt(n, a, b: Integer): Boolean;
function InsideRect(px, py: Integer; ARect: TRect): Boolean;
function InsideRects(px, py: Integer; ARects: array of TRect): Integer;
function OutsideRect(px, py: Integer; ARect: TRect): Boolean;
function StringIndex(AString: string; AList: array of string): Integer;
function TextInArray(AText: string; AArray: array of string): Boolean;

function GetListCount(AList: TList): Integer;
function RoundToInt(AValue: Double): Integer;
function FontStylesToInt(AStyle: TFontStyles): Integer;
function IntToFontStyles(AValue: Integer): TFontStyles;
function FontStylesToStr(AStyle: TFontStyles): string;
function StrToFontStyles(AValue: string): TFontStyles;

procedure TextOutLineTo(cv: TCanvas; x, y: Integer; text: string; fc, bc: TColor);
procedure TextSmoothTo(cv: TCanvas; x, y: Integer; text: string; fc, bc: TColor; thick: Integer = 1);

procedure DrawDotHLine(ACanvas: TCanvas; MinX, MaxX, Y, AGap: Integer; AColor: TColor; AOffset: Integer = -1);
procedure DrawDotVLine(ACanvas: TCanvas; X, MinY, MaxY, AGap: Integer; AColor: TColor; AOffset: Integer = -1);

procedure FreeMemNil(var APointer); inline;

function AbsoluteDiv(a, b: Integer): Integer;
function AbsoluteMod(a, b: Integer): Integer;
function SafeDiv(a, b: Double; c: Double = 0.0): Double;

function iif(r: boolean; a, b: Variant): Variant;
function VarToIntDef(V: Variant; ADefault: Integer): Integer;
function VarToFloatDef(V: Variant; ADefault: Double): Double;
function VarToBoolDef(V: Variant; ADefault: Boolean): Boolean;
function VarToDateTimeDef(V: Variant; ADefault: TDateTime): TDateTime;
function VarToStrDef(V: Variant; ADefault: string): string;
function VarIsZero(V: Variant): Boolean;

function FieldToStr(AField: TField): string;
function VariantStr(AValue: Variant): string;
function StrToFieldValue(AValue: string; ADataType: TFieldType): Variant;
function PosLength(ASubStr, AMainStr: string): Integer;

function CurrencyStrZ(AValue: Double; ADigit: Integer = 2): string; overload;
function CurrencyStrZ(AValue: Variant; ADigit: Integer = 2): string; overload;
function CurrencyStr(AValue: Double; ADigit: Integer = 2): string; overload;
function CurrencyStr(AValue: Variant; ADigit: Integer = 2): string; overload;
function CurrencyToFloat(s: string): Double;
function NumericStr(AValue: Double): string;
function RoundFloat(Value: Double; Decimal: Integer): Double;
function GenerateGUID: string;

function THDateTimeZ(ADateTime: TDateTime): string; overload;
function THDateTimeZ(AValue: Variant): string; overload;
function THDateTime(ADateTime: TDateTime): string; overload;
function THDateTime(AValue: Variant): string; overload;
function THShortDate(ADateTime: TDateTime): string; overload;
function THShortDate(AValue: Variant): string; overload;
function THStrToDate(AText: string; ADefault: TDateTime = 0.0): TDateTime;
function MicroTime: Double; overload;
function MicroTime(ADateTime: TDateTime): Double; overload;
function DateTimeOfMicroTime(AMicroTime: Double): TDateTime;

function Color32OfByte(R, G, B: Byte; A: Byte = 255): TColor32;
function Color32OfColor(AColor: TColor; AAlpha: Byte = 255): TColor32;
function Color32(AValue: Cardinal): TColor32;
function Color32OfGrayScale(AGrayScale: Byte; AAlpha: Byte = 255): TColor32;
function Color32OfHTML(AText: string): TColor32;
function ColorOfByte(AR, AG, AB: Byte): TColor;
function ColorOfGrayScale(AGrayScale: Byte): TColor;
function ColorOfHTML(AText: string): TColor;
function GetMonoColor(color, mcolor: TColor32): TColor32;
function GrayScaleOfColor(AColor: TColor): Integer;
function GrayScaleOfColor32(AColor32: TColor32): Integer;
function GrayScaleOfRGB(r, g, b: Byte): Integer;
function OppositeColorBW(AColor: TColor): TColor;

procedure GradHorizontal(Canvas: TCanvas; Rect: TRect; FromColor, ToColor: TColor);
procedure GradVertical(Canvas: TCanvas; Rect: TRect; FromColor, ToColor: TColor);
procedure GradImage(ACanvas: TCanvas; ARect: TRect; TopColor, BottomColor: TColor); overload;
procedure GradImage(AImage: TImage; TopColor, BottomColor: TColor); overload;
procedure GradImage(AImage: TImage; AColor: TColor); overload;
function GradImage(AControl: TWinControl; TopColor, BottomColor: TColor): TImage; overload;
function GradImage(AControl: TWinControl; AColor: TColor): TImage; overload;
function GradImage(AForm: TForm): TImage; overload;
function AutoGradImage(AControl: TWinControl; TopColor, BottomColor: TColor): TImage; overload;
function AutoGradImage(AControl: TWinControl; AColor: TColor): TImage; overload;
procedure SetPanelColor(APanel: TPanel; AImage: TImage);
procedure SetGroupBoxColor(AGroupBox: TGroupBox; AImage: TImage);
procedure EnableWinControl(AWincontrol: TWinControl; AFontColor: TColor = clWindowText);
procedure DisableWinControl(AWinControl: TWinControl; AFontColor: TColor = clMedGray);
procedure ScrollMemoToHome(AMemo: TMemo);
procedure ScrollMemoToEnd(AMemo: TMemo);
procedure GetComPortName(AStrings: TStrings; AAvailableOnly: Boolean);
function ComPortExists(APortName: string): Boolean;

procedure AlignCenter(AControl: TWinControl);
procedure AlignLeft(AControl: TWinControl);
procedure AlignRight(AControl: TWinControl);
procedure TransparentControl(AControl: TWinControl);

function FetchString(const ADelimiter: string; var ASource: string): string;
function FetchInteger(const ADelimiter: string; var ASource: string; ADefault: Integer = 0): Integer;
function FetchDouble(const ADelimiter: string; var ASource: string; ADefault: Double = 0.0): Double; overload;
function FetchDouble(const ADelimiter: string; var AValue: Double; var ASource: string; ADefault: Double = 0.0): Integer; overload;

function BinToDec(AText: string): Integer;
function DecToBin(AValue: Integer; ADigit: Integer = 0): string;
function OctToDec(AText: string): Integer;
function DecToOct(AValue: Integer; ADigit: Integer = 0): string;
function HexToDec(AText: string): Integer;
function DecToHex(AValue: Integer; ADigit: Integer = 0): string;

function CharToHex(AChar: Char): string; overload;
function CharToHex(AChar: Byte): string; overload;
function IntToChar(AValue: Int64; HighToLow: Boolean; ACount: Integer): string;
function HexChar(AIndex: Integer): Char; inline;
function HexToChar(AHex: string): Char;
function IntToHex(AValue: Integer; ADigit: Integer = 0): string;
function StringToHex(AText: string): string;
function HexToString(AHexText: string): string;
function HexEncode(var AVar; ALength: Integer; ASeparator: string = ''): string; overload;
function HexEncode(AVar: array of Byte; ASeparator: string = ''; ANewLine: Integer = 0;
   ALinePrefix: string = ''): string; overload;
function HexEncode(AVar: array of Word; ASeparator: string = ''; ANewLine: Integer = 0;
   ALinePrefix: string = ''): string; overload;
function HexEncode(AVar: array of Integer; ASeparator: string = ''; ANewLine: Integer = 0;
   ALinePrefix: string = ''): string; overload;
function HexEncode(AVar: array of Cardinal; ASeparator: string = ''; ANewLine: Integer = 0;
   ALinePrefix: string = ''): string; overload;
function HexEncode(var AVar; ALength, ADataSize: Integer; ASeparator: string = '';
  ANewLine: Integer = 0; ALinePrefix: string = ''): string; overload;
function HexEncode(AText: string; ASeparator: string): string; overload;
function HexDecode(AHexText: string; ASeparator: string): string;
function FileExtPos(AFileName, AFilter: string): Integer;
function GetTickDiff(AOldTick, ANewTick: Integer): Integer;
function GetUserStringDateTime(const UserString: string): TDateTime;
function GetPrintChar(AData: Byte): Char;
function GetPrintStr(AData: string): string;
function SamePrefixText(AText, APrefix: string): Boolean;
function SamePrefixStr(AText, APrefix: string): Boolean;
function SplitText(var AValues: Variant; AText, ASeparator: string): Integer;
function IndexStr(AStr: string; AArray: array of string): Integer;
function IndexText(AText: string; AArray: array of string): Integer;
function IndexPrefixStr(AStr: string; AArray: array of string): Integer;
function IndexPrefixText(AText: string; AArray: array of string): Integer;
function URLEncode(s: string): string;
function RepeatString(AText: AnsiString; ACount: Integer): AnsiString;
function ReplaceString(AText: AnsiString; AStart, ALength: Integer;
  ASubText: AnsiString): AnsiString;
function TextLine(AText: AnsiString; AFillChar: AnsiChar; AWidth: Integer): AnsiString;

function BrowseForFolder(var AFolder: string; const BrowseTitle: string): Boolean;
function IsDriveReady(const ADrive: string): Boolean;
procedure GetDriveLetters(AList: TStrings);
function GetDriveNumber(const Drive: string): Integer;
procedure GetFolderList(AList: TStrings; APath: string; AFolderOnly: Boolean; AFilter: string);
procedure GetFileList(AList: TStrings; AFileSpec: string;
  ARecursived: Boolean; APrefix: string = '');
function FindFileExists(AFolder: string; ASpecs: array of string;
  ARecursived: Boolean): Boolean;
procedure CategoryFiles(ASourceFolder, ADestFolder: string; ASpecs: array of string);
procedure Category3DFiles(ASourceFolder, ADestFolder: string);
function FileCount(var AFileCount, AFolderCount: Integer; AFolder: string): string;
procedure CompactFolder(ASourceFolder, ADestFolder: string);
procedure MoveFolder(ASourceFolder, ADestFolder: string);

procedure CloneProperties(const Source: TControl; const Dest: TControl);
function ReplaceControlEx(AControl: TControl; const AControlClass: TControlClass;
  const ANewName: string; const IsFreed : Boolean = True): TControl;
function ReplaceControl(AControl: TControl; const ANewName: string;
  const IsFreed : Boolean = True): TControl;
procedure CopyControl(ASource, ADest: TControl);
procedure SetTextBufDirect(AEdit: TEdit; ABuffer: PChar);
procedure SetTextDirect(AEdit: TEdit; NewText: string);

procedure PlayMedia(AWin: TWinControl; AFileName: string; Repeated: Boolean = False);
procedure CloseMedia;

implementation

function IntInside(AValue, AMin, AMax: Integer): Integer;
{$IFDEF WIN32}
asm
  // eax = AValue
  // edx = AMin
  // ecx = AMax
    cmp   eax,edx
    jge   @no_less
    mov   eax,edx

  @no_less:
    cmp   eax,ecx
    jle   @no_more
    mov   eax,ecx

  @no_more:
{$ELSE}
begin
  if AValue < AMin then
    Result := AMin
  else if AValue > AMax then
    Result := AMax
  else Result := AValue;
{$ENDIF}
end;

procedure SwapInt(var a, b: Integer);
asm
{$IFDEF Win32}
// eax = [a]
// edx = [b]
    mov  ecx,[eax]     // ecx := [a]
    xchg ecx,[edx]     // ecx <-> [b]
    mov  [eax],ecx     // [a] := ecx
{$ELSE}
// rcx = [a]
// rdx = [b]
    mov  eax,[rcx]     // eax := [a]
    xchg eax,[rdx]     // eax <-> [b]
    mov  [rcx],eax     // [a] := eax
{$ENDIF}
end;

procedure SwapIntOrder(var a, b: Integer);
asm
{$IFDEF Win32}
// eax = [a]
// edx = [b]
    mov  ecx,[eax]     // ecx := [a]
    cmp  ecx,[edx]
    jle  @exit         // ecx <= [b]? Exit
    xchg ecx,[edx]     // ecx <-> [b]
    mov  [eax],ecx     // [a] := ecx
{$ELSE}
// rcx = [a]
// rdx = [b]
    mov  eax,[rcx]     // eax := [a]
    cmp  eax,[rdx]
    jle  @exit         // eax <= [b]? Exit
    xchg eax,[rdx]     // eax <-> [b]
    mov  [rcx],eax     // [a] := eax
{$ENDIF}
  @exit:
end;

function MinInt(a, b: Integer): Integer;
asm
{$IFDEF Win32}
// eax = a
// edx = b
    cmp   eax,edx
    jle   @exit
    mov   eax,edx
{$ELSE}
// ecx = a
// edx = b
    cmp   ecx,edx
    mov   eax,ecx
    jle   @exit
    mov   eax,edx
{$ENDIF}
  @exit:
end;

function MaxInt(a, b: Integer): Integer;
asm
{$IFDEF Win32}
// eax = a
// edx = b
    cmp   eax,edx
    jge   @exit
    mov   eax,edx
{$ELSE}
// ecx = a
// edx = b
    cmp   ecx,edx
    mov   eax,ecx
    jge   @exit
    mov   eax,edx
{$ENDIF}
  @exit:
end;

function FloatRect(Left, Top, Right, Bottom: Double): TFloatRect;
begin
  Result.SetRect(Left, Top, Right, Bottom);
end;

function FloatBounds(ALeft, ATop, AWidth, AHeight: Double): TFloatRect;
begin
  Result.SetBounds(ALeft, ATop, AWidth, AHeight);
end;

function CompactRect(ARect: TRect; n: Integer): TRect;
begin
  Result := ExpandRect(ARect, -n, -n);
end;

function CompactRect(ARect: TRect; AWidth, AHeight: Integer): TRect;
begin
  Result := ExpandRect(ARect, -AWidth, -AHeight);
end;

function CompactRect(ARect: TRect; ALeft, ATop, ARight, ABottom: Integer): TRect;
begin
  Result := ExpandRect(ARect, -ALeft, -ATop, -ARight, -ABottom);
end;

function CompactRect(ARect, AMargin: TRect): TRect;
begin
  Result := ExpandRect(ARect, -AMargin.Left, -AMargin.Top, -AMargin.Right, -AMargin.Bottom);
end;

function ExpandRect(ARect: TRect; n: Integer): TRect;
begin
  Result := ExpandRect(ARect, n, n);
end;

function ExpandRect(ARect: TRect; AWidth, AHeight: Integer): TRect;
begin
  Result.Left := ARect.Left - AWidth;
  Result.Right := ARect.Right + AWidth;
  Result.Top := ARect.Top - AHeight;
  Result.Bottom := ARect.Bottom + AHeight;
end;

function ExpandRect(ARect: TRect; ALeft, ATop, ARight, ABottom: Integer): TRect;
begin
  Result.Left := ARect.Left - ALeft;
  Result.Right := ARect.Right + ARight;
  Result.Top := ARect.Top - ATop;
  Result.Bottom := ARect.Bottom + ABottom;
end;

function ExpandRect(ARect, AMargin: TRect): TRect;
begin
  Result.Left := ARect.Left - AMargin.Left;
  Result.Right := ARect.Right + AMargin.Right;
  Result.Top := ARect.Top - AMargin.Top;
  Result.Bottom := ARect.Bottom + AMargin.Bottom;
end;

function MoveRect(ARect: TRect; px, py: Integer): TRect;
begin
  Result.Left := ARect.Left + px;
  Result.Right := ARect.Right + px;
  Result.Top := ARect.Top + py;
  Result.Bottom := ARect.Bottom + py;
end;

function CrossRect(ARect1, ARect2: TRect): TRect;
begin
  if not CropRect(ARect1, ARect2) then ARect1 := Rect(0, 0, 0, 0);
  Result := ARect1;
end;

function UnionRect(ARect1, ARect2: TRect): TRect;
begin
  Result.Left := Min(ARect1.Left, ARect2.Left);
  Result.Top := Min(ARect1.Top, ARect2.Top);
  Result.Right := Max(ARect1.Right, ARect2.Right);
  Result.Bottom := Max(ARect1.Bottom, ARect2.Bottom);
end;

function CropRange(var a1, a2: Integer; b1, b2: Integer): Boolean;
begin
  CropMin(b1, a1);
  CropMax(b2, a2);
  Result := a1 < a2;
end;

function CropRect(var srect: TRect; drect: TRect): Boolean;
begin
  CropMin(drect.Left, srect.Left);
  CropMax(drect.Right, srect.Right);
  CropMin(drect.Top, srect.Top);
  CropMax(drect.Bottom, srect.Bottom);
  Result := (srect.Left < srect.Right) and (srect.Top < srect.Bottom);
end;

function CropRect(var srect: TRect; drect: TRect; var xoffs, yoffs: Integer; xflip, yflip: Boolean): Boolean;
begin
  xoffs := 0;
  yoffs := 0;
  if srect.Left < drect.Left then
  begin
    if not xflip then xoffs := xoffs + drect.Left - srect.Left;
    srect.Left := drect.Left;
  end;
  if srect.Right > drect.Right then
  begin
    if xflip then xoffs := xoffs + srect.Right - drect.Right;
    srect.Right := drect.Right;
  end;
  if srect.Left >= srect.Right then
  begin
    Result := False;
    Exit;
  end;
  if srect.Top < drect.Top then
  begin
    if not yflip then yoffs := yoffs + drect.Top - srect.Top;
    srect.Top := drect.Top;
  end;
  if srect.Bottom > drect.Bottom then
  begin
    if yflip then yoffs := yoffs + srect.Bottom - drect.Bottom;
    srect.Bottom := drect.Bottom;
  end;
  Result := srect.Top < srect.Bottom;
end;

procedure CropMin(AMin: Integer; var AValue: Integer);
{$IFDEF WIN32}
asm
// eax = AMin
// @edx = AValue
    cmp   eax,[edx]
    jle   @exit
    mov   [edx],eax
  @exit:
{$ELSE}
begin
  if AValue < AMin then AValue := AMin
{$ENDIF}
end;

procedure CropMax(AMax: Integer; var AValue: Integer);
{$IFDEF WIN32}
asm
// eax = AMax
// @edx = AValue
    cmp   eax,[edx]
    jge   @exit
    mov   [edx],eax
  @exit:
{$ELSE}
begin
  if AValue > AMax then AValue := AMax
{$ENDIF}
end;

function InsideInt(n, a, b: Integer): Boolean;
begin
  Result := (n >= a) and (n <= b);
end;

function OutsideInt(n, a, b: Integer): Boolean;
begin
  Result := (n < a) or (n > b);
end;

function InsideRect(px, py: Integer; ARect: TRect): Boolean;
begin
  Result := (px >= ARect.Left) and (px < ARect.Right) and (py >= ARect.Top) and (py < ARect.Bottom);
end;

function InsideRects(px, py: Integer; ARects: array of TRect): Integer;
var
  n: Integer;
begin
  Result := -1;
  n := Length(ARects);
  while (n > 0) and (Result < 0) do
  begin
    Dec(n);
    if InsideRect(px, py, ARects[n]) then Result := n;
  end;
end;

function OutsideRect(px, py: Integer; ARect: TRect): Boolean;
begin
  Result := (px < ARect.Left) and (px >= ARect.Right) and (py < ARect.Top) and (py >= ARect.Bottom);
end;

function StringIndex(AString: string; AList: array of string): Integer;
var
  n: Integer;
begin
  Result := -1;
  n := Length(AList);
  while (Result < 0) and (n > 0) do
  begin
    Dec(n);
    if AString = AList[n] then Result := n;
  end;
end;

function GetListCount(AList: TList): Integer;
begin
  if Assigned(AList) then
    Result := AList.Count
  else Result := 0;
end;

function RoundToInt(AValue: Double): Integer;
begin
  Result := Round(RoundTo(AValue, 0));
end;

function FontStylesToInt(AStyle: TFontStyles): Integer;
begin
  Result := 0;
  if fsBold in AStyle then Result := Result or 1;
  if fsItalic in AStyle then Result := Result or 2;
  if fsUnderline in AStyle then Result := Result or 4;
  if fsStrikeOut in AStyle then Result := Result or 8;
end;

function IntToFontStyles(AValue: Integer): TFontStyles;
begin
  Result := [];
  if (AValue and 1) <> 0 then Result := Result + [fsBold];
  if (AValue and 2) <> 0 then Result := Result + [fsItalic];
  if (AValue and 4) <> 0 then Result := Result + [fsUnderline];
  if (AValue and 8) <> 0 then Result := Result + [fsStrikeOut];
end;

function FontStylesToStr(AStyle: TFontStyles): string;
begin
  Result := Format('$%2.2X', [FontStylesToInt(AStyle)]);
end;

function StrToFontStyles(AValue: string): TFontStyles;
begin
  Result := IntToFontStyles(StrToIntDef(AValue, 0));
end;

function TextInArray(AText: string; AArray: array of string): Boolean;
var
  n: Integer;
begin
  Result := False;
  n := Length(AArray);
  while not Result and (n > 0) do
  begin
    Dec(n);
    if SameText(AArray[n], AText) then Result := True;
  end;
end;

procedure TextOutLineTo(cv: TCanvas; x, y: Integer; text: string; fc, bc: TColor);
begin
  cv.Brush.Style := bsClear;
  cv.Font.Color := bc;
  cv.TextOut(x - 1, y, text);
  cv.TextOut(x + 1, y, text);
  cv.TextOut(x, y - 1, text);
  cv.TextOut(x, y + 1, text);
  cv.Font.Color := fc;
  cv.TextOut(x, y, text);
end;

procedure TextSmoothTo(cv: TCanvas; x, y: Integer; text: String; fc, bc: TColor; thick: Integer = 1);
const
  Sampling = 2;
var
  w, h: Integer;
  bm_virtual: TBitmap;
  bm_render: TBitmap;
  cv_draw: TCanvas;
  x2, y2: Integer;
  i0, i1, o0: pbytearray;
begin
  w := cv.TextWidth(text) + thick * 2 + 4;
  h := cv.TextHeight(text) + thick * 2;

  bm_virtual := TBitmap.Create;
  bm_render := TBitmap.Create;
  try
    bm_virtual.Width := w * Sampling;
    bm_virtual.Height := h * Sampling;
    bm_virtual.PixelFormat := pf24bit;

    bm_render.Width := w;
    bm_render.Height := h;
    bm_render.PixelFormat := pf24bit;

    bm_render.Canvas.CopyRect(Rect(0, 0, w, h), cv, Rect(x, y, x + w, y + h));

    cv_draw := bm_virtual.Canvas;
    cv_draw.StretchDraw(Rect(0, 0, w * 2, h * 2), bm_render);

    cv_draw.Font.Color := fc;
    cv_draw.Font.Name := cv.Font.Name;
    cv_draw.Font.Size := cv.Font.Size * Sampling;
    cv_draw.Font.Style := cv.Font.Style;
    with cv_draw do
    begin
      Pen.Width := thick;
      Pen.Color := bc;
      Brush.Style := bsClear;
      BeginPath(Handle);
      TextOut(thick, thick, text);
      EndPath(Handle);
      StrokePath(Handle);
      TextOut(thick, thick, text);
    end;
    for y2 := 0 to h - 1 do
    begin
      i0 := bm_virtual.ScanLine[(y2 * 2)];
      i1 := bm_virtual.Scanline[(y2 * 2) + 1];
      o0 := bm_render.Scanline[y2];
      for x2 := 0 to w - 1 do
      begin
        o0[x2 * 3] := (i0[x2 * 2 * 3] + i1[x2 * 2 * 3] + i0[(x2 * 2 * 3) + 3] + i1[(x2 * 2 * 3) + 3]) div 4;
        o0[(x2 * 3) + 1] := (i0[(x2 * 2 * 3) + 1] + i1[(x2 * 2 * 3) + 1] + i0[(x2 * 2 * 3) + 4] + i1[(x2 * 2 * 3) + 4]) div 4;
        o0[(x2 * 3) + 2] := (i0[(x2 * 2 * 3) + 2] + i1[(x2 * 2 * 3) + 2] + i0[(x2 * 2 * 3) + 5] + i1[(x2 * 2 * 3) + 5]) div 4;
      end;
    end;
    cv.CopyRect(Rect(x, y, x + w, y + h), bm_render.Canvas, Rect(0, 0, w, h));
  finally
    bm_virtual.Free;
    bm_render.Free;
  end;
end;

procedure DrawDotHLine(ACanvas: TCanvas; MinX, MaxX, Y, AGap: Integer; AColor: TColor; AOffset: Integer = -1);
begin
  if AOffset > 0 then
    MinX := AOffset
  else MinX := MinX + (AGap - (MinX mod AGap)) mod AGap;
  while MinX <= MaxX do
  begin
    ACanvas.Pixels[MinX, Y] := AColor;
    Inc(MinX, AGap);
  end;
end;

procedure DrawDotVLine(ACanvas: TCanvas; X, MinY, MaxY, AGap: Integer; AColor: TColor; AOffset: Integer);
begin
  if AOffset > 0 then
    MinY := AOffset
  else MinY := MinY + (AGap - (MinY mod AGap)) mod AGap;
  while MinY <= MaxY do
  begin
    ACanvas.Pixels[X, MinY] := AColor;
    Inc(MinY, AGap);
  end;
end;

procedure FreeMemNil(var APointer);
var
  p: Pointer;
begin
  p := Pointer(APointer);
  Pointer(APointer) := nil;
  FreeMem(p);
end;

function AbsoluteDiv(a, b: Integer): Integer;
begin
  if b <> 0 then
    if a < 0 then
      Result := (a - b + 1) div b
    else Result := a div b
  else Result := 0;
end;

function AbsoluteMod(a, b: Integer): Integer;
begin
  if b <> 0 then
  begin
    Result := a mod b;
    if Result < 0 then Result := Result + b;
  end
  else Result := 0;
end;

function SafeDiv(a, b: Double; c: Double): Double;
begin
  if b = 0.0 then
    Result := c
  else Result := a / b;
end;

function iif(r: boolean; a, b: Variant): Variant;
begin
  if (r) then Result := a else Result := b;
end;

function VarToIntDef(V: Variant; ADefault: Integer): Integer;
begin
  if VarIsNULL(V) then
    Result := ADefault
  else if VarIsNumeric(V) then
    Result := Integer(V)
  else Result := StrToIntDef(VarToStrDef(V, ''), ADefault);
end;

function VarToFloatDef(V: Variant; ADefault: Double): Double;
begin
  if VarIsNULL(V) then
    Result := ADefault
  else if VarIsNumeric(V) or (VarType(V) = VarDate) then
    Result := Double(V)
  else Result := StrToFloatDef(VarToStrDef(V, ''), ADefault);
end;

function VarToBoolDef(V: Variant; ADefault: Boolean): Boolean;
begin
  if VarIsNULL(V) then
    Result := ADefault
  else if VarIsOrdinal(V) then
    Result := Boolean(V)
  else Result := StrToBoolDef(VarToStrDef(V, ''), ADefault);
end;

function VarToDateTimeDef(V: Variant; ADefault: TDateTime): TDateTime;
begin
  if VarIsNULL(V) then
    Result := ADefault
  else if VarIsStr(V) then
    Result := StrToDateTimeDef(VarToStrDef(V, ''), ADefault)
  else Result := VarToDateTime(V);
end;

function VarToStrDef(V: Variant; ADefault: string): string;
begin
  if VarIsNULL(V) then
    Result := ADefault
  else Result := VarToStr(V);
end;

function VarIsZero(V: Variant): Boolean;
begin
  Result := VarIsNull(V) or VarIsEmpty(V);
  if not Result then
  case VarType(V) of
    varUString, varString, varOleStr: Result := V = '';
    varShortInt, varSmallInt, varInteger, varByte: Result := V = 0;
    varSingle, varDouble, varCurrency, varDate: Result := V = 0.0;
  end;
end;

function FieldToStr(AField: TField): string;
begin
  Result := '';
  case AField.DataType of
    ftCurrency, ftFloat, ftBCD:
      if AField.AsFloat <> 0.0 then Result := Format('%2.2n', [AField.AsFloat]);
    ftInteger:
      if AField.AsInteger <> 0 then Result := IntToStr(AField.AsInteger);
    ftDate, ftTime, ftDateTime:
      if AField.AsFloat <> 0.0 then Result := THShortDate(AField.AsDateTime);
  else
    Result := AField.AsString;
  end;
end;

function VariantStr(AValue: Variant): string;
var
  d: Double;
  n: Integer;
begin
  Result := '';
  case VarType(AValue) of
    varCurrency, varSingle, varDouble:
    begin
      d := AValue;
      if d <> 0.0 then Result := Format('%2.2n', [d]);
    end;
    varInteger, varSmallInt, varShortInt, varByte, varWord, varLongWord, varInt64:
    begin
      n := AValue;
      if n <> 0 then Result := IntToStr(n);
    end;
    varDate:
    begin
      d := VarToDateTime(AValue);
      if d <> 0.0 then Result := THShortDate(d);
    end
  else
    Result := VarToStrDef(AValue, '');
  end;
end;

function StrToFieldValue(AValue: string; ADataType: TFieldType): Variant;
begin
  case ADataType of
    ftBoolean:
      Result := StrToBoolDef(AValue, False);
    ftCurrency, ftFloat, ftBCD:
      Result := CurrencyToFloat(AValue);
    ftInteger:
      Result := StrToIntDef(AValue, 0);
    ftDate, ftTime, ftDateTime:
      Result := THStrToDate(AValue, 0.0);
  else
    Result := AValue;
  end;
end;

function PosLength(ASubStr, AMainStr: string): Integer;
begin
  Result := Pos(ASubStr, AMainStr);
  if Result = 0 then Result := Length(AMainStr) + 1;
end;

function CurrencyStrZ(AValue: Double; ADigit: Integer): string;
begin
  if ADigit >= 0 then
    Result := Format('%.' + IntToStr(ADigit) + 'n', [AValue])
  else Result := Format('%n', [AValue]);
end;

function CurrencyStrZ(AValue: Variant; ADigit: Integer): string;
var
  n: Double;
begin
  if VarIsNULL(AValue) then
    n := 0.0
  else n := AValue;
  Result := CurrencyStrZ(n, ADigit);
end;

function CurrencyStr(AValue: Double; ADigit: Integer): string;
begin
  if AValue <> 0.0 then
    Result := CurrencyStrZ(AValue, ADigit)
  else Result := '';
end;

function CurrencyStr(AValue: Variant; ADigit: Integer): string;
var
  n: Double;
begin
  if VarIsNULL(AValue) then
    n := 0.0
  else n := AValue;
  Result := CurrencyStr(n, ADigit);
end;

function CurrencyToFloat(s: string): Double;
begin
  Result := StrToFloatDef(StringReplace(s, ',', '', []), 0.0);
end;

function NumericStr(AValue: Double): string;
begin
  Result := Format('%.0n', [AValue]);
end;

function RoundFloat(Value: Double; Decimal: Integer): Double;
var
  s: string;
begin
  s := IntToStr(Decimal);
  s := '%.' + s + 'f';
  s := Format(s, [Value]);
  Result := StrToFloatDef(s, 0.0);
end;

function GenerateGUID: string;
var
  id: TGUID;
begin
  Result := '';
  if CoCreateGuid(id) = S_OK then Result := GUIDToString(id);
end;

function THDateTimeZ(ADateTime: TDateTime): string;
begin
  if ADateTime <> 0.0 then
    Result := THDateTime(ADateTime)
  else Result := '';
end;

function THDateTimeZ(AValue: Variant): string;
begin
  Result := '';
  if not VarIsNull(AValue) then
  begin
    if AValue <> 0.0 then Result := THDateTime(AValue);
  end;
end;

function THDateTime(ADateTime: TDateTime): string;
var
  d, m, y: Integer;
begin
  d := DayOf(ADateTime);
  m := MonthOf(ADateTime);
  y := YearOf(ADateTime) + 543;
  Result := Format('%2.2d/%2.2d/%4.4d', [d, m, y]);
end;

function THDateTime(AValue: Variant): string;
var
  d: TDateTime;
begin
  Result := '';
  if not VarIsNull(AValue) then
  begin
    d := VarToDateTime(AValue);
    if d <> 0 then Result := THDateTime(d);
  end;
end;

function THShortDate(ADateTime: TDateTime): string;
var
  d, m, y: Integer;
begin
  d := DayOf(ADateTime);
  m := MonthOf(ADateTime);
  y := (YearOf(ADateTime) + 543) mod 100;
  Result := Format('%2.2d/%2.2d/%2.2d', [d, m, y]);
end;

function THShortDate(AValue: Variant): string;
begin
  if not VarIsNull(AValue) then
    Result := THShortDate(VarToDateTime(AValue))
  else Result := ''
end;

function THStrToDate(AText: string; ADefault: TDateTime = 0.0): TDateTime;
var
  p, d, m, y: Integer;
begin
  AText := Trim(AText);
  if AText = '' then
    Result := 0.0
  else
  begin
    p := Pos('/', AText);
    d := StrToIntDef(Copy(AText, 1, p - 1), 0);
    Delete(AText, 1, p);
    p := Pos('/', AText);
    m := StrToIntDef(Copy(AText, 1, p - 1), 0);
    Delete(AText, 1, p);
    y := StrToIntDef(AText, 0);
    if y < 100 then y := y + 2500;
    try
      Result := EncodeDateTime(y - 543, m, d, 0, 0, 0, 0);
    except
      Result := ADefault;
    end;
  end;
end;

function MicroTime: Double;
begin
  Result := MicroTime(Now);
end;

function MicroTime(ADateTime: TDateTime): Double;
begin
  ADateTime := IncHour(ADateTime, -7);
  ADateTime := IncDay(ADateTime, -2);
  ADateTime := IncYear(ADateTime, -70);
  Result := ADateTime * 60 * 60 * 24;
end;

function DateTimeOfMicroTime(AMicroTime: Double): TDateTime;
begin
  Result := AMicroTime / 60 / 60 / 24;
  Result := IncYear(Result, 70);
  Result := IncDay(Result, 2);
  Result := IncHour(Result, 7);
end;

function Color32OfByte(R, G, B: Byte; A: Byte): TColor32;
begin
  Result.R := R;
  Result.G := G;
  Result.B := B;
  Result.A := A;
end;

function Color32OfColor(AColor: TColor; AAlpha: Byte): TColor32;
begin
  with TColorEntry(AColor) do
  begin
    Result.R := R;
    Result.G := G;
    Result.B := B;
    Result.A := AAlpha;
  end;
end;

function Color32(AValue: Cardinal): TColor32;
begin
  Result.Value := AValue;
end;

function Color32OfGrayScale(AGrayScale: Byte; AAlpha: Byte): TColor32;
begin
  Result.R := AGrayScale;
  Result.G := AGrayScale;
  Result.B := AGrayScale;
  Result.A := AAlpha;
end;

function Color32OfHTML(AText: string): TColor32;
begin
  if Copy(AText, 1, 1) = '#' then AText[1] := '$';
  Result.BGRA := StrToIntDef(AText, 0);
end;

function ColorOfByte(AR, AG, AB: Byte): TColor;
begin
  with TColorEntry(Result) do
  begin
    R := AR;
    G := AG;
    B := AB;
    N := 0;
  end;
end;

function ColorOfGrayScale(AGrayScale: Byte): TColor;
begin
  with TColorEntry(Result) do
  begin
    R := AGrayScale;
    G := AGrayScale;
    B := AGrayScale;
    N := 0;
  end;
end;

function ColorOfHTML(AText: string): TColor;
var
  c: TColor32;
begin
  c := Color32OfHTML(AText);
  Result := c.Color;
end;

function GetMonoColor(color, mcolor: TColor32): TColor32;
asm
  // eax = color
  // edx = mcolor
    shr   eax,24
    mov   ecx,edx
    shr   ecx,24
    inc   eax
    imul  eax,ecx
    shl   eax,16
    and   eax,$FF000000
    and   edx,$00FFFFFF
    or    eax,edx
end;

function GrayScaleOfColor(AColor: TColor): Integer;
begin
  with TColorEntry(ColorToRGB(AColor)) do Result := GrayScaleOfRGB(R, G, B);
end;

function GrayScaleOfColor32(AColor32: TColor32): Integer;
begin
  with AColor32 do Result := GrayScaleOfRGB(R, G, B);
end;

function GrayScaleOfRGB(R, G, B: Byte): Integer;
begin
  Result := ((R * 61) + (G * 174) + (B * 21)) shr 8;
end;

function OppositeColorBW(AColor: TColor): TColor;
begin
  if GrayScaleOfColor(AColor) > 140 then
    Result := clBlack
  else Result := clWhite;
end;

procedure GradHorizontal(Canvas: TCanvas; Rect: TRect; FromColor, ToColor: TColor);
var
  X: Integer;
  dr, dg, db: Extended;
  C1,C2: TColor;
  r1, r2, g1, g2, b1, b2: Byte;
  R, G, B: Byte;
  cnt: Integer;
begin
  C1 := FromColor;
  R1 := GetRValue(C1);
  G1 := GetGValue(C1);
  B1 := GetBValue(C1);

  C2 := ToColor;
  R2 := GetRValue(C2);
  G2 := GetGValue(C2);
  B2 := GetBValue(C2);

  dr := (R2 - R1) / Rect.Right - Rect.Left;
  dg := (G2 - G1) / Rect.Right - Rect.Left;
  db := (B2 - B1) / Rect.Right - Rect.Left;

  cnt := 0;
  for X := Rect.Left to Rect.Right - 1 do
  begin
    R := R1 + Ceil(dr * cnt);
    G := G1 + Ceil(dg * cnt);
    B := B1 + Ceil(db * cnt);

    Canvas.Pen.Color := RGB(R, G, B);
    Canvas.MoveTo(X, Rect.Top);
    Canvas.LineTo(X, Rect.Bottom);
    Inc(cnt);
  end;
end;

procedure GradVertical(Canvas: TCanvas; Rect: TRect; FromColor, ToColor: TColor);
var
  Y: Integer;
  dr, dg, db: Extended;
  C1,C2: TColor;
  r1, r2, g1, g2, b1, b2: Byte;
  R, G, B: Byte;
  cnt: Integer;
begin
  C1 := FromColor;
  R1 := GetRValue(C1);
  G1 := GetGValue(C1);
  B1 := GetBValue(C1);

  C2 := ToColor;
  R2 := GetRValue(C2);
  G2 := GetGValue(C2);
  B2 := GetBValue(C2);

  dr := (R2 - R1) / Rect.Bottom - Rect.Top;
  dg := (G2 - G1) / Rect.Bottom - Rect.Top;
  db := (B2 - B1) / Rect.Bottom - Rect.Top;

  cnt := 0;
  for Y := Rect.Top to Rect.Bottom - 1 do
  begin
    R := R1 + Ceil(dr * cnt);
    G := G1 + Ceil(dg * cnt);
    B := B1 + Ceil(db * cnt);

    Canvas.Pen.Color := RGB(R, G, B);
    Canvas.MoveTo(Rect.Left, Y);
    Canvas.LineTo(Rect.Right, Y);
    Inc(cnt);
  end;
end;

procedure GradImage(ACanvas: TCanvas; ARect: TRect; TopColor, BottomColor: TColor);
var
  cr, cg, cb, nr, ng, nb: Double;
  n, ny: Integer;
begin
  ny := ARect.Bottom - ARect.Top;
  if ny <= 0 then Exit;

  TopColor := ColorToRGB(TopColor);
  BottomColor := ColorToRGB(BottomColor);
  cr := TopColor and $FF;
  cg := (TopColor shr 8)and $FF;
  cb := (TopColor shr 16)and $FF;
  nr := (cr - (BottomColor and $FF)) / ny;
  ng := (cg - ((BottomColor shr 8)and $FF)) / ny;
  nb := (cb - ((BottomColor shr 16)and $FF)) / ny;
  for n := ARect.Top to ARect.Bottom - 1 do
  begin
    ACanvas.Brush.Color :=  Round(cr - nr * n)
      or (Round(cg - ng * n) shl 8)
      or (Round(cb - nb * n) shl 16);
    ACanvas.FillRect(Rect(ARect.Left, n, ARect.Right, n + 1));
  end;
end;

procedure GradImage(AImage: TImage; TopColor, BottomColor: TColor);
var
  cr, cg, cb, nr, ng, nb: Double;
  n: Integer;
begin
//  AImage.Align := alClient;
  TopColor := ColorToRGB(TopColor);
  BottomColor := ColorToRGB(BottomColor);
  AImage.Align := alNone;
  AImage.SetBounds(0, 0, AImage.Parent.ClientWidth - 1, AImage.Parent.ClientHeight - 1);
  AImage.Anchors := [akLeft, akTop, akRight, akBottom];
  AImage.SendToBack;
  AImage.Stretch := True;
  AImage.Picture.Bitmap.Width := 1;
  AImage.Picture.Bitmap.Height := 512;
  cr := TopColor and $FF;
  cg := (TopColor shr 8)and $FF;
  cb := (TopColor shr 16)and $FF;
  nr := (cr - (BottomColor and $FF)) / 512;
  ng := (cg - ((BottomColor shr 8)and $FF)) / 512;
  nb := (cb - ((BottomColor shr 16)and $FF)) / 512;
  for n := 0 to 511 do
  begin
    AImage.Picture.Bitmap.Canvas.Pixels[0, n] := Round(cr - nr * n)
      or (Round(cg - ng * n) shl 8)
      or (Round(cb - nb * n) shl 16);
  end;
end;

procedure GradImage(AImage: TImage; AColor: TColor);
begin
  GradImage(AImage, $FFFFFF, AColor);
end;

function GradImage(AControl: TWinControl; TopColor, BottomColor: TColor): TImage;
begin
  Result := TImage.Create(nil);
  Result.Parent := AControl;
  GradImage(Result, TopColor, BottomColor);
end;

function GradImage(AControl: TWinControl; AColor: TColor): TImage;
begin
  Result := GradImage(AControl, $FFFFFF, AColor);
end;

function GradImage(AForm: TForm): TImage;
begin
  Result := GradImage(AForm, $FFFFFF, AForm.Color);
end;

function AutoGradImage(AControl: TWinControl; TopColor, BottomColor: TColor): TImage;
begin
  Result := TImage.Create(AControl);
  Result.Parent := AControl;
  GradImage(Result, TopColor, BottomColor);
end;

function AutoGradImage(AControl: TWinControl; AColor: TColor): TImage;
begin
  Result := AutoGradImage(AControl, $FFFFFF, AColor);
end;

procedure SetPanelColor(APanel: TPanel; AImage: TImage);
var
  y1, ny1, ny2: Integer;
begin
  y1 := APanel.Top;
  ny1 := APanel.Parent.ClientHeight;
  ny2 := AImage.Picture.Height;
  APanel.Color := AImage.Picture.Bitmap.Canvas.Pixels[0, AbsoluteDiv(y1 * ny2, ny1)];
end;

procedure SetGroupBoxColor(AGroupBox: TGroupBox; AImage: TImage);
var
  y1, ny1, ny2: Integer;
begin
  y1 := AGroupBox.Top;
  ny1 := AGroupBox.Parent.ClientHeight;
  ny2 := AImage.Picture.Height;
  AGroupBox.Color := AImage.Picture.Bitmap.Canvas.Pixels[0, AbsoluteDiv(y1 * ny2, ny1)];
end;

procedure EnableWinControl(AWincontrol: TWinControl; AFontColor: TColor = clWindowText);
var
  con: TControl;
  n: Integer;
begin
  if not AWincontrol.Enabled then
  begin
    for n := 0 to AWinControl.ControlCount - 1 do
    begin
      con := AWinControl.Controls[n];
      con.Enabled := con.HelpType = htContext;
      if con is TComboBox then with TComboBox(con) do
      begin
        SelStart := 0;
        SelLength := 0;
        Color := clWindow;
      end;
    end;
    if AWinControl is TGroupBox then
      TGroupBox(AWinControl).Font.Color := AFontColor
    else if AWinControl is TPanel then
      TPanel(AWinControl).Font.Color := AFontColor;
    AWinControl.Enabled := True;
  end;
end;

procedure DisableWinControl(AWinControl: TWinControl; AFontColor: TColor = clMedGray);
var
  con: TControl;
  n: Integer;
begin
  if AWincontrol.Enabled then
  begin
    for n := 0 to AWinControl.ControlCount - 1 do
    begin
      con := AWinControl.Controls[n];
      if con.Enabled then
        con.HelpType := htContext
      else con.HelpType := htKeyword;
      con.Enabled := False;
      if con is TComboBox then with TComboBox(con) do
      begin
        SelStart := 0;
        SelLength := 0;
        Color := clLtGray;
      end;
    end;
    if AWinControl is TGroupBox then
      TGroupBox(AWinControl).Font.Color := AFontColor
    else if AWinControl is TPanel then
      TPanel(AWinControl).Font.Color := AFontColor;
    AWinControl.Enabled := False;
  end;
end;

procedure ScrollMemoToHome(AMemo: TMemo);
begin
  SendMessage(AMemo.Handle, EM_LINESCROLL, 0, -AMemo.Lines.Count);
end;

procedure ScrollMemoToEnd(AMemo: TMemo);
begin
  SendMessage(AMemo.Handle, EM_LINESCROLL, 0, AMemo.Lines.Count);
end;

procedure GetComPortName(AStrings: TStrings; AAvailableOnly: Boolean);
var
  reg: TRegistry;
  sl: TStringList;
  n: Integer;
begin
  AStrings.Clear;
  if AAvailableOnly then
  begin
    reg := TRegistry.Create;
    try
      reg.RootKey := HKEY_LOCAL_MACHINE;
      if reg.OpenKeyReadOnly('\HARDWARE\DEVICEMAP\SERIALCOMM') then
      begin
        sl := TStringList.Create;
        try
          reg.GetValueNames(sl);
          for n := 0 to sl.Count - 1 do sl[n] := reg.ReadString(sl[n]);
          sl.Sort;
          for n := 0 to sl.Count - 1 do AStrings.Add(sl[n]);
        finally
          sl.Free;
        end;
      end;
    finally
      reg.Free;
    end;
  end
  else for n := 1 to 256 do AStrings.Add('COM' + IntToStr(n));
end;

function ComPortExists(APortName: string): Boolean;
var
  reg: TRegistry;
  sl: TStringList;
  n: Integer;
begin
  Result := False;
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_LOCAL_MACHINE;
    if reg.OpenKeyReadOnly('\HARDWARE\DEVICEMAP\SERIALCOMM') then
    begin
      sl := TStringList.Create;
      try
        reg.GetValueNames(sl);
        n := sl.Count;
        while (n > 0) and not Result do
        begin
          Dec(n);
          Result := SameText(sl[n], APortName);
        end;
      finally
        sl.Free;
      end;
    end;
  finally
    reg.Free;
  end;
end;

procedure AlignCenter(AControl: TWinControl);
begin
  SetWindowLong(AControl.Handle, GWL_STYLE,
  GetWindowLong(AControl.Handle, GWL_STYLE) or ES_CENTER);
  AControl.HandleNeeded;
  AControl.Repaint;
end;

procedure AlignLeft(AControl: TWinControl);
begin
  SetWindowLong(AControl.Handle, GWL_ExStyle,
  GetWindowLong(AControl.Handle, GWL_EXStyle) or WS_EX_LEFT);
  AControl.HandleNeeded;
  AControl.Repaint;
end;

procedure AlignRight(AControl: TWinControl);
begin
  SetWindowLong(AControl.Handle, GWL_ExStyle,
  GetWindowLong(AControl.Handle, GWL_EXStyle) or WS_EX_RIGHT);
  AControl.HandleNeeded;
  AControl.Repaint;
end;

procedure TransparentControl(AControl: TWinControl);
begin
  SetWindowLong(AControl.Handle, GWL_ExStyle,
  GetWindowLong(AControl.Handle, GWL_EXStyle) or WS_EX_TRANSPARENT);
  AControl.HandleNeeded;
  AControl.Repaint;
end;

function FetchString(const ADelimiter: string; var ASource: string): string;
var
  p: Integer;
begin
  ASource := TrimLeft(ASource);
  p := Pos(ADelimiter, ASource);
  if p = 0 then p := Length(ASource) + 1;
  Result := Copy(ASource, 1, p - 1);
  Delete(ASource, 1, p);
  ASource := TrimLeft(ASource);
end;

function FetchInteger(const ADelimiter: string; var ASource: string; ADefault: Integer = 0): Integer;
begin
  Result := StrToIntDef(FetchString(ADelimiter, ASource), ADefault);
end;

function FetchDouble(const ADelimiter: string; var ASource: string; ADefault: Double = 0.0): Double;
begin
  Result := StrToFloatDef(FetchString(ADelimiter, ASource), ADefault);
end;

function FetchDouble(const ADelimiter: string; var AValue: Double;
  var ASource: string; ADefault: Double = 0.0): Integer; overload;
var
  s: string;
begin
  s := FetchString(ADelimiter, ASource);
  if s <> '' then
  begin
    AValue := StrToFloatDef(s, ADefault);
    Result := 1;
  end
  else
  begin
    AValue := ADefault;
    Result := 0;
  end;
end;

function BinToDec(AText: string): Integer;
var
  b, n: Integer;
begin
  Result := 0;
  n := Length(AText);
  while n > 0 do
  begin
    if AText[n] = '1' then
      b := 1
    else b := 0;
    Result := (Result shl 1) or b;
    Dec(n);
  end;
end;

function DecToBin(AValue: Integer; ADigit: Integer = 0): string;
var
  c: Char;
begin
  Result := '';
  while AValue > 0 do
  begin
    if (AValue and 1) = 1 then
      c := '1'
    else c := '0';
    Result := Result + c;
    AValue := AValue shr 1;
  end;
  if Result = '' then Result := '0';
  if ADigit > 0 then while ADigit > Length(Result) do Result := '0' + Result;
end;

function OctToDec(AText: string): Integer;
var
  b, n: Integer;
begin
  Result := 0;
  n := Length(AText);
  while n > 0 do
  begin
    b := Ord(AText[n]) - Ord('0');
    Result := (Result shl 3) or b;
    Dec(n);
  end;
end;

function DecToOct(AValue: Integer; ADigit: Integer = 0): string;
var
  c: Char;
begin
  Result := '';
  while AValue > 0 do
  begin
    c := Chr(Ord('0') + (AValue and 7));
    Result := Result + c;
    AValue := AValue shr 3;
  end;
  if Result = '' then Result := '0';
  if ADigit > 0 then while ADigit > Length(Result) do Result := '0' + Result;
end;

function HexToDec(AText: string): Integer;
var
  b, n: Integer;
begin
  Result := 0;
  n := Length(AText);
  while n > 0 do
  begin
    b := Ord(UpCase(AText[n]));
    if b >= Ord('A') then
      b := b - Ord('A') + 10
    else b := b - Ord('0');
    Result := (Result shl 4) or b;
    Dec(n);
  end;
end;

function DecToHex(AValue: Integer; ADigit: Integer = 0): string;
var
  b: Integer;
begin
  Result := '';
  while AValue > 0 do
  begin
    b := AValue and 15;
    if b > 9 then
      b := b + Ord('A') - 10
    else b := b + Ord('0');
    Result := Result + Chr(b);
    AValue := AValue shr 4;
  end;
  if Result = '' then Result := '0';
  if ADigit > 0 then while ADigit > Length(Result) do Result := '0' + Result;
end;

function CharToHex(AChar: Char): string;
begin
  Result := HexChar(Ord(AChar) shr 4) + HexChar(Ord(AChar) and 15);
end;

function CharToHex(AChar: Byte): string;
begin
  Result := HexChar(AChar shr 4) + HexChar(AChar and 15);
end;

function IntToChar(AValue: Int64; HighToLow: Boolean; ACount: Integer): string;
begin
  Result := '';
  while ACount > 0 do
  begin
    if HighToLow then
      Result := Char(AValue and 255) + Result
    else Result := Result + Char(AValue and 255);
    AValue := AValue shr 8;
    Dec(ACount);
  end;
end;

function HexChar(AIndex: Integer): Char;
const
  HexCharStr = '0123456789ABCDEF';
begin
  Result := HexCharStr[AIndex + 1];
end;

function HexToChar(AHex: string): Char;
begin
  Result := Chr(StrToIntDef('$' + Copy(AHex, 2, 1), 0) + StrToIntDef('$' + Copy(AHex, 1, 1), 0) * 16);
end;

function IntToHex(AValue: Integer; ADigit: Integer): string;
begin
  Result := '';
  while ADigit > 0 do
  begin
    Result := HexChar(AValue and 15) + Result;
    AValue := AValue shr 4;
    Dec(ADigit);
  end;
  if Result = '' then
  repeat
    Result := HexChar(AValue and 15) + Result;
    AValue := AValue shr 4;
  until AValue = 0;
end;

function StringToHex(AText: string): string;
begin
  Result := HexEncode(AText, ' ');
end;

function HexToString(AHexText: string): string;
begin
  Result := HexDecode(AHexText, ' ');
end;

function HexEncode(var AVar; ALength: Integer; ASeparator: string): string;
var
  p: PByte;
  n: Integer;
begin
  p := @AVar;
  Result := '';
  for n := 0 to ALength - 1 do
  begin
    if n > 0 then Result := Result + ASeparator;
    Result := Result + CharToHex(p^);
    Inc(p);
  end;
end;

function HexEncode(AVar: array of Byte; ASeparator: string = ''; ANewLine: Integer = 0;
  ALinePrefix: string = ''): string;
begin
  Result := HexEncode(AVar[0], Length(AVar), 1, ASeparator, ANewLine, ALinePrefix);
end;

function HexEncode(AVar: array of Word; ASeparator: string = ''; ANewLine: Integer = 0;
  ALinePrefix: string = ''): string;
begin
  Result := HexEncode(AVar[0], Length(AVar), 2, ASeparator, ANewLine, ALinePrefix);
end;

function HexEncode(AVar: array of Integer; ASeparator: string = ''; ANewLine: Integer = 0;
  ALinePrefix: string = ''): string;
begin
  Result := HexEncode(AVar[0], Length(AVar), 4, ASeparator, ANewLine, ALinePrefix);
end;

function HexEncode(AVar: array of Cardinal; ASeparator: string = ''; ANewLine: Integer = 0;
  ALinePrefix: string = ''): string;
begin
  Result := HexEncode(AVar[0], Length(AVar), 4, ASeparator, ANewLine, ALinePrefix);
end;

function HexEncode(var AVar; ALength, ADataSize: Integer;
  ASeparator: string; ANewLine: Integer; ALinePrefix: string): string;
var
  p: PByte;
  n, nd: Integer;
  s: string;
begin
  p := @AVar;
  Result := '';
  n := 0;
  while n < ALength do
  begin
    if n > 0 then
    begin
      Result := Result + ASeparator;
      if (ANewLine > 0) and ((n mod ANewLine) = 0) then
        Result := Result + #13#10 + ALinePrefix;
    end;
    s := '';
    nd := 0;
    while nd < ADataSize do
    begin
      s := CharToHex(p^) + s;
      Inc(nd);
      Inc(p);
    end;
    Result := Result + s;
    Inc(n);
  end;
end;

function HexEncode(AText: string; ASeparator: string): string;
var
  n: Integer;
begin
  Result := '';
  for n := 1 to Length(AText) do
  begin
    if n > 1 then Result := Result + ASeparator;
    Result := Result + CharToHex(AText[n]);
  end;
end;

function HexDecode(AHexText: string; ASeparator: string): string;
var
  n: Integer;
begin
  n := 1;
  Result := '';
  while n < Length(AHexText) do
  begin
    Result := Result + HexToChar(Copy(AHexText, n, 2));
    Inc(n, 2 + Length(ASeparator));
  end;
end;

function FileExtPos(AFileName, AFilter: string): Integer;
begin
  Result := Pos(UpperCase(ExtractFileExt(AFileName)), UpperCase(AFilter));
end;

function GetTickDiff(AOldTick, ANewTick: Integer): Integer;
begin
  if ANewTick >= AOldTick then
    Result := ANewTick - AOldTick
  else Result := AOldTick - ANewTick;
end;

function GetUserStringDateTime(const UserString: string): TDateTime;
var
  d, m, y, hr, mn, sc, ms: Integer;
  s: string;
begin
  s := UserString;
  if Pos('/', s) <> 0 then
  begin
    d := StrToIntDef(FetchString('/', s), 0);
    m := StrToIntDef(FetchString('/', s), 0);
    y := StrToIntDef(FetchString(' ', s), 0) - 543;
    if y < 0 then y := y + 2500;
  end
  else
  begin
    d := 0;
    m := 0;
    y := 0;
  end;
  hr := StrToIntDef(FetchString(':', s), 0);
  mn := StrToIntDef(FetchString(':', s), 0);
  sc := StrToIntDef(FetchString('.', s), 0);
  ms := StrToIntDef(s, 0);
  Result := EncodeDateTime(y, m, d, hr, mn, sc, ms);
end;

function GetPrintChar(AData: Byte): Char;
begin
  if (AData > 31) and (AData < 127) then
    Result := Chr(AData)
  else Result := Chr(255);
end;

function GetPrintStr(AData: string): string;
var
  n: Integer;
begin
  Result := '';
  for n := 1 to Length(AData) do Result := Result + GetPrintChar(Ord(AData[n]));
end;

function SamePrefixText(AText, APrefix: string): Boolean;
begin
  Result := CompareText(Copy(AText, 1, Length(APrefix)), APrefix) = 0;
end;

function SamePrefixStr(AText, APrefix: string): Boolean;
begin
  Result := CompareStr(Copy(AText, 1, Length(APrefix)), APrefix) = 0;
end;

function SplitText(var AValues: Variant; AText, ASeparator: string): Integer;
var
  p: Integer;
  s: string;
begin
  Result := 1;
  AValues := VarArrayOf(['']);
  repeat
    p := Pos(ASeparator, AText);
    if p > 0 then
    begin
      AValues[Result - 1] := Copy(AText, 1, p - 1);
      Delete(AText, p, Length(ASeparator));
      Inc(Result);
      VarArrayRedim(AValues, Result);
    end;
  until p = 0;
  AValues[Result - 1] := s;
end;

function IndexStr(AStr: string; AArray: array of string): Integer;
var
  n: Integer;
begin
  Result := -1;
  n := Length(AArray);
  while (n > 0) and (Result < 0) do
  begin
    Dec(n);
    if SameStr(AStr, AArray[n]) then Result := n;
  end;
end;

function IndexText(AText: string; AArray: array of string): Integer;
var
  n: Integer;
begin
  Result := -1;
  n := Length(AArray);
  while (n > 0) and (Result < 0) do
  begin
    Dec(n);
    if SameText(AText, AArray[n]) then Result := n;
  end;
end;

function IndexPrefixStr(AStr: string; AArray: array of string): Integer;
var
  n: Integer;
begin
  Result := -1;
  n := 0;
  while (n < Length(AArray)) and (Result < 0) do
  begin
    if SameStr(Copy(AStr, 1, Length(AArray[n])), AArray[n]) then Result := n;
    Inc(n);
  end;
end;

function IndexPrefixText(AText: string; AArray: array of string): Integer;
var
  n: Integer;
begin
  Result := -1;
  n := 0;
  while (n < Length(AArray)) and (Result < 0) do
  begin
    if SameText(Copy(AText, 1, Length(AArray[n])), AArray[n]) then Result := n;
    Inc(n);
  end;
end;

function URLEncode(s: string): string;
var
  n: Integer;
  c: Char;
begin
  Result := '';
  for n := 1 to Length(s) do
  begin
    c := s[n];
    if c = ' ' then
      Result := Result + '+'
    else if (c = '+') or (c = '&') or (c = '%') or (c < ' ') or (c > #126) then
      Result := Result + Format('%%%2.2X', [Ord(c)])
    else Result := Result + c;
  end;
end;

function RepeatString(AText: AnsiString; ACount: Integer): AnsiString;
begin
  Result := '';
  while ACount > 0 do
  begin
    Result := Result + AText;
    Dec(ACount);
  end;
end;

function ReplaceString(AText: AnsiString; AStart, ALength: Integer;
  ASubText: AnsiString): AnsiString;
begin
  Result := Copy(AText, 1, AStart - 1) +
    ASubText +
    Copy(AText, AStart + ALength, Length(AText));
end;

function TextLine(AText: AnsiString; AFillChar: AnsiChar; AWidth: Integer): AnsiString;
begin
  Result := Copy(AText + StringOfChar(AFillChar, AWidth), 1, AWidth);
end;

var
  lg_StartFolder: string;

function BrowseForFolderCallBack(Wnd: HWND; uMsg: UINT; lParam, lpData: LPARAM): Integer stdcall;
begin
  if uMsg = BFFM_INITIALIZED then
  begin
    SendMessage(Wnd, BFFM_SETSELECTION, 1, Integer(@lg_StartFolder[1]));
  end;
  Result := 0;
end;

function BrowseForFolder(var AFolder: string; const BrowseTitle: string): Boolean;
var
  buffer: array[0..MAX_PATH] of Char;
  find_context: PItemIDList;
  browse_info: TBrowseInfo;
begin
  FillChar(browse_info, SizeOf(browse_info), #0);
  lg_StartFolder := AFolder;
  browse_info.pszDisplayName := @buffer[0];
  browse_info.lpszTitle := PChar(BrowseTitle);
  browse_info.ulFlags := BIF_RETURNONLYFSDIRS;
  browse_info.hwndOwner := Application.Handle;
  if AFolder <> '' then
    browse_info.lpfn := BrowseForFolderCallBack;
  find_context := SHBrowseForFolder(browse_info);
  Result := Assigned(find_context);
  if Result then
  begin
    Result := SHGetPathFromIDList(find_context, buffer);
    if Result then AFolder := buffer;
    GlobalFreePtr(find_context);
  end;
end;

function IsDriveReady(const ADrive: string): Boolean;
{ Checks if a local drive is ready. Drive must be a valid local drive (A:\ to Z:\). }
var
  ErrorMode: Word; // current error mode
  DriveNum: Integer; // zero based number of drive
begin
  Result := False;
  // Get zero based drive number
  DriveNum := GetDriveNumber(ADrive);
  if DriveNum = -1 then Exit;
  ErrorMode := Windows.SetErrorMode(Windows.SEM_FAILCRITICALERRORS);
  try
    // DiskSize requires 1 based drive numbers
    // returns -1 for invalid drives
    if SysUtils.DiskSize(DriveNum + 1) <> -1 then
      Result := True;
  finally
    Windows.SetErrorMode(ErrorMode);
  end;
end;

procedure GetDriveLetters(AList: TStrings);
var
  vDrivesSize: Cardinal;
  vDrives: array[0..128] of Char;
  vDrive: PChar;
begin
  AList.BeginUpdate;
  try
    AList.Clear;
    vDrivesSize := GetLogicalDriveStrings(SizeOf(vDrives), vDrives);
    if vDrivesSize > 0 then
    begin
      vDrive := vDrives;
      while vDrive^ <> #0 do
      begin
        AList.Add(StrPas(vDrive));
        Inc(vDrive, SizeOf(vDrive));
      end;
    end;
  finally
  	AList.EndUpdate;
  end;
end;

function GetDriveNumber(const Drive: string): Integer;
var
  DriveLetter: Char;  // drive letter
begin
  Result := -1;
  if Drive <> '' then
  begin
    DriveLetter := UpCase(Drive[1]);
    {$IFDEF UNICODE}
    if SysUtils.CharInSet(DriveLetter, ['A'..'Z']) then
    {$ELSE}
    if DriveLetter in ['A'..'Z'] then
    {$ENDIF}
      Result := Ord(DriveLetter) - Ord('A');
  end;
end;

procedure GetFolderList(AList: TStrings; APath: string; AFolderOnly: Boolean; AFilter: string);
var
  sr: TSearchRec;
  err: Integer;
  ext: string;
begin
  APath := IncludeTrailingPathDelimiter(APath);
  AList.BeginUpdate;
  try
    AList.Clear;
    err := FindFirst(APath + '*.*', faDirectory, sr);
    while err = 0 do
    begin
      if (sr.Attr and faDirectory) <> 0 then
      begin
        if (sr.Name <> '.') and (sr.Name <> '..') then AList.Add('0' + sr.Name)
      end
      else if not AFolderOnly then
      begin
        if AFilter <> '' then
        begin
          ext := UpperCase(ExtractFileExt(sr.Name));
          if Pos(ext, AFilter) > 0 then AList.Add('2' + sr.Name);
        end
        else AList.Add('1' + sr.Name);
      end;
      err := FindNext(sr);
    end;
  finally
    AList.EndUpdate;
  end;
end;

procedure GetFileList(AList: TStrings; AFileSpec: string; ARecursived: Boolean;
  APrefix: string = '');
var
  sr: TSearchRec;
  serr: Integer;
  spath, sspec: string;
begin
  if APrefix <> '' then APrefix := APrefix + '\';
  if ARecursived then
  begin
    spath := IncludeTrailingPathDelimiter(ExtractFilePath(AFileSpec));
    sspec := '\' + ExtractFileName(AFileSpec);
    serr := FindFirst(spath + '*.*', faDirectory, sr);
    while serr = 0 do
    begin
      if (sr.Name <> '.') and (sr.Name <> '..') then
        GetFileList(AList, spath + sr.Name + sspec, ARecursived, APrefix + sr.Name);
      serr := FindNext(sr);
    end;
    FindClose(sr);
  end;
  serr := FindFirst(AFileSpec, 0, sr);
  while serr = 0 do
  begin
    AList.Add(APrefix + sr.Name);
    serr := FindNext(sr);
  end;
  FindClose(sr);
end;

function FindFileExists(AFolder: string; ASpecs: array of string;
  ARecursived: Boolean): Boolean;
var
  sr: TSearchRec;
  serr: Integer;
  n: Integer;
begin
  Result := False;
  AFolder := IncludeTrailingPathDelimiter(AFolder);
  n := Length(ASpecs);
  while (n > 0) and not Result do
  begin
    Dec(n);
    Result := Result or (FindFirst(AFolder + ASpecs[n], 0, sr) = 0);
    FindClose(sr);
  end;
  if not Result and ARecursived then
  begin
    serr := FindFirst(AFolder + '*.*', faDirectory, sr);
    while (serr = 0) and not Result do
    begin
      if (sr.Name <> '.') and (sr.Name <> '..') then
        Result := Result or FindFileExists(AFolder + sr.Name, ASpecs, True);
      serr := FindNext(sr);
    end;
    FindClose(sr);
  end;
end;

procedure CategoryFiles(ASourceFolder, ADestFolder: string; ASpecs: array of string);
var
  sr: TSearchRec;
  err: Integer;
begin
  ASourceFolder := IncludeTrailingPathDelimiter(ASourceFolder);
  ADestFolder := IncludeTrailingPathDelimiter(ADestFolder);
  err := FindFirst(ASourceFolder + '*.*', faDirectory, sr);
  if err = 0 then ForceDirectories(ADestFolder);
  while err = 0 do
  begin
    if (sr.Name <> '.') and (sr.Name <> '..') then
    begin
      if FindFileExists(ASourceFolder + sr.Name, ASpecs, True) then
      begin
        RenameFile(ASourceFolder + sr.Name, ADestFolder + sr.Name);
      end;
    end;
    err := FindNext(sr);
  end;
  FindClose(sr);
end;

procedure Category3DFiles(ASourceFolder, ADestFolder: string);
begin
  ASourceFolder := IncludeTrailingPathDelimiter(ASourceFolder);
  ADestFolder := IncludeTrailingPathDelimiter(ADestFolder);
  CategoryFiles(ASourceFolder, ADestFolder + '@OBJ', ['*.obj']);
  CategoryFiles(ASourceFolder, ADestFolder + '@Blend', ['*.blend']);
  CategoryFiles(ASourceFolder, ADestFolder + '@3DS', ['*.3ds']);
  CategoryFiles(ASourceFolder, ADestFolder + '@DAE', ['*.dae']);
  CategoryFiles(ASourceFolder, ADestFolder + '@FBX', ['*.fbx']);
  CategoryFiles(ASourceFolder, ADestFolder + '@MAX', ['*.max']);
  CategoryFiles(ASourceFolder, ADestFolder + '@C4D', ['*.c4d']);
  CategoryFiles(ASourceFolder, ADestFolder + '@Mesh', ['*.mesh']);
  CategoryFiles(ASourceFolder, ADestFolder + '@RAW', ['*.raw']);
  CategoryFiles(ASourceFolder, ADestFolder + '@MB', ['*.ma', '*.mb']);
end;

function FileCount(var AFileCount, AFolderCount: Integer; AFolder: string): string;
var
  sr: TSearchRec;
  err: Integer;
begin
  Result := '';
  AFileCount := 0;
  AFolderCount := 0;
  AFolder := IncludeTrailingPathDelimiter(AFolder);
  err := FindFirst(AFolder + '*.*', faAnyFile, sr);
  try
    while err = 0 do
    begin
      if (sr.Name <> '.') and (sr.Name <> '..') then
      begin
        if Result = '' then Result := sr.Name;
        if (sr.Attr and faDirectory) = 0 then
          Inc(AFileCount)
        else Inc(AFolderCount);
      end;
      err := FindNext(sr);
    end;
  finally
    FindClose(sr);
  end;
end;

procedure CompactFolder(ASourceFolder, ADestFolder: string);
var
  sr: TSearchRec;
  err: Integer;
  s: string;
  nfile, nfolder: Integer;
begin
  ASourceFolder := IncludeTrailingPathDelimiter(ASourceFolder);
  ADestFolder := IncludeTrailingPathDelimiter(ADestFolder);
  err := FindFirst(ASourceFolder + '*.*', faDirectory, sr);
  try
    while err = 0 do
    begin
      if (sr.Name <> '.') and (sr.Name <> '..') then
      begin
        s := FileCount(nfile, nfolder, ASourceFolder + sr.Name);
        if (nfile = 0) and (nfolder = 1) then
        begin
          if not DirectoryExists(ADestFolder + s) then
          begin
            MoveFile(PChar(ASourceFolder + sr.Name + '\' + s), PChar(ADestFolder + s));
            RmDir(ASourceFolder + sr.Name);
          end
          else if SameText(ASourceFolder, ADestFolder) and SameText(sr.Name, s) then
          begin
            MoveFolder(ASourceFolder + sr.Name + '\' + s, ADestFolder + s);
          end;
        end;
      end;
      err := FindNext(sr);
    end;
  finally
    FindClose(sr);
  end;
end;

procedure MoveFolder(ASourceFolder, ADestFolder: string);
var
  sr: TSearchRec;
  err: Integer;
begin
  ASourceFolder := IncludeTrailingPathDelimiter(ASourceFolder);
  ADestFolder := IncludeTrailingPathDelimiter(ADestFolder);
  err := FindFirst(ASourceFolder + '*.*', faAnyFile, sr);
  try
    while err = 0 do
    begin
      if (sr.Name <> '.') and (sr.Name <> '..') then
      begin
        MoveFile(PChar(ASourceFolder + sr.Name), PChar(ADestFolder + sr.Name));
      end;
      err := FindNext(sr);
    end;
  finally
    FindClose(sr);
  end;
  RmDir(ASourceFolder);
end;

procedure CloneProperties(const Source: TControl; const Dest: TControl);
var
  ms: TMemoryStream;
  OldName: string;
begin
  OldName := Source.Name;
  Source.Name := ''; // needed to avoid Name collision
  try
    ms := TMemoryStream.Create;
    try
      ms.WriteComponent(Source);
      ms.Position := 0;
      ms.ReadComponent(Dest);
    finally
      ms.Free;
    end;
  finally
    Source.Name := OldName;
  end;
end;

function ReplaceControlEx(AControl: TControl; const AControlClass: TControlClass;
  const ANewName: string; const IsFreed : Boolean = True): TControl;
begin
  Result := nil;
  if AControl <> nil then
  begin
    Result := AControlClass.Create(AControl.Owner);
    CloneProperties(AControl, Result);// copy all properties to new control
    // Result.Left := AControl.Left;   // or copy some properties manually...
    // Result.Top := AControl.Top;
    Result.Name := ANewName;
    Result.Parent := AControl.Parent; // needed for the InsertControl & RemoveControl magic
    if IsFreed then
    begin
      AControl.Parent := nil;
      FreeAndNil(AControl);
    end;
  end;
end;

function ReplaceControl(AControl: TControl; const ANewName: string;
  const IsFreed : Boolean = True): TControl;
begin
  Result := nil;
  if AControl <> nil then
  begin
    Result := ReplaceControlEx(AControl, TControlClass(AControl.ClassType),
      ANewName, IsFreed);
  end;
end;

procedure CopyControl(ASource, ADest: TControl);
begin
  with ADest do
  begin
    Width := ASource.Width;
    Height := ASource.Height;
    Left := ASource.Left;
    Top := ASource.Top;
    Hint := ASource.Hint;
    HelpKeyword := ASource.HelpKeyWord;
    Anchors := ASource.Anchors;
    Enabled := ASource.Enabled;
    Parent := ASource.Parent;
  end;
end;

procedure SetTextBufDirect(AEdit: TEdit; ABuffer: PChar);
begin
  AEdit.Perform(WM_SETTEXT, 0, Longint(ABuffer));
end;

procedure SetTextDirect(AEdit: TEdit; NewText: string);
begin
  if AEdit.Text <> NewText then SetTextBufDirect(AEdit, PChar(NewText));
end;

procedure PlayMedia(AWin: TWinControl; AFileName: string; Repeated: Boolean);
var
  smci: string;
begin
  mciSendString('close alias1', nil, 0, 0);
  mciSendString(PChar('open "' + AFileName + '" alias alias1'), nil, 0, 0);
  if AWin <> nil then
  begin
    smci := Format('%d %d %d %d', [AWin.Left, AWin.Top, AWin.Width, AWin.Height]);
    mciSendString(PChar('window alias1 handle ' + IntToStr(AWin.Handle)), nil, 0, 0);
    mciSendString(PChar('put alias1 ' + smci), nil, 0, 0);
  end;
  smci := 'play alias1';
  if Repeated then smci := smci + ' repeat';
  mciSendString(PChar(smci), nil, 0, 0);
end;

procedure CloseMedia;
begin
  mciSendString('close alias1', nil, 0, 0);
end;

{ TStreamHelperXP }

function TStreamHelperXP.NextTextSection(var ASection: string): Boolean;
begin
  repeat
    Result := Readln(ASection);
    ASection := Trim(ASection);
  until not Result or (Copy(ASection, 1, 1) = '[');
end;

function TStreamHelperXP.ReadChar(var AChar: Char): Integer;
var
  c: AnsiChar;
begin
  Result := Read(c, 1);
  if Result > 0 then AChar := Char(c);
end;

function TStreamHelperXP.Readln(var AText: string): Boolean;
var
  n: Integer;
  c: AnsiChar;
begin
  AText := '';
  n := Read(c, 1);
  Result := n > 0;
  if Result then
  while (c <> #10) and (n > 0) do
  begin
    if c <> #13 then AText := AText + Char(c);
    n := Read(c, 1);
  end;
end;

function TStreamHelperXP.ReadString(AMaxLength: Integer): string;
var
  n: Integer;
  s: AnsiString;
begin
  if AMaxLength = 0 then AMaxLength := Size - Position;
  SetLength(s, AMaxLength);
  n := Read(s[1], AMaxLength);
  SetLength(s, n);
  Result := string(s);
end;

function TStreamHelperXP.SeekTextSection(ASection: string): Boolean;
var
  sline: string;
begin
  Seek(0, soFromBeginning);
  ASection := '[' + UpperCase(ASection) + ']';
  repeat
    Result := Readln(sline);
    sline := UpperCase(Trim(sline));
  until not Result or (sline = ASection);
end;

function TStreamHelperXP.WriteChar(AChar: Char): Integer;
var
  c: AnsiChar;
begin
  c := AnsiChar(AChar);
  Result := Write(c, 1);
end;

function TStreamHelperXP.Writeln(AText: string): Integer;
begin
  Result := WriteString(AText + #13#10);
end;

function TStreamHelperXP.WriteString(AText: string): Integer;
var
  s: AnsiString;
begin
  s := AnsiString(AText);
  Result := Write(s[1], Length(s));
end;

{ TStringGridHelperXP }

procedure TStringGridHelperXP.InsertRow(ARow: Integer; ATexts: array of string);
var
  n: Integer;
begin
  n := RowCount;
  RowCount := n + 1;
  while n > ARow do
  begin
    Rows[n] := Rows[n - 1];
    Dec(n);
  end;
  for n := 0 to Min(ColCount - 1, Length(ATexts) - 1) do
  begin
    Cells[n, ARow] := ATexts[n];
  end;
end;

{ TPNGImageHelper }

procedure TPNGImageHelper.LoadFromResourceType(AResourceName,
  AResourceType: string);
var
  rs: TResourceStream;
begin
  rs := TResourceStream.Create(HInstance, AResourceName, PChar(AResourceType));
  try
    LoadFromStream(rs);
  finally
    rs.Free;
  end;
end;

{ TWordEntry }

procedure TWordEntry.ReverseOrder;
var
  b: Byte;
begin
  b := Bytes[0];
  Bytes[0] := Bytes[1];
  Bytes[1] := b;
end;

{ TCardinalEntry }

procedure TCardinalEntry.ReverseOrder;
var
  b: Byte;
begin
  b := Bytes[0];
  Bytes[0] := Bytes[3];
  Bytes[3] := b;
  b := Bytes[1];
  Bytes[1] := Bytes[2];
  Bytes[2] := b;
end;

procedure TCardinalEntry.ReverseWord;
var
  w: Word;
begin
  w := Words[0];
  Words[0] := Words[1];
  Words[1] := w;
end;

{ TInt64Entry }

procedure TInt64Entry.ReverseCardinal;
var
  d: Cardinal;
begin
  d := Cardinals[0];
  Cardinals[0] := Cardinals[1];
  Cardinals[1] := d;
end;

procedure TInt64Entry.ReverseOrder;
var
  n: Integer;
  b: Byte;
begin
  for n := 0 to 3 do
  begin
    b := Bytes[n];
    Bytes[n] := Bytes[7 - n];
    Bytes[7 - n] := b;
  end;
end;

procedure TInt64Entry.ReverseWord;
var
  n: Integer;
  w: Word;
begin
  for n := 0 to 1 do
  begin
    w := Words[n];
    Words[n] := Words[3 - n];
    Words[3 - n] := w;
  end;
end;

{ TUInt24 }

function TUInt24.GetValue: Integer;
begin
  Result := Datas[0] or (Datas[1] shl 8) or (Datas[2] shl 16);
end;

procedure TUInt24.SetValue(AValue: Integer);
begin
  Datas[0] := AValue and 255;
  Datas[1] := (AValue shr 8) and 255;
  Datas[2] := (AValue shr 16) and 255;
end;

{ TPalFileHeader }

procedure TPalFileHeader.Initialize(APalCount: Word);
begin
  Signature := 'RIFF';
  PalSignature := 'PAL ';
  Length := SizeOf(TPalFileHeader) - 4 + SizeOf(TPalFileChunk)
    + SizeOf(TPalFileEntry) * APalCount;
end;

{ TPalFileChunk }

procedure TPalFileChunk.Initialize(APalCount: Word);
begin
  Signature := 'data';
  Version := $300;
  PalCount := APalCount;
  Length := SizeOf(TPalFileChunk) - 4 + SizeOf(TPalFileEntry) * APalCount;
end;

{ TPalFileEntry }

procedure TPalFileEntry.Initialize(R, G, B, Flags: Byte);
begin
  Red := R;
  Green := G;
  Blue := B;
  Self.Flags := Flags;
end;

{ TCMYKEntry }

function TCMYKEntry.Color32: TColor32;
begin
  Result := Color32OfByte(R, G, B, 255);
end;

function TCMYKEntry.B: Byte;
begin
  Result := (255 - Y) * (255 - K) div 255;
end;

function TCMYKEntry.Color: TColor;
begin
  Result := ColorOfByte(R, G, B);
end;

function TCMYKEntry.G: Byte;
begin
  Result := (255 - M) * (255 - K) div 255;
end;

function TCMYKEntry.R: Byte;
begin
  Result := (255 - C) * (255 - K) div 255;
end;

{ TRGBAColorEntry }

function TRGBAColorEntry.Color: TColor;
begin
  Result := ColorOfByte(R, G, B);
end;

function TRGBAColorEntry.Color32: TColor32;
begin
  Result := Color32OfByte(R, G, B, A);
end;

{ TColorEntry }

function TColorEntry.Difference(AColorEntry: TColorEntry): Integer;
begin
  Result := Abs(R - AColorEntry.R) + Abs(G - AColorEntry.G) + Abs(B - AColorEntry.B);
end;

class operator TColorEntry.Equal(A, B: TColorEntry): Boolean;
begin
  Result := A.Color = B.Color;
end;

function TColorEntry.GetColor: TColor;
begin
  Result := RGBN;
end;

function TColorEntry.GetColor32: TColor32;
begin
  Result.R := R;
  Result.G := G;
  Result.B := B;
  Result.A := 255;
end;

function TColorEntry.GetGrayScale: Byte;
begin
  Result := GrayScaleOfRGB(R, G, B);
end;

function TColorEntry.GetHTML: string;
begin
  Result := Color32OfColor(RGBN).GetHTML;
end;

function TColorEntry.OppositeBW: TColor;
begin
  if GetGrayScale > 140 then
    Result := clBlack
  else Result := clWhite;
end;

procedure TColorEntry.SetColor(const AValue: TColor);
begin
  RGBN := AValue;
end;

procedure TColorEntry.SetColor32(const AValue: TColor32);
begin
  R := AValue.R;
  G := AValue.G;
  B := AValue.B;
  N := 0;
end;

procedure TColorEntry.SetGrayScale(const Value: Byte);
begin
  R := Value;
  G := Value;
  B := Value;
  N := 0;
end;

{ TColor15 }

function TColor15.GetA: Byte;
begin
  Result := Value shr 15;
end;

function TColor15.GetB: Byte;
begin
  Result := Value and $1F;
end;

function TColor15.GetColor32: TColor32;
begin
  Result.R := R * 255 div 31;
  Result.G := G * 255 div 31;
  Result.B := B * 255 div 31;
  Result.A := 0;
end;

function TColor15.GetColor32A: TColor32;
begin
  Result.R := R * 255 div 31;
  Result.G := G * 255 div 31;
  Result.B := B * 255 div 31;
  Result.A := A * 255;
end;

function TColor15.GetG: Byte;
begin
  Result := (Value shr 10) and $1F;
end;

function TColor15.GetR: Byte;
begin
  Result := (Value shr 5) and $1F;
end;

procedure TColor15.SetA(AValue: Byte);
begin
  Value := (Value and $7FFF) or ((AValue and 1) shl 15);
end;

procedure TColor15.SetB(AValue: Byte);
begin
  Value := (Value and $FFE0) or (AValue and $1F);
end;

procedure TColor15.SetColor32(AValue: TColor32);
begin
  R := AValue.R * 31 div 255;
  G := AValue.G * 31 div 255;
  B := AValue.B * 31 div 255;
  A := 0;
end;

procedure TColor15.SetColor32A(AValue: TColor32);
begin
  R := AValue.R * 31 div 255;
  G := AValue.G * 31 div 255;
  B := AValue.B * 31 div 255;
  A := AValue.A div 255;
end;

procedure TColor15.SetG(AValue: Byte);
begin
  Value := (Value and $83FF) or ((AValue and $1F) shl 10);
end;

procedure TColor15.SetR(AValue: Byte);
begin
  Value := (Value and $FC1F) or ((AValue and $1F) shl 5);
end;

{ TColor16 }

function TColor16.GetB: Byte;
begin
  Result := Value and $1F;
end;

function TColor16.GetColor32: TColor32;
begin
  Result.R := R * 255 div 31;
  Result.G := G * 255 div 31;
  Result.B := B * 255 div 31;
  Result.A := 0;
end;

function TColor16.GetG: Byte;
begin
  Result := (Value shr 10) and $1F;
end;

function TColor16.GetR: Byte;
begin
  Result := (Value shr 5) and $1F;
end;

procedure TColor16.SetB(AValue: Byte);
begin
  Value := (Value and $FFE0) or (AValue and $1F);
end;

procedure TColor16.SetColor32(AValue: TColor32);
begin
  R := AValue.R * 31 div 255;
  G := AValue.G * 31 div 255;
  B := AValue.B * 31 div 255;
end;

procedure TColor16.SetG(AValue: Byte);
begin
  Value := (Value and $83FF) or ((AValue and $1F) shl 10);
end;

procedure TColor16.SetR(AValue: Byte);
begin
  Value := (Value and $FC1F) or ((AValue and $1F) shl 5);
end;

{ TGRB332Color }

class function TGRB332Color.Create(R, G, B: Byte): TGRB332Color;
begin
  Result.R := R;
  Result.G := G;
  Result.B := B;
end;

class function TGRB332Color.Create(AColor16: TColor16): TGRB332Color;
begin
  Result.R := AColor16.R shr 2;
  Result.G := AColor16.G shr 2;
  Result.B := AColor16.B shr 2;
end;

class function TGRB332Color.Create(AColor32: TColor32): TGRB332Color;
begin
  Result.R := AColor32.R shr 5;
  Result.G := AColor32.G shr 5;
  Result.B := AColor32.B shr 5;
end;

function TGRB332Color.GetB: Byte;
begin
  Result := ((Value and 3) shl 1) or ((Value shr 1) and 1);
end;

function TGRB332Color.GetColor32: TColor32;
begin
  Result.R := (R shl 5) or (R shl 2) or (R shr 2);
  Result.G := (G shl 5) or (G shl 2) or (G shr 2);
  Result.B := (B shl 5) or (B shl 2) or (B shr 2);
  Result.A := 255;
end;

function TGRB332Color.GetG: Byte;
begin
  Result := Value shr 5;
end;

function TGRB332Color.GetR: Byte;
begin
  Result := (Value shr 2) and 7;
end;

procedure TGRB332Color.SetB(AValue: Byte);
begin
  Value := (Value and $FC) or ((AValue and 7) shr 1);
end;

procedure TGRB332Color.SetColor32(AValue: TColor32);
begin
  R := AValue.R shr 5;
  G := AValue.G shr 5;
  B := AValue.B shr 5;
end;

procedure TGRB332Color.SetG(AValue: Byte);
begin
  Value := (Value and $1F) or ((AValue and 7) shl 5);
end;

procedure TGRB332Color.SetR(AValue: Byte);
begin
  Value := (Value and $E3) or ((AValue and 7) shl 2);
end;

{ TColor32 }

class function TColor32.Create(R, G, B, A: Byte): TColor32;
begin
  Result.SetRGBA(R, G, B, A);
end;

class function TColor32.Create(AValue: Cardinal): TColor32;
begin
  Result.Value := AValue;
end;

class operator TColor32.Equal(C1, C2: TColor32): Boolean;
begin
  Result := C1.BGRA = C2.BGRA;
end;

function TColor32.GetColor: TColor;
begin
  with TColorEntry(Result) do
  begin
    N := 0;
    R := Self.R;
    G := Self.G;
    B := Self.B;
  end;
end;

function TColor32.GetGrayScale: Byte;
begin
  Result := GrayScaleOfRGB(R, G, B);
end;

function TColor32.GetHTML: string;
begin
  Result := Format('#%8.8X', [Self.BGRA]);
end;

class operator TColor32.NotEqual(C1, C2: TColor32): Boolean;
begin
  Result := C1.BGRA <> C2.BGRA;
end;

procedure TColor32.SetGrayScale(AValue: Byte; AAlpha: Byte);
begin
  R := AValue;
  G := AValue;
  B := AValue;
  A := AAlpha;
end;

procedure TColor32.SetGrayScale(AValue: Byte);
begin
  R := AValue;
  G := AValue;
  B := AValue;
  A := 255;
end;

procedure TColor32.SetRGBA(R, G, B, A: Byte);
begin
  Self.R := R;
  Self.G := G;
  Self.B := B;
  Self.A := A;
end;

function TColor32.ChangeAlpha(AAlpha: Byte): TColor32;
begin
  Result := Self;
  Result.A := AAlpha;
end;

{ TYJKColor }

function TYJKColor.GetColor32(AIndex: Integer): TColor32;
var
  ny, nj, nk: Integer;
begin
  ny := GetY(AIndex);
  nj := GetJ;
  nk := GetK;
  Result.R := IntInside(ny + nj, 0, 31);
  Result.G := IntInside(ny + nk, 0, 31);
  Result.B := IntInside(ny * 5 div 4 - nj div 2 - nk div 4, 0, 31);
  Result.R := (Result.R shl 3) or (Result.R shr 2);
  Result.G := (Result.G shl 3) or (Result.G shr 2);
  Result.B := (Result.B shl 3) or (Result.B shr 2);
  Result.A := 255;
end;

function TYJKColor.GetJ: Integer;
begin
  Result := (Planes[2] and 7) or ((Planes[3] and 7) shl 3);
  if Result > 31 then Result := Result - 64;
end;

function TYJKColor.GetK: Integer;
begin
  Result := (Planes[0] and 7) or ((Planes[1] and 7) shl 3);
  if Result > 31 then Result := Result - 64;
end;

function TYJKColor.GetY(AIndex: Integer): Integer;
begin
  Result := Planes[AIndex] shr 3;
end;

procedure TYJKColor.SetColor32(AIndex: Integer; AValue: TColor32);
var
  ny: Integer;
begin
  AValue.R := AValue.R shr 3;
  AValue.G := AValue.G shr 3;
  AValue.B := AValue.B shr 3;
  ny := (AValue.B shr 1) + (AValue.R shr 2) + (AValue.G shr 3);
  Y[AIndex] := ny;
  J := AValue.R - ny;
  K := AValue.G - ny;
end;

procedure TYJKColor.SetJ(AValue: Integer);
begin
  if AValue < 0 then AValue := AValue + 64;
  Planes[2] := (Planes[2] and $F8) or (AValue and 7);
  Planes[3] := (Planes[3] and $F8) or ((AValue shr 3) and 7);
end;

procedure TYJKColor.SetK(AValue: Integer);
begin
  if AValue < 0 then AValue := AValue + 64;
  Planes[0] := (Planes[0] and $F8) or (AValue and 7);
  Planes[1] := (Planes[1] and $F8) or ((AValue shr 3) and 7);
end;

procedure TYJKColor.SetY(AIndex, AValue: Integer);
begin
  Planes[AIndex] := (Planes[AIndex] and 7) or ((AValue and 31) shl 3);
end;

procedure TYJKColor.SetYJK(Y0, Y1, Y2, Y3, J, K: Integer);
begin
  Self.Y[0] := Y0;
  Self.Y[1] := Y1;
  Self.Y[2] := Y2;
  Self.Y[3] := Y3;
  Self.J := J;
  Self.K := K;
end;

{ TYJKAColor }

function TYJKAColor.GetA(AIndex: Integer): Integer;
begin
  Result := (Planes[AIndex] shr 3) and 1;
end;

function TYJKAColor.GetColor32(AIndex: Integer): TColor32;
var
  ny, nj, nk: Integer;
begin
  ny := GetY(AIndex);
  nj := GetJ;
  nk := GetK;
  Result.R := IntInside(ny + nj, 0, 31);
  Result.G := IntInside(ny + nk, 0, 31);
  Result.B := IntInside(ny * 5 div 4 - nj div 2 - nk div 4, 0, 31);
  Result.R := (Result.R shl 3) or (Result.R shr 2);
  Result.G := (Result.G shl 3) or (Result.G shr 2);
  Result.B := (Result.B shl 3) or (Result.B shr 2);
  Result.A := 255;
end;

function TYJKAColor.GetColor4(AIndex: Integer): Byte;
begin
  Result := Planes[AIndex] shr 4;
end;

function TYJKAColor.GetJ: Integer;
begin
  Result := (Planes[2] and 7) or ((Planes[3] and 7) shl 3);
  if Result > 31 then Result := Result - 64;
end;

function TYJKAColor.GetK: Integer;
begin
  Result := (Planes[0] and 7) or ((Planes[1] and 7) shl 3);
  if Result > 31 then Result := Result - 64;
end;

function TYJKAColor.GetY(AIndex: Integer): Integer;
begin
  Result := (Planes[AIndex] shr 3) and $1E;
end;

procedure TYJKAColor.SetA(AIndex, AValue: Integer);
begin
  Planes[AIndex] := (Planes[AIndex] and $F7) or ((AValue and 1) shl 3);
end;

procedure TYJKAColor.SetColor32(AIndex: Integer; AValue: TColor32);
var
  ny: Integer;
begin
  AValue.R := AValue.R shr 3;
  AValue.G := AValue.G shr 3;
  AValue.B := AValue.B shr 3;
  ny := (AValue.B shr 1) + (AValue.R shr 2) + (AValue.G shr 3);
  Y[AIndex] := ny;
  J := AValue.R - ny;
  K := AValue.G - ny;
end;

procedure TYJKAColor.SetColor4(AIndex: Integer; AValue: Byte);
begin
  Planes[AIndex] := (Planes[AIndex] and 15) or ((AValue and 15) shl 4) or 8;
end;

procedure TYJKAColor.SetJ(AValue: Integer);
begin
  if AValue < 0 then AValue := AValue + 64;
  Planes[2] := (Planes[2] and $F8) or (AValue and 7);
  Planes[3] := (Planes[3] and $F8) or ((AValue shr 3) and 7);
end;

procedure TYJKAColor.SetK(AValue: Integer);
begin
  if AValue < 0 then AValue := AValue + 64;
  Planes[0] := (Planes[0] and $F8) or (AValue and 7);
  Planes[1] := (Planes[1] and $F8) or ((AValue shr 3) and 7);
end;

procedure TYJKAColor.SetPlanes(var Planes);
begin
  Value := PCardinal(@Planes)^;
end;

procedure TYJKAColor.SetPlanes(P0, P1, P2, P3: Byte);
begin
  Planes[0] := P0;
  Planes[1] := P1;
  Planes[2] := P2;
  Planes[3] := P3;
end;

procedure TYJKAColor.SetY(AIndex, AValue: Integer);
begin
  Planes[AIndex] := (Planes[AIndex] and 7) or ((AValue and $1E) shl 3);
end;

procedure TYJKAColor.SetYJK(Y0, Y1, Y2, Y3, J, K: Integer);
begin
  Self.Y[0] := Y0;
  Self.Y[1] := Y1;
  Self.Y[2] := Y2;
  Self.Y[3] := Y3;
  Self.J := J;
  Self.K := K;
end;

{ TYUVColor }

function TYUVColor.GetColor32(AIndex: Integer): TColor32;
var
  ny, nu, nv: Integer;
begin
  ny := GetY(AIndex);
  nu := GetU;
  nv := GetV;
  Result.R := IntInside(ny + nu, 0, 31);
  Result.B := IntInside(ny + nv, 0, 31);
  Result.G := IntInside(ny * 5 div 4 - nu div 2 - nv div 4, 0, 31);
  Result.R := (Result.R shl 3) or (Result.R shr 2);
  Result.G := (Result.G shl 3) or (Result.G shr 2);
  Result.B := (Result.B shl 3) or (Result.B shr 2);
  Result.A := 255;
end;

function TYUVColor.GetU: Integer;
begin
  Result := (Planes[2] and 7) or ((Planes[3] and 7) shl 3);
  if Result > 31 then Result := Result - 64;
end;

function TYUVColor.GetV: Integer;
begin
  Result := (Planes[0] and 7) or ((Planes[1] and 7) shl 3);
  if Result > 31 then Result := Result - 64;
end;

function TYUVColor.GetY(AIndex: Integer): Integer;
begin
  Result := Planes[AIndex] shr 3;
end;

procedure TYUVColor.SetColor32(AIndex: Integer; AValue: TColor32);
var
  ny: Integer;
begin
  AValue.R := AValue.R shr 3;
  AValue.G := AValue.G shr 3;
  AValue.B := AValue.B shr 3;
  ny := (AValue.G shr 1) + (AValue.R shr 2) + (AValue.B shr 3);
  Y[AIndex] := ny;
  U := AValue.R - ny;
  V := AValue.B - ny;
end;

procedure TYUVColor.SetU(AValue: Integer);
begin
  if AValue < 0 then AValue := AValue + 64;
  Planes[2] := (Planes[2] and $F8) or (AValue and 7);
  Planes[3] := (Planes[3] and $F8) or ((AValue shr 3) and 7);
end;

procedure TYUVColor.SetV(AValue: Integer);
begin
  if AValue < 0 then AValue := AValue + 64;
  Planes[0] := (Planes[0] and $F8) or (AValue and 7);
  Planes[1] := (Planes[1] and $F8) or ((AValue shr 3) and 7);
end;

procedure TYUVColor.SetY(AIndex, AValue: Integer);
begin
  Planes[AIndex] := (Planes[AIndex] and 7) or ((AValue and 31) shl 3);
end;

procedure TYUVColor.SetYUV(Y0, Y1, Y2, Y3, U, V: Integer);
begin
  Self.Y[0] := Y0;
  Self.Y[1] := Y0;
  Self.Y[2] := Y0;
  Self.Y[3] := Y0;
  Self.U := U;
  Self.V := V;
end;

{ TRGBColorEntry }

function TRGBColorEntry.GetColor32: TColor32;
begin
  Result.SetRGBA(R, G, B, 255);
end;

procedure TRGBColorEntry.SetColor32(AValue: TColor32);
begin
  R := AValue.R;
  G := AValue.G;
  B := AValue.B;
end;

procedure TRGBColorEntry.SetRGB(R, G, B: Byte);
begin
  Self.R := R;
  Self.G := G;
  Self.B := B;
end;

{ TBGRColorEntry }

function TBGRColorEntry.GetColor32: TColor32;
begin
  Result.SetRGBA(R, G, B, 255);
end;

procedure TBGRColorEntry.SetColor32(AValue: TColor32);
begin
  SetRGB(AValue.R, AValue.G, AValue.B);
end;

procedure TBGRColorEntry.SetRGB(R, G, B: Byte);
begin
  Self.R := R;
  Self.G := G;
  Self.B := B;
end;

{ TFloatRect }

function TFloatRect.GetHeight: Double;
begin
  Result := Bottom - Top;
end;

function TFloatRect.GetWidth: Double;
begin
  Result := Right - Left;
end;

procedure TFloatRect.SetBounds(ALeft, ATop, AWidth, AHeight: Double);
begin
  Left := ALeft;
  Top := ATop;
  Right := Left + AWidth;
  Bottom := Top + AHeight;
end;

procedure TFloatRect.SetHeight(const Value: Double);
begin
  Bottom := Top + Value;
end;

procedure TFloatRect.SetRect(ALeft, ATop, ARight, ABottom: Double);
begin
  Left := ALeft;
  Top := ATop;
  Right := ARight;
  Bottom := ABottom;
end;

procedure TFloatRect.SetWidth(const Value: Double);
begin
  Right := Left + Value;
end;

{ TMarginRect }

procedure TMarginRect.SetMargin(ALeft, ATop, ARight, ABottom: Double);
begin
  Left := ALeft;
  Top := ATop;
  Right := ARight;
  Bottom := ABottom;
end;

end.
