{
Пакет             Simple Tools 1
Файл              StringArray.pas
Версия            1.5
Создан            14.05.2018
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Динамический массив строк

Доработать
                  Сделать разные способы сортировки
}

unit StringArray;

{$mode objfpc}{$H+}

interface

uses
  SysUtils;


const
  sa_StrDivider = #13#10;


type
  //Модификаторы поиска
  TSearchOptions = set of (soUnique, soCaseSensivity);

  //Способы сортировки
  TSortMode = (smBubble);

  //Направление сортировки
  TSortDirection = (sdForward, sdBackward);


  //Массив строк
  TStringArray = array of String;
  PStringArray = ^TStringArray;




procedure StringArray_Clear(P: PStringArray);
function 	StringArray_GetCount(P: PStringArray): Integer;
function 	StringArray_GetIdxByString(P: PStringArray; Str: String; Options: TSearchOptions = []): Integer;
function 	StringArray_Add(P: PStringArray; Str: String = ''; Options: TSearchOptions = []): Boolean;
procedure StringArray_Add(P, NewArraw: PStringArray; Options: TSearchOptions = []);
function 	StringArray_Insert(P: PStringArray; Idx: Integer; Str: String; Options: TSearchOptions = []): Boolean;
procedure StringArray_Insert(P, NewArray: PStringArray; Idx: Integer; Options: TSearchOptions = []);
function 	StringArray_Delete(P: PStringArray; Idx: Integer): Boolean;
function 	StringArray_Delete(P: PStringArray; Str: String; Options: TSearchOptions = []): Boolean;
function 	StringArray_Set(P: PStringArray; Idx: Integer; Str: String): Boolean;
function 	StringArray_Get(P: PStringArray; Idx: Integer; var ResultStr: String): Boolean;
function 	StringArray_ArrayToString(P: PStringArray; Divider: String = sa_StrDivider): String;
procedure StringArray_StringToArray(P: PStringArray; Str: String; Divider: String = sa_StrDivider);
function 	StringArray_SaveToFile(P: PStringArray; FileName: String; Divider: String = sa_StrDivider): Boolean;
function 	StringArray_LoadFromFile(P: PStringArray; FileName: String; Divider: String = sa_StrDivider): Boolean;
function 	StringArray_AppendToFile(P: PStringArray; FileName: String; Divider: String = sa_StrDivider): Boolean;
function 	StringArray_Equal(P: PStringArray; MinCount: Integer): Boolean;
procedure StringArray_Copy(PSrc, PDest: PStringArray; Options: TSearchOptions = []);
procedure StringArray_Remix(P: PStringArray; Count: Integer = -1);
procedure StringArray_Sort(P: PStringArray; Direction: TSortDirection = sdForward; Mode: TSortMode = smBubble);
function  StringArray_GetPart(P: PStringArray; Index: Integer; Default: String = ''): String;



implementation


{
Описание
  Очистить массив
Параметры
  P - Массив строк
}
procedure StringArray_Clear(P: PStringArray);
begin
  SetLength(P^, 0);
end;



{
Описание
  Вернуть количество строк
Параметры
  P - Массив строк
Результат
  Количество строк
}
function StringArray_GetCount(P: PStringArray): Integer;
begin
  Result := Length(P^);
end;



{
Описание
  Найти индекс строки в массиве
Параметры
  P       - Массив строк
  Str     - Строка для поиска
  Options - Модификаторы поиска
    soCaseSensivity - Учитывать регистр при поиске
Результат
  -1   - Строка не найдена
  >= 0 - Индекс строки1
Пояснение
}
function StringArray_GetIdxByString(P: PStringArray; Str: String; Options: TSearchOptions = []): Integer;
var
  c, i: Integer;
  S: String;
begin
  Result := -1;
  if not (soCaseSensivity in Options) then Str := LowerCase(Str);
  c := StringArray_GetCount(P) - 1;
  for i := 0 to c do
    begin
    if (soCaseSensivity in Options) then S := P^[i] else S := LowerCase(P^[i]);
    if Str = S then
      begin
      Result := i;
      Break;
      end;
    end;

end;



{
Описание
  Добавить строку в массив
Параметры
  P       - Массив строк
  Str     - Строка для поиска
  Options - Модификаторы поиска
    soUnique        - Добавлять только уникальные строки
    soCaseSensivity - Учитывать регистр при поиске
Результат
  True  - Добавлено
  False - Не добавлено
}
function StringArray_Add(P: PStringArray; Str: String = ''; Options: TSearchOptions = []): Boolean;
var
  c: Integer;
begin
  Result := False;
  if (soUnique in Options) and (StringArray_GetIdxByString(P, Str, Options) <> -1) then Exit;
  c := StringArray_GetCount(P);
  SetLength(P^, c + 1);
  P^[c] := Str;
  Result := True;
end;



{
Описание
  Добавить массив строк в массив строк :)
Параметры
  P        - Массив строк куда добавлять
  NewArray - Массив строк откуда брать
  Options - Модификаторы поиска
    soUnique        - Добавлять только уникальные строки
    soCaseSensivity - Учитывать регистр при поиске
}
procedure StringArray_Add(P, NewArraw: PStringArray; Options: TSearchOptions = []);
var
  i, c: Integer;
begin
  c := StringArray_GetCount(NewArraw) - 1;
  for i := 0 to c do
    StringArray_Add(P, NewArraw^[i], Options);
end;



{
Описание
  Вставить строку в массив по указанному индексу
Параметры
  P       - Массив строк
  Idx     - Индекс для вставки
  Str     - Строка для вставки
  Options - Модификаторы поиска
    soUnique        - Вставлять только уникальные строки
    soCaseSensivity - Учитывать регистр при поиске
Результат
  True  - Вставлено
  False - Не вставлено
}
function StringArray_Insert(P: PStringArray; Idx: Integer; Str: String; Options: TSearchOptions = []): Boolean;
var
  i, c: Integer;
begin
  Result := False;
  c := StringArray_GetCount(P);
  if (Idx < 0) or (Idx > c) then Exit;
  if (soUnique in Options) and (StringArray_GetIdxByString(P, Str, Options) <> -1) then Exit;
  SetLength(P^, c + 1);
  for i := c downto Idx + 1 do
    P^[i] := P^[i - 1];
  P^[Idx] := Str;
  Result := True;
end;



{
Описание
  Вставить массив строк в массив строк по указанному индексу
Параметры
  P        - Массив строк куда вставлять
  NewArray - Массив строк откуда брать
  Idx      - Индекс с которго вставлять
  Options - Модификаторы поиска
    soUnique        - Добавлять только уникальные строки
    soCaseSensivity - Учитывать регистр при поиске
}
procedure StringArray_Insert(P, NewArray: PStringArray; Idx: Integer; Options: TSearchOptions = []);
var
  i, c: Integer;
begin
  c := StringArray_GetCount(NewArray) - 1;
  for i := 0 to c do
    if StringArray_Insert(P, Idx, NewArray^[i], Options) then Inc(Idx);
end;



{
Описание
  Удалить строку из массива строк по индексу
Параметры
  P   - Массив строк
  Idx - Индекс для удаления
Результат
  True  - Удалено
  False - Не удалено
}
function StringArray_Delete(P: PStringArray; Idx: Integer): Boolean;
var
  i, c: Integer;
begin
  Result := False;
  c := StringArray_GetCount(P) - 1;
  if (Idx < 0) or (Idx > c) then Exit;
  for i := Idx to c - 1 do
    P^[i] := P^[i + 1];
  SetLength(P^, c);
  Result := True;
end;



{
Описание
  Удалить строку из массива строк по строке
Параметры
  P       - Массив строк
  Str     - Строка для удаления
  Options - Модификаторы работы
    soCaseSensivity - Учитывать регистр при поиске
Результат
  True  - Удалено
  False - Не удалено
}
function StringArray_Delete(P: PStringArray; Str: String; Options: TSearchOptions = []): Boolean;
var
  Idx: Integer;
begin
  Idx := StringArray_GetIdxByString(P, Str, Options);
  Result := StringArray_Delete(P, Idx);
end;



{
Описание
  Изменить строку в массива по индексу
Параметры
  P   - Массив строк
  Idx - Индекс для изменения
  Str - Новое значение
Результат
  True  - Удалено
  False - Не удалено
}
function StringArray_Set(P: PStringArray; Idx: Integer; Str: String): Boolean;
var
  c: Integer;
begin
  Result := False;
  c := StringArray_GetCount(P) - 1;
  if (Idx < 0) or (Idx > c) then Exit;
  P^[Idx] := Str;
  Result := True;
end;



{
Описание
  Узнать строку в массива по индексу
Параметры
  P   - Массив строк
  Idx - Индекс для чтения
  ResultStr - Результат функции при отсутствии ошибок
Результат
  True  - Найдено
  False - Не найдено
}
function StringArray_Get(P: PStringArray; Idx: Integer; var ResultStr: String): Boolean;
var
  c: Integer;
begin
  Result := False;
  c := StringArray_GetCount(P) - 1;
  if (Idx < 0) or (Idx > c) then Exit;
  ResultStr := P^[Idx];
  Result := True;
end;



{
Описание
  Объеденить массив в строку через разделитель
Параметры
  P       - Массив строк
  Divider - Разделитель между строк
Результат
  Массив в виде строки
}
function StringArray_ArrayToString(P: PStringArray; Divider: String = sa_StrDivider): String;
var
  i, c: Integer;
begin
  Result := '';
  c := StringArray_GetCount(P) - 1;
  for i := 0 to c do
    begin
    Result := Result + P^[i];
    if c <> i then Result := Result + Divider;
    end;
end;



{
Описание
  Преобразовать строку в массив через разделитель
Параметры
  P - Массив строк для записи результата
  Str - Строка для разбора
  Divider - Разделитель между строками
}
procedure StringArray_StringToArray(P: PStringArray; Str: String; Divider: String = sa_StrDivider);
var
  i, l: Integer;
  s: String;
begin
  StringArray_Clear(P);
  l := Length(Divider);
  repeat
  i := Pos(Divider, Str);
  if i > 0 then
    begin
    s := Copy(Str, 1, i - 1);
    StringArray_Add(P, s);
    Delete(Str, 1, i + l - 1);
    end;
  if (i = 0) and (Length(Str) > 0) then StringArray_Add(P, Str);
  until i <= 0;
end;



{
Описание
  Сохранить массив строк в файл
Параметры
  P        - Массив строк
  FileName - Имя файла
  Divider  - Разделитель для строк в файле
Результат
  False - Не сохранено
  True  - Сохранено
}
function StringArray_SaveToFile(P: PStringArray; FileName: String; Divider: String = sa_StrDivider): Boolean;
var
  Str: String;
  f: file of Char;
  Size: Integer;
begin
  Result := False;
  if not ForceDirectories(ExtractFilePath(FileName)) then Exit;
  Str := StringArray_ArrayToString(P, Divider);
  try
    AssignFile(f, FileName);
    Rewrite(f);
    Size := Length(Str);
    if Size > 0 then BlockWrite(f, Str[1], Size);
    CloseFile(f);
  except
    Exit;
  end;
  Result := True;
end;



{
Описание
  Прочитать строки из файла в массив
Параметры
  P        - Массив строк
  FileName - Имя файла
  Divider  - Разделитель для строк в файле
Результат
  False - Ошибка при чтении
  True  - Прочитано
}
function StringArray_LoadFromFile(P: PStringArray; FileName: String; Divider: String = sa_StrDivider): Boolean;
var
  Str: String;
  f: file of Char;
  Size: Integer;
begin
  Result := False;
  if not FileExists(FileName) then Exit;
  try
    AssignFile(f, FileName);
    Reset(f);
    Size := FileSize(f);
    SetLength(Str, Size);
    if Size > 0 then BlockRead(f, Str[1], Size);
    CloseFile(f);
  except
    SetLength(Str, 0);
    Exit;
  end;
  StringArray_StringToArray(P, Str, Divider);
  SetLength(Str, 0);  //Str := '';
  Result := True;
end;



{
Описание
  Дописать массив строк в конец файла
Параметры
  P        - Массив строк
  FileName - Имя файла
  Divider  - Разделитель для строк в файле
Результат
  False - Ошибка при чтении
  True  - Прочитано
}
function StringArray_AppendToFile(P: PStringArray; FileName: String; Divider: String = sa_StrDivider): Boolean;
var
  Str: String;
  f: file of Char;
  Size: Integer;
begin
  Result := False;
  if not ForceDirectories(ExtractFilePath(FileName)) then Exit;
  Str := StringArray_ArrayToString(P, Divider);
  if Length(Str) = 0 then Exit;
  try
    AssignFile(f, FileName);
    if not FileExists(FileName) then Rewrite(f) else Reset(f);
    Seek(f, FileSize(f));
    Size := Length(Str);
    if Size > 0 then BlockWrite(f, Str[1], Size);
    CloseFile(f);
  except
    Exit;
  end;
  Result := True;
end;



{
Описание
  Преверить, содержит ли массив минимальное количество строк
Параметры
  P        - Массив строк
  MinCount - Минимальное количество строк
Результат
  True  - Содержит
  False - Не содержит
}
function StringArray_Equal(P: PStringArray; MinCount: Integer): Boolean;
begin
  Result := (StringArray_GetCount(P) >= MinCount);
end;



{
Описание
  Скопировать элементы одного массива в другой
Параметры
  PSrc    - Массив строк источника
  PDest   - Массив строк приёмника
  Options - Модификаторы поиска
    soUnique        - Копировать только уникальные строки
    soCaseSensivity - Учитывать регистр при поиске
Результат
Пояснение
}
procedure StringArray_Copy(PSrc, PDest: PStringArray; Options: TSearchOptions = []);
var
  i, c: Integer;
begin
  c := StringArray_GetCount(PSrc) - 1;
  StringArray_Clear(PDest);
  for i := 0 to c do
    StringArray_Add(PDest, PSrc^[i], Options);
end;



{
Описание
  Перемешать элементы массива заданное количество раз
Параметры
  P - Массив строк
  Count - Количество операций перемены строк
Пояснение
  Ессли Count = -1, то количество операций равно половине длины массива
}
procedure StringArray_Remix(P: PStringArray; Count: Integer = -1);
var
  Idx1, Idx2, c, i: Integer;
  s: String;
begin
  c := StringArray_GetCount(P);
  if Count = -1 then Count := c div 2;
  for i := 0 to Count do
    begin
    Idx1 := Random(c);
    Idx2 := Random(c);
    s := P^[Idx1];
    P^[Idx1] := P^[Idx2];
    P^[Idx2] := s;
    end;
end;



{
Описание
  Упорядочить строки по алфавиту
Параметры
  P - Массив строк
  Direction - Направление
    sdForward - Прямое
    sdBackward - Обратное
  Mode - Способ упорядочивания
    smBubble - "Пузырьковый"
Пояснение
  По умолчанию все способы должны быть в прямом направлении.
  Пока только один единственный способ
}
procedure StringArray_Sort(P: PStringArray; Direction: TSortDirection = sdForward; Mode: TSortMode = smBubble);
var
  i, j, ci, cj: Integer;
  s: String;
begin
  //Выбор способа сортировки
  case Mode of
    smBubble:
      begin
      ci := StringArray_GetCount(P) - 1;
      cj := ci - 1;
      for i := 0 to ci do
        for j := 0 to cj do
          if P^[j] > P^[j + 1] then
            begin
            s := P^[j];
            P^[j] := P^[j + 1];
            P^[j + 1] := s;
            end;
      end;
  end;


  //Отразить сверху вниз
  ci := StringArray_GetCount(P) - 1;
  if (Direction = sdBackward) and (ci > 0) then
    begin
    cj := ci div 2;
    for i := 0 to cj do
      begin
      s := P^[i];
      P^[i] := P^[ci - i];
      P^[ci - i] := s;
      end;
    end;
end;


{
Описание
  Функция возвращает один элемент массива
Параметры
  P       - Массив строк
  Index   - Номер части
  Default - Значение по умолчанию
}
function StringArray_GetPart(P: PStringArray; Index: Integer; Default: String = ''): String;
var
  c: Integer;
begin
  c := StringArray_GetCount(P) - 1;
  if (Index < 0) or (Index > c) then Result := Default else Result := P^[Index];
end;





end.
