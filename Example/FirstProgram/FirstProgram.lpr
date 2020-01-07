program FirstProgram;

{$mode objfpc}{$H+}


uses
  SimpleGameEngine, sgeGraphic, sgeGraphicColor;


type
  TMyGame = class(TSimpleGameEngine)
  public
    procedure Draw; override;
  end;


var
  MyGame: TMyGame;


procedure TMyGame.Draw;
begin
  Graphic.Color := GC_Blue;                           //Задать базовый цвет примитива
  Graphic.DrawRect(256, 256, 256, 256, gdmCentered);  //Вывод прямоугольника залитого цветом


  Graphic.Color := GC_Red;                            //Задать базовый цвет примитива
  Graphic.PointSize := 32;                            //Установить размер точки
  Graphic.Capabilities[gcPointSmooth] := True;        //Включить сглаживание точек
  Graphic.DrawPoint(256, 256);                        //Вывод точки
  Graphic.Capabilities[gcPointSmooth] := False;       //Выключить сглаживание точек

  Graphic.DrawRectGradient(512, 128, 256, 32, GC_Fuchsia, GC_Yellow);
end;


begin
  MyGame := TMyGame.Create;   //Создать объект
  MyGame.InitWindow;          //Создать окно
  MyGame.InitGraphic;         //Создать графику

  //По умолчанию окно невидимо, покажем и настроим заголовок
  MyGame.Window.Caption := 'First SimpleGameEngine application';
  MyGame.Window.Show;

  MyGame.Run;                 //Запуск бесконечного цикла
  MyGame.Free;                //Удалить объект
end.

