unit XPEngine32;

interface

uses
  XPRoutine,
  Classes, Windows, Vcl.Graphics, Types, Math, SysUtils, Vcl.Dialogs, Variants,
  System.UITypes;


// GDI Canvas
procedure Draw(DCanvas: TCanvas; DRect: TRect; SCanvas: TCanvas; SRect: TRect; AAlpha: Integer; ASrcAlpha: Boolean = False);
procedure DrawAlpha(DCanvas: TCanvas; DRect: TRect; SCanvas: TCanvas; SRect: TRect; AAlpha: Integer = 255);
procedure FillRectAlpha(ACanvas: TCanvas; ARect: TRect; AColor: TColor; AAlpha: Integer);

// pixel
function MergeAlpha(scolor, dcolor: TColor32): TColor32; overload;
function MergeAlpha(scolor, dcolor: TColor32; alpha: Integer): TColor32; overload;
procedure PlotAlpha(var dcolor; scolor: TColor32); overload;
procedure PlotAlpha(var dcolor; scolor: TColor32; alpha: Integer); overload;

// hozizontal line
procedure FillColor(dest: Pointer; color: TColor32; count: Integer); overload;
procedure FillAlpha(dest: Pointer; color: TColor32; count: Integer); overload;
procedure FillAlpha(dest: Pointer; color: TColor32; count, alpha: Integer); overload;

// vertical line
procedure FillColorInc(dest: Pointer; color: TColor32; count, increase: Integer); overload;
procedure FillAlphaInc(dest: Pointer; color: TColor32; count, increase: Integer); overload;
procedure FillAlphaInc(dest: Pointer; color: TColor32; count, increase, alpha: Integer); overload;

procedure Copy_RGBA_To_BGRA(source, dest: Pointer; count: Integer; reverse: Boolean);
procedure Copy_RGB_To_BGR(source, dest: Pointer; count: Integer; reverse: Boolean);
procedure Copy_RGB_A8_To_RGBA(source, dest: Pointer; count: Integer; asource: Pointer; reverse: Boolean); overload;
procedure Copy_RGB_A8_To_RGBA(source, dest: Pointer; count: Integer; alpha: Byte; reverse: Boolean); overload;
procedure Copy_BGR_A8_To_RGBA(source, dest: Pointer; count: Integer; asource: Pointer; reverse: Boolean); overload;
procedure Copy_BGR_A8_To_RGBA(source, dest: Pointer; count: Integer; alpha: Byte; reverse: Boolean); overload;
procedure Copy_RGB_A24_To_RGBA(source, dest: Pointer; count: Integer; asource: Pointer; reverse: Boolean);
procedure Copy_BGR_A24_To_RGBA(source, dest: Pointer; count: Integer; asource: Pointer; reverse: Boolean);
procedure Copy_RGBA_A32_To_RGBA(source, dest: Pointer; count: Integer; asource: Pointer; reverse: Boolean);
procedure Copy_BGRA_A32_To_RGBA(source, dest: Pointer; count: Integer; asource: Pointer; reverse: Boolean);

// inline
procedure Copy_BGRA_To_RGBA(source, dest: Pointer; count: Integer; reverse: Boolean); inline;
procedure Copy_BGR_To_RGB(source, dest: Pointer; count: Integer; reverse: Boolean); inline;
procedure Copy_BGR_A8_To_BGRA(source, dest: Pointer; count: Integer; asource: Pointer; reverse: Boolean); overload; inline;
procedure Copy_BGR_A8_To_BGRA(source, dest: Pointer; count: Integer; alpha: Byte; reverse: Boolean); overload; inline;
procedure Copy_RGB_A8_To_BGRA(source, dest: Pointer; count: Integer; asource: Pointer; reverse: Boolean); overload; inline;
procedure Copy_RGB_A8_To_BGRA(source, dest: Pointer; count: Integer; alpha: Byte; reverse: Boolean); overload; inline;
procedure Copy_BGR_A24_To_BGRA(source, dest: Pointer; count: Integer; asource: Pointer; reverse: Boolean); inline;
procedure Copy_RGB_A24_To_BGRA(source, dest: Pointer; count: Integer; asource: Pointer; reverse: Boolean); inline;
procedure Copy_BGRA_A32_To_BGRA(source, dest: Pointer; count: Integer; asource: Pointer; reverse: Boolean); inline;
procedure Copy_RGBA_A32_To_BGRA(source, dest: Pointer; count: Integer; asource: Pointer; reverse: Boolean); inline;
//

procedure CopyColor(source, dest: Pointer; count: Integer; reverse: Boolean); overload;
procedure CopyColor(source, dest: Pointer; count: Integer; reverse: Boolean; alpha: Integer); overload;
procedure CopyColor(source, dest: Pointer; scount0, dcount0, dcount, doffset: Integer; reverse: Boolean); overload;
procedure CopyColor(source, dest: Pointer; scount0, dcount0, dcount, doffset: Integer; reverse: Boolean; alpha: Integer); overload;

procedure CopyAlpha(source, dest: Pointer; count: Integer; reverse: Boolean); overload;
procedure CopyAlpha(source, dest: Pointer; count: Integer; reverse: Boolean; alpha: Integer); overload;
procedure CopyAlpha(source, dest: Pointer; scount0, dcount0, dcount, doffset: Integer; reverse: Boolean); overload;
procedure CopyAlpha(source, dest: Pointer; scount0, dcount0, dcount, doffset: Integer; reverse: Boolean; alpha: Integer); overload;

procedure CopyMono(source, dest: Pointer; count: Integer; reverse: Boolean; color: TColor32); overload;
procedure CopyMono(source, dest: Pointer; count: Integer; reverse: Boolean; color: TColor32; alpha: Integer); overload;
procedure CopyMono(source, dest: Pointer; scount0, dcount0, dcount, doffset: Integer; reverse: Boolean; color: TColor32); overload;
procedure CopyMono(source, dest: Pointer; scount0, dcount0, dcount, doffset: Integer; reverse: Boolean; color: TColor32; alpha: Integer); overload;

procedure CopyAlphaPalette(source, dest: Pointer; count: Integer; reverse: Boolean; pal: Pointer; palcount: Integer); overload;
procedure CopyAlphaPalette(source, dest: Pointer; count: Integer; reverse: Boolean; pal: Pointer; palcount: Integer; alpha: Integer); overload;
procedure CopyAlphaPalette(source, dest: Pointer; scount0, dcount0, dcount, doffset: Integer; reverse: Boolean; pal: Pointer; palcount: Integer); overload;
procedure CopyAlphaPalette(source, dest: Pointer; scount0, dcount0, dcount, doffset: Integer; reverse: Boolean; pal: Pointer; palcount: Integer; alpha: Integer); overload;

// bit copy
procedure CopyBit(source, dest: Pointer; count, nbits: Integer; reverse: Boolean);

procedure CopyBitPalette(source, dest: Pointer; count, nbits, boffset: Integer; reverse: Boolean; pal: Pointer; palcount: Integer); overload;
procedure CopyBitPalette(source, dest: Pointer; scount0, dcount0, dcount, doffset, nbits, boffset: Integer; reverse: Boolean; pal: Pointer; palcount: Integer); overload;

procedure CopyCharPattern(csource, dest: Pointer; count, nbits, boffset: Integer; reverse: Boolean; cpattern: Pointer; fgcolor, bgcolor: TColor32); overload;
procedure CopyCharPattern(csource, dest: Pointer; scount0, dcount0, dcount, doffset, nbits, boffset: Integer; reverse: Boolean; cpattern: Pointer; fgcolor, bgcolor: TColor32); overload;

procedure CopyColorPattern(csource, dest: Pointer; count, boffset: Integer; reverse, mode2: Boolean; cpattern, ccolor, pal: Pointer; palcount: Integer); overload;
procedure CopyColorPattern(csource, dest: Pointer; scount0, dcount0, dcount, doffset, boffset: Integer; reverse, mode2: Boolean; cpattern, ccolor, pal: Pointer; palcount: Integer); overload;

procedure CopyCharColor(csource, dest: Pointer; count, boffset: Integer; reverse: Boolean; cpattern, pal: Pointer; palcount: Integer); overload;
procedure CopyCharColor(csource, dest: Pointer; scount0, dcount0, dcount, doffset, boffset: Integer; reverse: Boolean; cpattern, pal: Pointer; palcount: Integer); overload;

procedure CopyYJK(source, dest: Pointer; count, boffset: Integer; reverse: Boolean); overload;
procedure CopyYJK(source, dest: Pointer; scount0, dcount0, dcount, doffset, boffset: Integer; reverse: Boolean); overload;

procedure CopyYJKPalette(source, dest: Pointer; count, boffset: Integer; reverse: Boolean; pal: Pointer; palcount: Integer); overload;
procedure CopyYJKPalette(source, dest: Pointer; scount0, dcount0, dcount, doffset, boffset: Integer; reverse: Boolean; pal: Pointer; palcount: Integer); overload;

//procedure CopyScreen2(source, dest: Pointer; count, boffset: Integer; pattable, coltable: Pointer; reverse: Boolean; pal: Pointer; palcount: Integer);

procedure MMXCopyColor(source, dest: Pointer; count: Integer; reverse: Boolean; alpha: Integer); overload;
procedure MMXCopyColor(source, dest: Pointer; scount0, dcount0, dcount, doffset: Integer; reverse: Boolean; alpha: Integer); overload;

procedure MMXCopyAlpha(source, dest: Pointer; count: Integer; reverse: Boolean); overload;
procedure MMXCopyAlpha(source, dest: Pointer; count: Integer; reverse: Boolean; alpha: Integer); overload;

implementation

uses
  XPCPU;

procedure Draw(DCanvas: TCanvas; DRect: TRect; SCanvas: TCanvas; SRect: TRect; AAlpha: Integer; ASrcAlpha: Boolean);
var
  sw, sh, dw, dh: Integer;
  blendFn: BLENDFUNCTION;
begin
  blendFn.BlendOp := AC_SRC_OVER;
  blendFn.BlendFlags := 0;
  blendFn.SourceConstantAlpha := AAlpha;
  if ASrcAlpha then
    blendFn.AlphaFormat := AC_SRC_ALPHA
  else blendFn.AlphaFormat := 0;

  sw := SRect.Right - SRect.Left;
  sh := SRect.Bottom - SRect.Top;
  dw := DRect.Right - DRect.Left;
  dh := DRect.Bottom - DRect.Top;

  Windows.AlphaBlend(DCanvas.Handle, DRect.Left, DRect.Right, dw, dh,
    SCanvas.Handle, SRect.Left, SRect.Top, sw, sh, blendFn);
end;

procedure DrawAlpha(DCanvas: TCanvas; DRect: TRect; SCanvas: TCanvas; SRect: TRect; AAlpha: Integer);
begin
  Draw(DCanvas, DRect, SCanvas, SRect, AAlpha, True);
end;

procedure FillRectAlpha(ACanvas: TCanvas; ARect: TRect; AColor: TColor; AAlpha: Integer);
var
  bm: TBitmap;
begin
  bm := TBitmap.Create;
  try
    bm.PixelFormat        := pf32bit;
    bm.Width              := ARect.Right - ARect.Left;
    bm.Height             := ARect.Bottom - ARect.Top;
    bm.Canvas.Brush.Color := AColor;
    bm.Canvas.FillRect(bm.Canvas.ClipRect);
    Draw(ACanvas, ARect, bm.Canvas, bm.Canvas.ClipRect, AAlpha);
  finally
    bm.Free;
  end;
end;

function MergeAlpha(scolor, dcolor: TColor32): TColor32;
asm
// Result = fa * frgb + (1 - fa) * brgb
// eax = scolor
// edx = dcolor

  // test fa = 255 ?
    cmp   ecx,$FF000000   // fa = 255 ? => Result = eax
    jnc   @exit

  // test fa = 0 ?
    test  eax,$FF000000   // fa = 0 ?   => Result = edx
    jz    @no_copy

  // get weight w = fa * m
    mov   ecx,eax         // ecx  <-  fa fr fg fb
    shr   ecx,24          // ecx  <-  00 00 00 fa

    push  ebx

  // p = w * f
    mov   ebx,eax         // ebx  <-  fa fr fg fb
    and   eax,$00FF00FF   // eax  <-  00 fr 00 fb
    and   ebx,$FF00FF00   // ebx  <-  fa 00 fg 00
    imul  eax,ecx         // eax  <-  pr ** pb **
    shr   ebx,8           // ebx  <-  00 fa 00 fg
    imul  ebx,ecx         // ebx  <-  pa ** pg **
    add   eax,$00800080
    and   eax,$FF00FF00   // eax  <-  pr 00 pb 00
    shr   eax,8           // eax  <-  00 pr ** pb
    add   ebx,$00800080
    and   ebx,$FF00FF00   // ebx  <-  pa 00 pg 00
    or    eax,ebx         // eax  <-  pa pr pg pb

  // w = 1 - w; q = w * b
    xor   ecx,$000000FF   // ecx  <-  1 - ecx
    mov   ebx,edx         // ebx  <-  ba br bg bb
    and   edx,$00FF00FF   // edx  <-  00 br 00 bb
    and   ebx,$FF00FF00   // ebx  <-  ba 00 bg 00
    imul  edx,ecx         // edx  <-  qr ** qb **
    shr   ebx,8           // ebx  <-  00 ba 00 bg
    imul  ebx,ecx         // ebx  <-  qa ** qg **
    add   edx,$00800080
    and   edx,$FF00FF00   // edx  <-  qr 00 qb 00
    shr   edx,8           // edx  <-  00 qr ** qb
    add   ebx,$00800080
    and   ebx,$FF00FF00   // ebx  <-  qa 00 qg 00
    or    ebx,edx         // ebx  <-  qa qr qg qb

  // z = p + q (assuming no overflow at each byte)
    add   eax,ebx         // eax  <-  za zr zg zb
    pop   ebx
    jmp   @exit

  @no_copy:
    mov   eax,edx

  @exit:
end;

function MergeAlpha(scolor, dcolor: TColor32; alpha: Integer): TColor32;
asm
// Result = fa * m * frgb + (1 - fa * m) * brgb
// eax = scolor
// edx = dcolor
// ecx = alpha

  // test fa = 0 ?
    test  eax,$FF000000   // fa = 0 ? => Result = edx
    jz    @full_copy

    push  ebx

  // get weight w = fa * m
    mov   ebx,eax         // ebc  <-  fa fr fg fb
    inc   ecx             // 255:256 range bias
    shr   ebx,24          // ebc  <-  00 00 00 fa
    imul  ecx,ebx         // ecx  <-  00 00  w **
    shr   ecx,8           // ecx  <-  00 00 00  w
    jz    @no_copy        // w = 0 ?  => write nothing

  // p = w * f
    mov   ebx,eax         // ebx  <-  fa fr fg fb
    and   eax,$00FF00FF   // eax  <-  00 fr 00 fb
    and   ebx,$FF00FF00   // ebx  <-  fa 00 fg 00
    imul  eax,ecx         // eax  <-  pr ** pb **
    shr   ebx,8           // ebx  <-  00 fa 00 fg
    imul  ebx,ecx         // ebx  <-  pa ** pg **
    add   eax,$00800080
    and   eax,$FF00FF00   // eax  <-  pr 00 pb 00
    shr   eax,8           // eax  <-  00 pr ** pb
    add   ebx,$00800080
    and   ebx,$FF00FF00   // ebx  <-  pa 00 pg 00
    or    eax,ebx         // eax  <-  pa pr pg pb

  // w = 1 - w; q = w * b
    xor   ecx,$000000FF   // ecx  <-  1 - ecx
    mov   ebx,edx         // ebx  <-  ba br bg bb
    and   edx,$00FF00FF   // edx  <-  00 br 00 bb
    and   ebx,$FF00FF00   // ebx  <-  ba 00 bg 00
    imul  edx,ecx         // edx  <-  qr ** qb **
    shr   ebx,8           // ebx  <-  00 ba 00 bg
    imul  ebx,ecx         // ebx  <-  qa ** qg **
    add   edx,$00800080
    and   edx,$FF00FF00   // edx  <-  qr 00 qb 00
    shr   edx,8           // edx  <-  00 qr ** qb
    add   ebx,$00800080
    and   ebx,$FF00FF00   // ebx  <-  qa 00 qg 00
    or    edx,ebx         // edx  <-  qa qr qg qb

  // z = p + q (assuming no overflow at each byte)
    add   edx,eax         // edx  <-  za zr zg zb

  @no_copy:
    pop   ebx

  @full_copy:
    mov   eax,edx

  @exit:
end;

procedure PlotAlpha(var dcolor; scolor: TColor32);
asm
// eax = @dcolor
// edx = scolor

    test  edx,$FF000000
    jz    @exit

  // get weight w = fa * m
    mov   ecx,edx         // ecx  <-  fa fr fg fb
    shr   ecx,24          // ecx  <-  00 00 00 fa

  // test fa = 255 ?
    cmp   ecx,$FF
    jz    @full_copy

    push  edi
    push  ebx
    mov   edi,eax

  // p = w * f
    mov   eax,edx         // eax  <-  fa fr fg fb
    and   eax,$00FF00FF   // eax  <-  00 fr 00 fb
    and   edx,$FF00FF00   // ebx  <-  fa 00 fg 00
    imul  eax,ecx         // eax  <-  pr ** pb **
    shr   edx,8           // ebx  <-  00 fa 00 fg
    imul  edx,ecx         // ebx  <-  pa ** pg **
    add   eax,$00800080
    and   eax,$FF00FF00   // eax  <-  pr 00 pb 00
    shr   eax,8           // eax  <-  00 pr ** pb
    add   edx,$00800080
    and   edx,$FF00FF00   // ebx  <-  pa 00 pg 00
    or    eax,edx         // eax  <-  pa pr pg pb

  // w = 1 - w; q = w * b
    mov   edx,[edi]
    xor   ecx,$000000FF   // ecx  <-  1 - ecx
    mov   ebx,edx         // ebx  <-  ba br bg bb
    and   edx,$00FF00FF   // esi  <-  00 br 00 bb
    and   ebx,$FF00FF00   // ebx  <-  ba 00 bg 00
    imul  edx,ecx         // esi  <-  qr ** qb **
    shr   ebx,8           // ebx  <-  00 ba 00 bg
    imul  ebx,ecx         // ebx  <-  qa ** qg **
    add   edx,$00800080
    and   edx,$FF00FF00   // esi  <-  qr 00 qb 00
    shr   edx,8           // esi  <-  00 qr ** qb
    add   ebx,$00800080
    and   ebx,$FF00FF00   // ebx  <-  qa 00 qg 00
    or    ebx,edx         // ebx  <-  qa qr qg qb

  // z = p + q (assuming no overflow at each byte)
    add   eax,ebx         // eax  <-  za zr zg zb
    mov   [edi],eax
    pop   ebx
    pop   edi
    jmp   @exit

  @full_copy:
    mov   [eax],edx

  @exit:
end;

procedure PlotAlpha(var dcolor; scolor: TColor32; alpha: Integer);
asm
// eax = @dcolor
// edx = scolor
// ecx = alpha

    test  edx,$FF000000
    jz    @exit

    push  ebx

  // get weight w = fa * m
    mov   ebx,edx         // ebc  <-  fa fr fg fb
    inc   ecx             // 255:256 range bias
    shr   ebx,24          // ebc  <-  00 00 00 fa
    imul  ecx,ebx         // ecx  <-  00 00  w **
    shr   ecx,8           // ecx  <-  00 00 00  w
    jz    @no_copy        // w = 0 ?  => write nothing

    push  edi
    mov   edi,eax

  // p = w * f
    mov   eax,edx         // eax  <-  fa fr fg fb
    and   eax,$00FF00FF   // eax  <-  00 fr 00 fb
    and   edx,$FF00FF00   // ebx  <-  fa 00 fg 00
    imul  eax,ecx         // eax  <-  pr ** pb **
    shr   edx,8           // ebx  <-  00 fa 00 fg
    imul  edx,ecx         // ebx  <-  pa ** pg **
    add   eax,$00800080
    and   eax,$FF00FF00   // eax  <-  pr 00 pb 00
    shr   eax,8           // eax  <-  00 pr ** pb
    add   edx,$00800080
    and   edx,$FF00FF00   // ebx  <-  pa 00 pg 00
    or    eax,edx         // eax  <-  pa pr pg pb

  // w = 1 - w; q = w * b
    mov   edx,[edi]
    xor   ecx,$000000FF   // ecx  <-  1 - ecx
    mov   ebx,edx         // ebx  <-  ba br bg bb
    and   edx,$00FF00FF   // edx  <-  00 br 00 bb
    and   ebx,$FF00FF00   // ebx  <-  ba 00 bg 00
    imul  edx,ecx         // edx  <-  qr ** qb **
    shr   ebx,8           // ebx  <-  00 ba 00 bg
    imul  ebx,ecx         // ebx  <-  qa ** qg **
    add   edx,$00800080
    and   edx,$FF00FF00   // esi  <-  qr 00 qb 00
    shr   edx,8           // esi  <-  00 qr ** qb
    add   ebx,$00800080
    and   ebx,$FF00FF00   // ebx  <-  qa 00 qg 00
    or    ebx,edx         // ebx  <-  qa qr qg qb

  // z = p + q (assuming no overflow at each byte)
    add   eax,ebx         // eax  <-  za zr zg zb
    mov   [edi],eax
    pop   edi

  @no_copy:
    pop   ebx

  @exit:
end;

procedure FillColor(dest: Pointer; color: TColor32; count: Integer);
asm
// eax = dest
// edx = color
// ecx = count
    push  edi
    mov  edi,eax
    mov  eax,edx
    test ecx,ecx
    js   @end_copy
    jz   @end_copy
    rep  stosd
  @end_copy:
    pop   edi
end;

procedure FillAlpha(dest: Pointer; color: TColor32; count: Integer);
asm
// eax = dest
// edx = color
// ecx = count

    test ecx,ecx
    js   @exit
    jz   @exit

    test edx,$FF000000
    jz   @exit

    push esi
    push edi
    push ebx
    mov  edi,eax
    mov  eax,edx
    mov  esi,ecx

  // get weight w = fa * m
    mov  ecx,eax         // ecx  <-  fa fr fg fb
    shr  ecx,24          // ecx  <-  00 00 00 fa

  // p = w * f
    mov  ebx,eax         // ebx  <-  fa fr fg fb
    and  eax,$00FF00FF   // eax  <-  00 fr 00 fb
    and  ebx,$FF00FF00   // ebx  <-  fa 00 fg 00
    imul eax,ecx         // eax  <-  pr ** pb **
    shr  ebx,8           // ebx  <-  00 fa 00 fg
    imul ebx,ecx         // ebx  <-  pa ** pg **
    add  eax,$00800080
    and  eax,$FF00FF00   // eax  <-  pr 00 pb 00
    shr  eax,8           // eax  <-  00 pr ** pb
    add  ebx,$00800080
    and  ebx,$FF00FF00   // ebx  <-  pa 00 pg 00
    or   eax,ebx         // eax  <-  pa pr pg pb
    xor  ecx,$000000FF   // ecx  <-  1 - ecx

  @loop_fill:
  // w = 1 - w; q = w * b
    mov  edx,[edi]
    mov  ebx,edx         // ebx  <-  ba br bg bb
    and  edx,$00FF00FF   // esi  <-  00 br 00 bb
    and  ebx,$FF00FF00   // ebx  <-  ba 00 bg 00
    imul edx,ecx         // esi  <-  qr ** qb **
    shr  ebx,8           // ebx  <-  00 ba 00 bg
    imul ebx,ecx         // ebx  <-  qa ** qg **
    add  edx,$00800080
    and  edx,$FF00FF00   // esi  <-  qr 00 qb 00
    shr  edx,8           // esi  <-  00 qr ** qb
    add  ebx,$00800080
    and  ebx,$FF00FF00   // ebx  <-  qa 00 qg 00
    or   ebx,edx         // ebx  <-  qa qr qg qb

  // z = p + q (assuming no overflow at each byte)
    add  ebx,eax         // eax  <-  za zr zg zb
    mov  [edi],ebx
    add  edi,4
    dec  esi
    jnz  @loop_fill

    pop  ebx
    pop  edi
    pop  esi

  @exit:
end;

procedure FillAlpha(dest: Pointer; color: TColor32; count: Integer; alpha: Integer);
asm
// eax = dest
// edx = color
// ecx = count

    test  ecx,ecx
    js    @exit
    jz    @exit

    test  edx,$FF000000
    jz    @exit

    push  ebx
    push  esi
    mov   esi,[alpha]

  // get weight w = fa * m
    mov   ebx,edx         // ebx  <-  fa fr fg fb
    inc   esi             // 255:256 range bias
    shr   ebx,24          // ebx  <-  00 00 00 fa
    imul  esi,ebx         // ecx  <-  00 00  w **
    shr   esi,8           // ecx  <-  00 00 00  w
    jz    @no_copy        // w = 0 ?  => write nothing

    push  edi
    mov   edi,eax

  // p = w * f
    mov   ebx,edx         // ebx  <-  fa fr fg fb
    and   edx,$00FF00FF   // eax  <-  00 fr 00 fb
    and   ebx,$FF00FF00   // ebx  <-  fa 00 fg 00
    imul  edx,esi         // eax  <-  pr ** pb **
    shr   ebx,8           // ebx  <-  00 fa 00 fg
    imul  ebx,esi         // ebx  <-  pa ** pg **
    add   edx,$00800080
    and   edx,$FF00FF00   // eax  <-  pr 00 pb 00
    shr   edx,8           // eax  <-  00 pr ** pb
    add   ebx,$00800080
    and   ebx,$FF00FF00   // ebx  <-  pa 00 pg 00
    or    edx,ebx         // eax  <-  pa pr pg pb
    xor   esi,$000000FF   // ecx  <-  1 - ecx

  @loop_fill:
  // w = 1 - w; q = w * b
    mov   eax,[edi]
    mov   ebx,eax         // ebx  <-  ba br bg bb
    and   eax,$00FF00FF   // esi  <-  00 br 00 bb
    and   ebx,$FF00FF00   // ebx  <-  ba 00 bg 00
    imul  eax,esi         // esi  <-  qr ** qb **
    shr   ebx,8           // ebx  <-  00 ba 00 bg
    imul  ebx,esi         // ebx  <-  qa ** qg **
    add   eax,$00800080
    and   eax,$FF00FF00   // esi  <-  qr 00 qb 00
    shr   eax,8           // esi  <-  00 qr ** qb
    add   ebx,$00800080
    and   ebx,$FF00FF00   // ebx  <-  qa 00 qg 00
    or    eax,ebx         // ebx  <-  qa qr qg qb

  // z = p + q (assuming no overflow at each byte)
    add   eax,edx         // eax  <-  za zr zg zb
    stosd
    dec   ecx
    jnz   @loop_fill
    pop   edi

  @no_copy:
    pop   esi
    pop   ebx

  @exit:
end;

procedure FillColorInc(dest: Pointer; color: TColor32; count, increase: Integer);
asm
// fill opaque color with increment
// eax = dest
// edx = color
// ecx = count

    test  ecx,ecx
    js    @exit
    jz    @exit

    push  ebx
    mov   ebx,[increase]
    shl   ebx,2

  @loop_y:
    mov   [eax],edx
    add   eax,ebx
    dec   ecx
    jnz   @loop_y
    pop   ebx

  @exit:
end;

procedure FillAlphaInc(dest: Pointer; color: TColor32; count, increase: Integer);
asm
// fill alpha color with increment
// eax = dest
// edx = color
// ecx = count

    test ecx,ecx
    js   @exit
    jz   @exit

    test edx,$FF000000
    jz   @exit

    push esi
    push edi
    push ebx
    mov  edi,eax
    mov  eax,edx
    mov  esi,ecx
    shl  [increase],2

  // get weight w = fa * m
    mov  ecx,eax         // ecx  <-  fa fr fg fb
    shr  ecx,24          // ecx  <-  00 00 00 fa

  // p = w * f
    mov  ebx,eax         // ebx  <-  fa fr fg fb
    and  eax,$00FF00FF   // eax  <-  00 fr 00 fb
    and  ebx,$FF00FF00   // ebx  <-  fa 00 fg 00
    imul eax,ecx         // eax  <-  pr ** pb **
    shr  ebx,8           // ebx  <-  00 fa 00 fg
    imul ebx,ecx         // ebx  <-  pa ** pg **
    add  eax,$00800080
    and  eax,$FF00FF00   // eax  <-  pr 00 pb 00
    shr  eax,8           // eax  <-  00 pr ** pb
    add  ebx,$00800080
    and  ebx,$FF00FF00   // ebx  <-  pa 00 pg 00
    or   eax,ebx         // eax  <-  pa pr pg pb
    xor  ecx,$000000FF   // ecx  <-  1 - ecx

  @loop_fill:
  // w = 1 - w; q = w * b
    mov  edx,[edi]
    mov  ebx,edx         // ebx  <-  ba br bg bb
    and  edx,$00FF00FF   // esi  <-  00 br 00 bb
    and  ebx,$FF00FF00   // ebx  <-  ba 00 bg 00
    imul edx,ecx         // esi  <-  qr ** qb **
    shr  ebx,8           // ebx  <-  00 ba 00 bg
    imul ebx,ecx         // ebx  <-  qa ** qg **
    add  edx,$00800080
    and  edx,$FF00FF00   // esi  <-  qr 00 qb 00
    shr  edx,8           // esi  <-  00 qr ** qb
    add  ebx,$00800080
    and  ebx,$FF00FF00   // ebx  <-  qa 00 qg 00
    or   ebx,edx         // ebx  <-  qa qr qg qb

  // z = p + q (assuming no overflow at each byte)
    add  ebx,eax         // eax  <-  za zr zg zb
    mov  [edi],ebx
    add  edi,[increase]
    dec  esi
    jnz  @loop_fill

    pop  ebx
    pop  edi
    pop  esi

  @exit:
end;

procedure FillAlphaInc(dest: Pointer; color: TColor32; count, increase, alpha: Integer);
asm
// fill alpha color with master alpha & increment
// eax = dest
// edx = color
// ecx = count

    test  ecx,ecx
    js    @exit
    jz    @exit

    test  edx,$FF000000
    jz    @exit

    push  ebx
    push  esi
    mov   esi,[alpha]
    shl   [increase],2

  // get weight w = fa * m
    mov   ebx,edx         // ebx  <-  fa fr fg fb
    inc   esi             // 255:256 range bias
    shr   ebx,24          // ebx  <-  00 00 00 fa
    imul  esi,ebx         // ecx  <-  00 00  w **
    shr   esi,8           // ecx  <-  00 00 00  w
    jz    @no_copy        // w = 0 ?  => write nothing

    push  edi
    mov   edi,eax

  // p = w * f
    mov   ebx,edx         // ebx  <-  fa fr fg fb
    and   edx,$00FF00FF   // eax  <-  00 fr 00 fb
    and   ebx,$FF00FF00   // ebx  <-  fa 00 fg 00
    imul  edx,esi         // eax  <-  pr ** pb **
    shr   ebx,8           // ebx  <-  00 fa 00 fg
    imul  ebx,esi         // ebx  <-  pa ** pg **
    add   edx,$00800080
    and   edx,$FF00FF00   // eax  <-  pr 00 pb 00
    shr   edx,8           // eax  <-  00 pr ** pb
    add   ebx,$00800080
    and   ebx,$FF00FF00   // ebx  <-  pa 00 pg 00
    or    edx,ebx         // eax  <-  pa pr pg pb
    xor   esi,$000000FF   // ecx  <-  1 - ecx

  @loop_fill:
  // w = 1 - w; q = w * b
    mov   eax,[edi]
    mov   ebx,eax         // ebx  <-  ba br bg bb
    and   eax,$00FF00FF   // esi  <-  00 br 00 bb
    and   ebx,$FF00FF00   // ebx  <-  ba 00 bg 00
    imul  eax,esi         // esi  <-  qr ** qb **
    shr   ebx,8           // ebx  <-  00 ba 00 bg
    imul  ebx,esi         // ebx  <-  qa ** qg **
    add   eax,$00800080
    and   eax,$FF00FF00   // esi  <-  qr 00 qb 00
    shr   eax,8           // esi  <-  00 qr ** qb
    add   ebx,$00800080
    and   ebx,$FF00FF00   // ebx  <-  qa 00 qg 00
    or    eax,ebx         // ebx  <-  qa qr qg qb

  // z = p + q (assuming no overflow at each byte)
    add   eax,edx         // eax  <-  za zr zg zb
    mov   [edi],eax
    add   edi,[increase]
    dec   ecx
    jnz   @loop_fill
    pop   edi

  @no_copy:
    pop   esi
    pop   ebx

  @exit:
end;

procedure Copy_RGBA_To_BGRA(source, dest: Pointer; count: Integer; reverse: Boolean);
asm
// eax = source
// edx = dest
// ecx = count
    test ecx,ecx
    js   @exit
    jz   @exit

    push edi
    push ebx

    test byte ptr reverse,$FF
    jz   @not_reverse
    lea  edx,[edx + ecx * 4 - 4]
    std

  @not_reverse:
    mov  edi,edx
    mov  edx,eax

  @loop_d:
    mov  eax,[edx]
    add  edx,4
    mov  ebx,eax
    rol  ebx,16
    and  ebx,$00FF00FF
    and  eax,$FF00FF00
    or   eax,ebx
    stosd
    dec  ecx
    jnz  @loop_d

    cld
    pop  ebx
    pop  edi

  @exit:
end;

procedure Copy_RGB_To_BGR(source, dest: Pointer; count: Integer; reverse: Boolean);
asm
// eax = source
// edx = dest
// ecx = count
    test ecx,ecx
    js   @exit
    jz   @exit

    push edi
    push ebx

    mov  ebx,1
    test byte ptr reverse,$FF
    jz   @not_reverse
    lea  edx,[edx + ecx * 4 - 4]
    mov  ebx,-1

  @not_reverse:
    mov  edi,edx
    mov  edx,eax

  @loop_d:
    mov  al,[edx]
    inc  edx
    rol  eax,16
    mov  ax,[edx]
    add  edx,2
    mov  [edi],ah
    add  edi,ebx
    mov  [edi],al
    add  edi,ebx
    ror  eax,16
    mov  [edi],al
    add  edi,ebx
    dec  ecx
    jnz  @loop_d

    cld
    pop  ebx
    pop  edi

  @exit:
end;

procedure Copy_RGB_A8_To_RGBA(source, dest: Pointer; count: Integer; asource: Pointer; reverse: Boolean);
asm
// eax = source
// edx = dest
// ecx = count
    test ecx,ecx
    js   @exit
    jz   @exit

    push edi
    push esi

    test byte ptr [reverse],$FF
    jz   @not_reverse
    lea  edx,[edx + ecx * 4 - 4]
    std

  @not_reverse:
    mov  edi,edx
    mov  edx,eax
    mov  esi,[asource]

  @loop_d:
    mov  ax,[edx]
    add  edx,2
    rol  eax,16
    xchg al,ah
    mov  al,[edx]
    inc  edx
    ror  eax,8
    mov  al,[esi]
    inc  esi
    ror  eax,8
    stosd
    dec  ecx
    jnz  @loop_d

    cld
    pop  esi
    pop  edi

  @exit:
end;

procedure Copy_RGB_A8_To_RGBA(source, dest: Pointer; count: Integer; alpha: Byte; reverse: Boolean);
asm
// eax = source
// edx = dest
// ecx = count
    test ecx,ecx
    js   @exit
    jz   @exit

    push edi

    test byte ptr [reverse],$FF
    jz   @not_reverse
    lea  edx,[edx + ecx * 4 - 4]
    std

  @not_reverse:
    mov  edi,edx
    mov  edx,eax
    mov  al,alpha
    ror  eax,8

  @loop_d:
    mov  ax,[edx]
    add  edx,2
    rol  eax,16
    mov  al,[edx]
    inc  edx
    rol  eax,16
    stosd
    dec  ecx
    jnz  @loop_d

    cld
    pop  edi

  @exit:
end;

procedure Copy_BGR_A8_To_RGBA(source, dest: Pointer; count: Integer; asource: Pointer; reverse: Boolean);
asm
// eax = source
// edx = dest
// ecx = count
    test ecx,ecx
    js   @exit
    jz   @exit

    push edi
    push esi

    test byte ptr [reverse],$FF
    jz   @not_reverse
    lea  edx,[edx + ecx * 4 - 4]
    std

  @not_reverse:
    mov  edi,edx
    mov  edx,eax
    mov  esi,[asource]

  @loop_d:
    mov  ah,[esi]
    inc  esi
    mov  al,[edx]
    inc  edx
    rol  eax,16
    mov  ax,[edx]
    add  edx,2
    xchg al,ah
    stosd
    dec  ecx
    jnz  @loop_d

    cld
    pop  esi
    pop  edi

  @exit:
end;

procedure Copy_BGR_A8_To_RGBA(source, dest: Pointer; count: Integer; alpha: Byte; reverse: Boolean);
asm
// eax = source
// edx = dest
// ecx = count
    test ecx,ecx
    js   @exit
    jz   @exit

    push edi

    test byte ptr [reverse],$FF
    jz   @not_reverse
    lea  edx,[edx + ecx * 4 - 4]
    std

  @not_reverse:
    mov  edi,edx
    mov  edx,eax
    mov  al,alpha
    ror  eax,8

  @loop_d:
    rol  eax,16
    mov  al,[edx]
    inc  edx
    rol  eax,16
    mov  ax,[edx]
    add  edx,2
    xchg al,ah
    stosd
    dec  ecx
    jnz  @loop_d

    cld
    pop  edi

  @exit:
end;

//  Make alpha from [asource] = ((r * 61) + (g * 174) + (b * 21)) shr 8;
procedure Copy_RGB_A24_To_RGBA(source, dest: Pointer; count: Integer; asource: Pointer; reverse: Boolean);
asm
// eax = source
// edx = dest
// ecx = count

    test ecx,ecx
    js   @exit
    jz   @exit

    push esi
    push edi
    push ebx

    test byte ptr [reverse],$FF
    jz   @not_reverse
    lea  edx,[edx + ecx * 4 - 4]
    std

  @not_reverse:
    mov  esi,eax
    mov  edi,edx
    mov  edx,[asource]

  @loop_d:
    mov  ax,[edx]
    add  edx,2
    shl  eax,16
    mov  al,[edx]
    inc  edx
    rol  eax,16

    mov  ebx,eax
    mov  al,21
    mul  bl
    rol  eax,16
    mov  al,174
    mul  bh
    mov  bx,ax
    rol  ebx,16
    mov  al,61
    mul  bl
    mov  bx,ax
    rol  eax,16
    add  ax,bx
    rol  ebx,16
    add  ax,bx
    shl  eax,16
    and  eax,$FF000000

    mov  bx,[esi]
    add  esi,2
    rol  ebx,16
    mov  bl,[esi]
    inc  esi
    xor  bh,bh
    rol  ebx,16
    or   eax,ebx
    stosd
    dec  ecx
    jnz  @loop_d

    cld
    pop  ebx
    pop  edi
    pop  esi

  @exit:
end;

//  Make alpha from [asource] = ((r * 61) + (g * 174) + (b * 21)) shr 8;
procedure Copy_BGR_A24_To_RGBA(source, dest: Pointer; count: Integer; asource: Pointer; reverse: Boolean);
asm
// eax = source
// edx = dest
// ecx = count

    test ecx,ecx
    js   @exit
    jz   @exit

    push esi
    push edi
    push ebx

    test byte ptr [reverse],$FF
    jz   @not_reverse
    lea  edx,[edx + ecx * 4 - 4]
    std

  @not_reverse:
    mov  esi,eax
    mov  edi,edx
    mov  edx,[asource]

  @loop_d:
    mov  ax,[edx]
    add  edx,2
    shl  eax,16
    mov  al,[edx]
    inc  edx
    rol  eax,16

    mov  ebx,eax
    mov  al,21
    mul  bl
    rol  eax,16
    mov  al,174
    mul  bh
    mov  bx,ax
    rol  ebx,16
    mov  al,61
    mul  bl
    mov  bx,ax
    rol  eax,16
    add  ax,bx
    rol  ebx,16
    add  ax,bx
    shl  eax,16
    and  eax,$FF000000

    xor  bh,bh
    mov  bl,[esi]
    inc  esi
    rol  ebx,16
    mov  bx,[esi]
    add  esi,2
    xchg bl,bh
    or   eax,ebx
    stosd
    dec  ecx
    jnz  @loop_d

    cld
    pop  ebx
    pop  edi
    pop  esi

  @exit:
end;

//  Make alpha from [asource] = ((r * 61) + (g * 174) + (b * 21)) shr 8;
procedure Copy_RGBA_A32_To_RGBA(source, dest: Pointer; count: Integer; asource: Pointer; reverse: Boolean);
asm
// eax = source
// edx = dest
// ecx = count

    test ecx,ecx
    js   @exit
    jz   @exit

    push esi
    push edi
    push ebx

    test byte ptr [reverse],$FF
    jz   @not_reverse
    lea  edx,[edx + ecx * 4 - 4]
    std

  @not_reverse:
    mov  edi,edx
    mov  esi,eax
    mov  edx,[asource]

  @loop_d:
    mov  eax,[edx]
    add  edx,4

    mov  ebx,eax
    mov  al,21
    mul  bl
    rol  eax,16
    mov  al,174
    mul  bh
    mov  bx,ax
    rol  ebx,16
    mov  al,61
    mul  bl
    mov  bx,ax
    rol  eax,16
    add  ax,bx
    rol  ebx,16
    add  ax,bx
    mov  bh,ah

    mov  eax,[esi]
    add  esi,4
    rol  eax,16
    mov  ah,bh
    rol  eax,16
    stosd
    dec  ecx
    jnz  @loop_d

    cld
    pop  ebx
    pop  edi
    pop  esi

  @exit:
end;

//  Make alpha from [asource] = ((r * 61) + (g * 174) + (b * 21)) shr 8;
procedure Copy_BGRA_A32_To_RGBA(source, dest: Pointer; count: Integer; asource: Pointer; reverse: Boolean);
asm
// eax = source
// edx = dest
// ecx = count

    test ecx,ecx
    js   @exit
    jz   @exit

    push esi
    push edi
    push ebx

    test byte ptr [reverse],$FF
    jz   @not_reverse
    lea  edx,[edx + ecx * 4 - 4]
    std

  @not_reverse:
    mov  edi,edx
    mov  esi,eax
    mov  edx,[asource]

  @loop_d:
    mov  eax,[edx]
    add  edx,4

    mov  ebx,eax
    mov  al,21
    mul  bl
    rol  eax,16
    mov  al,174
    mul  bh
    mov  bx,ax
    rol  ebx,16
    mov  al,61
    mul  bl
    mov  bx,ax
    rol  eax,16
    add  ax,bx
    rol  ebx,16
    add  ax,bx
    mov  bh,ah

    mov  eax,[esi]
    add  esi,4
    mov  bl,al
    rol  eax,16
    mov  ah,bh
    mov  bh,al
    mov  al,bl
    rol  eax,16
    mov  al,bh
    stosd
    dec  ecx
    jnz  @loop_d

    cld
    pop  ebx
    pop  edi
    pop  esi

  @exit:
end;

procedure Copy_BGRA_To_RGBA(source, dest: Pointer; count: Integer; reverse: Boolean);
begin
  Copy_RGBA_To_BGRA(source, dest, count, reverse);
end;

procedure Copy_BGR_To_RGB(source, dest: Pointer; count: Integer; reverse: Boolean);
begin
  Copy_RGB_To_BGR(source, dest, count, reverse);
end;

procedure Copy_BGR_A8_To_BGRA(source, dest: Pointer; count: Integer; asource: Pointer; reverse: Boolean);
begin
  Copy_RGB_A8_To_RGBA(source, dest, count, asource, reverse);
end;

procedure Copy_BGR_A8_To_BGRA(source, dest: Pointer; count: Integer; alpha: Byte; reverse: Boolean);
begin
  Copy_RGB_A8_To_RGBA(source, dest, count, alpha, reverse);
end;

procedure Copy_RGB_A8_To_BGRA(source, dest: Pointer; count: Integer; asource: Pointer; reverse: Boolean);
begin
  Copy_BGR_A8_To_RGBA(source, dest, count, asource, reverse);
end;

procedure Copy_RGB_A8_To_BGRA(source, dest: Pointer; count: Integer; alpha: Byte; reverse: Boolean);
begin
  Copy_BGR_A8_To_RGBA(source, dest, count, alpha, reverse);
end;

procedure Copy_BGRA_A32_To_BGRA(source, dest: Pointer; count: Integer; asource: Pointer; reverse: Boolean);
begin
  Copy_RGBA_A32_To_RGBA(source, dest, count, asource, reverse);
end;

procedure Copy_BGR_A24_To_BGRA(source, dest: Pointer; count: Integer; asource: Pointer; reverse: Boolean);
begin
  Copy_RGB_A24_To_RGBA(source, dest, count, asource, reverse);
end;

procedure Copy_RGB_A24_To_BGRA(source, dest: Pointer; count: Integer; asource: Pointer; reverse: Boolean);
begin
  Copy_RGB_A24_To_RGBA(source, dest, count, asource, reverse);
end;

procedure Copy_RGBA_A32_To_BGRA(source, dest: Pointer; count: Integer; asource: Pointer; reverse: Boolean);
begin
  Copy_BGRA_A32_To_RGBA(source, dest, count, asource, reverse);
end;

procedure CopyColor(source, dest: Pointer; count: Integer; reverse: Boolean);
asm
// eax = source
// edx = dest
// ecx = count

    test ecx,ecx
    js   @exit
    jz   @exit

    push edi

    test byte ptr reverse,$FF
    jz   @not_reverse
    lea  edx,[edx + ecx * 4 - 4]
    std

  @not_reverse:
    mov  edi,edx
    mov  edx,eax

  @loop_d:
    mov  eax,[edx]
    add  edx,4
    stosd
    dec  ecx
    jnz  @loop_d

    cld
    pop  edi

  @exit:
end;

procedure CopyColor(source, dest: Pointer; count: Integer; reverse: Boolean; alpha: Integer);
asm
  // eax = source
  // edx = dest
  // ecx = count

  // test the counter for zero or negativity
    cmp   ecx,0
    jle   @exit

    push  ebx

    mov   ebx,[alpha]     // ebx  <-  ** ** ** ma
    test  ebx,$FF         // ebx  <-  ma 00 00 00
    jz    @end_copy

    push  esi
    push  edi

    mov   esi,eax         // esi <- src
    mov   edi,edx         // edi <- dst

    test  byte ptr reverse,$FF
    jz    @loop_x
    lea   esi,[esi + ecx * 4 - 4]
    std

  // loop start
  @loop_x:
    lodsd
    and   eax,$00FFFFFF
    shl   ebx,24
    or    eax,ebx
    shr   ebx,24

  // p = w * f
    mov   edx,eax         // ebx  <-  fa fr fg fb
    and   eax,$00FF00FF   // eax  <-  00 fr 00 fb
    and   edx,$FF00FF00   // ebx  <-  fa 00 fg 00
    imul  eax,ebx         // eax  <-  pr ** pb **
    shr   edx,8           // ebx  <-  00 fa 00 fg
    imul  edx,ebx         // ebx  <-  pa ** pg **
    add   eax,$00800080
    and   eax,$FF00FF00   // eax  <-  pr 00 pb 00
    shr   eax,8           // eax  <-  00 pr ** pb
    add   edx,$00800080
    and   edx,$FF00FF00   // ebx  <-  pa 00 pg 00
    or    eax,edx         // eax  <-  pa pr pg pb

    push  ecx             // store counter

  // w = 1 - w; q = w * b
    mov   edx,[edi]
    xor   ebx,$000000FF   // ecx  <-  1 - ecx
    mov   ecx,edx         // ebx  <-  ba br bg bb
    and   edx,$00FF00FF   // esi  <-  00 br 00 bb
    and   ecx,$FF00FF00   // ebx  <-  ba 00 bg 00
    imul  edx,ebx         // esi  <-  qr ** qb **
    shr   ecx,8           // ebx  <-  00 ba 00 bg
    imul  ecx,ebx         // ebx  <-  qa ** qg **
    add   edx,$00800080
    and   edx,$FF00FF00   // esi  <-  qr 00 qb 00
    shr   edx,8           // esi  <-  00 qr ** qb
    add   ecx,$00800080
    and   ecx,$FF00FF00   // ebx  <-  qa 00 qg 00
    or    edx,ecx         // ebx  <-  qa qr qg qb

  // z = p + q (assuming no overflow at each byte)
    add   eax,edx         // eax  <-  za zr zg zb

  @full_copy:
    mov   [edi],eax

    pop   ecx             // restore counter

  @no_copy:
    add   edi,4

  // loop end
    xor   ebx,$FF
    dec   ecx
    jnz   @loop_x

    cld
    pop   edi
    pop   esi

  @end_copy:
    pop   ebx

  @exit:
end;

procedure CopyColor(source, dest: Pointer; scount0, dcount0, dcount, doffset: Integer; reverse: Boolean);
asm
// eax = source
// edx = dest
// ecx = scount0

    push edi
    push ebx

    mov  edi,edx          // edi <- dest
    mov  ebx,ecx          // ebx <- scount0
    mov  ecx,[dcount]     // ecx <- dcount

//  if dcount = 0 then Exit;
    test ecx,ecx
    js   @exit
    jz   @exit

    push esi
    mov  esi,eax          // esi <- source

//  doffset := dcount0 - doffset * scount0 mod dcount0 - 1;
    mov  eax,[doffset]
    imul ebx
    idiv dword ptr [dcount0]
    mov  eax,[dcount0]
    stc
    sbb  eax,edx
    mov  edx,eax          // edx <- doffset

    test byte ptr [reverse],$FF
    jz   @loop_inc_x
    lea  edi,[edi + ecx * 4 - 4]
    std

  @loop_inc_x:
    mov  eax,[esi]

  @loop_x:
    stosd
    sub  edx,ebx
    jc   @do_inc_esi
    dec  ecx
    jnz  @loop_x
    jmp  @end_copy

  @do_inc_esi:
    add  esi,4
    add  edx,[dcount0]
    jnc  @do_inc_esi
    dec  ecx
    jnz  @loop_inc_x

  @end_copy:
    cld
    pop  esi

  @exit:
    pop  ebx
    pop  edi
end;

procedure CopyColor(source, dest: Pointer; scount0, dcount0, dcount, doffset: Integer; reverse: Boolean; alpha: Integer);
asm
// eax = source
// edx = dest
// ecx = scount0

  // if dcount = 0 then Exit;
    cmp   ecx,0
    jle   @exit

    and   [alpha],$FF
    jz    @exit

    push  ebx
    push  esi
    push  edi

    mov   esi,eax          // esi <- source
    mov   edi,edx          // edi <- dest
    mov   ebx,ecx          // ebx <- scount0
    mov   ecx,[dcount]     // ecx <- dcount

  // doffset := dcount0 - doffset * scount0 mod dcount0 - 1;
    mov   eax,[doffset]
    imul  ebx
    idiv  [dcount0]
    mov   eax,[dcount0]
    stc
    sbb   eax,edx
    mov   edx,eax          // edx <- doffset

    test  byte ptr [reverse],$FF
    jz    @loop_inc_x
    lea   edi,[edi + ecx * 4 - 4]
    std

  @loop_inc_x:
    push  ecx
    push  ebx

    mov   eax,[esi]
    and   eax,$00FFFFFF
    mov   ecx,[alpha]
    shl   ecx,24
    or    eax,ecx
    shr   ecx,24

  // p = w * f
    mov   ebx,eax          // ebx  <-  fa fr fg fb
    and   eax,$00FF00FF    // eax  <-  00 fr 00 fb
    and   ebx,$FF00FF00    // ebx  <-  fa 00 fg 00
    imul  eax,ecx          // eax  <-  pr ** pb **
    shr   ebx,8            // ebx  <-  00 fa 00 fg
    imul  ebx,ecx          // ebx  <-  pa ** pg **
    add   eax,$00800080
    and   eax,$FF00FF00    // eax  <-  pr 00 pb 00
    shr   eax,8            // eax  <-  00 pr ** pb
    add   ebx,$00800080
    and   ebx,$FF00FF00    // ebx  <-  pa 00 pg 00
    or    ebx,eax          // ebx  <-  pa pr pg pb
    xor   ecx,$000000FF    // ecx  <-  1 - ecx

  @loop_x:
  // w = 1 - w; q = w * b
    push  edx
    mov   edx,[edi]
    mov   eax,edx          // ebx  <-  ba br bg bb
    and   edx,$00FF00FF    // esi  <-  00 br 00 bb
    and   eax,$FF00FF00    // ebx  <-  ba 00 bg 00
    imul  edx,ecx          // esi  <-  qr ** qb **
    shr   eax,8            // ebx  <-  00 ba 00 bg
    imul  eax,ecx          // ebx  <-  qa ** qg **
    add   edx,$00800080
    and   edx,$FF00FF00    // esi  <-  qr 00 qb 00
    shr   edx,8            // esi  <-  00 qr ** qb
    add   eax,$00800080
    and   eax,$FF00FF00    // ebx  <-  qa 00 qg 00
    or    eax,edx          // ebx  <-  qa qr qg qb

  // z = p + q (assuming no overflow at each byte)
    add   eax,ebx          // eax  <-  za zr zg zb
    stosd
    pop   edx
    sub   edx,[esp]
    jc    @do_inc_pop
    dec   [esp + 4]
    jnz   @loop_x
    pop   ebx
    pop   ecx
    jmp   @end_copy

  @do_inc_pop:
    pop   ebx
    pop   ecx

  @do_inc_esi:
    add   esi,4
    add   edx,[dcount0]
    jnc   @do_inc_esi
    dec   ecx
    jnz   @loop_inc_x

  @end_copy:
    cld
    pop   edi
    pop   esi
    pop   ebx

  @exit:
end;

procedure CopyAlpha(source, dest: Pointer; count: Integer; reverse: Boolean);
asm
  // eax = source
  // edx = dest
  // ecx = count

  // test the counter for zero or negativity
    test ecx,ecx
    js   @exit
    jz   @exit

    test byte ptr reverse,$FF
    jz   @not_reverse
    lea  eax,[eax + ecx * 4 - 4]
    std

  @not_reverse:
    push ebx
    push esi
    push edi

    mov  esi,eax         // esi <- src
    mov  edi,edx         // edi <- dst

  // loop start
  @loop_x:
    lodsd
    test eax,$FF000000
    jz   @no_copy        // complete transparency, proceed to next point

    push ecx             // store counter

  // get weight w = fa * m
    mov  ecx,eax         // ecx  <-  fa fr fg fb
    shr  ecx,24          // ecx  <-  00 00 00 fa

  // test fa = 255 ?
    cmp  ecx,$FF
    jz   @full_copy

  // p = w * f
    mov  ebx,eax         // ebx  <-  fa fr fg fb
    and  eax,$00FF00FF   // eax  <-  00 fr 00 fb
    and  ebx,$FF00FF00   // ebx  <-  fa 00 fg 00
    imul eax,ecx         // eax  <-  pr ** pb **
    shr  ebx,8           // ebx  <-  00 fa 00 fg
    imul ebx,ecx         // ebx  <-  pa ** pg **
    add  eax,$00800080
    and  eax,$FF00FF00   // eax  <-  pr 00 pb 00
    shr  eax,8           // eax  <-  00 pr ** pb
    add  ebx,$00800080
    and  ebx,$FF00FF00   // ebx  <-  pa 00 pg 00
    or   eax,ebx         // eax  <-  pa pr pg pb

  // w = 1 - w; q = w * b
    mov  edx,[edi]
    xor  ecx,$000000FF   // ecx  <-  1 - ecx
    mov  ebx,edx         // ebx  <-  ba br bg bb
    and  edx,$00FF00FF   // esi  <-  00 br 00 bb
    and  ebx,$FF00FF00   // ebx  <-  ba 00 bg 00
    imul edx,ecx         // esi  <-  qr ** qb **
    shr  ebx,8           // ebx  <-  00 ba 00 bg
    imul ebx,ecx         // ebx  <-  qa ** qg **
    add  edx,$00800080
    and  edx,$FF00FF00   // esi  <-  qr 00 qb 00
    shr  edx,8           // esi  <-  00 qr ** qb
    add  ebx,$00800080
    and  ebx,$FF00FF00   // ebx  <-  qa 00 qg 00
    or   ebx,edx         // ebx  <-  qa qr qg qb

  // z = p + q (assuming no overflow at each byte)
    add  eax,ebx         // eax  <-  za zr zg zb
  @full_copy:
    mov  [edi],eax

    pop  ecx             // restore counter

  @no_copy:
    add  edi,4

  // loop end
    dec  ecx
    jnz  @loop_x

    cld
    pop  edi
    pop  esi
    pop  ebx
@exit:
end;

procedure CopyAlpha(source, dest: Pointer; count: Integer; reverse: Boolean; alpha: Integer);
asm // copy alpha color with master alpha
  // eax = source
  // edx = dest
  // ecx = count

  // test the counter for zero or negativity
    test  ecx,ecx
    js    @exit
    jz    @exit

    test  byte ptr reverse,$FF
    jz    @not_reverse
    lea   eax,[eax + ecx * 4 - 4]
    std

  @not_reverse:
    push  ebx
    push  esi
    push  edi

    mov   esi,eax         // esi <- src
    mov   edi,edx         // edi <- dst
    mov   edx,[alpha]

  // loop start
  @loop_x:
    lodsd
    test  eax,$FF000000
    jz    @no_copy        // complete transparency, proceed to next point

  // get weight w = fa * m
    mov   ebx,eax         // ebx  <-  fa fr fg fb
    shr   ebx,24          // ebx  <-  00 00 00 fa
    inc   ebx             // 255:256 range bias
    imul  ebx,edx         // ebx  <-  00 00  w **
    shr   ebx,8           // ebx  <-  00 00 00  w
    jz    @no_copy        // w = 0 ?  => write nothing

    push ecx              // store counter
    push edx              // store master alpha

  // p = w * f
    mov   ecx,eax         // ecx  <-  fa fr fg fb
    and   eax,$00FF00FF   // eax  <-  00 fr 00 fb
    and   ecx,$FF00FF00   // ecx  <-  fa 00 fg 00
    imul  eax,ebx         // eax  <-  pr ** pb **
    shr   ecx,8           // ecx  <-  00 fa 00 fg
    imul  ecx,ebx         // ecx  <-  pa ** pg **
    add   eax,$00800080
    and   eax,$FF00FF00   // eax  <-  pr 00 pb 00
    shr   eax,8           // eax  <-  00 pr ** pb
    add   ecx,$00800080
    and   ecx,$FF00FF00   // ecx  <-  pa 00 pg 00
    or    eax,ecx         // eax  <-  pa pr pg pb

  // w = 1 - w; q = w * b
    mov   edx,[edi]
    xor   ebx,$000000FF   // ebx  <-  1 - ebx
    mov   ecx,edx         // ecx  <-  ba br bg bb
    and   edx,$00FF00FF   // edx  <-  00 br 00 bb
    and   ecx,$FF00FF00   // ecx  <-  ba 00 bg 00
    imul  edx,ebx         // edx  <-  qr ** qb **
    shr   ecx,8           // ecx  <-  00 ba 00 bg
    imul  ecx,ebx         // ecx  <-  qa ** qg **
    add   edx,$00800080
    and   edx,$FF00FF00   // edx  <-  qr 00 qb 00
    shr   edx,8           // edx  <-  00 qr ** qb
    add   ecx,$00800080
    and   ecx,$FF00FF00   // ecx  <-  qa 00 qg 00
    or    ecx,edx         // ecx  <-  qa qr qg qb

  // z = p + q (assuming no overflow at each byte)
    add   eax,ecx         // eax  <-  za zr zg zb

  @full_copy:
    mov   [edi],eax

    pop   edx             // restore master alpha
    pop   ecx             // restore counter

  @no_copy:
    add   edi,4

  // loop end
    dec   ecx
    jnz   @loop_x

    cld
    pop   edi
    pop   esi
    pop   ebx

  @exit:
end;

procedure CopyAlpha(source, dest: Pointer; scount0, dcount0, dcount, doffset: Integer; reverse: Boolean);
asm
// eax = source
// edx = dest
// ecx = scount0

    push edi
    push ebx

    mov  edi,edx          // edi <- dest
    mov  ebx,ecx          // ebx <- scount0
    mov  ecx,[dcount]     // ecx <- dcount

  // if dcount = 0 then Exit;
    test ecx,ecx
    js   @exit
    jz   @exit

    push esi
    mov  esi,eax          // esi <- source

  // doffset := dcount0 - doffset * scount0 mod dcount0 - 1;
    mov  eax,[doffset]
    imul ebx
    idiv [dcount0]
    mov  eax,[dcount0]
    stc
    sbb  eax,edx
    mov  edx,eax          // edx <- doffset

    test byte ptr [reverse],$FF
    jz   @loop_inc_x
    lea  edi,[edi + ecx * 4 - 4]
    std

  @loop_inc_x:
    mov  eax,[esi]
    test eax,$FF000000
    jz   @loop_no_x
    cmp  eax,$FF000000
    jc   @do_alpha

  @loop_fill_x:
    stosd
    sub  edx,ebx
    jc   @do_inc_esi
    dec  ecx
    jnz  @loop_fill_x
    jmp  @end_copy

  @loop_no_x:
    mov  eax,[edi]
    stosd
    sub  edx,ebx
    jc   @do_inc_esi
    dec  ecx
    jnz  @loop_no_x
    jmp  @end_copy

  // get weight w = fa * m
  @do_alpha:
    push ecx
    push ebx

    mov  ecx,eax          // ecx  <-  fa fr fg fb
    shr  ecx,24           // ecx  <-  00 00 00 fa

  // p = w * f
    mov  ebx,eax          // ebx  <-  fa fr fg fb
    and  eax,$00FF00FF    // eax  <-  00 fr 00 fb
    and  ebx,$FF00FF00    // ebx  <-  fa 00 fg 00
    imul eax,ecx          // eax  <-  pr ** pb **
    shr  ebx,8            // ebx  <-  00 fa 00 fg
    imul ebx,ecx          // ebx  <-  pa ** pg **
    add  eax,$00800080
    and  eax,$FF00FF00    // eax  <-  pr 00 pb 00
    shr  eax,8            // eax  <-  00 pr ** pb
    add  ebx,$00800080
    and  ebx,$FF00FF00    // ebx  <-  pa 00 pg 00
    or   ebx,eax          // ebx  <-  pa pr pg pb
    xor  ecx,$000000FF    // ecx  <-  1 - ecx

  @loop_x:
  // w = 1 - w; q = w * b
    push edx
    mov  edx,[edi]
    mov  eax,edx          // ebx  <-  ba br bg bb
    and  edx,$00FF00FF    // esi  <-  00 br 00 bb
    and  eax,$FF00FF00    // ebx  <-  ba 00 bg 00
    imul edx,ecx          // esi  <-  qr ** qb **
    shr  eax,8            // ebx  <-  00 ba 00 bg
    imul eax,ecx          // ebx  <-  qa ** qg **
    add  edx,$00800080
    and  edx,$FF00FF00    // esi  <-  qr 00 qb 00
    shr  edx,8            // esi  <-  00 qr ** qb
    add  eax,$00800080
    and  eax,$FF00FF00    // ebx  <-  qa 00 qg 00
    or   eax,edx          // ebx  <-  qa qr qg qb

  // z = p + q (assuming no overflow at each byte)
    add  eax,ebx          // eax  <-  za zr zg zb
    stosd
    pop  edx
    sub  edx,[esp]
    jc   @do_inc_pop
    dec  [esp + 4]
    jnz  @loop_x
    pop  ebx
    pop  ecx
    jmp  @end_copy

  @do_inc_pop:
    pop  ebx
    pop  ecx

  @do_inc_esi:
    add  esi,4
    add  edx,[dcount0]
    jnc  @do_inc_esi
    dec  ecx
    jnz  @loop_inc_x

  @end_copy:
    cld
    pop  esi

  @exit:
    pop  ebx
    pop  edi
end;

procedure CopyAlpha(source, dest: Pointer; scount0, dcount0, dcount, doffset: Integer; reverse: Boolean; alpha: Integer);
asm // copy alpha color with scale & master alpha
  // eax = source
  // edx = dest
  // ecx = scount0

    push  edi
    push  ebx

    mov   edi,edx          // edi <- dest
    mov   ebx,ecx          // ebx <- scount0
    mov   ecx,[dcount]     // ecx <- dcount

  // if dcount = 0 then Exit;
    test  ecx,ecx
    js    @exit
    jz    @exit

    push  esi
    mov   esi,eax          // esi <- source

  // doffset := dcount0 - doffset * scount0 mod dcount0 - 1;
    mov   eax,[doffset]
    imul  ebx
    idiv  [dcount0]
    mov   eax,[dcount0]
    stc
    sbb   eax,edx
    mov   edx,eax          // edx <- doffset

    test  byte ptr [reverse],$FF
    jz    @loop_inc_x
    lea   edi,[edi + ecx * 4 - 4]
    std

  @loop_inc_x:
    mov   eax,[esi]
    test  eax,$FF000000
    jz    @loop_no_x

    push  ecx
  //    push  ebx

  // get weight w = fa * m
    mov   ecx,eax         // ecx  <-  fa fr fg fb
    shr   ecx,24          // ecx  <-  00 00 00 fa
    inc   ecx             // 255:256 range bias
    imul  ecx,[alpha]     // ecx  <-  00 00  w **
    shr   ecx,8           // ecx  <-  00 00 00  w
    jz    @no_copy        // w = 0 ?  => write nothing

    push  ebx

  // p = w * f
    mov   ebx,eax          // ebx  <-  fa fr fg fb
    and   eax,$00FF00FF    // eax  <-  00 fr 00 fb
    and   ebx,$FF00FF00    // ebx  <-  fa 00 fg 00
    imul  eax,ecx          // eax  <-  pr ** pb **
    shr   ebx,8            // ebx  <-  00 fa 00 fg
    imul  ebx,ecx          // ebx  <-  pa ** pg **
    add   eax,$00800080
    and   eax,$FF00FF00    // eax  <-  pr 00 pb 00
    shr   eax,8            // eax  <-  00 pr ** pb
    add   ebx,$00800080
    and   ebx,$FF00FF00    // ebx  <-  pa 00 pg 00
    or    ebx,eax          // ebx  <-  pa pr pg pb
    xor   ecx,$000000FF    // ecx  <-  1 - ecx

  @loop_x:
  // w = 1 - w; q = w * b
    push  edx
    mov   edx,[edi]
    mov   eax,edx          // ebx  <-  ba br bg bb
    and   edx,$00FF00FF    // esi  <-  00 br 00 bb
    and   eax,$FF00FF00    // ebx  <-  ba 00 bg 00
    imul  edx,ecx          // esi  <-  qr ** qb **
    shr   eax,8            // ebx  <-  00 ba 00 bg
    imul  eax,ecx          // ebx  <-  qa ** qg **
    add   edx,$00800080
    and   edx,$FF00FF00    // esi  <-  qr 00 qb 00
    shr   edx,8            // esi  <-  00 qr ** qb
    add   eax,$00800080
    and   eax,$FF00FF00    // ebx  <-  qa 00 qg 00
    or    eax,edx          // ebx  <-  qa qr qg qb

  // z = p + q (assuming no overflow at each byte)
    add   eax,ebx          // eax  <-  za zr zg zb
    stosd
    pop   edx
    sub   edx,[esp]
    jc    @do_inc_pop
    dec   [esp + 4]
    jnz   @loop_x
    pop   ebx
    pop   ecx
    jmp   @end_copy

  @no_copy:
//    pop   ebx
    pop   ecx

  @loop_no_x:
    mov   eax,[edi]
    stosd
    sub   edx,ebx
    jc    @do_inc_esi
    dec   ecx
    jnz   @loop_no_x
    jmp   @end_copy

  @do_inc_pop:
    pop   ebx
    pop   ecx

  @do_inc_esi:
    add   esi,4
    add   edx,[dcount0]
    jnc   @do_inc_esi
    dec   ecx
    jnz   @loop_inc_x

  @end_copy:
    cld
    pop   esi

  @exit:
    pop   ebx
    pop   edi
end;

procedure CopyMono(source, dest: Pointer; count: Integer; reverse: Boolean; color: TColor32);
asm // copy alpha color replace with monocolor
  // eax = source
  // edx = dest
  // ecx = count

  // test the counter for zero or negativity
    test  ecx,ecx
    js    @exit
    jz    @exit

  // complete transparency, exit
    test  [color],$FF000000
    jz    @exit

    test  byte ptr reverse,$FF
    jz    @not_reverse
    lea   eax,[eax + ecx * 4 - 4]
    std

  @not_reverse:
    push  ebx
    push  esi
    push  edi

    mov   esi,eax         // esi <- src
    mov   edi,edx         // edi <- dst

  // loop start
  @loop_x:
    lodsd
    shr   eax,24
    jz    @no_copy        // complete transparency, proceed to next point

  // get weight w = fa * m
    mov   ebx,eax         // ebx  <-  00 00 00 ma
    mov   eax,[color]     // eax  <-  fa fr fg fb
    mov   edx,eax         // edx  <-  fa fr fg fb
    shr   edx,24          // edx  <-  00 00 00 fa
    inc   edx             // 255:256 range bias
    imul  edx,ebx         // ebx  <-  00 00  w **
    shr   edx,8           // ebx  <-  00 00 00  w
    jz    @no_copy        // w = 0 ?  => write nothing

  // test fa = 255 ?
    cmp   edx,$FF
    jz    @full_copy

    push  ecx             // store counter

  // p = w * f
    mov   ebx,eax         // ebx  <-  fa fr fg fb
    and   eax,$00FF00FF   // eax  <-  00 fr 00 fb
    and   ebx,$FF00FF00   // ebx  <-  fa 00 fg 00
    imul  eax,edx         // eax  <-  pr ** pb **
    shr   ebx,8           // ebx  <-  00 fa 00 fg
    imul  ebx,edx         // ebx  <-  pa ** pg **
    add   eax,$00800080
    and   eax,$FF00FF00   // eax  <-  pr 00 pb 00
    shr   eax,8           // eax  <-  00 pr ** pb
    add   ebx,$00800080
    and   ebx,$FF00FF00   // ebx  <-  pa 00 pg 00
    or    eax,ebx         // eax  <-  pa pr pg pb

  // w = 1 - w; q = w * b
    mov   ecx,[edi]
    xor   edx,$000000FF   // ecx  <-  1 - ecx
    mov   ebx,ecx         // ebx  <-  ba br bg bb
    and   ecx,$00FF00FF   // esi  <-  00 br 00 bb
    and   ebx,$FF00FF00   // ebx  <-  ba 00 bg 00
    imul  ecx,edx         // esi  <-  qr ** qb **
    shr   ebx,8           // ebx  <-  00 ba 00 bg
    imul  ebx,edx         // ebx  <-  qa ** qg **
    add   ecx,$00800080
    and   ecx,$FF00FF00   // esi  <-  qr 00 qb 00
    shr   ecx,8           // esi  <-  00 qr ** qb
    add   ebx,$00800080
    and   ebx,$FF00FF00   // ebx  <-  qa 00 qg 00
    or    ebx,ecx         // ebx  <-  qa qr qg qb

  // z = p + q (assuming no overflow at each byte)
    add   eax,ebx         // eax  <-  za zr zg zb
    pop   ecx             // restore counter

  @full_copy:
    mov   [edi],eax

  @no_copy:
    add   edi,4

  // loop end
    dec   ecx
    jnz   @loop_x

    cld
    pop   edi
    pop   esi
    pop   ebx

  @exit:
end;

procedure CopyMono(source, dest: Pointer; count: Integer; reverse: Boolean; color: TColor32; alpha: Integer);
asm // copy alpha color replace with monocolor & master alpha
  // eax = source
  // edx = dest
  // ecx = count

  // test the counter for zero or negativity
    test  ecx,ecx
    js    @exit
    jz    @exit

  // complete transparency, exit
    test  [alpha],$000000FF
    jz    @exit

  // complete transparency, exit
    test  [color],$FF000000
    jz    @exit

    test  byte ptr reverse,$FF
    jz    @not_reverse
    lea   eax,[eax + ecx * 4 - 4]
    std

  @not_reverse:
    push  ebx
    push  esi
    push  edi

    mov   esi,eax         // esi <- src
    mov   edi,edx         // edi <- dst

  // loop start
  @loop_x:
    lodsd
    shr   eax,24
    jz    @no_copy        // complete transparency, proceed to next point

  // get weight w = fa * m
    mov   ebx,eax         // ebx  <-  00 00 00 ma
    mov   eax,[color]     // eax  <-  fa fr fg fb
    mov   edx,eax         // edx  <-  fa fr fg fb
    shr   edx,24          // edx  <-  00 00 00 fa
    inc   edx             // 255:256 range bias
    imul  edx,ebx         // ebx  <-  00 00  w **
    shr   edx,8           // ebx  <-  00 00 00  w
    jz    @no_copy        // w = 0 ?  => write nothing

  // get weight w = fa * m
    inc   edx             // 255:256 range bias
    imul  edx,[alpha]     // ebx  <-  00 00  w **
    shr   edx,8           // ebx  <-  00 00 00  w
    jz    @no_copy        // w = 0 ?  => write nothing

  // test fa = 255 ?
    cmp   edx,$FF
    jz    @full_copy

    push  ecx             // store counter

  // p = w * f
    mov   ebx,eax         // ebx  <-  fa fr fg fb
    and   eax,$00FF00FF   // eax  <-  00 fr 00 fb
    and   ebx,$FF00FF00   // ebx  <-  fa 00 fg 00
    imul  eax,edx         // eax  <-  pr ** pb **
    shr   ebx,8           // ebx  <-  00 fa 00 fg
    imul  ebx,edx         // ebx  <-  pa ** pg **
    add   eax,$00800080
    and   eax,$FF00FF00   // eax  <-  pr 00 pb 00
    shr   eax,8           // eax  <-  00 pr ** pb
    add   ebx,$00800080
    and   ebx,$FF00FF00   // ebx  <-  pa 00 pg 00
    or    eax,ebx         // eax  <-  pa pr pg pb

  // w = 1 - w; q = w * b
    mov   ecx,[edi]
    xor   edx,$000000FF   // ecx  <-  1 - ecx
    mov   ebx,ecx         // ebx  <-  ba br bg bb
    and   ecx,$00FF00FF   // esi  <-  00 br 00 bb
    and   ebx,$FF00FF00   // ebx  <-  ba 00 bg 00
    imul  ecx,edx         // esi  <-  qr ** qb **
    shr   ebx,8           // ebx  <-  00 ba 00 bg
    imul  ebx,edx         // ebx  <-  qa ** qg **
    add   ecx,$00800080
    and   ecx,$FF00FF00   // esi  <-  qr 00 qb 00
    shr   ecx,8           // esi  <-  00 qr ** qb
    add   ebx,$00800080
    and   ebx,$FF00FF00   // ebx  <-  qa 00 qg 00
    or    ebx,ecx         // ebx  <-  qa qr qg qb

  // z = p + q (assuming no overflow at each byte)
    add   eax,ebx         // eax  <-  za zr zg zb
    pop   ecx             // restore counter

  @full_copy:
    mov   [edi],eax

  @no_copy:
    add   edi,4

  // loop end
    dec   ecx
    jnz   @loop_x

    cld
    pop   edi
    pop   esi
    pop   ebx

  @exit:
end;

procedure CopyMono(source, dest: Pointer; scount0, dcount0, dcount, doffset: Integer; reverse: Boolean; color: TColor32);
asm // copy alpha color replace with monocolor & scale
// eax = source
// edx = dest
// ecx = scount0

    push  edi
    push  ebx

    mov   edi,edx          // edi <- dest
    mov   ebx,ecx          // ebx <- scount0
    mov   ecx,[dcount]     // ecx <- dcount

  // if dcount = 0 then Exit;
    test  ecx,ecx
    js    @exit
    jz    @exit

    push  esi
    mov   esi,eax          // esi <- source

  // doffset := dcount0 - doffset * scount0 mod dcount0 - 1;
    mov   eax,[doffset]
    imul  ebx
    idiv  [dcount0]
    mov   eax,[dcount0]
    stc
    sbb   eax,edx
    mov   edx,eax          // edx <- doffset

    test  byte ptr [reverse],$FF
    jz    @loop_inc_x
    lea   edi,[edi + ecx * 4 - 4]
    std

  @loop_inc_x:
    mov   eax,[esi]
    shr   eax,24
    jz    @loop_no_x

    push  ecx
    push  ebx

  // get weight w = fa * m
    mov   ebx,eax         // ebx  <-  00 00 00 ma
    mov   eax,[color]     // eax  <-  fa fr fg fb
    mov   ecx,eax         // edx  <-  fa fr fg fb
    shr   ecx,24          // edx  <-  00 00 00 fa
    inc   ecx             // 255:256 range bias
    imul  ecx,ebx         // ebx  <-  00 00  w **
    shr   ecx,8           // ebx  <-  00 00 00  w
    jz    @no_copy        // w = 0 ?  => write nothing

  // p = w * f
    mov   ebx,eax          // ebx  <-  fa fr fg fb
    and   eax,$00FF00FF    // eax  <-  00 fr 00 fb
    and   ebx,$FF00FF00    // ebx  <-  fa 00 fg 00
    imul  eax,ecx          // eax  <-  pr ** pb **
    shr   ebx,8            // ebx  <-  00 fa 00 fg
    imul  ebx,ecx          // ebx  <-  pa ** pg **
    add   eax,$00800080
    and   eax,$FF00FF00    // eax  <-  pr 00 pb 00
    shr   eax,8            // eax  <-  00 pr ** pb
    add   ebx,$00800080
    and   ebx,$FF00FF00    // ebx  <-  pa 00 pg 00
    or    ebx,eax          // ebx  <-  pa pr pg pb
    xor   ecx,$000000FF    // ecx  <-  1 - ecx

  @loop_x:
  // w = 1 - w; q = w * b
    push  edx
    mov   edx,[edi]
    mov   eax,edx          // ebx  <-  ba br bg bb
    and   edx,$00FF00FF    // esi  <-  00 br 00 bb
    and   eax,$FF00FF00    // ebx  <-  ba 00 bg 00
    imul  edx,ecx          // esi  <-  qr ** qb **
    shr   eax,8            // ebx  <-  00 ba 00 bg
    imul  eax,ecx          // ebx  <-  qa ** qg **
    add   edx,$00800080
    and   edx,$FF00FF00    // esi  <-  qr 00 qb 00
    shr   edx,8            // esi  <-  00 qr ** qb
    add   eax,$00800080
    and   eax,$FF00FF00    // ebx  <-  qa 00 qg 00
    or    eax,edx          // ebx  <-  qa qr qg qb

  // z = p + q (assuming no overflow at each byte)
    add   eax,ebx          // eax  <-  za zr zg zb
    stosd
    pop   edx
    sub   edx,[esp]
    jc    @do_inc_pop
    dec   [esp + 4]
    jnz   @loop_x
    pop   ebx
    pop   ecx
    jmp   @end_copy

  @no_copy:
    pop   ebx
    pop   ecx

  @loop_no_x:
    mov   eax,[edi]
    stosd
    sub   edx,ebx
    jc    @do_inc_esi
    dec   ecx
    jnz   @loop_no_x
    jmp   @end_copy

  @do_inc_pop:
    pop   ebx
    pop   ecx

  @do_inc_esi:
    add   esi,4
    add   edx,[dcount0]
    jnc   @do_inc_esi
    dec   ecx
    jnz   @loop_inc_x

  @end_copy:
    cld
    pop   esi

  @exit:
    pop   ebx
    pop   edi
end;

procedure CopyMono(source, dest: Pointer; scount0, dcount0, dcount, doffset: Integer; reverse: Boolean; color: TColor32; alpha: Integer);
asm // copy alpha color replace with monocolor & scale & master alpha
// eax = source
// edx = dest
// ecx = scount0

    push  edi
    push  ebx

    mov   edi,edx          // edi <- dest
    mov   ebx,ecx          // ebx <- scount0
    mov   ecx,[dcount]     // ecx <- dcount

  // if dcount = 0 then Exit;
    test  ecx,ecx
    js    @exit
    jz    @exit

    push  esi
    mov   esi,eax          // esi <- source

  // doffset := dcount0 - doffset * scount0 mod dcount0 - 1;
    mov   eax,[doffset]
    imul  ebx
    idiv  [dcount0]
    mov   eax,[dcount0]
    stc
    sbb   eax,edx
    mov   edx,eax          // edx <- doffset

    test  byte ptr [reverse],$FF
    jz    @loop_inc_x
    lea   edi,[edi + ecx * 4 - 4]
    std

  @loop_inc_x:
    mov   eax,[esi]
    shr   eax,24
    jz    @loop_no_x

    push  ecx
    push  ebx

  // get weight w = fa * m
    mov   ebx,eax         // ebx  <-  00 00 00 ma
    mov   eax,[color]     // eax  <-  fa fr fg fb
    mov   ecx,eax         // edx  <-  fa fr fg fb
    shr   ecx,24          // edx  <-  00 00 00 fa
    inc   ecx             // 255:256 range bias
    imul  ecx,ebx         // ebx  <-  00 00  w **
    shr   ecx,8           // ebx  <-  00 00 00  w
    jz    @no_copy        // w = 0 ?  => write nothing

  // get weight w = fa * m
    inc   ecx             // 255:256 range bias
    imul  ecx,[alpha]     // ebx  <-  00 00  w **
    shr   ecx,8           // ebx  <-  00 00 00  w
    jz    @no_copy        // w = 0 ?  => write nothing

  // p = w * f
    mov   ebx,eax          // ebx  <-  fa fr fg fb
    and   eax,$00FF00FF    // eax  <-  00 fr 00 fb
    and   ebx,$FF00FF00    // ebx  <-  fa 00 fg 00
    imul  eax,ecx          // eax  <-  pr ** pb **
    shr   ebx,8            // ebx  <-  00 fa 00 fg
    imul  ebx,ecx          // ebx  <-  pa ** pg **
    add   eax,$00800080
    and   eax,$FF00FF00    // eax  <-  pr 00 pb 00
    shr   eax,8            // eax  <-  00 pr ** pb
    add   ebx,$00800080
    and   ebx,$FF00FF00    // ebx  <-  pa 00 pg 00
    or    ebx,eax          // ebx  <-  pa pr pg pb
    xor   ecx,$000000FF    // ecx  <-  1 - ecx

  @loop_x:
  // w = 1 - w; q = w * b
    push  edx
    mov   edx,[edi]
    mov   eax,edx          // ebx  <-  ba br bg bb
    and   edx,$00FF00FF    // esi  <-  00 br 00 bb
    and   eax,$FF00FF00    // ebx  <-  ba 00 bg 00
    imul  edx,ecx          // esi  <-  qr ** qb **
    shr   eax,8            // ebx  <-  00 ba 00 bg
    imul  eax,ecx          // ebx  <-  qa ** qg **
    add   edx,$00800080
    and   edx,$FF00FF00    // esi  <-  qr 00 qb 00
    shr   edx,8            // esi  <-  00 qr ** qb
    add   eax,$00800080
    and   eax,$FF00FF00    // ebx  <-  qa 00 qg 00
    or    eax,edx          // ebx  <-  qa qr qg qb

  // z = p + q (assuming no overflow at each byte)
    add   eax,ebx          // eax  <-  za zr zg zb
    stosd
    pop   edx
    sub   edx,[esp]
    jc    @do_inc_pop
    dec   [esp + 4]
    jnz   @loop_x
    pop   ebx
    pop   ecx
    jmp   @end_copy

  @no_copy:
    pop   ebx
    pop   ecx

  @loop_no_x:
    mov   eax,[edi]
    stosd
    sub   edx,ebx
    jc    @do_inc_esi
    dec   ecx
    jnz   @loop_no_x
    jmp   @end_copy

  @do_inc_pop:
    pop   ebx
    pop   ecx

  @do_inc_esi:
    add   esi,4
    add   edx,[dcount0]
    jnc   @do_inc_esi
    dec   ecx
    jnz   @loop_inc_x

  @end_copy:
    cld
    pop   esi

  @exit:
    pop   ebx
    pop   edi
end;

procedure CopyAlphaPalette(source, dest: Pointer; count: Integer; reverse: Boolean; pal: Pointer; palcount: Integer);
asm
  // eax = source
  // edx = dest
  // ecx = count

  // test the counter for zero or negativity
    test ecx,ecx
    js   @exit
    jz   @exit

    test byte ptr reverse,$FF
    jz   @not_reverse
    lea  eax,[eax + ecx * 4 - 4]
    std

  @not_reverse:
    push ebx
    push esi
    push edi

    mov  esi,eax         // esi <- src
    mov  edi,edx         // edi <- dst

  // loop start
  @loop_x:
    lodsd
    cmp   eax,[palcount]
    jnc   @no_pal
    shl   eax,2
    add   eax,dword ptr [pal]
    mov   eax,[eax]

  @no_pal:
    test eax,$FF000000
    jz   @no_copy        // complete transparency, proceed to next point

    push ecx             // store counter

  // get weight w = fa * m
    mov  ecx,eax         // ecx  <-  fa fr fg fb
    shr  ecx,24          // ecx  <-  00 00 00 fa

  // test fa = 255 ?
    cmp  ecx,$FF
    jz   @full_copy

  // p = w * f
    mov  ebx,eax         // ebx  <-  fa fr fg fb
    and  eax,$00FF00FF   // eax  <-  00 fr 00 fb
    and  ebx,$FF00FF00   // ebx  <-  fa 00 fg 00
    imul eax,ecx         // eax  <-  pr ** pb **
    shr  ebx,8           // ebx  <-  00 fa 00 fg
    imul ebx,ecx         // ebx  <-  pa ** pg **
    add  eax,$00800080
    and  eax,$FF00FF00   // eax  <-  pr 00 pb 00
    shr  eax,8           // eax  <-  00 pr ** pb
    add  ebx,$00800080
    and  ebx,$FF00FF00   // ebx  <-  pa 00 pg 00
    or   eax,ebx         // eax  <-  pa pr pg pb

  // w = 1 - w; q = w * b
    mov  edx,[edi]
    xor  ecx,$000000FF   // ecx  <-  1 - ecx
    mov  ebx,edx         // ebx  <-  ba br bg bb
    and  edx,$00FF00FF   // esi  <-  00 br 00 bb
    and  ebx,$FF00FF00   // ebx  <-  ba 00 bg 00
    imul edx,ecx         // esi  <-  qr ** qb **
    shr  ebx,8           // ebx  <-  00 ba 00 bg
    imul ebx,ecx         // ebx  <-  qa ** qg **
    add  edx,$00800080
    and  edx,$FF00FF00   // esi  <-  qr 00 qb 00
    shr  edx,8           // esi  <-  00 qr ** qb
    add  ebx,$00800080
    and  ebx,$FF00FF00   // ebx  <-  qa 00 qg 00
    or   ebx,edx         // ebx  <-  qa qr qg qb

  // z = p + q (assuming no overflow at each byte)
    add  eax,ebx         // eax  <-  za zr zg zb
  @full_copy:
    mov  [edi],eax

    pop  ecx             // restore counter

  @no_copy:
    add  edi,4

  // loop end
    dec  ecx
    jnz  @loop_x

    cld
    pop  edi
    pop  esi
    pop  ebx
@exit:
end;

procedure CopyAlphaPalette(source, dest: Pointer; count: Integer; reverse: Boolean; pal: Pointer; palcount: Integer; alpha: Integer);
asm // copy alpha color with master alpha
  // eax = source
  // edx = dest
  // ecx = count

  // test the counter for zero or negativity
    test  ecx,ecx
    js    @exit
    jz    @exit

    test  byte ptr reverse,$FF
    jz    @not_reverse
    lea   eax,[eax + ecx * 4 - 4]
    std

  @not_reverse:
    push  ebx
    push  esi
    push  edi

    mov   esi,eax         // esi <- src
    mov   edi,edx         // edi <- dst
    mov   edx,[alpha]

  // loop start
  @loop_x:
    lodsd
    cmp   eax,[palcount]
    jnc   @no_pal
    shl   eax,2
    add   eax,dword ptr [pal]
    mov   eax,[eax]

  @no_pal:
    test  eax,$FF000000
    jz    @no_copy        // complete transparency, proceed to next point

  // get weight w = fa * m
    mov   ebx,eax         // ebx  <-  fa fr fg fb
    shr   ebx,24          // ebx  <-  00 00 00 fa
    inc   ebx             // 255:256 range bias
    imul  ebx,edx         // ebx  <-  00 00  w **
    shr   ebx,8           // ebx  <-  00 00 00  w
    jz    @no_copy        // w = 0 ?  => write nothing

    push ecx              // store counter
    push edx              // store master alpha

  // p = w * f
    mov   ecx,eax         // ecx  <-  fa fr fg fb
    and   eax,$00FF00FF   // eax  <-  00 fr 00 fb
    and   ecx,$FF00FF00   // ecx  <-  fa 00 fg 00
    imul  eax,ebx         // eax  <-  pr ** pb **
    shr   ecx,8           // ecx  <-  00 fa 00 fg
    imul  ecx,ebx         // ecx  <-  pa ** pg **
    add   eax,$00800080
    and   eax,$FF00FF00   // eax  <-  pr 00 pb 00
    shr   eax,8           // eax  <-  00 pr ** pb
    add   ecx,$00800080
    and   ecx,$FF00FF00   // ecx  <-  pa 00 pg 00
    or    eax,ecx         // eax  <-  pa pr pg pb

  // w = 1 - w; q = w * b
    mov   edx,[edi]
    xor   ebx,$000000FF   // ebx  <-  1 - ebx
    mov   ecx,edx         // ecx  <-  ba br bg bb
    and   edx,$00FF00FF   // edx  <-  00 br 00 bb
    and   ecx,$FF00FF00   // ecx  <-  ba 00 bg 00
    imul  edx,ebx         // edx  <-  qr ** qb **
    shr   ecx,8           // ecx  <-  00 ba 00 bg
    imul  ecx,ebx         // ecx  <-  qa ** qg **
    add   edx,$00800080
    and   edx,$FF00FF00   // edx  <-  qr 00 qb 00
    shr   edx,8           // edx  <-  00 qr ** qb
    add   ecx,$00800080
    and   ecx,$FF00FF00   // ecx  <-  qa 00 qg 00
    or    ecx,edx         // ecx  <-  qa qr qg qb

  // z = p + q (assuming no overflow at each byte)
    add   eax,ecx         // eax  <-  za zr zg zb
  @full_copy:
    mov   [edi],eax

    pop   edx             // restore master alpha
    pop   ecx             // restore counter

  @no_copy:
    add   edi,4

  // loop end
    dec   ecx
    jnz   @loop_x

    cld
    pop   edi
    pop   esi
    pop   ebx

  @exit:
end;

procedure CopyAlphaPalette(source, dest: Pointer; scount0, dcount0, dcount, doffset: Integer; reverse: Boolean; pal: Pointer; palcount: Integer);
asm
// eax = source
// edx = dest
// ecx = scount0

    push  edi
    push  ebx

    mov   edi,edx          // edi <- dest
    mov   ebx,ecx          // ebx <- scount0
    mov   ecx,[dcount]     // ecx <- dcount

  // if dcount = 0 then Exit;
    test  ecx,ecx
    js    @exit
    jz    @exit

    push  esi
    mov   esi,eax          // esi <- source

  // doffset := dcount0 - doffset * scount0 mod dcount0 - 1;
    mov   eax,[doffset]
    imul  ebx
    idiv  [dcount0]
    mov   eax,[dcount0]
    stc
    sbb   eax,edx
    mov   edx,eax          // edx <- doffset

    test  byte ptr [reverse],$FF
    jz    @loop_inc_x
    lea   edi,[edi + ecx * 4 - 4]
    std

  @loop_inc_x:
    mov   eax,[esi]
    cmp   eax,[palcount]
    jnc   @no_pal
    shl   eax,2
    add   eax,dword ptr [pal]
    mov   eax,[eax]

  @no_pal:
    test  eax,$FF000000
    jz    @loop_no_x
    cmp   eax,$FF000000
    jc    @do_alpha

  @loop_fill_x:
    stosd
    sub   edx,ebx
    jc    @do_inc_esi
    dec   ecx
    jnz   @loop_fill_x
    jmp   @end_copy

  @loop_no_x:
    mov   eax,[edi]
    stosd
    sub   edx,ebx
    jc    @do_inc_esi
    dec   ecx
    jnz   @loop_no_x
    jmp   @end_copy

  // get weight w = fa * m
  @do_alpha:
    push  ecx
    push  ebx

    mov   ecx,eax          // ecx  <-  fa fr fg fb
    shr   ecx,24           // ecx  <-  00 00 00 fa

  // p = w * f
    mov   ebx,eax          // ebx  <-  fa fr fg fb
    and   eax,$00FF00FF    // eax  <-  00 fr 00 fb
    and   ebx,$FF00FF00    // ebx  <-  fa 00 fg 00
    imul  eax,ecx          // eax  <-  pr ** pb **
    shr   ebx,8            // ebx  <-  00 fa 00 fg
    imul  ebx,ecx          // ebx  <-  pa ** pg **
    add   eax,$00800080
    and   eax,$FF00FF00    // eax  <-  pr 00 pb 00
    shr   eax,8            // eax  <-  00 pr ** pb
    add   ebx,$00800080
    and   ebx,$FF00FF00    // ebx  <-  pa 00 pg 00
    or    ebx,eax          // ebx  <-  pa pr pg pb
    xor   ecx,$000000FF    // ecx  <-  1 - ecx

  @loop_x:
  // w = 1 - w; q = w * b
    push  edx
    mov   edx,[edi]
    mov   eax,edx          // ebx  <-  ba br bg bb
    and   edx,$00FF00FF    // esi  <-  00 br 00 bb
    and   eax,$FF00FF00    // ebx  <-  ba 00 bg 00
    imul  edx,ecx          // esi  <-  qr ** qb **
    shr   eax,8            // ebx  <-  00 ba 00 bg
    imul  eax,ecx          // ebx  <-  qa ** qg **
    add   edx,$00800080
    and   edx,$FF00FF00    // esi  <-  qr 00 qb 00
    shr   edx,8            // esi  <-  00 qr ** qb
    add   eax,$00800080
    and   eax,$FF00FF00    // ebx  <-  qa 00 qg 00
    or    eax,edx          // ebx  <-  qa qr qg qb

  // z = p + q (assuming no overflow at each byte)
    add   eax,ebx          // eax  <-  za zr zg zb
    stosd
    pop   edx
    sub   edx,[esp]
    jc    @do_inc_pop
    dec   [esp + 4]
    jnz   @loop_x
    pop   ebx
    pop   ecx
    jmp   @end_copy

  @do_inc_pop:
    pop   ebx
    pop   ecx

  @do_inc_esi:
    add   esi,4
    add   edx,[dcount0]
    jnc   @do_inc_esi
    dec   ecx
    jnz   @loop_inc_x

  @end_copy:
    cld
    pop   esi

  @exit:
    pop   ebx
    pop   edi
end;

procedure CopyAlphaPalette(source, dest: Pointer; scount0, dcount0, dcount, doffset: Integer; reverse: Boolean; pal: Pointer; palcount: Integer; alpha: Integer);
asm // copy alpha color with scale & master alpha
  // eax = source
  // edx = dest
  // ecx = scount0

    push  edi
    push  ebx

    mov   edi,edx          // edi <- dest
    mov   ebx,ecx          // ebx <- scount0
    mov   ecx,[dcount]     // ecx <- dcount

  // if dcount = 0 then Exit;
    test  ecx,ecx
    js    @exit
    jz    @exit

    push  esi
    mov   esi,eax          // esi <- source

  // doffset := dcount0 - doffset * scount0 mod dcount0 - 1;
    mov   eax,[doffset]
    imul  ebx
    idiv  [dcount0]
    mov   eax,[dcount0]
    stc
    sbb   eax,edx
    mov   edx,eax          // edx <- doffset

    test  byte ptr [reverse],$FF
    jz    @loop_inc_x
    lea   edi,[edi + ecx * 4 - 4]
    std

  @loop_inc_x:
    mov   eax,[esi]
    cmp   eax,[palcount]
    jnc   @no_pal
    shl   eax,2
    add   eax,dword ptr [pal]
    mov   eax,[eax]

  @no_pal:
    test  eax,$FF000000
    jz    @loop_no_x

    push  ecx
//    push  ebx

  // get weight w = fa * m
    mov   ecx,eax         // ecx  <-  fa fr fg fb
    shr   ecx,24          // ecx  <-  00 00 00 fa
    inc   ecx             // 255:256 range bias
    imul  ecx,[alpha]     // ecx  <-  00 00  w **
    shr   ecx,8           // ecx  <-  00 00 00  w
    jz    @no_copy        // w = 0 ?  => write nothing

    push  ebx

  // p = w * f
    mov   ebx,eax          // ebx  <-  fa fr fg fb
    and   eax,$00FF00FF    // eax  <-  00 fr 00 fb
    and   ebx,$FF00FF00    // ebx  <-  fa 00 fg 00
    imul  eax,ecx          // eax  <-  pr ** pb **
    shr   ebx,8            // ebx  <-  00 fa 00 fg
    imul  ebx,ecx          // ebx  <-  pa ** pg **
    add   eax,$00800080
    and   eax,$FF00FF00    // eax  <-  pr 00 pb 00
    shr   eax,8            // eax  <-  00 pr ** pb
    add   ebx,$00800080
    and   ebx,$FF00FF00    // ebx  <-  pa 00 pg 00
    or    ebx,eax          // ebx  <-  pa pr pg pb
    xor   ecx,$000000FF    // ecx  <-  1 - ecx

  @loop_x:
  // w = 1 - w; q = w * b
    push  edx
    mov   edx,[edi]
    mov   eax,edx          // ebx  <-  ba br bg bb
    and   edx,$00FF00FF    // esi  <-  00 br 00 bb
    and   eax,$FF00FF00    // ebx  <-  ba 00 bg 00
    imul  edx,ecx          // esi  <-  qr ** qb **
    shr   eax,8            // ebx  <-  00 ba 00 bg
    imul  eax,ecx          // ebx  <-  qa ** qg **
    add   edx,$00800080
    and   edx,$FF00FF00    // esi  <-  qr 00 qb 00
    shr   edx,8            // esi  <-  00 qr ** qb
    add   eax,$00800080
    and   eax,$FF00FF00    // ebx  <-  qa 00 qg 00
    or    eax,edx          // ebx  <-  qa qr qg qb

  // z = p + q (assuming no overflow at each byte)
    add   eax,ebx          // eax  <-  za zr zg zb
    stosd
    pop   edx
    sub   edx,[esp]
    jc    @do_inc_pop
    dec   [esp + 4]
    jnz   @loop_x
    pop   ebx
    pop   ecx
    jmp   @end_copy

  @no_copy:
//    pop   ebx
    pop   ecx

  @loop_no_x:
    mov   eax,[edi]
    stosd
    sub   edx,ebx
    jc    @do_inc_esi
    dec   ecx
    jnz   @loop_no_x
    jmp   @end_copy

  @do_inc_pop:
    pop   ebx
    pop   ecx

  @do_inc_esi:
    add   esi,4
    add   edx,[dcount0]
    jnc   @do_inc_esi
    dec   ecx
    jnz   @loop_inc_x

  @end_copy:
    cld
    pop   esi

  @exit:
    pop   ebx
    pop   edi
end;

procedure CopyBit(source, dest: Pointer; count, nbits: Integer; reverse: Boolean);
asm
// eax = source
// edx = dest
// ecx = count
    test  ecx,ecx
    js    @exit
    jz    @exit

    push  ebx
    push  esi
    push  edi

    test  byte ptr [reverse],$FF
    jz    @not_reverse
    lea   edx,[edx + ecx * 4 - 4]
    std

  @not_reverse:
    mov   esi,eax
    mov   edi,edx
    push  ecx
    mov   ecx,[nbits]

    mov   ebx,1
    shl   ebx,cl
    dec   ebx
    mov   [nbits],ebx

    mov   eax,32
    cdq
    idiv  ecx
    dec   eax
    mov   ebx,eax

  @loop_d:
    mov   edx,[esi]
    xchg  dh,dl
    rol   edx,16
    xchg  dh,dl
    add   esi,4
    xchg  esi,[esp]

  @loop_bit:
    rol   edx,cl
    mov   eax,edx
    and   eax,[nbits]
    stosd
    dec   esi
    jz    @end_copy
    test  esi,ebx
    jnz   @loop_bit
    xchg  esi,[esp]
    jmp   @loop_d


  @end_copy:
    cld
    pop   ecx
    pop   edi
    pop   esi
    pop   ebx

  @exit:
end;

procedure CopyBitPalette(source, dest: Pointer; count, nbits, boffset: Integer; reverse: Boolean; pal: Pointer; palcount: Integer);
asm
// eax = source
// edx = dest
// ecx = count
    test  ecx,ecx
    js    @exit
    jz    @exit

    push  ebx
    push  esi
    push  edi

    test  byte ptr [reverse],$FF
    jz    @not_reverse
    lea   edx,[edx + ecx * 4 - 4]
    std

  @not_reverse:
    mov   esi,eax
    mov   edi,edx
    push  ecx
    mov   ecx,[nbits]

    mov   ebx,1
    shl   ebx,cl
    dec   ebx
    mov   [nbits],ebx     // nbits = 2 ^ nbits - 1

    mov   eax,32
    cdq
    idiv  ecx
    dec   eax
    mov   ebx,[boffset]
    and   ebx,eax
    mov   [boffset],eax
    imul  eax,ecx         // eax = nbits * boffset

    mov   edx,[esi]
    xchg  dh,dl
    rol   edx,16
    xchg  dh,dl

  @loop_byte:
    add   esi,4
    xchg  esi,[esp]

  @loop_bit:
    rol   edx,cl
    mov   eax,edx
    and   eax,[nbits]
    cmp   eax,[palcount]
    jnc   @no_pal
    shl   eax,2
    add   eax,dword ptr [pal]
    mov   eax,[eax]

  @no_pal:
    stosd
    dec   esi
    jz    @end_copy
    inc   ebx
    and   ebx,[boffset]
    jnz   @loop_bit

    xchg  esi,[esp]
    mov   edx,[esi]
    xchg  dh,dl
    rol   edx,16
    xchg  dh,dl
    jmp   @loop_byte

  @end_copy:
    cld
    pop   ecx
    pop   edi
    pop   esi
    pop   ebx

  @exit:
end;

procedure CopyBitPalette(source, dest: Pointer; scount0, dcount0, dcount, doffset, nbits, boffset: Integer; reverse: Boolean; pal: Pointer; palcount: Integer);
// eax = source
// edx = dest
// ecx = scount0
asm
    push edi
    push ebx

    mov  edi,edx          // edi <- dest
    mov  ebx,ecx          // ebx <- scount0
    mov  ecx,[dcount]     // ecx <- dcount
    mov  [dcount],ebx     // dcount <- scount0

//  if dcount = 0 then Exit;
    test ecx,ecx
    js   @exit
    jz   @exit

    push esi
    mov  esi,eax          // esi <- source

//  doffset := dcount0 - doffset * scount0 mod dcount0 - 1;
    mov  eax,[doffset]
    imul ebx
    idiv [dcount0]
    mov  eax,[dcount0]
    stc
    sbb  eax,edx
    mov  edx,eax          // edx <- doffset

    test byte ptr [reverse],$FF
    jz   @not_reverse
    lea  edi,[edi + ecx * 4 - 4]
    std

  @not_reverse:
    push  ecx
    push  edx

    mov   ecx,[nbits]
    mov   ebx,1
    shl   ebx,cl
    dec   ebx
    mov   [nbits],ebx

    mov   eax,32
    cdq
    idiv  ecx
    dec   eax
    mov   ebx,[boffset]
    and   ebx,eax
    mov   [boffset],eax
    mov   eax,ebx
    imul  eax,ecx         // eax = nbits * boffset

    mov   edx,[esi]
    add   esi,4
    xchg  dh,dl
    rol   edx,16
    xchg  dh,dl
    xchg  eax,ecx
    rol   edx,cl
    mov   ecx,eax
    rol   edx,cl
    xchg  esi,[esp + 4]

  @loop_bit:
    mov   eax,edx
    and   eax,[nbits]
    cmp   eax,[palcount]
    jnc   @no_pal
    shl   eax,2
    add   eax,dword ptr [pal]
    mov   eax,[eax]

  @no_pal:
    xchg  edx,[esp]

  @loop_x:
    stosd
    sub   edx,[dcount]
    jc    @inc_src
    dec   esi
    jnz   @loop_x
    jmp   @end_copy

  @inc_src:
    pop   eax
    xchg  esi,[esp]

  @loop_inc_src:
    inc   ebx
    and   ebx,[boffset]
    jnz   @no_inc_esi
    mov   eax,[esi]
    xchg  ah,al
    rol   eax,16
    xchg  ah,al
    add   esi,4

  @no_inc_esi:
    rol   eax,cl
    add   edx,[dcount0]
    jnc   @loop_inc_src
    xchg  esi,[esp]
    xchg  eax,edx
    push  eax
    dec   esi
    jnz   @loop_bit

  @end_copy:
    cld
    pop   edx
    pop   ecx
    pop   esi

  @exit:
    pop   ebx
    pop   edi
end;

procedure CopyCharPattern(csource, dest: Pointer; count, nbits, boffset: Integer; reverse: Boolean; cpattern: Pointer; fgcolor, bgcolor: TColor32);
asm
// MSX Screen 0
// eax      = csource / character table
// edx      = dest / 32 bit BGRA
// ecx      = count of pixels
// nbits    = number of bits per character row (6)
// boffset  = horizontal pixel offset
// reverse  = horizontal flip
// cpattern = character pattern + row offset(8 bytes per character)
// fgcolor  = foreground color in BGRA
// bgcolor  = background color in BGRA

    test  ecx,ecx
    js    @exit
    jz    @exit

    push  ebx
    push  esi
    push  edi

    test  byte ptr [reverse],$FF
    jz    @not_reverse
    lea   edx,[edx + ecx * 4 - 4]
    std

  @not_reverse:
    mov   esi,eax
    mov   edi,edx
    mov   ebx,ecx
    mov   ecx,[nbits]
    mov   eax,[boffset]
    xor   dx,dx
    div   cx
    mov   ch,cl
    mov   cl,dl
    mov   dh,ch
    sub   dh,cl
    inc   cl

  @loop_byte:
    xor   eax,eax
    mov   al,[esi]
    inc   esi
    shl   eax,3
    add   eax,dword ptr cpattern
    mov   dl,[eax]

  @loop_bit:
    rol   dl,cl
    test  dl,1
    jz    @put_bg
    mov   eax,[fgcolor]
    jmp   @put_color

  @put_bg:
    mov   eax,[bgcolor]

  @put_color:
    stosd
    dec   ebx
    jz    @end_copy
    mov   cl,1
    dec   dh
    jnz   @loop_bit
    mov   dh,ch
    jp    @loop_byte

  @end_copy:
    cld
    pop   edi
    pop   esi
    pop   ebx

  @exit:
end;

procedure CopyCharPattern(csource, dest: Pointer; scount0, dcount0, dcount, doffset, nbits, boffset: Integer; reverse: Boolean; cpattern: Pointer; fgcolor, bgcolor: TColor32); overload;
// MSX Screen 0
// eax      = csource / character table
// edx      = dest / 32 bit BGRA
// ecx      = scount0 / actual width of source
// dcount0  = actual width of dest
// dcount   = byte to copy
// doffset  = calculation offset
// nbits    = number of bits per character row (6)
// boffset  = horizontal pixel offset
// reverse  = horizontal flip
// cpattern = character pattern + row offset(8 bytes per character)
// fgcolor  = foreground color in BGRA
// bgcolor  = background color in BGRA
asm
    push edi
    push ebx

    mov  edi,edx          // edi <- dest
    mov  ebx,ecx          // ebx <- scount0
    mov  ecx,[dcount]     // ecx <- dcount
    mov  [dcount],ebx     // dcount <- scount0

//  if dcount = 0 then Exit;
    test ecx,ecx
    js   @exit
    jz   @exit

    push esi
    mov  esi,eax          // esi <- source

//  doffset := dcount0 - doffset * scount0 mod dcount0 - 1;
    mov  eax,[doffset]
    imul ebx
    idiv [dcount0]
    mov  eax,[dcount0]
    stc
    sbb  eax,edx
    mov  ebx,eax          // ebx <- doffset

    test byte ptr [reverse],$FF
    jz   @not_reverse
    lea  edi,[edi + ecx * 4 - 4]
    std

  @not_reverse:
    push  ecx

    mov   ecx,[nbits]
    mov   eax,[boffset]
    xor   dx,dx
    div   cx
    mov   ch,cl
    mov   cl,dl
    mov   dh,ch
    sub   dh,cl
    inc   cl

    xor   eax,eax
    mov   al,[esi]
    inc   esi
    shl   eax,3
    add   eax,dword ptr [cpattern]
    mov   dl,[eax]
    rol   dl,cl
    xchg  esi,[esp]

  @loop_bit:
    test  dl,1
    jz    @put_bg
    mov   eax,[fgcolor]
    jmp   @loop_x

  @put_bg:
    mov   eax,[bgcolor]

  @loop_x:
    stosd
    sub   ebx,[dcount]
    jc    @inc_src
    dec   esi
    jnz   @loop_x
    jmp   @end_copy

  @inc_src:
    xchg  esi,[esp]

  @loop_inc_src:
    rol   dl,1
    dec   dh
    jnz   @no_inc_esi
    xor   eax,eax
    mov   al,[esi]
    inc   esi
    shl   eax,3
    add   eax,dword ptr [cpattern]
    mov   dl,[eax]
    rol   dl,1
    mov   dh,ch

  @no_inc_esi:
    add   ebx,[dcount0]
    jnc   @loop_inc_src

    xchg  esi,[esp]
    dec   esi
    jnz   @loop_bit

  @end_copy:
    cld
    pop   ecx
    pop   esi

  @exit:
    pop   ebx
    pop   edi
end;

procedure CopyColorPattern(csource, dest: Pointer; count, boffset: Integer; reverse, mode2: Boolean; cpattern, ccolor, pal: Pointer; palcount: Integer);
asm
// MSX Screen 1 / 2
// eax      = csource / character table
// edx      = dest / 32 bit BGRA
// ecx      = count of pixels
// boffset  = horizontal pixel offset
// reverse  = horizontal flip
// mode2    = Screen 2
// cpattern = character pattern + row offset(8 bytes per character)
// ccolor   = color pattern 1 byte per 8 characters
// pal      = pallette table of BGRA
// palcount = pallette count

    test  ecx,ecx
    js    @exit
    jz    @exit

    push  ebx
    push  esi
    push  edi

    test  byte ptr [reverse],$FF
    jz    @not_reverse
    lea   edx,[edx + ecx * 4 - 4]
    std

  @not_reverse:
    mov   esi,eax
    mov   edi,edx
    mov   ebx,ecx
    mov   ecx,8         // 8 pixels per byte
    mov   eax,[boffset]
    xor   dx,dx
    div   cx
    mov   ch,cl
    mov   cl,dl
    mov   dh,ch
    sub   dh,cl
    inc   cl

  @loop_byte:
    xor   eax,eax
    mov   al,[esi]
    inc   esi

    push  eax
    test  byte ptr [mode2],$FF
    jz    @mode1
    shl   eax,3
    jmp   @get_color

  @mode1:
    shr   eax,3

  @get_color:
    add   eax,dword ptr [ccolor]
    mov   dl,[eax]
    xor   eax,eax
    mov   al,dl
    shr   al,4
    cmp   eax,[palcount]
    jnc   @f_no_pal
    shl   eax,2
    add   eax,dword ptr [pal]
    mov   eax,[eax]

  @f_no_pal:
    push  eax
    xor   eax,eax
    mov   al,dl
    and   al,15
    cmp   eax,[palcount]
    jnc   @b_no_pal
    shl   eax,2
    add   eax,dword ptr [pal]
    mov   eax,[eax]

  @b_no_pal:
    xchg  eax,[esp + 4]
    shl   eax,3
    add   eax,dword ptr [cpattern]
    mov   dl,[eax]

  @loop_bit:
    rol   dl,cl
    test  dl,1
    jz    @put_bg
    mov   eax,[esp]
    jmp   @put_color

  @put_bg:
    mov   eax,[esp + 4]

  @put_color:
    stosd
    dec   ebx
    jz    @end_copy
    mov   cl,1
    dec   dh
    jnz   @loop_bit
    add   esp,8
    mov   dh,ch
    jmp   @loop_byte

  @end_copy:
    cld
    add   esp,8
    pop   edi
    pop   esi
    pop   ebx

  @exit:
end;

procedure CopyColorPattern(csource, dest: Pointer; scount0, dcount0, dcount, doffset, boffset: Integer; reverse, mode2: Boolean; cpattern, ccolor, pal: Pointer; palcount: Integer);
// MSX Screen 1 / 2
// eax      = csource / character table
// edx      = dest / 32 bit BGRA
// ecx      = scount0 / actual width of source
// dcount0  = actual width of dest
// dcount   = byte to copy
// doffset  = calculation offset
// boffset  = horizontal pixel offset
// reverse  = horizontal flip
// mode2    = Screen 2
// cpattern = character pattern + row offset(8 bytes per character)
// ccolor   = color pattern 1 byte per 8 characters
// pal      = pallette table of BGRA
// palcount = pallette count
asm
    push edi
    push ebx

    mov  edi,edx          // edi <- dest
    mov  ebx,ecx          // ebx <- scount0
    mov  ecx,[dcount]     // ecx <- dcount
    mov  [dcount],ebx     // dcount <- scount0

//  if dcount = 0 then Exit;
    test ecx,ecx
    js   @exit
    jz   @exit

    push esi
    mov  esi,eax          // esi <- source

//  doffset := dcount0 - doffset * scount0 mod dcount0 - 1;
    mov  eax,[doffset]
    imul ebx
    idiv [dcount0]
    mov  eax,[dcount0]
    stc
    sbb  eax,edx
    mov  ebx,eax          // ebx <- doffset

    test byte ptr [reverse],$FF
    jz   @not_reverse
    lea  edi,[edi + ecx * 4 - 4]
    std

  @not_reverse:
    push  ecx

    mov   ecx,8
    mov   eax,[boffset]
    xor   dx,dx
    div   cx
    mov   ch,cl
    mov   cl,dl
    mov   dh,ch
    sub   dh,cl
    inc   cl

    xor   eax,eax
    mov   al,[esi]
    inc   esi
    push  eax
    test  byte ptr [mode2],$FF
    jz    @mode1
    shl   eax,3
    jmp   @get_color

  @mode1:
    shr   eax,3

  @get_color:
    add   eax,dword ptr [ccolor]
    mov   dl,[eax]
    xor   eax,eax
    mov   al,dl
    shr   al,4
    cmp   eax,[palcount]
    jnc   @f_no_pal
    shl   eax,2
    add   eax,dword ptr [pal]
    mov   eax,[eax]

  @f_no_pal:
    push  eax
    xor   eax,eax
    mov   al,dl
    and   al,15
    cmp   eax,[palcount]
    jnc   @b_no_pal
    shl   eax,2
    add   eax,dword ptr [pal]
    mov   eax,[eax]

  @b_no_pal:
    xchg  eax,[esp + 4]
    shl   eax,3
    add   eax,dword ptr [cpattern]
    mov   dl,[eax]
    rol   dl,cl
    xchg  esi,[esp + 8]

  @loop_bit:
    test  dl,1
    jz    @put_bg
    mov   eax,[esp]
    jmp   @loop_x

  @put_bg:
    mov   eax,[esp + 4]

  @loop_x:
    stosd
    sub   ebx,[dcount]
    jc    @inc_src
    dec   esi
    jnz   @loop_x
    jmp   @end_copy

  @inc_src:
    xchg  esi,[esp + 8]

  @loop_inc_src:
    rol   dl,1
    dec   dh
    jnz   @no_inc_esi
    xor   eax,eax
    mov   al,[esi]
    inc   esi

    mov   [esp + 4],eax
    test  byte ptr [mode2],$FF
    jz    @lmode1
    shl   eax,3
    jmp   @lget_color

  @lmode1:
    shr   eax,3

  @lget_color:
    add   eax,dword ptr [ccolor]
    mov   dl,[eax]
    xor   eax,eax
    mov   al,dl
    shr   al,4
    cmp   eax,[palcount]
    jnc   @f_no_pal2
    shl   eax,2
    add   eax,dword ptr [pal]
    mov   eax,[eax]

  @f_no_pal2:
    mov   [esp],eax
    xor   eax,eax
    mov   al,dl
    and   al,15
    cmp   eax,[palcount]
    jnc   @b_no_pal2
    shl   eax,2
    add   eax,dword ptr [pal]
    mov   eax,[eax]

  @b_no_pal2:
    xchg  eax,[esp + 4]
    shl   eax,3
    add   eax,dword ptr [cpattern]
    mov   dl,[eax]
    rol   dl,1
    mov   dh,ch

  @no_inc_esi:
    add   ebx,[dcount0]
    jnc   @loop_inc_src

    xchg  esi,[esp + 8]
    dec   esi
    jnz   @loop_bit

  @end_copy:
    cld
    add   esp,12
    pop   esi

  @exit:
    pop   ebx
    pop   edi
end;

procedure CopyCharColor(csource, dest: Pointer; count, boffset: Integer; reverse: Boolean; cpattern, pal: Pointer; palcount: Integer);
// MSX Screen 3
// eax      = csource / character table
// edx      = dest / 32 bit BGRA
// ecx      = count of pixels
// reverse  = horizontal flip
// cpattern = character pattern + row offset(8 bytes per character)
// pal      = pallette table of BGRA
// palcount = pallette count
asm
    test  ecx,ecx
    js    @exit
    jz    @exit

    push  ebx
    push  esi
    push  edi

    test  byte ptr [reverse],$FF
    jz    @not_reverse
    lea   edx,[edx + ecx * 4 - 4]
    std

  @not_reverse:
    mov   esi,eax
    mov   edi,edx
    mov   ebx,ecx
    mov   ecx,[boffset]
    and   ecx,1
    shl   ecx,2
    xor   cl,4

  @loop_byte:
    xor   eax,eax
    mov   al,[esi]
    inc   esi
    shl   eax,3
    add   eax,dword ptr [cpattern]
    mov   dl,[eax]

  @loop_bit:
    xor   eax,eax
    mov   al,dl
    rol   al,cl
    and   al,15
    cmp   eax,[palcount]
    jnc   @no_pal
    shl   eax,2
    add   eax,dword ptr [pal]
    mov   eax,[eax]

  @no_pal:

    stosd
    dec   ebx
    jz    @end_copy
    xor   cl,4
    jz    @loop_bit
    jmp   @loop_byte

  @end_copy:
    cld
    pop   edi
    pop   esi
    pop   ebx

  @exit:
end;

procedure CopyCharColor(csource, dest: Pointer; scount0, dcount0, dcount, doffset, boffset: Integer; reverse: Boolean; cpattern, pal: Pointer; palcount: Integer); overload;
// MSX Screen 3
// eax      = csource / character table
// edx      = dest / 32 bit BGRA
// ecx      = scount0 / actual width of source
// dcount0  = actual width of dest
// dcount   = byte to copy
// doffset  = calculation offset
// boffset  = horizontal pixel offset
// reverse  = horizontal flip
// cpattern = character pattern + row offset(8 bytes per character)
// pal      = pallette table of BGRA
// palcount = pallette count
asm
    push edi
    push ebx

    mov  edi,edx          // edi <- dest
    mov  ebx,ecx          // ebx <- scount0
    mov  ecx,[dcount]     // ecx <- dcount
    mov  [dcount],ebx     // dcount <- scount0

//  if dcount = 0 then Exit;
    test ecx,ecx
    js   @exit
    jz   @exit

    push esi
    mov  esi,eax          // esi <- source

//  doffset := dcount0 - doffset * scount0 mod dcount0 - 1;
    mov  eax,[doffset]
    imul ebx
    idiv [dcount0]
    mov  eax,[dcount0]
    stc
    sbb  eax,edx
    mov  ebx,eax          // ebx <- doffset

    test byte ptr [reverse],$FF
    jz   @not_reverse
    lea  edi,[edi + ecx * 4 - 4]
    std

  @not_reverse:
    push  ecx

    mov   ecx,[boffset]
    and   ecx,1
    shl   ecx,2
    xor   cl,4

    xor   eax,eax
    mov   al,[esi]
    inc   esi
    shl   eax,3
    add   eax,dword ptr [cpattern]
    mov   dl,[eax]
    xchg  esi,[esp]

  @loop_bit:
    xor   eax,eax
    mov   al,dl
    rol   al,cl
    and   al,15
    cmp   eax,[palcount]
    jnc   @loop_x
    shl   eax,2
    add   eax,dword ptr [pal]
    mov   eax,[eax]

  @loop_x:
    stosd
    sub   ebx,[dcount]
    jc    @inc_src
    dec   esi
    jnz   @loop_x
    jmp   @end_copy

  @inc_src:
    xchg  esi,[esp]

  @loop_inc_src:
    xor   cl,4
    jz    @no_inc_esi
    xor   eax,eax
    mov   al,[esi]
    inc   esi
    shl   eax,3
    add   eax,dword ptr [cpattern]
    mov   dl,[eax]

  @no_inc_esi:
    add   ebx,[dcount0]
    jnc   @loop_inc_src

    xchg  esi,[esp]
    dec   esi
    jnz   @loop_bit

  @end_copy:
    cld
    pop   ecx
    pop   esi

  @exit:
    pop   ebx
    pop   edi
end;

procedure FetchJK; // IN: eax = YJK / OUT: eax = J, edx = K, ebx = [Y3|Y2|Y1|Y0]
asm
    mov   ebx,eax
    and   eax,7
    mov   edx,ebx
    shr   edx,5
    and   edx,$38
    or    eax,edx
    cmp   eax,32
    jle   @no_neg_ik
    sub   eax,64

  @no_neg_ik:
    push  eax

    mov   eax,ebx
    shr   eax,16
    and   eax,7
    mov   edx,ebx
    shr   edx,21
    and   edx,$38
    or    eax,edx
    cmp   eax,32
    jle   @no_neg_ij
    sub   eax,64

  @no_neg_ij:
    shr   ebx,3
    pop   edx
end;

// VRAM 0: [Y4|Y3|Y2|Y1|Y0|K2|K1|K0]    (K > 31 -> K = K - 64)
// VRAM 1: [Y4|Y3|Y2|Y1|Y0|K5|K4|K3]
// VRAM 2: [Y4|Y3|Y2|Y1|Y0|J2|J1|J0]    (J > 31 -> J = J - 64)
// VRAM 3: [Y4|Y3|Y2|Y1|Y0|J5|J4|J3]
// R = Y + K                            (0 - 31)
// G = Y + J                            (0 - 31)
// B = 5 * Y / 4 - J / 2 - K / 4        (0 - 31)
procedure CopyYJK(source, dest: Pointer; count, boffset: Integer; reverse: Boolean);
var
  ij, ik: Integer;
asm
// eax = source
// edx = dest
// ecx = count

    cmp   ecx,1
    jl    @exit

    push  esi
    push  edi
    push  ebx

    test  byte ptr [reverse],$FF
    jz    @not_reverse
    lea   edx,[edx + ecx * 4 - 4]
    std

  @not_reverse:
    mov   esi,eax
    mov   edi,edx

    mov   eax,[esi]
    add   esi,4
    mov   ebx,eax
    mov   edx,[boffset]

  @loop_offset:
    test  edx,3
    jz    @end_offset
    shr   ebx,8
    dec   edx
    jmp   @loop_offset

  @end_offset:
    and   eax,$07070707
    and   ebx,$F8F8F8F8
    or    eax,ebx

  @loop_d:
    push  esi
    mov   ebx,eax
    and   eax,7
    mov   edx,ebx
    shr   edx,5
    and   edx,$38
    or    eax,edx
    cmp   eax,32
    jle   @no_neg_ik
    sub   eax,64

  @no_neg_ik:
    mov   [ik],eax

    mov   eax,ebx
    shr   eax,16
    and   eax,7
    mov   edx,ebx
    shr   edx,21
    and   edx,$38
    or    eax,edx
    cmp   eax,32
    jle   @no_neg_ij
    sub   eax,64

  @no_neg_ij:
    mov   [ij],eax
    shr   ebx,3

  @loop_bit:
    mov   edx,ebx
    shr   ebx,8
    and   edx,$1F

    mov   eax,edx
    add   eax,[ij]
    jns   @no_less_r
    xor   eax,eax
    jmp   @no_more_r

  @no_less_r:
    cmp   eax,31
    jle   @no_more_r
    mov   eax,31

  @no_more_r:
    imul  eax,33
    shr   eax,2
    shl   eax,16
    or    edx,eax

    movzx eax,dl
    add   eax,[ik]
    jns   @no_less_g
    xor   eax,eax
    jmp   @no_more_g

  @no_less_g:
    cmp   eax,31
    jle   @no_more_g
    mov   eax,31

  @no_more_g:
    imul  eax,33
    shr   eax,2
    shl   eax,8
    or    edx,eax

    movzx eax,dl
    imul  eax,5
    shr   eax,2
    mov   esi,[ij]
    test  esi,esi
    jns   @no_sign_ij
    inc   esi

  @no_sign_ij:
    sar   esi,1
    sub   eax,esi
    mov   esi,[ik]
    test  esi,esi
    jns   @no_sign_ik
    inc   esi

  @no_sign_ik:
    sar   esi,1
    sub   eax,esi
    jns   @no_less_b
    xor   eax,eax
    jmp   @no_more_b

  @no_less_b:
    cmp   eax,31
    jle   @no_more_b
    mov   eax,31

  @no_more_b:
    imul  eax,33
    shr   eax,2
    mov   dl,al
    mov   eax,edx
    or    eax,$FF000000
    stosd
    dec   ecx
    jz    @end_copy
    inc   [boffset]
    test  [boffset],3
    jnz   @loop_bit
    pop   esi
    mov   eax,[esi]
    add   esi,4
    jmp   @loop_d

  @end_copy:
    cld
    pop   esi // dummy
    pop   ebx
    pop   edi
    pop   esi

  @exit:
end;

procedure CopyYJK(source, dest: Pointer; scount0, dcount0, dcount, doffset, boffset: Integer; reverse: Boolean);
var
  ij, ik: Integer;
asm
// eax = source
// edx = dest
// ecx = scount0

    push edi
    push ebx

    mov  edi,edx          // edi <- dest
    mov  ebx,ecx          // ebx <- scount0
    mov  ecx,[dcount]     // ecx <- dcount
    mov  [dcount],ebx     // dcount <- scount0
    and  [boffset], 3

//  if dcount = 0 then Exit;
    test ecx,ecx
    js   @exit
    jz   @exit

    push esi
    mov  esi,eax          // esi <- source

//  doffset := dcount0 - doffset * scount0 mod dcount0 - 1;
    mov  eax,[doffset]
    imul ebx
    idiv [dcount0]
    mov  eax,[dcount0]
    stc
    sbb  eax,edx
    mov  edx,eax          // edx <- doffset

    test byte ptr [reverse],$FF
    jz   @not_reverse
    lea  edi,[edi + ecx * 4 - 4]
    std

// edx = doffset / ebx = ? / ecx = dcount / esi = source / edi = dest
  @not_reverse:
    push  edx
    mov   eax,[esi]
    add   esi,4
    mov   ebx,eax
    mov   edx,[boffset]

  @loop_offset:
    and   edx,3
    jz    @end_offset
    shr   ebx,8
    dec   edx
    jmp   @loop_offset

  @end_offset:
    and   eax,$07070707
    and   ebx,$F8F8F8F8
    or    eax,ebx
    call  FetchJK
    mov   [ij],eax
    mov   [ik],edx

  @loop_bit:
    push  esi
    mov   edx,ebx
//    shr   ebx,8
    and   edx,$1F

    mov   eax,edx
    add   eax,[ij]
    jns   @no_less_r
    xor   eax,eax
    jmp   @no_more_r

  @no_less_r:
    cmp   eax,31
    jle   @no_more_r
    mov   eax,31

  @no_more_r:
    imul  eax,33
    shr   eax,2
    shl   eax,16
    or    edx,eax

    movzx eax,dl
    add   eax,[ik]
    jns   @no_less_g
    xor   eax,eax
    jmp   @no_more_g

  @no_less_g:
    cmp   eax,31
    jle   @no_more_g
    mov   eax,31

  @no_more_g:
    imul  eax,33
    shr   eax,2
    shl   eax,8
    or    edx,eax

    movzx eax,dl
    imul  eax,5
    shr   eax,2
    mov   esi,[ij]
    test  esi,esi
    jns   @no_sign_ij
    inc   esi

  @no_sign_ij:
    sar   esi,1
    sub   eax,esi
    mov   esi,[ik]
    test  esi,esi
    jns   @no_sign_ik
    inc   esi

  @no_sign_ik:
    sar   esi,1
    sub   eax,esi
    jns   @no_less_b
    xor   eax,eax
    jmp   @no_more_b

  @no_less_b:
    cmp   eax,31
    jle   @no_more_b
    mov   eax,31

  @no_more_b:
    imul  eax,33
    shr   eax,2
    mov   dl,al
    mov   eax,edx
    or    eax,$FF000000
    pop   esi
    pop   edx

  @loop_x:
    stosd
    sub   edx,[dcount]
    jc    @inc_src
    dec   ecx
    jnz   @loop_x
    jmp   @end_copy

  @inc_src:
    push  ecx
    mov   ecx,edx

  @loop_inc_src:
    shr   ebx,8
    inc   [boffset]
    and   [boffset],3
    jnz   @no_inc_esi
    mov   eax,[esi]
    add   esi,4
    call  FetchJK
    mov   [ij],eax
    mov   [ik],edx

  @no_inc_esi:
    add   ecx,[dcount0]
    jnc   @loop_inc_src
    xchg  ecx,[esp]
    dec   ecx
    jnz   @loop_bit
    pop   edx

  @end_copy:
    cld
    pop   esi

  @exit:
    pop   ebx
    pop   edi
end;

// VRAM 0: [Y4|Y3|Y2|Y1|Y0|K2|K1|K0]    (K > 31 -> K = K - 64)
// VRAM 1: [Y4|Y3|Y2|Y1|Y0|K5|K4|K3]
// VRAM 2: [Y4|Y3|Y2|Y1|Y0|J2|J1|J0]    (J > 31 -> J = J - 64)
// VRAM 3: [Y4|Y3|Y2|Y1|Y0|J5|J4|J3]

// Y0 = 0 -> Use YJK
// Y0 = 1 -> Use 4 bits pallette color (Y1 - Y4)

// R = Y + K                            (0 - 31)
// G = Y + J                            (0 - 31)
// B = 5 * Y / 4 - J / 2 - K / 4        (0 - 31)
procedure CopyYJKPalette(source, dest: Pointer; count, boffset: Integer; reverse: Boolean; pal: Pointer; palcount: Integer);
var
  ij, ik: Integer;
asm
// eax = source
// edx = dest
// ecx = count

    cmp   ecx,1
    jl    @exit

    push  esi
    push  edi
    push  ebx

    test  byte ptr [reverse],$FF
    jz    @not_reverse
    lea   edx,[edx + ecx * 4 - 4]
    std

  @not_reverse:
    mov   esi,eax
    mov   edi,edx

    mov   eax,[esi]
    add   esi,4
    mov   ebx,eax
    mov   edx,[boffset]

  @loop_offset:
    test  edx,3
    jz    @end_offset
    shr   ebx,8
    dec   edx
    jmp   @loop_offset

  @end_offset:
    and   eax,$07070707
    and   ebx,$F8F8F8F8
    or    eax,ebx

  @loop_d:
    push  esi
    mov   ebx,eax
    and   eax,7
    mov   edx,ebx
    shr   edx,5
    and   edx,$38
    or    eax,edx
    cmp   eax,32
    jle   @no_neg_ik
    sub   eax,64

  @no_neg_ik:
    mov   [ik],eax

    mov   eax,ebx
    shr   eax,16
    and   eax,7
    mov   edx,ebx
    shr   edx,21
    and   edx,$38
    or    eax,edx
    cmp   eax,32
    jle   @no_neg_ij
    sub   eax,64

  @no_neg_ij:
    mov   [ij],eax
    shr   ebx,3

  @loop_bit:
    mov   edx,ebx
    shr   ebx,8
    and   edx,$1F
    mov   eax,edx
    test  eax,1
    jz    @do_yjk
    shr   eax,1
    cmp   eax,[palcount]
    jnc   @put_color
    shl   eax,2
    add   eax,dword ptr [pal]
    mov   eax,[eax]
    jmp   @put_color

  @do_yjk:
    add   eax,[ij]
    jns   @no_less_r
    xor   eax,eax
    jmp   @no_more_r

  @no_less_r:
    cmp   eax,31
    jle   @no_more_r
    mov   eax,31

  @no_more_r:
    imul  eax,33
    shr   eax,2
    shl   eax,16
    or    edx,eax

    movzx eax,dl
    add   eax,[ik]
    jns   @no_less_g
    xor   eax,eax
    jmp   @no_more_g

  @no_less_g:
    cmp   eax,31
    jle   @no_more_g
    mov   eax,31

  @no_more_g:
    imul  eax,33
    shr   eax,2
    shl   eax,8
    or    edx,eax

    movzx eax,dl
    imul  eax,5
    shr   eax,2
    mov   esi,[ij]
    test  esi,esi
    jns   @no_sign_ij
    inc   esi

  @no_sign_ij:
    sar   esi,1
    sub   eax,esi
    mov   esi,[ik]
    test  esi,esi
    jns   @no_sign_ik
    inc   esi

  @no_sign_ik:
    sar   esi,1
    sub   eax,esi
    jns   @no_less_b
    xor   eax,eax
    jmp   @no_more_b

  @no_less_b:
    cmp   eax,31
    jle   @no_more_b
    mov   eax,31

  @no_more_b:
    imul  eax,33
    shr   eax,2
    mov   dl,al
    mov   eax,edx
    or    eax,$FF000000

  @put_color:
    stosd
    dec   ecx
    jz    @end_copy
    inc   [boffset]
    test  [boffset],3
    jnz   @loop_bit
    pop   esi
    mov   eax,[esi]
    add   esi,4
    jmp   @loop_d

  @end_copy:
    cld
    pop   esi // dummy
    pop   ebx
    pop   edi
    pop   esi

  @exit:
end;

procedure CopyYJKPalette(source, dest: Pointer; scount0, dcount0, dcount, doffset, boffset: Integer; reverse: Boolean; pal: Pointer; palcount: Integer);
var
  ij, ik: Integer;
asm
// eax = source
// edx = dest
// ecx = scount0

    push edi
    push ebx

    mov  edi,edx          // edi <- dest
    mov  ebx,ecx          // ebx <- scount0
    mov  ecx,[dcount]     // ecx <- dcount
    mov  [dcount],ebx     // dcount <- scount0
    and  [boffset], 3

//  if dcount = 0 then Exit;
    test ecx,ecx
    js   @exit
    jz   @exit

    push esi
    mov  esi,eax          // esi <- source

//  doffset := dcount0 - doffset * scount0 mod dcount0 - 1;
    mov  eax,[doffset]
    imul ebx
    idiv [dcount0]
    mov  eax,[dcount0]
    stc
    sbb  eax,edx
    mov  edx,eax          // edx <- doffset

    test byte ptr [reverse],$FF
    jz   @not_reverse
    lea  edi,[edi + ecx * 4 - 4]
    std

// edx = doffset / ebx = ? / ecx = dcount / esi = source / edi = dest
  @not_reverse:
    push  edx
    mov   eax,[esi]
    add   esi,4
    mov   ebx,eax
    mov   edx,[boffset]

  @loop_offset:
    and   edx,3
    jz    @end_offset
    shr   ebx,8
    dec   edx
    jmp   @loop_offset

  @end_offset:
    and   eax,$07070707
    and   ebx,$F8F8F8F8
    or    eax,ebx
    call  FetchJK
    mov   [ij],eax
    mov   [ik],edx

  @loop_bit:
    push  esi
    mov   edx,ebx
//    shr   ebx,8
    and   edx,$1F
    mov   eax,edx
    test  eax,1
    jz    @do_yjk
    shr   eax,1
    cmp   eax,[palcount]
    jnc   @put_color
    shl   eax,2
    add   eax,dword ptr [pal]
    mov   eax,[eax]
    jmp   @put_color

  @do_yjk:
    add   eax,[ij]
    jns   @no_less_r
    xor   eax,eax
    jmp   @no_more_r

  @no_less_r:
    cmp   eax,31
    jle   @no_more_r
    mov   eax,31

  @no_more_r:
    imul  eax,33
    shr   eax,2
    shl   eax,16
    or    edx,eax

    movzx eax,dl
    add   eax,[ik]
    jns   @no_less_g
    xor   eax,eax
    jmp   @no_more_g

  @no_less_g:
    cmp   eax,31
    jle   @no_more_g
    mov   eax,31

  @no_more_g:
    imul  eax,33
    shr   eax,2
    shl   eax,8
    or    edx,eax

    movzx eax,dl
    imul  eax,5
    shr   eax,2
    mov   esi,[ij]
    test  esi,esi
    jns   @no_sign_ij
    inc   esi

  @no_sign_ij:
    sar   esi,1
    sub   eax,esi
    mov   esi,[ik]
    test  esi,esi
    jns   @no_sign_ik
    inc   esi

  @no_sign_ik:
    sar   esi,1
    sub   eax,esi
    jns   @no_less_b
    xor   eax,eax
    jmp   @no_more_b

  @no_less_b:
    cmp   eax,31
    jle   @no_more_b
    mov   eax,31

  @no_more_b:
    imul  eax,33
    shr   eax,2
    mov   dl,al
    mov   eax,edx
    or    eax,$FF000000

  @put_color:
    pop   esi
    pop   edx

  @loop_x:
    stosd
    sub   edx,[dcount]
    jc    @inc_src
    dec   ecx
    jnz   @loop_x
    jmp   @end_copy

  @inc_src:
    push  ecx
    mov   ecx,edx

  @loop_inc_src:
    shr   ebx,8
    inc   [boffset]
    and   [boffset],3
    jnz   @no_inc_esi
    mov   eax,[esi]
    add   esi,4
    call  FetchJK
    mov   [ij],eax
    mov   [ik],edx

  @no_inc_esi:
    add   ecx,[dcount0]
    jnc   @loop_inc_src
    xchg  ecx,[esp]
    dec   ecx
    jnz   @loop_bit
    pop   edx

  @end_copy:
    cld
    pop   esi

  @exit:
    pop   ebx
    pop   edi
end;

////**** not complete ***
//procedure CopyScreen2(source, dest: Pointer; count, boffset: Integer; pattable, coltable: Pointer; reverse: Boolean; pal: Pointer; palcount: Integer);
//asm
//// eax = source
//// edx = dest
//// ecx = count
//
//    cmp   ecx,1
//    jl    @exit
//
//    push  esi
//    push  edi
//    push  ebx
//
//    test  byte ptr [reverse],$FF
//    jz    @not_reverse
//    lea   edx,[edx + ecx * 4 - 4]
//    std
//
//  @not_reverse:
//    mov   esi,eax
//    mov   edi,edx
//
//    mov   eax,[esi]
//    add   esi,4
//    mov   ebx,eax
//    mov   edx,[boffset]
//
//  @loop_offset:
//    test  edx,3
//    jz    @end_offset
//    shr   ebx,8
//    dec   edx
//    jmp   @loop_offset
//
//  @end_offset:
//    and   eax,$07070707
//    and   ebx,$F8F8F8F8
//    or    eax,ebx
//
//  @loop_d:
//
//
//
//  @loop_byte:
//    add   esi,4
//    xchg  esi,[esp]
//
//  @loop_bit:
//    rol   edx,cl
//    mov   eax,edx
////    and   eax,[nbits]
//    cmp   eax,[palcount]
//    jnc   @no_pal
//    shl   eax,2
//    add   eax,[pal]
//    mov   eax,[eax]
//
//  @no_pal:
//    stosd
//    dec   esi
//    jz    @end_copy
//    inc   ebx
//    and   ebx,[boffset]
//    jnz   @loop_bit
//
//    xchg  esi,[esp]
//    mov   edx,[esi]
//    xchg  dh,dl
//    rol   edx,16
//    xchg  dh,dl
//    jmp   @loop_byte
//
//  @end_copy:
//    cld
//    pop   ecx
//    pop   edi
//    pop   esi
//    pop   ebx
//
//  @exit:
//end;

procedure MMXCopyColor(source, dest: Pointer; count: Integer; reverse: Boolean; alpha: Integer);
asm
  // eax = source
  // edx = dest
  // ecx = count

  // test the counter for zero or negativity
    cmp   ecx,0
    jle   @exit

    push  ebx

    mov   ebx,[alpha]     // ebx  <-  ** ** ** ma
    test  ebx,$FF         // ebx  <-  ma 00 00 00
    jz    @end_copy

    push  esi
    mov   esi,eax         // esi <- src

    test  byte ptr reverse,$FF
    jz    @not_reverse
    lea   esi,[esi + ecx * 4 - 4]
    std

  @not_reverse:
    shl       ebx,3
    add       ebx,dword ptr MMXAlphaPtr
    movq      mm3,[ebx]
    mov       ebx,dword ptr MMXBiasPtr
    movq      mm4,[ebx]

  // loop start
  @loop_x:
    lodsd
    movd      mm1,eax
    pxor      mm0,mm0
    movd      mm2,[edx]
    punpcklbw mm1,mm0
    punpcklbw mm2,mm0

    psubw     mm1,mm2
    pmullw    mm1,mm3
    psllw     mm2,8

    paddw     mm2,mm4
    paddw     mm1,mm2
    psrlw     mm1,8
    packuswb  mm1,mm0
    movd      [edx],mm1

    add       edx,4

  // loop end
    dec       ecx
    jnz       @loop_x

    cld
    pop       esi

  @end_copy:
    pop       ebx

  @exit:
end;

procedure MMXCopyAlpha(source, dest: Pointer; count: Integer; reverse: Boolean);
asm
  // eax = source
  // edx = dest
  // ecx = count

  // test the counter for zero or negativity
    test ecx,ecx
    js   @exit
    jz   @exit

    test byte ptr reverse,$FF
    jz   @not_reverse
    lea  eax,[eax + ecx * 4 - 4]
    std

  @not_reverse:
    push esi
    push edi

    mov  esi,eax         // esi <- src
    mov  edi,edx         // edi <- dst

  // loop start
  @loop_x:
    lodsd
    test eax,$FF000000
    jz   @no_copy        // complete transparency, proceed to next point

  // test fa = 255 ?
    cmp  eax,$FF000000
    jnc  @full_copy

    movd      mm0,eax
    pxor      mm3,mm3
    movd      mm2,[edi]
    punpcklbw mm0,mm3
    mov       eax,dword ptr MMXBiasPtr
    punpcklbw mm2,mm3
    movq      mm1,mm0
    punpckhwd mm1,mm1
    psubw     mm0,mm2
    punpckhdq mm1,mm1
    psllw     mm2,8
    pmullw    mm0,mm1
    paddw     mm2,[eax]
    paddw     mm2,mm0
    psrlw     mm2,8
    packuswb  mm2,mm3
    movd      eax,mm2

  @full_copy:
    mov  [edi],eax

  @no_copy:
    add  edi,4

  // loop end
    dec  ecx
    jnz  @loop_x

    cld
    pop  edi
    pop  esi
  @exit:
end;

procedure MMXCopyAlpha(source, dest: Pointer; count: Integer; reverse: Boolean; alpha: Integer);
asm // copy alpha color with master alpha
  // eax = source
  // edx = dest
  // ecx = count

  // test the counter for zero or negativity
    test  ecx,ecx
    js    @exit
    jz    @exit

    test  byte ptr reverse,$FF
    jz    @not_reverse
    lea   eax,[eax + ecx * 4 - 4]
    std

  @not_reverse:
    push  ebx
    push  esi
    push  edi

    mov   esi,eax         // esi <- src
    mov   edi,edx         // edi <- dst
    mov   edx,[alpha]

  // loop start
  @loop_x:
    lodsd
    test  eax,$FF000000
    jz    @no_copy        // complete transparency, proceed to next point
    mov   ebx,eax
    shr   ebx,24
    inc   ebx
    imul  ebx,edx
    shr   ebx,8
    jz    @no_copy

    pxor      mm0,mm0
    movd      mm1,eax
    shl       ebx,3
    movd      mm2,[edi]
    punpcklbw mm1,mm0
    punpcklbw mm2,mm0
    add       ebx,dword ptr MMXAlphaPtr
    psubw     mm1,mm2
    pmullw    mm1,[ebx]
    psllw     mm2,8
    mov       ebx,dword ptr MMXBiasPtr
    paddw     mm2,[ebx]
    paddw     mm1,mm2
    psrlw     mm1,8
    packuswb  mm1,mm0
    movd      eax,mm1

  @full_copy:
    mov   [edi],eax

  @no_copy:
    add   edi,4

  // loop end
    dec   ecx
    jnz   @loop_x

    cld
    pop   edi
    pop   esi
    pop   ebx

  @exit:
end;

procedure MMXCopyColor(source, dest: Pointer; scount0, dcount0, dcount, doffset: Integer; reverse: Boolean; alpha: Integer);
asm
// eax = source
// edx = dest
// ecx = scount0

  // if dcount = 0 then Exit;
    cmp       ecx,0
    jle       @exit

    push      ebx

    mov       ebx,[alpha]   // ebx  <-  ** ** ** ma
    test      ebx,$FF       // ebx  <-  ma 00 00 00
    jz        @exit_pop

    push      esi
    push      edi

    shl       ebx,3
    add       ebx,dword ptr MMXAlphaPtr
    movq      mm3,[ebx]
    mov       ebx,dword ptr MMXBiasPtr
    movq      mm4,[ebx]

    mov       esi,eax       // esi <- source
    mov       edi,edx       // edi <- dest
    mov       ebx,ecx       // ebx <- scount0
    mov       ecx,[dcount]  // ecx <- dcount

  // doffset := dcount0 - doffset * scount0 mod dcount0 - 1;
    mov       eax,[doffset]
    imul      ebx
    idiv      [dcount0]
    mov       eax,[dcount0]
    stc
    sbb       eax,edx
    mov       edx,eax       // edx <- doffset

    test      byte ptr [reverse],$FF
    jz        @not_reverse
    lea       edi,[edi + ecx * 4 - 4]
    std

  @not_reverse:
    pxor      mm0,mm0     // mm0 = 00 00 00 00 00 00 00 00

  @loop_inc_x:
    movd      mm5,[esi]   // mm1 = 00 00 00 00 fa fr fg fb
    punpcklbw mm5,mm0     // mm1 = 00 fa 00 fr 00 fg 00 fb

  // loop start
  @loop_x:
    movq      mm1,mm5     // mm1 = 00 fa 00 fr 00 fg 00 fb
    movd      mm2,[edi]   // mm2 = 00 00 00 00 ba br bg bb
    punpcklbw mm2,mm0     // mm2 = 00 ba 00 br 00 bg 00 bb

                          // p = a - b; q = p * w
    psubw     mm1,mm2     // mm1 = 00 pa 00 pr 00 pg 00 pb
    pmullw    mm1,mm3     // mm1 = ***qa ***qr ***qg ***qb
    psllw     mm2,8       // mm2 = ba 00 br 00 bg 00 bb 00

                          // y = (1 - w) * b
    paddw     mm2,mm4     // mm2 = ba 80 br 80 bg 80 bb 80
    paddw     mm1,mm2     // mm1 = za ** zr ** zg ** zb **
    psrlw     mm1,8       // mm1 = 00 za 00 zr 00 zg 00 zb
    packuswb  mm1,mm0     // mm1 = 00 00 00 00 za zr zg zb
    movd      eax,mm1

    stosd
    sub   edx,ebx
    jc    @do_inc_esi
    dec   ecx
    jnz   @loop_x
    jmp   @end_copy

  @do_inc_esi:
    add   esi,4
    add   edx,[dcount0]
    jnc   @do_inc_esi
    dec   ecx
    jnz   @loop_inc_x

  @end_copy:
    cld
    pop   edi
    pop   esi

  @exit_pop:
    pop   ebx

  @exit:
end;

end.
