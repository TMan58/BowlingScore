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
    procedure btnNewGameClick(Sender: TObject);
    procedure btnAddPlayerClick(Sender: TObject);
    procedure btnAddScoreClick(Sender: TObject);
    procedure gbAddPlayerExit(Sender: TObject);
  private
    { Private declarations }
    ATSBowlingGame: IBowlingGame;
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
    ATSBowlingGame.AddPlayer(edAddPlayer.Text);
    iIndex := cbxPlayers.Items.Add(edAddPlayer.Text);
    edAddPLayer.Text := '';
    cbxPlayers.ItemIndex := iIndex;
    gbScoring.Enabled := True;
  end;

end;

procedure TfrmBowlingGame.btnAddScoreClick(Sender: TObject);
var
  NoPins: Integer;
begin
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
        Memo1.Clear;
        Memo1.Lines.Text := ATSBowlingGame.GetAllPlayersScores;
      finally
        if ATSBowlingGame.IsCurrentFrameComplete(cbxPlayers.Text) then
        begin
          if ((cbxPlayers.ItemIndex+1) = cbxPlayers.Items.Count) then
            cbxPlayers.ItemIndex := 0
          else
            cbxPlayers.ItemIndex := cbxPlayers.ItemIndex+1;
        end;
        SendMessage(Memo1.Handle, EM_LINESCROLL, 0,Memo1.Lines.Count);
        FocusControl(edNoPins);
      end;
    end;
  end;
end;

procedure TfrmBowlingGame.btnNewGameClick(Sender: TObject);
begin
   if NOT Assigned(ATSBowlingGame) then
      ATSBowlingGame := BowlingGame;
   ATSBowlingGame.StartGame;
   gbAddPlayer.Enabled := True;
   Memo1.Clear;
   edAddPlayer.Text := '';
   edNoPins.Text := '';
   cbxPlayers.Clear;
   FocusControl(edAddPlayer)
end;

procedure TfrmBowlingGame.gbAddPlayerExit(Sender: TObject);
begin
  cbxPlayers.ItemIndex := 0;
  FocusControl(edNoPins);
end;

end.
