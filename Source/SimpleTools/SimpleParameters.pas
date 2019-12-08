{
Пакет             Simple Tools 1
Файл              SimpleParameters.pas
Версия            1.2
Создан            26.05.2018
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Массив параметров

Доделать
                  Проверить на ошибки в процессе использования
}

unit SimpleParameters;

{$mode objfpc}{$H+}{$Hints Off}


interface

uses
  StringArray, SimpleCommand, SysUtils;


const
  sp_Commentary = '#'; //Заметка
  sp_Divider    = '='; //Разделитель между именем и значением
  sp_Staple     = #39; //Символ скобки
  sp_Control    = '`'; //Экран


type
  TSimpleParam = record
    Name: String;
    Value: String;
  end;
  PSimpleParam = ^TSimpleParam;


  TSimpleParameters = array of TSimpleParam;
  PSimpleParameters = ^TSimpleParameters;




procedure SimpleParameters_Clear(P: PSimpleParameters);
function 	SimpleParameters_GetCount(P: PSimpleParameters): Integer;
function 	SimpleParameters_GetIdxByName(P: PSimpleParameters; Name: String; Options: TSearchOptions = []): Integer;
function 	SimpleParameters_GetNameByIdx(P: PSimpleParameters; Index: Integer; var ResultStr: String): Boolean;
function 	SimpleParameters_Add(P: PSimpleParameters; Name, Value: String; Options: TSearchOptions = []): Boolean;
function 	SimpleParameters_Add(P: PSimpleParameters; Prm: TSimpleParam; Options: TSearchOptions = []): Boolean;
procedure SimpleParameters_Add(PDst, PSrc: PSimpleParameters; Options: TSearchOptions = []);
function 	SimpleParameters_Insert(P: PSimpleParameters; Index: Integer; Name, Value: String; Options: TSearchOptions = []): Boolean;
function 	SimpleParameters_Insert(P: PSimpleParameters; Index: Integer; Prm: TSimpleParam; Options: TSearchOptions = []): Boolean;
procedure SimpleParameters_Insert(PDst, PSrc: PSimpleParameters; Index: Integer; Options: TSearchOptions = []);
function 	SimpleParameters_Delete(P: PSimpleParameters; Index: Integer): Boolean;
function 	SimpleParameters_Delete(P: PSimpleParameters; Name: String; Options: TSearchOptions = []): Boolean;
function 	SimpleParameters_Set(P: PSimpleParameters; Index: Integer; Name, Value: String): Boolean;
function 	SimpleParameters_Set(P: PSimpleParameters; Index: Integer; Prm: TSimpleParam): Boolean;
function 	SimpleParameters_Set(P: PSimpleParameters; Name, Value: String; Options: TSearchOptions = []): Boolean;
function 	SimpleParameters_Set(P: PSimpleParameters; Name: String; Value: Integer; Options: TSearchOptions = []): Boolean;
function 	SimpleParameters_Set(P: PSimpleParameters; Name: String; Value: Real; Options: TSearchOptions = []): Boolean;
function 	SimpleParameters_Set(P: PSimpleParameters; Name: String; Value: Boolean; TrueStr: String = 'True'; FalseStr: String = 'False'; Options: TSearchOptions = []): Boolean;
function 	SimpleParameters_Get(P: PSimpleParameters; Index: Integer; var ResultName, ResultValue: String): Boolean;
function 	SimpleParameters_Get(P: PSimpleParameters; Index: Integer; var ResultPrm: TSimpleParam): Boolean;
function 	SimpleParameters_Get(P: PSimpleParameters; Name: String; var ResultValue: String; Options: TSearchOptions = []): Boolean;
function 	SimpleParameters_Get(P: PSimpleParameters; Name: String; var ResultValue: Integer; Options: TSearchOptions = []): Boolean;
function 	SimpleParameters_Get(P: PSimpleParameters; Name: String; var ResultValue: Real; Options: TSearchOptions = []): Boolean;
function 	SimpleParameters_Get(P: PSimpleParameters; Name: String; var ResultValue: Boolean; TrueStr: String = 'True'; Options: TSearchOptions = []): Boolean;
procedure SimpleParameters_ToStringArray(P: PSimpleParameters; StrArray: PStringArray; UseIndent: Boolean = True);
procedure SimpleParameters_FromStringArray(P: PSimpleParameters; StrArray: PStringArray);
function 	SimpleParameters_ToString(P: PSimpleParameters; UseIndent: Boolean = True; Divider: String = sa_StrDivider): String;
procedure SimpleParameters_FromString(P: PSimpleParameters; Str: String; Divider: String = sa_StrDivider);
function 	SimpleParameters_SaveToFile(P: PSimpleParameters; FileName: String; UseIndent: Boolean = True; Divider: String = sa_StrDivider): Boolean;
function 	SimpleParameters_LoadFromFile(P: PSimpleParameters; FileName: String; Divider: String = sa_StrDivider): Boolean;
function 	SimpleParameters_SetInFile(FileName: String; Name, Value: String; UseIndent: Boolean = True; Options: TSearchOptions = []; Divider: String = sa_StrDivider; AutoCreate: Boolean = False): Boolean;
function 	SimpleParameters_SetInFile(FileName: String; Name: String; Value: Integer; UseIndent: Boolean = True; Options: TSearchOptions = []; Divider: String = sa_StrDivider; AutoCreate: Boolean = False): Boolean;
function 	SimpleParameters_SetInFile(FileName: String; Name: String; Value: Real; UseIndent: Boolean = True; Options: TSearchOptions = []; Divider: String = sa_StrDivider; AutoCreate: Boolean = False): Boolean;
function 	SimpleParameters_SetInFile(FileName: String; Name: String; Value: Boolean; TrueStr: String = 'True'; FalseStr: String = 'False'; UseIndent: Boolean = True; Options: TSearchOptions = []; Divider: String = sa_StrDivider; AutoCreate: Boolean = False): Boolean;
function 	SimpleParameters_GetFromFile(FileName: String; Name: String; var ResultValue: String; Options: TSearchOptions = []; Divider: String = sa_StrDivider): Boolean;
function 	SimpleParameters_GetFromFile(FileName: String; Name: String; var ResultValue: Integer; Options: TSearchOptions = []; Divider: String = sa_StrDivider): Boolean;
function 	SimpleParameters_GetFromFile(FileName: String; Name: String; var ResultValue: Real; Options: TSearchOptions = []; Divider: String = sa_StrDivider): Boolean;
function 	SimpleParameters_GetFromFile(FileName: String; Name: String; var ResultValue: Boolean; TrueStr: String = 'True'; Options: TSearchOptions = []; Divider: String = sa_StrDivider): Boolean;
function 	SimpleParameters_UpdateInFile(P: PSimpleParameters; FileName: String; UseIndent: Boolean = True; Options: TSearchOptions = []; Divider: String = sa_StrDivider; AutoCreate: Boolean = False): Boolean;
function 	SimpleParameters_UpdateFromFile(P: PSimpleParameters; FileName: String; Options: TSearchOptions = []; Divider: String = sa_StrDivider; AutoCreate: Boolean = False): Boolean;





implementation




{
Описание
  Очистить массив
Параметры
  P - Массив параметров
}
procedure SimpleParameters_Clear(P: PSimpleParameters);
begin
  SetLength(P^, 0);
end;



{
Описание
  Узнать количество параметров в массиве
Параметры
  P - Массив параметров
Результат
  Количество параметров
Пояснение
}
function SimpleParameters_GetCount(P: PSimpleParameters): Integer;
begin
  Result := Length(P^);
end;



{
Описание
  Поиск индекса параметра в массиве по имени
Параметры
  P       - Массив параметров
  Name    - Имя для поиска
  Options - Модификаторы работы
    soCaseSensivity - Учитывать регистр при поиске
Результат
  -1   - Имя не найдено
  >= 0 - Индекс
Пояснение
}
function SimpleParameters_GetIdxByName(P: PSimpleParameters; Name: String; Options: TSearchOptions = []): Integer;
var
  i, c: Integer;
  S: String;
begin
  Result := -1;                                                     //По умолчанию - индекс не найден
  if not (soCaseSensivity in Options) then Name := LowerCase(Name); //Перевести в нижний регистр если не нужно учитывать регистр
  c := SimpleParameters_GetCount(P) - 1;                            //Сколько параметров в массиве
  for i := 0 to c do                                                //Пробежать по параметрам
    begin
    if (soCaseSensivity in Options) then
      S := P^[i].Name else S := LowerCase(P^[i].Name);              //Поправить регистр в зависимости от модификатора
    if Name = S then                                                //Сравнить искомое имя и имя текущего параметра
      begin
      Result := i;                                                  //Вернуть индекс
      Break;                                                        //Оборвать цикл
      end;
    end;
end;



{
Описание
  Узнать имя парметра по индексу в массиве
Параметры
  P         - Массив параметров
  Index     - Номер в массиве
  ResultStr - Результат при отсутствии ошибок
Результат
  True  - Найдено
  False - Не найдено
Пояснение
}
function SimpleParameters_GetNameByIdx(P: PSimpleParameters; Index: Integer; var ResultStr: String): Boolean;
var
  c: Integer;
begin
  Result := False;
  c := SimpleParameters_GetCount(P) - 1;    //Последний индекс массива
  if (Index < 0) or (Index > c) then Exit;  //Индекс вне диапазона массива, выход
  ResultStr := P^[Index].Name;              //Вернуть имя
  Result := True;
end;



{
Описание
  Добавить параметр в массив
Параметры
  P       - Массив параметров
  Name    - Имя параметра
  Value   - Значение параметра
  Options - Модификаторы работы
    soUnique        - Только уникальные строки
    soCaseSensivity - Учитывать регистр при поиске
Результат
  True  - Добавлено
  False - Не добавлено
}
function SimpleParameters_Add(P: PSimpleParameters; Name, Value: String; Options: TSearchOptions = []): Boolean;
var
  c: Integer;
begin
  Result := False;
  if (soUnique in Options) and (SimpleParameters_GetIdxByName(P, Name, Options) <> -1) then Exit; //Если добавлять уникальные и найден параметр, то выйти
  c := SimpleParameters_GetCount(P);  //Сколько всего параметров
  SetLength(P^, c + 1);               //Добавить параметр
  P^[c].Name := Name;                 //Записать имя
  P^[c].Value := Value;               //Записать значение
  Result := True;
end;



{
Описание
  Добавить параметр в массив
Параметры
  P       - Массив параметров
  Prm     - Параметр
  Options - Модификаторы работы
    soUnique        - Только уникальные строки
    soCaseSensivity - Учитывать регистр при поиске
Результат
  True  - Добавлено
  False - Не добавлено
}
function SimpleParameters_Add(P: PSimpleParameters; Prm: TSimpleParam; Options: TSearchOptions = []): Boolean;
begin
  Result := SimpleParameters_Add(P, Prm.Name, Prm.Value, Options);
end;



{
Описание
  Добавить параметр в массив
Параметры
  PDst    - Массив в который копируются новые параметры
  PSrc    - Массив из которого копируются новые параметры
  Options - Модификаторы работы
    soUnique        - Только уникальные строки
    soCaseSensivity - Учитывать регистр при поиске
}
procedure SimpleParameters_Add(PDst, PSrc: PSimpleParameters; Options: TSearchOptions = []);
var
  c, i: Integer;
begin
  c := SimpleParameters_GetCount(PSrc) - 1;         //Сколько всего параметров нужно добавить
  for i := 0 to c do
    SimpleParameters_Add(PDst, PSrc^[i], Options);  //Добавить параметр с модификаторами
end;



{
Описание
  Вставить параметр в массив по указанному индексу
Параметры
  P       - Массив параметров
  Index   - Индекс в массиве для вставки
  Name    - Имя параметра
  Value   - Значение параметра
  Options - Модификаторы работы
    soUnique        - Только уникальные строки
    soCaseSensivity - Учитывать регистр при поиске
Результат
  True  - Вставлено
  False - Не вставлено
}
function SimpleParameters_Insert(P: PSimpleParameters; Index: Integer; Name, Value: String; Options: TSearchOptions = []): Boolean;
var
  i, c: Integer;
begin
  Result := False;
  c := SimpleParameters_GetCount(P);        //Сколько всего параметров
  if (Index < 0) or (Index > c) then Exit;  //Индекс вне диапазона массива
  if (soUnique in Options) and (SimpleParameters_GetIdxByName(P, Name, Options) <> -1) then Exit; //Если вставлять уникальные и найден параметр, то выйти
  SetLength(P^, c + 1);                     //Добавить в конец массива параметр
  for i := c downto Index + 1 do            //Сдвинуть вправо все праметры от Index до конца массива
    P^[i] := P^[i - 1];
  P^[Index].Name := Name;                   //Изменить в нужном месте имя
  P^[Index].Value := Value;                 //Изменить в нужном месте значение
  Result := True;
end;



{
Описание
  Вставить параметр в массив по указанному индексу
Параметры
  P       - Массив параметров
  Prm     - Параметр
  Value   - Значение параметра
  Options - Модификаторы работы
    soUnique        - Только уникальные строки
    soCaseSensivity - Учитывать регистр при поиске
Результат
  True  - Вставлено
  False - Не вставлено
}
function SimpleParameters_Insert(P: PSimpleParameters; Index: Integer; Prm: TSimpleParam; Options: TSearchOptions = []): Boolean;
begin
  Result := SimpleParameters_Insert(P, Index, Prm.Name, Prm.Value, Options);
end;



{
Описание
  Вставить массив параметров в массив параметров
Параметры
  PDst    - Массив в который вставляются новые параметры
  PSrc    - Массив из которого вставляются новые параметры
  Index   - Начальный индекс для вставки
  Options - Модификаторы работы
    soUnique        - Только уникальные строки
    soCaseSensivity - Учитывать регистр при поиске
}
procedure SimpleParameters_Insert(PDst, PSrc: PSimpleParameters; Index: Integer; Options: TSearchOptions = []);
var
  i, c: Integer;
begin
  c := SimpleParameters_GetCount(PSrc) - 1; //Сколько параметров нужно вставить
  for i := 0 to c do
    if SimpleParameters_Insert(PDst, Index, PSrc^[i], Options) then Inc(Index); //Если всавка успешная, подвинуть индекс вправо на 1
end;



{
Описание
  Удалить параметр из массива по индексу
Параметры
  P     - Массив параметров
  Index - Индекс для удаления
Результат
  True  - Удалено
  False - Не удалено
}
function SimpleParameters_Delete(P: PSimpleParameters; Index: Integer): Boolean;
var
  i, c: Integer;
begin
  Result := False;
  c := SimpleParameters_GetCount(P) - 1;    //Сколько всего параметров
  if (Index < 0) or (Index > c) then Exit;  //Индекс вне диапазона массива
  for i := Index to c - 1 do                //Сдвинуть все параметры влево на 1 от Index до конца массива
    P^[i] := P^[i + 1];
  SetLength(P^, c);                         //Обрезать последний параметр
  Result := True;
end;



{
Описание
  Удалить параметр из массива по имени
Параметры
  P       - Массив параметров
  Name    - Имя для удаления
  Options - Модификаторы работы
    soCaseSensivity - Учитывать регистр при поиске
Результат
  True  - Удалено
  False - Не удалено
}
function SimpleParameters_Delete(P: PSimpleParameters; Name: String; Options: TSearchOptions = []): Boolean;
var
  Index: Integer;
begin
  Index := SimpleParameters_GetIdxByName(P, Name, Options); //Найти индекс параметра по имени
  Result := SimpleParameters_Delete(P, Index);              //Удалить по индексу
end;



{
Описание
  Изменить параметр в массиве по индексу
Параметры
  P     - Массив параметров
  Index - Индекс в массиве
  Name  - Имя
  Value - Значение
Результат
  True  - Изменено
  False - Не изменено
}
function SimpleParameters_Set(P: PSimpleParameters; Index: Integer; Name, Value: String): Boolean;
var
  c: Integer;
begin
  Result := False;
  c := SimpleParameters_GetCount(P) - 1;    //Индекс последнего параметра в массиве
  if (Index < 0) or (Index > c) then Exit;  //Индекс вне диапазона массива
  P^[Index].Name := Name;                   //Изменить имя
  P^[Index].Value := Value;                 //Изменить значение
  Result := True;
end;



{
Описание
  Изменить параметр в массиве по индексу
Параметры
  P     - Массив параметров
  Index - Индекс в массиве
  Prm   - Параметр
Результат
  True  - Изменено
  False - Не изменено
}
function SimpleParameters_Set(P: PSimpleParameters; Index: Integer; Prm: TSimpleParam): Boolean;
begin
  Result := SimpleParameters_Set(P, Index, Prm.Name, Prm.Value);
end;



{
Описание
  Изменить параметр в массиве по имени
Параметры
  P     - Массив параметров
  Name  - Имя для поиска
  Value - Новое значение
  Options - Модификаторы работы
    soCaseSensivity - Учитывать регистр при поиске
Результат
  True  - Изменено
  False - Не изменено
}
function SimpleParameters_Set(P: PSimpleParameters; Name, Value: String; Options: TSearchOptions = []): Boolean;
var
  Index: Integer;
begin
  Index := SimpleParameters_GetIdxByName(P, Name, Options); //Найти индекс параметра в массиве
  Result := SimpleParameters_Set(P, Index, Name, Value);    //Изменить по индексу
end;



{
Описание
  Изменить параметр в массиве по имени
Параметры
  P     - Массив параметров
  Name  - Имя для поиска
  Value - Новое значение
  Options - Модификаторы работы
    soCaseSensivity - Учитывать регистр при поиске
Результат
  True  - Изменено
  False - Не изменено
}
function SimpleParameters_Set(P: PSimpleParameters; Name: String; Value: Integer; Options: TSearchOptions = []): Boolean;
begin
  Result := SimpleParameters_Set(P, Name, IntToStr(Value), Options);
end;



{
Описание
  Изменить параметр в массиве по имени
Параметры
  P     - Массив параметров
  Name  - Имя для поиска
  Value - Новое значение
  Options - Модификаторы работы
    soCaseSensivity - Учитывать регистр при поиске
Результат
  True  - Изменено
  False - Не изменено
}
function SimpleParameters_Set(P: PSimpleParameters; Name: String; Value: Real; Options: TSearchOptions = []): Boolean;
begin
  Result := SimpleParameters_Set(P, Name, FloatToStr(Value), Options);
end;



{
Описание
  Изменить параметр в массиве по имени
Параметры
  P        - Массив параметров
  Name     - Имя для поиска
  Value    - Новое значение
  TrueStr  - Строковое представление истины
  FalseStr - Строковое представление ереси :)
  Options  - Модификаторы работы
    soCaseSensivity - Учитывать регистр при поиске
Результат
  True  - Изменено
  False - Не изменено
}
function SimpleParameters_Set(P: PSimpleParameters; Name: String; Value: Boolean; TrueStr: String = 'True'; FalseStr: String = 'False'; Options: TSearchOptions = []): Boolean;
var
  S: String;
begin
  if Value then S := TrueStr else S := FalseStr;        //Подготовить строку отражающую значение
  Result := SimpleParameters_Set(P, Name, S, Options);  //Изменить значение параметра по имени
end;



{
Описание
  Взять имя и значение параметра из массива по индексу
Параметры
  P           - Массив параметров
  Index       - Индекс
  ResultName  - Результат работы, Имя
  ResultValue - Результат работы, Значение
Результат
  True  - Найдено
  False - Не найдено
}
function SimpleParameters_Get(P: PSimpleParameters; Index: Integer; var ResultName, ResultValue: String): Boolean;
var
  c: Integer;
begin
  Result := False;
  c := SimpleParameters_GetCount(P) - 1;    //Индекс последнего параметра
  if (Index < 0) or (Index > c) then Exit;  //Индекс вне диапазона массива
  ResultName := P^[Index].Name;             //Вернуть имя
  ResultValue := P^[Index].Value;           //Вернуть значение
  Result := True;
end;



{
Описание
  Взять параметр из массива по индексу
Параметры
  P         - Массив параметров
  Index     - Индекс
  ResultPrm - Результат работы, Параметр
Результат
  True  - Найдено
  False - Не найдено
}
function SimpleParameters_Get(P: PSimpleParameters; Index: Integer; var ResultPrm: TSimpleParam): Boolean;
var
  c: Integer;
begin
  Result := False;
  c := SimpleParameters_GetCount(P) - 1;    //Индекс последнего параметра
  if (Index < 0) or (Index > c) then Exit;  //Индекс вне диапазона массива
  ResultPrm := P^[Index];                   //Вернуть запись
  Result := True;
end;



{
Описание
  Взять значение параметра из массива по имени
Параметры
  P           - Массив параметров
  Name        - Имя для поиска
  ResultValue - Результат работы, Значение
  Options     - Модификаторы работы
    soCaseSensivity - Учитывать регистр при поиске
Результат
  True  - Найдено
  False - Не найдено
}
function SimpleParameters_Get(P: PSimpleParameters; Name: String; var ResultValue: String; Options: TSearchOptions = []): Boolean;
var
  Index: Integer;
begin
  Result := False;
  Index := SimpleParameters_GetIdxByName(P, Name, Options); //Найти индекс параметра в массиве
  if Index = -1 then Exit;                                  //Индекс не найден
  ResultValue := P^[Index].Value;                           //Вернуть значение
  Result := True;
end;



{
Описание
  Взять значение параметра из массива по имени
Параметры
  P           - Массив параметров
  Name        - Имя для поиска
  ResultValue - Результат работы, Значение
  Options     - Модификаторы работы
    soCaseSensivity - Учитывать регистр при поиске
Результат
  True  - Найдено
  False - Не найдено
Дополнительно
  Функция возвращает False если произошла ошибка преобразования
}
function SimpleParameters_Get(P: PSimpleParameters; Name: String; var ResultValue: Integer; Options: TSearchOptions = []): Boolean;
var
  rs: Integer;
  s: String;
begin
  Result := False;
  if not SimpleParameters_Get(P, Name, s, Options) then Exit; //Если не удалось узнать значение, то выход
  if not TryStrToInt(s, rs) then Exit;                        //Попытка преобразования числа в строку, если ошибка, то выход
  ResultValue := rs;                                          //Вернуть значение
  Result := True;
end;



{
Описание
  Взять значение параметра из массива по имени
Параметры
  P           - Массив параметров
  Name        - Имя для поиска
  ResultValue - Результат работы, Значение
  Options     - Модификаторы работы
    soCaseSensivity - Учитывать регистр при поиске
Результат
  True  - Найдено
  False - Не найдено
Дополнительно
  Функция возвращает False если произошла ошибка преобразования
}
function SimpleParameters_Get(P: PSimpleParameters; Name: String; var ResultValue: Real; Options: TSearchOptions = []): Boolean;
var
  rs: Real;
  s: String;
begin
  Result := False;
  if not SimpleParameters_Get(P, Name, s, Options) then Exit; //Если не удалось узнать значение, то выход
  if not TryStrToFloat(s, rs) then Exit;                      //Попытка преобразования числа в строку, если ошибка, то выход
  ResultValue := rs;                                          //Вернуть значение
  Result := True;
end;



{
Описание
  Взять значение параметра из массива по имени
Параметры
  P           - Массив параметров
  Name        - Имя для поиска
  ResultValue - Результат работы, Значение
  TrueStr     - Строковое представление истины
  Options     - Модификаторы работы
    soCaseSensivity - Учитывать регистр при поиске
Результат
  True  - Найдено
  False - Не найдено
}
function SimpleParameters_Get(P: PSimpleParameters; Name: String; var ResultValue: Boolean; TrueStr: String = 'True'; Options: TSearchOptions = []): Boolean;
var
  s: String;
begin
  Result := False;
  if not SimpleParameters_Get(P, Name, s, Options) then Exit;                   //Если не удалось узнать значение, то выход
  s := LowerCase(s);                                                            //Значение в нижний регистр
  if s = LowerCase(TrueStr) then ResultValue := True else ResultValue := False; //Вернуть результат
  Result := True;
end;



{
Описание
  Скопировать массив параметров в массив строк
Параметры
  P         - Массив параметров
  StrArray  - Результат работы, массив строк вида 'Name=Value'
  UseIndent - Использовать пробел перед разделителем и после
}
procedure SimpleParameters_ToStringArray(P: PSimpleParameters; StrArray: PStringArray; UseIndent: Boolean = True);
var
  i, c: Integer;
  Value, a: String;
begin
  StringArray_Clear(StrArray);              //Очистить выходной массив
  c := SimpleParameters_GetCount(P) - 1;    //Индекс последнего параметра
  if UseIndent then a := ' ' else a := '';  //Подготовить отступ
  for i := 0 to c do
    begin
    Value := SimpleCommand_SecureString(P^[i].Value, sp_Divider, sp_Staple, sp_Control);  //Обезопасить строку
    StringArray_Add(StrArray, P^[i].Name + a + sp_Divider + a + Value); //Добавить в массив строк
    end;
end;



{
Описание
  Скопировать найденные параметры из массива строк в массив параметров
Параметры
  P        - Результат работы, найденные параметры
  StrArray - Массив строк
}
procedure SimpleParameters_FromStringArray(P: PSimpleParameters; StrArray: PStringArray);
var
  i, c: Integer;
  sstr: TStringArray;
  s: String;
begin
  c := StringArray_GetCount(StrArray) - 1;                    //Индекс последнего параметра
  SimpleParameters_Clear(P);                                  //Очистить выходной массив
  for i := 0 to c do
    begin
    s := TrimLeft(StrArray^[i]);                              //Обрезать пробелы слева
    if (s = '') or (s[1] = sp_Commentary) then Continue;      //Пустая строка или заметка, выход
    SimpleCommand_Disassemble(@sstr, s, sp_Divider, sp_Staple, sp_Control); //Разобрать строку
    if StringArray_Equal(@sstr, 2) then
      SimpleParameters_Add(P, Trim(sstr[0]), Trim(sstr[1]));  //Если есть 2 части, то добавить
    end;
  StringArray_Clear(@sstr);                                   //Почистить память
end;



{
Описание
  Преобразовать массив параметров в строку через разделитель
Параметры
  P         - Массив параметров
  UseIndent - Использовать пробел перед разделителем и после
  Divider   - Разделитель между параметрами
Результат
  Массив параметров в виде строки
}
function SimpleParameters_ToString(P: PSimpleParameters; UseIndent: Boolean = True; Divider: String = sa_StrDivider): String;
var
  sa: TStringArray;
begin
  SimpleParameters_ToStringArray(P, @sa, UseIndent);  //Скопировать параметры в массив строк
  Result := StringArray_ArrayToString(@sa, Divider);  //Преобразовать массив строк в одну строку
  StringArray_Clear(@sa);                             //Почистить память
end;



{
Описание
  Прочитать параметры из строки в массив
Параметры
  P - Результат работы, Массив параметров
  Str - Строка с параметрами
  Divider - Разделитель между параметрами
}
procedure SimpleParameters_FromString(P: PSimpleParameters; Str: String; Divider: String = sa_StrDivider);
var
  sa: TStringArray;
begin
  StringArray_StringToArray(@sa, Str, Divider); //Переобразовать строку в массив строк
  SimpleParameters_FromStringArray(P, @sa);     //Скопировать параметры из массива строк в массив параметров
  StringArray_Clear(@sa);                       //Почистить память
end;



{
Описание
  Сохранить параметры в файл
Параметры
  P         - Массив параметров
  FileName  - Полнуй путь к файлу для сохранения
  UseIndent - Использовать пробел перед разделителем и после
  Divider   - Разделитель для строк
Результат
  True  - Сохранено
  False - Не сохранено
}
function SimpleParameters_SaveToFile(P: PSimpleParameters; FileName: String; UseIndent: Boolean = True; Divider: String = sa_StrDivider): Boolean;
var
  sa: TStringArray;
begin
  Result := False;
  SimpleParameters_ToStringArray(P, @sa, UseIndent);                      //Скопировать параметры в массив строк
  if StringArray_SaveToFile(@sa, FileName, Divider) then Result := True;  //Сохранить массив строк
  StringArray_Clear(@sa);                                                 //Почистить память
end;



{
Описание
  Прочитать параметры из файла в массив
Параметры
  P - Результат функции, Найденные параметры
  FileName  - Полнуй путь к файлу для сохранения
  Divider   - Разделитель для строк
Результат
  True  - Загружено
  False - Не загружено
}
function SimpleParameters_LoadFromFile(P: PSimpleParameters; FileName: String; Divider: String = sa_StrDivider): Boolean;
var
  sa: TStringArray;
begin
  Result := False;
  if not StringArray_LoadFromFile(@sa, FileName, Divider) then Exit;  //Загрузить массив строк из файла
  SimpleParameters_FromStringArray(P, @sa);                           //Скопировать параметры из массива строк в массив параметров
  StringArray_Clear(@sa);                                             //Почистить память
  Result := True;
end;



{
Описание
  Изменить значение параметра в файле не изменяя форматирование
Параметры
  FileName   - Полный путь к файлу
  Name       - Имя параметра для поиска
  Value      - Новое значение
  UseIndent  - Использовать пробел перед разделителем и после
  Options    - Модификаторы работы
    soCaseSensivity - Учитывать регистр при поиске
  Divider    - Разделитель строк в файле
  AutoCreate - Записать параметр в файл если не удалось обновить
Результат
  True  - Обновлено
  False - Не обновлено
}
function SimpleParameters_SetInFile(FileName: String; Name, Value: String; UseIndent: Boolean = True; Options: TSearchOptions = []; Divider: String = sa_StrDivider; AutoCreate: Boolean = False): Boolean;
var
  sa, sstr: TStringArray;
  i, c: Integer;
  sPrm, str, lcPrm, a: String;
  Exist: Boolean;
begin
  Result := False;
  StringArray_LoadFromFile(@sa, FileName, Divider);                                 //Попробовать загрузить массив строк из файла
  Value := SimpleCommand_SecureString(Value, sp_Divider, sp_Staple, sp_Control);    //Обезопасить новое значение параметра
  c := StringArray_GetCount(@sa) - 1;                                               //Узнать индекс песледней строки
  if (soCaseSensivity in Options) then lcPrm := Name else lcPrm := LowerCase(Name); //Поправить имя при использовании модификатора
  Exist := False;                                                                   //По умолчанию - параметр не найден
  if UseIndent then a := ' ' else a := '';                                          //Подготовить отступ
  for i := 0 to c do                                                                //Пробежать по всем строкам
    begin
    str := TrimLeft(sa[i]);                                                         //Обрезать пробелы слева
    if (str = '') or (str[1] = sp_Commentary) then Continue;                        //Если пустая строка или заметка, то пропуск
    SimpleCommand_Disassemble(@sstr, sa[i], sp_Divider, sp_Staple, sp_Control);     //Разобрать строку на части
    if not StringArray_Equal(@sstr, 2) then Continue;                               //если нет двух частей, то пропуск
    sPrm := Trim(sstr[0]);                                                          //Подготовить имя параметра из массива строк
    if not (soCaseSensivity in Options) then sPrm := LowerCase(sPrm);               //Поправить имя при использовании модификатора
    if sPrm = lcPrm then                                                            //Проверить на равенство
      begin
      sa[i] := sstr[0] + sp_Divider + a + Value;                                    //Изменить строку в массиве не трогая левую часть до разделителя
      Exist := True;                                                                //Параметр найден
      Break;                                                                        //Оборвать цикл
      end;
    end;
  StringArray_Clear(@sstr);                                                         //Очистить временный массив
  if not (Exist and AutoCreate) then                                                //Если параметр не найден и не нужно добавлять новый, то выход
    begin
    StringArray_Clear(@sa);                                                         //Почистить память
    Exit;
    end;
  if (not Exist) and AutoCreate then
    StringArray_Add(@sa, Name + a + sp_Divider + a + Value);                        //Если параметр не найден и нужно добавлять новый, то добавить в массив
  if StringArray_SaveToFile(@sa, FileName, Divider) then Result := True;            //Перезаписать массив строк в файл
  StringArray_Clear(@sa);                                                           //Почистить память
end;



{
Описание
  Изменить значение параметра в файле не изменяя форматирование
Параметры
  FileName   - Полный путь к файлу
  Name       - Имя параметра для поиска
  Value      - Новое значение
  UseIndent  - Использовать пробел перед разделителем и после
  Options    - Модификаторы работы
    soCaseSensivity - Учитывать регистр при поиске
  Divider    - Разделитель строк в файле
  AutoCreate - Записать параметр в файл если не удалось обновить
Результат
  True  - Обновлено
  False - Не обновлено
}
function SimpleParameters_SetInFile(FileName: String; Name: String; Value: Integer; UseIndent: Boolean = True; Options: TSearchOptions = []; Divider: String = sa_StrDivider; AutoCreate: Boolean = False): Boolean;
begin
  Result := SimpleParameters_SetInFile(FileName, Name, IntToStr(Value), UseIndent, Options, Divider, AutoCreate);
end;



{
Описание
  Изменить значение параметра в файле не изменяя форматирование
Параметры
  FileName   - Полный путь к файлу
  Name       - Имя параметра для поиска
  Value      - Новое значение
  UseIndent  - Использовать пробел перед разделителем и после
  Options    - Модификаторы работы
    soCaseSensivity - Учитывать регистр при поиске
  Divider    - Разделитель строк в файле
  AutoCreate - Записать параметр в файл если не удалось обновить
Результат
  True  - Обновлено
  False - Не обновлено
}
function SimpleParameters_SetInFile(FileName: String; Name: String; Value: Real; UseIndent: Boolean = True; Options: TSearchOptions = []; Divider: String = sa_StrDivider; AutoCreate: Boolean = False): Boolean;
begin
  Result := SimpleParameters_SetInFile(FileName, Name, FloatToStr(Value), UseIndent, Options, Divider, AutoCreate);
end;



{
Описание
  Изменить значение параметра в файле не изменяя форматирование
Параметры
  FileName   - Полный путь к файлу
  Name       - Имя параметра для поиска
  Value      - Новое значение
  TrueStr    - Строковое представление истины
  FalseStr   - Строковое представление ереси :)
  UseIndent  - Использовать пробел перед разделителем и после
  Options    - Модификаторы работы
    soCaseSensivity - Учитывать регистр при поиске
  Divider    - Разделитель строк в файле
  AutoCreate - Записать параметр в файл если не удалось обновить
Результат
  True  - Обновлено
  False - Не обновлено
}
function SimpleParameters_SetInFile(FileName: String; Name: String; Value: Boolean; TrueStr: String = 'True'; FalseStr: String = 'False'; UseIndent: Boolean = True; Options: TSearchOptions = []; Divider: String = sa_StrDivider; AutoCreate: Boolean = False): Boolean;
var
  S: String;
begin
  if Value then S := TrueStr else S := FalseStr;
  Result := SimpleParameters_SetInFile(FileName, Name, S, UseIndent, Options, Divider, AutoCreate);
end;



{
Описание
  Прочитать значение параметра из файла
Параметры
  FileName    - Полный путь к файлу
  Name        - Имя параметра для поиска
  ResultValue - Результат функции, Значение
  Options     - Модификаторы работы
    soCaseSensivity - Учитывать регистр при поиске
  Divider     - Разделитель строк в файле
Результат
  True  - Прочтено
  False - Не прочтено
}
function SimpleParameters_GetFromFile(FileName: String; Name: String; var ResultValue: String; Options: TSearchOptions = []; Divider: String = sa_StrDivider): Boolean;
var
  sp: TSimpleParameters;
begin
  Result := False;
  if not SimpleParameters_LoadFromFile(@sp, FileName, Divider) then Exit; //Загрузить параметры во временный массив
  Result := SimpleParameters_Get(@sp, Name, ResultValue, Options);        //Узнать значение парметра
  SimpleParameters_Clear(@sp);                                            //Почистить память
end;



{
Описание
  Прочитать значение параметра из файла
Параметры
  FileName    - Полный путь к файлу
  Name        - Имя параметра для поиска
  ResultValue - Результат функции, Значение
  Options     - Модификаторы работы
    soCaseSensivity - Учитывать регистр при поиске
  Divider     - Разделитель строк в файле
Результат
  True  - Прочтено
  False - Не прочтено
}
function SimpleParameters_GetFromFile(FileName: String; Name: String; var ResultValue: Integer; Options: TSearchOptions = []; Divider: String = sa_StrDivider): Boolean;
var
  rs: Integer;
  s: String;
begin
  Result := False;
  if not SimpleParameters_GetFromFile(FileName, Name, s, Options, Divider) then Exit; //Если параметр не найден, то выход
  if not TryStrToInt(s, rs) then Exit;                                                //Попытатся преобразовать, иначе выход
  ResultValue := rs;                                                                  //Вернуть результат
  Result := True;
end;



{
Описание
  Прочитать значение параметра из файла
Параметры
  FileName    - Полный путь к файлу
  Name        - Имя параметра для поиска
  ResultValue - Результат функции, Значение
  Options     - Модификаторы работы
    soCaseSensivity - Учитывать регистр при поиске
  Divider     - Разделитель строк в файле
Результат
  True  - Прочтено
  False - Не прочтено
}
function SimpleParameters_GetFromFile(FileName: String; Name: String; var ResultValue: Real; Options: TSearchOptions = []; Divider: String = sa_StrDivider): Boolean;
var
  rs: Real;
  s: String;
begin
  Result := False;
  if not SimpleParameters_GetFromFile(FileName, Name, s, Options, Divider) then Exit; //Если параметр не найден, то выход
  if not TryStrToFloat(s, rs) then Exit;                                              //Попытатся преобразовать, иначе выход
  ResultValue := rs;                                                                  //Вернуть результат
  Result := True;
end;



{
Описание
  Прочитать значение параметра из файла
Параметры
  FileName    - Полный путь к файлу
  Name        - Имя параметра для поиска
  ResultValue - Результат функции, Значение
  Options     - Модификаторы работы
    soCaseSensivity - Учитывать регистр при поиске
  Divider     - Разделитель строк в файле
Результат
  True  - Прочтено
  False - Не прочтено
}
function SimpleParameters_GetFromFile(FileName: String; Name: String; var ResultValue: Boolean; TrueStr: String = 'True'; Options: TSearchOptions = []; Divider: String = sa_StrDivider): Boolean;
var
  s: String;
begin
  Result := False;
  if not SimpleParameters_GetFromFile(FileName, Name, s, Options, Divider) then Exit; //Если параметр не найден, то выход
  s := LowerCase(s);                                                                  //Значение в нижний регистр
  if s = LowerCase(TrueStr) then ResultValue := True else ResultValue := False;       //Вернуть результат
  Result := True;
end;





{
Описание
  Изменить параметры в файле не изменяя форматирование
Параметры
  P          - Массив параметров
  FileName   - Полный путь к файлу
  UseIndent  - Использовать пробел перед разделителем и после
  Options    - Модификаторы работы
    soCaseSensivity - Учитывать регистр при поиске
  Divider    - Разделитель строк в файле
  AutoCreate - Записать параметр в файл если не удалось обновить
Результат
  True  - Обновлено
  False - Не обновлено
}
function SimpleParameters_UpdateInFile(P: PSimpleParameters; FileName: String; UseIndent: Boolean = True; Options: TSearchOptions = []; Divider: String = sa_StrDivider; AutoCreate: Boolean = False): Boolean;
var
  sa, sstr: TStringArray;
  i, c, j, k: Integer;
  sPrm, sPrm2, Value, a: String;
  Exist: Boolean;
begin
  Result := False;
  StringArray_LoadFromFile(@sa, FileName, Divider);                                 //Попробовать загрузить массив строк из файла
  k := StringArray_GetCount(@sa) - 1;                                               //Индекс последней строки в массиве
  c := SimpleParameters_GetCount(P) - 1;                                            //Индекс последнего параметра в массиве
  if UseIndent then a := ' ' else a := '';                                          //Подготовить отступ
  for i := 0 to c do                                                                //Цикл по параметрам
    begin
    Exist := False;                                                                 //По умолчанию - текущий параметр не найден
    if (soCaseSensivity in Options) then sPrm := P^[i].Name else sPrm := LowerCase(P^[i].Name); //Подготовить имя параметра
    Value := SimpleCommand_SecureString(P^[i].Value, sp_Divider, sp_Staple, sp_Control);        //Подготовить значение для замены в файле
    for j := 0 to k do                                                              //Цикл по строкам из файла
      begin
      if (sa[j] = '') or (sa[j][1] = sp_Commentary) then Continue;                  //Если пустая строка или заметка, то пропуск
      SimpleCommand_Disassemble(@sstr, sa[j], sp_Divider, sp_Staple, sp_Control);   //Разбить текущую строку на части
      if not StringArray_Equal(@sstr, 2) then Continue;                             //Если нет 2 частей, то пропуск
      sPrm2 := Trim(sstr[0]);                                                       //Подготовить название параметра из файла
      if not (soCaseSensivity in Options) then sPrm2 := LowerCase(sPrm2);           //Поправить регистр при использовании модификатора
      if sPrm = sPrm2 then                                                          //Если имена одинаковы
        begin
        sa[j] := sstr[0] + sp_Divider + a + Value;                                  //Заменить строку в не трогая левую часть до разделителя
        Exist := True;                                                              //Текущий параметр обновлён
        Break;                                                                      //Оборвать цикл
        end;
      end; //for j
    if (not Exist) and AutoCreate then                                              //Если параметр не найден в файле и добавлять отсутствующие, то добавить
      StringArray_Add(@sa, P^[i].Name + a + sp_Divider + a + Value);
    end; //for i
  StringArray_Clear(@sstr);                                                         //Почистить память
  if StringArray_SaveToFile(@sa, FileName, Divider) then Result := True;            //Перезаписать массив строк в файл
  StringArray_Clear(@sa);                                                           //Почистить память
end;




{
Описание
  Прочитать значения параметров из файла в массив
Параметры
  P          - Массив параметров для обновления значений
  FileName   - Полный путь к файлу
  Options    - Модификаторы работы
    soCaseSensivity - Учитывать регистр при поиске
  Divider    - Разделитель строк в файле
  AutoCreate - Добавлять параметр в массив если не удалось найти
Результат
  True  - Прочитано
  False - Не прочитано
}
function SimpleParameters_UpdateFromFile(P: PSimpleParameters; FileName: String; Options: TSearchOptions = []; Divider: String = sa_StrDivider; AutoCreate: Boolean = False): Boolean;
var
  sa, sstr: TStringArray;
  i, c, Idx: Integer;
  str, Sprm, Sval: String;
begin
  Result := False;
  if not StringArray_LoadFromFile(@sa, FileName, Divider) then Exit;            //Загрузить массив строк из файла
  c := StringArray_GetCount(@sa) - 1;                                           //Индекс последней строки
  for i := 0 to c do                                                            //Цикл по строкам
    begin
    str := TrimLeft(sa[i]);                                                     //Обрезать пробелы слева
    if (str = '') or (str[1] = sp_Commentary) then Continue;                    //Если пустая строка или заметка, то пропуск
    SimpleCommand_Disassemble(@sstr, sa[i], sp_Divider, sp_Staple, sp_Control); //Разобрать строку на части
    if not StringArray_Equal(@sstr, 2) then Continue;                           //Если нет 2 частей, то пропуск
    Sprm := Trim(sstr[0]);                                                      //Обрезать лишние пробелы в имени
    Sval := Trim(sstr[1]);                                                      //Обрезать лишние пробелы в значении
    Idx := SimpleParameters_GetIdxByName(P, Sprm, Options);                     //Найти индекс параметра в массиве
    if Idx >= 0 then P^[Idx].Value := Sval else                                 //Если найден, то обновить значение
      if AutoCreate then SimpleParameters_Add(P, Sprm, Sval);                   //Иначе добавить новый параметр, если добавлять отсутствующие
    end;
  StringArray_Clear(@sstr);                                                     //Почистить память
  StringArray_Clear(@sa);                                                       //Почистить память
  Result := True;
end;





end.
