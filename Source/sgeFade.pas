{
Пакет             Simple Game Engine 1
Файл              sgeFade.pas
Версия            1.0
Создан            20.08.2019
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Класс для затемнения экрана
}

unit sgeFade;

{$mode objfpc}{$H+}

interface

uses
  sgeGraphicColor,
  Windows;



type
  //Виды затемнения
  TsgeFadeMode = (fmNormalToColor, fmColorToNormal, fmNormalToColorToNormal, fmColorToNormalToColor);


  TsgeFade = class
  private
    FValues: array of Single; //Массив прозрачностей для градиента
    FEnable: Boolean;         //Активность
    FStartTime: Int64;        //Время запуска
    FTime: Cardinal;          //Длительность в мс
    FColor: TsgeGraphicColor; //Промежуточный цвет

    procedure ValuesClear;
    procedure ValuesAdd(aValue: Single);
    function  ValuesGradient(Pos: Single): Single;
  public
    destructor Destroy; override;

    procedure Start(Mode: TsgeFadeMode; Color: TsgeGraphicColor; Time: Cardinal);
    procedure Stop;

    function  GetColor: TsgeGraphicColor;

    property Enable: Boolean read FEnable;
  end;



implementation



procedure TsgeFade.ValuesClear;
begin
  SetLength(FValues, 0);
end;


procedure TsgeFade.ValuesAdd(aValue: Single);
var
  Idx: Integer;
begin
  Idx := Length(FValues);
  SetLength(FValues, Idx + 1);
  FValues[Idx] := aValue;
end;


function TsgeFade.ValuesGradient(Pos: Single): Single;
var
  I, N: Integer;
  X1, X2: Single;
begin
  //Поправить диапазон
  if Pos <= 0 then Pos := 0;
  if Pos >= 1 then Pos := 1;

  //Высчитать положение
  N := Length(FValues);
  I := 0;
  X1 := 0;
  X2 := 1;

  while I < N do
    begin
    X1 := I / (N - 1);
    X2 := (I + 1) / (N - 1);
    if (Pos >= X1) and (Pos <= X2) then Break;
    Inc(I);
    end;

  Result := FValues[I] + (FValues[I + 1] - FValues[I]) * ((Pos - X1) / (X2 - X1));
end;


destructor TsgeFade.Destroy;
begin
  ValuesClear;
end;


procedure TsgeFade.Start(Mode: TsgeFadeMode; Color: TsgeGraphicColor; Time: Cardinal);
begin
  //Запомнить длительность
  if Time < 1 then Time := 1;
  FTime := Time;

  //Запомнить цвет
  FColor := Color;

  //Заполнить массив прозрачностей
  ValuesClear;
  case Mode of
    fmNormalToColor:
      begin
      ValuesAdd(0);
      ValuesAdd(FColor.Alpha);
      end;

    fmColorToNormal:
      begin
      ValuesAdd(FColor.Alpha);
      ValuesAdd(0);
      end;

    fmNormalToColorToNormal:
      begin
      ValuesAdd(0);
      ValuesAdd(FColor.Alpha);
      ValuesAdd(0);
      end;

    fmColorToNormalToColor:
      begin
      ValuesAdd(FColor.Alpha);
      ValuesAdd(0);
      ValuesAdd(FColor.Alpha);
      end;
  end;

  //Запомнить время запуска
  FStartTime := GetTickCount64;

  //Запустить
  FEnable := True;
end;


procedure TsgeFade.Stop;
begin
  FEnable := False;
end;


function TsgeFade.GetColor: TsgeGraphicColor;
var
  cTime: Int64;
begin
  Result := sgeGraphicColor_ChangeAlpha(FColor, 0);
  cTime := GetTickCount64 - FStartTime;
  if cTime <= FTime then Result := sgeGraphicColor_ChangeAlpha(FColor, ValuesGradient(cTime / FTime)) else FEnable := False;
end;




end.

