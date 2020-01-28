program PingPong;

{$Mode objfpc}{$H+}
{$AppType GUI}

uses
  SimpleGameEngine, sgeTypes, sgeGraphic, sgeGraphicSprite, sgeGraphicFont, sgeWindow, sgeSoundBuffer,
  sgeSoundSource, sgeSound, sgeResourceList, sgeKeyTable, sgeFade, sgeGraphicColor,
  Windows, Math, SysUtils;


const
  FadeColor: TsgeGraphicColor = (Red: 0; Green: 0; Blue: 0; Alpha: 1);


type
  TBall = record
    X: Single;
    Y: Single;
    Radius: Single;
    Speed: Single;
    Angle: Single;
    MaxSpeed: Single;
  end;

  TPad = record
    Left: Single;
    Top: Single;
    Width: Single;
    Height: Single;
    Goals: Integer;
  end;


  TPingPong = class(TSimpleGameEngine)
  private
    FBall: TBall;
    FUser: TPad;
    FCPU: TPad;

    FSprBG: TsgeGraphicSprite;
    FSprBall: TsgeGraphicSprite;
    FSprPad: TsgeGraphicSprite;

    FSndPad: TsgeSoundBuffer;
    FSndBorder: TsgeSoundBuffer;
    FSndGoal: TsgeSoundBuffer;

    FSrcPad: TsgeSoundSource;
    FSrcBorder: TsgeSoundSource;

    FFont: TsgeGraphicFont;

    FPause: Boolean;

    procedure SetPause(APAuse: Boolean);
  public
    constructor Create(InitSound: Boolean = False); override;
    destructor  Destroy; override;

    procedure Init;
    procedure InitBall;
    procedure NewGame;

    procedure Draw; override;
    procedure Tick;
    procedure ResizeWindow; override;

    procedure KeyDown(Key: Byte; KeyboardButtons: TsgeKeyboardButtons); override;
    procedure MouseDown(X, Y: Integer; MouseButtons: TsgeMouseButtons; KeyboardButtons: TsgeKeyboardButtons); override;
    procedure MouseMove(X, Y: Integer; MouseButtons: TsgeMouseButtons; KeyboardButtons: TsgeKeyboardButtons); override;

    property Pause: Boolean read FPause write SetPause;
  end;


procedure TPingPong.SetPause(APAuse: Boolean);
begin
  if FPause = APAuse then Exit;

  FPause := APAuse;
  if FPause then
    begin
    TaskList.NamedTask['Tick'].Enable := False;
    Window.ClipCursor := False;
    Window.ShowCursor := True;
    end
    else begin
    TaskList.NamedTask['Tick'].Enable := True;
    Window.ClipCursor := True;
    Window.ShowCursor := False;
    end;
end;


constructor TPingPong.Create(InitSound: Boolean);
begin
  inherited Create(InitSound);
end;


destructor TPingPong.Destroy;
begin
  FSrcPad.Free;
  FSrcBorder.Free;
  inherited Destroy;
end;


procedure TPingPong.Init;
begin
  //Окно
  Window.Caption := 'Ping pong';
  Window.Style := [wsCaption, wsSystemMenu];
  Window.Buttons := [wbClose, wbMinimize];
  Window.Width := 800;
  Window.Height := 600;
  Window.Center(wcpClientArea);
  LoadAppIcon('MainIcon', lfHinstance);

  //Игрок
  FUser.Left := 0;
  FUser.Width := 20;
  FUser.Height := 150;
  FUser.Top := Window.Height / 2 - FUser.Height / 2;

  //CPU
  FCPU.Width := 20;
  FCPU.Left := Window.Width - FCPU.Width;
  FCPU.Height := 150;
  FCPU.Top := Window.Height / 2 - FCPU.Height / 2;

  //Загрузка ресурсов
  LoadPackFromDirectory('');
  LoadResourcesFromTable('Res.List');

  //Поиск в хранилище ссылок
  FSprBG := GetGraphicSprite('Spr.BG');
  FSprBall := GetGraphicSprite('Spr.Ball');
  FSprPad := GetGraphicSprite('Spr.Pad');
  FSndPad := GetSoundBuffer('Snd.Pad');
  FSndBorder := GetSoundBuffer('Snd.Border');
  FSndGoal := GetSoundBuffer('Snd.Goal');
  FFont := GetGraphicFont('Fnt');

  //Графика
  Graphic.State[gsTexture] := True;
  Graphic.State[gsColorBlend] := True;

  //Звук
  Sound.DistanceModel := sdmNone;
  Sound.PosX := Window.Width / 2;
  Sound.PosY := Window.Height / 2;
  Sound.Source.Buffer := FSndGoal;
  FSrcPad := TsgeSoundSource.Create;
  FSrcBorder := TsgeSoundSource.Create;
  FSrcBorder.Buffer := FSndBorder;
  FSrcPad.Buffer := FSndPad;

  //Система
  Randomize;
  TaskList.Add('Tick', @Tick, 2, -1, True, False);
  TaskEnable := True;
  MaxFPS := 60;
  DrawControl := dcProgram;
  Priority := pHigh;
  NewGame;

  //Привязать оболочку
  Shell.KeyTable.NamedKey['Tilde'] := sgeGetCommandKey('', 'Shell on');

  //Показать окно
  Window.Show;
end;


procedure TPingPong.InitBall;
begin
  FBall.X := Window.Width / 2;
  FBall.Y := Window.Height / 2;
  FBall.Radius := 10;
  FBall.Speed := 1;
  FBall.MaxSpeed := 10;
  FBall.Angle := gradtorad(Random(141) - 70);
end;


procedure TPingPong.NewGame;
begin
  InitBall;
  FUser.Goals := 0;
  FCPU.Goals := 0;
  Pause := True;
end;



procedure TPingPong.Draw;
var
  X: Integer;
  S: String;
begin
  //Вывод фона
  Graphic.DrawSprite(0, 0, Window.Width, Window.Height, FSprBG, gdmClassic);

  //Игрок
  Graphic.DrawSprite(FUser.Left, FUser.Top, FUser.Width, FUser.Height, FSprPad);

  //CPU
  Graphic.DrawSprite(FCPU .Left, FCPU.Top, FCPU.Width, FCPU.Height, FSprPad);

  //Вывод шарика
  Graphic.DrawSprite(FBall.X, FBall.Y, FBall.Radius * 2, FBall.Radius * 2, FSprBall, gdmCentered);

  //Счёт
  S := IntToStr(FUser.Goals) + ':' + IntToStr(FCPU.Goals);
  X := FFont.GetStringWidth(S);
  Graphic.DrawText(Window.Width / 2 - X / 2, 10, FFont, S);

  //Пауза
  if Pause then
    begin
    S := 'Pause';
    X := FFont.GetStringWidth(S);
    Graphic.DrawText(Window.Width / 2 - X / 2, Window.Height / 2 - FFont.Height / 2, FFont, S);
    end;
end;


procedure TPingPong.Tick;
const
  CpuOffset = 2;
  BallOffset = 0.1;
  PadAngle = 120;
var
  Dx, A: Single;
begin
  //Изменить положение шарика
  FBall.X := FBall.X + FBall.Speed * cos(FBall.Angle);
  FBall.Y := FBall.Y + FBall.Speed * sin(FBall.Angle);

  //Изменить положение источника
  FSrcBorder.PosX := FBall.X;
  FSrcBorder.PosY := FBall.Y;
  FSrcPad.PosX := FBall.X;
  FSrcPad.PosY := FBall.Y;

  //Изменить положение доски CPU
  if FBall.Y < FCPU.Top + FCPU.Height / 2 then FCPU.Top := FCPU.Top - CpuOffset else FCPU.Top := FCPU.Top + CpuOffset;
  if FCPU.Top <= 0 then FCPU.Top := 0;
  if FCPU.Top >= Window.Height - FCPU.Height then FCPU.Top := Window.Height - FCPU.Height;


  //Отскок от верха
  if (FBall.Y <= FBall.Radius) then
    begin
    FBall.Angle := -FBall.Angle;
    FBall.Y := FBall.Radius;
    FSrcBorder.Play;
    end;

  //Отскок от низа
  if (FBall.Y >= Window.Height - FBall.Radius) then
    begin
    FBall.Angle := -FBall.Angle;
    FBall.Y := Window.Height - FBall.Radius;
    FSrcBorder.Play;
    end;

  //Удар о левую панель
  if (FBall.X - FBall.Radius <= FUser.Width) and (FBall.Y >= FUser.Top) and (FBall.Y <= FUser.Top + FUser.Height) then
    begin
    FBall.Speed := FBall.Speed + BallOffset;
    if FBall.Speed >= FBall.MaxSpeed then FBall.Speed := FBall.MaxSpeed;
    FBall.X := FUser.Width + FBall.Radius;
    Dx := PadAngle / FUser.Height;
    A := Abs(FUser.Top - FBall.Y) * Dx - (PadAngle / 2);
    FBall.Angle := gradtorad(A);
    FSrcPad.Play;
    end;

  //Удар о правую панель
  if (FBall.X + FBall.Radius >= FCPU.Left) and (FBall.Y >= FCPU.Top) and (FBall.Y <= FCPU.Top + FCPU.Height) then
    begin
    FBall.Speed := FBall.Speed + BallOffset;
    if FBall.Speed >= FBall.MaxSpeed then FBall.Speed := FBall.MaxSpeed;
    FBall.X := FCPU.Left - FBall.Radius;
    Dx := PadAngle / FCPU.Height;
    FBall.Angle := -(FBall.Angle + pi);
    FSrcPad.Play;
    end;

  //Проверка проигрыша игрока
  if FBall.X <= 0 then
    begin
    Sound.Source.Play;
    Inc(FCPU.Goals);
    InitBall;
    FadeStart(fmNormalToColorToNormal, FadeColor, 150);
    end;

  //Проверка проигрыша CPU
  if FBall.X >= Window.Width then
    begin
    Sound.Source.Play;
    Inc(FUser.Goals);
    InitBall;
    FadeStart(fmNormalToColorToNormal, FadeColor, 150);
    end;

end;


procedure TPingPong.ResizeWindow;
begin
  FCPU.Left := Window.Width - FCPU.Width;
  FCPU.Top := Window.Height / 2 - FCPU.Height / 2;
end;


procedure TPingPong.KeyDown(Key: Byte; KeyboardButtons: TsgeKeyboardButtons);
begin
  case Key of
    VK_ESCAPE: Stop;
    VK_SPACE: Pause := not Pause;
  end;
end;


procedure TPingPong.MouseDown(X, Y: Integer; MouseButtons: TsgeMouseButtons; KeyboardButtons: TsgeKeyboardButtons);
begin
  if mbLeft in MouseButtons then Pause := not Pause;
  if mbRight in MouseButtons then NewGame;
end;


procedure TPingPong.MouseMove(X, Y: Integer; MouseButtons: TsgeMouseButtons; KeyboardButtons: TsgeKeyboardButtons);
var
  NewY: Single;
begin
  if FPause then Exit;

  //Пошевелить доску игрока
  NewY := Y - FUser.Height / 2;
  if NewY <= 0 then NewY := 0;
  if NewY >= Window.Height - FUser.Height then NewY := Window.Height - FUser.Height;
  FUser.Top := NewY;
end;





var
  Game: TPingPong;


{$R *.res}

begin
  Game := TPingPong.Create(True);
  Game.Init;
  Game.Run;
  Game.Free;
end.

