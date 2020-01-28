program RenderToSprite;

{$Mode objfpc}{$H+}
{$AppType GUI}


uses
  SimpleGameEngine, sgeGraphic, sgeGraphicColor, sgeGraphicSprite, sgeKeyTable;


type
  TGame = class(TSimpleGameEngine)
  private
    FSpr: TsgeGraphicSprite;

    procedure Init;
    procedure DeInit;
  public
    procedure Draw; override;
  end;



procedure TGame.Init;
begin
  //Оболочка
  Shell.KeyTable.NamedKey['Tilde'] := sgeGetCommandKey('', 'Shell On');
  Shell.DoCommand('Attach ESC Close');

  //Настроить окно
  Window.Center;
  Window.Show;

  //Создать спрайт и залить шахматной доской
  FSpr := TsgeGraphicSprite.Create(300, 300, GC_Fuchsia);
  FSpr.FillChessBoard(50);
end;


procedure TGame.DeInit;
begin
  FSpr.Free;
end;


procedure TGame.Draw;
var
  S: TsgeGraphicSprite;
begin
  Graphic.State[gsTexture] := True;                         //Включить заливку текстурой
  Graphic.State[gsColorBlend] := True;                      //Включить смешивание цветов

  S := TsgeGraphicSprite.Create(350, 350, GC_Yellow);       //Создать временный спрайт

  Graphic.RenderSprite := S;                                //Установить временный спрайт для отрисовки
  Graphic.RenderPlace := grpSprite;                         //Изменить место вывода в спрайт

  Graphic.DrawSprite(0, 0, FSpr, 0, 0.5);                   //Нарисовать на временном спрайте шахматную доску в половину масштаба
  Graphic.Color := sgeGraphicColor_GetColor(1, 0, 0, 0.7);  //Установить цвет примитива
  Graphic.DrawRect(50, 50, 200, 200);                       //Вывести прямоугольник
  Graphic.Color := sgeGraphicColor_GetColor(0, 1, 0, 0.7);  //Установить цвет примитива
  Graphic.DrawCircle(350, 350, 100, 32);                    //Нарисовать окружность

  Graphic.RenderPlace := grpScreen;                         //Установить место вывода на экран

  Graphic.DrawSprite(100, 100, S);                          //Вывести временный спрайт на экран
  S.Free;                                                   //Удалить временный спрайт


  Graphic.State[gsTexture] := False;                        //Выключить заливку текстурой
  Graphic.State[gsColorBlend] := False;                     //Выключить смешивание цветов
end;



var
  Game: TGame;


begin
  Game := TGame.Create;
  Game.Init;
  Game.Run;
  Game.DeInit;
  Game.Free;
end.

