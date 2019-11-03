{
Пакет             Simple Game Engine 1
Файл              sgeCounter.pas
Версия            1.1
Создан            25.08.2018
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Счётчик событий в секунду
}

unit sgeCounter;

{$mode objfpc}{$H+}

interface

uses
  Windows;

type
  TsgeCounter = class
  private
    FCurrentTime: QWord;  //Текущее время вызова
    FLastTime: QWord;     //Последнее время вызова
    FCounter: Cardinal;   //Счётчик до наступления интервала
    FCount: Cardinal;     //Сколько срабатываний в интервал
    FInterval: Cardinal;  //Время замера в милисекундах

    function GetStrCount: String;
  public
    constructor Create(Interval: Cardinal = 1000);

    procedure Clear;
    procedure Process;

    property Count: Cardinal read FCount;
    property StrCount: String read GetStrCount;
    property Interval: Cardinal read FInterval write FInterval;
  end;

implementation


function TsgeCounter.GetStrCount: String;
begin
  Str(FCount, Result);
end;


constructor TsgeCounter.Create(Interval: Cardinal);
begin
  FInterval := Interval;
  Clear;
end;

procedure TsgeCounter.Clear;
begin
  FLastTime := GetTickCount64;
  FCounter := 0;
  FCount := 0;
end;


procedure TsgeCounter.Process;
begin
  FCurrentTime := GetTickCount64;
  if FCurrentTime - FLastTime >= FInterval then
    begin
    FCount := FCounter;
    FCounter := 0;
    FLastTime := FCurrentTime;
    end else Inc(FCounter);
end;


end.

