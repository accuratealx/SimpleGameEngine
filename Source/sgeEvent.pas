{
Пакет             Simple Game Engine 1
Файл              sgeEvent.pas
Версия            1.1
Создан            04.07.2018
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Событие срабатывающее через определённый интервал времени
}

unit sgeEvent;

{$mode objfpc}{$H+}

interface

uses
  sgeConst, sgeTypes,
  MMSystem;


type
  TsgeEventProc = procedure of object;


  TsgeEvent = class
  private
    FDelay: Cardinal;                               //Задержка между тиками
    FEnable: Boolean;                               //Флаг работы
    FProc: TsgeEventProc;                           //Процедура для вызова
    FTimes: Integer;                                //Сколько раз срабатывать (меньше 0 - бесконечный вызов)
    FTimerID: Cardinal;                             //Идентификатор таймера
    FCount: Cardinal;                               //Всего вызовов
    FTimesCount: Cardinal;                          //Вызовов с каждого момента запуска

    FMinPeriod: Cardinal;                           //Миниимальный интервал
    FMaxPeriod: Cardinal;                           //Максимальный интервал

    procedure SetEnable(AEnable: Boolean);          //Переключить флаг работы
    procedure SetDelay(ADelay: Cardinal);           //Изменить задержку между вызовами
    procedure SetTimes(ATimes: Integer);            //Установить количество срабатываний после запуска
    procedure StartEvent;                           //Запуск таймера
    procedure StopEvent;                            //Останов таймера
    procedure CorrectPeriod(var Period: Cardinal);  //Поправить задержку
  public
    constructor Create(Delay: Cardinal; Enable: Boolean; Proc: TsgeEventProc; Times: Integer = -1);
    destructor  Destroy; override;

    property MinPeriod: Cardinal read FMinPeriod;
    property MaxPeriod: Cardinal read FMaxPeriod;
    property Delay: Cardinal read FDelay write SetDelay;
    property Enable: Boolean read FEnable write SetEnable;
    property Times: Integer read FTimes write SetTimes;
    property Proc: TsgeEventProc read FProc write FProc;
    property Count: Cardinal read FCount write FCount;
  end;


implementation


function sgeTimeSetEvent(uDelay: Cardinal; uResolution: Cardinal; lpTimeProc: Pointer; dwUser: TObject; fuEvent: Cardinal): Cardinal; stdcall; external 'winmm.dll' name 'timeSetEvent';
Function sgeTimeKillEvent(uTimerID: Cardinal): Cardinal; stdcall; external 'winmm.dll' name 'timeKillEvent';


//Функция обратного вызова
Procedure sgeTimeEventProc(uTimerID, uMsg: Cardinal; dwUser, dw1, dw2: PtrUInt); stdcall;
var
  Eo: TsgeEvent;
begin
  //Подготовить ссылку
  Eo := TsgeEvent(dwUser);
  if Eo = nil then Exit;

  //Выполнить процедуру
  if Eo.FProc <> nil then
    begin
    Eo.Proc;                //Вызвать метод
    Inc(Eo.FCount);         //Прибавить вызов
    end;

  //Предусмотреть бесконечую работу, при отрицательных значениях
  if Eo.FTimes < 0 then Exit;

  //Обработать счётчик ограниченной работы
  Inc(Eo.FTimesCount);
  if Eo.FTimesCount >= Eo.FTimes then Eo.StopEvent;
end;


procedure TsgeEvent.SetEnable(AEnable: Boolean);
begin
  if FEnable = AEnable then Exit;
  if AEnable then StartEvent else StopEvent;
end;


procedure TsgeEvent.SetDelay(ADelay: Cardinal);
begin
  CorrectPeriod(ADelay);

  if FDelay = ADelay then Exit;
  FDelay := ADelay;

  if FEnable then
    begin
    StopEvent;
    StartEvent;
    end;
end;


procedure TsgeEvent.SetTimes(ATimes: Integer);
begin
  if FTimes = ATimes then Exit;
  FTimes := ATimes;

  if FEnable then
    begin
    StopEvent;
    StartEvent;
    end;
end;


procedure TsgeEvent.StartEvent;
begin
  FTimerID := sgeTimeSetEvent(FDelay, 0, @sgeTimeEventProc, Self, 1);
  if FTimerID = 0 then
    raise EsgeException.Create(Err_sgeEvent + Err_Separator + Err_sgeEvent_CantStartEvent);

  FEnable := True;
end;


procedure TsgeEvent.StopEvent;
begin
  sgeTimeKillEvent(FTimerID); //Прибить таймер
  FEnable := False;           //Выклоючить флаг работы
  FTimerID := 0;              //Обнулить ID таймера
  FTimesCount := 0;           //Обнулить счётчик ограниченной работы
end;


procedure TsgeEvent.CorrectPeriod(var Period: Cardinal);
begin
  if Period < FMinPeriod then Period := FMinPeriod;
  if Period > FMaxPeriod then Period := FMaxPeriod;
end;


constructor TsgeEvent.Create(Delay: Cardinal; Enable: Boolean; Proc: TsgeEventProc; Times: Integer);
var
  tc: TTIMECAPS;
begin
  //Определить диапазон
  timeGetDevCaps(@tc, SizeOf(TTIMECAPS));
  FMinPeriod := tc.wPeriodMin;
  FMaxPeriod := tc.wPeriodMax;

  //Поправить диапазон
  CorrectPeriod(Delay);

  FDelay := Delay;              //Задержка
  FProc := Proc;                //Метод класса без параметров
  FTimes := Times;              //Раз срабатываний
  if Enable then StartEvent;    //Запуск если нужно
end;


destructor TsgeEvent.Destroy;
begin
  StopEvent;
end;



end.

