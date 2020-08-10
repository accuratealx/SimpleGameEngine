{
Пакет             Simple Game Engine 1
Файл              sgeStringList.pas
Версия            1.4
Создан            31.05.2020
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Массив строк с поддержкой UTF-8
}

unit sgeStringList;

{$mode objfpc}{$H+}{$Warnings Off}{$Hints Off}

interface

uses
  sgeTypes, sgeMemoryStream;


type
  //Метод отрезания лишних символов
  TsgeStringListTrimMethod = (sltmLeft, sltmRight, sltmBoth);

  //Способы сортировки
  TsgeStringListSortMode = (slsmBubble);

  //Направление сортировки
  TsgeStringListSortDirection = (slsdForward, slsdBackward);


  //Список строк
  TsgeStringList = class
  private
    FStringList: array of String;                     //Список строк
    FSearchOptions: TsgeSearchOptions;                //Модификаторы поиска
    FSortMode: TsgeStringListSortMode;                //Метод сортировки
    FSortDirection: TsgeStringListSortDirection;      //Направление сортировки
    FSeparator: String;                               //Разделитель

    function  GetCount: Integer;
    procedure SetPart(Index: Integer; Part: String);
    function  GetPart(Index: Integer): String;
  public
    constructor Create;
    destructor  Destroy; override;

    procedure Clear;
    function  IndexOf(Part: String): Integer;
    procedure Add(Part: String);
    procedure Add(List: TsgeStringList);
    procedure Insert(Index: Integer; Part: String);
    procedure Insert(Index: Integer; List: TsgeStringList);
    procedure Delete(Index: Integer);
    procedure Delete(Part: String);
    procedure Delete(List: TsgeStringList);

    function  ToString: String; override;
    procedure FromString(Str: String);
    procedure CopyFrom(List: TsgeStringList);
    procedure CopyTo(List: TsgeStringList);
    procedure ToMemoryStream(Stream: TsgeMemoryStream);
    procedure FromMemoryStream(Stream: TsgeMemoryStream);

    procedure AppendToFile(FileName: String);
    procedure SaveToFile(FileName: String);
    procedure LoadFromFile(FileName: String);

    procedure Remix(Count: Integer = -1);
    procedure Trim(Method: TsgeStringListTrimMethod = sltmBoth);
    procedure Sort;

    property Count: Integer read GetCount;
    property SearchOptions: TsgeSearchOptions read FSearchOptions write FSearchOptions;
    property SortMode: TsgeStringListSortMode read FSortMode write FSortMode;
    property SortDirection: TsgeStringListSortDirection read FSortDirection write FSortDirection;
    property Separator: String read FSeparator write FSeparator;
    property Part[Index: Integer]: String read GetPart write SetPart;
  end;




implementation

uses
  sgeConst, sgeFile,
  LazUTF8, SysUtils;

const
  _UNITNAME = 'sgeStringList';



function TsgeStringList.GetCount: Integer;
begin
  Result := Length(FStringList);
end;


function TsgeStringList.GetPart(Index: Integer): String;
begin
  if (Index < 0) or (Index > GetCount - 1) then
    raise EsgeException.Create(_UNITNAME, Err_IndexOutOfBounds, IntToStr(Index));

  Result := FStringList[Index];
end;


procedure TsgeStringList.SetPart(Index: Integer; Part: String);
begin
  if (Index < 0) or (Index > GetCount - 1) then
    raise EsgeException.Create(_UNITNAME, Err_IndexOutOfBounds, IntToStr(Index));

  FStringList[Index] := Part;
end;


constructor TsgeStringList.Create;
begin
  FSearchOptions := [];
  FSeparator := #13#10;
  FSortMode := slsmBubble;
  FSortDirection := slsdForward;
end;


destructor TsgeStringList.Destroy;
begin
  Clear;
end;


procedure TsgeStringList.Clear;
begin
  SetLength(FStringList, 0);
end;


function TsgeStringList.IndexOf(Part: String): Integer;
var
  i, c: Integer;
  s: String;
begin
  Result := -1;

  //Проверить модификатор поиска
  if not (soCaseSensivity in FSearchOptions) then Part := UTF8LowerCase(Part);


  c := Length(FStringList) - 1;
  for i := 0 to c do
    begin
    //Проверить модификатор поиска
    if not (soCaseSensivity in FSearchOptions) then s := UTF8LowerCase(FStringList[i]) else s := FStringList[i];

    //Сравнить
    if s = Part then
      begin
      Result := i;
      Break;
      end;
    end;
end;


procedure TsgeStringList.Add(Part: String);
var
  c: Integer;
begin
  //Проверить модификаторы поиска
  if (soUnique in FSearchOptions) and (IndexOf(Part) <> -1) then Exit;

  //Добавить часть
  c := GetCount;
  SetLength(FStringList, c + 1);
  FStringList[c] := Part;
end;


procedure TsgeStringList.Add(List: TsgeStringList);
var
  i, c: Integer;
begin
  c := List.Count - 1;
  for i := 0 to c do
    Add(List.Part[i]);
end;


procedure TsgeStringList.Insert(Index: Integer; Part: String);
var
  c, i: Integer;
begin
  c := GetCount;
  if (Index < 0) or (Index > GetCount) then
    raise EsgeException.Create(_UNITNAME, Err_IndexOutOfBounds, IntToStr(Index));

  //Проверить модификаторы поиска
  if (soUnique in FSearchOptions) and (IndexOf(Part) <> -1) then Exit;

  //Раздвинуть
  SetLength(FStringList, c + 1);
  for i := c downto Index + 1 do
    FStringList[i] := FStringList[i - 1];

  //Вставить
  FStringList[Index] := Part;
end;


procedure TsgeStringList.Insert(Index: Integer; List: TsgeStringList);
var
  i, c: Integer;
begin
  c := List.Count - 1;
  for i := 0 to c do
    begin
    Insert(Index, List.Part[i]);
    Inc(Index);
    end;
end;


procedure TsgeStringList.Delete(Index: Integer);
var
  c, i: Integer;
begin
  c := GetCount - 1;
  if (Index < 0) or (Index > GetCount) then
    raise EsgeException.Create(_UNITNAME, Err_IndexOutOfBounds, IntToStr(Index));

  //Сдвинуть хвост
  for i := Index to c - 1 do
    FStringList[i] := FStringList[i + 1];

  //Удалить последний элемент
  SetLength(FStringList, c);
end;


procedure TsgeStringList.Delete(Part: String);
begin
  Delete(IndexOf(Part));
end;


procedure TsgeStringList.Delete(List: TsgeStringList);
var
  i, c, Idx: Integer;
begin
  c := List.Count - 1;
  for i := 0 to c do
    begin
    Idx := IndexOf(List.Part[i]);
    if Idx <> -1 then Delete(Idx);
    end;
end;


function TsgeStringList.ToString: String;
var
  c, i: Integer;
begin
  Result := '';
  c := GetCount - 1;
  for i := 0 to c do
    begin
    Result := Result + FStringList[i];
    if c <> i then Result := Result + FSeparator;
    end;
end;


procedure TsgeStringList.FromString(Str: String);
var
  i, l, StartIdx, Size: Integer;
  s: String;
begin
  //Почистить список
  Clear;

  //Начальные параметры
  StartIdx := 1;
  Size := Length(Str);
  l := UTF8Length(FSeparator);


  repeat
   //Поиск вхождения разделителя
   i := utf8pos(FSeparator, Str, StartIdx);

   //Есть совпадение
   if i > 0 then
    begin
    s := UTF8Copy(Str, StartIdx, i - StartIdx);
    Add(s);
    StartIdx := i + l;
    end;

    //Нет совпадения
    if (i = 0) and (i <> Size) then
      begin
      s := '';
      s := UTF8Copy(Str, StartIdx, Size - StartIdx + 1);
      Add(s);
      end;

  until i <= 0;
end;


procedure TsgeStringList.CopyFrom(List: TsgeStringList);
var
  i, c: Integer;
begin
  //Почистить список
  Clear;

  //Скопировать строчки
  c := List.Count - 1;
  for i := 0 to c do
    Add(List.Part[i]);
end;


procedure TsgeStringList.CopyTo(List: TsgeStringList);
var
  i, c: Integer;
begin
  //Почистить выходной список
  List.Clear;

  //Скопировать строчки
  c := Count - 1;
  for i := 0 to c do
    List.Add(FStringList[i]);
end;


procedure TsgeStringList.ToMemoryStream(Stream: TsgeMemoryStream);
begin
  Stream.FromString(ToString);
end;


procedure TsgeStringList.FromMemoryStream(Stream: TsgeMemoryStream);
begin
  FromString(Stream.ToString);
end;


procedure TsgeStringList.AppendToFile(FileName: String);
var
  F: TsgeFile;
  S: String;
  Size: Integer;
begin
  //Подготовить строку для записи
  S := ToString;
  Size := Length(S);

  //Записать в файл
  try
    try
      F := TsgeFile.Create(FileName, fmWrite);
      F.SeekEnd;
      F.Write(S[1], Size);
    except
      raise EsgeException.Create(_UNITNAME, Err_FileWriteError, FileName);
    end;

  finally
    F.Free
  end;
end;


procedure TsgeStringList.SaveToFile(FileName: String);
var
  F: TsgeFile;
  S: String;
  Size: Integer;
begin
  //Подготовить строку для записи
  S := ToString;
  Size := Length(S);

  //Записать в файл
  try
    try
      F := TsgeFile.Create(FileName, fmWrite);
      F.Size := 0;
      if Size > 0 then F.Write(S[1], Size);
    except
      raise EsgeException.Create(_UNITNAME, Err_FileWriteError, FileName);
    end;

  finally
    F.Free
  end;
end;


procedure TsgeStringList.LoadFromFile(FileName: String);
var
  F: TsgeFile;
  S: String;
  Size: Integer;
begin
  //Проверить на существование файла
  if not FileExists(FileName) then
    raise EsgeException.Create(_UNITNAME, Err_FileNotFound, FileName);

  //Прочитать файл в строку
  try
    try
      F := TsgeFile.Create(FileName, fmRead);
      Size := F.Size;
      SetLength(S, Size);
      F.Read(S[1], Size);
    except
      raise EsgeException.Create(_UNITNAME, Err_FileReadError, FileName);
    end;

  finally
    F.Free;
  end;

  //Преобразовать строку в массив
  FromString(S);
end;


procedure TsgeStringList.Remix(Count: Integer);
var
  Idx1, Idx2, c, i: Integer;
  s: String;
begin
  //Определить количество перемешиваний
  c := GetCount;
  if Count = -1 then Count := c div 2;

  //Перемешивать строки
  for i := 0 to Count do
    begin
    Idx1 := Random(c);
    Idx2 := Random(c);
    s := FStringList[Idx1];
    FStringList[Idx1] := FStringList[Idx2];
    FStringList[Idx2] := s;
    end;
end;


procedure TsgeStringList.Trim(Method: TsgeStringListTrimMethod);
var
  i, c: Integer;
begin
  c := GetCount - 1;

  for i := 0 to c do
    case Method of
      sltmBoth : FStringList[i] := UTF8Trim(FStringList[i]);
      sltmLeft : FStringList[i] := UTF8Trim(FStringList[i], [u8tKeepEnd]);
      sltmRight: FStringList[i] := UTF8Trim(FStringList[i], [u8tKeepStart]);
    end;
end;


procedure TsgeStringList.Sort;
var
  i, j, ci, cj: Integer;
  s: String;
begin
  //Выбор способа сортировки
  case FSortMode of

    //Пузырьковая
    slsmBubble:
      begin
      ci := GetCount - 1;
      cj := ci - 1;
      for i := 0 to ci do
        for j := 0 to cj do
          if FStringList[j] > FStringList[j + 1] then
            begin
            s := FStringList[j];
            FStringList[j] := FStringList[j + 1];
            FStringList[j + 1] := s;
            end;
      end;

  end;


  //Отразить сверху вниз
  ci := GetCount - 1;
  if (FSortDirection = slsdBackward) and (ci > 0) then
    begin
    cj := ci div 2;
    for i := 0 to cj do
      begin
      s := FStringList[i];
      FStringList[i] := FStringList[ci - i];
      FStringList[ci - i] := s;
      end;
    end;
end;








end.

