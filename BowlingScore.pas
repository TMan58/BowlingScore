unit BowlingScore;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, GameUnit, ExtCtrls;

type
  TfrmBowlingGame = class(TForm)
    Memo1: TMemo;
    Label1: TLabel;
    btnNewGame: TButton;
    gbAddPlayer: TGroupBox;
    edAddPlayer: TLabeledEdit;
    btnAddPlayer: TButton;
    gbScoring: TGroupBox;
    cbxPlayers: TComboBox;
    Label2: TLabel;
    edNoPins: TLabeledEdit;
    btnAddScore: TButton;
    btGetAllStats: TButton;
    cbxRandom: TCheckBox;
    cbxDisplayInSingleLine: TCheckBox;
    cbxDisplayLastTwoFrames: TCheckBox;
    procedure btnNewGameClick(Sender: TObject);
    procedure btnAddPlayerClick(Sender: TObject);
    procedure btnAddScoreClick(Sender: TObject);
    procedure gbAddPlayerExit(Sender: TObject);
    procedure btGetAllStatsClick(Sender: TObject);
    procedure edAddPlayerEnter(Sender: TObject);
    procedure edNoPinsEnter(Sender: TObject);
    procedure cbxRandomClick(Sender: TObject);
  private
    { Private declarations }
    ATSBowlingGame: IBowlingGame;
    procedure AdvancePlayer;
    procedure IsGameOver;
  public
    { Public declarations }
  end;

var
  frmBowlingGame: TfrmBowlingGame;

implementation

{$R *.dfm}

procedure TfrmBowlingGame.btnAddPlayerClick(Sender: TObject);
var
  iIndex: Integer;
begin
  if Length(Trim(edAddPlayer.Text))>0 then
  begin
    cbxDisplayInSingleLine.Enabled := False;
    ATSBowlingGame.AddPlayer(edAddPlayer.Text, cbxDisplayInSingleLine.Checked);
    iIndex := cbxPlayers.Items.Add(edAddPlayer.Text);
    edAddPLayer.Text := '';
    cbxPlayers.ItemIndex := iIndex;
    gbScoring.Enabled := True;
  end;

end;

procedure TfrmBowlingGame.btnAddScoreClick(Sender: TObject);
var
  NoPins: Integer;
  bDone: Boolean;
  iTry: Integer;
begin
  gbAddPlayer.Enabled := False;
  ATSBowlingGame.SetDisplayLastTwoFrames(cbxDisplayLastTwoFrames.Checked);
  if cbxRandom.Checked then
  begin
    bDone := False;
    iTry := 0;
    repeat
    Inc(iTry);
    NoPins := 1+Random(10);
    try
        OutputDebugString(pChar(Format('Tries %d) NoPins: %d', [iTry, NoPins])));
        ATSBowlingGame.AddRoll(cbxPlayers.Text, NoPins);
        edNoPins.Text := '';
        Memo1.Lines.Add(ATSBowlingGame.GetPlayersLastFrameStats(cbxPlayers.ItemIndex));
        bDone := True;
    except
      // do nothing
    end;
    until (iTry = 100) oR bDone;
    if bDone then
    begin
      AdvancePlayer;
      IsGameOver;
      if gbScoring.Enabled then
        FocusControl(edNoPins);
      SendMessage(Memo1.Handle, EM_LINESCROLL, 0,Memo1.Lines.Count);
    end;
  end
  else
  if Length(Trim(edNoPins.Text))>0 then
  begin
    NoPins := StrToIntDef(edNoPins.Text, -1);
    if (NoPins=-1) then
    begin
      edNoPins.Text := 'Number please';
      edNoPins.SelectAll;
    end
    else
    begin
      try
        ATSBowlingGame.AddRoll(cbxPlayers.Text, NoPins);
        edNoPins.Text := '';
        Memo1.Lines.Add(ATSBowlingGame.GetPlayersLastFrameStats(cbxPlayers.ItemIndex));
        //Memo1.Lines.Add(edNoPins.Text);
      finally
        AdvancePlayer;
        IsGameOver;
        if gbScoring.Enabled then
          FocusControl(edNoPins);
        SendMessage(Memo1.Handle, EM_LINESCROLL, 0,Memo1.Lines.Count);
      end;
    end;
  end;
end;

procedure TfrmBowlingGame.btnNewGameClick(Sender: TObject);
begin
   if NOT Assigned(ATSBowlingGame) then
      ATSBowlingGame := BowlingGame;
   ATSBowlingGame.StartGame;
   cbxDisplayInSingleLine.Enabled := True;
   gbAddPlayer.Enabled := True;
   Memo1.Clear;
   edAddPlayer.Text := '';
   edNoPins.Text := '';
   cbxPlayers.Clear;
   btnAddPlayer.Default := true;
   FocusControl(edAddPlayer)
end;

procedure TfrmBowlingGame.cbxRandomClick(Sender: TObject);
var
  hours, mins, secs, milliSecs : Word;
begin
  DecodeTime(now, hours, mins, secs, milliSecs);
  RandSeed := milliSecs;
end;

procedure TfrmBowlingGame.btGetAllStatsClick(Sender: TObject);
begin
  ATSBowlingGame.SetDisplayLastTwoFrames(cbxDisplayLastTwoFrames.Checked);
  Memo1.Lines.Text := ATSBowlingGame.GetAllPlayersStats;
end;

procedure TfrmBowlingGame.edAddPlayerEnter(Sender: TObject);
begin
   btnAddPlayer.Default := true;
   FocusControl(edAddPlayer)
end;

procedure TfrmBowlingGame.edNoPinsEnter(Sender: TObject);
begin
   btnAddPlayer.Default := False;
   btnAddScore.Default := True;
   FocusControl(edNoPins);
end;

procedure TfrmBowlingGame.AdvancePlayer;
begin
  if ATSBowlingGame.IsCurrentFrameComplete(cbxPlayers.Text) then
  begin
    if ((cbxPlayers.ItemIndex + 1) = cbxPlayers.Items.Count) then
      cbxPlayers.ItemIndex := 0
    else
      cbxPlayers.ItemIndex := cbxPlayers.ItemIndex + 1;
  end;
end;

procedure TfrmBowlingGame.IsGameOver;
var
  NoGamesOver: Integer;
  bPlayerGameOver: Boolean;
begin
  if ATSBowlingGame.IsGameOver(cbxPlayers.ItemIndex) then
  begin
    NoGamesOver := 1;
    bPlayerGameOver := false;
    repeat
      if ((cbxPlayers.ItemIndex + 1) = cbxPlayers.Items.Count) then
      begin
        cbxPlayers.ItemIndex := 0;
        NoGamesOver := 0;
      end
      else
        cbxPlayers.ItemIndex := cbxPlayers.ItemIndex + 1;
      bPlayerGameOver := ATSBowlingGame.IsGameOver(cbxPlayers.ItemIndex);
      if bPlayerGameOver then
        Inc(NoGamesOver);
      Application.ProcessMessages;
    until (not bPlayerGameOver) or (NoGamesOver >= (cbxPlayers.Items.Count));
    if NoGamesOver = (cbxPlayers.Items.Count) then
    begin
      edNoPins.Text := 'Game Over';
      Memo1.Lines.Add(edNoPins.Text);
      Memo1.Lines.Add(ATSBowlingGame.GetAllPlayersTotals);
      gbScoring.Enabled := False;
    end;
  end;
end;

procedure TfrmBowlingGame.gbAddPlayerExit(Sender: TObject);
begin
  cbxPlayers.ItemIndex := 0;
  if gbScoring.Enabled then
    FocusControl(edNoPins);
end;

end.
