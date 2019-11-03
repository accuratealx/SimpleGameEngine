{
Пакет             Simple Game Engine 1
Файл              sgeResources.pas
Версия            1.3
Создан            30.06.2018
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Хранилище загруженных ресурсов
}

unit sgeResources;

{$mode objfpc}{$H+}

interface

uses
  sgeConst, sgeTypes,
  SysUtils;


const
  rtGraphicSprite     = 'graphicsprite';
  rtGraphicFont       = 'graphicfont';
  rtGraphicFrames     = 'graphicframes';
  rtSystemFont        = 'systemfont';
  rtSystemIcon        = 'systemicon';
  rtSystemCursor      = 'systemcursor';
  rtSoundBuffer       = 'soundbuffer';
  rtParameters        = 'parameters';


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

    property Count: Integer read GetCount;
    property Item[Index: Integer]: TsgeResource read GetItem write SetItem;
    property TypedItem[Name: String; rType: String]: TsgeResource read GetTypedItem write SetTypedItem;
    property Obj[Name: String]: TObject read GetObject;
    property TypedObj[Name: String; rType: String]: TObject read GetTypedObject;
  end;



implementation


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
    raise EsgeException.Create(Err_sgeResources + Err_Separator + Err_sgeResources_IndexOutOfBounds + Err_Separator + IntToStr(Index));

  FResources[Index] := AItem;
end;


function TsgeResources.GetItem(Index: Integer): TsgeResource;
var
  c: Integer;
begin
  c := GetCount - 1;
  if (Index < 0) or (Index > c) then
    raise EsgeException.Create(Err_sgeResources + Err_Separator + Err_sgeResources_IndexOutOfBounds + Err_Separator + IntToStr(Index));

  Result := FResources[Index];
end;


procedure TsgeResources.SetTypedItem(Name: String; rType: String; AItem: TsgeResource);
var
  Idx: Integer;
begin
  Idx := IndexOf(Name, rType);
  if Idx = -1 then
    raise EsgeException.Create(Err_sgeResources + Err_Separator + Err_sgeResources_TypedResourceNotFound + Err_Separator + Name + ', ' + rType);

  FResources[Idx] := AItem;
end;


function TsgeResources.GetTypedItem(Name: String; rType: String): TsgeResource;
var
  Idx: Integer;
begin
  Idx := IndexOf(Name, rType);
  if Idx = -1 then
    raise EsgeException.Create(Err_sgeResources + Err_Separator + Err_sgeResources_TypedResourceNotFound + Err_Separator + Name + ', ' + rType);

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
    raise EsgeException.Create(Err_sgeResources + Err_Separator + Err_sgeResources_IndexOutOfBounds + Err_Separator + IntToStr(Index));

  //Почистить память от объекта
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
    raise EsgeException.Create(Err_sgeResources + Err_Separator + Err_sgeResources_ResourceNotFound + Err_Separator + Name);

  Delete(Idx);
end;


procedure TsgeResources.Delete(Name: String; rType: String);
var
  Idx: Integer;
begin
  Idx := IndexOf(Name, rType);
  if Idx = -1 then
    raise EsgeException.Create(Err_sgeResources + Err_Separator + Err_sgeResources_ResourceNotFound + Err_Separator + Name);

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





end.

