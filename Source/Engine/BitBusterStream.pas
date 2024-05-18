unit BitBusterStream;

interface

uses
  Classes, SysUtils;

type
  TBitBusterCoreClass = class of TBitBusterCore;
  TBitBusterCore = class
  private
    FStream: TStream;
  protected
    function GetPosition: Integer; virtual; abstract;
    procedure SetPosition(APos: Integer); virtual; abstract;
  public
    constructor Create(AStream: TStream);
    procedure Restart; virtual; abstract;
    function Read(var AData: Byte): Integer; virtual; abstract;
    function Write(AData: Byte): Integer; virtual; abstract;
    property Position: Integer read GetPosition write SetPosition;
    property Stream: TStream read FStream;
  end;
  TBitBusterDecode = class(TBitBusterCore)
  private
    src_position, out_position: Integer;
    bit_count, match_length, repeat_length: Integer;
    bit_data: Byte;
    out_data: array[0..2047] of Byte;
    function ReadBit: Integer;
    function ReadByte: Byte;
    function ReadGammaValue: Integer;
  protected
    function GetPosition: Integer; override;
    procedure SetPosition(APos: Integer); override;
  public
    procedure Restart; override;
    function Read(var AData: Byte): Integer; override;
    function Write(AData: Byte): Integer; override;
  end;
  TBitBusterEncode = class(TBitBusterCore)
  protected
    function GetPosition: Integer; override;
    procedure SetPosition(APos: Integer); override;
  public
    procedure Restart; override;
    function Read(var AData: Byte): Integer; override;
    function Write(AData: Byte): Integer; override;
  end;
  TBitBusterStream = class(TStream)
  private
    FDecoder: TBitBusterCore;
    FEncoder: TBitBusterCore;
    FWriteMode: Boolean;
  protected
    function GetDecoderClass: TBitBusterCoreClass; virtual;
    function GetEncoderClass: TBitBusterCoreClass; virtual;
    function GetSize: Int64; override;
    procedure SetSize(NewSize: Longint); override;
    procedure SetSize(const NewSize: Int64); override;
  public
    constructor Create(const AStream: TStream; AWriteMode: Boolean);
    destructor Destroy; override;
    procedure Restart; virtual;
    function Read(var Buffer; Count: Longint): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
  end;

  TG9BCore = class(TBitBusterCore)
  private
    FBlockCount, FBitData: Byte;
    FBlockSize, FBlockPos: Word;
    FBitCount: Integer;
    FDatas: array of Byte;
  public
    destructor Destroy; override;
    procedure Restart; override;
  end;
  TG9BDecode = class(TG9BCore)
  private
    FBuffers: array[0..2047] of Byte;
    FRepeatLength, FMatchLength, FMatchPos, FBufPos: Integer;
    function ReadBit: Integer;
    function ReadByte: Byte;
    function ReadGammaValue: Integer;
    procedure NextBlock;
  public
    function Read(var AData: Byte): Integer; override;
    procedure Restart; override;
  end;
  TG9BEncode = class(TG9BCore)
  public
    procedure Restart; override;
    function Write(AData: Byte): Integer; override;
  end;
  TG9BStream = class(TBitBusterStream)
  protected
    function GetDecoderClass: TBitBusterCoreClass; override;
    function GetEncoderClass: TBitBusterCoreClass; override;
  end;

implementation

{ TBitBusterCore }

constructor TBitBusterCore.Create(AStream: TStream);
begin
  FStream := AStream;
  Restart;
end;

{ TBitBusterDecode }

function TBitBusterDecode.GetPosition: Integer;
begin
  Result := out_position;
end;

function TBitBusterDecode.Read(var AData: Byte): Integer;
var
  offset: Integer;
begin
  if repeat_length > 0 then
  begin
    AData := out_data[(out_position - 1) and $7FF];
    out_data[out_position and $7FF] := AData;
    Inc(out_position);
    Dec(repeat_length);
    Result := 1;
  end
  else if match_length > 0 then
  begin
    AData := out_data[src_position and $7FF];
    out_data[out_position and $7FF] := AData;
    Inc(out_position);
    Inc(src_position);
    Dec(match_length);
    Result := 1;
  end
  else
  begin
    if ReadBit <> 0 then
    begin
      offset := ReadByte;
      if offset = 0 then // RLE
      begin
        repeat_length := ReadGammaValue + 2;
        Result := Read(AData);
      end
      else
      begin
        if (offset and 128) <> 0 then
        begin
          offset := offset and 127;
          offset := offset or (ReadBit shl 10);
          offset := offset or (ReadBit shl 9);
          offset := offset or (ReadBit shl 8);
          offset := offset or (ReadBit shl 7);
        end;
        src_position := out_position - offset - 1;
        match_length := ReadGammaValue + 2;
        Result := Read(AData);
      end;
    end
    else
    begin
      AData := ReadByte;
      out_data[out_position and $7FF] := AData;
      Inc(out_position);
      Result := 1;
    end;
  end;
end;

function TBitBusterDecode.ReadBit: Integer;
begin
  if bit_count = 8 then
  begin
    bit_data := 0;
    FStream.Read(bit_data, 1);
    bit_count := 0;
  end;
  Inc(bit_count);
  Result := (bit_data and 128) shr 7;
  bit_data := bit_data shl 1;
end;

function TBitBusterDecode.ReadByte: Byte;
begin
  Result := 0;
  FStream.Read(Result, 1);
end;

function TBitBusterDecode.ReadGammaValue: Integer;
var
  n: Integer;
begin
  Result := 1;
  n := 0;
  while ReadBit <> 0 do Inc(n);
  while n > 0 do
  begin
    Dec(n);
    Result := Result shl 1;
    if ReadBit <> 0 then Inc(Result);
  end;
  Dec(Result);
end;

procedure TBitBusterDecode.Restart;
begin
  bit_count := 8;
  bit_data := 0;
  src_position := 0;
  out_position := 0;
  repeat_length := 0;
  match_length := 0;
end;

procedure TBitBusterDecode.SetPosition(APos: Integer);
begin
  raise Exception.Create('Can not set size on BitBuster decoder.');
end;

function TBitBusterDecode.Write(AData: Byte): Integer;
begin
  raise Exception.Create('BitBuster decoder can not write any data.');
end;

{ TBitBusterEncode }

function TBitBusterEncode.GetPosition: Integer;
begin
  raise Exception.Create('Can not get position on BitBuster encoder.');
end;

function TBitBusterEncode.Read(var AData: Byte): Integer;
begin
  raise Exception.Create('BitBuster encoder can not read any data.');
end;

procedure TBitBusterEncode.Restart;
begin

end;

procedure TBitBusterEncode.SetPosition(APos: Integer);
begin
  raise Exception.Create('Can not set position on BitBuster encoder.');
end;

function TBitBusterEncode.Write(AData: Byte): Integer;
begin
  Result := 0;
end;

{ TBitBusterStream }

constructor TBitBusterStream.Create(const AStream: TStream; AWriteMode: Boolean);
begin
  if AWriteMode then
  begin
    FDecoder := nil;
    FEncoder := GetEncoderClass.Create(AStream);
  end
  else
  begin
    FDecoder := GetDecoderClass.Create(AStream);
    FEncoder := nil;
  end;
  FWriteMode := AWriteMode;
end;

destructor TBitBusterStream.Destroy;
begin
  FreeAndNil(FDecoder);
  FreeAndNil(FEncoder);
  inherited Destroy;
end;

function TBitBusterStream.GetDecoderClass: TBitBusterCoreClass;
begin
  Result := TBitBusterDecode;
end;

function TBitBusterStream.GetEncoderClass: TBitBusterCoreClass;
begin
  Result := TBitBusterEncode;
end;

function TBitBusterStream.GetSize: Int64;
begin
  raise Exception.Create('Can not get size on BitBuster stream.');
end;

function TBitBusterStream.Read(var Buffer; Count: Longint): Longint;
var
  n: Integer;
  p: PByte;
begin
  Result := 0;
  if not FWriteMode then
  begin
    p := @Buffer;
    n := 1;
    while (Count > 0) and (n > 0) do
    begin
      n := FDecoder.Read(p^);
      Inc(Result, n);
      Inc(p);
      Dec(Count);
    end
  end
  else raise Exception.Create('Can not read from BitBuster write stream.');
end;

procedure TBitBusterStream.Restart;
begin
  if not FWriteMode then
    FDecoder.Restart
  else FEncoder.Restart;
end;

function TBitBusterStream.Seek(const Offset: Int64; Origin: TSeekOrigin): Int64;
var
  n, p: Int64;
  b: Byte;
begin
  if not FWriteMode then
  begin
    case Origin of
      soCurrent: n := FDecoder.Position + Offset;
      soEnd: raise Exception.Create('Can not seek with soEnd on BitBuster stream.')
    else
      n := Offset;
    end;
    if n >= FDecoder.Position then
    begin
      p := FDecoder.Position;
      while p < n do
      begin
        FDecoder.Read(b);
        Inc(p);
      end;
    end
    else raise Exception.CreateFmt('Seek position error for BitBuster read stream. (%d)', [Offset]);
    Result := FDecoder.Position;
  end
  else raise Exception.Create('Can not seek on BitBuster write stream.');
end;

procedure TBitBusterStream.SetSize(const NewSize: Int64);
begin
  raise Exception.Create('Can not set size of BitBuster stream.');
end;

procedure TBitBusterStream.SetSize(NewSize: Longint);
begin
  raise Exception.Create('Can not set size of BitBuster stream.');
end;

function TBitBusterStream.Write(const Buffer; Count: Longint): Longint;
var
  n: Integer;
  p: PByte;
begin
  Result := 0;
  if FWriteMode then
  begin
    p := @Buffer;
    n := 1;
    while (Count > 0) and (n > 0) do
    begin
      n := FEncoder.Write(p^);
      Inc(Result, n);
      Inc(p);
      Dec(Count);
    end;
  end
  else raise Exception.Create('Can not write to BitBuster read stream.');
end;

{ TG9BStream }

function TG9BStream.GetDecoderClass: TBitBusterCoreClass;
begin
  Result := TG9BDecode;
end;

function TG9BStream.GetEncoderClass: TBitBusterCoreClass;
begin
  Result := TG9BEncode;
end;

{ TG9BDecode }

procedure TG9BDecode.NextBlock;
begin
  if FBlockCount = 0 then FStream.Read(FBlockCount, 1);
  FStream.Read(FBlockSize, 2);
  SetLength(FDatas, FBlockSize);
  FStream.Read(FDatas[0], FBlockSize);
  FBlockPos := 0;
  Dec(FBlockCount);
  FBitData := 0;
  FBitCount := 8;
end;

function TG9BDecode.Read(var AData: Byte): Integer;
var
  count, offset: Integer;
begin
  if FMatchLength > 0 then
  begin
    AData := FBuffers[FMatchPos and 2047];
    FBuffers[FBufPos and 2047] := AData;
    Inc(FMatchPos);
    Inc(FBufPos);
    Dec(FMatchLength);
    Result := 1;
  end
  else if ReadBit = 0 then
  begin
    AData := ReadByte;
    FBuffers[FBufPos and 2047] := AData;
    Inc(FBufPos);
    Result := 1;
  end
  else
  begin
    count := ReadGammaValue;
    if count > 65536 then
    begin
      NextBlock;
      Result := Read(AData);
    end
    else
    begin
      offset := ReadByte;
      if (offset and 128) <> 0 then
      begin
        offset := (offset and 127) or (ReadBit shl 10);
        offset := offset or (ReadBit shl 9);
        offset := offset or (ReadBit shl 8);
        offset := offset or (ReadBit shl 7);
      end;
      FMatchPos := FBufPos - offset - 1;
      FMatchLength := count;
      Result := Read(AData);
    end;
  end;
end;

function TG9BDecode.ReadBit: Integer;
begin
  if FBitCount = 8 then
  begin
    FBitData := ReadByte;
    FBitCount := 0;
  end;
  Inc(FBitCount);
  Result := (FBitData and 128) shr 7;
  FBitData := FBitData shl 1;
end;

function TG9BDecode.ReadByte: Byte;
begin
  if FBlockPos < FBlockSize then
  begin
    Result := FDatas[FBlockPos];
    Inc(FBlockPos);
  end
  else Result := 0;
end;

function TG9BDecode.ReadGammaValue: Integer;
var
  have: Boolean;
begin
  Result := 1;
  have := ReadBit <> 0;
  while have do
  begin
    Result := (Result shl 1) or ReadBit;
    if Result < 65536 then
      have := ReadBit <> 0
    else have := False;
  end;
  Inc(Result);
end;

procedure TG9BDecode.Restart;
begin
  inherited Restart;
  FRepeatLength := 0;
  FMatchLength := 0;
  FMatchPos := 0;
  FBufPos := 0;
  NextBlock;
end;

{ TG9BCore }

destructor TG9BCore.Destroy;
begin
  SetLength(FDatas, 0);
  inherited Destroy;
end;

procedure TG9BCore.Restart;
begin
  FBlockCount := 0;
  FBlockSize := 0;
  FBlockPos := 0;
  FBitData := 0;
  FBitCount := 8;
  SetLength(FDatas, 0);
end;

{ TG9BEncode }

procedure TG9BEncode.Restart;
begin
  inherited Restart;
end;

function TG9BEncode.Write(AData: Byte): Integer;
begin
  Result := 0;
end;

end.
