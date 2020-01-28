{
Пакет             Simple Game Engine 1
Файл              sgeSpriteList.pas
Версия            1.0
Создан            04.05.2020
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Именованное хранилище спрайтов
}

unit sgeSpriteList;

{$mode objfpc}{$H+}

interface

uses
  sgeGraphicSprite;



type
  TsgeSprite = record
    Name: String;
    Sprite: TsgeGraphicSprite;
  end;


  TsgeSpriteList = class
  private
    FSprites: array of TsgeSprite;

    function  GetCount: Integer;
    procedure SetItem(Index: Integer; Sprite: TsgeSprite);
    function  GetItem(Index: Integer): TsgeSprite;
    procedure SetNamedItem(Name: String; Sprite: TsgeSprite);
    function  GetNamedItem(Name: String): TsgeSprite;
  public
    destructor Destroy; override;

    procedure Clear;
    procedure Add(Sprite: TsgeSprite);
    procedure Add(Name: String; SpriteObj: TsgeGraphicSprite);
    procedure Delete(Index: Integer);
    procedure Delete(Name: String);
    function  IndexOf(Name: String): Integer;

    property Count: Integer read GetCount;
    property Item[Index: Integer]: TsgeSprite read GetItem write SetItem;
    property NamedItem[Name: String]: TsgeSprite read GetNamedItem write SetNamedItem;
  end;


implementation

uses
  sgeConst, sgeTypes,
  SysUtils;


const
  _UNITNAME = 'sgeSpriteList';



function TsgeSpriteList.GetCount: Integer;
begin
  Result := Length(FSprites);
end;


procedure TsgeSpriteList.SetItem(Index: Integer; Sprite: TsgeSprite);
var
  c: Integer;
begin
  c := GetCount - 1;
  if (Index < 0) or (Index > c) then
    raise EsgeException.Create(_UNITNAME, Err_IndexOutOfBounds, IntToStr(Index));

  FSprites[Index] := Sprite;
end;


function TsgeSpriteList.GetItem(Index: Integer): TsgeSprite;
var
  c: Integer;
begin
  c := GetCount - 1;
  if (Index < 0) or (Index > c) then
    raise EsgeException.Create(_UNITNAME, Err_IndexOutOfBounds, IntToStr(Index));

  Result := FSprites[Index];
end;


procedure TsgeSpriteList.SetNamedItem(Name: String; Sprite: TsgeSprite);
var
  Idx: Integer;
begin
  Idx := IndexOf(Name);
  if Idx = -1 then
    raise EsgeException.Create(_UNITNAME, Err_NameNotFound, Name);

  FSprites[Idx] := Sprite;
end;


function TsgeSpriteList.GetNamedItem(Name: String): TsgeSprite;
var
  Idx: Integer;
begin
  Idx := IndexOf(Name);
  if Idx = -1 then
    raise EsgeException.Create(_UNITNAME, Err_NameNotFound, Name);

  Result := FSprites[Idx];
end;


destructor TsgeSpriteList.Destroy;
begin
  Clear;
end;

procedure TsgeSpriteList.Clear;
{var
  i, c: Integer;}
begin
  {c := GetCount - 1;
  for i := 0 to c do
    FSprites[i].Sprite.Free;}

  SetLength(FSprites, 0);
end;


procedure TsgeSpriteList.Add(Sprite: TsgeSprite);
var
  c, Idx: Integer;
begin
   Idx := IndexOf(Sprite.Name);
  if Idx <> -1 then
    raise EsgeException.Create(_UNITNAME, Err_DuplicateName, Sprite.Name);

  c := GetCount;
  SetLength(FSprites, c + 1);
  FSprites[c] := Sprite;
end;


procedure TsgeSpriteList.Add(Name: String; SpriteObj: TsgeGraphicSprite);
var
  A: TsgeSprite;
begin
  A.Name := Name;
  A.Sprite := SpriteObj;

  Add(A);
end;


procedure TsgeSpriteList.Delete(Index: Integer);
var
  i, c: Integer;
begin
  c := GetCount - 1;
  if (Index < 0) or (Index > c) then
    raise EsgeException.Create(_UNITNAME, Err_IndexOutOfBounds, IntToStr(Index));

  //FSprites[Index].Sprite.Free;

  for i := Index to c - 1 do
    FSprites[i] := FSprites[i + 1];

  SetLength(FSprites, c);
end;


procedure TsgeSpriteList.Delete(Name: String);
var
  Idx: Integer;
begin
  Idx := IndexOf(Name);
  if Idx = -1 then
    raise EsgeException.Create(_UNITNAME, Err_NameNotFound, Name);

  Delete(Idx);
end;


function TsgeSpriteList.IndexOf(Name: String): Integer;
var
  i, c: Integer;
begin
  Result := -1;

  c := GetCount - 1;
  Name := LowerCase(Name);
  for i := 0 to c do
    if Name = LowerCase(FSprites[i].Name) then
      begin
      Result := i;
      Break;
      end;
end;


end.

