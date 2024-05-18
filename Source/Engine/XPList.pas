unit XPList;

interface

uses
  XPRoutine, XPStream, XPObject,
  Classes, SysUtils, Vcl.Dialogs, Variants, Math;

type
  TXPList = class;

  TXPListEnumerator = class
  private
    FIndex: Integer;
    FList: TXPList;
  public
    constructor Create(AList: TXPList);
    function GetCurrent: TXPObject;
    function MoveNext: Boolean;
    property Current: TXPObject read GetCurrent;
  end;

  TXPList = class(TXPObject)
  private
    FItems: array of TXPObject;
    FFirstIndex, FLastIndex: Integer;
    FCount: Integer;
  protected
    function GetDebugText: string; override;
    function GetDebugRec: TXPDebugRec; override;
    function GetItems(AIndex: Integer): TXPObject;
    procedure SetItems(AIndex: Integer; AItem: TXPObject);
    procedure SetFirstIndex(NewValue: Integer);
    property FirstIndex: Integer read FFirstIndex write SetFirstIndex;
    property LastIndex: Integer read FLastIndex;
  public
    ItemIndex: Integer;
    constructor Create; overload; override;
    destructor Destroy; override;
    procedure Clear; override;
    procedure Assign(AObject: TXPObject); override;
    procedure Allocate(NewSize: integer); virtual;

    function CreateItem: TXPObject; virtual;
    function CompareItem(AIndex, BIndex: Integer): Integer; virtual;

    function AddItem: TXPObject;
    function InsertItem(AIndex: Integer): TXPObject;
    function Add(AItem: TXPObject): Integer;
    procedure Insert(AIndex: Integer; AItem: TXPObject); virtual;
    procedure Delete(AItem: TXPObject); overload; virtual;
    procedure Delete(AIndex: Integer); overload; virtual;
    function Empty: Boolean;
    function Put(AItem: TXPObject): Integer;
    function Get: TXPObject;
    function Pop: TXPObject;
    function GetEnumerator: TXPListEnumerator;
    function IndexOf(AItem: TXPObject): Integer;
    procedure Sort; virtual;
    function Compare(AObject: TXPObject): Integer; override;
    function First: TXPObject;
    function Last: TXPObject;
    function Current: TXPObject;
    function Previous: TXPObject;
    function Next: TXPObject;

    procedure LoadFromStream(AStream: TStream); override;
    procedure AppendFromStream(AStream: TStream); virtual;
    procedure SaveToStream(AStream: TStream); override;

    procedure LoadFromFile(AFileName: string); override;
    procedure AppendFromFile(AFileName: string); virtual;

    property Count: Integer read FCount;
    property Items[AIndex: Integer]: TXPObject read GetItems write SetItems; default;
  end;

  TXPIntegerItem = class(TXPObject)
  protected
    function GetDebugText: string; override;
    function GetDebugRec: TXPDebugRec; override;
  public
    Value: Integer;
    constructor Create; override;
    procedure Clear; override;
    procedure Assign(AObject: TXPObject); override;
    function Compare(AItem: TXPObject): Integer; override;
  end;

  TXPIntegerList = class(TXPList)
  protected
    function GetValues(AIndex: Integer): Integer;
    procedure SetValues(AIndex, AValue: Integer);
  public
    function CreateItem: TXPObject; override;
    function AddValue(AValue: Integer = 0): Integer;
    procedure InsertValue(AIndex, AValue: Integer);
    function Put(AValue: Integer): Integer;
    function Get: Integer;
    function Pop: Integer;
    procedure ReadFromStream(AStream: TStream); override;
    procedure WriteToStream(AStream: TStream); override;
    class procedure LoadSupports(AList: TXPFileSupportList); override;
    property FirstIndex;
    property LastIndex;
    property Values[AIndex: Integer]: Integer read GetValues write SetValues; default;
  end;

  TXPStringItem = class(TXPObject)
  protected
    function GetDebugText: string; override;
    function GetDebugRec: TXPDebugRec; override;
  public
    Text: string;
    constructor Create; override;
    procedure Clear; override;
    procedure Assign(AObject: TXPObject); override;
    function Compare(AItem: TXPObject): Integer; override;
  end;

  TXPStringList = class(TXPList)
  protected
    function GetItems(AIndex: Integer): TXPStringItem;
    function GetLines(AIndex: Integer): string;
    procedure SetLines(AIndex: Integer; AText: string);
  public
    CaseSensitive: Boolean;
    constructor Create; override;

    function CreateItem: TXPObject; override;
    function CompareItem(AIndex, BIndex: Integer): Integer; override;

    function AddString(AText: string): Integer;
    procedure InsertString(AIndex: Integer; AText: string);
    function IndexOf(AText: string): Integer;
    procedure Put(AText: string);
    function Get: string;
    function Pop: string;
    function First: string;
    function Last: string;
    function Current: string;
    function Previous: string;
    function Next: string;
    procedure ReadFromStream(AStream: TStream); override;
    procedure WriteToStream(AStream: TStream); override;
    class procedure LoadSupports(AList: TXPFileSupportList); override;

    property FirstIndex;
    property LastIndex;
    property Items[AIndex: Integer]: TXPStringItem read GetItems;
    property Lines[AIndex: Integer]: string read GetLines write SetLines; default;
  end;

  TXPCollection = class;
  TXPCollectionItem = class(TXPObject)
  private
    FName: string;
    FParent: TXPCollection;
  protected
    procedure SetName(NewName: string);
    procedure SetParent(NewParent: TXPCollection);
    function GetDebugText: string; override;
    function GetDebugRec: TXPDebugRec; override;
  public
    constructor Create; override;
    procedure Clear; override;
    procedure Assign(AObject: TXPObject); override;
    function Compare(AItem: TXPObject): Integer; override;
    property Name: string read FName write SetName;
    property Parent: TXPCollection read FParent write SetParent;
  end;

  TXPCollection = class(TXPList)
  protected
    function GetItems(AIndex: Integer): TXPCollectionItem;
    function GetItemByName(AName: string): TXPCollectionItem;
    function GetNames(AIndex: Integer): string;
    procedure SetNames(AIndex: Integer; NewName: string);
  public
    function CreateItem: TXPObject; override;
    function Add(AItem: TXPCollectionItem): Integer; reintroduce;
    procedure Delete(AName: string); overload;
    function Compare(AItem: TXPObject): Integer; override;
    function IndexOfName(AName: string): Integer; virtual;
    function NameExists(AName: string): Boolean;
    property Items[AIndex: Integer]: TXPCollectionItem read GetItems;
    property ItemByName[AName: string]: TXPCollectionItem read GetItemByName; default;
    property Names[AIndex: Integer]: string read GetNames write SetNames;
  end;

  TXPVarCollectionItem = class(TXPCollectionItem)
  protected
    procedure SetAsInteger(AValue: Integer);
    function GetAsInteger: Integer;
    procedure SetAsFloat(AValue: Double);
    function GetAsFloat: Double;
    procedure SetAsDateTime(AValue: TDateTime);
    function GetAsDateTime: TDateTime;
    procedure SetAsBoolean(AValue: Boolean);
    function GetAsBoolean: Boolean;
    procedure SetAsString(AValue: string);
    function GetAsString: string;
    function GetDebugText: string; override;
    function GetDebugRec: TXPDebugRec; override;
  public
    Value: Variant;
    constructor Create; override;
    procedure Clear; override;
    procedure Assign(AObject: TXPObject); override;
    function Compare(AItem: TXPObject): Integer; override;
    property AsInteger: Integer read GetAsInteger write SetAsInteger;
    property AsFloat: Double read GetAsFloat write SetAsFloat;
    property AsBoolean: Boolean read GetAsBoolean write SetAsBoolean;
    property AsDateTime: TDateTime read GetAsDateTime write SetAsDateTime;
    property AsString: string read GetAsString write SetAsString;
  end;

  TXPVarCollection = class(TXPCollection)
  private
    function GetValueBool(AIndex: Variant): Boolean;
    function GetValueDateTime(AIndex: Variant): TDateTime;
    function GetValueFloat(AIndex: Variant): Double;
    function GetValueInt(AIndex: Variant): Integer;
    function GetValueStr(AIndex: Variant): string;
    procedure SetValueBool(AIndex: Variant; const Value: Boolean);
    procedure SetValueDateTime(AIndex: Variant; const Value: TDateTime);
    procedure SetValueFloat(AIndex: Variant; const Value: Double);
    procedure SetValueInt(AIndex: Variant; const Value: Integer);
    procedure SetValueStr(AIndex: Variant; const Value: string);
  protected
    function GetItems(AIndex: Variant): TXPVarCollectionItem;
    function GetValues(AIndex: Variant): Variant;
    procedure SetValues(AIndex, AValue: Variant);
    function GetItemByName(AName: string): TXPVarCollectionItem;
    function GetValueByName(AName: string): Variant;
    procedure SetValueByName(AName: string; AValue: Variant);
  public
    function CreateItem: TXPObject; override;
    property Items[AIndex: Variant]: TXPVarCollectionItem read GetItems;
    property Values[AIndex: Variant]: Variant read GetValues write SetValues; default;
    property ValueInt[AIndex: Variant]: Integer read GetValueInt write SetValueInt;
    property ValueFloat[AIndex: Variant]: Double read GetValueFloat write SetValueFloat;
    property ValueDateTime[AIndex: Variant]: TDateTime read GetValueDateTime write SetValueDateTime;
    property ValueBool[AIndex: Variant]: Boolean read GetValueBool write SetValueBool;
    property ValueStr[AIndex: Variant]: string read GetValueStr write SetValueStr;
  end;

  TXPStringCollectionItem = class(TXPCollectionItem)
  protected
    function GetDebugText: string; override;
    function GetDebugRec: TXPDebugRec; override;
  public
    Value: string;
    constructor Create; override;
    procedure Clear; override;
    procedure Assign(AObject: TXPObject); override;
    function Compare(AItem: TXPObject): Integer; override;
  end;

  TXPStringCollection = class(TXPCollection)
  protected
    function GetItems(AIndex: Variant): TXPStringCollectionItem;
    function GetValues(AIndex: Variant): string;
    procedure SetValues(AIndex: Variant; AValue: string);
    function GetItemByName(AName: string): TXPStringCollectionItem;
    function GetValueByName(AName: string): string;
    procedure SetValueByName(AName, AValue: string);
  public
    function CreateItem: TXPObject; override;
    property Items[AIndex: Variant]: TXPStringCollectionItem read GetItems;
    property Values[AIndex: Variant]: string read GetValues write SetValues; default;
  end;

implementation

{ TXPListEnumerator }

constructor TXPListEnumerator.Create(AList: TXPList);
begin
  inherited Create;
  FIndex := -1;
  FList := AList;
end;

function TXPListEnumerator.GetCurrent: TXPObject;
begin
  Result := FList[FIndex];
end;

function TXPListEnumerator.MoveNext: Boolean;
begin
  Result := FIndex < FList.Count - 1;
  if Result then Inc(FIndex);
end;

{ TXPList }

constructor TXPList.Create;
begin
  inherited Create;
  FCount := 0;
  FFirstIndex := 0;
  FLastIndex := -1;
  ItemIndex := -1;
  SetLength(FItems, 0);
end;

function TXPList.CreateItem: TXPObject;
begin
  Result := TXPObject.Create;
end;

destructor TXPList.Destroy;
begin
  Clear;
  inherited Destroy;
end;

procedure TXPList.Clear;
begin
  Allocate(0);
  FFirstIndex := 0;
  FLastIndex := -1;
  ItemIndex := -1;
end;

function TXPList.Compare(AObject: TXPObject): Integer;
var
  AList: TXPList;
  n: Integer;
begin
  AList := TXPList(AObject);
  n := FLastIndex + 1;
  Result := n - (AList.FLastIndex + 1);
  while (Result = 0) and (n > FFirstIndex) do
  begin
    Dec(n);
    Result := Items[n].Compare(AList.Items[n]);
  end;
end;

function TXPList.CompareItem(AIndex, BIndex: Integer): Integer;
begin
  Result := Items[AIndex].Compare(Items[BIndex]);
end;

procedure TXPList.Allocate(NewSize: Integer);
begin
  while FCount > NewSize do
  begin
    Dec(FCount);
    FItems[FCount].Free;
  end;
  SetLength(FItems, NewSize);
  while FCount < NewSize do
  begin
    FItems[FCount] := CreateItem;
    Inc(FCount);
  end;
  FLastIndex := FFirstIndex + FCount - 1;
end;

procedure TXPList.AppendFromStream(AStream: TStream);
begin
  ReadHeaderFromStream(AStream);
  ReadFromStream(AStream);
end;

procedure TXPList.AppendFromFile(AFileName: string);
begin
  inherited LoadFromFile(AFileName);
end;

procedure TXPList.Assign(AObject: TXPObject);
var
  xlist: TXPList;
  n: Integer;
begin
  if AObject is TXPList then
  begin
    xlist := AObject as TXPList;
    n := Length(xlist.FItems);
    SetLength(FItems, n);
    while n > 0 do
    begin
      Dec(n);
      FItems[n] := CreateItem;
      FItems[n].Assign(xlist.FItems[n]);
    end;
    FCount := xlist.FCount;
    FFirstIndex := xlist.FFirstIndex;
    FLastIndex := xlist.FLastIndex;
  end
  else raise Exception.Create('Can not assign TXPList with other class.');
end;

function TXPList.GetItems(AIndex: Integer): TXPObject;
  function ReturnAddr: Pointer;
  asm
      mov   eax,[ebp + 4]
  end;
begin
  try
    Result := FItems[AIndex - FFirstIndex];
  except
    raise Exception.Create('List index out of bound') at ReturnAddr;
  end;
end;

procedure TXPList.SetFirstIndex(NewValue: Integer);
begin
  FFirstIndex := NewValue;
  FLastIndex := NewValue + FCount - 1;
end;

procedure TXPList.SetItems(AIndex: Integer; AItem: TXPObject);
begin
  FItems[AIndex - FFirstIndex] := AItem;
end;

function TXPList.AddItem: TXPObject;
begin
  Result := CreateItem;
  Add(Result);
end;

function TXPList.Add(AItem: TXPObject): Integer;
begin
  SetLength(FItems, FCount + 1);
  FItems[FCount] := AItem;
  Inc(FCount);
  Inc(FLastIndex);
  Result := FLastIndex;
end;

function TXPList.InsertItem(AIndex: Integer): TXPObject;
begin
  Result := CreateItem;
  Insert(AIndex, Result);
end;

procedure TXPList.Insert(AIndex: Integer; AItem: TXPObject);
begin
  if (AIndex < FFirstIndex) or (AIndex > FLastIndex + 1) then
    raise Exception.Create('List index out of bounds')
  else
  begin
    AIndex := AIndex - FFirstIndex;
    SetLength(FItems, FCount + 1);
    System.Move(FItems[AIndex], FItems[AIndex + 1], (FCount - AIndex) * SizeOf(TXPObject));
    FItems[AIndex] := AItem;
    Inc(FCount);
    Inc(FLastIndex);
  end;
end;

procedure TXPList.Delete(AItem: TXPObject);
begin
  Delete(IndexOf(AItem));
end;

procedure TXPList.Delete(AIndex: Integer);
begin
  if (AIndex >= FFirstIndex) and (AIndex <= FLastIndex) then
  begin
    AIndex := AIndex - FFirstIndex;
    FItems[AIndex].Free;
    Dec(FCount);
    Dec(FLastIndex);
    System.Move(FItems[AIndex + 1], FItems[AIndex], (FCount - AIndex) * SizeOf(TXPObject));
    SetLength(FItems, FCount);
  end;
end;

function TXPList.Empty: Boolean;
begin
  Result := FCount > 0;
end;

function TXPList.IndexOf(AItem: TXPObject): Integer;
var
  n: Integer;
begin
  Result := -1;
  n := 0;
  while (Result < 0) and (n < FCount) do
  begin
    if FItems[n] = AItem then Result := n;
    Inc(n);
  end;
  Result := Result + FFirstIndex;
end;

function TXPList.Put(AItem: TXPObject): Integer;
begin
  Result := Add(AItem);
end;

function TXPList.Get: TXPObject;
begin
  if FCount > 0 then
  begin
    Result := Items[FFirstIndex];
    Delete(FFirstIndex);
  end
  else Result := nil;
end;

function TXPList.GetDebugRec: TXPDebugRec;
var
  p, n: Integer;
begin
  Result.Text := '';
  Result.Value := nil;
  p := 0;
  n := FCount;
  SetLength(Result.Value, n);
  while n > 0 do
  begin
    Result.Value[p] := FItems[p].DebugRec;
    Inc(p);
    Dec(n);
  end;
end;

function TXPList.GetDebugText: string;
var
  p, n: Integer;
begin
  Result := '';
  p := 0;
  n := FCount;
  while n > 0 do
  begin
    if Result <> '' then Result := Result + #13#10;
    Result := Result + Format('%d: %s', [FFirstIndex + p, FItems[p].DebugText]);
    Inc(p);
    Dec(n);
  end;
end;

function TXPList.GetEnumerator: TXPListEnumerator;
begin
  Result := TXPListEnumerator.Create(Self);
end;

function TXPList.Pop: TXPObject;
begin
  if FCount > 0 then
  begin
    Result := Items[FLastIndex];
    Delete(FLastIndex);
  end
  else Result := nil;
end;

procedure TXPList.SaveToStream(AStream: TStream);
begin
  WriteHeaderToStream(AStream);
  WriteToStream(AStream);
end;

procedure TXPList.Sort;
var
  n1, n2, nc: Integer;
  item: TXPObject;
begin
  n1 := FCount;
  while n1 > 1 do
  begin
    Dec(n1);
    nc := n1;
    n2 := n1;
    while n2 > 0 do
    begin
      Dec(n2);
      if CompareItem(FFirstIndex + nc, FFirstIndex + n2) < 0 then nc := n2;
    end;
    if nc <> n1 then
    begin
      item := FItems[n1];
      FItems[n1] := FItems[nc];
      FItems[nc] := item;
    end;
  end;
end;

function TXPList.First: TXPObject;
begin
  ItemIndex := FFirstIndex;
  Result := Current;
end;

function TXPList.Last: TXPObject;
begin
  ItemIndex := FLastIndex;
  Result := Current;
end;

procedure TXPList.LoadFromStream(AStream: TStream);
begin
  Clear;
  AppendFromStream(AStream);
end;

procedure TXPList.LoadFromFile(AFileName: string);
begin
  Clear;
  AppendFromFile(AFileName);
end;

function TXPList.Current: TXPObject;
begin
  if (ItemIndex >= FFirstIndex) and (ItemIndex <= FLastIndex) then
    Result := Items[ItemIndex]
  else Result := nil;
end;

function TXPList.Previous: TXPObject;
begin
  Dec(ItemIndex);
  if ItemIndex > FLastIndex then ItemIndex := FLastIndex;
  if ItemIndex >= FFirstIndex then
    Result := Items[ItemIndex]
  else
  begin
    ItemIndex := FFirstIndex - 1;
    Result := nil;
  end;
end;

function TXPList.Next: TXPObject;
begin
  Inc(ItemIndex);
  if ItemIndex < FFirstIndex then ItemIndex := FFirstIndex;
  if ItemIndex <= FLastIndex then
    Result := Items[ItemIndex]
  else
  begin
    ItemIndex := FLastIndex + 1;
    Result := nil;
  end;
end;

// TXPIntegerItem
procedure TXPIntegerItem.Assign(AObject: TXPObject);
begin
  inherited Assign(AObject);
  Value := TXPIntegerItem(AObject).Value;
end;
                  
procedure TXPIntegerItem.Clear;
begin
  inherited Clear;
  Value := 0;
end;

function TXPIntegerItem.Compare(AItem: TXPObject): Integer;
begin
  Result := Value - TXPIntegerITem(AItem).Value;
end;

constructor TXPIntegerItem.Create;
begin
  inherited Create;
  Value := 0;
end;

function TXPIntegerItem.GetDebugRec: TXPDebugRec;
begin
  Result.Text := IntToStr(Value);
  Result.Value := nil;
end;

function TXPIntegerItem.GetDebugText: string;
begin
  Result := IntToStr(Value);
end;

// TXPIntegerList
function TXPIntegerList.GetValues(AIndex: Integer): Integer;
begin
  Result := TXPIntegerItem(inherited Items[AIndex]).Value;
end;

procedure TXPIntegerList.SetValues(AIndex: Integer; AValue: Integer);
begin
  TXPIntegerItem(inherited Items[AIndex]).Value := AValue;
end;


function TXPIntegerList.CreateItem: TXPObject;
begin
  Result := TXPIntegerItem.Create;
end;

function TXPIntegerList.AddValue(AValue: Integer = 0): Integer;
begin
  Result := Add(TXPIntegerItem.Create);
  Values[Result] := AValue;
end;

procedure TXPIntegerList.InsertValue(AIndex, AValue: Integer);
var
  item: TXPIntegerItem;
begin
  item := TXPIntegerItem.Create;
  item.Value := AValue;
  Insert(AIndex, item);
end;

class procedure TXPIntegerList.LoadSupports(AList: TXPFileSupportList);
begin
  inherited LoadSupports(AList);
  AList.AddSupport(TXPIntegerList, 'TXPIntegerList', '.xpints', 'XPINTS', 'XPINTS'#0);
end;

function TXPIntegerList.Put(AValue: Integer): Integer;
begin
  Result := AddValue(AValue);
end;

procedure TXPIntegerList.ReadFromStream(AStream: TStream);
var
  n, nitem: Integer;
begin
  AStream.Read(nitem, 4);
  while nitem > 0 do
  begin
    Dec(nitem);
    AStream.Read(n, 4);
    AddValue(n);
  end;
end;

procedure TXPIntegerList.WriteToStream(AStream: TStream);
var
  n, nitem: Integer;
begin
  AStream.Write(FCount, 4);
  for nitem := 0 to FCount - 1 do
  begin
    n := Values[nitem];
    AStream.Write(n, 4);
  end;
end;

function TXPIntegerList.Get: Integer;
begin
  Result := Values[0];
  Delete(0);
end;

function TXPIntegerList.Pop: Integer;
begin
  Result := Values[FCount - 1];
  Delete(FCount - 1);
end;

// TXPStringItem
procedure TXPStringItem.Assign(AObject: TXPObject);
begin
  inherited Assign(AObject);
  Text := TXPStringItem(AObject).Text;
end;

procedure TXPStringItem.Clear;
begin
  inherited Clear;
  Text := '';
end;

function TXPStringItem.Compare(AItem: TXPObject): Integer;
begin
  Result := CompareStr(Text, TXPStringItem(AITem).Text);
end;

constructor TXPStringItem.Create;
begin
  inherited Create;
  Text := '';
end;

function TXPStringItem.GetDebugRec: TXPDebugRec;
begin
  Result.Text := Text;
  Result.Value := nil;
end;

function TXPStringItem.GetDebugText: string;
begin
  Result := Text;
end;

// TXPStringList
function TXPStringList.GetItems(AIndex: Integer): TXPStringItem;
begin
  Result := TXPStringItem(inherited Items[AIndex]);
end;

function TXPStringList.GetLines(AIndex: Integer): string;
begin
  Result := TXPStringItem(inherited Items[AIndex]).Text;
end;

procedure TXPStringList.SetLines(AIndex: Integer; AText: string);
begin
  TXPStringItem(inherited Items[AIndex]).Text := AText;
end;

function TXPStringList.CreateItem: TXPObject;
begin
  Result := TXPStringItem.Create;
end;

constructor TXPStringList.Create;
begin
  inherited Create;
  CaseSensitive := True;
end;

function TXPStringList.AddString(AText: string): Integer;
begin
  Result := Add(TXPStringItem.Create);
  Lines[Result] := AText;
end;

procedure TXPStringList.InsertString(AIndex: Integer; AText: string);
var
  item: TXPStringItem;
begin
  item := TXPStringItem.Create;
  item.Text := AText;
  Insert(AIndex, item);
end;

function TXPStringList.IndexOf(AText: string): Integer;
var
  same: Boolean;
  n: Integer;
begin
  n := FFirstIndex;
  Result := n - 1;
  while (Result < FFirstIndex) and (n <= FLastIndex) do
  begin
    if CaseSensitive then
      same := Items[n].Text = AText
    else same := SameText(Items[n].Text, AText);
    if same then Result := n;
    Inc(n);
  end;
end;

function TXPStringList.CompareItem(AIndex, BIndex: Integer): Integer;
begin
  if CaseSensitive then
    Result := CompareStr(Items[AIndex].Text, Items[BIndex].Text)
  else Result := CompareText(Items[AIndex].Text, Items[BIndex].Text);
end;

procedure TXPStringList.Put(AText: string);
begin
  AddString(AText);
end;

procedure TXPStringList.ReadFromStream(AStream: TStream);
var
  n, len: Integer;
  s: string;
begin
  AStream.Read(n, 4);
  while n > 0 do
  begin
    Dec(n);
    AStream.Read(len, 4);
    SetLength(s, len);
    AStream.Read(s[1], len);
  end;
end;

procedure TXPStringList.WriteToStream(AStream: TStream);
var
  n, len: Integer;
  s: string;
begin
  AStream.Write(FCount, 4);
  for n := 0 to FCount - 1 do
  begin
    s := Lines[n];
    len := Length(s);
    AStream.Write(len, 4);
    AStream.Write(s[1], len);
  end;
end;

function TXPStringList.Get: string;
begin
  Result := Lines[0];
  Delete(0);
end;

function TXPStringList.Pop: string;
begin
  Result := Lines[FCount - 1];
  Delete(FCount - 1);
end;

function TXPStringList.First: string;
var
  item: TXPStringItem;
begin
  item := TXPStringItem(inherited First);
  if item <> nil then
    Result := item.Text
  else Result := '';
end;

function TXPStringList.Last: string;
var
  item: TXPStringItem;
begin
  item := TXPStringItem(inherited Last);
  if item <> nil then
    Result := item.Text
  else Result := '';
end;

class procedure TXPStringList.LoadSupports(AList: TXPFileSupportList);
begin
  inherited LoadSupports(AList);
  AList.AddSupport(TXPStringList, 'TXPStringList', '.xpstrs', 'XPSTRS', 'XPSTRS'#0);
end;

function TXPStringList.Current: string;
var
  item: TXPStringItem;
begin
  item := TXPStringItem(inherited Current);
  if item <> nil then
    Result := item.Text
  else Result := '';
end;

function TXPStringList.Previous: string;
var
  item: TXPStringItem;
begin
  item := TXPStringItem(inherited Previous);
  if item <> nil then
    Result := item.Text
  else Result := '';
end;

function TXPStringList.Next: string;
var
  item: TXPStringItem;
begin
  item := TXPStringItem(inherited Next);
  if item <> nil then
    Result := item.Text
  else Result := '';
end;

{ TXPCollectionItem }

procedure TXPCollectionItem.Assign(AObject: TXPObject);
begin
  Name := TXPCollectionItem(AObject).Name;
end;

procedure TXPCollectionItem.Clear;
begin
  inherited Clear;
  FName := '';
end;

function TXPCollectionItem.Compare(AItem: TXPObject): Integer;
begin
  Result := CompareStr(Name, TXPCollectionItem(AItem).Name);
end;

constructor TXPCollectionItem.Create;
begin
  inherited Create;
  FParent := nil;
  FName := '';
end;

function TXPCollectionItem.GetDebugRec: TXPDebugRec;
begin
  Result.Text := FName + ':';
  Result.Value := nil;
end;

function TXPCollectionItem.GetDebugText: string;
begin
  Result := FName + ':';
end;

procedure TXPCollectionItem.SetName(NewName: string);
begin
  if FName <> NewName then
  begin
    if Assigned(FParent) then FParent.Delete(Self);
    FName := NewName;
    if Assigned(FParent) then FParent.Add(Self);
  end;
end;

procedure TXPCollectionItem.SetParent(NewParent: TXPCollection);
begin
  if FParent <> NewParent then
  begin
    if Assigned(FParent) then FParent.Delete(Self);
    if Assigned(NewParent) then NewParent.Add(Self);
  end;
end;

{ TXPCollection }

function TXPCollection.Add(AItem: TXPCollectionItem): Integer;
begin
  Result := -1;
  if AItem <> nil then
  begin
    Result := FCount;
    while (Result > 0) and (TXPCollectionItem(FItems[Result - 1]).Name > AItem.Name) do
    begin
      Dec(Result);
    end;
    if (Result < FCount) and (TXPCollectionItem(FItems[Result]).Name = AItem.Name) then
    begin
      FItems[Result].Free;
      FItems[Result] := AItem;
    end
    else Insert(Result, AItem);
    AItem.FParent := Self;
  end;
end;

function TXPCollection.Compare(AItem: TXPObject): Integer;
var
  ACollection: TXPCollection;
  n, m: Integer;
begin
  Result := 0;
  if not (AItem is TXPCollection) then
    Exception.Create('Compare destination is not TXPCollection')
  else
  begin
    ACollection := TXPCollection(AItem);
    n := Count;
    Result := n - ACollection.Count;
    while (Result = 0) and (n > 0) do
    begin
      Dec(n);
      m := ACollection.IndexOfName(Items[n].Name);
      if m >= 0 then
        Result := Items[n].Compare(ACollection.Items[m])
      else Result := 1;
    end;
  end;
end;

function TXPCollection.CreateItem: TXPObject;
begin
  Result := TXPCollectionItem.Create;
end;

procedure TXPCollection.Delete(AName: string);
begin
  inherited Delete(IndexOfName(AName));
end;

function TXPCollection.GetItemByName(AName: string): TXPCollectionItem;
var
  n: Integer;
begin
  n := IndexOfName(AName);
  if n < 0 then
    Result := nil
  else Result := TXPCollectionITem(inherited Items[n]);
end;

function TXPCollection.GetItems(AIndex: Integer): TXPCollectionItem;
begin
  Result := TXPCollectionItem(inherited Items[AIndex]);
end;

function TXPCollection.GetNames(AIndex: Integer): string;
begin
  Result := Items[AIndex].Name;
end;

procedure TXPCollection.SetNames(AIndex: Integer; NewName: string);
begin
  Items[AIndex].Name := NewName;
end;

function TXPCollection.IndexOfName(AName: string): Integer;
var
  n: Integer;
begin
  n := FCount;
  Result := -1;
  while (Result < 0) and (n > 0) do
  begin
    Dec(n);
    if Items[n].Name = AName then Result := n;
  end;
end;

function TXPCollection.NameExists(AName: string): Boolean;
begin
  Result := IndexOfName(AName) >= 0;
end;

{ TXPVarCollectionItem }

procedure TXPVarCollectionItem.Assign(AObject: TXPObject);
begin
  inherited Assign(AObject);
  Value := TXPVarCollectionItem(AObject).Value;
end;

procedure TXPVarCollectionItem.Clear;
begin
  inherited Clear;
  Value := NULL;
end;

function TXPVarCollectionItem.Compare(AItem: TXPObject): Integer;
var
  v1, v2: TXPVarCollectionItem;
begin
  try
    v1 := Self;
    v2 := TXPVarCollectionItem(AITem);
    Result := CompareStr(v1.AsString, v2.AsString);
  except
    Result := 0;
  end;
//  Result := CompareStr(AsString, TXPVarCollectionItem(AItem).AsString);
end;

constructor TXPVarCollectionItem.Create;
begin
  inherited Create;
  Value := NULL;
end;

function TXPVarCollectionItem.GetAsBoolean: Boolean;
begin
  Result := VarToBoolDef(Value, False);
end;

function TXPVarCollectionItem.GetAsDateTime: TDateTime;
begin
  Result := VarToDateTimeDef(Value, 0.0);
end;

function TXPVarCollectionItem.GetAsFloat: Double;
begin
  Result := VarToFloatDef(Value, 0.0);
end;

function TXPVarCollectionItem.GetAsInteger: Integer;
begin
  Result := VarToIntDef(Value, 0);
end;

function TXPVarCollectionItem.GetAsString: string;
begin
  if Self = nil then
    Result := ''
  else if VarType(Value) = VarDate then
    Result := FloatToStr(VarToFloatDef(Value, 0.0))
  else Result := VarToStrDef(Value, '');
end;

function TXPVarCollectionItem.GetDebugRec: TXPDebugRec;
begin
  Result.Text := Format('%s: %s', [FName, VarToStrDef(Value, '')]);
  Result.Value := nil;
end;

function TXPVarCollectionItem.GetDebugText: string;
begin
  Result := Format('%s: %s', [FName, VarToStrDef(Value, '')]);
end;

procedure TXPVarCollectionItem.SetAsBoolean(AValue: Boolean);
begin
  Value := AValue;
end;

procedure TXPVarCollectionItem.SetAsDateTime(AValue: TDateTime);
begin
  Value := AValue;
end;

procedure TXPVarCollectionItem.SetAsFloat(AValue: Double);
begin
  Value := AValue;
end;

procedure TXPVarCollectionItem.SetAsInteger(AValue: Integer);
begin
  Value := AValue;
end;

procedure TXPVarCollectionItem.SetAsString(AValue: string);
begin
  Value := AValue;
end;

{ TXPVarCollection }

function TXPVarCollection.CreateItem: TXPObject;
begin
  Result := TXPVarCollectionItem.Create;
end;

function TXPVarCollection.GetItemByName(AName: string): TXPVarCollectionItem;
begin
  Result := TXPVarCollectionItem(inherited ItemByName[AName]);
end;

function TXPVarCollection.GetItems(AIndex: Variant): TXPVarCollectionItem;
begin
  if VarIsOrdinal(AIndex) then
    Result := TXPVarCollectionItem(inherited Items[AIndex])
  else if VarIsStr(AIndex) then
    Result := GetItemByName(AIndex)
  else raise Exception.Create('Invalid collection index type.');
end;

function TXPVarCollection.GetValueBool(AIndex: Variant): Boolean;
begin
  Result := VarToBoolDef(Values[AIndex], False);
end;

function TXPVarCollection.GetValueByName(AName: string): Variant;
var
  item: TXPVarCollectionItem;
begin
  item := Items[AName];
  if item <> nil then
    Result := item.Value
  else Result := NULL;
end;

function TXPVarCollection.GetValueDateTime(AIndex: Variant): TDateTime;
begin
  Result := VarToDateTimeDef(Values[AIndex], 0.0);
end;

function TXPVarCollection.GetValueFloat(AIndex: Variant): Double;
begin
  Result := VarToFloatDef(Values[AIndex], 0.0);
end;

function TXPVarCollection.GetValueInt(AIndex: Variant): Integer;
begin
  Result := VarToIntDef(Values[AIndex], 0);
end;

function TXPVarCollection.GetValues(AIndex: Variant): Variant;
begin
  if VarIsOrdinal(AIndex) then
    Result := Items[AIndex].Value
  else if VarIsStr(AIndex) then
    Result := GetValueByName(AIndex)
  else raise Exception.Create('Invalid collection index type.');
end;

function TXPVarCollection.GetValueStr(AIndex: Variant): string;
begin
  Result := VarToStrDef(Values[AIndex], '');
end;

procedure TXPVarCollection.SetValueBool(AIndex: Variant; const Value: Boolean);
begin
  Values[AIndex] := Value;
end;

procedure TXPVarCollection.SetValueByName(AName: string; AValue: Variant);
var
  item: TXPVarCollectionItem;
begin
  item := Items[AName];
  if item = nil then
  begin
    item := TXPVarCollectionItem.Create;
    item.Name := AName;
    Add(item);
  end;
  item.Value := AValue;
end;

procedure TXPVarCollection.SetValueDateTime(AIndex: Variant;
  const Value: TDateTime);
begin
  Values[AIndex] := Value;
end;

procedure TXPVarCollection.SetValueFloat(AIndex: Variant; const Value: Double);
begin
  Values[AIndex] := Value;
end;

procedure TXPVarCollection.SetValueInt(AIndex: Variant; const Value: Integer);
begin
  Values[AIndex] := Value;
end;

procedure TXPVarCollection.SetValues(AIndex: Variant; AValue: Variant);
begin
  if VarIsOrdinal(AIndex) then
    TXPVarCollectionItem(inherited Items[AIndex]).Value := AValue
  else if VarIsStr(AIndex) then
    SetValueByName(AIndex, AValue)
  else raise Exception.Create('Invalid collection index type.');
end;

procedure TXPVarCollection.SetValueStr(AIndex: Variant; const Value: string);
begin
  Values[AIndex] := Value;
end;

{ TXPStringCollectionItem }

procedure TXPStringCollectionItem.Assign(AObject: TXPObject);
begin
  inherited Assign(AObject);
  Value := TXPStringCollectionItem(AObject).Value;
end;

procedure TXPStringCollectionItem.Clear;
begin
  inherited Clear;
  Value := '';
end;

function TXPStringCollectionItem.Compare(AItem: TXPObject): Integer;
begin
  Result := CompareStr(Value, TXPStringCollectionItem(AItem).Value);
end;

constructor TXPStringCollectionItem.Create;
begin
  inherited Create;
  Value := '';
end;

function TXPStringCollectionItem.GetDebugRec: TXPDebugRec;
begin
  Result.Text := Format('%s: %s', [FName, Value]);
  Result.Value := nil;
end;

function TXPStringCollectionItem.GetDebugText: string;
begin
  Result := Format('%s: %s', [FName, Value]);
end;

{ TXPStringCollection }

function TXPStringCollection.CreateItem: TXPObject;
begin
  Result := TXPStringCollectionItem.Create;
end;

function TXPStringCollection.GetItemByName(AName: string): TXPStringCollectionItem;
begin
  Result := TXPStringCollectionItem(inherited ItemByName[AName]);
end;

function TXPStringCollection.GetItems(AIndex: Variant): TXPStringCollectionItem;
begin
  if VarIsOrdinal(AIndex) then
    Result := TXPStringCollectionItem(inherited Items[AIndex])
  else if VarIsStr(AIndex) then
    Result := GetItemByName(AIndex)
  else raise Exception.Create('Invalid collection index type.');
end;

function TXPStringCollection.GetValueByName(AName: string): string;
var
  item: TXPStringCollectionItem;
begin
  item := Items[AName];
  if item <> nil then
    Result := item.Value
  else Result := '';
end;

function TXPStringCollection.GetValues(AIndex: Variant): string;
begin
  if VarIsOrdinal(AIndex) then
    Result := Items[AIndex].Value
  else if VarIsStr(AIndex) then
    Result := GetValueByName(AIndex)
  else raise Exception.Create('Invalid collection index type.');
end;

procedure TXPStringCollection.SetValueByName(AName, AValue: string);
var
  item: TXPStringCollectionItem;
begin
  item := Items[AName];
  if item = nil then
  begin
    item := TXPStringCollectionItem.Create;
    item.Name := AName;
    Add(item);
  end;
  item.Value := AValue;
end;

procedure TXPStringCollection.SetValues(AIndex: Variant; AValue: string);
begin
  if VarIsOrdinal(AIndex) then
    TXPStringCollectionItem(inherited Items[AIndex]).Value := AValue
  else if VarIsStr(AIndex) then
    SetValueByName(AIndex, AValue)
  else raise Exception.Create('Invalid collection index type.');
end;

end.

