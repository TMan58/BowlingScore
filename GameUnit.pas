unit GameUnit;

    // And explanation of scoring that I can understand

    // https://www.thoughtco.com/bowling-scoring-420895

interface

type
  IBowlingGame = Interface
    ['{6F4E6568-9CEC-4703-A544-1C7ADA4D38F9}']
    procedure StartGame;
    function AddPlayer(const Name: String; DisplayInSingleLine: Boolean): Integer; // index
    function AddRoll(const PlayerName: String; NoPins: Integer): integer; //frame
    function IsCurrentFrameComplete(const PlayerName: String): Boolean;
    function IsGameOver(Index: Integer): Boolean;
    function GetPlayerStats(const PlayerName: String): String;
    // function GetPlayersLastStats(NoFrames, PlayerNo: Integer): String;
    function GetPlayersLastFrameStats(Index: Integer): String;
    //function GetAllPlayersLastFrameOnly: String;
    function GetAllPlayersStats: String;
    function GetAllPlayersTotals: String;
    procedure SetDisplayLastTwoFrames(Value: Boolean);
  End;

  function BowlingGame: IBowlingGame;

implementation

uses
  Contnrs, Classes, SysUtils, TypInfo, Windows;
type

  // fsDoubleStrikeBonusRoll = two strikes in a row
  TGameState = (fsFirstRoll, fsSecondRoll, fsOpen, fsSpareBonusRoll, fsSpare,
                   fsStrikeBonusFirstRoll, fsStrikeBonusSecondRoll, fsStrike,
                   fsGameOver, fsDoubleStrikeBonusRoll,
                   fsSpareBonusRollFrame10, fsStrikeBonusFirstRollFrame10,
                   fsStrikeBonusSecondRollFrame10, fsDoubleStrikeBonusRollFrame10);

  //TFrameState = fsFirstRoll..fsStrike+fsGameOver;
  TFrameState = fsFirstRoll..fsGameOver;
  TRoll = (trFirst=1, trSecond);

const
  cCrLf = #$D#$A;
  cMaxFrames = 10; // Frames collection starts at "0"
  cDisplayLastTwoFrames = false; // should NOT of brought these out to the UI, but oh well ;-(
  cDisplayInLine = true; // displays stats in a single line.. Same here with UI ;-(
  cShowLastTwoFrameState = ([fsSpareBonusRoll, fsSpare,
                   fsStrikeBonusFirstRoll, fsStrikeBonusSecondRoll, fsStrike,
                   fsDoubleStrikeBonusRoll,
                   fsSpareBonusRollFrame10, fsStrikeBonusFirstRollFrame10,
                   fsStrikeBonusSecondRollFrame10]);


type
  TFrame = class
  private
    FState: TFrameState;
    FFrameTotal: Integer;
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
    FBonusRoll: array[1..2] of Integer;
    function GetRoll(Roll: TRoll): Integer;
    procedure SetState(AState: TFrameState);
    function GetState: TFrameState;
    function IsCurrentFrameComplete: Boolean;
    function IsFinalFrameComplete: Boolean;
    procedure TotalUpFrame;
    function GetFrameTotal: Integer;
  public
    FDisplayInLine: Boolean; // ;-(
    constructor Create(DisplayInLine: Boolean);
    procedure AddRoll(AState: TFrameState; NoPins: Integer);
    function GetScore: String;
    property Roll[Roll: TRoll]: Integer read GetRoll;
    property State: TFrameState read GetState write SetState;
    property FrameTotal: Integer read GetFrameTotal;
    property FinalFrameCompleted: Boolean read IsFinalFrameComplete;
    property CurrentFrameCompleted: Boolean read IsCurrentFrameComplete;
  end;

  TFrames = class(TObjectList)
    private
      FGameState: TGameState;
      FDisplayInLine: Boolean;
      function GetFrameState(Index: Integer): TFrameState;
      //function GetFrameStateStr(Index: Integer): String;
      procedure UpdateState;
      function IsCurrentFrameComplete: Boolean;
      function IsGameOver: Boolean;
      function GetLast(NoFrames: Integer): String;
    public
      constructor Create(DisplayInSingleLine: Boolean);
      function AddRoll(NoPins: Integer): Integer; // return frame;
      function GetGameState: String;
      function GetFrameStats(Index: Integer): String;
      function GetFrameTotal(Index: Integer): Integer;
      function GetGameTotal: Integer;
      function GetLastTwoFrames: String;
      function GetLastFrame: String;
      function GetAllFrameStats: String;
    property FrameState[frame: Integer]: TFrameState read GetFrameState;
    property CurrentFrameCompleted: Boolean read IsCurrentFrameComplete;
    property GameOver: Boolean read IsGameOver;
  end;

  TPlayers = class(TStringList)
    private
      FDisplayLastTwoFrames: Boolean;
//      function GetPlayersLast(NoFrames, PlayerNo: Integer): String;
    public
      procedure Clear; override;
      function AddPlayer(const Name: String; DisplayInSingleLine: Boolean): Integer; //return index
      function AddRoll(const Name: String; NoPins: Integer): integer; // return frame
      function IsPlayerCurrentFrameComplete(const Name: String): Boolean;
      function IsGameOver(Index: Integer): Boolean;
      function GetPlayerTotals(const Name: String): String;
      function GetPlayerStats(const Name: String): String;
      function GetPlayersLastFrameStats(Index: Integer): String; overload;
      function GetPlayersLastFrameStats(const Name: String): String; overload;
      //function GetAllPlayersLastFrameOnly: String;
      function GetAllPlayersStats: String;
      function GetAllPlayersTotals: String;
    property DisplayLastTwoFrames: Boolean read FDisplayLastTwoFrames write FDisplayLastTwoFrames;
  end;

  TBowlingGame = Class(TInterfacedObject, IBowlingGame)
    private
      FPlayers: TPlayers;
    public
      procedure StartGame;
      procedure SetDisplayLastTwoFrames(Value: Boolean);
      function AddPlayer(const PlayerName: String; DisplayInSingleLine: BOolean): Integer; // return index
      function AddRoll(const PlayerName: String; NoPins: Integer): Integer;// return frame;
      function IsCurrentFrameComplete(const PlayerName: String): Boolean;
      function IsGameOver(Index: Integer): Boolean;
      function GetPlayerStats(const PlayerName: String): String;
      //function GetPlayersLastStats(NoFrames, PlayerNo: Integer): String;
      function GetPlayersLastFrameStats(Index: Integer): String;
      //function GetAllPlayersLastFrameOnly: String;
      function GetAllPlayersStats: String;
      function GetAllPlayersTotals: String;
  end;

  procedure DebugStr(const S: String);
  begin
    OutputDebugString(pChar(S));
  end;

  constructor TFrame.Create(DisplayInLine: Boolean);
  begin
    inherited Create;
    FDisplayInLine := DisplayInLine;
    FillChar(FRoll,SizeOf(FRoll),0);
    FillChar(FBonusRoll, SizeOf(FBonusRoll), 0);
  end;

  function TFrame.GetRoll(Roll: TRoll): Integer;
  begin
    result := FRoll[Ord(Roll)];
  end;

  Procedure TFrame.SetState(AState: TFrameState);
  begin
    FState := AState;
  end;

  function TFrame.GetState: TFrameState;
  begin
    result := FState;
  end;

  function TFrame.IsFinalFrameComplete: Boolean;
  begin
    result := FState in [fsSpare, fsStrike, fsOpen];
    // result := FState in [fsSpareBonusRoll, fsSpare, fsStrikeBonusFirstRoll, fsStrike, fsOpen];
  end;

  function TFrame.IsCurrentFrameComplete: Boolean;
  begin
    // result := FState in [fsSpare, fsStrike, fsOpen];
    result := FState in [fsSpareBonusRoll, fsSpare, fsStrikeBonusFirstRoll, fsStrike, fsOpen];
  end;

  // FRoll Each frame contains two rolls
  // Two rolls for a total of ten for a Spare
  // or 10 on the first roll is a Strike
  // in which case the second roll is a StrikeBonus
  procedure TFrame.AddRoll(AState: TFrameState; NoPins: Integer);
  begin
    case AState of
      fsFirstRoll: FRoll[1] := NoPins;
      fsSecondRoll: FRoll[2] := NoPins;
      fsOpen: ;
      fsSpare: ;
      fsSpareBonusRoll: FBonusRoll[1] := NoPins;
      fsStrike: ;
      fsStrikeBonusFirstRoll: FBonusRoll[1] := NoPins;
      fsStrikeBonusSecondRoll: FBonusRoll[2] := NoPins;
    end;
    TotalUpFrame;
  end;

  procedure TFrame.TotalUpFrame;
  begin
    FFrameTotal := FRoll[1]+FRoll[2]+FBonusROll[1]+FBonusRoll[2];
  end;

  function TFrame.GetFrameTotal: Integer;
  begin
   result := FFrameTotal;
  end;

  function TFrame.GetScore: String;
  begin
    if FDisplayInLine then
      result := Format('FirstRoll: %2d SecondRoll: %2d '+
                        'BonusRoll 1: %2d BonusRoll 2: %2d '+
                        'FrameTotal: %3d '+
                        'State: %s',
                          [FRoll[1], FRoll[2],
                          FBonusRoll[1], FBonusRoll[2],
                          FFrameTotal,
                          GetEnumName(TypeInfo(TFrameState), Ord(FState))])
  else
    result := Format('FirstRoll: %d%sSecondRoll: %d%s'+
                      'BonusRoll 1: %d%sBonusRoll 2: %d%s'+
                      'FrameTotal: %d%s'+
                      'State: %s%s',
                        [FRoll[1], cCrLf, FRoll[2], cCrLf,
                        FBonusRoll[1], cCrLf, FBonusRoll[2], cCrLf,
                        FFrameTotal, cCrLf,
                        GetEnumName(TypeInfo(TFrameState), Ord(FState)), cCrLf]);

  end;

  constructor TFrames.Create(DisplayInSingleLine: Boolean);
  begin
    inherited;
    FDisplayInLine := DisplayInSingleLine;
  end;
  function TFrames.GetGameState: String;
  begin
    result := GetEnumName(TypeInfo(TGameState), Ord(FGameState));
  end;

  function TFrames.GetFrameState(Index: Integer): TFrameState;
  begin
    result := (Items[Index] as TFrame).State;
  end;

//  function TFrames.GetFrameStateStr(Index: Integer): String;
//  begin
//    result := GetEnumName(TypeInfo(TFrameState), Ord(GetFrameState(Index)));
//  end;

  function TFrames.GetFrameStats(Index: integer): String;
  begin
    result := (Items[Index] as TFrame).GetScore;
  end;

  function TFrames.GetFrameTotal(Index: Integer): Integer;
  begin
    result := (Items[Index] as TFrame).GetFrameTotal;
  end;

  function TFrames.GetGameTotal: Integer;
  var
    t, TotalScore: Integer;
  begin
    TotalScore := 0;
    result := 0;
    for t := 0 to Count - 1 do
      TotalScore := TotalScore + GetFrameTotal(t);
    result := TotalScore;
  end;

  function TFrames.GetLastTwoFrames: String;
  var
    iShowFrames: Integer;
  begin
    iShowFrames := 1;
    if (Count > 1) AND (GetFrameState(Count-2) in cShowLastTwoFrameState) then
      iShowFrames := 2;
    result := GetLast(iShowFrames);
  end;

  function TFrames.GetLast(NoFrames: Integer): String;
  var
    t: integer;
    TotalScore: Integer;
  begin
    TotalScore := 0;
    result := '';
    for t := 0 to Count - 1 do
    begin
      if (t < (Count-NoFrames)) then
        continue;
      if FDisplayInLine then
        result := Format('%sFrame: %2d %s ',
                      [result, //  GetGameState, cCrLf,
                        Succ(t),
                        GetFrameStats(t)])
      else
        result := Format('%sFrame: %d%s%s',
                    [result, //  GetGameState, cCrLf,
                      Succ(t), cCrLf,
                      GetFrameStats(t)]);
      TotalScore := TotalScore+GetFrameTotal(t);
      result := Format('%sTotal score: %d%s%s', [result, TotalScore,
                            cCrLf, cCrLf]);
    end;
  end;

  function TFrames.GetAllFrameStats: String;
  var
    t: integer;
    TotalScore: Integer;
  begin
    TotalScore := 0;
    result := '';
    for t := 0 to Count - 1 do
      begin
        if FDisplayInLine then
          result := Format('%sFrame: %2d %s ',
                        [result, //  GetGameState, cCrLf,
                          Succ(t),
                          GetFrameStats(t)])
        else
          result := Format('%sFrame: %d%s%s',
                      [result, //  GetGameState, cCrLf,
                        Succ(t), cCrLf,
                        GetFrameStats(t)]);
        TotalScore := TotalScore+GetFrameTotal(t);
        result := Format('%sTotal score: %d%s%s', [result, TotalScore,
                              cCrLf, cCrLf]);
      end;
  end;

  function TFrames.GetLastFrame: String;
  var
    t: integer;
    TotalScore: Integer;
  begin
    TotalScore := 0;
    result := '';
    for t := 0 to Count - 1 do
      begin
        TotalScore := TotalScore+GetFrameTotal(t);
        if t=Pred(Count) then
        begin
          result := Format('%sFrame: %2d%s%s',
                        [result,  //  GetGameState, cCrLf,
                          Succ(t), cCrLf,
                          GetFrameStats(t)]);
          result := Format('%sTotal score: %d%s', [result, TotalScore,
                                cCrLf]);
        end
      end;
  end;

  function TFrames.IsCurrentFrameComplete: BOolean;
  begin
    if (Count<cMaxFrames) then
      result := (Items[Count-1] as TFrame).CurrentFrameCompleted
    else
      result := (Items[Count-1] as TFrame).FinalFrameCompleted
  end;

  function TFrames.IsGameOver: Boolean;
  var
    State: TFrameState;
    bOk, bInState: boolean;
  begin
     result := false;
     if Count=0 then
      exit;
     bOk := Count = cMaxFrames;
     State := (Items[Count-1] as TFrame).GetState;
     bInState := State in [fsOpen, fsSpare,
              fsStrike];
     result := bOk AND bInState;
    DebugStr(Format('CurrentFrameComplete: %s', [BoolToStr(result)]));
  end;

  function TFrames.AddRoll(NoPins: Integer): Integer; // frame
  var
    Frame: TFrame;
  begin
    result := -1;
    if (Count = 0) OR ((Count<cMaxFrames) AND (FGameState in [fsOpen, fsSpareBonusRoll, fsStrikeBonusFirstRoll, fsDoubleStrikeBonusRoll])) then
    begin
      if (Count=0) OR (FGameState=fsOpen) then
        FGameState := fsFirstRoll;
      Add(TFrame.Create(FDisplayInLine));
    end;
    Frame := Items[Pred(Count)] as TFrame;
    if ((NoPins>10) OR (NoPins<0))
      OR ((Frame.State=fsSecondRoll) AND (Frame.Roll[trFirst]+NoPins >10)) then
        raise Exception.CreateFmt('%d for the number of pins out of range', [NoPins]);
    case FGameState of
      fsFirstRoll, fsSecondRoll:
          begin
            Frame.AddRoll(FGameState, NoPins);
          end;
      fsSpareBonusRoll:
          begin
            Frame.AddRoll(fsFirstRoll, NoPins);
            Frame := Items[Count-2] as TFrame;
            Frame.AddRoll(fsSpareBonusRoll, NoPins);
          end;
      fsStrikeBonusFirstRoll:
          begin
            Frame.AddRoll(fsFirstRoll, NoPins);
            Frame := Items[Count-2] as TFrame;
            Frame.AddRoll(fsStrikeBonusFirstRoll, NoPins);
          end;
      fsStrikeBonusSecondRoll:
        begin
          Frame.AddRoll(fsSecondRoll, NoPins);
          Frame := Items[Count-2] as TFrame;
          Frame.AddRoll(FGameState, NoPins);
        end;
      // two strikes in a row
      fsDoubleStrikeBonusRoll:
        begin
          Frame.AddRoll(fsFirstRoll, NoPins);
          (Items[Count-2] as TFrame).AddRoll(fsStrikeBonusFirstRoll, NoPins);
          (Items[Count-3] as TFrame).AddRoll(fsStrikeBonusSecondRoll, NoPins);
        end;
			fsSpareBonusRollFrame10:  Frame.AddRoll(fsSpareBonusRoll, NoPins);
      fsStrikeBonusFirstRollFrame10: Frame.AddRoll(fsStrikeBonusFirstRoll, NoPins);
      fsStrikeBonusSecondRollFrame10: Frame.AddRoll(fsStrikeBonusSecondRoll, NoPins);
      fsDoubleStrikeBonusRollFrame10:
      begin
          Frame.AddRoll(fsStrikeBonusFirstRoll, NoPins);
          (Items[Count-2] as TFrame).AddRoll(fsStrikeBonusSecondRoll, NoPins);
//          (Items[Count-3] as TFrame).AddRoll(fsStrikeBonusSecondRoll, NoPins);
      end;
    end;
    UpdateState;

    result := Count;
  end;

  procedure TFrames.UpdateState;
  var
    Frame: TFrame;
  begin
    Frame := (Items[Count-1] as TFrame);
    case FGameState of
      fsFirstRoll:
        begin
          if Frame.Roll[trFirst]=10 then
            FGameState := fsStrikeBonusFirstRoll
          else
            FGameState := fsSecondRoll;
          Frame.State := FGameState;
        end;
      fsSecondRoll:
        begin
          if Frame.Roll[trFirst]+Frame.Roll[trSecond]=10 then
            FGameState := fsSpareBonusRoll
          else
            FGameState := fsOpen;
          Frame.State := FGameState;
        end;
      fsSpareBonusRoll:
        begin
          if Frame.Roll[trFirst]=10 then
            FGameState := fsStrikeBonusFirstRoll
          else
            FGameState := fsSecondRoll;
          Frame.State := FGameState;
          (Items[Count-2] as TFrame).State := fsSpare;
        end;
      fsStrikeBonusFirstRoll:
        begin
          if Frame.Roll[trFirst]=10 then
          begin
            Frame.State := fsStrikeBonusFirstRoll;
            FGameState := fsDoubleStrikeBonusRoll;
          end
          else
          begin
            FGameState := fsStrikeBonusSecondRoll;
            Frame.State := fsSecondRoll;
          end;
          (Items[Count-2] as TFrame).State := fsStrikeBonusSecondRoll;
        end;
      fsStrikeBonusSecondRoll:
        begin
          if Frame.Roll[trFirst]+Frame.Roll[trSecond]=10 then
            FGameState := fsSpareBonusRoll
          else
            FGameState := fsOpen;
          Frame.State := FGameState;
          (Items[Count-2] as TFrame).State := fsStrike;
        end;
      fsDoubleStrikeBonusRoll:
        begin
          if Frame.Roll[trFirst]=10 then
          begin
            Frame.State := fsStrikeBonusFirstRoll;
            FGameState := fsDoubleStrikeBonusRoll
          end
          else
          begin
            FGameState := fsStrikeBonusSecondRoll;
            Frame.State := fsSecondRoll;
          end;
          (Items[Count-2] as TFrame).State := fsStrikeBonusSecondRoll;
          (Items[Count-3] as TFrame).State := fsStrike;
        end;
    end;

    // tenth frame fix up
    if Count=10 then
    begin
			case FGameState of
				fsSpareBonusRoll: FGameState := fsSpareBonusRollFrame10;
        fsSpareBonusRollFrame10:
        begin
          FGameState := fsSpare;
          Frame.State := fsSpare;
        end;
				fsStrikeBonusFirstRoll:
          begin
            FGameState := fsStrikeBonusFirstRollFrame10;
            Frame.State := fsStrikeBonusFirstRoll;
          end;
        fsDoubleStrikeBonusRoll:
        begin
          FGameState := fsDoubleStrikeBonusRollFrame10
        end;
				fsStrikeBonusFirstRollFrame10:
          begin
            FGameState := fsStrikeBonusSecondRollFrame10;
            Frame.State := fsStrikeBonusSecondRoll;
          end;
        fsStrikeBonusSecondRollFrame10:
        begin
          FGameState := fsStrike;
          Frame.State := FGameState;
        end;
        fsDoubleStrikeBonusRollFrame10:
        begin
           Frame.State := fsStrikeBonusSecondRoll;
           FGameState := fsStrikeBonusSecondRollFrame10;
          (Items[Count-2] as TFrame).State := fsStrike;
        end;

//				fsStrikeBonusFirstRoll: FGameState := fsStrikeBonusFirstRollFrame10;
//				fsStrikeBonusFirstRollFrame10: FGameState := fsStrikeBonusSecondRollFrame10;
//        fsStrikeBonusSecondRollFrame10:
//        begin
//          FGameState := fsStrike;
//          Frame.State := FGameState;
//        end;
      end;
    end;
  end;

  procedure TPlayers.Clear;
  var
  t: Integer;
  begin
    for t := 0 to Count - 1 do
      Objects[t].Free;
    inherited clear;
  end;

  function TPlayers.AddPlayer(const Name: String; DisplayInSingleLine: Boolean): Integer;
  begin
    if IndexOf(Name) = -1 then
      result := AddObject(Name, TFrames.Create(DisplayInSingleLine))
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

  function TPlayers.GetPlayerTotals(const Name: String): String;
  var
    Frames: TFrames;
    GameTotal: Integer;
  begin
    if IndexOf(Name) = -1 then
      raise Exception.CreateFmt('Player: [%s] does not exist.', [Name]);
    Frames := Objects[IndexOf(Name)] as TFrames;
    GameTotal := Frames.GetGameTotal;
    result := IntToStr(GameTotal);
  end;

  function TPlayers.GetPlayerStats(const Name: String): String;
  var
    Frames: TFrames;
  begin
    if IndexOf(Name) = -1 then
      raise Exception.CreateFmt('Player: [%s] does not exist.', [Name]);
    Frames := Objects[IndexOf(Name)] as TFrames;
    result := Frames.GetAllFrameStats;
  end;

  function TPlayers.IsGameOver(Index: Integer): Boolean;
  var
    Name: String;
  begin
    Name := Strings[Index];
    if IndexOf(Name) = -1 then
      raise Exception.CreateFmt('Player: [%s] does not exist.', [Name]);
    result := (Objects[IndexOf(Name)] as TFrames).GameOver;
  end;

//  function TPlayers.GetPlayersLast(NoFrames, PlayerNo: Integer): String;
//  var
//    Frames: TFrames;
//    Name: String;
//  begin
//    Name :=  Strings[PlayerNo];
//    if IndexOf(Name) = -1 then
//      raise Exception.CreateFmt('Player: [%s] does not exist.', [Name]);
//    Frames := Objects[IndexOf(Name)] as TFrames;
//    result := Format('%s%s%s', [Name, cCrLf, Frames.GetLastFrame])
//  end;

  function TPlayers.GetPlayersLastFrameStats(Index: Integer): String;
  var
//    Frames: TFrames;
    Name: String;
  begin
    Name :=  Strings[Index];
    result := GetPlayersLastFrameStats(Name);
//    if IndexOf(Name) = -1 then
//      raise Exception.CreateFmt('Player: [%s] does not exist.', [Name]);
//    Frames := Objects[IndexOf(Name)] as TFrames;
//    result := Format('%s%s%s', [Name, cCrLf, Frames.GetLastFrame])
  end;

  function TPlayers.GetPlayersLastFrameStats(const Name: String): String;
  var
    Frames: TFrames;
  begin
    result := '';
    if IndexOf(Name) = -1 then
      raise Exception.CreateFmt('Player: [%s] does not exist.', [Name]);
    Frames := Objects[IndexOf(Name)] as TFrames;
    if NOT cDisplayLastTwoFrames then
      result := Format('%s%sGame State: %s%s%s', [Name, cCrLf, Frames.GetGameState, cCrLf, Frames.GetLastFrame])
    else
      result := Format('%s%s%s%s%s', [Name, cCrLf, Frames.GetGameState, cCrLf, Frames.GetLastTwoFrames])
  end;

  function TPlayers.GetAllPlayersStats: String;
  var
    I: Integer;
    Frames: TFrames;
  begin
    result := '';
    for I := 0 to Count - 1 do
    begin
      Result := Format('%s%s:%s%s', [result, Strings[i], cCrLf, GetPlayerStats(Strings[i]), cCrLf]);
      Frames := Objects[IndexOf(Strings[i])] as TFrames;
      result := Format('%sGame State: %s%s%s', [result, Frames.GetGameState, cCrlf, cCrLf]);
    end;
  end;

  function TPlayers.GetAllPlayersTotals: String;
  var
    i: Integer;
  begin
    result := '';
    for I := 0 to Count - 1 do
    begin
      Result := Format('%s%s: %s%s', [result, Strings[i], GetPlayerTotals(Strings[i]), cCrLf]);
    end;
  end;
//  function TPlayers.GetAllPlayersLastFrameOnly: String;
//  var
//    I: Integer;
//  begin
//    result := '';
//    for I := 0 to Count - 1 do
//    begin
//      Result := Format('%s%s:%s%s', [result, Strings[i], cCrLf,GetPlayerStatsLastFrame(Strings[i]), cCrLf]);
//    end;
//  end;

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

  procedure TBowlingGame.SetDisplayLastTwoFrames(Value: Boolean);
  begin
    FPlayers.DisplayLastTwoFrames := Value;
  end;

  function TBowlingGame.AddPlayer(const PlayerName: String; DisplayInSingleLine: Boolean): Integer;
  begin
    result := FPlayers.AddPlayer(PlayerName, DisplayInSingleLine);
  end;

  function TBowlingGame.AddRoll(const PlayerName: String; NoPins: Integer): Integer;
  begin
    result := FPlayers.AddRoll(PlayerName, NoPins);
  end;

  function TBowlingGame.IsCurrentFrameComplete(const PlayerName: string): Boolean;
  begin
    result := FPlayers.IsPlayerCurrentFrameComplete(PlayerName);
  end;

  function TBowlingGame.IsGameOver(Index: Integer): Boolean;
  begin
    result := FPlayers.IsGameOver(Index);
  end;

  function TBowlingGame.GetPlayerStats(const PlayerName: string): String;
  begin
    result := FPlayers.GetPlayerStats(PlayerName);
  end;

  function TBowlingGame.GetAllPlayersStats: String;
  begin
    result := FPlayers.GetAllPlayersStats;
  end;

  function TBowlingGame.GetAllPlayersTotals: String;
  begin
    result := FPlayers.GetAllPlayersTotals;
  end;
//  function TBowlingGame.GetPlayersLastStats(NoFrames: Integer; PlayerNo: Integer): String;
//  begin
//    result := FPlayers.GetPlayersLast(NoFrames, PlayerNo);
//  end;

  function TBowlingGame.GetPlayersLastFrameStats(Index: Integer): String;
  begin
    result := FPlayers.GetPlayersLastFrameStats(Index);
  end;
//  function TBowlingGame.GetAllPlayersLastFrameOnly: String;
//  begin
//    result := FPlayers.GetAllPlayersLastFrameOnly;
//  end;

  function BowlingGame: IBowlingGame;
  begin
    result := TBowlingGame.Create;
  end;
end.
