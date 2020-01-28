{
Пакет             Simple Game Engine 1
Файл              sgeGraphicFrameList.pas
Версия            1.10
Создан            31.10.2018
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Класс с набором плиток анимации
}

unit sgeGraphicFrameList;

{$mode objfpc}{$H+}

interface

uses
  sgeGraphicSprite, sgeResourceList, sgeMemoryStream;


type
  //Инормация об одном кадре
  TsgeGraphicFrame = record
    Sprite: TsgeGraphicSprite;  //Указатель на спрайт
    SpriteName: String;         //Имя спрайта в таблице ресурсов
    Col: Word;                  //Номер столбца плитки
    Row: Word;                  //Номер строки плитки
    Time: Integer;              //Время показа на экране в тиках процессора
  end;


  //Массив кадров
  TsgeGraphicFrameArray = array of TsgeGraphicFrame;  //Массив кадров


  TsgeGraphicFrameList = class
  private
    FResources: TsgeResourceList;     //Указатель на список ресурсов

    FFrames: TsgeGraphicFrameArray;   //Список кадров
    FFileName: String;                //Имя файла

    function  GetCount: Integer;
    procedure SetFrame(Index: Integer; AFrame: TsgeGraphicFrame);
    function  GetFrame(Index: Integer): TsgeGraphicFrame;
    function  GetFrameAsString(AFrame: TsgeGraphicFrame): String;
  public
    constructor Create(AFrames: TsgeGraphicFrameArray);
    constructor Create(FileName: String; Resources: TsgeResourceList);
    constructor Create(Stream: TsgeMemoryStream; Resources: TsgeResourceList);
    destructor  Destroy; override;

    procedure Reload;

    procedure Clear;
    procedure Add(AFrame: TsgeGraphicFrame);
    procedure Delete(Index: Integer);
    procedure Insert(Index: Integer; AFrame: TsgeGraphicFrame);

    procedure FromString(Str: String);
    function  ToString: String; override;
    procedure LoadFromFile(FileName: String);
    procedure SaveToFile(FileName: String);
    procedure FromMemoryStream(Stream: TsgeMemoryStream);
    procedure ToMemoryStream(Stream: TsgeMemoryStream);

    property FileName: String read FFileName write FFileName;
    property Count: Integer read GetCount;
    property Frame[Index: Integer]: TsgeGraphicFrame read GetFrame write SetFrame;
  end;


implementation

uses
  sgeConst, sgeTypes, sgeStringList, sgeSimpleCommand, sgeFile,
  SysUtils;

const
  _UNITNAME = 'sgeGraphicFrameList';
  LineSeparator = #13#10;



function TsgeGraphicFrameList.GetCount: Integer;
begin
  Result := Length(FFrames);
end;


procedure TsgeGraphicFrameList.SetFrame(Index: Integer; AFrame: TsgeGraphicFrame);
var
  c: Integer;
begin
  c := Length(FFrames);
  if (Index < 0) or (Index > c) then
    raise EsgeException.Create(_UNITNAME, Err_IndexOutOfBounds, IntToStr(Index));

  FFrames[Index] := AFrame;
end;


function TsgeGraphicFrameList.GetFrame(Index: Integer): TsgeGraphicFrame;
var
  c: Integer;
begin
  c := Length(FFrames);
  if (Index < 0) or (Index > c) then
    raise EsgeException.Create(_UNITNAME, Err_IndexOutOfBounds, IntToStr(Index));

  Result := FFrames[Index];
end;


function TsgeGraphicFrameList.GetFrameAsString(AFrame: TsgeGraphicFrame): String;
begin
  Result := AFrame.SpriteName + ' ' +
            IntToStr(AFrame.Col) + ' ' +
            IntToStr(AFrame.Row) + ' ' +
            IntToStr(AFrame.Time);
end;


constructor TsgeGraphicFrameList.Create(AFrames: TsgeGraphicFrameArray);
var
  i, c: Integer;
begin
  Clear;
  c := Length(AFrames) - 1;
  SetLength(FFrames, c + 1);
  for i := 0 to c do
    FFrames[i] := AFrames[i];
end;


constructor TsgeGraphicFrameList.Create(FileName: String; Resources: TsgeResourceList);
begin
  FResources := Resources;
  FFileName := FileName;

  LoadFromFile(FFileName);
end;


constructor TsgeGraphicFrameList.Create(Stream: TsgeMemoryStream; Resources: TsgeResourceList);
begin
  FResources := Resources;
  FFileName := '';

  FromMemoryStream(Stream);
end;


destructor TsgeGraphicFrameList.Destroy;
begin
  Clear;
end;


procedure TsgeGraphicFrameList.Reload;
begin
  LoadFromFile(FFileName);
end;


procedure TsgeGraphicFrameList.Clear;
begin
  SetLength(FFrames, 0);
end;


procedure TsgeGraphicFrameList.Add(AFrame: TsgeGraphicFrame);
var
  c: Integer;
begin
  c := GetCount;
  SetLength(FFrames, c + 1);
  FFrames[c] := AFrame;
end;


procedure TsgeGraphicFrameList.Delete(Index: Integer);
var
  i, c: Integer;
begin
  c := GetCount - 1;
  if (Index < 0) or (Index > c) then
    raise EsgeException.Create(_UNITNAME, Err_IndexOutOfBounds, IntToStr(Index));

  for i := 0 to c - 1 do
    FFrames[i] := FFrames[i + 1];

  SetLength(FFrames, c);
end;


procedure TsgeGraphicFrameList.Insert(Index: Integer; AFrame: TsgeGraphicFrame);
var
  i, c: Integer;
begin
  c := Length(FFrames);
  if (Index < 0) or (Index > c) then
    raise EsgeException.Create(_UNITNAME, Err_IndexOutOfBounds, IntToStr(Index));

  SetLength(FFrames, c + 1);      //Добавить 1 кадр
  for i := c downto Index + 1 do  //Сместить кадры
    FFrames[i] := FFrames[i - 1];

  FFrames[Index] := AFrame;       //Вставить новый кадр
end;


procedure TsgeGraphicFrameList.FromString(Str: String);
var
  i, c, Cnt: Integer;
  Fr: TsgeGraphicFrame;
  aCol, aRow: Integer;
  TempFrames: TsgeGraphicFrameArray;
  Lines: TsgeStringList;
  Frm: TsgeSimpleCommand;
begin
  //Проверить на существование объекта
  if FResources = nil then
    raise EsgeException.Create(_UNITNAME, Err_ObjectIsEmpty, 'Resources');

  try
    //Подготовить классы
    Frm := TsgeSimpleCommand.Create;
    Lines := TsgeStringList.Create;
    Lines.Separator := LineSeparator;
    Lines.FromString(Trim(Str));
    Cnt := Lines.Count - 1;

    //Проверить на наличие одного кадра
    if Cnt < 0 then
      raise EsgeException.Create(_UNITNAME, Err_NoPartsToLoad);


    try
      SetLength(TempFrames, 0);

      for i := 0 to Cnt do
        begin
        //Почистить запись
        Fr.SpriteName := '';
        Fr.Sprite := nil;
        Fr.Col := 0;
        Fr.Row := 0;
        Fr.Time := 0;

        //Разобрать кадр на части
        Frm.Command := Lines.Part[i];

        //Проверитьт на наличие 4 частей
        if Frm.Count < 4 then
          raise EsgeException.Create(_UNITNAME, Err_NotEnoughParameters, Lines.Part[i]);

        //Определить имя кадра
        Fr.SpriteName := Frm.Part[0];
        Fr.Sprite := TsgeGraphicSprite(FResources.TypedObj[Frm.Part[0], rtGraphicSprite]);
        if Fr.Sprite = nil then
          raise EsgeException.Create(_UNITNAME, Err_SpriteNotFound, Frm.Part[0]);

        //Определить номер столбца
        if not TryStrToInt(Frm.Part[1], aCol) then
          raise EsgeException.Create(_UNITNAME, Err_UnableToDetermineColumn, Frm.Part[1]);
        Fr.Col := aCol;

        //Определить номер строки
        if not TryStrToInt(Frm.Part[2], aRow) then
          raise EsgeException.Create(_UNITNAME, Err_UnableToDetermineRow, Frm.Part[2]);
        Fr.Row := aRow;

        //Определить время видимости в строке милисекунды
        if not TryStrToInt(Frm.Part[3], Fr.Time) then
          raise EsgeException.Create(_UNITNAME, Err_UnableToDetermineTime, Frm.Part[3]);
        if Fr.Time < 1 then Fr.Time := 0;

        //Добавить во временный массив
        c := Length(TempFrames);
        SetLength(TempFrames, c + 1);
        TempFrames[c] := Fr;
        end;


    except
      on E: EsgeException do
        raise EsgeException.Create(_UNITNAME, Err_CantReadData, Lines.Part[i], E.Message);
    end;


    //Скопировать данные
    c := Length(TempFrames) - 1;
    SetLength(FFrames, c + 1);
    for i := 0 to c do
      FFrames[i] := TempFrames[i];


  finally
    SetLength(TempFrames, 0);
    Lines.Free;
    Frm.Free;
  end;
end;


function TsgeGraphicFrameList.ToString: String;
var
  i, c: Integer;
begin
  c := Length(FFrames) - 1;
  Result := '';
  for i := 0 to c do
    begin
    Result := Result + GetFrameAsString(FFrames[i]);
    if i <> c then Result := Result + LineSeparator;
    end;
end;


procedure TsgeGraphicFrameList.LoadFromFile(FileName: String);
var
  F: TsgeFile;
begin
  try

    try
      F := TsgeFile.Create(FileName, fmRead);
      FromString(F.AsString);
    except
      on E: EsgeException do
        raise EsgeException.Create(_UNITNAME, Err_FileReadError, FileName, E.Message);
    end;

  finally
    F.Free;
  end;
end;


procedure TsgeGraphicFrameList.SaveToFile(FileName: String);
var
  s: String;
  F: TsgeFile;
begin
  try

    try
      F := TsgeFile.Create(FileName, fmWrite);
      s := ToString;
      F.Size := 0;
      F.Write(s[1], Length(s));
    except
      raise EsgeException.Create(_UNITNAME, Err_FileWriteError, FileName);
    end;

  finally
    F.Free;
  end;
end;


procedure TsgeGraphicFrameList.FromMemoryStream(Stream: TsgeMemoryStream);
begin
  try
    FromString(Stream.ToString);
  except
    on E: EsgeException do
      raise EsgeException.Create(_UNITNAME, Err_CantLoadFromStream, '', E.Message);
  end;
end;


procedure TsgeGraphicFrameList.ToMemoryStream(Stream: TsgeMemoryStream);
begin
  Stream.FromString(ToString);
end;





end.


