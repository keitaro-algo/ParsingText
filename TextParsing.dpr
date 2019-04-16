program TextParsing;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {fMain},
  uSettings in 'uSettings.pas' {fSettings},
  uViewFrame in 'uViewFrame.pas' {fViewMain: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfMain, fMain);
  Application.Run;
end.
