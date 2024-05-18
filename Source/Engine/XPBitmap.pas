unit XPBitmap;

interface

uses
  {$IFDEF Win32} XPEngine32, {$ELSE} XPEngine64, {$ENDIF}
  XPRoutine, XPCPU, XPList, XPStream, XPObject, GdiPlus, BitBusterStream,
  Classes, Windows, Vcl.Graphics, Types, Math, SysUtils, Vcl.Dialogs,
  Vcl.Imaging.Jpeg, Vcl.Imaging.GifImg, Vcl.Imaging.PNGImage, UITypes;

type
  TXPDrawMode = (xdmOpaque, xdmAlpha, xdmMono, xdmPalette);
  TXPDrawModeEx = (
    xdmxOpaque, xdmxAlpha, xdmxMono, xdmxPalette,
    xdmxOpaqueEx, xdmxAlphaEx, xdmxMonoEx, xdmxPaletteEx
  );

  TXPPalette = class
  private
    FPaletteItems: array of TColor32;
    FCount: Integer;
    function GetPaletteTable: PColor32Array;
    function GetItems(AIndex: Integer): TColor32;
    procedure SetItems(AIndex: Integer; AColor: TColor32);
    procedure SetCount(n: Integer);
  public
    property PaletteTable: PColor32Array read GetPaletteTable;
    property Items[AIndex: Integer]: TColor32 read GetItems write SetItems; default;
    property Count: Integer read FCount write SetCount;
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Assign(APal: TXPPalette);
  end;

  TXPBitmap = class;

  TXPCanvas = class(TXPObject)
  private
    FCanvas: TCanvas;
    FXOrigin, FYOrigin, FWidth, FHeight: Integer;
    FBitmap: TXPBitmap;
    procedure CanvasChanged(Sender: TObject);
  protected
    procedure SetCanvas(ACanvas: TCanvas);
  public
    constructor Create; overload; override;
    constructor Create(ACanvas: TCanvas); reintroduce; overload;
    destructor Destroy; override;
    procedure Assign(AObject: TXPObject); override;
    property Canvas: TCanvas read FCanvas write SetCanvas;
    property Bitmap: TXPBitmap read FBitmap;
    property XOrigin: Integer read FXOrigin;
    property YOrigin: Integer read FYOrigin;
    property Width: Integer read FWidth;
    property Height: Integer read FHeight;
  end;

  TXPDrawParam = record
    XOffset, YOffset: Integer;
    SrcWidth, SrcHeight, DestWidth, DestHeight: Integer;
    FlipX, FlipY: Boolean;
//    SrcRect: TRect;
  end;

  TXPGraphic = class(TXPObject)
  protected
    FWidth, FHeight: Integer;
    FClipRect, FPaintRect, FDrawClipRect, FDrawPaintRect, FDefaultClipRect: TRect;

    function Draw(gbm: TXPBitmap; px, py: Integer): Boolean; overload; virtual;
    function Draw(gbm: TXPBitmap; px, py: Integer; AMode: TXPDrawMode): Boolean; overload; virtual;
    function Draw(gbm: TXPBitmap; drect: TRect): Boolean; overload; virtual;
    function Draw(gbm: TXPBitmap; drect: TRect; AMode: TXPDrawMode): Boolean; overload; virtual;

    procedure SetWidth(AWidth: Integer); virtual;
    procedure SetHeight(AHeight: Integer); virtual;
    procedure SetClipRect(ARect: TRect);
    procedure SetClipLeft(n: Integer);
    procedure SetClipTop(n: Integer);
    procedure SetClipRight(n: Integer);
    procedure SetClipBottom(n: Integer);
    procedure SetPaintRect(ARect: TRect);
    procedure ChangedSize; virtual;
  public
    FlipX, FlipY: Boolean;
    CopyMode: TXPDrawMode;
    constructor Create; override;
    procedure SetSize(AWidth, AHeight: Integer); virtual;
    procedure Assign(AGraphic: TXPGraphic); reintroduce;
    function GetDrawParam(ABitmap: TXPBitmap; var ARect: TRect; var AParam: TXPDrawParam): Boolean;
    property Width: Integer read FWidth write SetWidth;
    property Height: Integer read FHeight write SetHeight;
    property DrawClipRect: TRect read FDrawClipRect;
    property DrawPaintRect: TRect read FDrawPaintRect;
    property ClipRect: TRect read FClipRect write SetClipRect;
    property ClipLeft: Integer read FClipRect.Left write SetClipLeft;
    property ClipTop: Integer read FClipRect.Top write SetClipTop;
    property ClipRight: Integer read FClipRect.Right write SetClipRight;
    property ClipBottom: Integer read FClipRect.Bottom write SetClipBottom;
    property PaintRect: TRect read FPaintRect write SetPaintRect;
  end;

  TXPBitmap = class(TXPGraphic)
  private
    FHDC: HDC;
    FHandle: HBITMAP;
    FCanvas: TCanvas;
    FSurface: PColor32Array;
    FBitmapInfo: TBitmapInfo;
    FAlphaValue, FCopyAlphaValue: Integer;
    FPalette: TXPPalette;
    function GetCanvas: TCanvas;
    procedure SetAlphaValue(AValue: Integer);
    procedure SetCopyAlphaValue(AValue: Integer);
    function GetScanLine(py: Integer): PColor32Array;
    function GetPixels(px, py: Integer): TColor32;
    procedure SetPixels(px, py: Integer; c32: TColor32);
    function GetAlphaPixels(px, py: Integer): Integer;
    procedure SetAlphaPixels(px, py: Integer; a: Integer);
    function GetPaletteCount: Integer;
    procedure SetPaletteCount(Amount: Integer);
    function GetDrawModeEx: TXPDrawModeEx;
    function FetchDrawModeEx(AMode: TXPDrawMode; Alpha: Integer): TXPDrawModeEx;
  protected
    function Draw(gbm: TXPBitmap; px, py: Integer): Boolean; overload; override;
    function Draw(gbm: TXPBitmap; px, py: Integer; AMode: TXPDrawMode): Boolean; overload; override;
    function Draw(gbm: TXPBitmap; drect: TRect): Boolean; overload; override;
    function Draw(ABitmap: TXPBitmap; ARect: TRect; AMode: TXPDrawMode): Boolean; overload; override;

    procedure DrawTile(gbm: TXPBitmap; AMode: TXPDrawMode; px: Integer = 0; py: Integer = 0); overload;
    procedure DrawTile(gbm: TXPBitmap; drect: TRect; AMode: TXPDrawMode; px: Integer = 0; py: Integer = 0); overload;

    procedure ChangedSize; override;
  public
    PenX, PenY: Integer;
    DrawMode: TXPDrawMode;
    SourceMode: Boolean;
    BrushColor, MonoColor: TColor32;
    constructor Create; overload; override;
    constructor Create(AFileName: string); reintroduce; overload;
    destructor Destroy; override;
    procedure Clear; override;
    procedure Assign(ABitmap: TXPBitmap); reintroduce;
    procedure AssignTo(ABitmap: TBitmap);
    procedure DeleteCanvas;
    procedure ClearClipRect;
    procedure ClearPaintRect;
    procedure ClearFlip;
    function CanvasAllocated: Boolean;
    function GetPalette(AIndex: Integer): TColor32;
    procedure SetPalette(AIndex: Integer; AColor: TColor32);
    function PaletteTable: PColor32;
    procedure CreatePalette(APalette: TXPPalette);

    function Draw(x1, y1: Integer; grp: TXPGraphic): Boolean; overload;
    function Draw(x1, y1: Integer; grp: TXPGraphic; AMode: TXPDrawMode): Boolean; overload;
    function Draw(drect: TRect; grp: TXPGraphic): Boolean; overload;
    function Draw(drect: TRect; grp: TXPGraphic; AMode: TXPDrawMode): Boolean; overload;

    procedure DrawTile(px, py: Integer; gbm: TXPBitmap); overload;
    procedure DrawTile(px, py: Integer; gbm: TXPBitmap; AMode: TXPDrawMode); overload;
    procedure DrawTile(px, py: Integer; gbm: TXPBitmap; drect: TRect); overload;
    procedure DrawTile(px, py: Integer; gbm: TXPBitmap; drect: TRect; AMode: TXPDrawMode); overload;

    procedure Draw(px, py: Integer; DrawStr: string; AMul, ADiv, Angle: Integer); overload;

    procedure Draw(ACanvas: TCanvas; px, py: Integer); overload;
    procedure Draw(ACanvas: TCanvas; px, py: Integer; AMode: TXPDrawMode); overload;
    procedure Draw(ACanvas: TCanvas; ARect: TRect); overload;

    procedure Draw(ACanvas: TXPCanvas; px, py: Integer); overload;
    procedure Draw(ACanvas: TXPCanvas; px, py: Integer; AMode: TXPDrawMode); overload;

    procedure DrawSmooth(ACanvas: TCanvas; ARect: TRect);

    function CopyRect(drect: TRect; gbm: TXPBitmap; srect: TRect): Boolean; overload;
    function CopyRect(drect: TRect; gbm: TXPBitmap; srect: TRect; AMode: TXPDrawMode): Boolean; overload;
    function ReplaceRect(gbm: TXPBitmap; srect: TRect): Boolean; overload;
    function ReplaceRect(gbm: TXPBitmap; srect: TRect; AMode: TXPDrawMode): Boolean; overload;

    function PenPos: TPoint;
    function InClipRect(px, py: Integer): Boolean; overload;
    function InClipRect(APoint: TPoint): Boolean; overload;
    function InDrawClipRect(px, py: Integer): Boolean; overload;
    function InDrawClipRect(APoint: TPoint): Boolean; overload;
    procedure PutPixel(px, py: Integer); overload;
    procedure PutPixel(px, py: Integer; AMode: TXPDrawMode); overload;
    procedure PutPixel(px, py: Integer; c32: TColor32); overload;
    procedure PutPixel(px, py: Integer; c32: TColor32; AMode: TXPDrawMode); overload;
    procedure MoveTo(px, py: Integer); overload;
    procedure MoveTo(APoint: TPoint); overload;
    procedure LineTo(qx, qy: Integer); overload;
    procedure LineTo(qx, qy: Integer; AMode: TXPDrawMode); overload;
    procedure LineTo(APoint: TPoint); overload;
    procedure LineTo(APoint: TPoint; AMode: TXPDrawMode); overload;
    procedure HLineTo(px: Integer); overload;
    procedure HLineTo(px: Integer; AMode: TXPDrawMode); overload;
    procedure VLineTo(py: Integer); overload;
    procedure VLineTo(py: Integer; AMode: TXPDrawMode); overload;
    procedure FrameRect(x1, y1, x2, y2: Integer); overload;
    procedure FrameRect(x1, y1, x2, y2: Integer; AMode: TXPDrawMode); overload;
    procedure FrameRect(rect: TRect); overload;
    procedure FrameRect(rect: TRect; AMode: TXPDrawMode); overload;
    procedure FillRect; overload;
    procedure FillRect(AMode: TXPDrawMode); overload;
    procedure FillRect(x1, y1, x2, y2: Integer); overload;
    procedure FillRect(x1, y1, x2, y2: Integer; AMode: TXPDrawMode); overload;
    procedure FillRect(rect: TRect); overload;
    procedure FillRect(rect: TRect; AMode: TXPDrawMode); overload;
    procedure Circle(px, py, r: Integer); overload;
    procedure Circle(px, py, r: Integer; AMode: TXPDrawMode); overload;
    procedure FillCircle(px, py, r: Integer); overload;
    procedure FillCircle(px, py, r: Integer; AMode: TXPDrawMode); overload;

    procedure TextOutLine(x, y: Integer; text: string; fc, bc: TColor);
    procedure TextSmooth(x, y: Integer; text: string; fc, bc: TColor; thick: Integer = 1);

    procedure LoadAlpha(gbm: TXPBitmap);

    procedure ReadFromStream(AStream: TStream); override;
    procedure WriteToStream(AStream: TStream); override;

    procedure LoadFromBitmap(ABitmap: TBitmap; AAlpha: TBitmap = nil); virtual;

    function LoadFromExt(AStream: TStream; AFileName: string): Integer;
    procedure LoadFromBMP(AStream: TStream);
    procedure LoadFromJPG(AStream: TStream);
    procedure LoadFromPNG(AStream: TStream);
    procedure LoadFromGIF(AStream: TStream);
    procedure LoadFromG9B(AStream: TStream);

    procedure LoadFromFile(AFileName: string); overload; override;
    procedure LoadFromFile(AFileName, AlphaName: string); reintroduce; overload; virtual;
    
    procedure SaveToFile(fname: string); override;
    
    class procedure LoadSupports(AList: TXPFileSupportList); override;

    property DefaultClipRect: TRect read FDefaultClipRect;
    property AlphaValue: Integer read FAlphaValue write SetAlphaValue;
    property CopyAlphaValue: Integer read FCopyAlphaValue write SetCopyAlphaValue;
    property Canvas: TCanvas read GetCanvas;
    property Handle: HDC read FHDC;
    property BitmapHandle: HBITMAP read FHandle;
    property BitmapInfo: TBitmapInfo read FBitmapInfo;
    property Surface: PColor32Array read FSurface;
    property ScanLine[y: Integer]: PColor32Array read GetScanLine;
    property Pixels[px, py: Integer]: TColor32 read GetPixels write SetPixels;
    property AlphaPixels[px, py: Integer]: Integer read GetAlphaPixels write SetAlphaPixels;
    property DrawModeEx: TXPDrawModeEx read GetDrawModeEx;
    property Palette: TXPPalette read FPalette;
    property PaletteCount: Integer read GetPaletteCount write SetPaletteCount;
  end;

  TXPBitmapList = class(TXPList)
  private
    function GetBitmaps(n: Integer): TXPBitmap;
  public
    constructor Create; override;
    constructor Create(AFileName: string); reintroduce; overload;
    function AddBitmap: TXPBitmap; reintroduce;
    function AddFromFile(fname: string): TXPBitmap; virtual;
    function CreateItem: TXPObject; override;
    procedure ReadFromStream(AStream: TStream); override;
    procedure WriteToStream(AStream: TStream); override;
    procedure LoadFromFile(AFileName: string); override;
    procedure SaveToFile(AFileName: string); override;
    class procedure LoadSupports(AList: TXPFileSupportList); override;
    property Bitmaps[n: Integer]: TXPBitmap read GetBitmaps; default;
  end;

  TG9BHeader = packed record
    Signature: array[0..2] of AnsiChar; // "G9B"
    ChunkSize: Word;     // 11
  end;
  TG9BChunk = packed record
    BitDepth: Byte;       // 2, 4, 8, 16
    ColorType: Byte;      // 0 = 64 colors with pal, 64 = 256 colors, 128 = YJK, 192 = YUV
    PalCount: Byte;       // Palette count
    Width, Height: Word;
    Compression: Byte;    // 1 = Bitbuster compression
    DataSize: TUInt24;     // 24 bit
  end;
  TG9BPalEntry = packed record
    R, G, B: Byte;
  end;

implementation

// TXPPalette
constructor TXPPalette.Create;
begin
  Clear;
end;

destructor TXPPalette.Destroy;
begin
  Clear;
  inherited Destroy;
end;

procedure TXPPalette.Clear;
begin
  SetLength(FPaletteItems, 0);
  FCount := 0;
end;

procedure TXPPalette.Assign(APal: TXPPalette);
var
  n: Integer;
begin
  Count := APal.Count;
  for n := 0 to FCount - 1 do
  begin
    FPaletteItems[n] := APal[n];
  end;
end;

function TXPPalette.GetPaletteTable: PColor32Array;
begin
  if Length(FPaletteItems) > 0 then
    Result := @FPaletteItems[0]
  else Result := nil;
end;

function TXPPalette.GetItems(AIndex: Integer): TColor32;
begin
  if (AIndex >= 0) and (AIndex < FCount) then
    Result := FPaletteItems[AIndex]
  else Result.BGRA := AIndex;
end;

procedure TXPPalette.SetItems(AIndex: Integer; AColor: TColor32);
begin
  try
    FPaletteItems[AIndex] := AColor
  except
    raise Exception.Create('Palette index out of bound');
  end;
end;

procedure TXPPalette.SetCount(n: Integer);
begin
  SetLength(FPaletteItems, n);
  while FCount < n do
  begin
    FPaletteItems[FCount].BGRA := 0;
    Inc(FCount);
  end;
  FCount := n;
end;

// TXPBitmap
constructor TXPBitmap.Create;
begin
  inherited Create;
  FillChar(FBitmapInfo, SizeOf(TBitmapInfo), 0);
  with FBitmapInfo.bmiHeader do
  begin
    biSize := SizeOf(TBitmapInfoHeader);
    biPlanes := 1;
    biBitCount := 32;
    biCompression := BI_RGB;
  end;
  FSurface := nil;
  FCanvas := nil;
  FHandle := 0;
  FHDC := 0;
  PenX := 0;
  PenY := 0;
  FAlphaValue := 255;
  FCopyAlphaValue := 255;
  DrawMode := xdmOpaque;
  SourceMode := True;
  BrushColor := c32Black;
  MonoColor := c32White;
  FPalette := nil;
end;

destructor TXPBitmap.Destroy;
begin
  SetSize(0, 0);
  if Assigned(FPalette) then FPalette.Free;
  inherited Destroy;
end;

procedure TXPBitmap.Assign(ABitmap: TXPBitmap);
begin
  ReplaceRect(ABitmap, ABitmap.DefaultClipRect);
end;

procedure TXPBitmap.ChangedSize;
var
  w, h: Integer;
begin
  DeleteCanvas;
  if FHDC <> 0 then
  begin
    DeleteDC(FHDC);
    FHDC := 0;
  end;
  if FHandle <> 0 then
  begin
    DeleteObject(FHandle);
    FHandle := 0;
  end;
  FSurface := nil;
  w := FWidth;
  h := FHeight;
  FWidth := 0;
  FHeight := 0;
  if (w > 0) and (h > 0) then
  begin
    with FBitmapInfo.bmiHeader do
    begin
      biWidth := w;
      biHeight := -h;
    end;
    FHandle := CreateDIBSection(0, FBitmapInfo, DIB_RGB_COLORS, Pointer(FSurface), 0, 0);
    if FSurface = nil then raise Exception.Create('Can''t allocate the DIB handle');
    FHDC := CreateCompatibleDC(0);
    if FHDC = 0 then
    begin
      DeleteObject(FHandle);
      FHandle := 0;
      FSurface := nil;
      raise Exception.Create('Can''t create compatible DC');
    end;
    if SelectObject(FHDC, FHandle) = 0 then
    begin
      DeleteDC(FHDC);
      DeleteObject(FHandle);
      FHDC := 0;
      FHandle := 0;
      FSurface := nil;
      raise Exception.Create('Can''t select an object into DC');
    end;
  end;
  FWidth := w;
  FHeight := h;
  inherited;
end;

procedure TXPBitmap.SetAlphaValue(AValue: Integer);
begin
  FAlphaValue := IntInside(AValue, 0, 255);
end;

function TXPBitmap.GetScanLine(py: Integer): PColor32Array;
begin
  Result := @FSurface[py * FWidth];
end;

function TXPBitmap.GetPixels(px, py: Integer): TColor32;
begin
  Result := FSurface[py * FWidth + px];
end;

procedure TXPBitmap.SetPixels(px, py: Integer; c32: TColor32);
begin
  FSurface[py * FWidth + px] := c32;
end;

function TXPBitmap.GetAlphaPixels(px, py: Integer): Integer;
begin
  Result := FSurface[py * FWidth + px].A;
end;

procedure TXPBitmap.SetAlphaPixels(px, py: Integer; a: Integer);
begin
  FSurface[py * FWidth + px].A := a;
end;

function TXPBitmap.GetPaletteCount: Integer;
begin
  if Assigned(FPalette) then
    Result := FPalette.Count
  else Result := 0;
end;

procedure TXPBitmap.SetPaletteCount(Amount: Integer);
begin
  if not Assigned(FPalette) then FPalette := TXPPalette.Create;
  FPalette.Count := AMount;
end;

function TXPBitmap.GetDrawModeEx: TXPDrawModeEx;
begin
  Result := FetchDrawModeEx(DrawMode, FAlphaValue);
end;

function TXPBitmap.FetchDrawModeEx(AMode: TXPDrawMode; Alpha: Integer): TXPDrawModeEx;
begin
  if Alpha < 255 then
    Result := TXPDrawModeEx(Ord(AMode) + Ord(xdmxOpaqueEx))
  else Result := TXPDrawModeEx(Amode);
end;

function TXPBitmap.GetCanvas: TCanvas;
begin
  if not Assigned(FCanvas) then
  begin
    FCanvas := TCanvas.Create;
    FCanvas.Handle := FHDC;
  end;
  Result := FCanvas;
end;

procedure TXPBitmap.AssignTo(ABitmap: TBitmap);
var
  ny: Integer;
  sptr, dptr: PColor32Array;
begin
  ABitmap.PixelFormat := pf32bit;
  ABitmap.SetSize(FWidth, FHeight);
  for ny := 0 to FHeight - 1 do
  begin
    sptr := ScanLine[ny];
    dptr := ABitmap.ScanLine[ny];
    Move(sptr[0], dptr[0], FWidth shl 2);
  end;
end;

function TXPBitmap.CanvasAllocated: Boolean;
begin
  Result := FCanvas <> nil;
end;

procedure TXPBitmap.DeleteCanvas;
begin
  if FCanvas <> nil then
  begin
    FCanvas.Handle := 0;
    FCanvas.Free;
    FCanvas := nil;
  end;
end;

function TXPBitmap.GetPalette(AIndex: Integer): TColor32;
begin
  Result.BGRA := AIndex;
  if Assigned(FPalette) then
  begin
    if (AIndex >= 0) and (AIndex < FPalette.Count) then Result := FPalette[AIndex];
  end;
end;

procedure TXPBitmap.SetPalette(AIndex: Integer; AColor: TColor32);
begin
  if Assigned(FPalette) then
  begin
    if (AIndex >= 0) and (AIndex < FPalette.Count) then FPalette[AIndex] := AColor;
  end;
end;

function TXPBitmap.PaletteTable: PColor32;
begin
  if Assigned(FPalette) then
    Result := PColor32(FPalette.PaletteTable)
  else Result := nil;
end;

constructor TXPBitmap.Create(AFileName: string);
begin
  Create;
  LoadFromFile(AFileName);
end;

procedure TXPBitmap.CreatePalette(APalette: TXPPalette);
begin
  if not Assigned(FPalette) then FPalette := TXPPalette.Create;
  FPalette.Assign(APalette);
end;

procedure TXPBitmap.Clear;
begin
  inherited;
  SetSize(0, 0);
  if Assigned(FPalette) then FreeAndNil(FPalette);
  PenX := 0;
  PenY := 0;
  FlipX := False;
  FlipY := False;
  FAlphaValue := 255;
  FCopyAlphaValue := 255;
  DrawMode := xdmOpaque;
  CopyMode := xdmOpaque;
  SourceMode := True;
  BrushColor := c32Black;
  MonoColor := c32White;
end;

procedure TXPBitmap.ClearClipRect;
begin
  FClipRect := DefaultClipRect;
  FDrawClipRect := DefaultClipRect;
end;

procedure TXPBitmap.ClearPaintRect;
begin
  FPaintRect := FDefaultClipRect;
  FDrawPaintRect := FDefaultClipRect;
end;

procedure TXPBitmap.ClearFlip;
begin
  FlipX := False;
  FlipY := False;
end;

procedure TXPBitmap.Draw(ACanvas: TCanvas; px: Integer; py: Integer);
begin
  Draw(ACanvas, px, py, CopyMode);
end;

procedure TXPBitmap.Draw(ACanvas: TCanvas; px, py: Integer; AMode: TXPDrawMode);
var
  blendFn: BLENDFUNCTION;
  drect: TRect;
  w, h: Integer;
begin
  if not Assigned(ACanvas) then Exit;
  ACanvas.Lock;
  try
    w := FDrawPaintRect.Right - FDrawPaintRect.Left;
    h := FDrawPaintRect.Bottom - FDrawPaintRect.Top;
    drect.TopLeft := Point(px, py);
    drect.BottomRight := Point(px + w, py + h);
    if (AMode = xdmOpaque) and (FCopyAlphaValue = 255) then
      BitBlt(ACanvas.Handle, px, py, w, h, FHDC, FDrawPaintRect.Left, FDrawPaintRect.Top, SRCCOPY)
    else
    begin
      blendFn.BlendOp := AC_SRC_OVER;
      blendFn.BlendFlags := 0;
      blendFn.SourceConstantAlpha := FCopyAlphaValue;
      if AMode = xdmOpaque then
        blendFn.AlphaFormat := 0
      else blendFn.AlphaFormat := AC_SRC_ALPHA;
      Windows.AlphaBlend(ACanvas.Handle, px, py, w, h, FHDC, FDrawPaintRect.Left, FDrawPaintRect.Top, w, h, blendFn);
    end;
  finally
    ACanvas.Unlock;
  end;
end;

procedure TXPBitmap.Draw(ACanvas: TCanvas; ARect: TRect);
begin
  ACanvas.Lock;
  try
    StretchBlt(ACanvas.Handle, ARect.Left, ARect.Top, ARect.Right - ARect.Left, ARect.Bottom - ARect.Top, FHDC, 0, 0, FWidth, FHeight, SRCCOPY);
  finally
    ACanvas.Unlock;
  end;
end;

procedure TXPBitmap.Draw(ACanvas: TXPCanvas; px, py: Integer);
begin
  Draw(ACanvas, px, py, CopyMode);
end;

procedure TXPBitmap.Draw(ACanvas: TXPCanvas; px, py: Integer;
  AMode: TXPDrawMode);
begin
  Draw(ACanvas.Bitmap, px - ACanvas.XOrigin, py - ACanvas.YOrigin, AMode);
  Draw(ACanvas.Canvas, px, py, Amode);
end;

procedure TXPBitmap.DrawSmooth(ACanvas: TCanvas; ARect: TRect);
var
  grp: IGPGraphics;
//  brush: IGPBrush;
  bm: IGPBitmap;
begin
  ACanvas.Lock;
  try
    try
      grp := TGPGraphics.Create(ACanvas.Handle);
      bm := TGPBitmap.Create(FHandle, 0);
//      brush := TGPSolidBrush.Create(TGPColor.Create(BrushColor.A, BrushColor.R, BrushColor.G, BrushColor.B));
//      grp.FillRectangle(brush, TGPRect.Create(ARect));
      grp.DrawImage(bm, TGPRect.Create(ARect));
    finally
//      brush := nil;
      bm := nil;
      grp := nil;
    end;
  finally
    ACanvas.Unlock;
  end;
end;

function TXPBitmap.Draw(x1, y1: Integer; grp: TXPGraphic): Boolean;
begin
  if SourceMode then
    Result := grp.Draw(Self, x1, y1, grp.CopyMode)
  else Result := grp.Draw(Self, x1, y1, DrawMode);
end;

function TXPBitmap.Draw(x1, y1: Integer; grp: TXPGraphic; AMode: TXPDrawMode): Boolean;
begin
  Result := grp.Draw(Self, x1, y1, AMode);
end;

function TXPBitmap.Draw(drect: TRect; grp: TXPGraphic): Boolean;
begin
  if SourceMode then
    Result := grp.Draw(Self, drect, grp.CopyMode)
  else Result := grp.Draw(Self, drect, DrawMode);
end;

function TXPBitmap.Draw(drect: TRect; grp: TXPGraphic; AMode: TXPDrawMode): Boolean;
begin
  Result := grp.Draw(Self, drect, AMode);
end;

function TXPBitmap.CopyRect(drect: TRect; gbm: TXPBitmap; srect: TRect): Boolean;
begin
  if SourceMode then
    Result := CopyRect(drect, gbm, srect, gbm.CopyMode)
  else Result := CopyRect(drect, gbm, srect, DrawMode);
end;

function TXPBitmap.CopyRect(drect: TRect; gbm: TXPBitmap; srect: TRect; AMode: TXPDrawMode): Boolean;
begin
  gbm.ClipRect := srect;
  Result := Draw(drect, gbm, AMode);
end;

function TXPBitmap.ReplaceRect(gbm: TXPBitmap; srect: TRect): Boolean;
begin
  if SourceMode then
    Result := ReplaceRect(gbm, srect, gbm.CopyMode)
  else Result := ReplaceRect(gbm, srect, DrawMode);
end;

function TXPBitmap.ReplaceRect(gbm: TXPBitmap; srect: TRect; AMode: TXPDrawMode): Boolean;
begin
  SetSize(0, 0);
  SetSize(srect.Right - srect.Left, srect.Bottom - srect.Top);
  Result := CopyRect(FClipRect, gbm, srect, AMode);
end;

(***********************************************************************
  Draw --- Draw set of command at (px, py)
  Draw --- Draw with scale AMul/ADiv, Angle degree
    Format:
      ( = disable pen
	    ) = enable pen
  	  [ = push (x,y)
	    ] = pop (x,y)
  	  m?x? = line rel (example m-5x20)
  	  m?y? = rec rel
  	  m?z? = bar rel
  	  a? = circle (data is radius)
  	  b? = fill circle
  	  c? = color (start by = 15)
  	  u?,e?,r?,f?,d?,g?,l?,h? = up,right-up,right,...,left-up
    Remark: ? = decimal number data
***********************************************************************)
procedure TXPBitmap.Draw(px, py: Integer; DrawStr: string; AMul, ADiv, Angle: Integer);
var
  i, x0, y0, dx, dy: Integer;
  sinr, cosr: Extended;
  data, c: Char;
  pen, s: Boolean;
  stack: TXPIntegerList;
begin
  stack := TXPIntegerList.Create;
  try
    pen := True;
    sinr := 0.0;
    cosr := 0.0;
    dx := 0;
    dy := 0;
    s := False;
    if DrawStr = '' then Exit;
    if Angle > 0 then
    begin
      sinr := Angle * Pi / 180;
    	cosr := cos(sinr);
    	sinr := sin(sinr);
    end;
    x0 := px;
    y0 := py;
    while Length(DrawStr) > 0 do
    begin
      data := DrawStr[1];
      Delete(DrawStr, 1, 1);
      case data of
        '(': pen := False;
      	')': pen := True;
        '[':
        begin
          stack.Put(px);
          stack.Put(py);
        end;
        ']':
        begin
          py := stack.Pop;
          px := stack.Pop;
          x0 := px;
          y0 := py;
        end;
      else
      	if Copy(DrawStr, 1, 1) = '-' then
        begin
          Delete(DrawStr, 1, 1);
          s := True;
        end;
        i := 0;
        if Length(DrawStr) > 0 then
          c := DrawStr[1]
        else c := #0;
        while (c >= '0') and (c <= '9') do
        begin
          i := i + (i shl 3) + i + Ord(c) - Ord('0');
          Delete(DrawStr, 1, 1);
          if Length(DrawStr) > 0 then
            c := DrawStr[1]
          else c := #0;
        end;
      	if data = 'c' then
          BrushColor.BGRA := i
        else
        begin
          if s then
          begin
            i := -i;
            s := False;
          end;
        	if AMul <> ADiv then i := i * AMul div ADiv;
        	if data = 'm' then
            x0 := x0 + i
          else
          begin
          	if Pos(data, 'uhe') > 0 then y0 := y0 - i;
          	if Pos(data, 'ref') > 0 then x0 := x0 + i;
          	if Pos(data, 'dfgxyz') > 0 then y0 := y0 + i;
          	if Pos(data, 'lgh') > 0 then x0 := x0 - i;
          	if Angle <> 0 then
            begin
              dx := x0 - px;
              dy := y0 - py;
         	    x0 := Round(px + dx * cosr - dy * sinr);
         	    y0 := Round(py + dx * sinr + dy * cosr);
            end;
          	if pen then case data of
          	  'y':
              begin
            		if Angle <> 0 then
                begin
                  dx := Round(dx * cosr);
                  dy := Round(dy * cosr);
                  MoveTo(px, py);
          		    LineTo(px + dx, y0 - dy);
          		    LineTo(x0, y0);
          		    LineTo(x0 - dx, py + dy);
          		    LineTo(px, py);
                end
                else FillRect(px, py, x0, y0);
              end;
        	    'z':
              begin
            		if Angle <> 0 then
                begin
  //        		    triangle(x, y, x0, y0, x + (dx *= cosr), y0 - (dy *= cosr), color);
  //        		    triangle(x, y, x0, y0, x0 - dx, y + dy, color);
                end
                else FrameRect(px, py, x0, y0);
              end;
         	    'a': Circle(px, py, i);
          	  'b': FillCircle(px, py, i);
            else
              MoveTo(px, py);
          	  LineTo(x0, y0);
            end;
          	px := x0;
          	py := y0;
          end;
        end;
      end;
    end;
  finally
    stack.Free;
  end;
end;

procedure TXPBitmap.DrawTile(gbm: TXPBitmap; AMode: TXPDrawMode; px: Integer = 0; py: Integer = 0);
begin
  DrawTile(gbm, gbm.ClipRect, AMode, px, py);
end;

procedure TXPBitmap.DrawTile(gbm: TXPBitmap; drect: TRect; AMode: TXPDrawMode; px: Integer = 0; py: Integer = 0);
var
  nx: Integer;
begin
  if (FWidth = 0) or (FHeight = 0) then Exit;
  if CropRect(drect, gbm.DefaultClipRect) then
  begin
    px := drect.Left - AbsoluteMod(px, FWidth);
    py := drect.Top - AbsoluteMod(py, FHeight);
    while py < drect.Bottom do
    begin
      nx := px;
      while nx < drect.Right do
      begin
        Draw(gbm, nx, py, AMode);
        nx := nx + FWidth;
      end;
      py := py + FHeight;
    end;
  end;
end;

function TXPBitmap.Draw(gbm: TXPBitmap; px, py: Integer): Boolean;
begin
  if gbm.SourceMode then
    Result := Draw(gbm, px, py, CopyMode)
  else Result := Draw(gbm, px, py, gbm.DrawMode);
end;

function TXPBitmap.Draw(gbm: TXPBitmap; px, py: Integer; AMode: TXPDrawMode): Boolean;
var
  difx, dify, xoffs, yoffs: Integer;
  ptr1, ptr2: PColor32;
  dmode: TXPDrawModeEx;
  sgbm: TXPBitmap;
  srect: TRect;
begin
  Result := False;
  if not Assigned(gbm) then Exit;
  difx := FWidth;
  dify := FHeight;
  if difx > FDrawClipRect.Right then difx := FDrawClipRect.Right;
  if dify > FDrawClipRect.Bottom then dify := FDrawClipRect.Bottom;
  difx := difx - FDrawClipRect.Left;
  dify := dify - FDrawClipRect.Top;
  if (difx <= 0) or (dify <= 0) or (gbm.Width <= 0) or (gbm.Height <= 0) then Exit;
  srect.TopLeft := Point(px, py);
  srect.BottomRight := Point(px + difx, py + dify);
  Result := CropRect(srect, gbm.DrawClipRect, xoffs, yoffs, FlipX, FlipY);
  xoffs := xoffs + FDrawClipRect.Left;
  yoffs := yoffs + FDrawClipRect.Top;
  if Result then
  begin
    if gbm.SourceMode then
      sgbm := Self
    else sgbm := gbm;
    dmode := FetchDrawModeEx(Amode, sgbm.AlphaValue);
    difx := srect.Right - srect.Left;
    try
      while srect.Top < srect.Bottom do
      begin
        ptr1 := @ScanLine[yoffs][xoffs];
        if FlipY then
        begin
          Dec(srect.Bottom);
          ptr2 := @gbm.ScanLine[srect.Bottom][srect.Left];
        end
        else
        begin
          ptr2 := @gbm.ScanLine[srect.Top][srect.Left];
          Inc(srect.Top);
        end;
        if TXPCPU.MMXEnabled then
        case dmode of
          xdmxOpaque: CopyColor(ptr1, ptr2, difx, FlipX);
          xdmxOpaqueEx: MMXCopyColor(ptr1, ptr2, difx, FlipX, sgbm.AlphaValue);
          xdmxAlpha: MMXCopyAlpha(ptr1, ptr2, difx, FlipX);
          xdmxAlphaEx: MMXCopyAlpha(ptr1, ptr2, difx, FlipX, sgbm.AlphaValue);
          xdmxMono: CopyMono(ptr1, ptr2, difx, FlipX, sgbm.MonoColor);
          xdmxMonoEx: CopyMono(ptr1, ptr2, difx, FlipX, sgbm.MonoColor, sgbm.AlphaValue);
          xdmxPalette: CopyAlphaPalette(ptr1, ptr2, difx, FlipX, sgbm.PaletteTable, sgbm.PaletteCount);
          xdmxPaletteEx: CopyAlphaPalette(ptr1, ptr2, difx, FlipX, sgbm.PaletteTable, sgbm.PaletteCount, sgbm.AlphaValue);
        end
        else case dmode of
          xdmxOpaque: CopyColor(ptr1, ptr2, difx, FlipX);
          xdmxOpaqueEx: CopyColor(ptr1, ptr2, difx, FlipX, sgbm.AlphaValue);
          xdmxAlpha: CopyAlpha(ptr1, ptr2, difx, FlipX);
          xdmxAlphaEx: CopyAlpha(ptr1, ptr2, difx, FlipX, sgbm.AlphaValue);
          xdmxMono: CopyMono(ptr1, ptr2, difx, FlipX, sgbm.MonoColor);
          xdmxMonoEx: CopyMono(ptr1, ptr2, difx, FlipX, sgbm.MonoColor, sgbm.AlphaValue);
          xdmxPalette: CopyAlphaPalette(ptr1, ptr2, difx, FlipX, sgbm.PaletteTable, sgbm.PaletteCount);
          xdmxPaletteEx: CopyAlphaPalette(ptr1, ptr2, difx, FlipX, sgbm.PaletteTable, sgbm.PaletteCount, sgbm.AlphaValue);
        end;
        Inc(yoffs);
      end;
    finally
      emms;
    end;
  end;
end;

function TXPBitmap.Draw(gbm: TXPBitmap; drect: TRect): Boolean;
begin
  if gbm.SourceMode then
    Result := Draw(gbm, drect, CopyMode)
  else Result := Draw(gbm, drect, gbm.DrawMode);
end;

function TXPBitmap.Draw(ABitmap: TXPBitmap; ARect: TRect; AMode: TXPDrawMode): Boolean;
var
  param: TXPDrawParam;
  ptr1, ptr2: PColor32;
  difx, dify, px, py: Integer;
//  xoffs, yoffs, difx0, dify0: Integer;
//  difxs, difys: Integer;
//  xflip, yflip: Boolean;
//  srect: TRect;
  dmode: TXPDrawModeEx;
  xbm: TXPBitmap;
begin
//  Result := False;
//  if not Assigned(ABitmap) then Exit;
//  difx0 := Min(FWidth, FDrawClipRect.Right) - FDrawClipRect.Left; // source draw width
//  dify0 := Min(FHeight, FDrawClipRect.Bottom) - FDrawClipRect.Top; // source draw height
//  difxs := ARect.Right - ARect.Left; // dest draw width
//  difys := ARect.Bottom - ARect.Top; // dest draw height
//  if (difx0 <= 0) or (dify0 <= 0)
//    or (difxs <= 0) or (difys <= 0)
//    or (ABitmap.Width <= 0) or (ABitmap.Height <= 0)
//  then Exit;
//  srect.TopLeft := ARect.TopLeft;
//  xflip := FlipX;
//  yflip := FlipY;
//  if difxs < 0 then
//  begin
//    difxs := -difxs;
//    srect.Left := srect.Left - difxs;
//    xflip := not xflip;
//  end;
//  if difys < 0 then
//  begin
//    difys := -difys;
//    srect.Top := srect.Top - difys;
//    yflip := not yflip;
//  end;
//  srect.BottomRight := Point(srect.Left + difxs, srect.Top + difys);
//  Result := CropRect(srect, ABitmap.ClipRect, xoffs, yoffs, xflip, yflip);
//  if Result then
//  begin
//    if ABitmap.SourceMode then
//      sgbm := Self
//    else sgbm := ABitmap;
//    dmode := FetchDrawModeEx(AMode, sgbm.AlphaValue);
//    px := xoffs * difx0 div difxs + FClipRect.Left;
//    py := yoffs * dify0 div difys + FClipRect.Top;
//    difx := srect.Right - srect.Left;
//    dify := difys - yoffs * dify0 mod difys - 1;
//    try
//      while srect.Top < srect.Bottom do
//      begin
//        ptr1 := @ScanLine[py][px];
//        if yflip then
//        begin
//          Dec(srect.Bottom);
//          ptr2 := @ABitmap.ScanLine[srect.Bottom][srect.Left];
//        end
//        else
//        begin
//          ptr2 := @ABitmap.ScanLine[srect.Top][srect.Left];
//          Inc(srect.Top);
//        end;
//        if TXPCPU.MMXEnabled then
//        case dmode of
//          xdmxOpaque: CopyColor(ptr1, ptr2, difx0, difxs, difx, xoffs, xflip);
//          xdmxOpaqueEx: MMXCopyColor(ptr1, ptr2, difx0, difxs, difx, xoffs, xflip, sgbm.AlphaValue);
//          xdmxAlpha: CopyAlpha(ptr1, ptr2, difx0, difxs, difx, xoffs, xflip);
//          xdmxAlphaEx: CopyAlpha(ptr1, ptr2, difx0, difxs, difx, xoffs, xflip, sgbm.AlphaValue);
//          xdmxMono: CopyMono(ptr1, ptr2, difx0, difxs, difx, xoffs, xflip, sgbm.MonoColor);
//          xdmxMonoEx: CopyMono(ptr1, ptr2, difx0, difxs, difx, xoffs, xflip, sgbm.MonoColor, sgbm.AlphaValue);
//          xdmxPalette: CopyAlphaPalette(ptr1, ptr2, difx0, difxs, difx, xoffs, xflip, sgbm.PaletteTable, sgbm.PaletteCount);
//          xdmxPaletteEx: CopyAlphaPalette(ptr1, ptr2, difx0, difxs, difx, xoffs, xflip, sgbm.PaletteTable, sgbm.PaletteCount, sgbm.AlphaValue);
//        end
//        else case dmode of
//          xdmxOpaque: CopyColor(ptr1, ptr2, difx0, difxs, difx, xoffs, xflip);
//          xdmxOpaqueEx: CopyColor(ptr1, ptr2, difx0, difxs, difx, xoffs, xflip, sgbm.AlphaValue);
//          xdmxAlpha: CopyAlpha(ptr1, ptr2, difx0, difxs, difx, xoffs, xflip);
//          xdmxAlphaEx: CopyAlpha(ptr1, ptr2, difx0, difxs, difx, xoffs, xflip, sgbm.AlphaValue);
//          xdmxMono: CopyMono(ptr1, ptr2, difx0, difxs, difx, xoffs, xflip, sgbm.MonoColor);
//          xdmxMonoEx: CopyMono(ptr1, ptr2, difx0, difxs, difx, xoffs, xflip, sgbm.MonoColor, sgbm.AlphaValue);
//          xdmxPalette: CopyAlphaPalette(ptr1, ptr2, difx0, difxs, difx, xoffs, xflip, sgbm.PaletteTable, sgbm.PaletteCount);
//          xdmxPaletteEx: CopyAlphaPalette(ptr1, ptr2, difx0, difxs, difx, xoffs, xflip, sgbm.PaletteTable, sgbm.PaletteCount, sgbm.AlphaValue);
//        end;
//        dify := dify - dify0;
//        while dify < 0 do
//        begin
//          Inc(py);
//          dify := dify + difys;
//        end;
//      end;
//    finally
//      emms;
//    end;
//  end;


  Result := GetDrawParam(ABitmap, ARect, param);
  if Result then
  begin
    if ABitmap.SourceMode then
      xbm := Self
    else xbm := ABitmap;
    dmode := FetchDrawModeEx(AMode, xbm.AlphaValue);
    px := param.XOffset * param.SrcWidth div param.DestWidth + FClipRect.Left;
    py := param.YOffset * param.SrcHeight div param.DestHeight + FClipRect.Top;
//    difx := param.SrcRect.Right - param.SrcRect.Left;
    difx := ARect.Right - ARect.Left;
    dify := param.DestHeight - param.YOffset * param.SrcHeight mod param.DestHeight - 1;
    try
//      while param.SrcRect.Top < param.SrcRect.Bottom do
      while ARect.Top < ARect.Bottom do
      begin
        ptr1 := @ScanLine[py][px];
        if param.FlipY then
        begin
//          Dec(param.SrcRect.Bottom);
//          ptr2 := @ABitmap.ScanLine[param.SrcRect.Bottom][param.SrcRect.Left];
          Dec(ARect.Bottom);
          ptr2 := @ABitmap.ScanLine[ARect.Bottom][ARect.Left];
        end
        else
        begin
//          ptr2 := @ABitmap.ScanLine[param.SrcRect.Top][param.SrcRect.Left];
//          Inc(param.SrcRect.Top);
          ptr2 := @ABitmap.ScanLine[ARect.Top][ARect.Left];
          Inc(ARect.Top);
        end;
        if TXPCPU.MMXEnabled then
        case dmode of
          xdmxOpaque: CopyColor(ptr1, ptr2, param.SrcWidth, param.DestWidth, difx, param.XOffset, param.FlipX);
          xdmxOpaqueEx: MMXCopyColor(ptr1, ptr2, param.SrcWidth, param.DestWidth, difx, param.XOffset, param.FlipX, xbm.AlphaValue);
          xdmxAlpha: CopyAlpha(ptr1, ptr2, param.SrcWidth, param.DestWidth, difx, param.XOffset, param.FlipX);
          xdmxAlphaEx: CopyAlpha(ptr1, ptr2, param.SrcWidth, param.DestWidth, difx, param.XOffset, param.FlipX, xbm.AlphaValue);
          xdmxMono: CopyMono(ptr1, ptr2, param.SrcWidth, param.DestWidth, difx, param.XOffset, param.FlipX, xbm.MonoColor);
          xdmxMonoEx: CopyMono(ptr1, ptr2, param.SrcWidth, param.DestWidth, difx, param.XOffset, param.FlipX, xbm.MonoColor, xbm.AlphaValue);
          xdmxPalette: CopyAlphaPalette(ptr1, ptr2, param.SrcWidth, param.DestWidth, difx, param.XOffset, param.FlipX, xbm.PaletteTable, xbm.PaletteCount);
          xdmxPaletteEx: CopyAlphaPalette(ptr1, ptr2, param.SrcWidth, param.DestWidth, difx, param.XOffset, param.FlipX, xbm.PaletteTable, xbm.PaletteCount, xbm.AlphaValue);
        end
        else case dmode of
          xdmxOpaque: CopyColor(ptr1, ptr2, param.SrcWidth, param.DestWidth, difx, param.XOffset, param.FlipX);
          xdmxOpaqueEx: CopyColor(ptr1, ptr2, param.SrcWidth, param.DestWidth, difx, param.XOffset, param.FlipX, xbm.AlphaValue);
          xdmxAlpha: CopyAlpha(ptr1, ptr2, param.SrcWidth, param.DestWidth, difx, param.XOffset, param.FlipX);
          xdmxAlphaEx: CopyAlpha(ptr1, ptr2, param.SrcWidth, param.DestWidth, difx, param.XOffset, param.FlipX, xbm.AlphaValue);
          xdmxMono: CopyMono(ptr1, ptr2, param.SrcWidth, param.DestWidth, difx, param.XOffset, param.FlipX, xbm.MonoColor);
          xdmxMonoEx: CopyMono(ptr1, ptr2, param.SrcWidth, param.DestWidth, difx, param.XOffset, param.FlipX, xbm.MonoColor, xbm.AlphaValue);
          xdmxPalette: CopyAlphaPalette(ptr1, ptr2, param.SrcWidth, param.DestWidth, difx, param.XOffset, param.FlipX, xbm.PaletteTable, xbm.PaletteCount);
          xdmxPaletteEx: CopyAlphaPalette(ptr1, ptr2, param.SrcWidth, param.DestWidth, difx, param.XOffset, param.FlipX, xbm.PaletteTable, xbm.PaletteCount, xbm.AlphaValue);
        end;
        dify := dify - param.SrcHeight;
        while dify < 0 do
        begin
          Inc(py);
          dify := dify + param.DestHeight;
        end;
      end;
    finally
      emms;
    end;
  end;
end;

function TXPBitmap.PenPos: TPoint;
begin
  Result.X := PenX;
  Result.Y := PenY;
end;

function TXPBitmap.InClipRect(px, py: Integer): Boolean;
begin
  Result := InsideRect(px, py, FClipRect);
end;

function TXPBitmap.InClipRect(APoint: TPoint): Boolean;
begin
  Result := InsideRect(APoint.X, APoint.Y, FClipRect);
end;

function TXPBitmap.InDrawClipRect(px, py: Integer): Boolean;
begin
  Result := InsideRect(px, py, FDrawClipRect);
end;

function TXPBitmap.InDrawClipRect(APoint: TPoint): Boolean;
begin
  Result := InsideRect(APoint.X, APoint.Y, FDrawClipRect);
end;

procedure TXPBitmap.PutPixel(px, py: Integer);
begin
  PutPixel(px, py, BrushColor, DrawMode);
end;

procedure TXPBitmap.PutPixel(px, py: Integer; AMode: TXPDrawMode);
begin
  PutPixel(px, py, BrushColor, AMode);
end;

procedure TXPBitmap.PutPixel(px, py: Integer; c32: TColor32);
begin
  PutPixel(px, py, c32, DrawMode);
end;

procedure TXPBitmap.PutPixel(px, py: Integer; c32: TColor32; AMode: TXPDrawMode);
var
  vptr: PColor32;
begin
  if InDrawClipRect(px, py) then
  begin
    vptr := @ScanLine[py][px];
    case FetchDrawModeEx(AMode, FAlphaValue) of
      xdmxOpaque: vptr^ := c32;
      xdmxOpaqueEx: PlotAlpha(vptr^, c32.ChangeAlpha(FAlphaValue));
      xdmxAlpha: PlotAlpha(vptr^, c32);
      xdmxAlphaEx: PlotAlpha(vptr^, c32, FAlphaValue);
      xdmxMono: PlotAlpha(vptr^, GetMonoColor(c32, MonoColor));
      xdmxMonoEx: PlotAlpha(vptr^, GetMonoColor(c32, MonoColor), FAlphaValue);
      xdmxPalette: PlotAlpha(vptr^, GetPalette(c32.BGRA));
      xdmxPaletteEx: PlotAlpha(vptr^, GetPalette(c32.BGRA), FAlphaValue)
    end;
  end;
end;

procedure TXPBitmap.MoveTo(px: Integer; py: Integer);
begin
  PenX := px;
  PenY := py;
end;

procedure TXPBitmap.MoveTo(APoint: TPoint);
begin
  PenX := APoint.X;
  PenY := APoint.Y;
end;

procedure TXPBitmap.LineTo(qx, qy: Integer);
begin
  LineTo(qx, qy, DrawMode);
end;

procedure TXPBitmap.LineTo(qx, qy: Integer; AMode: TXPDrawMode);
var
  x0, y0, px, py, t, incy, distance: Integer;
begin
  x0 := 0;
  y0 := 0;
  t := 0;
  px := PenX;
  py := PenY;
  PenX := qx;
  PenY := qy;
  if px > qx then
  begin
  	SwapInt(px, qx);
	  SwapInt(py, qy);
  end;
  qx := qx - px + 1;
  if py > qy then
  begin
    incy := -1;
    qy := py - qy + 1;
  end
  else
  begin
   incy := 1;
   qy := qy - py + 1;
  end;
  distance := Max(qx, qy);
  while t <= distance do
  begin
  	PutPixel(px, py, AMode);
    x0 := x0 + qx;
  	if x0 >= distance then
    begin
	    x0 := x0 - distance;
	    Inc(px);
    end;
    y0 := y0 + qy;
  	if y0 >= distance then
    begin
	    y0 := y0 - distance;
	    py := py + incy;
    end;
    Inc(t);
  end;
end;

procedure TXPBitmap.LineTo(APoint: TPoint);
begin
  LineTo(APoint.X, APoint.Y, DrawMode);
end;

procedure TXPBitmap.LineTo(APoint: TPoint; AMode: TXPDrawMode);
begin
  LineTo(APoint.X, APoint.Y, AMode);
end;

procedure TXPBitmap.HLineTo(px: Integer);
begin
  HLineTo(px, DrawMode);
end;

procedure TXPBitmap.HLineTo(px: Integer; AMode: TXPDrawMode);
var
  vptr: PColor32;
  qx: Integer;
begin
  qx := PenX;
  PenX := px;
  if InsideInt(PenY, FDrawClipRect.Top, FDrawClipRect.Bottom - 1) then
  begin
    SwapIntOrder(px, qx);
    Inc(qx);
    if CropRange(px, qx, FDrawClipRect.Left, FDrawClipRect.Right - 1) then
    begin
      qx := qx - px;
      vptr := @ScanLine[PenY][px];
      case FetchDrawModeEx(AMode, FAlphaValue) of
        xdmxOpaque: FillColor(vptr, BrushColor, qx);
        xdmxOpaqueEx: FillAlpha(vptr, BrushColor.ChangeAlpha(FAlphaValue), qx);
        xdmxAlpha: FillAlpha(vptr, BrushColor, qx);
        xdmxAlphaEx: FillAlpha(vptr, BrushColor, qx, FAlphaValue);
        xdmxMono: FillAlpha(vptr, GetMonoColor(BrushColor, MonoColor), qx);
        xdmxMonoEx: FillAlpha(vptr, GetMonoColor(BrushColor, MonoColor), qx, FAlphaValue);
        xdmxPalette: FillAlpha(vptr, GetPalette(BrushColor.BGRA), qx);
        xdmxPaletteEx: FillAlpha(vptr, GetPalette(BrushColor.BGRA), qx, FAlphaValue);
      end;
    end;
  end;
end;

procedure TXPBitmap.VLineTo(py: Integer);
begin
  VLineTo(py, DrawMode);
end;

procedure TXPBitmap.VLineTo(py: Integer; AMode: TXPDrawMode);
var
  ptr: PColor32;
  qy: Integer;
begin
  qy := PenY;
  PenY := py;
  if InsideInt(PenX, ClipRect.Left, ClipRect.Right - 1) then
  begin
    SwapIntOrder(py, qy);
    Inc(qy);
    if CropRange(py, qy, ClipRect.Top, ClipRect.Bottom - 1) then
    begin
      ptr := @ScanLine[py][PenX];
      qy := qy - py;
      case FetchDrawModeEx(AMode, FAlphaValue) of
        xdmxOpaque: FillColorInc(ptr, BrushColor, qy, FWidth);
        xdmxOpaqueEx: FillAlphaInc(ptr, BrushColor.ChangeAlpha(FAlphaValue), qy, FWidth);
        xdmxAlpha: FillAlphaInc(ptr, BrushColor, qy, FWidth);
        xdmxAlphaEx: FillAlphaInc(ptr, BrushColor, qy, FWidth, FAlphaValue);
        xdmxMono: FillAlphaInc(ptr, GetMonoColor(BrushColor, MonoColor), qy, FWidth);
        xdmxMonoEx: FillAlphaInc(ptr, GetMonoColor(BrushColor, MonoColor), qy, FWidth, FAlphaValue);
        xdmxPalette: FillAlphaInc(ptr, GetPalette(BrushColor.BGRA), qy, FWidth);
        xdmxPaletteEx: FillAlphaInc(ptr, GetPalette(BrushColor.BGRA), qy, FWidth, FAlphaValue);
      end;
    end;
  end;
end;

procedure TXPBitmap.FrameRect(x1, y1, x2, y2: Integer);
begin
  FrameRect(x1, y1, x2, y2, DrawMode);
end;

procedure TXPBitmap.FrameRect(x1, y1, x2, y2: Integer; AMode: TXPDrawMode);
begin
  MoveTo(x1, y1);
  HLineTo(x2, AMode);
  VLineTo(y2, AMode);
  HLineTo(x1, AMode);
  VLineTo(y1, AMode);
end;

procedure TXPBitmap.FrameRect(rect: TRect);
begin
  FrameRect(rect.Left, rect.Top, rect.Right - 1, rect.Bottom - 1, DrawMode);
end;

procedure TXPBitmap.FrameRect(rect: TRect; AMode: TXPDrawMode);
begin
  FrameRect(rect.Left, rect.Top, rect.Right - 1, rect.Bottom - 1, AMode);
end;

procedure TXPBitmap.FillRect;
begin
  FillRect(ClipRect, DrawMode);
end;

procedure TXPBitmap.FillRect(AMode: TXPDrawMode);
begin
  FillRect(ClipRect, AMode);
end;

procedure TXPBitmap.FillRect(x1, y1, x2, y2: Integer);
begin
  FillRect(Rect(x1, y1, x2 + 1, y2 + 1), DrawMode);
end;

procedure TXPBitmap.FillRect(x1, y1, x2, y2: Integer; AMode: TXPDrawMode);
begin
  FillRect(Rect(x1, y1, x2 + 1, y2 + 1), AMode);
end;

procedure TXPBitmap.FillRect(rect: TRect);
begin
  FillRect(rect, DrawMode);
end;

procedure TXPBitmap.FillRect(rect: TRect; AMode: TXPDrawMode);
var
  dmode: TXPDrawModeEx;
  vptr: PColor32;
  nx: Integer;
begin
  SwapIntOrder(rect.Left, rect.Right);
  SwapIntOrder(rect.Top, rect.Bottom);
  if CropRect(rect, ClipRect) then
  begin
    if CropRect(rect, DefaultClipRect) then
    begin
      dmode := FetchDrawModeEx(AMode, FAlphaValue);
      nx := rect.Right - rect.Left;
      while rect.Top < rect.Bottom do
      begin
        vptr := @ScanLine[rect.Top][rect.Left];
        case dmode of
          xdmxOpaque: FillColor(vptr, BrushColor, nx);
          xdmxOpaqueEx: FillAlpha(vptr, BrushColor.ChangeAlpha(FAlphaValue), nx);
          xdmxAlpha: FillAlpha(vptr, BrushColor, nx);
          xdmxAlphaEx: FillAlpha(vptr, BrushColor, nx, FAlphaValue);
          xdmxMono: FillAlpha(vptr, GetMonoColor(BrushColor, MonoColor), nx);
          xdmxMonoEx: FillAlpha(vptr, GetMonoColor(BrushColor, MonoColor), nx, FAlphaValue);
          xdmxPalette: FillAlpha(vptr, GetPalette(BrushColor.BGRA), nx);
          xdmxPaletteEx: FillAlpha(vptr, GetPalette(BrushColor.BGRA), nx, FAlphaValue);
        end;
        Inc(rect.Top);
      end;
    end;
  end;
end;

procedure TXPBitmap.DrawTile(px, py: Integer; gbm: TXPBitmap);
begin
  if SourceMode then
    gbm.DrawTile(Self, ClipRect, gbm.CopyMode, px, py)
  else gbm.DrawTile(Self, ClipRect, DrawMode, px, py);
end;

procedure TXPBitmap.DrawTile(px, py: Integer; gbm: TXPBitmap; AMode: TXPDrawMode);
begin
  gbm.DrawTile(Self, ClipRect, AMode, px, py);
end;

procedure TXPBitmap.DrawTile(px, py: Integer; gbm: TXPBitmap; drect: TRect);
begin
  if SourceMode then
    gbm.DrawTile(Self, drect, gbm.CopyMode, px, py)
  else gbm.DrawTile(Self, drect, DrawMode, px, py);
end;

procedure TXPBitmap.DrawTile(px, py: Integer; gbm: TXPBitmap; drect: TRect; AMode: TXPDrawMode);
begin
  gbm.DrawTile(Self, drect, AMode, px, py);
end;

procedure TXPBitmap.Circle(px, py, r: Integer);
begin
  Circle(px, py, r, DrawMode);
end;

procedure TXPBitmap.Circle(px, py, r: Integer; AMode: TXPDrawMode);
var
  i, d: Integer;
begin
  i := 0;
  d := 3 - (r shl 1);
  while i <= r do
  begin
    PutPixel(px - r, py - i, AMode);
    PutPixel(px + r, py - i, AMode);
    PutPixel(px - r, py + i, AMode);
    PutPixel(px + r, py + i, AMode);
    PutPixel(px - i, py - r, AMode);
    PutPixel(px + i, py - r, AMode);
    PutPixel(px - i, py + r, AMode);
    PutPixel(px + i, py + r, AMode);
    if d >= 0 then
    begin
      d := d - (r shl 2) + 10;
      Dec(r);
    end
    else d := d + 6;
    d := d + (i shl 2);
    Inc(i);
  end;
end;

procedure TXPBitmap.FillCircle(px, py, r: Integer);
begin
  FillCircle(px, py, r, DrawMode);
end;

procedure TXPBitmap.FillCircle(px, py, r: Integer; AMode: TXPDrawMode);
var
  i, d: Integer;
begin
  i := 0;
  d := 3 - (r shl 1);
  while i <= r do
  begin
  	MoveTo(px - r, py - i);
  	HLineTo(px + r, AMode);
    if (i > 0) then
    begin
    	MoveTo(px - r, py + i);
    	HLineTo(px + r, AMode);
    end;
    if d >= 0 then
    begin
      if i <> r then
      begin
      	MoveTo(px - i, py - r);
      	HLineTo(px + i, AMode);
  	    MoveTo(px - i, py + r);
    	  HLineTo(px + i, AMode);
      end;
      d := d - (r shl 2) + 10;
      Dec(r);
    end
    else d := d + 6;
    d := d + (i shl 2);
    Inc(i);
  end;
end;

procedure TXPBitmap.TextOutLine(x, y: Integer; text: string; fc, bc: TColor);
begin
  TextOutLineTo(Canvas, x, y, text, fc, bc);
end;

procedure TXPBitmap.TextSmooth(x, y: Integer; text: String; fc, bc: TColor; thick: Integer = 1);
begin
  TextSmoothTo(Canvas, x, y, text, fc, bc, thick);
end;

procedure TXPBitmap.LoadAlpha(gbm: TXPBitmap);
var
  nx, ny: Integer;
begin
  for ny := gbm.ClipRect.Top to gbm.ClipRect.Bottom - 1 do
  begin
    for nx := gbm.ClipRect.Left to gbm.ClipRect.Right - 1 do
    begin
      AlphaPixels[nx, ny] := gbm.Pixels[nx, ny].GrayScale;
    end;
  end;
end;

procedure TXPBitmap.ReadFromStream(AStream: TStream);
var
  ny, w, h: Integer;
begin
  AStream.Read(w, 4);
  AStream.Read(h, 4);
  SetSize(w, h);
  for ny := 0 to h - 1 do
  begin
    AStream.Read(FSurface[ny * w], w * 4);
  end;
end;

procedure TXPBitmap.WriteToStream(AStream: TStream);
var
  ny: Integer;
begin
  AStream.Write(FWidth, 4);
  AStream.Write(FHeight, 4);
  for ny := 0 to FHeight - 1 do
  begin
    AStream.Write(FSurface[ny * FWidth], FWidth * 4);
  end;
end;

procedure TXPBitmap.LoadFromBitmap(ABitmap: TBitmap; AAlpha: TBitmap = nil);
var
  sp, dp, ap: PColor32Array;
  nx, ny: Integer;
begin
  ABitmap.PixelFormat := pf32bit;
  SetSize(ABitmap.Width, ABitmap.Height);
  if Assigned(AAlpha) then
  begin
    AAlpha.PixelFormat := pf32bit;
    for ny := 0 to FHeight - 1 do
    begin
      sp := ABitmap.ScanLine[ny];
      ap := AAlpha.ScanLine[ny];
      dp := @FSurface[ny * FWidth];
      for nx := 0 to FWidth - 1 do dp[nx] := sp[nx].ChangeAlpha(ap[nx].GrayScale);
    end;
  end
  else
  begin
    for ny := 0 to FHeight - 1 do
    begin
      sp := ABitmap.ScanLine[ny];
      dp := @FSurface[ny * FWidth];
      for nx := 0 to FWidth - 1 do dp[nx] := sp[nx].ChangeAlpha(255);
    end;
  end;
end;

procedure TXPBitmap.LoadFromBMP(AStream: TStream);
var
  bm: TBitmap;
begin
  bm := TBitmap.Create;
  try
    bm.LoadFromStream(AStream);
    LoadFromBitmap(bm);
  finally
    bm.Free;
  end;
end;

function TXPBitmap.LoadFromExt(AStream: TStream; AFileName: string): Integer;
const
  ImgExt = '.BMP.GIF.JPG.PNG.G9B';
begin
  Result := (Pos(UpperCase(ExtractFileExt(AFileName)), ImgExt) + 3) div 4;
  case Result of
    1: LoadFromBMP(AStream);
    2: LoadFromGIF(AStream);
    3: LoadFromJPG(AStream);
    4: LoadFromPNG(AStream);
    5: LoadFromG9B(AStream);
  end;
end;

procedure TXPBitmap.LoadFromFile(AFileName: string);
begin
  LoadFromFile(AFileName, '');
end;

procedure TXPBitmap.LoadFromFile(AFileName, AlphaName: string);
var
  fs: TFileStream;
  xbm: TXPBitmap;
  n: Integer;
begin
  FileSupportIndex := FileSupportList.IndexOfSupport(AFileName);
  if FileSupportClass = TXPBitmap then
  begin
    fs := TFileStream.Create(AFileName, fmOpenRead);
    try
      n := LoadFromExt(fs, AFileName);
    finally
      fs.Free;
    end;
    if n = 0 then inherited LoadFromFile(AFileName);
  end;
  if AlphaName <> '' then
  begin
    xbm := TXPBitmap.Create;
    try
      xbm.LoadFromFile(AlphaName);
      LoadAlpha(xbm);
    finally
      xbm.Free;
    end;
  end;
end;

procedure TXPBitmap.LoadFromG9B(AStream: TStream);
var
  pal: TG9BPalEntry;
  hd: TG9BHeader;
  chk: TG9BChunk;
  x, y: Integer;
  c15: TColor15;
  c8: TGRB332Color;
//  yc: array[0..3] of TColor32;
  yjk: TYJKColor;
  yuv: TYUVColor;
  b: Byte;
  stm: TStream;
begin
  AStream.Read(hd, SizeOf(hd));
  if (hd.Signature = 'G9B') and (hd.ChunkSize = SizeOf(TG9BChunk)) then
  begin
    AStream.Read(chk, SizeOf(TG9BChunk));
    SetSize(chk.Width, chk.Height);
    SetPaletteCount(chk.PalCount);
    for x := 0 to chk.PalCount - 1 do
    begin
      AStream.Read(pal, 3);
      with FPalette.PaletteTable[x] do
      begin
        R := (pal.R shl 3) or (pal.R shr 2);
        G := (pal.G shl 3) or (pal.G shr 2);
        B := (pal.B shl 3) or (pal.B shr 2);
      end;
    end;
    case chk.BitDepth of
      2, 4, 8, 16:
      case chk.ColorType of
        0, 64, 128, 192:;
      else
        raise Exception.CreateFmt('G9B color type %d not supported.', [chk.ColorType]);
      end;
    else
      raise Exception.CreateFmt('G9B color depth %d not supported.', [chk.BitDepth]);
    end;
    if chk.Compression = 1 then
    begin
      stm := AStream;
      AStream := TG9BStream.Create(AStream, False);
    end
    else stm := nil;
    try
      x := 0;
      y := 0;
      while y < chk.Height do
      begin
        case chk.ColorType of
          0: // 64 Palette entrys
          case chk.BitDepth of
            2:
            begin
              AStream.Read(b, 1);
              Pixels[x, y] := FPalette[b];
            end;
            4:
            begin
              AStream.Read(b, 1);
              Pixels[x, y] := FPalette[b shr 4];
              Inc(x);
              Pixels[x, y] := FPalette[b and 15];
            end;
            8:
            begin
              AStream.Read(b, 1);
              Pixels[x, y] := FPalette[b and 63];
            end;
            16:
            begin
              AStream.Read(c15, 2);
              Pixels[x, y] := c15.Color32;
            end;
          end;
          64: // 256 colors
          begin
            AStream.Read(c8, 1);
            Pixels[x, y] := c8.Color32;
          end;
          128: // YJK
          begin
            AStream.Read(yjk, 4);
            Pixels[x, y] := yjk.Color32[0];
            Pixels[x + 1, y] := yjk.Color32[1];
            Pixels[x + 2, y] := yjk.Color32[2];
            Pixels[x + 3, y] := yjk.Color32[3];
//            CopyYJK(@yjk, @yc[0], 4, 0, False);
//            Pixels[x, y] := yc[0];
//            Pixels[x + 1, y] := yc[1];
//            Pixels[x + 2, y] := yc[2];
//            Pixels[x + 3, y] := yc[3];
            Inc(x, 3);
          end;
          192: // YUV
          begin
            AStream.Read(yuv, 4);
            Pixels[x, y] := yuv.Color32[0];
            Pixels[x + 1, y] := yuv.Color32[1];
            Pixels[x + 2, y] := yuv.Color32[2];
            Pixels[x + 3, y] := yuv.Color32[3];
            Inc(x, 3);
          end;
        end;
        Inc(x);
        if x >= chk.Width then
        begin
          Inc(y);
          x := 0;
        end;
      end;
    finally
      if stm <> nil then AStream.Free;
//      FreeAndNil(sm);
    end;
  end
  else MessageDlg('Invalid G9B header.', mtError, [mbOK], 0);
end;

procedure TXPBitmap.LoadFromGIF(AStream: TStream);
var
  gif: TGIFImage;
  bm: TBitmap;
begin
  gif := TGIFImage.Create;
  try
    gif.LoadFromStream(AStream);
    bm := gif.Bitmap;
    LoadFromBitmap(bm);
  finally
    gif.Free;
  end;
end;

procedure TXPBitmap.LoadFromJPG(AStream: TStream);
var
  jpg: TJpegImage;
  bm: TBitmap;
begin
  jpg := TJpegImage.Create;
  try
    jpg.LoadFromStream(AStream);
    bm := TBitmap.Create;
    try
      bm.Assign(jpg);
      LoadFromBitmap(bm);
    finally
      bm.Free;
    end;
  finally
    jpg.Free;
  end;
end;

procedure TXPBitmap.LoadFromPNG(AStream: TStream);
var
  dp: PColor32Array;
  nx, ny: Integer;
  aptr: PByteArray;
  png: TPNGImage;
begin
  png := TPNGImage.Create;
  try
    png.LoadFromStream(AStream);
    SetSize(png.Width, png.Height);
    for ny := 0 to FHeight - 1 do
    begin
      aptr := PByteArray(png.AlphaScanline[ny]);
      dp := @FSurface[ny * FWidth];
      for nx := 0 to FWidth - 1 do
      begin
        if aptr <> nil then
          dp[nx] := Color32OfColor(png.Pixels[nx, ny], aptr[nx])
        else dp[nx] := Color32OfColor(png.Pixels[nx, ny], 255);
      end;
    end;
  finally
    png.Free;
  end;
end;

class procedure TXPBitmap.LoadSupports(AList: TXPFileSupportList);
begin
  inherited LoadSupports(AList);
  AList.AddSupport(TXPBitmap, 'XPBitmap', '.bm1', 'BM1', 'BM1'#0);
  AList.AddSupport(TXPBitmap, 'XPBitmap', '.bmp', 'BMP', '');
  AList.AddSupport(TXPBitmap, 'XPBitmap', '.gif', 'GIF', '');
  AList.AddSupport(TXPBitmap, 'XPBitmap', '.jpg', 'JPG', '');
  AList.AddSupport(TXPBitmap, 'XPBitmap', '.png', 'PNG', '');
  AList.AddSupport(TXPBitmap, 'XPBitmap', '.g9b', 'G9B', '');
end;

procedure TXPBitmap.SaveToFile(fname: string);
var
  bm: TBitmap;
  png: TPNGImage;
  jpg: TJPEGImage;
  ext: string;
  nx, ny: Integer;
  sp: PColor32Array;
  dp: PColor32Array;
  aptr: PByteArray;
begin
  ext := LowerCase(ExtractFileExt(fname));
  if ext = '.png' then
  begin
    png := TPNGImage.CreateBlank(COLOR_RGBALPHA, 8, FWidth, FHeight);
    try
      for ny := 0 to FHeight - 1 do
      begin
        aptr := PByteArray(png.AlphaScanline[ny]);
        dp := @FSurface[ny * FWidth];
        for nx := 0 to FWidth - 1 do
        begin
          png.Pixels[nx, ny] := dp[nx].Color;
          aptr[nx] := dp[nx].A;
        end;
      end;
      png.SaveToFile(fname);
    finally
      png.Free;
    end;
  end
  else if (ext = '.bmp') or (ext = '.jpg') then
  begin
    bm := TBitmap.Create;
    try
      bm.PixelFormat := pf32bit;
      bm.Width := FWidth;
      bm.Height := FHeight;
      for ny := 0 to FHeight - 1 do
      begin
        sp := bm.ScanLine[ny];
        dp := @FSurface[ny * FWidth];
        for nx := 0 to FWidth - 1 do sp[nx] := dp[nx].ChangeAlpha(0);
      end;
      if ext = '.jpg' then
      begin
        jpg := TJPEGImage.Create;
        try
          jpg.Assign(bm);
          jpg.SaveToFile(fname);
        finally
          jpg.Free;
        end;
      end
      else bm.SaveToFile(ChangeFileExt(fname, '.bmp'));
    finally
      bm.Free;
    end;
  end
  else inherited SaveToFile(fname);
end;

// TXPBitmapList
function TXPBitmapList.GetBitmaps(n: Integer): TXPBitmap;
begin
  Result := TXPBitmap(inherited Items[n]);
end;

procedure TXPBitmapList.LoadFromFile(AFileName: string);
begin
  if TXPBitmap.IsFileSupport(AFileName) then
  begin
    Clear;
    AddFromFile(AFileName);
  end
  else inherited LoadFromFile(AFileName);
end;

class procedure TXPBitmapList.LoadSupports(AList: TXPFileSupportList);
begin
  inherited LoadSupports(AList);
  AList.AddSupport(TXPBitmapList, 'TXPBitmapList', '.bms', 'BMS', 'BMS'#0);
end;

function TXPBitmapList.AddFromFile(fname: string): TXPBitmap;
begin
  Result := TXPBitmap.Create;
  Result.LoadFromFile(fname);
  Add(Result);
end;

constructor TXPBitmapList.Create;
begin
  inherited Create;
end;

constructor TXPBitmapList.Create(AFileName: string);
begin
  Create;
  LoadFromFile(AFileName);
end;

function TXPBitmapList.CreateItem: TXPObject;
begin
  Result := TXPBitmap.Create;
end;

procedure TXPBitmapList.ReadFromStream(AStream: TStream);
var
  gbm: TXPBitmap;
  npic, p: Integer;
  fpos: Int64;
begin
  AStream.Read(npic, 4);
  fpos := AStream.Position;
  while npic > 0 do
  begin
    Dec(npic);
    AStream.Seek(fpos, soBeginning);
    AStream.Read(p, 4);
    fpos := fpos + p;
    if AStream is TLZWStream then TLZWStream(AStream).Start;
    gbm := TXPBitmap.Create;
    gbm.FileSupportIndex := gbm.FileSupportList.IndexOfResType('BM1');
    gbm.ReadFromStream(AStream);
    Add(gbm);
    if AStream is TLZWStream then TLZWStream(AStream).Stop;
  end;
end;

procedure TXPBitmapList.WriteToStream(AStream: TStream);
var
  n, p: Integer;
  fpos1, fpos2: Int64;
begin
  p := Count;
  AStream.Write(p, 4);
  for n := 0 to Count - 1 do
  begin
    fpos1 := AStream.Position;
    p := 0;
    AStream.Write(p, 4);
    if AStream is TLZWStream then TLZWStream(AStream).Start;
    Bitmaps[n].WriteToStream(AStream);
    if AStream is TLZWStream then TLZWStream(AStream).Stop;
    fpos2 := AStream.Position;
    AStream.Seek(fpos1, soBeginning);
    p := fpos2 - fpos1;
    AStream.Write(p, 4);
    AStream.Seek(fpos2, soBeginning);
  end;
end;

function TXPBitmapList.AddBitmap: TXPBitmap;
begin
  Result := TXPBitmap.Create;
  Add(Result);
end;

procedure TXPBitmapList.SaveToFile(AFileName: string);
var
  n: Integer;
  support: TXPFileSupport;
begin
  support := FileSupportList.SupportByFileName[AFileName];
  if support = nil then
  begin
    raise Exception.CreateFmt('XPBitmapList file [%s] format not support.', [AFileName]);
    Exit;
  end;
  if support.ObjectClass = TXPBitmap then
  begin
    AFileName := ChangeFileExt(AFileName, '_%3.3d' + support.Extension);
    for n := 0 to Count - 1 do
    begin
      Bitmaps[n].SaveToFile(Format(AFileName, [n]));
    end;
  end
  else inherited SaveToFile(AFileName);
end;

{ TXPGraphic }

procedure TXPGraphic.Assign(AGraphic: TXPGraphic);
begin
  inherited Assign(AGraphic);
  FWidth := AGraphic.FWidth;
  FHeight := AGraphic.FHeight;
  FClipRect := AGraphic.FClipRect;
  FPaintRect := AGraphic.FPaintRect;
  FDrawClipRect := AGraphic.FDrawClipRect;
  FDrawPaintRect := AGraphic.FDrawPaintRect;
  FDefaultClipRect := AGraphic.FDefaultClipRect;
  FlipX := AGraphic.FlipX;
  FlipY := AGraphic.FlipY;
  CopyMode := AGraphic.CopyMode;
end;

procedure TXPGraphic.ChangedSize;
begin
  FDefaultClipRect.Right := FWidth;
  FDefaultClipRect.Bottom := FHeight;
  FClipRect := FDefaultClipRect;
  FPaintRect := FDefaultClipRect;
  FDrawClipRect := FDefaultClipRect;
  FDrawPaintRect := FDefaultClipRect;
end;

constructor TXPGraphic.Create;
begin
  inherited Create;
  FlipX := False;
  FlipY := False;
  FWidth := 0;
  FHeight := 0;
  FDefaultClipRect.Left := 0;
  FDefaultClipRect.Top := 0;
  FDefaultClipRect.Right := FWidth;
  FDefaultClipRect.Bottom := FHeight;
  FClipRect := FDefaultClipRect;
  FPaintRect := FDefaultClipRect;
  FDrawClipRect := FDefaultClipRect;
  FDrawPaintRect := FDefaultClipRect;
  CopyMode := xdmOpaque;
end;

function TXPGraphic.Draw(gbm: TXPBitmap; px, py: Integer;
  AMode: TXPDrawMode): Boolean;
begin
  raise Exception.Create('XPGraphic abstract error.');
end;

function TXPGraphic.Draw(gbm: TXPBitmap; px, py: Integer): Boolean;
begin
  raise Exception.Create('XPGraphic abstract error.');
end;

function TXPGraphic.Draw(gbm: TXPBitmap; drect: TRect;
  AMode: TXPDrawMode): Boolean;
begin
  raise Exception.Create('XPGraphic abstract error.');
end;

function TXPGraphic.Draw(gbm: TXPBitmap; drect: TRect): Boolean;
begin
  raise Exception.Create('XPGraphic abstract error.');
end;

function TXPGraphic.GetDrawParam(ABitmap: TXPBitmap; var ARect: TRect;
  var AParam: TXPDrawParam): Boolean;
begin
  Result := False;
  if not Assigned(ABitmap) then Exit;
  AParam.SrcWidth := Min(FWidth, FDrawClipRect.Right) - FDrawClipRect.Left;
  AParam.SrcHeight := Min(FHeight, FDrawClipRect.Bottom) - FDrawClipRect.Top;
  AParam.DestWidth := ARect.Right - ARect.Left;
  AParam.DestHeight := ARect.Bottom - ARect.Top;
  if (AParam.SrcWidth <= 0) or (AParam.SrcHeight <= 0)
    or (AParam.DestWidth <= 0) or (AParam.DestHeight <= 0)
    or (ABitmap.FWidth <= 0) or (ABitmap.FHeight <= 0)
  then Exit;
//  AParam.SrcRect.TopLeft := ARect.TopLeft;
  AParam.FlipX := FlipX;
  AParam.FlipY := FlipY;
  if AParam.DestWidth < 0 then
  begin
    AParam.DestWidth := -AParam.DestWidth;
//    AParam.SrcRect.Left := AParam.SrcRect.Left - AParam.DestWidth;
    ARect.Left := ARect.Left - AParam.DestWidth;
    AParam.FlipX := not AParam.FlipX;
  end;
  if AParam.DestHeight < 0 then
  begin
    AParam.DestHeight := -AParam.DestHeight;
//    AParam.SrcRect.Top := AParam.SrcRect.Top - AParam.DestHeight;
    ARect.Top := ARect.Top - AParam.DestHeight;
    AParam.FlipY := not AParam.FlipY;
  end;
  ARect.BottomRight := Point(ARect.Left + AParam.DestWidth, ARect.Top + AParam.DestHeight);
  Result := CropRect(ARect, ABitmap.DrawClipRect, AParam.XOffset, AParam.YOffset, AParam.FlipX, AParam.FlipY);
end;

procedure TXPBitmap.SetCopyAlphaValue(AValue: Integer);
begin
  FCopyAlphaValue := IntInside(AValue, 0, 255);
end;

procedure TXPGraphic.SetClipBottom(n: Integer);
begin
  FClipRect.Bottom := n;
  FDrawClipRect.Bottom := MinInt(n, FDefaultClipRect.Bottom);
end;

procedure TXPGraphic.SetClipLeft(n: Integer);
begin
  FClipRect.Left := n;
  FDrawClipRect.Left := MaxInt(n, FDefaultClipRect.Left);
end;

procedure TXPGraphic.SetClipRect(ARect: TRect);
begin
  FClipRect := ARect;
  FDrawClipRect := ARect;
  CropRect(FDrawClipRect, FDefaultClipRect);
end;

procedure TXPGraphic.SetClipRight(n: Integer);
begin
  FClipRect.Right := n;
  FDrawClipRect.Right := MinInt(n, FDefaultClipRect.Right);
end;

procedure TXPGraphic.SetClipTop(n: Integer);
begin
  FClipRect.Top := n;
  FDrawClipRect.Top := MaxInt(n, FDefaultClipRect.Top);
end;

procedure TXPGraphic.SetHeight(AHeight: Integer);
begin
  SetSize(FWidth, AHeight);
end;

procedure TXPGraphic.SetPaintRect(ARect: TRect);
begin
  FPaintRect := ARect;
  FDrawPaintRect := ARect;
  CropRect(FDrawPaintRect, FDefaultClipRect);
end;

procedure TXPGraphic.SetSize(AWidth, AHeight: Integer);
begin
  if (FWidth <> AWidth) or (FHeight <> AHeight) then
  begin
    FWidth := AWidth;
    FHeight := AHeight;
    ChangedSize;
  end;
end;

procedure TXPGraphic.SetWidth(AWidth: Integer);
begin
  SetSize(AWidth, FHeight);
end;

{ TXPCanvas }

procedure TXPCanvas.Assign(AObject: TXPObject);
begin
  inherited;
  if AObject is TXPCanvas then
    SetCanvas(TXPCanvas(AObject).Canvas)
  else Exception.Create('Can not assign XPCanvas');
end;

procedure TXPCanvas.CanvasChanged(Sender: TObject);
begin
  if Assigned(FCanvas) then with FCanvas.ClipRect do
  begin
    FXOrigin := Left;
    FYOrigin := Top;
    FWidth := Right - Left;
    FHeight := Bottom - Top;
  end
  else
  begin
    FXOrigin := 0;
    FYOrigin := 0;
    FWidth := 0;
    FHeight := 0;
  end;
  FBitmap.SetSize(FWidth, FHeight);
end;

constructor TXPCanvas.Create(ACanvas: TCanvas);
begin
  Create;
  SetCanvas(ACanvas);
end;

constructor TXPCanvas.Create;
begin
  inherited Create;
  FBitmap := TXPBitmap.Create;
  FXOrigin := 0;
  FYOrigin := 0;
  FWidth := 0;
  FHeight := 0;
  FCanvas := nil;
end;

destructor TXPCanvas.Destroy;
begin
  SetCanvas(nil);
  FBitmap.Free;
  inherited;
end;

procedure TXPCanvas.SetCanvas(ACanvas: TCanvas);
begin
  if Assigned(FCanvas) then
  begin
    if @FCanvas.OnChange = @TXPCanvas.CanvasChanged then
    begin
      FCanvas.OnChange := nil;
    end;
  end;
  FCanvas := ACanvas;
  if Assigned(FCanvas) then FCanvas.OnChange := CanvasChanged;
end;

initialization
end.

