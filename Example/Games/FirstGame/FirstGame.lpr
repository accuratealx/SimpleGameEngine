program FirstGame;

{$Mode objfpc}{$H+}
{$AppType GUI}


uses
  SimpleGameEngine, sgeGraphic, sgeGraphicColor, sgeKeyTable,
  SysUtils;


type
  TGame = class(TSimpleGameEngine)
  private
    procedure Init;
  public
    procedure Draw; override;
  end;



procedure TGame.Init;
var
  fn: String;
begin
  //Оболочка
  Shell.KeyTable.NamedKey['Tilde'] := sgeGetCommandKey('', 'Shell On');
  Shell.DoCommand('Attach ESC Close');
  Shell.DoCommand('FontSize 16');
  Shell.DoCommand('FontAttrib B');

  fn := '..\..\..\Language\Russian.Language';
  if FileExists(fn) then LoadLanguage(fn);


  //Настроить графику
  AutoEraseBG := False;             //Автостирание фона перед выводом кадра
  Graphic.RenderBuffer := grbFront; //Отрисовка в передний буфер
  Graphic.PointSize := 2;           //Размер точки

  //Настроить окно
  Window.Center;
  Window.Show;
end;


procedure TGame.Draw;
var
  i: Integer;
begin
  //Стереть 1000 точек
  Graphic.Color := GC_Black;
  for i := 0 to 5000 do
    Graphic.DrawPoint(Random(Window.Width), Random(Window.Height));

  //Нарисовать одну
  Graphic.Color := GC_White;
  Graphic.DrawPoint(Random(Window.Width), Random(Window.Height));
end;



var
  Game: TGame;


begin
  Game := TGame.Create(False);
  Game.Init;
  Game.Run;
  Game.Free;
end.

