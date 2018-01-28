object frmBowlingGame: TfrmBowlingGame
  Left = 0
  Top = 0
  Caption = 'Andy Bowling'
  ClientHeight = 419
  ClientWidth = 590
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    590
    419)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 24
    Top = 8
    Width = 55
    Height = 13
    Caption = 'Score &card:'
    FocusControl = Memo1
  end
  object Memo1: TMemo
    Left = 33
    Top = 27
    Width = 376
    Height = 374
    Anchors = [akLeft, akTop, akRight, akBottom]
    Lines.Strings = (
      'Press button "New Game" to start.'
      ''
      'Note: Scoring not completed.'
      'It'#39's not whether you win or lose, it'#39's how you play the game...')
    ScrollBars = ssBoth
    TabOrder = 3
  end
  object btnNewGame: TButton
    Left = 462
    Top = 41
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'New &Game'
    TabOrder = 0
    OnClick = btnNewGameClick
  end
  object gbAddPlayer: TGroupBox
    Left = 415
    Top = 72
    Width = 167
    Height = 97
    Anchors = [akTop, akRight]
    Caption = 'Add Player:'
    Enabled = False
    TabOrder = 1
    OnExit = gbAddPlayerExit
    object edAddPlayer: TLabeledEdit
      Left = 11
      Top = 32
      Width = 132
      Height = 21
      EditLabel.Width = 31
      EditLabel.Height = 13
      EditLabel.Caption = '&Name:'
      TabOrder = 0
      OnEnter = edAddPlayerEnter
    end
    object btnAddPlayer: TButton
      Left = 38
      Top = 59
      Width = 75
      Height = 25
      Caption = '&Add'
      TabOrder = 1
      OnClick = btnAddPlayerClick
    end
  end
  object gbScoring: TGroupBox
    Left = 415
    Top = 175
    Width = 167
    Height = 170
    Anchors = [akTop, akRight]
    Caption = 'Scoring:'
    Enabled = False
    TabOrder = 2
    object Label2: TLabel
      Left = 13
      Top = 27
      Width = 30
      Height = 13
      Caption = 'P&layer'
      FocusControl = cbxPlayers
    end
    object cbxPlayers: TComboBox
      Left = 11
      Top = 44
      Width = 132
      Height = 21
      ItemHeight = 13
      TabOrder = 0
    end
    object edNoPins: TLabeledEdit
      Left = 11
      Top = 103
      Width = 132
      Height = 21
      EditLabel.Width = 72
      EditLabel.Height = 13
      EditLabel.Caption = 'Number of &Pins'
      TabOrder = 2
      OnEnter = edNoPinsEnter
    end
    object btnAddScore: TButton
      Left = 40
      Top = 136
      Width = 75
      Height = 25
      Caption = 'Add &Score'
      Default = True
      TabOrder = 3
      OnClick = btnAddScoreClick
    end
    object cbxRandom: TCheckBox
      Left = 99
      Top = 71
      Width = 65
      Height = 26
      Caption = '&Random'
      TabOrder = 1
    end
  end
  object btGetAllStats: TButton
    Left = 455
    Top = 360
    Width = 75
    Height = 25
    Hint = 'Get all the players stats'
    Anchors = [akTop, akRight]
    Caption = 'Get All S&tats'
    TabOrder = 4
    OnClick = btGetAllStatsClick
  end
end
