{
Пакет             Simple Game Engine
Файл              sgeTask.pas
Версия            1.1
Создан            13.07.2020
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Класс пользовательской задачи
}

unit sgeTask;

{$mode objfpc}{$H+}

interface


type
  //Указатель на метод задачи
  TsgeTaskProc = procedure of object;



  TsgeTask = class
  private
    //Основные параметры
    FName: String;                              //Имя задачи
    FDelay: Cardinal;                           //Задержка между вызовами в ms
    FEnable: Boolean;                           //Активность
    FTimes: Integer;                            //Количество срабатываний, -1 - бесконечно
    FProc: TsgeTaskProc;                        //Указатель на метод
    FStartDelay: Cardinal;                      //Задержка перед первым выполнением
    FAutoDelete: Boolean;                       //Автоудаление при выполнении

    //Дополнительные параметры
    FLastExecuteTime: Int64;                    //Время последнего вызова
    FTimesCounter: Int64;                       //Количество срабатываний

    procedure SetTimes(ATimes: Integer);
    procedure SetEnable(AEnable: Boolean);
  public
    constructor Create(Name: String; Proc: TsgeTaskProc; Delay: Cardinal = 0; Times: Integer = -1; Enable: Boolean = True; AutoDelete: Boolean = True; StartDelay: Cardinal = 0);

    procedure Restart;
    procedure Start;
    procedure Stop;

    function  GetExecuteCount: Integer;         //Сколько раз выполнять задачу
    procedure Execute;                          //Выполнить задачу

    property Name: String read FName write FName;
    property Delay: Cardinal read FDelay write FDelay;
    property Enable: Boolean read FEnable write SetEnable;
    property Times: Integer read FTimes write SetTimes;
    property Proc: TsgeTaskProc read FProc write FProc;
    property StartDelay: Cardinal read FStartDelay write FStartDelay;
    property AutoDelete: Boolean read FAutoDelete write FAutoDelete;
    property Count: Int64 read FTimesCounter;
  end;





implementation

uses
  sgeConst, sgeTypes;


const
  _UNITNAME = 'sgeTask';


procedure TsgeTask.SetTimes(ATimes: Integer);
begin
  if ATimes < 0 then ATimes := -1;
  if FTimes = ATimes then Exit;

  FTimes := ATimes;
end;


procedure TsgeTask.SetEnable(AEnable: Boolean);
begin
  if AEnable = FEnable then Exit;

  FEnable := AEnable;
  if FEnable then FLastExecuteTime := sgeGetTickCount;
end;


constructor TsgeTask.Create(Name: String; Proc: TsgeTaskProc; Delay: Cardinal; Times: Integer; Enable: Boolean; AutoDelete: Boolean; StartDelay: Cardinal);
begin
  //Основные параметры
  FName := Name;
  FProc := Proc;
  FDelay := Delay;
  FTimes := Times;
  FEnable := Enable;
  FStartDelay := StartDelay;
  FAutoDelete := AutoDelete;

  //Дополнительные параметры
  FLastExecuteTime := sgeGetTickCount + FStartDelay;
  FTimesCounter := 0;
end;


procedure TsgeTask.Restart;
begin
  FLastExecuteTime := sgeGetTickCount + FStartDelay;
  FTimesCounter := 0;
  FEnable := True;
end;


procedure TsgeTask.Start;
begin
  SetEnable(True);
end;


procedure TsgeTask.Stop;
begin
  SetEnable(False);
end;


function TsgeTask.GetExecuteCount: Integer;
var
  NowTime, ATimes: Int64;
begin
  Result := 0;

  if not FEnable then Exit;

  NowTime := sgeGetTickCount;
  ATimes := (NowTime - FLastExecuteTime) div FDelay;
  if ATimes > 0 then
    begin
    FLastExecuteTime := FLastExecuteTime + (FDelay * ATimes);
    Result := ATimes;
    end;
end;


procedure TsgeTask.Execute;
begin
  //Проверить указатель на метод
  if FProc = nil then
    raise EsgeException.Create(_UNITNAME, Err_EmptyPointer, FName);


  //Проверить ограничение на количество срабатываний
  if FTimes > -1 then
    if FTimesCounter >= FTimes then
      begin
      FEnable := False;
      Exit;
      end;

  //Выполнить задание
  FProc();                              //Выполнить задачу
  Inc(FTimesCounter);                   //Увеличить счётчик
end;


end.

