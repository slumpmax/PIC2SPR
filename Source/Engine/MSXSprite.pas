unit MSXSprite;

interface

uses
  Windows, SysUtils, Vcl.Graphics, Vcl.Imaging.GifImg, Vcl.Imaging.Jpeg,
  Vcl.Imaging.PNGImage, Math, Classes;

type
  TSpriteMemory = array[$7400..$7FFF] of Byte;
  TMSXSprite = class
  private
    FMemory: TSpriteMemory;
    FGIF: TGIFImage;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure PutSprite(ACanvas: TCanvas; ARect: TRect; ANumbers: array of Byte);
    procedure PutColor(ACanvas: TCanvas; ARect: TRect; AColor: Byte);
    procedure LoadFromGIF(AFileName: string);
    procedure SaveToFile(AFileName: string);
    property Memory: TSpriteMemory read FMemory;
  end;

implementation

uses
  XPRoutine, MSXPicture;

{ TMSXSprite }

procedure TMSXSprite.Clear;
var
  pattr: PMSXSpriteAttrTable;
  ppal: PMSXPalette;
  n: Integer;
begin
  FillChar(FMemory, $C00, 0);
  pattr := @FMemory[$7600];
  for n := 0 to 31 do pattr[n].Y := 216;
  ppal := @FMemory[$7680];
  ppal^ := MSXSystemPalette;
end;

constructor TMSXSprite.Create;
begin
  FGIF := TGIFImage.Create;
  Clear;
end;

destructor TMSXSprite.Destroy;
begin
  FGIF.Free;
  inherited Destroy;
end;

procedure TMSXSprite.LoadFromGIF(AFileName: string);
var
  n, nx, ny, sx, sy, tx, b1, b2, w, h: Integer;
  cc: array[0..2] of TColorEntry;
  cr: array[0..2] of Integer;
  cl: TColorEntry;
  nc, ic: array[0..15] of Byte;
  b: Byte;
  ppal: PMSXPalette;
  pal: TMaxLogPalette;
  sptr: PByteArray;
  bm: TBitmap;
begin
  Clear;
  FGIF.LoadFromFile(AFileName);
  bm := FGIF.Bitmap;
  GetPaletteEntries(bm.Palette, 0, 16, pal.palPalEntry);
  ppal := @FMemory[$7680];
  for b := 0 to 15 do
  begin
    ppal[b].R := pal.palPalEntry[b].peRed shr 5;
    ppal[b].G := pal.palPalEntry[b].peGreen shr 5;
    ppal[b].B := pal.palPalEntry[b].peBlue shr 5;
    ppal[b].X := 0;
  end;
  n := 0;
  ny := 0;
  w := Min(256, bm.Width - (bm.Width and 15));
  h := Min(32, bm.Height - (bm.Height and 15));
  while ny < h do
  begin
    nx := 0;
    while nx < w do
    begin
      for sy := 0 to 15 do
      begin
        sptr := bm.ScanLine[ny + sy];
        sptr := @sptr[nx];
        for sx := 0 to 15 do
        begin
          nc[sx] := 0;
          ic[sx] := sx;
        end;
        for sx := 0 to 15 do Inc(nc[sptr[sx]]);
        for sx := 0 to 14 do
        begin
          for tx := sx + 1 to 15 do
          begin
            if (nc[tx] > nc[sx]) or (ic[sx] = 0) then
            begin
              b := nc[tx];
              nc[tx] := nc[sx];
              nc[sx] := b;
              b := ic[tx];
              ic[tx] := ic[sx];
              ic[sx] := b;
            end;
          end;
        end;
        b1 := 0;
        b2 := 0;
        ic[2] := ic[0] or ic[1];
        cc[0].Color := ppal[ic[0]].Color;
        cc[1].Color := ppal[ic[1]].Color;
        cc[2].Color := ppal[ic[2]].Color;
        for sx := 0 to 15 do
        begin
          b1 := b1 shl 1;
          b2 := b2 shl 1;
          b := sptr[sx];
          cl.Color := ppal[b].Color;
          cr[0] := cl.Difference(cc[0]);
          cr[1] := cl.Difference(cc[1]);
          cr[2] := cl.Difference(cc[2]);
          if b <> 0 then
          begin
            if (cl = cc[0]) or ((cr[0] < cr[1]) and (cr[0] < cr[2])) then
              b1 := b1 or 1
            else if (cl = cc[1]) or (cr[1] < cr[2]) then
              b2 := b2 or 1
            else
            begin
              b1 := b1 or 1;
              b2 := b2 or 1;
            end;
          end;
        end;
        FMemory[$7800 + n * 32 + (sy mod 16) + ((nx and 15) div 8) * 16] := b1 shr 8;
        FMemory[$7800 + n * 32 + (sy mod 16) + ((nx and 15) div 8) * 16 + 16] := b1 and 255;
        FMemory[$7800 + (n + 1) * 32 + (sy mod 16) + ((nx and 15) div 8) * 16] := b2 shr 8;
        FMemory[$7800 + (n + 1) * 32 + (sy mod 16) + ((nx and 15) div 8) * 16 + 16] := b2 and 255;
        FMemory[$7400 + n * 16 + sy] := ic[0];
        FMemory[$7400 + (n + 1) * 16 + sy] := ic[1] or $40;
      end;
      Inc(nx, 16);
      Inc(n, 2);
    end;
    Inc(ny, 16);
  end;
end;

procedure TMSXSprite.PutColor(ACanvas: TCanvas; ARect: TRect; AColor: Byte);
var
  ppal: PMSXPalette;
begin
  ppal := @FMemory[$7680];
  ACanvas.Brush.Color := ppal[AColor].Color;
  ACanvas.FillRect(ARect);
end;

procedure TMSXSprite.PutSprite(ACanvas: TCanvas; ARect: TRect; ANumbers: array of Byte);
var
  ppal: PMSXPalette;
  bm: TBitmap;
  n, ns, nx, ny: Integer;
  b: Byte;
  c: array[0..15, 0..15] of Byte;
begin
  for nx := 0 to Length(ANumbers) - 2 do
  begin
    for ny := nx + 1 to Length(ANumbers) - 1 do
    begin
      if ANumbers[ny] < ANumbers[nx] then
      begin
        b := ANumbers[nx];
        ANumbers[nx] := ANumbers[ny];
        ANumbers[ny] := b;
      end;
    end;
  end;
  ppal := @FMemory[$7680];
  bm := TBitmap.Create;
  try
    bm.PixelFormat := pf24bit;
    bm.SetSize(16, 16);
    for ny := 0 to 15 do
    begin
      for nx := 0 to 15 do c[nx, ny] := 0;
    end;
    for n := 0 to Length(ANumbers) - 1 do
    begin
      ns := ANumbers[n];
      if ns < 32 then
      begin
        for ny := 0 to 15 do
        begin
          for nx := 0 to 15 do
          begin
            b := FMemory[$7800 + ns * 32 + (ny mod 16) + (nx div 8) * 16];
            b := b and ($80 shr (nx and 7));
            if b <> 0 then
            begin
              b := FMemory[$7400 + ns * 16 + ny] and 15;
              c[nx, ny] := c[nx, ny] or b;
            end;
          end;
        end;
      end;
    end;
    for ny := 0 to 15 do
    begin
      for nx := 0 to 15 do
      begin
        bm.Canvas.Pixels[nx, ny] := ppal[c[nx, ny]].Color;
      end;
    end;
    ACanvas.StretchDraw(ARect, bm);
  finally
    bm.Free;
  end;
end;

procedure TMSXSprite.SaveToFile(AFileName: string);
var
  fheader: TMSXBinaryHeader;
  fs: TFileStream;
begin
  fs := TFileStream.Create(AFileName, fmCreate);
  try
    fheader.ID := $FE;
    fheader.StartAddress := $7400;
    fheader.EndAddress := $7FFF;
    fheader.RunAddress := $7400;
    fs.Write(fheader, SizeOf(fheader));
    fs.Write(FMemory[$7400], $C00);
  finally
    fs.Free;
  end;
end;

end.
