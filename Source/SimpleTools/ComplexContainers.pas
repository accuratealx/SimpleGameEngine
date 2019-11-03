{
Пакет             Simple Tools 1
Файл              ComplexContainers.pas
Версия            1.0
Создан            30.01.2019
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Cложное хранилище параметров
}

unit ComplexContainers;

{$mode objfpc}{$H+}

interface

uses
  StringArray, SimpleParameters, SimpleContainers;



function ComplexContainers_ReadSection(P: PSimpleParameters; FileName: String; Section: String): Boolean;
function ComplexContainers_WriteSection(P: PSimpleParameters; FileName: String; Section: String): Boolean;
function ComplexContainers_ReadValue(FileName: String; Section, Parameter: String; var Value: String): Boolean;
function ComplexContainers_WriteValue(FileName: String; Section, Parameter, Value: String): Boolean;



implementation




{
Описание
  Прочитать параметры со значением из секции
Параметры
  P     - Массив параметров для возврата результата
  FileName - Имя файла
  Sectinon - Имя секции для чтения
Результат
  True  - Прочтено
  False - Ошибка чтения
Пояснение:
}
function ComplexContainers_ReadSection(P: PSimpleParameters; FileName: String; Section: String): Boolean;
var
  Str: String;
begin
  Result := False;
  if not SimpleContainers_GetFromFile(FileName, Section, Str) then Exit;
  SimpleParameters_FromString(P, Str);
  Result := True;
end;


{
Описание
  Записать параметры со значением в секцию
Параметры
  P        - Массив параметров
  FileName - Имя файла
  Sectinon - Имя секции для записи
Результат
  True  - Записано
  False - Ошибка записи
Пояснение:
}
function ComplexContainers_WriteSection(P: PSimpleParameters; FileName: String; Section: String): Boolean;
var
  Str: String;
begin
  Result := False;
  Str := sa_StrDivider + SimpleParameters_ToString(P, True) + sa_StrDivider;
  if not SimpleContainers_SetInFile(FileName, Section, Str, [], True) then Result := True;
end;


{
Описание
  Прочитать значение параметра секции
Параметры
  FileName  - Имя файла
  Sectinon  - Имя секции
  Parameter - Имя параметра
  Value     - Результат
Результат
  True  - Прочтено
  False - Ошибка чтения
Пояснение:
}
function ComplexContainers_ReadValue(FileName: String; Section, Parameter: String; var Value: String): Boolean;
var
  sp: TSimpleParameters;
begin
  Result := False;
  if not ComplexContainers_ReadSection(@sp, FileName, Section) then Exit;
  if SimpleParameters_Get(@sp, Parameter, Value) then Result := True;
  SimpleParameters_Clear(@sp);
end;


{
Описание
  Записать значение параметра секции
Параметры
  FileName  - Имя файла
  Sectinon  - Имя секции
  Parameter - Имя параметра
  Value     - Новое значение
Результат
  True  - Записано
  False - Ошибка записи
Пояснение:
}
function ComplexContainers_WriteValue(FileName: String; Section, Parameter, Value: String): Boolean;
var
  sp: TSimpleParameters;
  Idx: Integer;
begin
  Result := False;
  ComplexContainers_ReadSection(@sp, FileName, Section);
  Idx := SimpleParameters_GetIdxByName(@sp, Parameter);
  if Idx = -1 then SimpleParameters_Add(@sp, Parameter, Value) else sp[Idx].Value := Value;
  if ComplexContainers_WriteSection(@sp, FileName, Section) then Result := True;
  SimpleParameters_Clear(@sp);
end;




end.

