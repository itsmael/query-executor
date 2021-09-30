program QueryExecutor;

uses
  Vcl.Forms,
  uQueryExecutor in 'uQueryExecutor.pas' {frmQueryExecutor};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmQueryExecutor, frmQueryExecutor);
  Application.Run;
end.
