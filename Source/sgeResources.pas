{
Пакет             Simple Game Engine 1
Файл              sgeResources.pas
Версия            1.5
Создан            30.06.2018
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Хранилище загруженных ресурсов
}

unit sgeResources;

{$mode objfpc}{$H+}

interface

uses
  StringArray, SimpleCommand,
  sgeConst, sgeTypes, sgeParameters,
  SysUtils;


const
  //Типы ресурсов
  rtSystemFont        = 'sysfont';
  rtSystemIcon        = 'sysicon';
  rtSystemCursor      = 'syscursor';
  rtGraphicSprite     = 'sprite';
  rtGraphicFont       = 'font';
  rtGraphicFrames     = 'frames';
  rtSoundBuffer       = 'buffer';
  rtParameters        = 'params';


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
  end;


  TsgeResources = class
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
    destructor Destroy; override;

    procedure Clear;
    procedure AddItem(AItem: TsgeResource);
    procedure AddItem(Name: String; rType: String; Obj: TObject);
    procedure Delete(Index: Integer);
    procedure Delete(Name: String);
    procedure Delete(Name: String; rType: String);
    function  IndexOf(Name: String): Integer;
    function  IndexOf(Name: String; rType: String): Integer;
    function  IndexOf(Obj: TObject): Integer;

    function  LoadResource_SystemIcon(FileName: String): TObject;
    function  LoadResource_SystemCursor(FileName: String): TObject;
    function  LoadResource_SystemFont(FileName: String): TObject;
    function  LoadResource_GraphicFont(FileName: String; Line: PStringArray): TObject;
    function  LoadResource_GraphicSprite(FileName: String; Line: PStringArray): TObject;
    function  LoadResource_GraphicFrames(FileName: String): TObject;
    function  LoadResource_Parameters(FileName: String): TObject;
    function  LoadResource_SoundBuffer(FileName: String): TObject;

    procedure Command_SetParam(Prm: TsgeParameters; Line: PStringArray);
    procedure Command_DeleteParam(Prm: TsgeParameters; Line: PStringArray);
    procedure Command_ClearParams(Prm: TsgeParameters);
    procedure Command_LoadResource(BasePath: String; Line: PStringArray);
    procedure Command_LoadTable(BasePath: String; Line: PStringArray);

    procedure LoadFromTable(FullFileName: String);

    property Count: Integer read GetCount;
    property Item[Index: Integer]: TsgeResource read GetItem write SetItem;
    property TypedItem[Name: String; rType: String]: TsgeResource read GetTypedItem write SetTypedItem;
    property Obj[Name: String]: TObject read GetObject;
    property TypedObj[Name: String; rType: String]: TObject read GetTypedObject;
  end;



implementation

uses
  sgeSystemIcon, sgeSystemCursor, sgeSystemFont, sgeGraphicSprite, sgeGraphicFont, sgeGraphicFrames,
  sgeSoundBuffer;


const
  _UNITNAME = 'sgeResources';



function TsgeResources.GetCount: Integer;
begin
  Result := Length(FResources);
end;


procedure TsgeResources.SetItem(Index: Integer; AItem: TsgeResource);
var
  c: Integer;
begin
  c := GetCount - 1;
  if (Index < 0) or (Index > c) then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_IndexOutOfBounds, IntToStr(Index)));

  FResources[Index] := AItem;
end;


function TsgeResources.GetItem(Index: Integer): TsgeResource;
var
  c: Integer;
begin
  c := GetCount - 1;
  if (Index < 0) or (Index > c) then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_IndexOutOfBounds, IntToStr(Index)));

  Result := FResources[Index];
end;


procedure TsgeResources.SetTypedItem(Name: String; rType: String; AItem: TsgeResource);
var
  Idx: Integer;
begin
  Idx := IndexOf(Name, rType);
  if Idx = -1 then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_ResourceNotFound, Name + ', ' + rType));

  FResources[Idx] := AItem;
end;


function TsgeResources.GetTypedItem(Name: String; rType: String): TsgeResource;
var
  Idx: Integer;
begin
  Idx := IndexOf(Name, rType);
  if Idx = -1 then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_ResourceNotFound, Name + ', ' + rType));

  Result := FResources[Idx];
end;


function TsgeResources.GetObject(Name: String): TObject;
var
  Idx: Integer;
begin
  Result := nil;
  Idx := IndexOf(Name);
  if Idx = -1 then Exit;
  Result := FResources[Idx].Obj;
end;


function TsgeResources.GetTypedObject(Name: String; rType: String): TObject;
var
  Idx: Integer;
begin
  Result := nil;
  Idx := IndexOf(Name, rType);
  if Idx = -1 then Exit;
  Result := FResources[Idx].Obj;
end;


destructor TsgeResources.Destroy;
begin
  Clear;
end;


procedure TsgeResources.Clear;
var
  i, c: Integer;
begin
  c := GetCount - 1;
  for i := 0 to c do
    FResources[i].Obj.Free;
  SetLength(FResources, 0);
end;


procedure TsgeResources.AddItem(AItem: TsgeResource);
var
  c: Integer;
begin
  c := GetCount;
  SetLength(FResources, c + 1);
  FResources[c] := AItem;
end;


procedure TsgeResources.AddItem(Name: String; rType: String; Obj: TObject);
var
  I: TsgeResource;
begin
  I.Name := Name;
  I.rType := rType;
  I.Obj := Obj;
  AddItem(I);
end;


procedure TsgeResources.Delete(Index: Integer);
var
  i, c: Integer;
begin
  c := GetCount;
  if (Index < 0) or (Index > c) then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_IndexOutOfBounds, IntToStr(Index)));

  FResources[Index].Obj.Free;

  Dec(c, 2);
  for i := Index to c do
    FResources[i] := FResources[i + 1];
  SetLength(FResources, c + 1);
end;


procedure TsgeResources.Delete(Name: String);
var
  Idx: Integer;
begin
  Idx := IndexOf(Name);
  if Idx = -1 then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_ResourceNotFound, Name));

  Delete(Idx);
end;


procedure TsgeResources.Delete(Name: String; rType: String);
var
  Idx: Integer;
begin
  Idx := IndexOf(Name, rType);
  if Idx = -1 then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_ResourceNotFound, Name));

  Delete(Idx);
end;


function TsgeResources.IndexOf(Name: String): Integer;
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


function TsgeResources.IndexOf(Name: String; rType: String): Integer;
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


function TsgeResources.IndexOf(Obj: TObject): Integer;
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


function TsgeResources.LoadResource_SystemIcon(FileName: String): TObject;
begin
  Result := TsgeSystemIcon.CreateFromFile(FileName);
end;


function TsgeResources.LoadResource_SystemCursor(FileName: String): TObject;
begin
  Result := TsgeSystemCursor.CreateFromFile(FileName);
end;


function TsgeResources.LoadResource_SystemFont(FileName: String): TObject;
begin
  Result := TsgeSystemFont.Create(FileName);
end;


function TsgeResources.LoadResource_GraphicFont(FileName: String; Line: PStringArray): TObject;
var
  Size: Integer;
  fAttr: TsgeGraphicFontAttrib;
  s: String;
begin
  //Size
  Size := 12;
  if StringArray_Equal(Line, 5) then
    if not TryStrToInt(Line^[4], Size) then Size := 1;
  if Size < 1 then Size := 1;

  //Attrib
  fAttr := [];
  if StringArray_Equal(@Line, 6) then
    begin
    s := LowerCase(Line^[5]);
    if Pos('b', s) <> 0 then Include(fAttr, gfaBold);
    if Pos('i', s) <> 0 then Include(fAttr, gfaItalic);
    if Pos('u', s) <> 0 then Include(fAttr, gfaUnderline);
    if Pos('s', s) <> 0 then Include(fAttr, gfaStrikeOut);
    end;

  Result := TsgeGraphicFont.Create(FileName, Size, fAttr);
end;


function TsgeResources.LoadResource_GraphicSprite(FileName: String; Line: PStringArray): TObject;
var
  Cols, Rows: Integer;
  MagFilter, MinFilter: TsgeGraphicSpriteFilter;
begin
  //Cols
  Cols := 1;
  if StringArray_Equal(Line, 5) then
    if not TryStrToInt(Line^[4], Cols) then Cols := 1;
  if Cols < 1 then Cols := 1;

  //Rows
  Rows := 1;
  if StringArray_Equal(Line, 6) then
    if not TryStrToInt(Line^[5], Rows) then Rows := 1;
  if Rows < 1 then Rows := 1;

  //MagFilter
  MagFilter := gsfNearest;
  if StringArray_Equal(Line, 7) then
    if LowerCase(Line^[6]) = 'linear' then MagFilter := gsfLinear;

  //MinFilter
  MinFilter := gsfNearest;
  if StringArray_Equal(Line, 8) then
    if LowerCase(Line^[7]) = 'linear' then MinFilter := gsfLinear;

  Result := TsgeGraphicSprite.Create(FileName, Cols, Rows, MagFilter, MinFilter);
end;


function TsgeResources.LoadResource_GraphicFrames(FileName: String): TObject;
begin
  Result := TsgeGraphicFrames.Create(FileName, Self);
end;


function TsgeResources.LoadResource_Parameters(FileName: String): TObject;
begin
  Result := TsgeParameters.Create;
  TsgeParameters(Result).LoadFromFile(FileName);
end;


function TsgeResources.LoadResource_SoundBuffer(FileName: String): TObject;
begin
  Result := TsgeSoundBuffer.Create(FileName);
end;


procedure TsgeResources.Command_SetParam(Prm: TsgeParameters; Line: PStringArray);
begin
  if not StringArray_Equal(Line, 3) then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_NotEnoughParameters));

  if not Prm.SetString(Line^[1], Line^[2]) then Prm.Add(Line^[1], Line^[2]);
end;


procedure TsgeResources.Command_DeleteParam(Prm: TsgeParameters; Line: PStringArray);
begin
  if not StringArray_Equal(Line, 2) then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_NotEnoughParameters));

  Prm.Delete(Line^[1]);
end;


procedure TsgeResources.Command_ClearParams(Prm: TsgeParameters);
begin
  Prm.Clear;
end;


procedure TsgeResources.Command_LoadResource(BasePath: String; Line: PStringArray);
var
  Idx: Integer;
  nm, rt, fn: String;
  ResObj: TObject;
begin
  //Проверить количество частей
  if not StringArray_Equal(Line, 4) then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_NotEnoughParameters));

  //Проверить на одинаковое имя
  nm := Line^[2];
  Idx := IndexOf(nm);
  if Idx <> -1 then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_DuplicateResource, nm));

  //Подготовить переменные
  ResObj := nil;
  rt := '';
  fn := BasePath + Line^[3];

  //Создать ресурс
  case LowerCase(Line^[1]) of
    rtGraphicSprite:
      begin
      ResObj := LoadResource_GraphicSprite(fn, Line);
      rt := rtGraphicSprite;
      end;

    rtGraphicFont:
      begin
      ResObj := LoadResource_GraphicFont(fn, Line);
      rt := rtGraphicFont;
      end;

    rtGraphicFrames:
      begin
      ResObj := LoadResource_GraphicFrames(fn);
      rt := rtGraphicFrames;
      end;

    rtSystemFont:
      begin
      ResObj := LoadResource_SystemFont(fn);
      rt := rtSystemFont;
      end;

    rtSystemIcon:
      begin
      ResObj := LoadResource_SystemIcon(fn);
      rt := rtSystemIcon;
      end;

    rtSystemCursor:
      begin
      ResObj := LoadResource_SystemCursor(fn);
      rt := rtSystemCursor;
      end;

    rtSoundBuffer:
      begin
      ResObj := LoadResource_SoundBuffer(fn);
      rt := rtSoundBuffer;
      end;

    rtParameters:
      begin
      ResObj := LoadResource_Parameters(fn);
      rt := rtParameters;
      end;

    else
      raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_UnknownResource, Line^[1]));
  end;

  //Добавить в хранилище
  if ResObj <> nil then AddItem(nm, rt, ResObj);
end;


procedure TsgeResources.Command_LoadTable(BasePath: String; Line: PStringArray);
begin
  if not StringArray_Equal(Line, 2) then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_NotEnoughParameters));

  LoadFromTable(BasePath + Line^[1]);
end;


procedure TsgeResources.LoadFromTable(FullFileName: String);
var
  Params: TsgeParameters;
  sa, Line: TStringArray;
  BasePath: String;
  i, c: Integer;
begin
  //Проверить файл
  if not FileExists(FullFileName) then
    raise EsgeException.Create(sgeFoldErrorString(sgeCreateErrorString(_UNITNAME, Err_LoadResourceTableError, FullFileName), sgeCreateErrorString(_UNITNAME, Err_FileNotFound)));

  //Прочитать
  if not StringArray_LoadFromFile(@sa, FullFileName) then
    raise EsgeException.Create(sgeFoldErrorString(sgeCreateErrorString(_UNITNAME, Err_LoadResourceTableError, FullFileName), sgeCreateErrorString(_UNITNAME, Err_FileReadError)));


  try
    //Подготовить переменные
    BasePath := ExtractFilePath(FullFileName);
    Params := TsgeParameters.Create;

    //Пробежать по строкам
    c := StringArray_GetCount(@sa) - 1;
    for i := 0 to c do
      begin
      sa[i] := Trim(sa[i]);                         //Отрезать лишнее
      if sa[i] = '' then Continue;                  //Пусто
      if sa[i][1] = '#' then Continue;              //Заметка
      sa[i] := Params.Substitute(sa[i], '%', '%');  //Подставить в строку переменные
      SimpleCommand_Disassemble(@Line, sa[i]);      //Разобрать

      try
        case LowerCase(Line[0]) of
          rcClearParameters : Command_ClearParams(Params);
          rcSetParameter    : Command_SetParam(Params, @Line);
          rcDeleteParameter : Command_DeleteParam(Params, @Line);
          rcLoadTable       : Command_LoadTable(BasePath, @Line);
          rcLoadResource    : Command_LoadResource(BasePath, @Line);
          else
            raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_UnknownCommand, Line[0]));
        end;
      except
        on E: EsgeException do
          raise EsgeException.Create(sgeFoldErrorString(sgeCreateErrorString(_UNITNAME, Err_LoadResourceTableError, FullFileName + ' [' + IntToStr(i + 1) + ']'), E.Message));
      end;
      end;

  finally
    StringArray_Clear(@sa);
    StringArray_Clear(@Line);
    Params.Free;
  end;
end;





end.

