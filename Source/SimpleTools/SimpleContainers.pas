{
Пакет             Simple Tools 1
Файл              SimpleContainers.pas
Версия            1.3
Создан            27.09.2018
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Простое хранилище параметров
}

unit SimpleContainers;

{$mode objfpc}{$H+}

interface

uses
  StringArray, SimpleParameters, SysUtils;


const
  sc_NamePrefix  = '#'; //Префикс имени
  sc_StapleOpen  = '{'; //Открывающая скобка
  sc_StapleClose = '}'; //Закрывающая скобка
  sc_Shield      = '`'; //Символ экранирования



function  SimpleContainers_ToString(P: PSimpleParameters): String;
procedure SimpleContainers_FromString(P: PSimpleParameters; Str: String);
function  SimpleContainers_SaveToFile(P: PSimpleParameters; FileName: String): Boolean;
function  SimpleContainers_LoadFromFile(P: PSimpleParameters; FileName: String): Boolean;
function  SimpleContainers_SetInFile(FileName: String; Name, Value: String; Options: TSearchOptions = []; AutoCreate: Boolean = False): Boolean;
function  SimpleContainers_GetFromFile(FileName: String; Name: String; var ResultValue: String; Options: TSearchOptions = []): Boolean;
function  SimpleContainers_UpdateInFile(P: PSimpleParameters; FileName: String; Options: TSearchOptions = []; AutoCreate: Boolean = False): Boolean;
function  SimpleContainers_UpdateFromFile(P: PSimpleParameters; FileName: String; Options: TSearchOptions = []; AutoCreate: Boolean = False): Boolean;



implementation



function SecureString(Str: String): String;
var
  i, c: Integer;
begin
  Result := '';
  c := Length(Str);
  for i := 1 to c do
    begin
    if (Str[i] = sc_Shield) or (Str[i] = sc_StapleClose) then Result := Result + sc_Shield;
    Result := Result + Str[i];
    end;
end;


function SaveStringToFile(FileName: String; Str: String): Boolean;
var
  F: file of Char;
  Size: Integer;
begin
  try
    AssignFile(F, FileName);
    Rewrite(F);
    Size := Length(Str);
    if Size > 0 then BlockWrite(F, Str[1], Size);
    CloseFile(F);
  except
    Result := False;
    Exit;
  end;
  Result := True;
end;


function LoadStringFromFile(FileName: String; var Str: String): Boolean;
var
  Size: Integer;
  F: file of Char;
begin
  try
    AssignFile(F, FileName);
    Reset(F);
    Size := FileSize(F);
    SetLength(Str, Size);
    if Size > 0 then BlockRead(F, Str[1], Size);
    CloseFile(F);
  except
    Result := False;
    Exit;
  end;
  Result := True;
end;





{
Описание
  Преобразовать массив параметров в строку
Параметры
  P - Массив параметров
Результат
  Строка с масивом параметров
}
function SimpleContainers_ToString(P: PSimpleParameters): String;
var
  i, c: Integer;
begin
  Result := '';
  c := SimpleParameters_GetCount(P) - 1;

  for i := 0 to c do
    begin
    Result := Result + sc_NamePrefix + P^[i].Name + sa_StrDivider + sc_StapleOpen + SecureString(P^[i].Value) + sc_StapleClose;
    if i <> c then Result := Result + sa_StrDivider + sa_StrDivider;
    end;
end;


{
Описание
  Преобразовать строку в массив параметров
Параметры
  P   - Массив параметров
  Str - Строка с параметрами
}
procedure SimpleContainers_FromString(P: PSimpleParameters; Str: String);
const
  cEmpty = 0;
  cNamePrefix = 1;
  cName = 2;
  cStapleOpen = 3;
  cValue = 4;
  cStapleClose = 5;
var
  i, Size: Integer;
  CurrentMode: Byte;
  ShieldMode: Boolean;
  B: Char;
  Name, Value: String;
begin
  //Подготовка переменных
  SimpleParameters_Clear(P);  //Почистить выходной массив
  CurrentMode := cEmpty;      //Режим
  ShieldMode := False;        //Режим экранирования
  Name := '';
  Value := '';

  //Обработка строки
  Size := Length(Str);
  for i := 1 to Size do
    begin
    B := Str[i];

    //Проверить на экран
    if not ShieldMode and (B = sc_Shield) then
      begin
      ShieldMode := True;
      Continue;
      end;

    //Определить тип символа
    if (CurrentMode = cEmpty) and (B = sc_NamePrefix) then CurrentMode := cNamePrefix;
    if (CurrentMode = cNamePrefix) and (B <> sc_NamePrefix) then CurrentMode := cName;
    if (CurrentMode = cName) and (B = sc_StapleOpen) then CurrentMode := cStapleOpen;
    if (CurrentMode = cStapleOpen) and (B <> sc_StapleOpen) then CurrentMode := cValue;
    if (CurrentMode = cValue) and (B = sc_StapleClose) and (not ShieldMode) then CurrentMode := cStapleClose;

    //Отключить режим экранирования
    ShieldMode := False;


    //Обработать символ
    case CurrentMode of
      cEmpty: Continue;                           //Пропуск символа
      cNamePrefix: Name := '';                    //Обнулить имя
      cName:
        begin
        if (B = #13) or (B = #10) then Continue;  //Пропустить перевод строки
        Name := Name + B;                         //Добавить символ к имени
        end;
      cStapleOpen: Value := '';                   //Обнулить значение
      cValue: Value := Value + B;
      cStapleClose:
        begin
        Name := Trim(Name);                       //Обрезать лишние символы в имени
        SimpleParameters_Add(P, Name, Value);     //Добавить в массив
        CurrentMode := cEmpty;                    //Переключить режим
        end;
    end;  //Case

    end;  //For
end;


{
Описание
  Сохранить массив простых параметров в файл
Параметры
  P        - Массив параметров
  FileName - Имя файла для сохранения
Результат
  True  - Сохранено
  False - Ошибка
}
function SimpleContainers_SaveToFile(P: PSimpleParameters; FileName: String): Boolean;
var
  Str: String;
begin
  Str := SimpleContainers_ToString(P);
  Result := SaveStringToFile(FileName, Str);
end;


{
Описание
  Прочитать массив простых параметров из файла
Параметры
  P        - Массив параметров для сохранения результата
  FileName - Имя файла для сохранения
Результат
  True  - Прочтено
  False - Ошибка
}
function SimpleContainers_LoadFromFile(P: PSimpleParameters; FileName: String): Boolean;
var
  Str: String;
begin
  Result := LoadStringFromFile(FileName, Str);
  if Result then SimpleContainers_FromString(P, Str);
end;


{
Описание
  Изменить значение параметра в файле не изменяя форматирование
Параметры
  FileName   - Имя файла
  Name       - Имя параметра
  Value      - Новое значение
  Options    - Модификатор работы
    soCaseSensivity - Учитывать регистр при поиске
  AutoCreate - Записывать параметр в файл при отсутствии
Результат
  True  - Обновлено
  False - Не обновлено
}
function SimpleContainers_SetInFile(FileName: String; Name, Value: String; Options: TSearchOptions = []; AutoCreate: Boolean = False): Boolean;
var
  Str, S, lName: String;
  Size, Idx, i, i1, i2, cnt: Integer;
  NeedUpdate, Ctrl: Boolean;
begin
  Result := False;

  //Чтение файла
  LoadStringFromFile(FileName, Str);

  //Предусмотреть регистр поиска
  if soCaseSensivity in Options then
    begin
    S := Str;
    lName := Name;
    end
    else begin
    S := LowerCase(Str);
    lName := LowerCase(Name);
    end;

  //Поиск параметра
  NeedUpdate := False;
  Size := Length(Str);
  Idx := Pos(sc_NamePrefix + lName, S);
  if Idx > 0 then
    begin
    i1 := Idx + Length(sc_NamePrefix + lName);
    //Поиск открывающей скобки
    for i := i1 to Size do
      begin
      if S[i] = sc_NamePrefix then Break; //Найден новый параметр, что-то не так
      if S[i] = sc_StapleOpen then
        begin
        i1 := i;
        Break;
        end;
      end;
    //Поиск Закрывающей скобки
    Ctrl := False;
    i2 := i1;
    for i := i1 to Size do
      begin
      if S[i] = sc_Shield then
        begin
        Ctrl := True;
        Continue;
        end;
      if S[i] = sc_NamePrefix then Break;
      if (not Ctrl) and (S[i] = sc_StapleClose) then
        begin
        i2 := i;
        Break;
        end;
      Ctrl := False;
      end;
    //Изменить строку
    cnt := i2 - i1;
    if S[i2] = sc_StapleClose then Inc(cnt);  //Заплатка
    Delete(Str, i1, cnt);
    Insert(sc_StapleOpen + SecureString(Value) + sc_StapleClose, Str, i1);
    NeedUpdate := True;
    end
    else begin
    //Проверить автодобавление
    if AutoCreate then
      begin
      if Size > 0 then Str := Str + sa_StrDivider + sa_StrDivider;
      Str := Str + sc_NamePrefix + Name + sa_StrDivider + sc_StapleOpen + SecureString(Value) + sc_StapleClose;
      NeedUpdate := True;
      end;
    end;

  //Запись в файл
  if NeedUpdate then Result := SaveStringToFile(FileName, Str);
end;


{
Описание
  Прочиатть значение параметра из файла
Параметры
  FileName    - Имя файла
  Name        - Имя параметра
  ResultValue - Результат функции
  Options     - Модификатор работы
    soCaseSensivity - Учитывать регистр при поиске
Результат
  True  - Обновлено
  False - Не обновлено
Пояснение:
}
function SimpleContainers_GetFromFile(FileName: String; Name: String; var ResultValue: String; Options: TSearchOptions = []): Boolean;
var
  sp: TSimpleParameters;
begin
  Result := False;
  if not SimpleContainers_LoadFromFile(@sp, FileName) then Exit;
  Result := SimpleParameters_Get(@sp, Name, ResultValue, Options);
  SimpleParameters_Clear(@sp);
end;


{
Описание
  Обновить параметры в файле не изменяя форматирования
Параметры
  P          - Массив параметров
  FileName   - Имя файла
  Options    - Модификатор работы
    soCaseSensivity - Учитывать регистр при поиске
  AutoCreate - Записывать параметр в файл при отсутствии
Результат
  True  - Обновлено
  False - Не обновлено
}
function SimpleContainers_UpdateInFile(P: PSimpleParameters; FileName: String; Options: TSearchOptions = []; AutoCreate: Boolean = False): Boolean;
var
  Str, S, lName: String;
  Size, Idx, i, j, k, i1, i2, cnt: Integer;
  NeedUpdate, Ctrl: Boolean;
begin
  Result := False;
  NeedUpdate := False;

  //Чтение файла
  LoadStringFromFile(FileName, Str);

  //Цикл по параметрам
  k := SimpleParameters_GetCount(P) - 1;
  for j := 0 to k do
    begin
    //Предусмотреть регистр поиска
    if soCaseSensivity in Options then
      begin
      S := Str;
      lName := P^[j].Name;
      end
      else begin
      S := LowerCase(Str);
      lName := LowerCase(P^[j].Name);
      end;
    Size := Length(Str);

    //Поиск параметра
    Idx := Pos(sc_NamePrefix + lName, S);
    if Idx > 0 then
      begin
      i1 := Idx + Length(sc_NamePrefix + lName);
      //Поиск открывающей скобки
      for i := i1 to Size do
        begin
        if S[i] = sc_NamePrefix then Break; //Найден новый параметр, что-то не так
        if S[i] = sc_StapleOpen then
          begin
          i1 := i;
          Break;
          end;
        end;
      //Поиск Закрывающей скобки
      Ctrl := False;
      i2 := i1;
      for i := i1 to Size do
        begin
        if S[i] = sc_Shield then
          begin
          Ctrl := True;
          Continue;
          end;
        if S[i] = sc_NamePrefix then Break;
        if (not Ctrl) and (S[i] = sc_StapleClose) then
          begin
          i2 := i;
          Break;
          end;
        Ctrl := False;
        end;
      //Изменить строку
      cnt := i2 - i1;
      if S[i2] = sc_StapleClose then Inc(cnt);  //Заплатка
      Delete(Str, i1, cnt);
      Insert(sc_StapleOpen + SecureString(P^[j].Value) + sc_StapleClose, Str, i1);
      NeedUpdate := True;
      end
      else begin
      //Проверить автодобавление
      if AutoCreate then
        begin
        if Size > 0 then Str := Str + sa_StrDivider + sa_StrDivider;
        Str := Str + sc_NamePrefix + P^[j].Name + sa_StrDivider + sc_StapleOpen + SecureString(P^[j].Value) + sc_StapleClose;
        NeedUpdate := True;
        end;
      end;
    end; //for

  //Запись в файл
  if NeedUpdate then Result := SaveStringToFile(FileName, Str);
end;


{
Описание
  Обновить значения параметров в массиве из файла
Параметры
  P          - Массив параметров
  FileName   - Имя файла
  Options    - Модификатор работы
    soCaseSensivity - Учитывать регистр при поиске
  AutoCreate - Записывать параметр в массив при отсутствии в файле
Результат
  True  - Обновлено
  False - Не обновлено
}
function SimpleContainers_UpdateFromFile(P: PSimpleParameters; FileName: String; Options: TSearchOptions = []; AutoCreate: Boolean = False): Boolean;
var
  sp: TSimpleParameters;
  i, c, Idx: Integer;
begin
  Result := False;
  if not SimpleContainers_LoadFromFile(@sp, FileName) then Exit;
  c := SimpleParameters_GetCount(@sp) - 1;
  for i := 0 to c do
    begin
    Idx := SimpleParameters_GetIdxByName(P, sp[i].Name, Options); //Найти параметр в массиве
    if Idx >= 0 then P^[Idx].Value := sp[i].Value else            //Если найден, то обновить значение
      if AutoCreate then SimpleParameters_Add(P, sp[i]);          //Если нет, добавить при AutoCreate
    end;
  SimpleParameters_Clear(@sp);
  Result := False;
end;



end.

