object FormMain: TFormMain
  Left = 0
  Top = 0
  Caption = 'PIC to SPRITE'
  ClientHeight = 253
  ClientWidth = 810
  Color = clBtnFace
  Constraints.MinHeight = 292
  Constraints.MinWidth = 826
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    810
    253)
  PixelsPerInch = 96
  TextHeight = 13
  object ButtonBrowse: TButton
    Left = 727
    Top = 222
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Convert...'
    TabOrder = 0
    OnClick = ButtonBrowseClick
    ExplicitLeft = 674
    ExplicitTop = 370
  end
  object GridSprite: TDrawGrid
    Left = 8
    Top = 8
    Width = 794
    Height = 208
    Anchors = [akLeft, akTop, akRight, akBottom]
    ColCount = 16
    DefaultColWidth = 48
    DefaultRowHeight = 48
    FixedCols = 0
    RowCount = 4
    FixedRows = 0
    TabOrder = 1
    OnDrawCell = GridSpriteDrawCell
    ExplicitWidth = 741
    ExplicitHeight = 356
  end
  object OpenDialog: TOpenDialog
    Filter = 'GIF Images (*.gif)|*.gif|All Files (*.*)|*.*'
    Options = [ofFileMustExist, ofEnableSizing]
    Left = 200
    Top = 40
  end
end
