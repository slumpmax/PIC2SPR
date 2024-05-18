unit XPPackStream;

interface

uses
  Classes, SysUtils, Math;

type
  TXPPackCoreClass = class of TXPPackCore;
  TXPPackCore = class
  private
    FStream: TStream;
    FActive: Boolean;
    procedure SetActive(AValue: Boolean);
  protected
    procedure Changed; virtual; abstract;
  public
    constructor Create(AStream: TStream; Active: Boolean); overload;
    // not require for derived class
    constructor Create(AStream: TStream); overload; virtual;
    // maybe require for derived class
    destructor Destroy; override;
    function Read(var AData: Byte): Integer; virtual; abstract;
    function Write(AData: Byte): Integer; virtual; abstract;
    property Active: Boolean read FActive write SetActive;
    property Stream: TStream read FStream;
  end;

  TXPPackStreamClass = class of TXPPackStream;
  TXPPackStream = class(TStream)
  private
    FDecoder: TXPPackCore;
    FEncoder: TXPPackCore;
    FWriteMode: Boolean;
    FPosition: Int64;
    function GetActive: Boolean;
    procedure SetActive(AValue: Boolean);
    function GetCoder: TXPPackCore;
  protected
    function GetDecoderClass: TXPPackCoreClass; virtual; abstract;
    function GetEncoderClass: TXPPackCoreClass; virtual; abstract;
    function GetSize: Int64; override;
    procedure SetSize(const NewSize: Int64); override;
  public
    constructor Create(const AStream: TStream; WriteMode: Boolean; Active: Boolean = True);
    destructor Destroy; override;
    procedure Restart;
    procedure Start;
    procedure Stop;
    function Read(var Buffer; Count: Longint): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    property Active: Boolean read GetActive write SetActive;
    property Coder: TXPPackCore read GetCoder;
  end;

  TBufferStream = class(TStream)
  private
    FStream: TStream;
    FBuffer: array of Byte;
    FBlockSize, FStartOffset, FBufLength, FPosition, FStartPosition: Integer;
    procedure ReadBuffer;
  public
    constructor Create(AStream: TStream; AStartOffset, ABufLength: Integer; ABlockSize: Integer = 131072);
    destructor Destroy; override;
    function Read(var Buffer; Count: Longint): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
  end;

implementation

{ TXPPackCore }

constructor TXPPackCore.Create(AStream: TStream; Active: Boolean);
begin
  Create(AStream);
  SetActive(Active);
end;

constructor TXPPackCore.Create(AStream: TStream);

begin
  FStream := AStream;
  FActive := False;
end;

destructor TXPPackCore.Destroy;

begin
  SetActive(False);
  inherited Destroy;
end;

procedure TXPPackCore.SetActive(AValue: Boolean);

begin
  if AValue <> FActive then
  begin
    FActive := AValue;
    Changed;
  end;
end;

{ TXPPackStream }

constructor TXPPackStream.Create(const AStream: TStream; WriteMode: Boolean; Active: Boolean);
begin
  if WriteMode then
  begin
    FDecoder := nil;
    FEncoder := GetEncoderClass.Create(AStream, Active);
  end
  else
  begin
    FDecoder := GetDecoderClass.Create(AStream, Active);
    FEncoder := nil;
  end;
  FWriteMode := WriteMode;
  FPosition := 0;
end;

destructor TXPPackStream.Destroy;
begin
  SetActive(False);
  FreeAndNil(FDecoder);
  FreeAndNil(FEncoder);
  inherited Destroy;
end;

function TXPPackStream.GetActive: Boolean;
begin
  Result := Coder.Active;
end;

function TXPPackStream.GetCoder: TXPPackCore;
begin
  if FWriteMode then
    Result := FEncoder
  else Result := FDecoder;
end;

function TXPPackStream.GetSize: Int64;
begin
  if GetActive then
  begin
    raise EAbstractError.Create('Can not get size from pack stream.');
  end;
  Result := Coder.FStream.Size;
end;

function TXPPackStream.Read(var Buffer; Count: Longint): Longint;
var
  n: Integer;
  p: PByte;
begin
  if GetActive then
  begin
    if FWriteMode then
    begin
      raise Exception.Create('Can not read from write only pack stream.');
    end;
    Result := 0;
    p := @Buffer;
    n := 1;
    while (Count > 0) and (n > 0) do
    begin
      n := FDecoder.Read(p^);
      Inc(Result, n);
      Inc(p);
      Dec(Count);
    end;
    Inc(FPosition, Result);
  end
  else
  begin
    Result := Coder.FStream.Read(Buffer, Count);
  end;
end;

procedure TXPPackStream.Restart;
begin
  SetActive(False);
  SetActive(True);
end;

function TXPPackStream.Seek(const Offset: Int64; Origin: TSeekOrigin): Int64;
var
  n, nb: Int64;
  b: Byte;
begin
  if GetActive then
  begin
    if FWriteMode then
    begin
      raise Exception.Create('Can not seek on write only pack stream.');
    end;
    case Origin of
      soBeginning: n := Offset - FPosition;
      soEnd: n := GetSize + Offset - FPosition;
    else
      n := Offset;
    end;
    if n < 0 then
    begin
      raise Exception.Create('Can not seek backward on read only pack stream.');
    end;
    nb := 1;
    while (n > 0) and (nb > 0) do
    begin
      nb := FDecoder.Read(b);
      Inc(FPosition, nb);
      Dec(n);
    end;
    Result := FPosition;
  end
  else
  begin
    Result := Coder.FStream.Seek(Offset, Origin);
  end;
end;

procedure TXPPackStream.SetActive(AValue: Boolean);
begin
  if AValue <> GetActive then
  begin
    Coder.Active := AValue;
    if AValue then FPosition := 0;
  end;
end;

procedure TXPPackStream.SetSize(const NewSize: Int64);
begin
  if GetActive then
  begin
    raise EAbstractError.Create('Can not set size of pack stream.');
  end;
  Coder.FStream.Size := NewSize;
end;

procedure TXPPackStream.Start;
begin
  SetActive(True);
end;

procedure TXPPackStream.Stop;
begin
  SetActive(False);
end;

function TXPPackStream.Write(const Buffer; Count: Longint): Longint;
var
  n: Integer;
  p: PByte;
begin
  if GetActive then
  begin
    if not FWriteMode then
    begin
      raise Exception.Create('Can not write to read only pack stream.');
    end;
    Result := 0;
    p := @Buffer;
    n := 1;
    while (Count > 0) and (n > 0) do
    begin
      n := FEncoder.Write(p^);
      Inc(Result, n);
      Inc(p);
      Dec(Count);
    end;
    Inc(FPosition, Result);
  end
  else
  begin
    Result := Coder.FStream.Write(Buffer, Count);
  end;
end;

{ TBufferStream }

constructor TBufferStream.Create(AStream: TStream; AStartOffset, ABufLength, ABlockSize: Integer);
begin
  FStream := AStream;
  FStartOffset := AStartOffset;
  FBufLength := ABufLength;
  FBlockSize := ABlockSize;
  FStartPosition := -ABlockSize;
  FPosition := 0;
  SetLength(FBuffer, FBlockSize);
end;

destructor TBufferStream.Destroy;
begin
  SetLength(FBuffer, 0);
  inherited Destroy;
end;

function TBufferStream.Read(var Buffer; Count: Longint): Longint;
var
  p: PByteArray;
  n: Integer;
begin
  Result := 0;
  p := @Buffer;
  while (Count > 0) and (FPosition < FBufLength) do
  begin
    ReadBuffer;
    n := Min(Count, FStartPosition + FBlockSize - FPosition);
    Move(FBuffer[FPosition - FStartPosition], p[0], n);
    Inc(FPosition, n);
    Inc(Result, n);
    p := @p[n];
    Dec(Count, n);
  end;
end;

procedure TBufferStream.ReadBuffer;
begin
  if (FPosition < FStartPosition) or (FPosition >= FStartPosition + FBlockSize) then
  begin
    FStartPosition := FPosition - (FPosition mod FBlockSize);
    if FStartPosition < FBufLength then
    begin
      FStream.Seek(FStartOffset + FStartPosition, soBeginning);
      FStream.Read(FBuffer[0], Min(FBlockSize, FBufLength - FStartPosition));
    end;
  end;
end;

function TBufferStream.Seek(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
  case Origin of
    soCurrent: FPosition := FPosition + Offset;
    soEnd: FPosition := FBufLength + Offset;
  else
    FPosition := Offset;
  end;
  if FPosition < 0 then FPosition := 0;
  Result := FPosition;
end;

function TBufferStream.Write(const Buffer; Count: Longint): Longint;
begin
  raise Exception.Create('Can not write to buffer stream.');
end;

end.
