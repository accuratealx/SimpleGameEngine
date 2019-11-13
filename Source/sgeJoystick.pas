{
Пакет             Simple Game Engine 1
Файл              sgeJoystick.pas
Версия            1.1
Создан            08.03.2019
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Класс работы с джойстиком
}

unit sgeJoystick;

{$mode objfpc}{$H+}

interface

uses
  sgeConst, sgeTypes,
  SysUtils, MMSystem;


type
  //Тип крестовины
  TsgeJoystickPovType = (jptVirtual, jptDirection, jptDegree);

  //Одна кнопка джойстика
  TsgeJoystickButton = record
    Down: Boolean;
    DownOnce: Boolean;
    RepeatCount: Cardinal;
  end;
  PsgeJoystickButton = ^TsgeJoystickButton;


  TsgeJoystick = class
  private
    _Delta: Single;                         //Волшебное число
    _Middle: Integer;                       //Среднее значение оси

    FDriverID: Byte;                        //Идентификатор драйвера
    FCaps: TJOYCAPS;                        //Параметры оборудования
    FPosEx: TJOYINFOEX;                     //Состояние кнопок и осей

    FBtnArray: array of TsgeJoystickButton; //Массив кнопок
    FPovType: TsgeJoystickPovType;          //Тип крестовины
    FAxisMin: Integer;                      //Наименьшее значение осей
    FAxisMax: Integer;                      //Наибольшее значение осей
    FAxisSmooth: Boolean;                   //Сглаживать значения

    FZAxisExist: Boolean;                   //Ось Z
    FRAxisExist: Boolean;                   //Ось Rudder
    FUAxisExist: Boolean;                   //Ось U
    FVAxisExist: Boolean;                   //Ось V

    function  GetName: ShortString;
    function  GetButtonCount: Byte;
    function  GetAxisCount: Byte;

    function  GetPov: Integer;
    function  GetXAxis: Integer;
    function  GetYAxis: Integer;
    function  GetZAxis: Integer;
    function  GetRAxis: Integer;
    function  GetUAxis: Integer;
    function  GetVAxis: Integer;
    function  GetButton(Index: Byte): TsgeJoystickButton;

    procedure SetAxisMin(AMin: Integer);
    procedure SetAxisMax(AMax: Integer);
    procedure CalculateDelta;
  public
    constructor Create(ID: Byte);
    destructor  Destroy; override;

    procedure Reset;
    procedure Process;

    property DriverID: Byte read FDriverID;
    property Name: ShortString read GetName;
    property PovType: TsgeJoystickPovType read FPovType;
    property ButtonCount: Byte read GetButtonCount;
    property AxisCount: Byte read GetAxisCount;
    property AxisMin: Integer read FAxisMin write SetAxisMin;
    property AxisMax: Integer read FAxisMax write SetAxisMax;
    property AxisSmooth: Boolean read FAxisSmooth write FAxisSmooth;
    property ZAxisExist: Boolean read FZAxisExist;
    property RAxisExist: Boolean read FRAxisExist;
    property UAxisExist: Boolean read FUAxisExist;
    property VAxisExist: Boolean read FVAxisExist;

    property POV: Integer read GetPov;
    property XAxis: Integer read GetXAxis;
    property YAxis: Integer read GetYAxis;
    property ZAxis: Integer read GetZAxis;
    property RAxis: Integer read GetRAxis;
    property UAxis: Integer read GetUAxis;
    property VAxis: Integer read GetVAxis;
    property Button[Index: Byte]: TsgeJoystickButton read GetButton;
  end;




implementation


const
  _UNITNAME = 'sgeJoystick';



function TsgeJoystick.GetName: ShortString;
begin
  Result := FCaps.szPname;
end;


function TsgeJoystick.GetButtonCount: Byte;
begin
  Result := FCaps.wNumButtons;
end;


function TsgeJoystick.GetAxisCount: Byte;
begin
  Result := FCaps.wNumAxes;
end;


function TsgeJoystick.GetPov: Integer;
var
  X, Y: Byte;
begin
  if FPovType = jptVirtual then
    begin
    //Определить состояние осей
    X := 0;
    Y := 0;
    if FPosEx.wYpos = 0 then Y := 1;
    if FPosEx.wXpos = $FFFF then X := 2;
    if FPosEx.wYpos = $FFFF then Y := 4;
    if FPosEx.wXpos = 0 then X := 8;

    //Вернуть значение POV
    case X + Y of
      1 : Result := 0;
      3 : Result := 45;
      2 : Result := 90;
      6 : Result := 135;
      4 : Result := 180;
      12: Result := 225;
      8 : Result := 270;
      9 : Result := 315;
      else Result := -1;
    end;
    end else
      if FPosEx.dwPOV = $FFFF then Result := -1 else Result := FPosEx.dwPOV div 100;
end;


function TsgeJoystick.GetXAxis: Integer;
begin
  Result := FAxisMin + Round(FPosEx.wXpos * _Delta);
end;


function TsgeJoystick.GetYAxis: Integer;
begin
  Result := FAxisMin + Round(FPosEx.wYpos * _Delta);
end;


function TsgeJoystick.GetZAxis: Integer;
begin
  if FZAxisExist then Result := FAxisMin + Round(FPosEx.wZpos * _Delta) else Result := _Middle;
end;


function TsgeJoystick.GetRAxis: Integer;
begin
  if FRAxisExist then Result := FAxisMin + Round(FPosEx.dwRpos * _Delta) else Result := _Middle;
end;


function TsgeJoystick.GetUAxis: Integer;
begin
  if FUAxisExist then Result := FAxisMin + Round(FPosEx.dwUpos * _Delta) else Result := _Middle;
end;


function TsgeJoystick.GetVAxis: Integer;
begin
  if FVAxisExist then Result := FAxisMin + Round(FPosEx.dwVpos * _Delta) else Result := _Middle;
end;


function TsgeJoystick.GetButton(Index: Byte): TsgeJoystickButton;
begin
  if Index > FCaps.wNumButtons - 1 then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_IndexOutOfBounds, IntToStr(Index)));

  Result := FBtnArray[Index];
end;


procedure TsgeJoystick.SetAxisMin(AMin: Integer);
begin
  FAxisMin := AMin;
  CalculateDelta;
end;


procedure TsgeJoystick.SetAxisMax(AMax: Integer);
begin
  FAxisMax := AMax;
  CalculateDelta;
end;


procedure TsgeJoystick.CalculateDelta;
begin
  _Delta := Abs(FAxisMax - FAxisMin) / $FFFF;
  _Middle := FAxisMin + Round($7FFF * _Delta);
end;


constructor TsgeJoystick.Create(ID: Byte);
var
  J: TJOYINFO;
begin
  //Проверить физическое подключение
  if joyGetPos(ID, @J) <> JOYERR_NOERROR then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_DeviceNotAttach, IntToStr(ID)));

  //Запросить параметры
  if joyGetDevCaps(ID, @FCaps, SizeOf(TJOYCAPS)) <> JOYERR_NOERROR then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_CantGetDeviceInfo, IntToStr(ID)));

  //Задать значения
  FDriverID := ID;
  FPosEx.dwSize := SizeOf(TJOYINFOEX);
  FAxisSmooth :=  True;

  //Определить тип крестовины
  FPovType := jptVirtual;
  if (FCaps.wCaps and JOYCAPS_HASPOV) = JOYCAPS_HASPOV then
    begin
    if (FCaps.wCaps and JOYCAPS_POV4DIR) = JOYCAPS_POV4DIR then FPovType := jptDirection;
    if (FCaps.wCaps and JOYCAPS_POVCTS) = JOYCAPS_POVCTS then FPovType := jptDegree;
    end;

  //Наличие осей
  if (FCaps.wCaps and JOYCAPS_HASZ) = JOYCAPS_HASZ then FZAxisExist := True;
  if (FCaps.wCaps and JOYCAPS_HASR) = JOYCAPS_HASR then FRAxisExist := True;
  if (FCaps.wCaps and JOYCAPS_HASU) = JOYCAPS_HASU then FUAxisExist := True;
  if (FCaps.wCaps and JOYCAPS_HASV) = JOYCAPS_HASV then FVAxisExist := True;

  //Создать массив кнопок
  SetLength(FBtnArray, FCaps.wNumButtons);

  //Задать диапазон осей
  FAxisMin := 0;
  FAxisMax := $FFFF;
  CalculateDelta;
end;


destructor TsgeJoystick.Destroy;
begin
  SetLength(FBtnArray, 0);
end;


procedure TsgeJoystick.Reset;
begin
  //Оси
  FPosEx.wXpos := _Middle;
  FPosEx.wYpos := _Middle;
  FPosEx.wZpos := _Middle;
  FPosEx.dwRpos := _Middle;
  FPosEx.dwUpos := _Middle;
  FPosEx.dwVpos := _Middle;

  //POV
  FPosEx.dwPOV := $FFFF;

  //Кнопки
  FillChar(FBtnArray[0], Length(FBtnArray) * SizeOf(TsgeJoystickButton), 0);
end;


procedure TsgeJoystick.Process;
var
  i, c: Integer;
  Mask: Cardinal;
  B: PsgeJoystickButton;
begin
  //Задать основные параметры запроса
  FPosEx.dwFlags := JOY_RETURNX or JOY_RETURNY or JOY_RETURNBUTTONS;

  //Оси
  if FZAxisExist then FPosEx.dwFlags := FPosEx.dwFlags or JOY_RETURNZ;
  if FRAxisExist then FPosEx.dwFlags := FPosEx.dwFlags or JOY_RETURNR;
  if FUAxisExist then FPosEx.dwFlags := FPosEx.dwFlags or JOY_RETURNU;
  if FVAxisExist then FPosEx.dwFlags := FPosEx.dwFlags or JOY_RETURNV;

  //POV
  case FPovType of
    jptDirection: FPosEx.dwFlags := FPosEx.dwFlags or JOY_RETURNPOV;
    jptDegree   : FPosEx.dwFlags := FPosEx.dwFlags or JOY_RETURNPOVCTS;
  end;

  //Сглаживание осей
  if FAxisSmooth then FPosEx.dwFlags := FPosEx.dwFlags or JOY_USEDEADZONE;

  //Запросить значения
  if joyGetPosEx(FDriverID, @FPosEx) <> JOYERR_NOERROR then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_CantReadData, IntToStr(FDriverID)));

  //Поправить массив кнопок
  Mask := 1;
  c := Length(FBtnArray) - 1;
  for i := 0 to c do
    begin
    B := @FBtnArray[i];                                                                     //Адрес кнопки
    if B^.Down then Inc(B^.RepeatCount) else B^.RepeatCount := 0;                           //Повторы нажатий
    if (FPosEx.wButtons and Mask) = Mask then B^.Down := True else B^.Down := False;        //Нажатие кнопки
    if B^.Down and (B^.RepeatCount = 0) then B^.DownOnce := True else B^.DownOnce := False; //Однократное нажатие
    Mask := Mask shl 1;                                                                     //Сдвинуть бит влево
    end;
end;




end.




