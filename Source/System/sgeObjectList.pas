{
Пакет             Simple Game Engine 1
Файл              sgeObjectList.pas
Версия            1.2
Создан            02.02.2020
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Класс хранения глобальных именованных объектов
}

unit sgeObjectList;

{$mode objfpc}{$H+}{$Warnings Off}{$Hints Off}

interface


type
  //Запись одного объекта
  TsgeObject = record
    Group: String;
    Name: String;
    Obj: TObject;
  end;


  TsgeObjectList = class
  private
    FObjects: array of TsgeObject;

    function  GetCount: Integer;
    procedure SetItem(Index: Integer; ObjRec: TsgeObject);
    function  GetItem(Index: Integer): TsgeObject;
    procedure SetNamedItem(Name: String; ObjRec: TsgeObject);
    function  GetNamedItem(Name: String): TsgeObject;
    procedure SetNamedObject(Name: String; Obj: TObject);
    function  GetNamedObject(Name: String): TObject;
  public
    destructor Destroy; override;

    procedure Clear;
    procedure Add(ObjRec: TsgeObject);
    procedure Add(Name: String; Obj: TObject; Group: String = '');
    procedure Delete(Index: Integer);
    procedure Delete(Name: String);
    procedure DeleteByGroup(Group: String);
    function  IndexOf(Name: String): Integer;

    property Count: Integer read GetCount;
    property Item[Index: Integer]: TsgeObject read GetItem write SetItem;
    property NamedItem[Name: String]: TsgeObject read GetNamedItem write SetNamedItem;
    property NamedObject[Name: String]: TObject read GetNamedObject write SetNamedObject;
  end;


var
  ObjectList: TsgeObjectList;


implementation


uses
  sgeConst, sgeTypes,
  SysUtils;


const
  _UNITNAME = 'sgeObjectList';


function TsgeObjectList.GetCount: Integer;
begin
  Result := Length(FObjects);
end;


procedure TsgeObjectList.SetItem(Index: Integer; ObjRec: TsgeObject);
var
  c: Integer;
begin
  c := GetCount - 1;
  if (Index < 0) or (Index > c) then
    raise EsgeException.Create(_UNITNAME, Err_IndexOutOfBounds, IntToStr(Index));

  FObjects[Index] := ObjRec;
end;


function TsgeObjectList.GetItem(Index: Integer): TsgeObject;
var
  c: Integer;
begin
  c := GetCount - 1;
  if (Index < 0) or (Index > c) then
    raise EsgeException.Create(_UNITNAME, Err_IndexOutOfBounds, IntToStr(Index));

  Result := FObjects[Index];
end;


procedure TsgeObjectList.SetNamedItem(Name: String; ObjRec: TsgeObject);
var
  Idx: Integer;
begin
  Idx := IndexOf(Name);
  if Idx = -1 then
    raise EsgeException.Create(_UNITNAME, Err_NameNotFound, Name);

  FObjects[Idx] := ObjRec;
end;


function TsgeObjectList.GetNamedItem(Name: String): TsgeObject;
var
  Idx: Integer;
begin
  Idx := IndexOf(Name);
  if Idx = -1 then
    raise EsgeException.Create(_UNITNAME, Err_NameNotFound, Name);

  Result := FObjects[Idx];
end;


procedure TsgeObjectList.SetNamedObject(Name: String; Obj: TObject);
var
  Idx: Integer;
begin
  Idx := IndexOf(Name);
  if Idx = -1 then
    raise EsgeException.Create(_UNITNAME, Err_NameNotFound, Name);

  FObjects[Idx].Obj := Obj;
end;


function TsgeObjectList.GetNamedObject(Name: String): TObject;
var
  Idx: Integer;
begin
  Idx := IndexOf(Name);
  if Idx = -1 then
    raise EsgeException.Create(_UNITNAME, Err_NameNotFound, Name);

  Result := FObjects[Idx].Obj;
end;


destructor TsgeObjectList.Destroy;
begin
  Clear;
end;


procedure TsgeObjectList.Clear;
begin
  SetLength(FObjects, 0);
end;


procedure TsgeObjectList.Add(ObjRec: TsgeObject);
var
  c, Idx: Integer;
begin
   Idx := IndexOf(ObjRec.Name);
  if Idx <> -1 then
    raise EsgeException.Create(_UNITNAME, Err_DuplicateName, ObjRec.Name);

  c := GetCount;
  SetLength(FObjects, c + 1);
  FObjects[c] := ObjRec;
end;


procedure TsgeObjectList.Add(Name: String; Obj: TObject; Group: String);
var
  O: TsgeObject;
begin
  O.Group := Group;
  O.Name := Name;
  O.Obj := Obj;

  Add(O);
end;


procedure TsgeObjectList.Delete(Index: Integer);
var
  i, c: Integer;
begin
  c := GetCount - 1;
  if (Index < 0) or (Index > c) then
    raise EsgeException.Create(_UNITNAME, Err_IndexOutOfBounds, IntToStr(Index));

  for i := Index to c - 1 do
    FObjects[i] := FObjects[i + 1];

  SetLength(FObjects, c);
end;


procedure TsgeObjectList.Delete(Name: String);
var
  Idx: Integer;
begin
  Idx := IndexOf(Name);
  if Idx = -1 then
    raise EsgeException.Create(_UNITNAME, Err_NameNotFound, Name);

  Delete(Idx);
end;


procedure TsgeObjectList.DeleteByGroup(Group: String);
var
  i: Integer;
begin
  Group := LowerCase(Group);

  i := -1;
  while i < GetCount - 1 do
    begin
    Inc(i);

    if LowerCase(FObjects[i].Group) = Group then
      begin
      Delete(i);
      Dec(i)
      end;
    end;
end;


function TsgeObjectList.IndexOf(Name: String): Integer;
var
  i, c: Integer;
begin
  Result := -1;

  c := GetCount - 1;
  Name := LowerCase(Name);
  for i := 0 to c do
    if Name = LowerCase(FObjects[i].Name) then
      begin
      Result := i;
      Break;
      end;
end;





initialization
begin
  ObjectList := TsgeObjectList.Create;
end;


finalization
begin
  ObjectList.Free;
end;


end.

