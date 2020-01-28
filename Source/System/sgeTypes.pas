{
Пакет             Simple Game Engine 1
Файл              sgeTypes.pas
Версия            1.8
Создан            24.01.2018
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Типы простого игрового движка плюс пару функций
}

unit sgeTypes;

{$mode objfpc}{$H+}

interface

uses
  sgeConst, sgeSimpleParameters, sgeSimpleCommand, sgeGraphicColor,
  SysUtils;


type
  EsgeException = class(Exception)
  public
    constructor Create(ModuleName, Error: String; Info: String = ''; NewLine: String = '');
  end;


  //Приоритет основного процесса
  TsgePriority = (pIdle, pBelowNormal, pNormal, pAboveNormal, pHigh, pRealTime);


  //Кнопки мыши
  TsgeMouseButton = (mbLeft, mbMiddle, mbRight, mbExtra1, mbExtra2);
  TsgeMouseButtons = set of TsgeMouseButton;


  //Специальные кнопки клавиатуры
  TsgeKeyboardButton = (kbLeftAlt, kbRightAlt, kbLeftCtrl, kbRightCtrl, kbLeftShift, kbRightShift,
                        kbAlt, kbCtrl, kbShift, kbCapsLock, kbNumLock, kbScrollLock, kbInsert);
  TsgeKeyboardButtons = set of TsgeKeyboardButton;


  //Режим загрузки из файла Замена/Добавление
  TsgeLoadMode = (lmReplace, lmAdd);


  //Модификаторы поиска
  TsgeSearchOptions = set of (soUnique, soCaseSensivity);


  //Шляпа
  TsgeInterval = record
    Start: Integer;
    Stop: Integer;
  end;


  //Дробная точка
  TsgeGraphicPoint = record
    X: Single;
    Y: Single;
  end;


  //Дробный прямоугольник
  TsgeGraphicRect = record
    X1: Single;
    Y1: Single;
    X2: Single;
    Y2: Single;
  end;


  //Точка
  TsgePoint = record
    X: Integer;
    Y: Integer;
  end;


  //Прямоугольник
  TsgeRect = record
    X1: Integer;
    Y1: Integer;
    X2: Integer;
    Y2: Integer;
  end;





function  sgeGetTickCount: Int64;
function  sgeGetPerformanceCounter: Int64;

function  sgeCreateErrorString(ModuleName, Error: String; Info: String = ''; NewLine: String = ''): String;
function  sgeGetMouseButtonIdx(Buttons: TsgeMouseButtons): Byte;
function  sgeGetShellMaxVisibleLines(WindowHeight, FontHeight: Integer): Integer;
function  sgeGetShellBGRect(ScreenW, ScreenH: Single; ImageW, ImageH: Single): TsgeRect;
function  sgeGetGraphicPoint(X, Y: Single): TsgeGraphicPoint;
function  sgeGetGraphicRect(X1, Y1, X2, Y2: Single): TsgeGraphicRect;
function  sgeGetPoint(X, Y: Integer): TsgePoint;
function  sgeGetRect(X1, Y1, X2, Y2: Integer): TsgeRect;
function  sgeSubstituteParameterToString(Str: String; Parameters: TsgeSimpleParameters; OpenQuote: String = ''; CloseQuote: String = ''): String;

function  sgeGetUniqueFileName: String;

function  sgeGetOnOffFromParam(Command: TsgeSimpleCommand): Byte;
function  sgeGetRGBAFromParam(Command: TsgeSimpleCommand; StartIdx: Byte = 1): TsgeRGBA;
function  sgeGetRGBAAsStringByGraphicColor(Col: TsgeGraphicColor): String;
function  sgeGetPartFromCommand(Command: TsgeSimpleCommand; Part: Integer = 1): String;

function  sgeBinStringToHex(BinString: String): String;
function  sgeHexToBinString(HexStr: String): String;


var
  OneSecondFrequency: Int64;      //Тиков ядра в 1 секунде
  OneMillisecondFrequency: Int64; //Тиков ядра в 1 миллисекунде


implementation


uses
  Windows;


constructor EsgeException.Create(ModuleName, Error: String; Info: String; NewLine: String);
begin
  inherited Create(sgeCreateErrorString(ModuleName, Error, Info, NewLine));
end;





function sgeGetTickCount: Int64;
begin
  {$IfDef WINDOWS}
    {$IfDef WIN64}
      Result := Windows.GetTickCount64;
    {$Else}
      Result := Windows.GetTickCount;
    {$EndIf}
  {$EndIf}
end;


{$Hints Off}
function sgeGetPerformanceCounter: Int64;
begin
  QueryPerformanceCounter(Result);
end;
{$Hints On}


function sgeCreateErrorString(ModuleName, Error: String; Info: String = ''; NewLine: String = ''): String;
const
  ParamSeparator = ';';
  LineSeparator = #13#10;
begin
  Result := ModuleName + ParamSeparator + Error;
  if Info <> '' then Result := Result + ParamSeparator + Info;
  if NewLine <> '' then Result := Result + LineSeparator + NewLine;
end;


function sgeGetMouseButtonIdx(Buttons: TsgeMouseButtons): Byte;
begin
  Result := 0;
  if (mbLeft in Buttons) then Result := 0;
  if (mbMiddle in Buttons) then Result := 1;
  if (mbRight in Buttons) then Result := 2;
  if (mbExtra1 in Buttons) then Result := 3;
  if (mbExtra2 in Buttons) then Result := 4;
end;


function sgeGetShellMaxVisibleLines(WindowHeight, FontHeight: Integer): Integer;
begin
  Result := (WindowHeight - sge_ShellIndent * 3 - FontHeight) div FontHeight;
  if Result < 0 then Result := 0;
end;


//Возврат размеров фоновой картинки
function sgeGetShellBGRect(ScreenW, ScreenH: Single; ImageW, ImageH: Single): TsgeRect;
var
  scrR, imgR: Single;
begin
  scrR := ScreenW / ScreenH;
  imgR := ImageW / ImageH;

  if imgR > scrR then
    begin
    Result.Y1 := 0;
    Result.Y2 := Round(ImageH);
    Result.X2 := Round(ScreenW * ImageH / ScreenH);
    Result.X1 := Round((ImageW - Result.X2) / 2);
    end
    else begin
    Result.X1 := 0;
    Result.X2 := Round(ImageW);
    Result.Y2 := Round(ScreenH * ImageW / ScreenW);
    Result.Y1 := Round((ImageH - Result.Y2) / 2);
    end;
end;


function sgeGetGraphicPoint(X, Y: Single): TsgeGraphicPoint;
begin
  Result.X := X;
  Result.Y := Y;
end;


function sgeGetGraphicRect(X1, Y1, X2, Y2: Single): TsgeGraphicRect;
begin
  Result.X1 := X1;
  Result.Y1 := Y1;
  Result.X2 := X2;
  Result.Y2 := Y2;
end;


function sgeGetPoint(X, Y: Integer): TsgePoint;
begin
  Result.X := X;
  Result.Y := Y;
end;


function sgeGetRect(X1, Y1, X2, Y2: Integer): TsgeRect;
begin
  Result.X1 := X1;
  Result.Y1 := Y1;
  Result.X2 := X2;
  Result.Y2 := Y2;
end;



//Функция подставляет значения параметров в строку
function sgeSubstituteParameterToString(Str: String; Parameters: TsgeSimpleParameters; OpenQuote: String; CloseQuote: String): String;
var
  i, c: Integer;
begin
  Result := Str;
  c := Parameters.Count - 1;
  for i := 0 to c do
    Result := StringReplace(Result, OpenQuote + Parameters.Parameter[i].Name + CloseQuote, Parameters.Parameter[i].Value, [rfIgnoreCase, rfReplaceAll]);
end;


//Вернуть уникальное имя файла по времени
function sgeGetUniqueFileName: String;
begin
  Result := FormatDateTime('yyyy.mm.dd-hh.nn.ss', Now);
end;


{
Результат:
  0 - Нет прараметра
  1 - Невозможно определить значение
  2 - Включено
  3 - Выключено
}
function sgeGetOnOffFromParam(Command: TsgeSimpleCommand): Byte;
var
  s: String;
begin
  Result := 0;
  if Command.Count >= 2 then
    begin
    Result := 1;
    s := LowerCase(Command.Part[1]);
    if (s = 'on') or (s = 'yes') or (s = '1') or (s = 'true') or (s = 'enable') then Result := 2;
    if (s = 'off') or (s = 'no') or (s = '0') or (s = 'false') or (s = 'disable') then Result := 3;
    end;
end;


function sgeGetRGBAFromParam(Command: TsgeSimpleCommand; StartIdx: Byte): TsgeRGBA;
var
  i: Integer;
begin
  Result.Red := 0;
  Result.Green := 0;
  Result.Blue := 0;
  Result.Alpha := 255;
  if Command.Count >= StartIdx + 1 then if TryStrToInt(Command.Part[StartIdx + 0], i) then Result.Red := i;
  if Command.Count >= StartIdx + 2 then if TryStrToInt(Command.Part[StartIdx + 1], i) then Result.Green := i;
  if Command.Count >= StartIdx + 3 then if TryStrToInt(Command.Part[StartIdx + 2], i) then Result.Blue := i;
  if Command.Count >= StartIdx + 4 then if TryStrToInt(Command.Part[StartIdx + 3], i) then Result.Alpha := i;
end;


function sgeGetRGBAAsStringByGraphicColor(Col: TsgeGraphicColor): String;
var
  cl: TsgeRGBA;
begin
  cl := sgeGraphicColor_ColorToRGBA(Col);
  Result := IntToStr(cl.Red) + ' ' + IntToStr(cl.Green) + ' ' + IntToStr(cl.Blue) + ' ' + IntToStr(cl.Alpha);
end;


//Безопасно вернуть часть команды
function sgeGetPartFromCommand(Command: TsgeSimpleCommand; Part: Integer = 1): String;
begin
  Result := '';

  if Command.Count > Part then Result := Command.Part[Part];
end;


//Перевод бинарной строки в HEX (11111111 - FF)
{$Hints Off}
function sgeBinStringToHex(BinString: String): String;
var
  StrLen, TailCount, i, c, j, ResIdx: Integer;
  Str, HexStr: String;
  b: Byte;
begin
  //Выровнять длину строку кратно 8
  StrLen := Length(BinString);
  TailCount := StrLen mod 8;
  if TailCount <> 0 then
    begin
    TailCount := 8 - TailCount;
    SetLength(BinString, StrLen + TailCount);
    FillChar(BinString[StrLen + 1], TailCount, '0');
    end;

  //Подготовить строку с результатом
  StrLen := Length(BinString);
  SetLength(Result, StrLen div 4);

  //Пробежать по строке и выбрать по 8 символов
  c := (StrLen div 8) - 1;
  ResIdx := 1;
  for i := 0 to c do
    begin
    //Взять 8 символов
    Str := Copy(BinString, i * 8 + 1, 8);

    //Перевести строку в байт
    b := 0;
    for j := 1 to 8 do
      b := (b shl 1) or Byte(Str[j] <> '0');

    //Записать результат
    HexStr := IntToHex(b, 2);
    Result[ResIdx] := HexStr[1];
    Result[ResIdx + 1] := HexStr[2];
    Inc(ResIdx, 2);
    end;
end;
{$Hints On}


//Перевод строки HEX в бинарную строку (F0 - 11110000)
{$Hints Off}
function sgeHexToBinString(HexStr: String): String;
const
  HEXDIGIT = ['0'..'9', 'A'..'F'];
var
  StrLen, i, c, j, ResIdx: Integer;
  Str: String;
  b: Byte;
begin
  //Выровнять длину строки кратно 2
  StrLen := Length(HexStr);
  if StrLen mod 2 <> 0 then HexStr := HexStr + '0';

  //Подготовить строку результат
  StrLen := Length(HexStr);
  SetLength(Result, StrLen * 4);

  //Развернуть HEX строку
  ResIdx := 0;
  c := (StrLen div 2) - 1;
  for i := 0 to c do
    begin
    //Взять 2 символа
    Str := UpperCase(Copy(HexStr, i * 2 + 1, 2));
    if not (Str[1] in HEXDIGIT) then Str[1] := '0';
    if not (Str[2] in HEXDIGIT) then Str[2] := '0';
    b := StrToInt('$' + Str);

    //Развернуть байт в строку ANSI
    for j := 8 downto 1 do
      begin
      Result[ResIdx + j] := chr($30 + (b and 1));
      b := b shr 1;
      end;

    //Сместить индекс
    Inc(ResIdx, 8);
    end;
end;
{$Warnings On}





initialization
begin
  //Тиков в 1 секунде
  QueryPerformanceFrequency(OneSecondFrequency);

  //Тиков в 1 миллисекунде
  OneMillisecondFrequency := Round(OneSecondFrequency / 1000);
end;




end.

