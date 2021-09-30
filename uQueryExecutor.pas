unit uQueryExecutor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.FB, FireDAC.Phys.FBDef, FireDAC.VCLUI.Wait,
  Vcl.StdCtrls, Data.DB, FireDAC.Comp.Client, FireDAC.Phys.IBBase,
  Data.DBXInterBase, Data.SqlExpr, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet, Vcl.Samples.Spin,
  System.Generics.Collections, Vcl.ExtCtrls;

type
  TTipoMensagem = (tmAviso, tmInformacao, tmErro);

  TfrmQueryExecutor = class(TForm)
    gbConexao: TGroupBox;
    lbConexao: TLabel;
    edtConexao: TEdit;
    lblUser: TLabel;
    edtUser: TEdit;
    lbSenha: TLabel;
    edtSenha: TEdit;
    btnTesteConexao: TButton;
    gbQuery: TGroupBox;
    mQuery: TMemo;
    gbParametrosExecucao: TGroupBox;
    lbQuantoRepete: TLabel;
    lbThreads: TLabel;
    btnExecutar: TButton;
    gbOutput: TGroupBox;
    mOutput: TMemo;
    seRepeticoes: TSpinEdit;
    seThreads: TSpinEdit;
    tFinal: TTimer;
    procedure btnTesteConexaoClick(Sender: TObject);
    procedure btnExecutarClick(Sender: TObject);
    procedure tFinalTimer(Sender: TObject);
  private
    procedure CriarThreads;
    procedure Mensagem(ATexto: String; ATipoMensagem: TTipoMensagem = tmAviso);
    function ValidarConexao: Boolean;
    function ValidarExecucao: Boolean;
    function ObterConexao: TFDCustomConnection;
    function ObterQuery(var AFDConnection: TFDCustomConnection): TFDQuery;
  public
    { Public declarations }
  end;

var
  frmQueryExecutor: TfrmQueryExecutor;

implementation

{$R *.dfm}

var
  FFimGeral: TDateTime;
  FTotalThreads: Integer;
  FInicioGeral: TDateTime;
  FContadorThreads: Integer;
  FThreadsFinalizadas: Integer;
  FOutput: TStringList;

function TfrmQueryExecutor.ObterConexao: TFDCustomConnection;
begin
  Result := TFDCustomConnection.Create(nil);
  Result.Params.Values['Database'] := edtConexao.Text;
  Result.Params.Values['User_Name'] := edtUser.Text;
  Result.Params.Values['Password'] := edtSenha.Text;
  Result.Params.Values['DriverID'] := 'FB';
  Result.LoginPrompt := False;
end;

function TfrmQueryExecutor.ObterQuery(var AFDConnection: TFDCustomConnection): TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := AFDConnection;
end;

procedure TfrmQueryExecutor.Mensagem(ATexto: String; ATipoMensagem: TTipoMensagem = tmAviso);
begin
  try
    case (ATipoMensagem) of
      tmAviso: Application.MessageBox(PWideChar(ATexto), 'Query Executor', MB_OK + MB_ICONWARNING);
      tmInformacao: Application.MessageBox(PWideChar(ATexto), 'Query Executor', MB_OK + MB_ICONINFORMATION);
      tmErro: Application.MessageBox(PWideChar(ATexto), 'Query Executor', MB_OK + MB_ICONERROR);
    end;
  except
    on E: Exception do
      raise Exception.Create(E.Message);
  end;
end;

procedure TfrmQueryExecutor.tFinalTimer(Sender: TObject);
begin
  if (FTotalThreads = FThreadsFinalizadas) then
  begin
    tFinal.Enabled := False;
    FOutput.Add('Fim Geral: ' + FormatDateTime('hh:mm:ss', FFimGeral));
    FOutput.Add('=================================');
    FOutput.Add('Tempo Geral: ' + FormatDateTime('hh:mm:ss:ms', FInicioGeral - FFimGeral));
    FOutput.Add('=================================');
    mOutput.Lines.Text := FOutput.Text;
    Mensagem('Finalizou!', tmInformacao);
    FreeAndNil(FOutput);
  end
  else
    mOutput.Lines.Text := FOutput.Text;
end;

procedure TfrmQueryExecutor.btnTesteConexaoClick(Sender: TObject);
var
  LFDConnection: TFDCustomConnection;
begin
  if (not ValidarConexao) then
    Exit;

  LFDConnection := ObterConexao;
  try
    try
      LFDConnection.Connected := True;
      Mensagem('Conectado!', tmInformacao);
      LFDConnection.Connected := False;
    except
      on E: Exception do
        Mensagem('Ocorreu um erro: ' + #13#13 + E.Message, tmErro);
    end;
  finally
    FreeAndNil(LFDConnection);
  end;
end;

function TfrmQueryExecutor.ValidarConexao: Boolean;
begin
  Result := False;

  if (Trim(edtConexao.Text) = '') then
  begin
    Mensagem('Conexão invalida');
    Exit;
  end;

  if (Trim(edtUser.Text) = '') then
  begin
    Mensagem('Usuário invalido');
    Exit;
  end;

  if (Trim(edtSenha.Text) = '') then
  begin
    Mensagem('Senha invalida');
    Exit;
  end;

  Result := True;
end;

function TfrmQueryExecutor.ValidarExecucao: Boolean;
begin
  Result := False;

  if (Trim(mQuery.Lines.Text) = '') then
  begin
    Mensagem('Query invalida');
    Exit;
  end;

  if (seRepeticoes.Value <= 0) then
  begin
    Mensagem('Quantidade de repetições invalida');
    Exit;
  end;

  if (seThreads.Value <= 0) then
  begin
    Mensagem('Quantidade de thread invalida');
    Exit;
  end;

  Result := True;
end;

procedure TfrmQueryExecutor.CriarThreads;
var
  LContador: Integer;
begin
  FContadorThreads := 0;
  FThreadsFinalizadas := 0;
  FTotalThreads := seThreads.Value;
  tFinal.Enabled := True;

  for LContador := 0 to Pred(FTotalThreads) do
  begin
    TThread.CreateAnonymousThread(
      procedure
      var
        LFim: TDateTime;
        LContador: Integer;
        LFDQuery: TFDQuery;
        LInicio: TDateTime;
        LThreadId: Integer;
        LConexao: TFDCustomConnection;
      begin
        Inc(FContadorThreads);
        LThreadId := FContadorThreads;
        try
          LConexao := ObterConexao;
          try
            for LContador := 0 to Pred(seRepeticoes.Value) do
            begin
              try
                LFDQuery := ObterQuery(LConexao);
                try
                  LFDQuery.Close;
                  LFDQuery.SQL.Clear;
                  LFDQuery.SQL.Text := mQuery.Lines.Text;

                  LInicio := Now();
                  LFDQuery.Open;
                  LFim := Now();

                  FOutput.Add(IntToStr(LThreadId) + '/' + IntToStr(LContador + 1) + ': ' + FormatDateTime('ss:ms', LInicio - LFim));
                finally
                  if (LConexao.Connected) then
                    LConexao.Connected := False;
                  FreeAndNil(LFDQuery);
                end;
              except
                on E: Exception do
                  FOutput.Add(IntToStr(LThreadId) + '/' + IntToStr(LContador + 1) + ' - Erro: ' + E.Message);
              end;
            end;
          finally
            FreeAndNil(LConexao);
            FFimGeral := Now();
            Inc(FThreadsFinalizadas);
          end;
        except
          on E: Exception do
          begin
            Inc(FThreadsFinalizadas);
            FOutput.Add(IntToStr(LThreadId) + ' - Erro: ' + E.Message);
          end;
        end;
      end).Start;
  end;
end;

procedure TfrmQueryExecutor.btnExecutarClick(Sender: TObject);
begin
  if (not ValidarConexao) then
    Exit;

  if (not ValidarExecucao) then
    Exit;

  FOutput := TStringList.Create;
  FOutput.Clear;
  FInicioGeral := Now();
  FOutput.Add('=================================');
  FOutput.Add('Inicio Geral: ' + FormatDateTime('hh:mm:ss', FInicioGeral));
  FOutput.Add('=================================');
  CriarThreads;
end;

end.
