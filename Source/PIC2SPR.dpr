program PIC2SPR;

uses
  Vcl.Forms,
  Form_Main in 'Form_Main.pas' {FormMain},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Smokey Quartz Kamri');
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
