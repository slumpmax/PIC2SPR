unit Form_Main;

interface

uses
  MSXSprite,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Grids;

type
  TFormMain = class(TForm)
    ButtonBrowse: TButton;
    OpenDialog: TOpenDialog;
    GridSprite: TDrawGrid;
    procedure ButtonBrowseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure GridSpriteDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
  private
    FSprite: TMSXSprite;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

procedure TFormMain.ButtonBrowseClick(Sender: TObject);
begin
  if OpenDialog.Execute then
  begin
    FSprite.LoadFromGIF(OpenDialog.FileName);
    FSprite.SaveToFile(ChangeFileExt(OpenDialog.FileName, '.SP5'));
    GridSprite.Invalidate;
  end;
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  FSprite := TMSXSprite.Create;
end;

procedure TFormMain.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FSprite);
end;

procedure TFormMain.GridSpriteDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
  State: TGridDrawState);
var
  grid: TDrawGrid;
begin
  if FSprite = nil then Exit;
  grid := TDrawGrid(Sender);
  if ARow > 2 then
    FSprite.PutSprite(grid.Canvas, Rect, [((ARow - 3) * 16 + ACol) * 2, ((ARow - 3) * 16 + ACol) * 2 + 1])
  else if ARow < 2 then
    FSprite.PutSprite(grid.Canvas, Rect, [ARow + ACol * 2])
  else FSprite.PutColor(grid.Canvas, Rect, ACol);
  if gdSelected in State then
  begin
    grid.Canvas.Brush.Style := bsClear;
    grid.Canvas.Pen.Color := clRed;
    grid.Canvas.Pen.Width := 1;
    grid.Canvas.Pen.Style := psDot;
    grid.Canvas.Rectangle(Rect);

    Rect.Left := Rect.Left + 1;
    Rect.Top := Rect.Top + 1;
    Rect.Right := Rect.Right - 1;
    Rect.Bottom := Rect.Bottom - 1;
    grid.Canvas.Pen.Color := clWhite;
    grid.Canvas.Rectangle(Rect);

    Rect.Left := Rect.Left + 1;
    Rect.Top := Rect.Top + 1;
    Rect.Right := Rect.Right - 1;
    Rect.Bottom := Rect.Bottom - 1;
    grid.Canvas.Pen.Color := clRed;
    grid.Canvas.Rectangle(Rect);
  end;
end;

end.
