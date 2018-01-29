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
    Left = 24
    Top = 27
    Width = 385
    Height = 374
    Anchors = [akLeft, akTop, akRight, akBottom]
    Lines.Strings = (
      'Press button "New Game" to start.'
      ''
      'Note: Scoring not completed.'
      'It'#39's not whether you win or lose, it'#39's how you play the game...')
    ScrollBars = ssBoth
    TabOrder = 4
  end
  object btnNewGame: TButton
    Left = 463
    Top = 18
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
    TabOrder = 2
    OnExit = gbAddPlayerExit
    object edAddPlayer: TLabeledEdit
      Left = 11
      Top = 32
      Width = 142
      Height = 21
      EditLabel.Width = 31
      EditLabel.Height = 13
      EditLabel.Caption = '&Name:'
      TabOrder = 0
      OnEnter = edAddPlayerEnter
    end
    object btnAddPlayer: TButton
      Left = 48
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
    TabOrder = 3
    object Label2: TLabel
      Left = 13
      Top = 27
      Width = 30
      Height = 13
      Caption = 'P&layer'
      FocusControl = cbxPlayers
    end
    object cbxPlayers: TComboBox
      Left = 14
      Top = 44
      Width = 142
      Height = 21
      ItemHeight = 13
      TabOrder = 0
    end
    object edNoPins: TLabeledEdit
      Left = 14
      Top = 103
      Width = 142
      Height = 21
      EditLabel.Width = 72
      EditLabel.Height = 13
      EditLabel.Caption = 'Number of &Pins'
      TabOrder = 2
      OnEnter = edNoPinsEnter
    end
    object btnAddScore: TButton
      Left = 48
      Top = 130
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
      OnClick = cbxRandomClick
    end
  end
  object btGetAllStats: TButton
    Left = 463
    Top = 351
    Width = 75
    Height = 25
    Hint = 'Get all the players stats'
    Anchors = [akTop, akRight]
    Caption = 'Get All S&tats'
    TabOrder = 5
    OnClick = btGetAllStatsClick
  end
  object cbxDisplayInSingleLine: TCheckBox
    Left = 426
    Top = 49
    Width = 156
    Height = 17
    Anchors = [akTop, akRight]
    Caption = 'Display frames in single line'
    TabOrder = 1
  end
  object cbxDisplayLastTwoFrames: TCheckBox
    Left = 426
    Top = 382
    Width = 142
    Height = 17
    Hint = 'If Previous frame is a Spare or Strike.'
    Anchors = [akTop, akRight]
    Caption = 'Display last two frames.'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 6
  end
end
