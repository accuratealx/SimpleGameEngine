{
Пакет             Simple Game Engine 1
Файл              sgeGraphicFrames.pas
Версия            1.2
Создан            31.10.2018
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Класс с набором плиток анимации
}

unit sgeGraphicFrames;

{$mode objfpc}{$H+}

interface

uses
  StringArray, SimpleCommand,
  sgeConst, sgeTypes, sgeGraphicSprite, sgeResources,
  Windows, SysUtils;


type
  TsgeGraphicFrame = record
    Sprite: TsgeGraphicSprite;  //Указатель на спрайт
    SpriteName: String;         //Имя спрайта в таблице ресурсов
    Col: Word;                  //Номер столбца плитки
    Row: Word;                  //Номер строки плитки
    Time: Int64;                //Время показа на экране в тиках процессора
  end;


  TsgeGraphicFrameArray = array of TsgeGraphicFrame;  //Массив кадров


  TsgeGraphicFrames = class
  private
    FFrames: TsgeGraphicFrameArray;

    function  GetCount: Integer;
    procedure SetFrame(Index: Integer; AFrame: TsgeGraphicFrame);
    function  GetFrame(Index: Integer): TsgeGraphicFrame;
    function  GetFrameAsString(AFrame: TsgeGraphicFrame): String;
  public
    constructor Create(AFrames: TsgeGraphicFrameArray);
    constructor Create(FileName: String; Resources: TsgeResources);
    destructor  Destroy; override;

    procedure Clear;
    procedure Add(AFrame: TsgeGraphicFrame);
    procedure Delete(Index: Integer);
    procedure Insert(Index: Integer; AFrame: TsgeGraphicFrame);

    procedure SetAsString(Str: String; Resources: TsgeResources);
    function  GetAsString: String;
    procedure LoadFromFile(FileName: String; Resources: TsgeResources);
    procedure SaveToFile(FileName: String);

    property Count: Integer read GetCount;
    property Frame[Index: Integer]: TsgeGraphicFrame read GetFrame write SetFrame;
  end;


implementation


const
  _UNITNAME = 'sgeGraphicFrames';



function TsgeGraphicFrames.GetCount: Integer;
begin
  Result := Length(FFrames);
end;


procedure TsgeGraphicFrames.SetFrame(Index: Integer; AFrame: TsgeGraphicFrame);
var
  c: Integer;
begin
  c := Length(FFrames);
  if (Index < 0) or (Index > c) then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_IndexOutOfBounds, IntToStr(Index)));

  FFrames[Index] := AFrame;
end;


function TsgeGraphicFrames.GetFrame(Index: Integer): TsgeGraphicFrame;
var
  c: Integer;
begin
  c := Length(FFrames);
  if (Index < 0) or (Index > c) then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_IndexOutOfBounds, IntToStr(Index)));

  Result := FFrames[Index];
end;


function TsgeGraphicFrames.GetFrameAsString(AFrame: TsgeGraphicFrame): String;
var
  OneSecondFrequency: Int64;
begin
  QueryPerformanceFrequency(OneSecondFrequency);
  Result := AFrame.SpriteName + ' ' + IntToStr(AFrame.Col) + ' ' + IntToStr(AFrame.Row) + ' ' +
            IntToStr(Round(AFrame.Time / (OneSecondFrequency / 1000)));

end;


constructor TsgeGraphicFrames.Create(AFrames: TsgeGraphicFrameArray);
var
  i, c: Integer;
begin
  Clear;                      //На всякий пожарный очистить
  c := Length(AFrames) - 1;   //Сколько кадров
  SetLength(FFrames, c + 1);  //Выделить память
  for i := 0 to c do          //Скопировать ячейки
    FFrames[i] := AFrames[i];
end;


constructor TsgeGraphicFrames.Create(FileName: String; Resources: TsgeResources);
begin
  LoadFromFile(FileName, Resources);
end;


destructor TsgeGraphicFrames.Destroy;
begin
  Clear;
end;


procedure TsgeGraphicFrames.Clear;
begin
  SetLength(FFrames, 0);
end;


procedure TsgeGraphicFrames.Add(AFrame: TsgeGraphicFrame);
var
  c: Integer;
begin
  c := GetCount;              //Узнать сколько кадров
  SetLength(FFrames, c + 1);  //Добавить 1 кадр
  FFrames[c] := AFrame;       //Изменить кадр
end;


procedure TsgeGraphicFrames.Delete(Index: Integer);
var
  i, c: Integer;
begin
  c := GetCount - 1;
  if (Index < 0) or (Index > c) then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_IndexOutOfBounds, IntToStr(Index)));

  for i := 0 to c - 1 do            //Переместить кадры
    FFrames[i] := FFrames[i + 1];

  SetLength(FFrames, c);            //Уменьшить на 1 кадр
end;


procedure TsgeGraphicFrames.Insert(Index: Integer; AFrame: TsgeGraphicFrame);
var
  i, c: Integer;
begin
  c := Length(FFrames);
  if (Index < 0) or (Index > c) then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_IndexOutOfBounds, IntToStr(Index)));

  SetLength(FFrames, c + 1);      //Добавить 1 кадр
  for i := c downto Index + 1 do  //Сместить кадры
    FFrames[i] := FFrames[i - 1];

  FFrames[Index] := AFrame;       //Вставить новый кадр
end;


procedure TsgeGraphicFrames.SetAsString(Str: String; Resources: TsgeResources);
var
  i, c, Cnt: Integer;
  Parts, tFrm: TStringArray;
  Fr: TsgeGraphicFrame;
  aCol, aRow: Integer;
  OneSecondFrequency: Int64;
  TempFrames: TsgeGraphicFrameArray;
begin
  Str := Trim(Str);                               //Отрезать лишнее
  SimpleCommand_Disassemble(@Parts, Str, ';');    //Разобрать на части через ;
  Cnt := StringArray_GetCount(@Parts);            //Узнать сколько частей
  if Cnt < 1 then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_NoPartsToLoad));

  try
    QueryPerformanceFrequency(OneSecondFrequency);  //Узнать количество тактов процессора
    Dec(Cnt);
    SetLength(TempFrames, 0);                       //Обнулить массив
    for i := 0 to Cnt do                            //Пробежать по кадрам
      begin
      //Почистить запись
      Fr.SpriteName := '';
      Fr.Sprite := nil;
      Fr.Col := 0;
      Fr.Row := 0;
      Fr.Time := 0;

      //Разобрать кадр на части
      SimpleCommand_Disassemble(@tFrm, Parts[i]);

      //Проверитьт на наличие 4 частей
      if not StringArray_Equal(@tFrm, 4) then
        raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_WrongDataFormat, Parts[i]));

      //Определить имя кадра
      Fr.SpriteName := tFrm[0];
      Fr.Sprite := TsgeGraphicSprite(Resources.TypedObj[tFrm[0], rtGraphicSprite]);
      if Fr.Sprite = nil then
        raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_SpriteNotFound, tFrm[0]));

      //Определить номер столбца
      if not TryStrToInt(tFrm[1], aCol) then
        raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_UnableToDetermineColumn, tFrm[1]));
      Fr.Col := aCol;

      //Определить номер строки
      if not TryStrToInt(tFrm[2], aRow) then
        raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_UnableToDetermineRow, tFrm[2]));
      Fr.Row := aRow;

      //Определить время видимости в строке милисекунды
      if not TryStrToInt64(tFrm[3], Fr.Time) then
        raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_UnableToDetermineTime, tFrm[3]));
      if Fr.Time < 1 then Fr.Time := 0;
      Fr.Time := Round((OneSecondFrequency / 1000) * Fr.Time);

      //Добавить во временный массив
      c := Length(TempFrames);
      SetLength(TempFrames, c + 1);
      TempFrames[c] := Fr;
      end;

    //Удалить старые кадры
    Clear;

    //Заменить указатель на новый массив
    FFrames := TempFrames;

  finally
    StringArray_Clear(@Parts);
    StringArray_Clear(@tFrm);
  end;
end;


function TsgeGraphicFrames.GetAsString: String;
var
  i, c: Integer;
begin
  //Склеить кадры в одну строку
  c := Length(FFrames) - 1;
  Result := '';
  for i := 0 to c do
    begin
    Result := Result + GetFrameAsString(FFrames[i]);
    if i <> c then Result := Result + ';';
    end;
end;


procedure TsgeGraphicFrames.LoadFromFile(FileName: String; Resources: TsgeResources);
var
  i, c: Integer;
  sa: TStringArray;
  s: String;
begin
  if not StringArray_LoadFromFile(@sa, FileName) then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_FileReadError, FileName));

  //Обработать файл
  s := '';
  c := StringArray_GetCount(@sa) - 1;
  for i := 0 to c do                    //Пройти по кадрам
    begin
    sa[i] := Trim(sa[i]);               //Обрезать лишние пробелы
    if sa[i] = '' then Continue;        //Пропуск пустых строк
    if sa[i] = '#' then Continue;       //Пропуск заметок
    s := s + sa[i];
    if i <> c then s := s + ';';
    end;
  StringArray_Clear(@sa);               //Почистить память

  //Загрузить из строки
  SetAsString(s, Resources);
end;


procedure TsgeGraphicFrames.SaveToFile(FileName: String);
var
  i, c: Integer;
  sa: TStringArray;
begin
  //Добавить кадры в массив строк
  c := Length(FFrames) - 1;
  for i := 0 to c do
    StringArray_Add(@sa, GetFrameAsString(FFrames[i]));

  //Записать в файл
  if not StringArray_SaveToFile(@sa, FileName) then
    begin
    StringArray_Clear(@sa);
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_FileWriteError, FileName));
    end;

  //Почистить память
  StringArray_Clear(@sa);
end;





end.


