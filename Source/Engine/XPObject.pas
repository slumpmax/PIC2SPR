unit XPObject;

interface

uses
  XPRoutine, XPStream,
  Classes, SysUtils;

type
  TXPObject = class;
  TXPObjectClass = class of TXPObject;

  TXPDebugRec = record
    Text: string;
    Value: array of TXPDebugRec;
  end;

  TXPFileSupport = class
  private
    FObjectClass: TXPObjectClass;
    FName, FExtension, FResourceType, FSignature: string;
  public
    constructor Create;
    function Supported(AFileName: string): Boolean;
    property ObjectClass: TXPObjectClass read FObjectClass;
    property Name: string read FName;
    property Extension: string read FExtension;
    property ResourceType: string read FResourceType;
    property Signature: string read FSignature;
  end;

  TXPFileSupportList = class(TList)
  private
    function GetSupports(AIndex: Integer): TXPFileSupport;
    function GetSupportByExtension(AExtension: string): TXPFileSupport;
    function GetSupportByFileName(AFileName: string): TXPFileSupport;
  public
    function Add(ASupport: TXPFileSupport): Integer;
    function AddSupport(AObjectClass: TXPObjectClass; AName, AExtension, AResourceType,
      ASignature: string): TXPFileSupport;
    procedure AddSupportList(AList: TXPFileSupportList);
    function IndexOfSupport(AFileName: string): Integer;
    function IndexOfExtension(AExtension: string): Integer;
    function IndexOfResType(AResType: string): Integer;
    property Supports[AIndex: Integer]: TXPFileSupport read GetSupports; default;
    property SupportByFileName[AFileName: string]: TXPFileSupport read GetSupportByFileName;
    property SupportByExtension[AExtension: string]: TXPFileSupport read GetSupportByExtension;
  end;

  TXPObject = class
  private
    FOwnerClass: TXPObjectClass;
    FFileSupportIndex: Integer;
    FFileSupportList: TXPFileSupportList;
    function GetFileSupport: TXPFileSupport;
    function GetFileSupportClass: TXPObjectClass;
  protected
    function GetDebugText: string; virtual;
    function GetDebugRec: TXPDebugRec; virtual;
  public
    Compressed: Boolean;
    constructor Create; virtual;
    constructor CreateFromFile(AFileName: string);
    constructor CreateFromRes(AResName: string; AResType: PChar);
    constructor CreateFromResName(AResName, AResType: string);
    constructor CreateFromResID(AResID: Integer; AResType: PChar);
    destructor Destroy; override;
    procedure Clear; virtual;
    procedure Assign(AItem: TXPObject); virtual;
    function Compare(AItem: TXPObject): Integer; virtual;
    function Same(AItem: TXPObject): Boolean;
    function ClassTypeXP: TXPObjectClass;

    procedure ReadHeaderFromStream(AStream: TStream); virtual;
    procedure WriteHeaderToStream(AStream: TStream); virtual;

    procedure ReadFromStream(AStream: TStream); virtual;
    procedure WriteToStream(AStream: TStream); virtual;

    procedure LoadFromStream(AStream: TStream); virtual;
    procedure SaveToStream(AStream: TStream); virtual;

    procedure LoadFromResource(resfilename: string); overload;
    procedure LoadFromResource(resname: string; restype: PChar); overload;
    procedure LoadFromResourceID(resid: Integer; restype: PChar);

    procedure LoadFromFile(AFileName: string); virtual;
    procedure SaveToFile(AFileName: string); virtual;
    class function IsFileSupport(AFileName: string): Boolean;
    class procedure LoadSupports(AList: TXPFileSupportList); virtual;

    property FileSupportList: TXPFileSupportList read FFileSupportList;
    property FileSupportIndex: Integer read FFileSupportIndex write FFileSupportIndex;
    property FileSupport: TXPFileSupport read GetFileSupport;
    property FileSupportClass: TXPObjectClass read GetFileSupportClass;
    property OwnerClass: TXPObjectClass read FOwnerClass;
    property DebugText: string read GetDebugText;
    property DebugRec: TXPDebugRec read GetDebugRec;
  end;

implementation

{ TXPObject }

procedure TXPObject.Assign(AItem: TXPObject);
begin
  // dummy
end;

procedure TXPObject.Clear;
begin
  // dummy
end;

function TXPObject.Compare(AItem: TXPObject): Integer;
begin
  Result := 0;
end;

constructor TXPObject.Create;
begin
  FFileSupportList := TXPFileSupportList.Create;
  FFileSupportIndex := -1;
  Compressed := True;
  LoadSupports(FFileSupportList);
end;

constructor TXPObject.CreateFromFile(AFileName: string);
begin
  Create;
  LoadFromFile(AFileName);
end;

constructor TXPObject.CreateFromRes(AResName: string; AResType: PChar);
begin
  Create;
  LoadFromResource(AResName, AResType);
end;

constructor TXPObject.CreateFromResID(AResID: Integer; AResType: PChar);
begin
  Create;
  LoadFromResourceID(AResID, AResType);
end;

constructor TXPObject.CreateFromResName(AResName, AResType: string);
begin
  Create;
  LoadFromResource(AResName + AResType);
end;

destructor TXPObject.Destroy;
begin
  FFileSupportList.Free;
  inherited Destroy;
end;

function TXPObject.GetDebugRec: TXPDebugRec;
begin
  Result.Text := '';
  Result.Value := nil;
end;

function TXPObject.GetDebugText: string;
begin
  Result := '';
end;

function TXPObject.GetFileSupport: TXPFileSupport;
begin
  if FFileSupportIndex >= 0 then Result := FFileSupportList[FFileSupportIndex]
  else Result := nil;
end;

function TXPObject.GetFileSupportClass: TXPObjectClass;
begin
  if FFileSupportIndex >= 0 then Result := FFileSupportList[FFileSupportIndex].FObjectClass
  else Result := nil;
end;

class function TXPObject.IsFileSupport(AFileName: string): Boolean;
var
  AList: TXPFileSupportList;
begin
  AList := TXPFileSupportList.Create;
  try
    LoadSupports(AList);
    Result := AList.IndexOfSupport(AFileName) >= 0;
  finally
    AList.Free;
  end;
end;

procedure TXPObject.LoadFromStream(AStream: TStream);
begin
  ReadHeaderFromStream(AStream);
  if AStream is TLZWStream then TLZWStream(AStream).Start;
  ReadFromStream(AStream);
  if AStream is TLZWStream then TLZWStream(AStream).Stop;
end;

class procedure TXPObject.LoadSupports(AList: TXPFileSupportList);
begin
  // dummy
end;

procedure TXPObject.LoadFromFile(AFileName: string);
var
  fs: TFileStream;
  lzw: TLZWStream;
begin
  FFileSupportIndex := FFileSupportList.IndexOfSupport(AFileName);
  fs := TFileStream.Create(AFileName, fmOpenRead);
  try
    lzw := TLZWStream.Create(fs, False, False);
    try
      LoadFromStream(lzw);
    finally
      lzw.Free;
    end;
  finally
    fs.Free;
  end;
end;

procedure TXPObject.LoadFromResource(resname: string; restype: PChar);
var
  rs: TResourceStream;
  ls: TLZWStream;
begin
  FFileSupportIndex := FFileSupportList.IndexOfResType(restype);
  rs := TResourceStream.Create(hInstance, resname, restype);
  try
    ls := TLZWStream.Create(rs, False, False);
    try
      LoadFromStream(ls);
    finally
      ls.Free;
    end;
  finally
    rs.Free;
  end;
end;

procedure TXPObject.LoadFromResourceID(resid: Integer; restype: PChar);
var
  rs: TResourceStream;
  ls: TLZWStream;
begin
  FFileSupportIndex := FFileSupportList.IndexOfResType(restype);
  rs := TResourceStream.CreateFromID(hInstance, resid, restype);
  try
    ls := TLZWStream.Create(rs, False, False);
    try
      LoadFromStream(ls);
    finally
      ls.Free;
    end;
  finally
    rs.Free;
  end;
end;

procedure TXPObject.ReadFromStream(AStream: TStream);
begin
  // dummy
end;

procedure TXPObject.ReadHeaderFromStream(AStream: TStream);
var
  sig: AnsiString;
begin
  if FFileSupportIndex >= 0 then
    with FFileSupportList[FFileSupportIndex] do
    begin
      SetLength(sig, Length(FSignature));
      SetLength(sig, AStream.Read(sig[1], Length(sig)));
      if string(sig) <> FSignature then
      begin
        raise Exception.Create('Missing ' + FName + ' signature');
      end;
    end;
end;

procedure TXPObject.LoadFromResource(resfilename: string);
var
  rtype: string;
begin
  rtype := ExtractFileExt(resfilename);
  System.Delete(rtype, 1, 1);
  LoadFromResource(ChangeFileExt(resfilename, ''), PChar(rtype));
end;

function TXPObject.Same(AItem: TXPObject): Boolean;
begin
  Result := Compare(AItem) = 0;
end;

procedure TXPObject.SaveToStream(AStream: TStream);
begin
  WriteHeaderToStream(AStream);
  if AStream is TLZWStream then TLZWStream(AStream).Start;
  WriteToStream(AStream);
  if AStream is TLZWStream then TLZWStream(AStream).Stop;
end;

procedure TXPObject.SaveToFile(AFileName: string);
var
  fs: TFileStream;
  lzw: TLZWStream;
begin
  FFileSupportIndex := FFileSupportList.IndexOfSupport(AFileName);
  if FFileSupportIndex >= 0 then
    with FFileSupportList[FFileSupportIndex] do
    begin
      if not SameText(FExtension, ExtractFileExt(AFileName)) then
          AFileName := AFileName + FExtension;
    end;
  fs := TFileStream.Create(AFileName, fmCreate);
  try
    lzw := TLZWStream.Create(fs, True, False);
    try
      SaveToStream(lzw);
    finally
      lzw.Free;
    end;
  finally
    fs.Free;
  end;
end;

procedure TXPObject.WriteHeaderToStream(AStream: TStream);
var
  sig: AnsiString;
begin
  if FFileSupportIndex >= 0 then
    with FFileSupportList[FFileSupportIndex] do
    begin
      sig := AnsiString(FSignature);
      AStream.Write(sig[1], Length(sig));
    end;
end;

procedure TXPObject.WriteToStream(AStream: TStream);
begin
  // dummy
end;

function TXPObject.ClassTypeXP: TXPObjectClass;
begin
  Result := TXPObjectClass(Self.ClassType);
end;

{ TXPFileSupportList }

function TXPFileSupportList.Add(ASupport: TXPFileSupport): Integer;
begin
  if (IndexOfExtension(ASupport.Extension) >= 0) or (IndexOfResType(ASupport.ResourceType) >= 0)
  then raise Exception.CreateFmt('FileSupportList extension [%s] has exists.)',
      [ASupport.FExtension]);
  Result := inherited Add(ASupport);
end;

function TXPFileSupportList.AddSupport(AObjectClass: TXPObjectClass;
  AName, AExtension, AResourceType, ASignature: string): TXPFileSupport;
begin
  Result := TXPFileSupport.Create;
  Result.FObjectClass := AObjectClass;
  Result.FName := AName;
  Result.FExtension := AExtension;
  Result.FResourceType := AResourceType;
  Result.FSignature := ASignature;
  Add(Result);
end;

procedure TXPFileSupportList.AddSupportList(AList: TXPFileSupportList);
var
  n: Integer;
begin
  for n := 0 to AList.Count - 1 do
    with Supports[n] do
    begin
      AddSupport(FObjectClass, FName, FExtension, FResourceType, FSignature);
    end;
end;

function TXPFileSupportList.GetSupportByExtension(AExtension: string): TXPFileSupport;
var
  n: Integer;
begin
  n := IndexOfExtension(AExtension);
  if n >= 0 then Result := Supports[n]
  else Result := nil;
end;

function TXPFileSupportList.GetSupportByFileName(AFileName: string): TXPFileSupport;
var
  n: Integer;
begin
  n := IndexOfSupport(AFileName);
  if n >= 0 then Result := Supports[n]
  else Result := nil;
end;

function TXPFileSupportList.GetSupports(AIndex: Integer): TXPFileSupport;
begin
  Result := TXPFileSupport(inherited Items[AIndex]);
end;

function TXPFileSupportList.IndexOfExtension(AExtension: string): Integer;
var
  n: Integer;
begin
  Result := -1;
  n := Count;
  while (n > 0) and (Result < 0) do
  begin
    Dec(n);
    if SameText(Supports[n].FExtension, AExtension) then Result := n;
  end;
end;

function TXPFileSupportList.IndexOfResType(AResType: string): Integer;
var
  n: Integer;
begin
  Result := -1;
  n := Count;
  while (n > 0) and (Result < 0) do
  begin
    Dec(n);
    if SameText(Supports[n].FResourceType, AResType) then Result := n;
  end;
end;

function TXPFileSupportList.IndexOfSupport(AFileName: string): Integer;
var
  n: Integer;
begin
  Result := -1;
  n := Count;
  while (n > 0) and (Result < 0) do
  begin
    Dec(n);
    if Supports[n].Supported(AFileName) then Result := n;
  end;
end;

{ TXPFileSupport }

constructor TXPFileSupport.Create;
begin
  FObjectClass := nil;
  FName := '';
  FExtension := '';
  FResourceType := '';
  FSignature := '';
end;

function TXPFileSupport.Supported(AFileName: string): Boolean;
begin
  Result := SameText(ExtractFileExt(AFileName), FExtension);
end;

end.
