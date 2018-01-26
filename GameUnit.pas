unit GameUnit;

interface

type
  IBowlingGame = Interface
    ['{6F4E6568-9CEC-4703-A544-1C7ADA4D38F9}']
    // Don't really need number of players,
    // but this gives a clue that you need to add players.
    procedure StartGame;
    function AddPlayer(const Name: String): Integer; // index
    function AddRoll(const PlayerName: String; NoPins: Integer): integer; //frame
    function IsCurrentFrameComplete(const PlayerName: String): Boolean;
    function GetPlayerScore(const PlayerName: String): String;
    function GetAllPlayersScores: String;
  End;

  function BowlingGame: IBowlingGame;

implementation

uses
  Contnrs, Classes, SysUtils, TypInfo;
const
  cCrLf = #$D#$A;
type
    // https://www.thoughtco.com/bowling-scoring-420895
    // totaling not implemented yet
    // read up on scoring there are two bonus rolls on a strike
    // and one bonus roll on a spare.
    // need more states
  TFrameState = (fsFirstRoll, fsSecondRoll, fsBonusRoll, fsSpare, fsStrike, fsOpen);

  TFrame = class
  private
    FState: TFrameState;
    FTotal: Integer;
    // FRoll Each frame contains two rolls
    // Two rolls for a total of ten for a Spare
    // or 10 on the first roll is a Strike
    // in which case the second roll is a StrikeBonus
    //
    // after reading the link above about scoring, i should
    // probably keep track of 4 rolls
    // a spare gets 1 Bonus roll
    // a strike get 2 Bonus rolls 
    FRoll: array[1..2] of Integer;
    procedure UpdateState;
    function IsCurrentFrameComplete: Boolean;
    procedure ValidateNoPinsAdded(PinsToAdd: Integer);
    procedure TotalUpFrame;
    function GetTotal: Integer;
  public
    constructor Create;
    procedure AddRoll(NoPins: Integer);
    function GetScore: String;
    property State: TFrameState read FState;
    property Total: Integer read GetTotal;
    property CurrentFrameCompleted: Boolean read IsCurrentFrameComplete;
  end;

  TFrames = class(TObjectList)
    private
      function GetState(frame: Integer): TFrameState;
      function IsCurrentFrameComplete: Boolean;
    public
      function AddRoll(NoPins: Integer): Integer; // return frame;
      function GetFrameScore(Index: Integer): String;
    property FrameState[frame: Integer]: TFrameState read GetState;
    property CurrentFrameCompleted: Boolean read IsCurrentFrameComplete;
  end;

  TPlayers = class(TStringList)
    public
      procedure Clear; override;
      function AddPlayer(const Name: String): Integer; //return index
      function AddRoll(const Name: String; NoPins: Integer): integer; // return frame
      function IsPlayerCurrentFrameComplete(const Name: String): Boolean;
      function GetPlayerScore(const Name: String): String;
      function GetAllPlayersScore: String;
  end;

  TBowlingGame = Class(TInterfacedObject, IBowlingGame)
    private
      FPlayers: TPlayers;
    public
      procedure StartGame;
      function AddPlayer(const PlayerName: String): Integer; // return index
      function AddRoll(const PlayerName: String; NoPins: Integer): Integer;// return frame;
      function IsCurrentFrameComplete(const PlayerName: String): Boolean;
      function GetPlayerScore(const PlayerName: String): String;
      function GetAllPlayersScores: String;
  end;

  constructor TFrame.Create;
  begin
    inherited;
     FillChar(FRoll,SizeOf(FRoll),0);
  end;

  procedure TFrame.UpdateState;
  begin
    if FState in [fsSpare, fsStrike, fsOpen] then
      exit; // final state.
    case FState of
      fsFirstRoll:
        begin
          if FRoll[1]=10 then
            FState := fsBonusRoll
          else
            FState := fsSecondRoll;
        end;
      fsSecondRoll:
        begin
          if FRoll[1]+FRoll[2]=10 then
            FState := fsSpare
          else
            FState := fsOpen;
        end;
      fsBonusRoll: FState := fsStrike;
    end;
  end;

  function TFrame.IsCurrentFrameComplete: Boolean;
  begin
    result := FState in [fsSpare, fsStrike, fsOpen];
  end;

  procedure TFrame.ValidateNoPinsAdded(PinsToAdd: Integer);
  var
    bOk: Boolean;
  begin
    bOk := (PinsToAdd<=10) AND (PinsToAdd>=0);
    if bOk then

      case FState of
        fsFirstRoll: ;
        fsSecondRoll: bOk := FRoll[1]+PinsToAdd <=10;
        fsBonusRoll: ;
        fsSpare: ;
        fsStrike: ;
        fsOpen: ;
      end;
    if NOT bOk then
      raise Exception.CreateFmt('%d for the number of pins out of range', [PinsToAdd]);
  end;
  // FRoll Each frame contains two rolls
  // Two rolls for a total of ten for a Spare
  // or 10 on the first roll is a Strike
  // in which case the second roll is a StrikeBonus
  procedure TFrame.AddRoll(NoPins: Integer);
  begin
    ValidateNoPinsAdded(NoPins);
    case FState of
      fsFirstRoll: FRoll[1] := NoPins;
      fsSecondRoll: FRoll[2] := NoPins;
      fsSpare: exit;
      fsBonusRoll: FRoll[2] := NoPins;
      fsStrike: exit;
      fsOpen: exit;
    end;
    UpdateState;
  end;

  procedure TFrame.TotalUpFrame;
  begin
    FTotal := -1;
    // not implemented yet
    // read up on scoring there are two bonus rolls on a strike
    // and one bonus roll on a spare.
    // need more states
   raise Exception.Create('Total Up Frame not implemented yet');
  end;

  function TFrame.GetTotal: Integer;
  begin
   // not implemented yet
   result := FTotal;
   raise Exception.Create('GetTotal not implemented yet');
  end;

  function TFrame.GetScore: String;
  begin
    Result := Format('FirstRoll: %d%sSecondRoll: %d%s'+
                      'State: %s%s',
                        [FRoll[1], cCrLf, FRoll[2], cCrLf,
                        GetEnumName(TypeInfo(TFrameState), Ord(FState)), cCrLf]);
  end;

  function TFrames.GetState(frame: Integer): TFrameState;
  begin
    result := (Items[frame] as TFrame).State;
  end;

  function TFrames.GetFrameScore(Index: integer): String;
  begin
    result := (Items[Index] as TFrame).GetScore;
  end;

  function TFrames.IsCurrentFrameComplete: BOolean;
  begin
    result := (Items[Count-1] as TFrame).CurrentFrameCompleted;
  end;

  function TFrames.AddRoll(NoPins: Integer): Integer; // frame
  var
    Frame: TFrame;
  begin
    if Count = 0 then
      Add(TFrame.Create);
    Frame := Items[Pred(Count)] as TFrame;
    if Frame.State in [fsSpare, fsStrike, fsOpen] then
    begin
      Add(TFrame.Create);
      Frame := Items[Pred(Count)] as TFrame;
    end;
    if Frame.State=fsBonusRoll then
    begin
      Frame.AddRoll(NoPins);
      Add(TFrame.Create);
      Frame := Items[Pred(Count)] as TFrame;
    end;
    Frame.AddRoll(NoPins);
    result := Count;
  end;

  procedure TPlayers.Clear;
  var
  t: Integer;
  begin
    for t := 0 to Count - 1 do
      Objects[t].Free;
    inherited clear;
  end;

  function TPlayers.AddPlayer(const Name: String): Integer;
  begin
    if IndexOf(Name) = -1 then
      result := AddObject(Name, TFrames.Create)
    else
      raise Exception.CreateFmt('Player: [%s] already exists in this game.', [Name]);
  end;

  function TPlayers.AddRoll(const Name: String; NoPins: Integer): Integer; //frame
  var
    Frames: TFrames;
  begin
    if IndexOf(Name) = -1 then
      raise Exception.CreateFmt('Player: [%s] does not exist.', [Name]);
    Frames := Objects[IndexOf(Name)] as TFrames;
    result := Frames.AddRoll(NoPins);
  end;

  function TPlayers.GetPlayerScore(const Name: String): String;
  var
    Frames: TFrames;
    t: integer;
  begin
    result := '';
    if IndexOf(Name) = -1 then
      raise Exception.CreateFmt('Player: [%s] does not exist.', [Name]);
    Frames := Objects[IndexOf(Name)] as TFrames;
    for t := 0 to Frames.Count - 1 do
      begin
        result := Format('%sFrame: %d%s%s%s', [result, Succ(t), cCrLf, Frames.GetFrameScore(t), cCrLf]);
      end;
  end;

  function TPlayers.GetAllPlayersScore;
  var
    I: Integer;
  begin
    result := '';
    for I := 0 to Count - 1 do
    begin
      Result := Format('%s%s:%s%s', [result, Strings[i], cCrLf, GetPlayerScore(Strings[i]), cCrLf]);
    end;
  end;

  function TPlayers.IsPlayerCurrentFrameComplete(const Name: string): Boolean;
  begin
    if IndexOf(Name) = -1 then
      raise Exception.CreateFmt('Player: [%s] does not exist.', [Name]);
    result := (Objects[IndexOf(Name)] as TFrames).CurrentFrameCompleted;
  end;

  procedure TBowlingGame.StartGame;
  begin
    if NOT Assigned(FPlayers) then
      FPlayers := TPlayers.Create
    else
      FPlayers.Clear;
  end;

  function TBowlingGame.AddPlayer(const PlayerName: String): Integer;
  begin
    result := FPlayers.AddPlayer(PlayerName);
  end;

  function TBowlingGame.AddRoll(const PlayerName: String; NoPins: Integer): Integer;
  begin
    result := FPlayers.AddRoll(PlayerName, NoPins);
  end;

  function TBowlingGame.IsCurrentFrameComplete(const PlayerName: string): Boolean;
  begin
    result := FPlayers.IsPlayerCurrentFrameComplete(PlayerName);
  end;
  function TBowlingGame.GetPlayerScore(const PlayerName: string): String;
  begin
    result := FPlayers.GetPlayerScore(PlayerName);
  end;

  function TBowlingGame.GetAllPlayersScores: String;
  begin
    result := FPlayers.GetAllPlayersScore;
  end;

  function BowlingGame: IBowlingGame;
  begin
    result := TBowlingGame.Create;
  end;
end.
