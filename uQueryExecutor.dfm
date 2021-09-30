object frmQueryExecutor: TfrmQueryExecutor
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Query Executor'
  ClientHeight = 761
  ClientWidth = 703
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object gbConexao: TGroupBox
    Left = 0
    Top = 0
    Width = 703
    Height = 89
    Align = alTop
    Caption = ' Parametros de conex'#227'o '
    TabOrder = 0
    ExplicitWidth = 693
    object lbConexao: TLabel
      Left = 11
      Top = 24
      Width = 47
      Height = 13
      Caption = 'Conex'#227'o:'
    end
    object lblUser: TLabel
      Left = 18
      Top = 55
      Width = 40
      Height = 13
      Caption = 'Usu'#225'rio:'
    end
    object lbSenha: TLabel
      Left = 181
      Top = 55
      Width = 34
      Height = 13
      Caption = 'Senha:'
    end
    object edtConexao: TEdit
      Left = 64
      Top = 21
      Width = 273
      Height = 21
      TabOrder = 0
    end
    object edtUser: TEdit
      Left = 64
      Top = 52
      Width = 100
      Height = 21
      TabOrder = 1
      Text = 'sysdba'
    end
    object edtSenha: TEdit
      Left = 227
      Top = 52
      Width = 110
      Height = 21
      TabOrder = 2
      Text = 'masterkey'
    end
    object btnTesteConexao: TButton
      Left = 343
      Top = 50
      Width = 115
      Height = 25
      Caption = 'Testar Conex'#227'o'
      TabOrder = 3
      OnClick = btnTesteConexaoClick
    end
  end
  object gbQuery: TGroupBox
    Left = 0
    Top = 89
    Width = 703
    Height = 272
    Align = alTop
    Caption = 'Query'
    TabOrder = 1
    ExplicitWidth = 693
    object mQuery: TMemo
      Left = 2
      Top = 15
      Width = 699
      Height = 255
      Align = alClient
      ScrollBars = ssVertical
      TabOrder = 0
      ExplicitWidth = 689
    end
  end
  object gbParametrosExecucao: TGroupBox
    Left = 0
    Top = 361
    Width = 703
    Height = 80
    Align = alTop
    Caption = ' Parametros execu'#231#227'o '
    TabOrder = 2
    ExplicitWidth = 693
    object lbQuantoRepete: TLabel
      Left = 11
      Top = 26
      Width = 119
      Height = 13
      Caption = 'Quantidade  Repeti'#231#245'es:'
    end
    object lbThreads: TLabel
      Left = 142
      Top = 26
      Width = 113
      Height = 13
      Caption = 'Quantidade de Threads'
    end
    object btnExecutar: TButton
      Left = 261
      Top = 43
      Width = 115
      Height = 25
      HelpType = htKeyword
      Caption = 'Executar'
      TabOrder = 2
      OnClick = btnExecutarClick
    end
    object seRepeticoes: TSpinEdit
      Left = 11
      Top = 45
      Width = 119
      Height = 22
      MaxValue = 9999
      MinValue = 1
      TabOrder = 0
      Value = 0
    end
    object seThreads: TSpinEdit
      Left = 142
      Top = 45
      Width = 113
      Height = 22
      MaxValue = 9999
      MinValue = 1
      TabOrder = 1
      Value = 0
    end
  end
  object gbOutput: TGroupBox
    Left = 0
    Top = 441
    Width = 703
    Height = 320
    Align = alClient
    Caption = ' Output '
    TabOrder = 3
    ExplicitLeft = 208
    ExplicitTop = 560
    ExplicitWidth = 185
    ExplicitHeight = 105
    object mOutput: TMemo
      Left = 2
      Top = 15
      Width = 699
      Height = 303
      Align = alClient
      ScrollBars = ssVertical
      TabOrder = 0
      ExplicitWidth = 689
      ExplicitHeight = 293
    end
  end
  object tFinal: TTimer
    Enabled = False
    OnTimer = tFinalTimer
    Left = 528
    Top = 27
  end
end
