program mvcactiverecord_primer;

uses
  Vcl.Forms,
  MainFormU in 'MainFormU.pas' {MainForm},
  EntitiesU in 'EntitiesU.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
