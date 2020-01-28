{
Пакет             Simple Game Engine 1
Файл              sgeResourceList.pas
Версия            1.13
Создан            30.06.2018
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Хранилище загруженных ресурсов
}

unit sgeResourceList;

{$mode objfpc}{$H+}

interface

uses
  sgeStringList, sgeSimpleCommand, sgeSimpleParameters,
  sgeMemoryStream;


const
  //Типы ресурсов
  rtSystemFont        = 'sysfont';
  rtGraphicSprite     = 'sprite';
  rtGraphicFont       = 'font';
  rtGraphicFrames     = 'frames';
  rtGraphicAnimations = 'animation';
  rtSoundBuffer       = 'buffer';
  rtParameters        = 'parameters';



  //Имена команд
  rcSetParameter    = 'setparam';
  rcDeleteParameter = 'delparam';
  rcClearParameters = 'clearparams';
  rcLoadResource    = 'loadres';
  rcLoadTable       = 'loadtable';



type
  TsgeResource = record
    Name: String;
    rType: String;
    Obj: TObject;
    Group: String;
  end;


  TsgeResourceList = class
  private
    FResources: array of TsgeResource;

    function  GetCount: Integer;
    procedure SetItem(Index: Integer; AItem: TsgeResource);
    function  GetItem(Index: Integer): TsgeResource;
    procedure SetTypedItem(Name: String; rType: String; AItem: TsgeResource);
    function  GetTypedItem(Name: String; rType: String): TsgeResource;
    function  GetObject(Name: String): TObject;
    function  GetTypedObject(Name: String; rType: String): TObject;
  public
    constructor Create;
    destructor  Destroy; override;

    procedure Clear;
    procedure AddItem(AItem: TsgeResource);
    procedure AddItem(Name: String; rType: String; Obj: TObject; Group: String = '');
    procedure Delete(Index: Integer);
    procedure Delete(Name: String);
    procedure Delete(Name: String; rType: String);
    procedure DeleteByGroup(Group: String);
    function  IndexOf(Name: String): Integer;
    function  IndexOf(Name: String; rType: String): Integer;
    function  IndexOf(Obj: TObject): Integer;

    function  LoadResource_SystemFont(Stream: TsgeMemoryStream): TObject;
    function  LoadResource_GraphicFont(Cmd: TsgeSimpleCommand): TObject;
    function  LoadResource_GraphicSprite(Stream: TsgeMemoryStream; Cmd: TsgeSimpleCommand): TObject;
    function  LoadResource_GraphicFrames(Stream: TsgeMemoryStream): TObject;
    function  LoadResource_Parameters(Stream: TsgeMemoryStream): TObject;
    function  LoadResource_SoundBuffer(Stream: TsgeMemoryStream): TObject;
    function  LoadResource_GraphicAnimation(Stream: TsgeMemoryStream; Cmd: TsgeSimpleCommand): TObject;

    procedure Command_SetParam(Prm: TsgeSimpleParameters; Cmd: TsgeSimpleCommand);
    procedure Command_DeleteParam(Prm: TsgeSimpleParameters; Cmd: TsgeSimpleCommand);
    procedure Command_ClearParams(Prm: TsgeSimpleParameters);
    procedure Command_LoadResource(Cmd: TsgeSimpleCommand);
    procedure Command_LoadTable(Cmd: TsgeSimpleCommand);

    procedure LoadFromTable(FileName: String);

    property Count: Integer read GetCount;
    property Item[Index: Integer]: TsgeResource read GetItem write SetItem;
    property TypedItem[Name: String; rType: String]: TsgeResource read GetTypedItem write SetTypedItem;
    property Obj[Name: String]: TObject read GetObject;
    property TypedObj[Name: String; rType: String]: TObject read GetTypedObject;
  end;



implementation

uses
  sgeConst, sgeTypes, sgeObjectList, SimpleGameEngine,
  sgeSystemFont, sgeGraphicSprite, sgeGraphicFont, sgeGraphicFrameList, sgeSoundBuffer,
  sgeGraphicAnimation,
  SysUtils;


const
  _UNITNAME = 'sgeResourceList';


var
  SGE: TSimpleGameEngine;


function TsgeResourceList.GetCount: Integer;
begin
  Result := Length(FResources);
end;


procedure TsgeResourceList.SetItem(Index: Integer; AItem: TsgeResource);
var
  c: Integer;
begin
  c := GetCount - 1;
  if (Index < 0) or (Index > c) then
    raise EsgeException.Create(_UNITNAME, Err_IndexOutOfBounds, IntToStr(Index));

  FResources[Index] := AItem;
end;


function TsgeResourceList.GetItem(Index: Integer): TsgeResource;
var
  c: Integer;
begin
  c := GetCount - 1;
  if (Index < 0) or (Index > c) then
    raise EsgeException.Create(_UNITNAME, Err_IndexOutOfBounds, IntToStr(Index));

  Result := FResources[Index];
end;


procedure TsgeResourceList.SetTypedItem(Name: String; rType: String; AItem: TsgeResource);
var
  Idx: Integer;
begin
  Idx := IndexOf(Name, rType);
  if Idx = -1 then
    raise EsgeException.Create(_UNITNAME, Err_ResourceNotFound, Name + ', ' + rType);

  FResources[Idx] := AItem;
end;


function TsgeResourceList.GetTypedItem(Name: String; rType: String): TsgeResource;
var
  Idx: Integer;
begin
  Idx := IndexOf(Name, rType);
  if Idx = -1 then
    raise EsgeException.Create(_UNITNAME, Err_ResourceNotFound, Name + ', ' + rType);

  Result := FResources[Idx];
end;


function TsgeResourceList.GetObject(Name: String): TObject;
var
  Idx: Integer;
begin
  Result := nil;
  Idx := IndexOf(Name);
  if Idx = -1 then Exit;
  Result := FResources[Idx].Obj;
end;


function TsgeResourceList.GetTypedObject(Name: String; rType: String): TObject;
var
  Idx: Integer;
begin
  Result := nil;
  Idx := IndexOf(Name, rType);
  if Idx = -1 then Exit;
  Result := FResources[Idx].Obj;
end;


constructor TsgeResourceList.Create;
begin
  SGE := TSimpleGameEngine(ObjectList.NamedObject[Obj_SGE]);
end;


destructor TsgeResourceList.Destroy;
begin
  Clear;
end;


procedure TsgeResourceList.Clear;
var
  i, c: Integer;
begin
  c := GetCount - 1;
  for i := 0 to c do
    FResources[i].Obj.Free;
  SetLength(FResources, 0);
end;


procedure TsgeResourceList.AddItem(AItem: TsgeResource);
var
  c: Integer;
begin
  c := GetCount;
  SetLength(FResources, c + 1);
  FResources[c] := AItem;
end;


procedure TsgeResourceList.AddItem(Name: String; rType: String; Obj: TObject; Group: String);
var
  I: TsgeResource;
begin
  I.Name := Name;
  I.rType := rType;
  I.Obj := Obj;
  I.Group := Group;

  AddItem(I);
end;


procedure TsgeResourceList.Delete(Index: Integer);
var
  i, c: Integer;
begin
  c := GetCount - 1;
  if (Index < 0) or (Index > c) then
    raise EsgeException.Create(_UNITNAME, Err_IndexOutOfBounds, IntToStr(Index));

  FResources[Index].Obj.Free;

  for i := Index to c - 1 do
    FResources[i] := FResources[i + 1];
  SetLength(FResources, c);
end;


procedure TsgeResourceList.Delete(Name: String);
var
  Idx: Integer;
begin
  Idx := IndexOf(Name);
  if Idx = -1 then
    raise EsgeException.Create(_UNITNAME, Err_ResourceNotFound, Name);

  Delete(Idx);
end;


procedure TsgeResourceList.Delete(Name: String; rType: String);
var
  Idx: Integer;
begin
  Idx := IndexOf(Name, rType);
  if Idx = -1 then
    raise EsgeException.Create(_UNITNAME, Err_ResourceNotFound, Name);

  Delete(Idx);
end;


procedure TsgeResourceList.DeleteByGroup(Group: String);
var
  i: Integer;
begin
  Group := LowerCase(Group);

  i := -1;
  while i < GetCount - 1 do
    begin
    Inc(i);

    if LowerCase(FResources[i].Group) = Group then
      begin
      Delete(i);
      Dec(i)
      end;
    end;
end;


function TsgeResourceList.IndexOf(Name: String): Integer;
var
  i, c: Integer;
begin
  Result := -1;
  c := GetCount - 1;
  Name := LowerCase(Name);
  for i := 0 to c do
    if Name = LowerCase(FResources[i].Name) then
      begin
      Result := i;
      Break;
      end;
end;


function TsgeResourceList.IndexOf(Name: String; rType: String): Integer;
var
  i, c: Integer;
begin
  Result := -1;
  c := GetCount - 1;
  Name := LowerCase(Name);
  rType := LowerCase(rType);
  for i := 0 to c do
    if (Name = LowerCase(FResources[i].Name)) and (rType = LowerCase(FResources[i].rType)) then
      begin
      Result := i;
      Break;
      end;
end;


function TsgeResourceList.IndexOf(Obj: TObject): Integer;
var
  i, c: Integer;
begin
  Result := -1;
  c := GetCount - 1;
  for i := 0 to c do
    if FResources[i].Obj = Obj then
      begin
      Result := i;
      Break;
      end;

end;


function TsgeResourceList.LoadResource_SystemFont(Stream: TsgeMemoryStream): TObject;
begin
  Result := TsgeSystemFont.Create(Stream);
end;


function TsgeResourceList.LoadResource_GraphicFont(Cmd: TsgeSimpleCommand): TObject;
var
  Size: Integer;
  fAttr: TsgeGraphicFontAttrib;
  s: String;
  Name: String;
begin
  //Name
  if Cmd.Count >= 4 then Name := Cmd.Part[3] else Name := '';

  //Size
  Size := 12;
  if (Cmd.Count >= 5) then
    if not TryStrToInt(Cmd.Part[4], Size) then Size := 1;
  if Size < 1 then Size := 1;

  //Attrib
  fAttr := [];
  if (Cmd.Count >= 6) then
    begin
    s := LowerCase(Cmd.Part[5]);
    if Pos('b', s) <> 0 then Include(fAttr, gfaBold);
    if Pos('i', s) <> 0 then Include(fAttr, gfaItalic);
    if Pos('u', s) <> 0 then Include(fAttr, gfaUnderline);
    if Pos('s', s) <> 0 then Include(fAttr, gfaStrikeOut);
    end;

  Result := TsgeGraphicFont.Create(Name, Size, fAttr);
end;


function TsgeResourceList.LoadResource_GraphicSprite(Stream: TsgeMemoryStream; Cmd: TsgeSimpleCommand): TObject;
var
  Cols, Rows: Integer;
  MagFilter, MinFilter: TsgeGraphicSpriteFilter;
begin
  //Cols
  Cols := 1;
  if Cmd.Count >= 5 then
    if not TryStrToInt(Cmd.Part[4], Cols) then Cols := 1;
  if Cols < 1 then Cols := 1;

  //Rows
  Rows := 1;
  if Cmd.Count >= 6 then
    if not TryStrToInt(Cmd.Part[5], Rows) then Rows := 1;
  if Rows < 1 then Rows := 1;

  //MagFilter
  MagFilter := gsfNearest;
  if Cmd.Count >= 7 then
    if LowerCase(Cmd.Part[6]) = 'linear' then MagFilter := gsfLinear;

  //MinFilter
  MinFilter := gsfNearest;
  if Cmd.Count >= 8 then
    if LowerCase(Cmd.Part[7]) = 'linear' then MinFilter := gsfLinear;


  Result := TsgeGraphicSprite.Create(Stream, Cols, Rows, MagFilter, MinFilter);
end;


function TsgeResourceList.LoadResource_GraphicFrames(Stream: TsgeMemoryStream): TObject;
begin
  Result := TsgeGraphicFrameList.Create(Stream, Self);
end;


function TsgeResourceList.LoadResource_Parameters(Stream: TsgeMemoryStream): TObject;
begin
  Result := TsgeSimpleParameters.Create(Stream);
end;


function TsgeResourceList.LoadResource_SoundBuffer(Stream: TsgeMemoryStream): TObject;
begin
  Result := TsgeSoundBuffer.Create(Stream);
end;


function TsgeResourceList.LoadResource_GraphicAnimation(Stream: TsgeMemoryStream; Cmd: TsgeSimpleCommand): TObject;
var
  Width, Height: Integer;
begin
  //Width
  Width := 16;
  if Cmd.Count >= 5 then
    if not TryStrToInt(Cmd.Part[4], Width) then Width := 16;

  //Height
  Height := 16;
  if Cmd.Count >= 6 then
    if not TryStrToInt(Cmd.Part[5], Height) then Height := 16;

  Result := TsgeGraphicAnimation.Create(Stream, Width, Height, Self);
end;


procedure TsgeResourceList.Command_SetParam(Prm: TsgeSimpleParameters; Cmd: TsgeSimpleCommand);
begin
  if Cmd.Count < 3 then
    raise EsgeException.Create(_UNITNAME, Err_NotEnoughParameters);

  Prm.SetValue(Cmd.Part[1], Cmd.Part[2]);
end;


procedure TsgeResourceList.Command_DeleteParam(Prm: TsgeSimpleParameters; Cmd: TsgeSimpleCommand);
begin
  if Cmd.Count < 2 then
    raise EsgeException.Create(_UNITNAME, Err_NotEnoughParameters);

  Prm.Delete(Cmd.Part[1]);
end;


procedure TsgeResourceList.Command_ClearParams(Prm: TsgeSimpleParameters);
begin
  Prm.Clear;
end;


procedure TsgeResourceList.Command_LoadResource(Cmd: TsgeSimpleCommand);
var
  Idx: Integer;
  nm, rt, fn, ResType: String;
  ResObj: TObject;
  Stream: TsgeMemoryStream;
begin
  //Проверить количество частей
  if Cmd.Count < 4 then
    raise EsgeException.Create(_UNITNAME, Err_NotEnoughParameters);

  //Проверить на одинаковое имя
  nm := Cmd.Part[2];
  Idx := IndexOf(nm);
  if Idx <> -1 then
    raise EsgeException.Create(_UNITNAME, Err_DuplicateResource, nm);

  //Подготовить переменные
  ResObj := nil;
  rt := '';
  fn := Cmd.Part[3];

  //Загрузить файл в MemoryStream
  try
    Stream := TsgeMemoryStream.Create;

    try
      //Тип ресурса
      ResType := LowerCase(Cmd.Part[1]);

      //Прочитаем файл, если это не GraphicFont
      if ResType <> rtGraphicFont then SGE.FileSystem.ReadFile(fn, Stream);


      //Создать ресурс
      case ResType of
        rtGraphicSprite:
          begin
          ResObj := LoadResource_GraphicSprite(Stream, Cmd);
          TsgeGraphicSprite(ResObj).FileName := fn;
          rt := rtGraphicSprite;
          end;

        rtGraphicFont:
          begin
          ResObj := LoadResource_GraphicFont(Cmd);
          rt := rtGraphicFont;
          end;

        rtGraphicFrames:
          begin
          ResObj := LoadResource_GraphicFrames(Stream);
          TsgeGraphicFrameList(ResObj).FileName := fn;
          rt := rtGraphicFrames;
          end;

        rtGraphicAnimations:
          begin
          ResObj := LoadResource_GraphicAnimation(Stream, Cmd);
          TsgeGraphicAnimation(ResObj).FileName := fn;
          rt := rtGraphicAnimations;
          end;

        rtSystemFont:
          begin
          ResObj := LoadResource_SystemFont(Stream);
          TsgeSystemFont(ResObj).FileName := fn;
          rt := rtSystemFont;
          end;

        rtSoundBuffer:
          begin
          ResObj := LoadResource_SoundBuffer(Stream);
          TsgeSoundBuffer(ResObj).FileName := fn;
          rt := rtSoundBuffer;
          end;

        rtParameters:
          begin
          ResObj := LoadResource_Parameters(Stream);
          TsgeSimpleParameters(ResObj).FileName := fn;
          rt := rtParameters;
          end;

        else
          raise EsgeException.Create(_UNITNAME, Err_UnknownResource, Cmd.Part[1]);
      end;


    except
      on E: EsgeException do
        raise EsgeException.Create(_UNITNAME, Err_LoadResourceError, Cmd.Part[1], E.Message);
    end;



  finally
    Stream.Free;
  end;


  //Добавить в хранилище
  if ResObj <> nil then AddItem(nm, rt, ResObj);
end;


procedure TsgeResourceList.Command_LoadTable(Cmd: TsgeSimpleCommand);
begin
  if Cmd.Count < 2 then
    raise EsgeException.Create(_UNITNAME, Err_NotEnoughParameters);

  LoadFromTable(Cmd.Part[1]);
end;


procedure TsgeResourceList.LoadFromTable(FileName: String);
var
  Params: TsgeSimpleParameters;
  Lines: TsgeStringList;
  Cmd: TsgeSimpleCommand;
  Stream: TsgeMemoryStream;
  i, c: Integer;
begin
  //Проверить файл
  if not SGE.FileSystem.FileExists(FileName) then
    raise EsgeException.Create(_UNITNAME, Err_LoadResourceTableError, FileName, _UNITNAME + ';' + Err_FileNotFound);


  try
    //Подготовить классы
    Stream := TsgeMemoryStream.Create;
    Lines := TsgeStringList.Create;
    Params := TsgeSimpleParameters.Create;
    Cmd := TsgeSimpleCommand.Create;


    //Прочитать таблицу из файла
    try
      SGE.FileSystem.ReadFile(FileName, Stream);
    except
      raise EsgeException.Create(_UNITNAME, Err_LoadResourceTableError, FileName, _UNITNAME + ';' + Err_FileReadError);
    end;

    //Загрузить строки из памяти
    Lines.FromMemoryStream(Stream);


    //Пробежать по строкам
    c := Lines.Count - 1;
    for i := 0 to c do
      begin
      Lines.Part[i] := Trim(Lines.Part[i]);                         //Отрезать лишнее
      if Lines.Part[i] = '' then Continue;                          //Пусто
      if Lines.Part[i][1] = '#' then Continue;                      //Заметка
      Lines.Part[i] := sgeSubstituteParameterToString(Lines.Part[i], Params, '%', '%'); //Подставить в строку переменные
      Cmd.Command := Lines.Part[i];                                 //Разобрать на части

      try
        case LowerCase(Cmd.Part[0]) of
          rcClearParameters : Command_ClearParams(Params);
          rcSetParameter    : Command_SetParam(Params, Cmd);
          rcDeleteParameter : Command_DeleteParam(Params, Cmd);
          rcLoadTable       : Command_LoadTable(Cmd);
          rcLoadResource    : Command_LoadResource(Cmd);
          else
            raise EsgeException.Create(_UNITNAME, Err_UnknownCommand, Lines.Part[0]);
        end;
      except
        on E: EsgeException do
          raise EsgeException.Create(_UNITNAME, Err_LoadResourceTableError, FileName + ' [' + IntToStr(i + 1) + ']', E.Message);
      end;
      end;

  finally
    Stream.Free;
    Lines.Free;
    Cmd.Free;
    Params.Free;
  end;
end;





end.

