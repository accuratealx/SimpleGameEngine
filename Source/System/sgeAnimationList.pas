{
Пакет             Simple Game Engine 1
Файл              sgeAnimationList.pas
Версия            1.0
Создан            03.02.2020
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Именованное хранилище анимаций
}

unit sgeAnimationList;

{$mode objfpc}{$H+}

interface

uses
  sgeGraphicAnimation;



type
  TsgeAnimation = record
    Name: String;
    Anim: TsgeGraphicAnimation;
  end;


  TsgeAnimationList = class
  private
    FAnimations: array of TsgeAnimation;

    function  GetCount: Integer;
    procedure SetItem(Index: Integer; Anim: TsgeAnimation);
    function  GetItem(Index: Integer): TsgeAnimation;
    procedure SetNamedItem(Name: String; Anim: TsgeAnimation);
    function  GetNamedItem(Name: String): TsgeAnimation;
  public
    destructor Destroy; override;

    procedure Clear;
    procedure Add(Anim: TsgeAnimation);
    procedure Add(Name: String; Animation: TsgeGraphicAnimation);
    procedure Delete(Index: Integer);
    procedure Delete(Name: String);
    function  IndexOf(Name: String): Integer;

    property Count: Integer read GetCount;
    property Item[Index: Integer]: TsgeAnimation read GetItem write SetItem;
    property NamedItem[Name: String]: TsgeAnimation read GetNamedItem write SetNamedItem;
  end;


implementation

uses
  sgeConst, sgeTypes,
  SysUtils;


const
  _UNITNAME = 'sgeAnimationList';



function TsgeAnimationList.GetCount: Integer;
begin
  Result := Length(FAnimations);
end;


procedure TsgeAnimationList.SetItem(Index: Integer; Anim: TsgeAnimation);
var
  c: Integer;
begin
  c := GetCount - 1;
  if (Index < 0) or (Index > c) then
    raise EsgeException.Create(_UNITNAME, Err_IndexOutOfBounds, IntToStr(Index));

  FAnimations[Index] := Anim;
end;


function TsgeAnimationList.GetItem(Index: Integer): TsgeAnimation;
var
  c: Integer;
begin
  c := GetCount - 1;
  if (Index < 0) or (Index > c) then
    raise EsgeException.Create(_UNITNAME, Err_IndexOutOfBounds, IntToStr(Index));

  Result := FAnimations[Index];
end;


procedure TsgeAnimationList.SetNamedItem(Name: String; Anim: TsgeAnimation);
var
  Idx: Integer;
begin
  Idx := IndexOf(Name);
  if Idx = -1 then
    raise EsgeException.Create(_UNITNAME, Err_NameNotFound, Name);

  FAnimations[Idx] := Anim;
end;


function TsgeAnimationList.GetNamedItem(Name: String): TsgeAnimation;
var
  Idx: Integer;
begin
  Idx := IndexOf(Name);
  if Idx = -1 then
    raise EsgeException.Create(_UNITNAME, Err_NameNotFound, Name);

  Result := FAnimations[Idx];
end;


destructor TsgeAnimationList.Destroy;
begin
  Clear;
end;

procedure TsgeAnimationList.Clear;
var
  i, c: Integer;
begin
  c := GetCount - 1;
  for i := 0 to c do
    FAnimations[i].Anim.Free;

  SetLength(FAnimations, 0);
end;


procedure TsgeAnimationList.Add(Anim: TsgeAnimation);
var
  c, Idx: Integer;
begin
   Idx := IndexOf(Anim.Name);
  if Idx <> -1 then
    raise EsgeException.Create(_UNITNAME, Err_DuplicateName, Anim.Name);

  c := GetCount;
  SetLength(FAnimations, c + 1);
  FAnimations[c] := Anim;
end;


procedure TsgeAnimationList.Add(Name: String; Animation: TsgeGraphicAnimation);
var
  A: TsgeAnimation;
begin
  A.Name := Name;
  A.Anim := Animation;

  Add(A);
end;


procedure TsgeAnimationList.Delete(Index: Integer);
var
  i, c: Integer;
begin
  c := GetCount - 1;
  if (Index < 0) or (Index > c) then
    raise EsgeException.Create(_UNITNAME, Err_IndexOutOfBounds, IntToStr(Index));

  FAnimations[Index].Anim.Free;

  for i := Index to c - 1 do
    FAnimations[i] := FAnimations[i + 1];

  SetLength(FAnimations, c);
end;


procedure TsgeAnimationList.Delete(Name: String);
var
  Idx: Integer;
begin
  Idx := IndexOf(Name);
  if Idx = -1 then
    raise EsgeException.Create(_UNITNAME, Err_NameNotFound, Name);

  Delete(Idx);
end;


function TsgeAnimationList.IndexOf(Name: String): Integer;
var
  i, c: Integer;
begin
  Result := -1;

  c := GetCount - 1;
  Name := LowerCase(Name);
  for i := 0 to c do
    if Name = LowerCase(FAnimations[i].Name) then
      begin
      Result := i;
      Break;
      end;
end;


end.

