unit MSXPicture;

interface

uses
  {$IFDEF Win32} XPEngine32, {$ELSE} XPEngine64, {$ENDIF}
  XPRoutine, XPBitmap, MSXDisk,
  Windows, Classes, Vcl.Graphics, SysUtils, Math, Types;

type
  TMSXPictureExt = record
    Mode: Integer;
    Ext, IExt: string;
  end;
  TScreen8Color = packed record
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
    class function Create(R, G, B: Byte): TScreen8Color; overload; static;
    class function Create(AColor16: TColor16): TScreen8Color; overload; static;
    class function Create(AColor32: TColor32): TScreen8Color; overload; static;
    procedure SetRGB(R, G, B: Byte);
    property R: Byte read GetR write SetR;
    property G: Byte read GetG write SetG;
    property B: Byte read GetB write SetB;
    property Color32: TColor32 read GetColor32 write SetColor32;
  end;
  TMSXPaletteEntry = packed record
  private
    function GetR: Byte;
    function GetG: Byte;
    function GetB: Byte;
    function GetX: Byte;
    function GetColor: TColor;
    function GetColor32: TColor32;
    procedure SetR(AValue: Byte);
    procedure SetG(AValue: Byte);
    procedure SetB(AValue: Byte);
    procedure SetX(AValue: Byte);
    procedure SetColor(AValue: TColor);
    procedure SetColor32(AValue: TColor32);
  public
    property R: Byte read GetR write SetR;
    property G: Byte read GetG write SetG;
    property B: Byte read GetB write SetB;
    property X: Byte read GetX write SetX;
    property Color: TColor read GetColor write SetColor;
    property Color32: TColor32 read GetColor32 write SetColor32;
    case Integer of
      0: (RB, XG: Byte);
      1: (XRGB: Word);
  end;
  PMSXPalette = ^TMSXPalette;
  TMSXPalette = array[0..15] of TMSXPaletteEntry;
  TMSXPaletteArray = array[0..32767] of TMSXPalette;
  TMSXArrayOfPalette = array of TMSXPalette;
  TMSXPalettes = class
  private
    FPalettes: TMSXArrayOfPalette;
    function GetCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Assign(APalettes: TMSXPalettes);
    procedure Add(APalette: TMSXPalette);
    function LoadFromFile(AFileName: string): Boolean;
    function LoadFromDisk(ADisk: TMSXDisk; AFileName: string): Boolean;
    function LoadFromStream(AStream: TStream): Boolean;
    function BLoadFromFile(AFileName: string): Boolean;
    function BLoadFromDisk(ADisk: TMSXDisk; AFileName: string): Boolean;
    function BLoadFromStream(AStream: TStream): Boolean;
    property Palettes: TMSXArrayOfPalette read FPalettes;
    property Count: Integer read GetCount;
  end;
  TMSXSpriteAttr = packed record
  private
    function GetColor: Byte;
    function GetEC: Boolean;
    procedure SetColor(const AValue: Byte);
    procedure SetEC(const AValue: Boolean);
  public
    Y, X, ID, Attr: Byte;
    property Color: Byte read GetColor write SetColor;
    property EC: Boolean read GetEC write SetEC;
  end;
  PMSXSpriteAttrTable = ^TMSXSpriteAttrTable;
  TMSXSpriteAttrTable = array[0..31] of TMSXSpriteAttr;
  TMSXBinaryHeader = packed record
    ID: Byte; // $FE
    StartAddress: Word;
    EndAddress: Word;
    RunAddress: Word;
  end;
  TMSXScanLines = record
    NameTable, PatternTable, ColorTable: PByteArray;
  end;

  TLT2Lookup = packed record
    Offset, Length: Word;
  end;
  TLT2Chunk = packed record
    Frames: array[0..2] of TLT2Lookup; // Frame 0 is non-copies during image shown
  end;
  TLT2Header = packed record
    PatternDatas: array[0..2] of TLT2Chunk; // Part 0, 1, 2
    ColorDatas: array[0..2] of TLT2Chunk; // Part 0, 1, 2
    NameOffsets: array[1..2] of Word; // Name table for frame 1 and 2 on the fly
  end;

  TMSXPicture = class(TXPGraphic)
  private
    FVRAM: TArrayOfByte;
    FPalette: TMSXPalette;
    FPalettes: TMSXPalettes;
    FFileName, FInterlaceName, FPaletteName: string;
    FScreenMode, FColorBits, FMaskBits, FPaletteIndex, FTextColor, FBGColor: Integer;
    FPaletteAddress, FPageAddress, FPageSize, FNameAddress, FPatternAddress, FColorAddress: Integer;
    FSpriteAttrAddress, FSpritePatternAddress, FSpriteColorAddress: Integer;
    FBinaryHeader: TMSXBinaryHeader;
    FPage: Byte;
    FInterlace: Boolean;
    FScanLine: Pointer;
    FMSXScanLines: TMSXScanLines;
    FLastLine, FMSXLastLine, FBytesPerRow: Integer;

    class procedure MakeScreen8Palette;
    function GetScanLine(PY: Integer): Pointer;
    function GetScanLines(PY: Integer): TMSXScanLines;
    procedure ChangedMode;
    procedure ChangedInterlace;
    procedure ChangedPage;
    procedure SetScreenMode(AMode: Integer);
    procedure SetPage(APage: Byte);
    procedure SetInterlace(AValue: Boolean);
    function GetColorAddress: Integer;
    function GetNameAddress: Integer;
    function GetPatternAddress: Integer;
    function GetPaletteTable: PMSXPalette;
    function GetPaletteExts: string; overload;
    function GetPaletteExts(AMode: Integer): string; overload;
    function CreateReadStream(AFileName: string; ADisk: TMSXDisk): TStream;
    function CreateWriteStream(AFileName: string; ADisk: TMSXDisk): TStream;
  protected
    function Draw(ABitmap: TXPBitmap; PX, PY: Integer): Boolean; overload; override;
    function Draw(ABitmap: TXPBitmap; PX, PY: Integer; AMode: TXPDrawMode): Boolean; overload; override;
    function Draw(ABitmap: TXPBitmap; ARect: TRect): Boolean; overload; override;
    function Draw(ABitmap: TXPBitmap; ARect: TRect; AMode: TXPDrawMode): Boolean; overload; override;
    procedure SetPaletteIndex(AIndex: Integer);
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Assign(APicture: TMSXPicture); reintroduce;
    function GetPageAddress(APage: Byte): Integer;
    procedure BloadRLE(AStream: TStream; ABuf: PByte ; ACount: Integer);

    function BloadFromStream(AStream: TStream): Boolean;
    function BloadFromFile(AFileName: string; ADisk: TMSXDisk = nil): Boolean;

    procedure BsaveToStream(AStream: TStream; APage: Integer = -1); overload;
    procedure BsaveToStream(AStream: TStream; AStartAddress, AEndAddress,
      ARunAddress: Word; APage: Integer = -1); overload;

    procedure BsaveToFile(AFileName: string; APage: Integer = -1); overload;
    procedure BsaveToFile(AFileName: string; AStartAddress, AEndAddress,
      ARunAddress: Word; APage: Integer = -1); overload;

    function CopyFromStream(AStream: TStream; IsFullScreen: Boolean = False): Boolean;
    function CopyFromFile(AFileName: string; IsFullScreen: Boolean = False): Boolean; overload;
    function CopyFromFile(AFileName: string; ADisk: TMSXDisk; IsFullScreen: Boolean = False): Boolean; overload;

    function CopyToStream(AStream: TStream; ARect: TRect; APage: Integer = 0): Boolean;
    function CopyToFile(AFileName: string; ARect: TRect; APage: Integer = 0): Boolean; overload;
    function CopyToFile(AFileName: string; ADisk: TMSXDisk; ARect: TRect; APage: Integer = 0): Boolean; overload;

    function FillFromFile(AFileName: string; ADisk: TMSXDisk = nil): Boolean;
    function FillFromStream(AStream: TStream): Integer;

    function LoadFromLT2(AStream: TStream): Boolean;

    procedure LoadFromStream(AStream: TStream; AFileName: string); reintroduce; overload;
    procedure LoadFromStream(AStream: TStream; AFileName: string; IsFullScreen: Boolean); reintroduce; overload;

    procedure LoadFromFile(AFileName: string); overload; override;
    procedure LoadFromFile(AFileName: string; IsFullScreen: Boolean); reintroduce; overload;
    procedure LoadFromFile(AFileName: string; ADisk: TMSXDisk); reintroduce; overload;
    procedure LoadFromFile(AFileName: string; ADisk: TMSXDisk; IsFullScreen: Boolean); reintroduce; overload;

    procedure SaveToFile(AFileName: string); override;

    function AppendFromFile(AFileName: string; ADisk: TMSXDisk = nil): Boolean;
    function AppendFromStream(AStream: TStream; AFilename: string; IsFullScreen: Boolean = False): Boolean;

    procedure ClearScreen(APage: Integer = -1);
    procedure ResetPalette;
    procedure RestorePalette;
    function GetPixel(PX, PY: Integer): Integer;
    procedure PutPixel(PX, PY, AColor: Integer);
    procedure PutPixelYJK(PX, PY, Y, J, K: Integer);
    function DisplayWidth: Integer;
    function DisplayHeight: Integer;
    function CreateBitmap: TBitmap;
    function CreateXPBitmap: TXPBitmap;
    function GetModeFromFileName(AFileName: string; var InterlaceName, PalExts: string): Integer;
    procedure SetPaletteName(AName: string; ADisk: TMSXDisk = nil);

    property BytesPerRow: Integer read FBytesPerRow;
    property ScanLine[PY: Integer]: Pointer read GetScanLine;
    property ScanLines[PY: Integer]: TMSXScanLines read GetScanLines;
    property ScreenMode: Integer read FScreenMode write SetScreenMode;
    property Page: Byte read FPage write SetPage;
    property PageSize: Integer read FPageSize;
    property NameAddress: Integer read GetNameAddress;
    property PatternAddress: Integer read GetPatternAddress;
    property ColorAddress: Integer read GetColorAddress;
    property Interlace: Boolean read FInterlace write SetInterlace;
    property InterlaceName: string read FInterlaceName write FInterlaceName;
    property PaletteName: string read FPaletteName;
    property PaletteExts: string read GetPaletteExts;
    property Palettes: TMSXPalettes read FPalettes;
    property Palette: TMSXPalette read FPalette;
    property PaletteIndex: Integer read FPaletteIndex write SetPaletteIndex;
    property PaletteAddress: Integer read FPaletteAddress;
    property PaletteTable: PMSXPalette read GetPaletteTable;
    property SpriteAttrAddress: Integer read FSpriteAttrAddress;
    property SpritePatternAddress: Integer read FSpritePatternAddress;
    property SpriteColorAddress: Integer read FSpriteColorAddress;
    property VRAM: TArrayOfByte read FVRAM;
  class var
    Screen8Palette: array of TColor32;
  end;

const
  MSXPictureExts: array[0..25] of TMSXPictureExt = (
    (Mode: 0;  Ext: '.GE0.SC0.SR0.GR0.GL0.S00.G00.S40.W40.T40'),
    (Mode: 0;  Ext: '.T0A.00A.40A'; IExt: '.T0B.00B.40B'),

    (Mode: 80; Ext: '.G80.S80.W80.T80'),
    (Mode: 80; Ext: '.80A'; IExt: '.80B'),

    (Mode: 1;  Ext: '.GE1.SC1.SR1.GR1.GL1.S01.G01'),
    (Mode: 1;  Ext: '.T1A.01A'; IExt: '.T1B.01B'),

    (Mode: 2;  Ext: '.GE2.SC2.SR2.GR2.GL2.S02.G02.LT2'),
    (Mode: 2;  Ext: '.S2A.G2A.SA2.S2A.GA2.G2A'; IExt: '.S2B.G2B.SB2.S2B.GB2.G2B'),

    (Mode: 3;  Ext: '.GE3.SC3.SR3.GR3.GL3'),
    (Mode: 3;  Ext: '.S3A.SA3.G3A.GA3.S03.G03'; IExt: '.S3B.SB3.G3B.GB3.S13.G13'),

    (Mode: 4;  Ext: '.GE4.SC4.SR4.GR4.GL4'),
    (Mode: 4;  Ext: '.S4A.SA4.G4A.GA4.S04.G04'; IExt: '.S4B.SB4.G4B.GB4.S14.G14'),

    (Mode: 5;  Ext: '.GE5.SC5.SR5.GR5.GL5.GRP'),
    (Mode: 5;  Ext: '.S5A.SA5.G5A.GA5.S05.G05'; IExt: '.S5B.SB5.G5B.GB5.S15.G15'),

    (Mode: 6;  Ext: '.GE6.SC6.SR6.GR6.GL6'),
    (Mode: 6;  Ext: '.S6A.SA6.G6A.GA6.S06.G06'; IExt: '.S6B.SB6.G6B.GA6.S16.G16'),

    (Mode: 7;  Ext: '.GE7.SC7.SR7.GR7.GL7'),
    (Mode: 7;  Ext: '.S7A.SA7.G7A.GA7.S07.G07'; IExt: '.S7B.SB7.G7B.GB7.S17.G17'),

    (Mode: 8;  Ext: '.GE8.SC8.SR8.GR8.GL8.PIC'),
    (Mode: 8;  Ext: '.S8A.SA8.G8A.GA8.S08.G08'; IExt: '.S8B.SB8.G8B.GB8.S18.G18'),

    (Mode: 10; Ext: '.GEA.SCA.SRA.GRA.GLA.S10.G10'),
    (Mode: 10; Ext: '.SA0.GA0.S0A.G0A.SAA.10A.A10'; IExt: '.SA1.GA1.S1A.G1A.SAB.10B.B10'),

    (Mode: 11; Ext: '.GEB.SCB.SRB.GRB.GLB.S11.G11'),
    (Mode: 11; Ext: '.SB0.GB0.S0B.G0B.SBA.11A.A11'; IExt: '.SB1.GB1.S1B.G1B.SBB.11B.B11'),

    (Mode: 12; Ext: '.GEC.SCC.SRC.GRC.GLC.S12.G12.SCS.SRS.YJK'),
    (Mode: 12; Ext: '.SS0.GC0.GCA.S0C.G0C.SSA.GSA.12A.A12'; IExt: '.SS1.GC1.GCB.S1C.G1C.SSB.GSB.12B.B12')
  );
  MSXPaletteExts: array[0..12] of TMSXPictureExt = (
    (Mode: 0;  Ext: '.PL0.PT0.PA0.PB0.PLT.P00.P40'),
    (Mode: 1;  Ext: '.PL1.PT1.PA1.PB1.PLT.P01'),
    (Mode: 2;  Ext: '.PL2.PT2.PA2.PB2.PLT.P02'),
    (Mode: 3;  Ext: '.PL3.PT3.PA3.PB3.PLT.P03'),
    (Mode: 4;  Ext: '.PL4.PT4.PA4.PB4.PLT.P04'),
    (Mode: 5;  Ext: '.PL5.PT5.PA5.PB5.PLT.P05'),
    (Mode: 6;  Ext: '.PL6.PT6.PA6.PB6.PLT.P06'),
    (Mode: 7;  Ext: '.PL7.PT7.PA7.PB7.PLT.P07'),
    (Mode: 8;  Ext: '.PL8.PT8.PA8.PB8.PLT.P08'),
    (Mode: 80; Ext: '.PL0.PA0.PB0.PLT.P00.P80'), // Index 9 = Screen 0 Width 80
    (Mode: 10; Ext: '.PLA.PTA.PLT.P10.PAA.PBA'),
    (Mode: 11; Ext: '.PLB.PTB.PLT.P11.PAB.PBB'),
    (Mode: 12; Ext: '.PLC.PLS.PTC.PTS.PLT.P12.PAC.PBC.PBS')
  );

  MSXRGB: array[0..7] of Byte = (0, 36, 73, 109, 146, 182, 219, 255);
  MSXSystemPalette: TMSXPalette = (
    (XRGB: $000), (XRGB: $000), (XRGB: $611), (XRGB: $733),
    (XRGB: $117), (XRGB: $327), (XRGB: $151), (XRGB: $627),
    (XRGB: $171), (XRGB: $373), (XRGB: $661), (XRGB: $664), // 663
    (XRGB: $411), (XRGB: $265), (XRGB: $555), (XRGB: $777)
  );

implementation

{ TMSXPicture }

constructor TMSXPicture.Create;
begin
  inherited Create;
  SetLength(FVRAM, 131072);
  FBinaryHeader.ID := $FE;
  FPalettes := TMSXPalettes.Create;
  FPalette := MSXSystemPalette;
  FPaletteIndex := 0;
  FInterlace := False;
  FPage := 0;
  FPageAddress := 0;
  FFileName := '';
  FInterlaceName := '';
  FPaletteName := '';
  FTextColor := 15;
  FBGColor := 4;
  FScreenMode := 5;
  FScanLine := nil;
  FMSXScanLines.NameTable := nil;
  FMSXScanLines.PatternTable := nil;
  FMSXScanLines.ColorTable := nil;
  FLastLine := -1;
  FMSXLastLine := -1;
  FBytesPerRow := 128;
  ChangedMode;
end;

function TMSXPicture.CreateBitmap: TBitmap;
var
  xbm: TXPBitmap;
  vw, vh: Integer;
begin
  xbm := TXPBitmap.Create;
  try
    xbm.SetSize(DisplayWidth, DisplayHeight);
    xbm.Draw(xbm.ClipRect, Self);
    vw := DisplayWidth;
    vh := DisplayHeight;

    Result := TBitmap.Create;
    with TBitmap(Result) do
    begin
      PixelFormat := pf24bit;
      if (vw < 512) and (vh < 424) then
      begin
        vw := 512;
        vh := 424;
        SetSize(vw, vh);
        Canvas.Brush.Color := clWhite;
        Canvas.FillRect(Canvas.ClipRect);
        xbm.Draw(Canvas, (512 - xbm.Width) div 2, (424 - xbm.Height) div 2);
      end
      else
      begin
        SetSize(vw, vh);
        xbm.Draw(Canvas, Canvas.ClipRect);
      end;
    end;
  finally
    xbm.Free;
  end;
end;

function TMSXPicture.CreateReadStream(AFileName: string; ADisk: TMSXDisk): TStream;
begin
  Result := nil;
  if ADisk <> nil then
    Result := ADisk.ExtractToMem(AFileName)
  else if FileExists(AFileName) then
  begin
    Result := TFileStream.Create(AFileName, fmOpenRead);
  end;
end;

function TMSXPicture.CreateWriteStream(AFileName: string; ADisk: TMSXDisk): TStream;
begin
  if ADisk <> nil then
    Result := TMSXDiskFileStream.Create(AFileName, ADisk, fmCreate)
  else Result := TFileStream.Create(AFileName, fmCreate);
end;

destructor TMSXPicture.Destroy;
begin
  FPalettes.Free;
  SetLength(FVRAM, 0);
  inherited;
end;

function TMSXPicture.DisplayHeight: Integer;
begin
  if FScreenMode = 3 then
    Result := FHeight * 4
  else Result := FHeight;
  if not FInterlace then Result := Result * 2;
end;

function TMSXPicture.DisplayWidth: Integer;
begin
  case FScreenMode of
    0, 1, 2, 4, 5, 8, 10, 11, 12: Result := FWidth * 2;
    3: Result := FWidth * 8;
  else
    Result := FWidth;
  end;
end;

function TMSXPicture.Draw(ABitmap: TXPBitmap; ARect: TRect): Boolean;
var
  pal_table: array[0..15] of TColor32;
  fcolor, bcolor: TColor32;
  src: TMSXScanLines;
  sptr: PByteArray;
  dptr: PColor32;
  difx, dify, px, py, boffset: Integer;
  param: TXPDrawParam;
begin
  Result := GetDrawParam(ABitmap, ARect, param);
  if Result then
  begin
    for difx := 0 to 15 do pal_table[difx] := FPalette[difx].GetColor32;
    px := param.XOffset * param.SrcWidth div param.DestWidth + FClipRect.Left;
    py := param.YOffset * param.SrcHeight div param.DestHeight + FClipRect.Top;
    difx := ARect.Right - ARect.Left;
    dify := param.DestHeight - param.YOffset * param.SrcHeight mod param.DestHeight - 1;
    case FScreenMode of
      0, 80:
      begin
        fcolor := pal_table[FTextColor];
        bcolor := pal_table[FBGColor];
        boffset := px mod 6;
        px := px div 6;
      end;
      1, 2, 4:
      begin
        boffset := px and 7;
        px := px shr 3;
      end;
      3:
      begin
        boffset := px and 1;
        px := (px shr 1);
      end;
      10, 11, 12:
      begin
        boffset := px and FMaskBits;
        px := (px shr 2) shl 2;
      end
    else
      boffset := px and FMaskBits;
      px := (px * FColorBits) shr 3;
    end;
    while ARect.Top < ARect.Bottom do
    begin
      src := ScanLines[py];
      sptr := @src.NameTable[px];
      if param.FlipY then
      begin
        Dec(ARect.Bottom);
        dptr := @ABitmap.ScanLine[ARect.Bottom][ARect.Left];
      end
      else
      begin
        dptr := @ABitmap.ScanLine[ARect.Top][ARect.Left];
        Inc(ARect.Top);
      end;
      case FScreenMode of
        0, 80: CopyCharPattern(sptr, dptr, param.SrcWidth, param.DestWidth, difx, param.XOffset, 6, boffset, param.FlipX, src.PatternTable, fcolor, bcolor);
        1: CopyColorPattern(sptr, dptr, param.SrcWidth, param.DestWidth, difx, param.XOffset, boffset, param.FlipX, False, src.PatternTable, src.ColorTable, @pal_table, 16);
        2, 4: CopyColorPattern(sptr, dptr, param.SrcWidth, param.DestWidth, difx, param.XOffset, boffset, param.FlipX, True, src.PatternTable, src.ColorTable, @pal_table, 16);
        3: CopyCharColor(sptr, dptr, param.SrcWidth, param.DestWidth, difx, param.XOffset, boffset, param.FlipX, src.PatternTable, @pal_table, 16);
        5, 7: CopyBitPalette(sptr, dptr, param.SrcWidth, param.DestWidth, difx, param.XOffset, 4, boffset, param.FlipX, @pal_table, 16);
        6: CopyBitPalette(sptr, dptr, param.SrcWidth, param.DestWidth, difx, param.XOffset, 2, boffset, param.FlipX, @pal_table, 4);
        10, 11: CopyYJKPalette(sptr, dptr, param.SrcWidth, param.DestWidth, difx, param.XOffset, boffset, param.FlipX, @pal_table, 16);
        12: CopyYJK(sptr, dptr, param.SrcWidth, param.DestWidth, difx, param.XOffset, boffset, param.FlipX);
      else
        CopyBitPalette(sptr, dptr, param.SrcWidth, param.DestWidth, difx, param.XOffset, 8, boffset, param.FlipX, @Screen8Palette[0], 256);
      end;
      dify := dify - param.SrcHeight;
      while dify < 0 do
      begin
        Inc(py);
        dify := dify + param.DestHeight;
      end;
    end;
  end;
end;

function TMSXPicture.Draw(ABitmap: TXPBitmap; PX, PY: Integer): Boolean;
var
  pal_table: array[0..15] of TColor32;
  difx, dify, xoffs, yoffs, boffset: Integer;
  fcolor, bcolor: TColor32;
  src: TMSXScanLines;
  sptr, dptr: PColor32;
  srect: TRect;
begin
  Result := False;
  if not Assigned(ABitmap) then Exit;
  difx := (FWidth shr 1) shl 1;
  dify := FHeight;
  if difx > FDrawClipRect.Right then difx := FDrawClipRect.Right;
  if dify > FDrawClipRect.Bottom then dify := FDrawClipRect.Bottom;
  difx := difx - FDrawClipRect.Left;
  dify := dify - FDrawClipRect.Top;
  if (difx <= 0) or (dify <= 0) or (ABitmap.Width <= 0) or (ABitmap.Height <= 0) then Exit;
  srect.TopLeft := Point(PX, PY);
  srect.BottomRight := Point(PX + difx, PY + dify);
  Result := CropRect(srect, ABitmap.DrawClipRect, xoffs, yoffs, FlipX, FlipY);
  xoffs := xoffs + FDrawClipRect.Left;
  yoffs := yoffs + FDrawClipRect.Top;
  if Result then
  begin
    for difx := 0 to 15 do pal_table[difx] := FPalette[difx].GetColor32;
    difx := srect.Right - srect.Left;
    case FScreenMode of
      0, 80:
      begin
        fcolor := pal_table[FTextColor];
        bcolor := pal_table[FBGColor];
        boffset := xoffs mod 6;
        xoffs := xoffs div 6;
      end;
      1, 2, 4:
      begin
        boffset := xoffs and 7;
        xoffs := xoffs shr 3;
      end;
      3:
      begin
        boffset := xoffs and 1;
        xoffs := (xoffs shr 1);
      end;
      10, 11, 12:
      begin
        boffset := xoffs and FMaskBits;
        xoffs := (xoffs shr 2) shl 2;
      end
    else
      boffset := xoffs and FMaskBits;
      xoffs := (xoffs * FColorBits) shr 3;
    end;
    while srect.Top < srect.Bottom do
    begin
      src := ScanLines[yoffs];
      sptr := @src.NameTable[xoffs];
      if FlipY then
      begin
        Dec(srect.Bottom);
        dptr := @ABitmap.ScanLine[srect.Bottom][srect.Left];
      end
      else
      begin
        dptr := @ABitmap.ScanLine[srect.Top][srect.Left];
        Inc(srect.Top);
      end;
      case FScreenMode of
        0, 80: CopyCharPattern(sptr, dptr, difx, 6, boffset, FlipX, src.PatternTable, fcolor, bcolor);
        1: CopyColorPattern(sptr, dptr, difx, boffset, FlipX, False, src.PatternTable, src.ColorTable, @pal_table, 16);
        2, 4: CopyColorPattern(sptr, dptr, difx, boffset, FlipX, True, src.PatternTable, src.ColorTable, @pal_table, 16);
        3: CopyCharColor(sptr, dptr, difx, boffset, FlipX, src.PatternTable, @pal_table, 16);
        5, 7: CopyBitPalette(sptr, dptr, difx, 4, boffset, FlipX, @pal_table, 16);
        6: CopyBitPalette(sptr, dptr, difx, 2, boffset, FlipX, @pal_table, 4);
        10, 11: CopyYJKPalette(sptr, dptr, difx, boffset, FlipX, @pal_table, 16);
        12: CopyYJK(sptr, dptr, difx, boffset, FlipX);
      else
        CopyBitPalette(sptr, dptr, difx, 8, boffset, FlipX, @Screen8Palette[0], 256);
      end;
      Inc(yoffs);
    end;
  end;
end;

function TMSXPicture.AppendFromFile(AFileName: string; ADisk: TMSXDisk): Boolean;
var
  ext: string;
begin
  ext := UpperCase(ExtractFileExt(AFileName));
  if Copy(ext, 1, 3) = '.GL' then
    Result := CopyFromFile(AFileName)
  else
  begin
    Result := BloadFromFile(AFileName);
    if FPalettes.Count = 0 then SetPaletteName(AFileName, ADisk);
  end;
end;

function TMSXPicture.AppendFromStream(AStream: TStream; AFilename: string;
  IsFullScreen: Boolean): Boolean;
var
  ext: string;
begin
  ext := UpperCase(ExtractFileExt(AFileName));
  if Copy(ext, 1, 3) = '.GL' then
    Result := CopyFromStream(AStream, IsFullScreen)
  else
  begin
    Result := BloadFromStream(AStream);
  end;
end;

procedure TMSXPicture.Assign(APicture: TMSXPicture);
begin
  inherited Assign(APicture);
  Move(APicture.FVRAM[0], FVRAM[0], Length(FVRAM));
  FPalettes.Assign(APicture.FPalettes);
  FPalette := APicture.FPalette;
  FFileName := APicture.FFileName;
  FInterlaceName := APicture.FInterlaceName;
  FPaletteName := APicture.FPaletteName;
  FScreenMode := APicture.FScreenMode;
  FColorBits := APicture.FColorBits;
  FMaskBits := APicture.FMaskBits;
  FPaletteIndex := APicture.FPaletteIndex;
  FTextColor := APicture.FTextColor;
  FBGColor := APicture.FBGColor;
  FNameAddress := APicture.FNameAddress;
  FPatternAddress := APicture.FPatternAddress;
  FColorAddress := APicture.FColorAddress;
  FSpriteAttrAddress := APicture.FSpriteAttrAddress;
  FSpritePatternAddress := APicture.FSpritePatternAddress;
  FSpriteColorAddress := APicture.FSpriteColorAddress;
  FPaletteAddress := APicture.FPaletteIndex;
  FPageAddress := APicture.FPageAddress;
  FPageSize := APicture.FPageSize;
  FPage := APicture.FPage;
  FInterlace := APicture.FInterlace;
end;

function TMSXPicture.BloadFromFile(AFileName: string; ADisk: TMSXDisk): Boolean;
var
  AStream: TStream;
begin
  AStream := CreateReadStream(AFileName, ADisk);
  try
    if AStream <> nil then
      Result := BloadFromStream(AStream)
    else Result := False;
  finally
    FreeAndNil(AStream);
  end;
end;

function TMSXPicture.BloadFromStream(AStream: TStream): Boolean;
var
  buf: array[0..6] of Byte;
  addr1, addr2: Word;
begin
  Result := False;
  if AStream.Read(&buf[0], 7) = 7 then
  begin
    if (buf[0] = $FE) or (buf[0] = $FD) then
    begin
      addr1 := buf[1] or (buf[2] shl 8);
      addr2 := buf[3] or (buf[4] shl 8);
      if buf[0] = $FE then
        AStream.Read(&FVRAM[FPageAddress + addr1], addr2 - addr1 + 1)
      else BloadRLE(AStream, @FVRAM[FPageAddress + addr1], addr2 - addr1 + 1);
      Result := True;
    end;
  end;
end;

procedure TMSXPicture.BloadRLE(AStream: TStream; ABuf: PByte; ACount: Integer);
var
  buf: array of Byte;
  bufpos: Integer;
  b, c: Byte;
begin
  SetLength(buf, ACount);
  try
    AStream.Read(buf[0], ACount);
    bufpos := 0;
    while ACount > 0 do
    begin
      b := buf[bufpos];
      Inc(bufpos);
      Dec(ACount, 1);
      case b of
        0:
        begin
          b := buf[bufpos];
          c := buf[bufpos + 1];
          Inc(bufpos, 2);
          Dec(ACount, 2);
          repeat
            ABuf^ := c;
            Inc(ABuf);
            Dec(b);
          until b = 0;
        end;
        1..15:
        begin
          c := buf[bufpos];
          Inc(bufpos);
          Dec(ACount, 1);
          repeat
            ABuf^ := c;
            Inc(ABuf);
            Dec(b);
          until b = 0;
        end;
      else
        ABuf^ := b;
        Inc(ABuf);
      end;
    end;
  finally
    SetLength(buf, 0);
  end;
end;

procedure TMSXPicture.BsaveToFile(AFileName: string; APage: Integer);
begin
  BsaveToFile(AFileName, FBinaryHeader.StartAddress, FBinaryHeader.EndAddress,
    FBinaryHeader.RunAddress, APage);
end;

procedure TMSXPicture.BsaveToFile(AFileName: string; AStartAddress, AEndAddress,
  ARunAddress: Word; APage: Integer);
var
  fs: TFileStream;
begin
  fs := TFileStream.Create(AFileName, fmCreate);
  try
    BsaveToStream(fs, AStartAddress, AEndAddress, ARunAddress, APage);
  finally
    fs.Free;
  end;
end;

procedure TMSXPicture.BsaveToStream(AStream: TStream; APage: Integer);
begin
  BsaveToStream(AStream, FBinaryHeader.StartAddress, FBinaryHeader.EndAddress,
    FBinaryHeader.RunAddress, APage);
end;

procedure TMSXPicture.BsaveToStream(AStream: TStream; AStartAddress,
  AEndAddress, ARunAddress: Word; APage: Integer);
var
  hd: TMSXBinaryHeader;
begin
  if APage < 0 then
    APage := FPageAddress
  else APage := APage * FPageSize;
  hd.ID := $FE;
  hd.StartAddress := AStartAddress;
  hd.EndAddress := AEndAddress;
  hd.RunAddress := ARunAddress;
  AStream.Write(hd, SizeOf(hd));
  AStream.Write(FVRAM[APage + AStartAddress], AEndAddress - AStartAddress + 1);
end;

procedure TMSXPicture.ChangedInterlace;
begin
  case FScreenMode of
    0, 1, 2, 4, 80:
      FHeight := 192;
    3:
      FHeight := 48;
  else
    FHeight := 212;
  end;
  if FInterlace then FHeight := FHeight * 2;
  ChangedSize;
end;

procedure TMSXPicture.ChangedMode;
begin
  case FScreenMode of
    0:
    begin
      FWidth := 240;
      FColorBits := 6;
      FMaskBits := 7;
      FPageSize := $1000;
      FNameAddress := $0000;      // 0000-03BF
      FPatternAddress := $0800;   // 0800-0FFF
      FColorAddress := 0;         // --------- not used
      FPaletteAddress := $400;    // 0400-041F
      FSpriteAttrAddress := 0;    // --------- not used
      FSpritePatternAddress := 0; // --------- not used
      FSpriteColorAddress := 0;   // --------- not used
      FBinaryHeader.StartAddress := 0;
      FBinaryHeader.EndAddress := $FFF;
      FBinaryHeader.RunAddress := 0;
      FBytesPerRow := 40;
    end;
    80:
    begin
      FWidth := 480;
      FColorBits := 6;
      FMaskBits := 7;
      FPageSize := $2000;
      FNameAddress := $0000;      // 0000-077F
      FPatternAddress := $1000;   // 1000-17FF
      FColorAddress := $800;      // 0800-08EF - Blink
      FPaletteAddress := $F00;    // 0F00-0F1F
      FSpriteAttrAddress := 0;    // --------- not used
      FSpritePatternAddress := 0; // --------- not used
      FSpriteColorAddress := 0;   // --------- not used
      FBinaryHeader.StartAddress := 0;
      FBinaryHeader.EndAddress := $17FF;
      FBinaryHeader.RunAddress := 0;
      FBytesPerRow := 80;
    end;
    1:
    begin
      FWidth := 256;
      FColorBits := 8;
      FMaskBits := 7;
      FPageSize := $4000;
      FNameAddress := $1800;          // 1800-1AFF
      FPatternAddress := $0000;       // 0000-07FF
      FColorAddress := $2000;         // 2000-201F
      FPaletteAddress := $2020;       // 2020-203F
      FSpriteAttrAddress := $1B00;    // 1B00-1B7F
      FSpritePatternAddress := $3800; // 3800-3FFF
      FSpriteColorAddress := 0;       // --------- not used
      FBinaryHeader.StartAddress := 0;
      FBinaryHeader.EndAddress := $201F;
      FBinaryHeader.RunAddress := 0;
      FBytesPerRow := 32;
    end;
    2:
    begin
      FWidth := 256;
      FColorBits := 8;
      FMaskBits := 7;
      FPageSize := $4000;
      FNameAddress := $1800;          // 1800-1AFF
      FPatternAddress := $0000;       // 0000-17FF
      FColorAddress := $2000;         // 2000-37FF
      FPaletteAddress := $1B80;       // 1B80-1B9F
      FSpriteAttrAddress := $1B00;    // 1B00-1B7F
      FSpritePatternAddress := $3800; // 3800-3FFF
      FSpriteColorAddress := 0;       // --------- not used
      FBinaryHeader.StartAddress := 0;
      FBinaryHeader.EndAddress := $37FF;
      FBinaryHeader.RunAddress := 0;
      FBytesPerRow := 32;
    end;
    3:
    begin
      FWidth := 64;
      FColorBits := 4;
      FMaskBits := 1;
      FPageSize := $4000;
      FNameAddress := $0800;          // 0800-0AFF
      FPatternAddress := $0000;       // 0000-05FF
      FColorAddress := 0;             // --------- not used
      FPaletteAddress := $2020;       // 2020-203F
      FSpriteAttrAddress := $1B00;    // 1B00-1B7F
      FSpritePatternAddress := $3800; // 3800-3FFF
      FSpriteColorAddress := 0;       // --------- not used
      FBinaryHeader.StartAddress := 0;
      FBinaryHeader.EndAddress := $AFF;
      FBinaryHeader.RunAddress := 0;
      FBytesPerRow := 32;
    end;
    4:
    begin
      FWidth := 256;
      FColorBits := 8;
      FMaskBits := 7;
      FPageSize := $4000;
      FNameAddress := $1800;          // 1800-1AFF
      FPatternAddress := $0000;       // 0000-17FF
      FColorAddress := $2000;         // 2000-37FF
      FPaletteAddress := $1B80;       // 1B80-1B9F
      FSpriteAttrAddress := $1E00;    // 1E00-1E7F
      FSpritePatternAddress := $3800; // 3800-3FFF
      FSpriteColorAddress := $1C00;   // 1C00-1DFF
      FBinaryHeader.StartAddress := 0;
      FBinaryHeader.EndAddress := $37FF;
      FBinaryHeader.RunAddress := 0;
      FBytesPerRow := 32;
    end;
    5:
    begin
      FWidth := 256;
      FColorBits := 4;
      FMaskBits := 1;
      FPageSize := $8000;
      FPaletteAddress := $7680;       // 7680-769F
      FNameAddress := $0000;          // 0000-69FF --------- not used
      FPatternAddress := $0000;       // 0000-69FF --------- not used
      FColorAddress := $0000;         // 0000-69FF --------- not used
      FSpriteAttrAddress := $7600;    // 7600-767F
      FSpritePatternAddress := $7800; // 7800-7FFF
      FSpriteColorAddress := $7400;   // 7400-75FF
      FBinaryHeader.StartAddress := 0;
      FBinaryHeader.EndAddress := $769F;
      FBinaryHeader.RunAddress := 0;
      FBytesPerRow := 128;
    end;
    6:
    begin
      FWidth := 512;
      FColorBits := 2;
      FMaskBits := 3;
      FPageSize := $8000;
      FPaletteAddress := $7680;       // 7680-769F
      FNameAddress := $0000;          // 0000-69FF --------- not used
      FPatternAddress := $0000;       // 0000-69FF --------- not used
      FColorAddress := $0000;         // 0000-69FF --------- not used
      FSpriteAttrAddress := $7600;    // 7600-767F
      FSpritePatternAddress := $7800; // 7800-7FFF
      FSpriteColorAddress := $7400;   // 7400-75FF
      FBinaryHeader.StartAddress := 0;
      FBinaryHeader.EndAddress := $769F;
      FBinaryHeader.RunAddress := 0;
      FBytesPerRow := 128;
    end;
    7:
    begin
      FWidth := 512;
      FColorBits := 4;
      FMaskBits := 1;
      FPageSize := $10000;
      FPaletteAddress := $FA80;       // FA80-FA9F
      FNameAddress := $0000;          // 0000-D3FF --------- not used
      FPatternAddress := $0000;       // 0000-D3FF --------- not used
      FColorAddress := $0000;         // 0000-D3FF --------- not used
      FSpriteAttrAddress := $FA00;    // FA00-FA7F
      FSpritePatternAddress := $F000; // F000-F7FF
      FSpriteColorAddress := $F800;   // F800-F9FF
      FBinaryHeader.StartAddress := 0;
      FBinaryHeader.EndAddress := $FA9F;
      FBinaryHeader.RunAddress := 0;
      FBytesPerRow := 256;
    end;
    10, 11, 12:
    begin
      FWidth := 256;
      FColorBits := 8;
      FMaskBits := 3;
      FPageSize := $10000;
      FPaletteAddress := $FA80;       // FA80-FA9F
      FNameAddress := $0000;          // 0000-D3FF --------- not used
      FPatternAddress := $0000;       // 0000-D3FF --------- not used
      FColorAddress := $0000;         // 0000-D3FF --------- not used
      FSpriteAttrAddress := $FA00;    // FA00-FA7F
      FSpritePatternAddress := $F000; // F000-F7FF
      FSpriteColorAddress := $F800;   // F800-F9FF
      FBinaryHeader.StartAddress := 0;
      FBinaryHeader.EndAddress := $FA9F;
      FBinaryHeader.RunAddress := 0;
      FBytesPerRow := 256;
    end;
  else // 8
    FWidth := 256;
    FColorBits := 8;
    FMaskBits := 0;
    FPageSize := $10000;
    FPaletteAddress := $FA80;       // FA80-FA9F
    FNameAddress := $0000;          // 0000-D3FF --------- not used
    FPatternAddress := $0000;       // 0000-D3FF --------- not used
    FColorAddress := $0000;         // 0000-D3FF --------- not used
    FSpriteAttrAddress := $FA00;    // FA00-FA7F
    FSpritePatternAddress := $F000; // F000-F7FF
    FSpriteColorAddress := $F800;   // F800-F9FF
    FBinaryHeader.StartAddress := 0;
    FBinaryHeader.EndAddress := $D3FF;
    FBinaryHeader.RunAddress := 0;
    FBytesPerRow := 256;
  end;
  ChangedInterlace;
end;

procedure TMSXPicture.ChangedPage;
begin
  FPageAddress := GetPageAddress(FPage);
end;

function TMSXPicture.CreateXPBitmap: TXPBitmap;
begin
  Result := TXPBitmap.Create;
  Result.SetSize(DisplayWidth, DisplayHeight);
  Result.Draw(Result.ClipRect, Self);
end;

function TMSXPicture.GetColorAddress: Integer;
begin
  Result := FPageAddress + FColorAddress;
end;

function TMSXPicture.GetModeFromFileName(AFileName: string;
  var InterlaceName, PalExts: string): Integer;
var
  ext: string;
  n, p: Integer;
begin
  Result := -1;
  InterlaceName := '';
  PalExts := '';
  ext := UpperCase(ExtractFileExt(AFileName));
  n := Length(MSXPictureExts);
  while (n > 0) and (Result < 0) do
  begin
    Dec(n);
    p := Pos(ext, MSXPictureExts[n].Ext);
    if p > 0 then
    begin
      Result := MSXPictureExts[n].Mode;
      InterlaceName := Copy(MSXPictureExts[n].IExt, p, 4);
      PalExts := GetPaletteExts(Result);
    end;
  end;
end;

function TMSXPicture.GetNameAddress: Integer;
begin
  Result := FPageAddress + FNameAddress;
end;

function TMSXPicture.GetPageAddress(APage: Byte): Integer;
begin
  Result := APage * FPageSize;
end;

function TMSXPicture.GetPaletteExts: string;
begin
  Result := GetPaletteExts(FScreenMode);
end;

function TMSXPicture.GetPaletteExts(AMode: Integer): string;
begin
  if AMode = 80 then AMode := 9;
  if (AMode >= 0) and (AMode < 13) then
    Result := MSXPaletteExts[AMode].Ext
  else Result := '';
end;

function TMSXPicture.GetPaletteTable: PMSXPalette;
begin
  Result := @FVRAM[FPaletteAddress];
end;

function TMSXPicture.GetPatternAddress: Integer;
begin
  Result := FPageAddress + FPatternAddress;
end;

function TMSXPicture.GetPixel(PX, PY: Integer): Integer;
var
  sline: TMSXScanLines;
  c, b: Byte;
begin
  sline := ScanLines[PY];
  case FScreenMode of
    0, 80, 1: Result := 0;
    2, 4:
    begin
      b := sline.NameTable[PX shr 3];
      c := sline.PatternTable[b shl 3];
      b := sline.ColorTable[b shl 3];
      if ((c shr (7 - (PX and 7))) and 1) = 0 then
        Result := b and 15
      else Result := b shr 4;
    end;
    6:
    begin
      c := sline.NameTable[PX shr 2];
      Result := c shr ((3 - (PX and 3)) shl 1);
    end;
    3, 5, 7:
    begin
      c := sline.NameTable[PX shr 1];
      Result := c shr ((1 - (PX and 1)) shl 2);
    end;
    10:
    begin
      c := sline.NameTable[PX];
      Result := c shr 4;
    end
  else
    Result := sline.NameTable[PX];
  end;
end;

function TMSXPicture.GetScanLine(PY: Integer): Pointer;
var
  mpage: Integer;
begin
  if PY = FLastLine then Exit(FScanLine);
  FLastLine := PY;
  if FInterlace then
  begin
    mpage := (PY and 1) * FPageSize + FNameAddress;
    PY := PY shr 1;
  end
  else mpage := FNameAddress;
  case FScreenMode of
    0, 1, 2, 4, 80: FScanLine := @FVRAM[mpage + ((PY shr 3) * FWidth div FColorBits)];
    3: FScanLine := @FVRAM[mpage + ((PY shr 3) shl 7) + (((PY and 7) shr 1) shl 5)];
  else
    FScanLine := @FVRAM[mpage + ((PY * FWidth * FColorBits) shr 3)];
  end;
  Result := FScanLine;
end;

function TMSXPicture.GetScanLines(PY: Integer): TMSXScanLines;
var
  mpage: Integer;
begin
  if PY = FMSXLastLine then Exit(FMSXScanLines);
  FMSXLastLine := PY;
  if FInterlace then
  begin
    mpage := (PY and 1) * FPageSize;
    PY := PY shr 1;
  end
  else mpage := 0;
  with Result do
  begin
    case FScreenMode of
      0, 1, 2, 4, 80: NameTable := @FVRAM[mpage + FNameAddress + ((PY shr 3) * FWidth div FColorBits)];
      3: NameTable := @FVRAM[mpage + FNameAddress + ((PY shr 3) shl 7) + (((PY and 7) shr 1) shl 5)];
    else
      NameTable := @FVRAM[mpage + FNameAddress + ((PY * FWidth * FColorBits) shr 3)];
    end;
    case FScreenMode of
      0, 1, 80:
      begin
        PatternTable := @FVRAM[mpage + FPatternAddress + (PY and 7)];
        ColorTable := @FVRAM[mpage + FColorAddress];
      end;
      2, 4:
      begin
        PatternTable := @FVRAM[mpage + FPatternAddress + ((PY shr 6) shl 11) + (PY and 7)];
        ColorTable := @FVRAM[mpage + FColorAddress + ((PY shr 6) shl 11) + (PY and 7)];
      end;
      3:
      begin
        PatternTable := @FVRAM[mpage + FPatternAddress + (PY and 7)];
        ColorTable := @FVRAM[mpage + FColorAddress];
      end
    else
      PatternTable := @FVRAM[mpage + FPatternAddress];
      ColorTable := @FVRAM[mpage + FColorAddress];
    end;
  end;
  FMSXScanLines := Result;
end;

procedure TMSXPicture.ClearScreen(APage: Integer);
var
  n, p, ap: Integer;
  c: Byte;
begin
  if APage < 0 then
    p := FPageAddress
  else p := APage * FPageSize;
  if FInterlace and (APage < 0) then
    ap := (FPage xor 1) * FPageAddress
  else ap := -1;
  c := ((FTextColor and 15) shl 4) or (FBGColor and 15);
  case FScreenMode of
    0:
    begin
      FillChar(FVRAM[p + FNameAddress], 960, 32);
      if ap >= 0 then FillChar(FVRAM[ap + FNameAddress], 960, 32);
    end;
    80:
    begin
      FillChar(FVRAM[p + FNameAddress], 1920, 32);
      if ap >= 0 then FillChar(FVRAM[ap + FNameAddress], 1920, 32);
    end;
    1:
    begin
      FillChar(FVRAM[p + FNameAddress], 768, 32);
      FillChar(FVRAM[p + FColorAddress], 32, c);
      if ap >= 0 then
      begin
        FillChar(FVRAM[ap + FNameAddress], 768, 32);
        FillChar(FVRAM[ap + FColorAddress], 32, c);
      end;
    end;
    2, 4:
    begin
      for n := 0 to 767 do FVRAM[p + FNameAddress + n] := n and 255;
      FillChar(FVRAM[p + FColorAddress], 6144, c);
      FillChar(FVRAM[p + FPatternAddress], 6144, 0);
      if ap >= 0 then
      begin
        for n := 0 to 767 do FVRAM[ap + FNameAddress + n] := n and 255;
        FillChar(FVRAM[ap + FColorAddress], 6144, c);
        FillChar(FVRAM[ap + FPatternAddress], 6144, 0);
      end;
    end;
    3:
    begin
      for n := 0 to 767 do FVRAM[p + FNameAddress + n] := ((n shr 7) shl 5) + (n and 31);
      FillChar(FVRAM[p + FPatternAddress], 1536, 0);
      if ap >= 0 then
      begin
        for n := 0 to 767 do FVRAM[ap + FNameAddress + n] := ((n shr 7) shl 5) + (n and 31);
        FillChar(FVRAM[ap + FPatternAddress], 1536, 0);
      end;
    end;
    5, 6:
    begin
      FillChar(FVRAM[p], 27136, 0);
      if ap >= 0 then
      begin
        FillChar(FVRAM[ap], 27136, 0);
      end;
    end;
    7, 8, 10, 11, 12:
    begin
      FillChar(FVRAM[p], 54272, 0);
      if ap >= 0 then
      begin
        FillChar(FVRAM[ap], 54272, 0);
      end;
    end;
  end;
  Move(MSXSystemPalette[0], FVRAM[p + FPaletteAddress], 32);
  if ap >= 0 then Move(MSXSystemPalette[0], FVRAM[ap + FPaletteAddress], 32);
end;

function TMSXPicture.CopyFromFile(AFileName: string; IsFullScreen: Boolean): Boolean;
begin
  Result := CopyFromFile(AFileName, nil, IsFullScreen);
end;

function TMSXPicture.CopyFromFile(AFileName: string; ADisk: TMSXDisk;
  IsFullScreen: Boolean): Boolean;
var
  AStream: TStream;
begin
  AStream := CreateReadStream(AFileName, ADisk);
  try
    if AStream <> nil then
      Result := CopyFromStream(AStream, IsFullScreen)
    else Result := False;
  finally
    FreeAndNil(AStream);
  end;
end;

function TMSXPicture.CopyFromStream(AStream: TStream;
  IsFullScreen: Boolean): Boolean;
var
  x, y, x0, y0, c, boffs, bmask, cmask: Integer;
  w, h: Word;
  b: Byte;
begin
  AStream.Read(w, 2);
  AStream.Read(h, 2);
  if not IsFullScreen then
  begin
    SetSize(w, h);
    x0 := 0;
    y0 := 0;
  end
  else
  begin
    x0 := (FWidth - w) div 2;
    y0 := (FHeight - h) div 2;
  end;
  cmask := (1 shl FColorBits) - 1;
  bmask := (8 div FColorBits) - 1;
  boffs := bmask;
  for y := y0 to y0 + h - 1 do
  begin
    for x := x0 to x0 + w - 1 do
    begin
      if (boffs and bmask) = bmask then AStream.Read(b, 1);
      c := (b shr (boffs * FColorBits)) and cmask;
      boffs := (boffs - 1) and bmask;
      PutPixel(x, y, c);
    end;
  end;
  Result := True;
end;

function TMSXPicture.CopyToFile(AFileName: string; ARect: TRect; APage: Integer): Boolean;
begin
  Result := CopyToFile(AFileName, nil, ARect, APage);
end;

function TMSXPicture.CopyToFile(AFileName: string; ADisk: TMSXDisk; ARect: TRect; APage: Integer): Boolean;
var
  AStream: TStream;
begin
  AStream := CreateWriteStream(AFileName, ADisk);
  try
    Result := CopyToStream(AStream, ARect, APage);
  finally
    FreeAndNil(AStream);
  end;
end;

function TMSXPicture.CopyToStream(AStream: TStream; ARect: TRect; APage: Integer): Boolean;
var
  x, y, c, boffs: Integer;
  w, h: Word;
  b: Byte;
begin
  w := ARect.Right - ARect.Left;
  h := ARect.Bottom - ARect.Top;
  AStream.Write(w, 2);
  AStream.Write(h, 2);
  b := 0;
  boffs := 8;
  for y := ARect.Top to ARect.Bottom - 1 do
  begin
    for x := ARect.Left to ARect.Right - 1 do
    begin
      c := GetPixel(x, y);
      Dec(boffs, FColorBits);
      b := b or (c shl boffs);
      if boffs = 0 then
      begin
        AStream.Write(b, 1);
        boffs := 8;
        b := 0;
      end;
    end;
  end;
  if boffs > 0 then AStream.Write(b, 1);
  Result := True;
end;

procedure TMSXPicture.SetPaletteIndex(AIndex: Integer);
begin
  case AIndex of
    -2: ResetPalette;
    -1: RestorePalette;
  else
    if AIndex >= FPalettes.Count then AIndex := FPalettes.Count - 1;
    if AIndex < 0 then AIndex := 0;
    FPaletteIndex := AIndex;
    if FPalettes.Count > 0 then
      FPalette := FPalettes.Palettes[AIndex]
    else RestorePalette;
  end;
end;

procedure TMSXPicture.SetPaletteName(AName: string; ADisk: TMSXDisk);
var
  iname, pext: string;
  n: Integer;
begin
  if AName <> '*' then
    FPaletteName := AName
  else
  begin
    n := GetModeFromFileName(FFileName, iname, pext);
    if n < 0 then Exit;
    FPalettes.Clear;
    FPaletteName := '';
    while (pext <> '') and (FPaletteName = '') do
    begin
      FPaletteName := ChangeFileExt(FFileName, Copy(pext, 1, 4));
      Delete(pext, 1, 4);
      if ADisk <> nil then
      begin
        if not FPalettes.BLoadFromDisk(ADisk, FPaletteName) then
        begin
          if not FPalettes.LoadFromDisk(ADisk, FPaletteName) then FPaletteName := '';
        end;
      end
      else
      begin
        if not FPalettes.BLoadFromFile(FPaletteName) then
        begin
          if not FPalettes.LoadFromFile(FPaletteName) then FPaletteName := '';
        end;
      end;
    end;
  end;
  if (FScreenMode < 5) and (AName = '*') then
    SetPaletteIndex(-2)
  else SetPaletteIndex(0);
end;

procedure TMSXPicture.RestorePalette;
begin
  Move(&FVRAM[FPageAddress + FPaletteAddress], &FPalette[0], 32);
  FPaletteIndex := -1;
end;

procedure TMSXPicture.ResetPalette;
begin
  FPalette := MSXSystemPalette;
  FPaletteIndex := -2;
end;

class procedure TMSXPicture.MakeScreen8Palette;
var
  n: Integer;
begin
  SetLength(Screen8Palette, 256);
  for n := 0 to 255 do Screen8Palette[n] := Color32OfByte(
    MSXRGB[(n shr 2) and 7], MSXRGB[n shr 5],
    MSXRGB[((n and 3) shl 1) or ((n shr 1) and 1)], 255
  );
end;

procedure TMSXPicture.PutPixel(PX, PY, AColor: Integer);
var
  ptr: PByteArray;
  b: Byte;
begin
  ptr := ScanLine[PY];
  case FScreenMode of
    0, 80, 1:;
    2, 4:
    begin
      ptr := @ptr[PX shr 3];
      PX := 7 - (PX and 7);
      b := ptr[0];
      ptr[0] := (b and (255 - (1 shl PX))) or ((AColor and 1) shl PX);
    end;
    6:
    begin
      ptr := @ptr[PX shr 2];
      PX := (3 - (PX and 3)) shl 1;
      b := ptr[0];
      ptr[0] := (b and (255 - (3 shl PX))) or ((AColor and 3) shl PX);
    end;
    3, 5, 7:
    begin
      ptr := @ptr[PX shr 1];
      PX := (1 - (PX and 1)) shl 2;
      b := ptr[0];
      ptr[0] := (b and (255 - (15 shl PX))) or ((AColor and 15) shl PX);
    end;
    10:
    begin
      b := ptr[PX];
      ptr[PX] := (b and 7) or ((AColor and 15) shl 4) or 8;
    end
  else
    ptr[PX] := AColor and 255;
  end;
end;

procedure TMSXPicture.PutPixelYJK(PX, PY, Y, J, K: Integer);
var
  ptry: PYJKColor;
  ptra: PYJKAColor;
  ptr: PByte;
  b: Byte;
begin
  case FScreenMode of
    10, 11:
    begin
      b := PX and 3;
      ptr := ScanLine[PY];
      ptra := @ptr[PX - b];
      ptra^.Y[b] := Y;
      ptra^.J := J;
      ptra^.K := K;
    end;
    12:
    begin
      b := PX and 3;
      ptr := ScanLine[PY];
      ptry := @ptr[PX - b];
      ptry^.Y[b] := Y;
      ptry^.J := J;
      ptry^.K := K;
    end;
  end;
end;

procedure TMSXPicture.SaveToFile(AFileName: string);
var
  xbm: TXPBitmap;
  ext: string;
begin
  ext := UpperCase(ExtractFileExt(AFileName));
  if ext = '.PNG' then
  begin
    xbm := CreateXPBitmap;
    try
      xbm.SaveToFile(AFileName);
    finally
      xbm.Free;
    end;
  end;
end;

procedure TMSXPicture.SetInterlace(AValue: Boolean);
begin
  if FInterlace <> AValue then
  begin
    FInterlace := AValue;
    ChangedInterlace;
  end;
end;

procedure TMSXPicture.SetPage(APage: Byte);
begin
  FPage := APage;
  ChangedPage;
end;

procedure TMSXPicture.SetScreenMode(AMode: Integer);
begin
  case AMode of
    0..8, 10..12, 80:
    begin
      FScreenMode := AMode;
      ChangedMode;
    end
  else
    raise Exception.Create('Invalid Screen Mode '+ IntToStr(Amode));
  end;
end;

function TMSXPicture.Draw(ABitmap: TXPBitmap; PX, PY: Integer;
  AMode: TXPDrawMode): Boolean;
begin
  Result := Draw(ABitmap, PX, PY);
end;

function TMSXPicture.Draw(ABitmap: TXPBitmap; ARect: TRect;
  AMode: TXPDrawMode): Boolean;
begin
  Result := Draw(ABitmap, ARect);
end;

function TMSXPicture.FillFromFile(AFileName: string; ADisk: TMSXDisk): Boolean;
var
  AStream: TStream;
begin
  AStream := CreateReadStream(AFileName, ADisk);
  try
    if AStream <> nil then
    begin
      FillFromStream(AStream);
      Result := True;
    end
    else Result := False;
  finally
    FreeAndNil(AStream);
  end;
end;

function TMSXPicture.FillFromStream(AStream: TStream): Integer;
begin
  Result := AStream.Read(&FVRAM[FPageAddress], FPageSize);
end;

procedure TMSXPicture.LoadFromFile(AFileName: string; ADisk: TMSXDisk);
begin
  LoadFromFile(AFileName, ADisk, False);
end;

procedure TMSXPicture.LoadFromFile(AFileName: string; ADisk: TMSXDisk;
  IsFullScreen: Boolean);
var
  stm: TStream;
  fname: string;
begin
  stm := CreateReadStream(AFileName, ADisk);
  try
    if stm <> nil then LoadFromStream(stm, AFileName, IsFullScreen);
  finally
    FreeAndNil(stm);
  end;
  stm := CreateReadStream(FInterlaceName, ADisk);
  try
    if stm <> nil then
    begin
      SetPage(FPage xor 1);
      SetInterlace(AppendFromStream(stm, fname, IsFullScreen) or FInterlace);
      SetPage(FPage xor 1);
    end;
  finally
    FreeAndNil(stm);
  end;
  SetPaletteName('*', ADisk);
end;

function TMSXPicture.LoadFromLT2(AStream: TStream): Boolean;
var
  hd: TLT2Header;
  npart, page0, page1, n0, n1, n2: Integer;
  dptr, cptr: PByteArray;
begin
  page0 := 0;
  page1 := FPageSize;
  AStream.Read(hd, SizeOf(hd));
  for npart := 0 to 2 do
  begin
    dptr := @FVRAM[page0 + FPatternAddress + npart * 2048];
    cptr := @FVRAM[page1 + FPatternAddress + npart * 2048];
    AStream.Position := hd.PatternDatas[npart].Frames[0].Offset;
    n0 := hd.PatternDatas[npart].Frames[0].Length;
    AStream.Read(dptr[0], n0);
    Move(dptr[0], cptr[0], n0);

    dptr := @FVRAM[page0 + FPatternAddress + npart * 2048 + n0];
    AStream.Position := hd.PatternDatas[npart].Frames[1].Offset;
    n1 := hd.PatternDatas[npart].Frames[1].Length;
    AStream.Read(dptr[0], n1);

    dptr := @FVRAM[page1 + FPatternAddress + npart * 2048 + n0];
    AStream.Position := hd.PatternDatas[npart].Frames[2].Offset;
    n2 := hd.PatternDatas[npart].Frames[2].Length;
    AStream.Read(dptr[0], n2);

    dptr := @FVRAM[page0 + FColorAddress + npart * 2048];
    cptr := @FVRAM[page1 + FColorAddress + npart * 2048];
    AStream.Position := hd.ColorDatas[npart].Frames[0].Offset;
    n0 := hd.ColorDatas[npart].Frames[0].Length;
    AStream.Read(dptr[0], n0);
    Move(dptr[0], cptr[0], n0);

    dptr := @FVRAM[page0 + FColorAddress + npart * 2048 + n0];
    AStream.Position := hd.ColorDatas[npart].Frames[1].Offset;
    n1 := hd.ColorDatas[npart].Frames[1].Length;
    AStream.Read(dptr[0], n1);

    dptr := @FVRAM[page1 + FColorAddress + npart * 2048 + n0];
    AStream.Position := hd.ColorDatas[npart].Frames[2].Offset;
    n2 := hd.ColorDatas[npart].Frames[2].Length;
    AStream.Read(dptr[0], n2);

    dptr := @FVRAM[page0 + FNameAddress];
    AStream.Position := hd.NameOffsets[1];
    AStream.Read(dptr[0], 768);

    dptr := @FVRAM[page1 + FNameAddress];
    AStream.Position := hd.NameOffsets[2];
    AStream.Read(dptr[0], 768);
  end;
  SetInterlace(True);
  Result := True;
end;

procedure TMSXPicture.LoadFromFile(AFileName: string);
begin
  LoadFromFile(AFileName, nil, False);
end;

procedure TMSXPicture.LoadFromFile(AFileName: string; IsFullScreen: Boolean);
begin
  LoadFromFile(AFileName, nil, IsFullScreen);
end;

procedure TMSXPicture.LoadFromStream(AStream: TStream; AFileName: string);
begin
  LoadFromStream(AStream, AFileName, False);
end;

procedure TMSXPicture.LoadFromStream(AStream: TStream; AFileName: string;
  IsFullScreen: Boolean);
var
  ext, iext, pext: string;
  n: Integer;
begin
  FInterlace := False;
  FFileName := AFileName;
  FPaletteName := '';
  n := GetModeFromFileName(AFileName, iext, pext);
  if iext <> '' then
    FInterlaceName := ChangeFileExt(AFileName, iext)
  else FInterlaceName := '';
  if n >= 0 then
  begin
    ScreenMode := n;
    ClearScreen;
    ext := UpperCase(ExtractFileExt(AFileName));
    if Copy(ext, 1, 3) = '.GL' then
      CopyFromStream(AStream, IsFullScreen)
    else if ext = '.LT2' then
      LoadFromLT2(AStream)
    else if not BloadFromStream(AStream) then
    begin
      FillFromStream(AStream);
    end;
//    SetPaletteName('*', ADisk);
  end;
end;

{ TMSXPaletteEntry }

function TMSXPaletteEntry.GetColor: TColor;
begin
  Result := ColorOfByte(MSXRGB[R], MSXRGB[G], MSXRGB[B]);
end;

function TMSXPaletteEntry.GetColor32: TColor32;
begin
  Result := Color32OfByte(MSXRGB[R], MSXRGB[G], MSXRGB[B]);
end;

function TMSXPaletteEntry.GetB: Byte;
begin
  Result := RB and 7;
end;

function TMSXPaletteEntry.GetG: Byte;
begin
  Result := XG and 7;
end;

function TMSXPaletteEntry.GetR: Byte;
begin
  Result := (RB shr 4) and 7;
end;

function TMSXPaletteEntry.GetX: Byte;
begin
  Result := (XG shr 4) and 7;
end;

procedure TMSXPaletteEntry.SetB(AValue: Byte);
begin
  RB := (RB and $F0) or (AValue and 7);
end;

procedure TMSXPaletteEntry.SetColor(AValue: TColor);
begin
  R := TColorEntry(AValue).R shr 5;
  G := TColorEntry(AValue).G shr 5;
  B := TColorEntry(AValue).B shr 5;
  X := 0;
end;

procedure TMSXPaletteEntry.SetColor32(AValue: TColor32);
begin
  R := AValue.R shr 5;
  G := AValue.G shr 5;
  B := AValue.B shr 5;
  X := 0;
end;

procedure TMSXPaletteEntry.SetG(AValue: Byte);
begin
  XG := (XG and $F0) or (AValue and 7);
end;

procedure TMSXPaletteEntry.SetR(AValue: Byte);
begin
  RB := (RB and $0F) or ((AValue and 7) shl 4);
end;

procedure TMSXPaletteEntry.SetX(AValue: Byte);
begin
  XG := (XG and $0F) or ((AValue and 7) shl 4);
end;

{ TMSXPalettes }

procedure TMSXPalettes.Add(APalette: TMSXPalette);
var
  n: Integer;
begin
  n := Length(FPalettes);
  SetLength(FPalettes, n + 1);
  FPalettes[n] := APalette;
end;

procedure TMSXPalettes.Assign(APalettes: TMSXPalettes);
begin
  SetLength(FPalettes, APalettes.Count);
  Move(APalettes.FPalettes[0], FPalettes[0], SizeOf(TMSXPalette) * Count);
end;

function TMSXPalettes.BLoadFromDisk(ADisk: TMSXDisk;
  AFileName: string): Boolean;
var
  stm: TStream;
begin
  Result := False;
  if ADisk.FileNameExists(AFileName) then
  begin
    stm := ADisk.ExtractToMem(AFileName);
    try
      Result := BloadFromStream(stm);
    finally
      stm.Free;
    end;
  end;
end;

function TMSXPalettes.BLoadFromFile(AFileName: string): Boolean;
var
  stream: TFileStream;
begin
  Result := False;
  if FileExists(AFileName) then
  begin
    stream := TFileStream.Create(AFileName, fmOpenRead);
    try
      Result := BloadFromStream(stream);
    finally
      stream.Free;
    end;
  end;
end;

function TMSXPalettes.BLoadFromStream(AStream: TStream): Boolean;
var
  buf: array[0..6] of Byte;
  pal: TMSXPalette;
  n: Integer;
begin
  Result := False;
  n := AStream.Read(buf[0], 7);
  if (n = 7) and ((buf[0] = $FE) or (buf[0] = $FD)) then
  begin
    Clear;
    n := AStream.Read(&pal[0], 32);
    while n = 32 do
    begin
      Add(pal);
      n := AStream.Read(&pal[0], 32);
    end;
    Result := True;
  end;
end;

procedure TMSXPalettes.Clear;
begin
  SetLength(FPalettes, 0);
end;

constructor TMSXPalettes.Create;
begin
  SetLength(FPalettes, 0);
end;

destructor TMSXPalettes.Destroy;
begin
  SetLength(FPalettes, 0);
  inherited;
end;

function TMSXPalettes.GetCount: Integer;
begin
  Result := Length(FPalettes);
end;

function TMSXPalettes.LoadFromDisk(ADisk: TMSXDisk; AFileName: string): Boolean;
var
  stm: TStream;
begin
  Result := False;
  if ADisk.FileNameExists(AFileName) then
  begin
    stm := ADisk.ExtractToMem(AFileName);
    try
      Result := LoadFromStream(stm);
    finally
      stm.Free;
    end;
  end;
end;

function TMSXPalettes.LoadFromFile(AFileName: string): Boolean;
var
  stream: TFileStream;
begin
  Result := False;
  if FileExists(AFileName) then
  begin
    stream := TFileStream.Create(AFileName, fmOpenRead);
    try
      Result := LoadFromStream(stream);
    finally
      stream.Free;
    end;
  end;
end;

function TMSXPalettes.LoadFromStream(AStream: TStream): Boolean;
var
  pal: TMSXPalette;
  n: Integer;
begin
  Clear;
  n := AStream.Read(&pal[0], 32);
  while n = 32 do
  begin
    Add(pal);
    n := AStream.Read(&pal[0], 32);
  end;
  Result := True;
end;

{ TScreen8Color }

class function TScreen8Color.Create(R, G, B: Byte): TScreen8Color;
begin
  Result.SetRGB(R, G, B);
end;

class function TScreen8Color.Create(AColor16: TColor16): TScreen8Color;
begin
  Result.R := AColor16.R shr 2;
  Result.G := AColor16.G shr 2;
  Result.B := AColor16.B shr 2;
end;

class function TScreen8Color.Create(AColor32: TColor32): TScreen8Color;
begin
  Result.Color32 := AColor32;
end;

function TScreen8Color.GetB: Byte;
begin
  Result := ((Value and 3) shl 1) or ((Value shr 1) and 1);
end;

function TScreen8Color.GetColor32: TColor32;
begin
  Result.R := (R shl 5) or (R shl 2) or (R shr 1);
  Result.G := (G shl 5) or (G shl 2) or (G shr 1);
  Result.B := (B shl 5) or (B shl 2) or (B shr 1);
  Result.A := 255;
end;

function TScreen8Color.GetG: Byte;
begin
  Result := Value shr 5;
end;

function TScreen8Color.GetR: Byte;
begin
  Result := (Value shr 2) and 7;
end;

procedure TScreen8Color.SetB(AValue: Byte);
begin
  Value := (Value and $FC) or ((AValue and 7) shr 1);
end;

procedure TScreen8Color.SetColor32(AValue: TColor32);
begin
  R := AValue.R shr 5;
  G := AValue.G shr 5;
  B := AValue.B shr 5;
end;

procedure TScreen8Color.SetG(AValue: Byte);
begin
  Value := (Value and $1F) or ((AValue and 7) shl 5);
end;

procedure TScreen8Color.SetR(AValue: Byte);
begin
  Value := (Value and $E3) or ((AValue and 7) shl 2);
end;

procedure TScreen8Color.SetRGB(R, G, B: Byte);
begin
  Self.R := R;
  Self.G := G;
  Self.B := B;
end;

{ TMSXSpriteAttr }

function TMSXSpriteAttr.GetColor: Byte;
begin
  Result := Attr and 15;
end;

function TMSXSpriteAttr.GetEC: Boolean;
begin
  Result := (Attr and $80) <> 0;
end;

procedure TMSXSpriteAttr.SetColor(const AValue: Byte);
begin
  Attr := (Attr and $F0) or AValue;
end;

procedure TMSXSpriteAttr.SetEC(const AValue: Boolean);
begin
  if AValue then
    Attr := Attr or $80
  else Attr := Attr and $7F;
end;

initialization
  TMSXPicture.MakeScreen8Palette;

finalization
  SetLength(TMSXPicture.Screen8Palette, 0);

end.
