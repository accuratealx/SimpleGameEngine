program SSTest;

{$mode objfpc}{$H+}
{$AppType GUI}

uses
  sgeScreenSaver, sgeGraphic, sgeGraphicColor,
  Math;


type
  TElement = record
    X: Single;
    Y: Single;
    Color: TsgeGraphicColor;
  end;



  TSaverRects = class(TsgeScreenSaver)
  private
    FRects: array of array of TElement; //Массив квадратиков
    FRectW: Integer;                    //Ширина массива
    FRectH: Integer;                    //Высота массива
    FRectSize: Integer;                 //Длина стороны квадрата
    FColor: TsgeGraphicColor;           //Базовый цвет
  public
    procedure Init;
    procedure DeInit;

    procedure Draw; override;
    procedure Tick; override;
  end;



var
  SS: TSaverRects;




{$R *.res}

{$R SaverName.rc} //Подключение таблицы строк для правильного имени в диалоге настройки хранителя


procedure TSaverRects.Init;
var
  i, j: Integer;
begin
  //Настройки графики
  Graphic.State[gsColorBlend] := True;
  FColor := sgeGraphicColor_GetColor(Random, Random, Random, 1);

  //Подготовить переменные
  if StartMode = sssmPreview then FRectSize := 16 else
    FRectSize := Random(128) + 32;
  FRectW := Ceil(Window.Width / FRectSize);
  FrectH := Ceil(Window.Height / FRectSize);

  //Создать массив
  SetLength(FRects, FRectH);
  for i := 0 to FRectH - 1 do
    SetLength(FRects[i], FRectW);

  //Заполнить данными
  for i := 0 to FRectW - 1 do
    for j := 0 to FrectH - 1 do
      begin
      FRects[j, i].X := i * FRectSize;
      FRects[j, i].Y := j * FRectSize;
      FRects[j, i].Color := GC_Black;
      end;

  //Настройка системы
  TickDelay := 1000;
  TickEnable := True;
end;


procedure TSaverRects.DeInit;
begin
  FRects := nil;
end;


procedure TSaverRects.Draw;
var
  i, j: Integer;
begin
  for i := 0 to FRectW - 1 do
    for j := 0 to FRectH - 1 do
      begin
      Graphic.Color := FRects[j, i].Color;
      Graphic.DrawRect(FRects[j, i].X, FRects[j, i].Y, FRectSize, FRectSize);
      end;
end;


procedure TSaverRects.Tick;
var
  X, Y: Integer;
  a: Single;
begin
  //Изменить прозрачность на максимум
  X := Random(FRectW);
  Y := Random(FRectH);
  a := FRects[Y, X].Color.Alpha;
  a := Random + 0.1;
  if a >= 1 then a := 1;
  FRects[Y, X].Color := sgeGraphicColor_ChangeAlpha(FColor, a);
end;



begin
  SS := TSaverRects.Create;
  SS.Init;
  SS.Run;
  SS.DeInit;
  SS.Free;
end.

