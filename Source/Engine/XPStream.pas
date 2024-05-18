unit XPStream;

interface

uses
  XPPackStream,
  Classes, SysUtils, Math;

const
  LZW_LARGEST_CODE = 4095;
  LZW_TABLE_SIZE = 9001;

type
  TLZWCore = class(TXPPackCore)
  private
    FOldCode, FCurrentCode: array of Word;
    FNewCode, FCode_Buffer, FTop_Stack: array of Byte;
    FPStack: Integer;
    FEof_Code, FClear_Code, FNew_Code, FFree_Code, FMax_Code: Word;
    FMin_Code_Size, FCode_Size: Word;
    FBits_Left, FByte_Left: Word;
    FCode: Word;
    FOverChar, FFrontChar: Word;
    FByte1: Byte;
    FPCode: Integer;
    FTiffMode: Boolean;
  public
    constructor Create(AStream: TStream); override;
  end;
  TLZWDecode = class(TLZWCore)
  private
    FEof: Boolean;
    function GetNextCode: Word;
  protected
    procedure Changed; override;
  public
    constructor Create(AStream: TStream); override;
    function Read(var AData: Byte): Integer; override;
    function Write(AData: Byte): Integer; override;
  end;
  TLZWEncode = class(TLZWCore)
  private
    FPrepacked: Boolean;
    FBit_Offset: Word;
    FPrefix_Code, FSuffix_Char: Word;
    procedure InitTable(FMin_Code_Size: Word);
    procedure WriteCode(code: Word);
    procedure Flush(n: Word);
  protected
    procedure Changed; override;
  public
    constructor Create(AStream: TStream); override;
    function Read(var AData: Byte): Integer; override;
    function Write(AData: Byte): Integer; override;
  end;
  TLZWStream = class(TXPPackStream)
  protected
    function GetDecoderClass: TXPPackCoreClass; override;
    function GetEncoderClass: TXPPackCoreClass; override;
  end;

  TLZWTiffDecode = class(TLZWDecode)
  public
    constructor Create(AStream: TStream); override;
  end;
  TLZWTiffEncode = class(TLZWEncode)
    constructor Create(AStream: TStream); override;
  end;
  TLZWTiffStream = class(TLZWStream)
  protected
    function GetDecoderClass: TXPPackCoreClass; override;
    function GetEncoderClass: TXPPackCoreClass; override;
  end;

  TPackBitsDecode = class(TXPPackCore)
  private
    FBuffer: array [0 .. 127] of Byte;
    FMatchPos, FMatchCount, FRepeatCount: Integer;
    FRepeatData: Byte;
  protected
    procedure Changed; override;
  public
    function Read(var AData: Byte): Integer; override;
    function Write(AData: Byte): Integer; override;
  end;
  TPackBitsEncode = class(TXPPackCore)
  protected
    procedure Changed; override;
  public
    function Read(var AData: Byte): Integer; override;
    function Write(AData: Byte): Integer; override;
  end;
  TPackBitsStream = class(TXPPackStream)
  protected
    function GetDecoderClass: TXPPackCoreClass; override;
    function GetEncoderClass: TXPPackCoreClass; override;
  end;

implementation

{ TLZWCore }

constructor TLZWCore.Create(AStream: TStream);
begin
  inherited Create(AStream);
  SetLength(FOldCode, 0);
  SetLength(FCurrentCode, 0);
  SetLength(FNewCode, 0);
  SetLength(FCode_Buffer, 0);
  SetLength(FTop_Stack, 0);
  FTiffMode := False;
end;

{ TLZWDecode }

procedure TLZWDecode.Changed;
var
  b: Byte;
begin
  if Active then
  begin
    if FTiffMode then FMin_Code_Size := 8
    else
    begin
      Stream.Read(b, 1);
      FMin_Code_Size := b;
      if (FMin_Code_Size < 2) or (FMin_Code_Size > 9) then FMin_Code_Size := 8;
    end;
    FPStack := 0;
    FCode_Size := FMin_Code_Size + 1;
    FMax_Code := 1 shl FCode_Size;
    if FTiffMode then Dec(FMax_Code);
    FClear_Code := 1 shl FMin_Code_Size;
    FEof_Code := FClear_Code + 1;
    FNew_Code := FEof_Code + 1;
    FFree_Code := FNew_Code;
    FByte_Left := 0;
    FBits_Left := 0;
    FOverChar := 0;
    FFrontChar := 0;
    FEof := False;
  end
  else
  begin
    while Read(b) > 0 do;
    Read(b);
  end;
end;

constructor TLZWDecode.Create(AStream: TStream);
begin
  inherited Create(AStream);
  SetLength(FCode_Buffer, 257);
  SetLength(FTop_Stack, LZW_LARGEST_CODE + 2);
  SetLength(FNewCode, LZW_LARGEST_CODE + 2);
  SetLength(FOldCode, LZW_LARGEST_CODE + 2);
  FEof := False;
end;

function TLZWDecode.GetNextCode: Word;
const
  code_mask: array [0 .. 12] of Word = (0, 1, 3, 7, $F, $1F, $3F, $7F, $FF, $1FF, $3FF, $7FF, $FFF);
var
  ret: Cardinal;
  b: Byte;
begin
  if FTiffMode then
  begin
    if FBits_Left = 0 then
    begin
      Stream.Read(FByte1, 1);
      FBits_Left := 8;
    end;
    ret := FByte1;
    while FCode_Size > FBits_Left do
    begin
      Stream.Read(FByte1, 1);
      ret := (ret shl 8) or FByte1;
      FBits_Left := FBits_Left + 8;
    end;
    Result := ret shr (FBits_Left - FCode_Size);
    FBits_Left := FBits_Left - FCode_Size;
    FByte1 := FByte1 and code_mask[FBits_Left];
  end
  else
  begin
    if FBits_Left = 0 then
    begin
      if FByte_Left <= 0 then
      begin
        FPCode := 0;
        Stream.Read(b, 1);
        FByte_Left := b;
        if (FByte_Left <> 0) then Stream.Read(FCode_Buffer[0], FByte_Left);
      end;
      FByte1 := FCode_Buffer[FPCode];
      Inc(FPCode);
      FBits_Left := 8;
      Dec(FByte_Left);
    end;
    ret := FByte1 shr (8 - FBits_Left);
    while FCode_Size > FBits_Left do
    begin
      if FByte_Left <= 0 then
      begin
        FPCode := 0;
        Stream.Read(b, 1);
        FByte_Left := b;
        if (FByte_Left <> 0) then Stream.Read(FCode_Buffer[0], FByte_Left);
      end;
      FByte1 := FCode_Buffer[FPCode];
      Inc(FPCode);
      ret := ret or (FByte1 shl FBits_Left);
      FBits_Left := FBits_Left + 8;
      Dec(FByte_Left);
    end;
    FBits_Left := FBits_Left - FCode_Size;
    Result := ret and code_mask[FCode_Size];
  end;
end;

function TLZWDecode.Read(var AData: Byte): Integer;
var
  c: Word;
begin
  Result := 0;
  if (FPStack > 0) then
  begin
    Dec(FPStack);
    AData := FTop_Stack[FPStack];
    Result := 1;
  end
  else if not FEof then
  begin
    c := GetNextCode;
    if c = FEof_Code then FEof := True
    else
    begin
      if c = FClear_Code then
      begin
        FCode_Size := FMin_Code_Size + 1;
        FFree_Code := FNew_Code;
        FMax_Code := 1 shl FCode_Size;
        if FTiffMode then Dec(FMax_Code);
        c := GetNextCode;
        while c = FClear_Code do c := GetNextCode;
        if c <> FEof_Code then
        begin
          if c >= FFree_Code then c := 0;
          FFrontChar := c;
          FOverChar := c;
          AData := c;
          Result := 1;
        end;
      end
      else
      begin
        FCode := c;
        if FCode >= FFree_Code then
        begin
          FCode := FOverChar;
          FTop_Stack[FPStack] := FFrontChar;
          Inc(FPStack);
        end;
        while FCode >= FNew_Code do
        begin
          FTop_Stack[FPStack] := FNewCode[FCode];
          Inc(FPStack);
          FCode := FOldCode[FCode];
        end;
        FTop_Stack[FPStack] := FCode;
        Inc(FPStack);
        if FFree_Code < FMax_Code then
        begin
          FNewCode[FFree_Code] := FCode;
          FFrontChar := FCode;
          FOldCode[FFree_Code] := FOverChar;
          Inc(FFree_Code);
          FOverChar := c;
        end;
        if (FFree_Code >= FMax_Code) and (FCode_Size < 12) then
        begin
          Inc(FCode_Size);
          FMax_Code := 1 shl FCode_Size;
          if FTiffMode then Dec(FMax_Code);
        end;
        Result := Read(AData);
      end;
    end;
  end;
end;

function TLZWDecode.Write(AData: Byte): Integer;
begin
  raise Exception.Create('Can not write to LZW read only stream.');
end;

{ TLZWEncode }

procedure TLZWEncode.Changed;
var
  b: Byte;
begin
  if Active then
  begin
    if not FTiffMode then
    begin
      b := 8;
      Stream.Write(b, 1);
    end;
    InitTable(8);
    FBit_Offset := 0;
    WriteCode(FClear_Code);
    FPrepacked := True;
  end
  else
  begin
    if not FPrepacked then WriteCode(FPrefix_Code);
    WriteCode(FEof_Code);
    if FBit_Offset > 0 then Flush((FBit_Offset + 7) div 8);
    Flush(0);
  end;
end;

constructor TLZWEncode.Create(AStream: TStream);
begin
  inherited Create(AStream);
  SetLength(FCode_Buffer, 259);
  SetLength(FOldCode, LZW_TABLE_SIZE);
  SetLength(FCurrentCode, LZW_TABLE_SIZE);
  SetLength(FNewCode, LZW_TABLE_SIZE);
end;

procedure TLZWEncode.Flush(n: Word);
var
  b: Byte;
begin
  b := n;
  if not FTiffMode then Stream.Write(b, 1);
  if n > 0 then Stream.Write(FCode_Buffer[0], n);
end;

procedure TLZWEncode.InitTable(FMin_Code_Size: Word);
var
  i: Word;
begin
  FCode_Size := FMin_Code_Size + 1;
  FClear_Code := 1 shl FMin_Code_Size;
  FEof_Code := FClear_Code + 1;
  FFree_Code := FClear_Code + 2;
  FMax_Code := 1 shl FCode_Size;
  if FTiffMode then Dec(FMax_Code);
  for i := 0 to LZW_TABLE_SIZE - 1 do FCurrentCode[i] := 0;
end;

function TLZWEncode.Read(var AData: Byte): Integer;
begin
  raise Exception.Create('Can not read from LZW write only stream.');
end;

function TLZWEncode.Write(AData: Byte): Integer;
var
  hx, d: Word;
begin
  if FPrepacked then
  begin
    FPrefix_Code := AData;
    FSuffix_Char := AData;
    FPrepacked := False;
    Result := 1;
  end
  else
  begin
    FSuffix_Char := AData;
    hx := (FPrefix_Code xor (FSuffix_Char shl 5)) mod LZW_TABLE_SIZE;
    d := 1;
    while True do
    begin
      if FCurrentCode[hx] = 0 then
      begin
        WriteCode(FPrefix_Code);
        d := FFree_Code;
        if FFree_Code <= LZW_LARGEST_CODE then
        begin
          FOldCode[hx] := FPrefix_Code;
          FNewCode[hx] := FSuffix_Char;
          FCurrentCode[hx] := FFree_Code;
          Inc(FFree_Code);
        end;
        if d = FMax_Code then
        begin
          if FCode_Size < 12 then
          begin
            Inc(FCode_Size);
            FMax_Code := 1 shl FCode_Size;
            if FTiffMode then Dec(FMax_Code);
          end
          else
          begin
            WriteCode(FClear_Code);
            if FTiffMode then InitTable(8)
            else InitTable(8);
          end;
        end;
        FPrefix_Code := FSuffix_Char;
        Break;
      end;
      if (FOldCode[hx] = FPrefix_Code) and (FNewCode[hx] = FSuffix_Char) then
      begin
        FPrefix_Code := FCurrentCode[hx];
        Break;
      end;
      hx := hx + d;
      d := d + 2;
      if hx >= LZW_TABLE_SIZE then hx := hx - LZW_TABLE_SIZE;
    end;
    Result := 1;
  end;
end;

procedure TLZWEncode.WriteCode(code: Word);
var
  temp: Cardinal;
  byte_offset: Word;
begin
  byte_offset := FBit_Offset shr 3;
  FBits_Left := FBit_Offset and 7;
  if byte_offset >= 254 then
  begin
    Flush(byte_offset);
    FCode_Buffer[0] := FCode_Buffer[byte_offset];
    FBit_Offset := FBits_Left;
    byte_offset := 0;
  end;
  if FBits_Left > 0 then
  begin
    if FTiffMode then
    begin
      temp := code or (FCode_Buffer[byte_offset] shl FCode_Size);
      FCode_Buffer[byte_offset] := temp shr Max(0, FBits_Left + FCode_Size - 8);
      FCode_Buffer[byte_offset + 1] := temp shr Max(0, FBits_Left + FCode_Size - 16);
      FCode_Buffer[byte_offset + 2] := temp shr Max(0, FBits_Left + FCode_Size - 24);
    end
    else
    begin
      temp := (code shl FBits_Left) or FCode_Buffer[byte_offset];
      FCode_Buffer[byte_offset] := temp;
      FCode_Buffer[byte_offset + 1] := (temp shr 8);
      FCode_Buffer[byte_offset + 2] := (temp shr 16);
    end;
  end
  else
  begin
    if FTiffMode then
    begin
      FCode_Buffer[byte_offset] := code shr (FCode_Size - 8);
      FCode_Buffer[byte_offset + 1] := code; // shl (16 - FCode_Size);
    end
    else
    begin
      FCode_Buffer[byte_offset] := code;
      FCode_Buffer[byte_offset + 1] := (code shr 8);
    end;
  end;
  FBit_Offset := FBit_Offset + FCode_Size;
end;

{ TLZWStream }

function TLZWStream.GetDecoderClass: TXPPackCoreClass;
begin
  Result := TLZWDecode;
end;

function TLZWStream.GetEncoderClass: TXPPackCoreClass;
begin
  Result := TLZWEncode;
end;

{ TPackBitsDecode }

procedure TPackBitsDecode.Changed;
begin
  FMatchCount := 0;
  FMatchPos := 0;
  FRepeatCount := 0;
  FRepeatData := 0;
end;

function TPackBitsDecode.Read(var AData: Byte): Integer;
var
  ib: ShortInt;
begin
  if FMatchCount > 0 then
  begin
    AData := FBuffer[FMatchPos];
    Inc(FMatchPos);
    Dec(FMatchCount);
    Result := 1;
  end
  else if FRepeatCount > 0 then
  begin
    AData := FRepeatData;
    Dec(FRepeatCount);
    Result := 1;
  end
  else
  begin
    Result := Stream.Read(ib, 1);
    if Result > 0 then
    begin
      case ib of
        0 .. 127:
          begin
            FMatchCount := ib + 1;
            FMatchPos := 0;
            Stream.Read(FBuffer[0], FMatchCount);
            Result := Read(AData);
          end;
        -128:
          begin
            AData := 128;
            Result := 1;
          end;
      else FRepeatCount := 1 - ib;
        Result := Stream.Read(FRepeatData, 1);
        if Result > 0 then Result := Read(AData);
      end;
    end;
  end;
end;

function TPackBitsDecode.Write(AData: Byte): Integer;
begin
  raise Exception.Create('Can not write to read only PackBits stream.');
end;

{ TPackBitsEncode }

procedure TPackBitsEncode.Changed;
begin
end;

function TPackBitsEncode.Read(var AData: Byte): Integer;
begin
  raise Exception.Create('Can not read from PackBits write stream.');
end;

function TPackBitsEncode.Write(AData: Byte): Integer;
begin
  Result := 0;
end;

{ TPackBitsStream }

function TPackBitsStream.GetDecoderClass: TXPPackCoreClass;
begin
  Result := TPackBitsDecode;
end;

function TPackBitsStream.GetEncoderClass: TXPPackCoreClass;
begin
  Result := TPackBitsEncode;
end;

{ TLZWTiffDecode }

constructor TLZWTiffDecode.Create(AStream: TStream);
begin
  inherited Create(AStream);
  FTiffMode := True;
end;

{ TLZWTiffEncode }

constructor TLZWTiffEncode.Create(AStream: TStream);
begin
  inherited Create(AStream);
  FTiffMode := True;
end;

{ TLZWTiffStream }

function TLZWTiffStream.GetDecoderClass: TXPPackCoreClass;
begin
  Result := TLZWTiffDecode;
end;

function TLZWTiffStream.GetEncoderClass: TXPPackCoreClass;
begin
  Result := TLZWTiffEncode;
end;

end.
