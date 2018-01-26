program BowlingScoreProject;

uses
  Forms,
  BowlingScore in 'BowlingScore.pas' {frmBowlingGame},
  GameUnit in 'GameUnit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmBowlingGame, frmBowlingGame);
  Application.Run;
end.
