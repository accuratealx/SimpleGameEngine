{
Пакет             Simple Game Engine 1
Файл              sgeColoredLines.pas
Версия            1.2
Создан            09.12.2018
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Массив цветных линий
}

unit sgeColoredLines;

{$mode objfpc}{$H+}

interface

uses
  StringArray,
  sgeConst, sgeTypes, sgeGraphicColor,
  SysUtils;


type
  TsgeColorLine = record
    Color: TsgeGraphicColor;
    Text: String;
  end;


  TsgeColorLineArray = array of TsgeColorLine;


  TsgeColoredLines = class
  private
    FLines: TsgeColorLineArray;
    FMaxLines: Word;

    function  GetCount: Integer;
    procedure SetLine(Index: Integer; ALine: TsgeColorLine);
    function  GetLine(Index: Integer): TsgeColorLine;
    procedure SetMaxLines(ALines: Word);
  public
    constructor Create(MaxLines: Word = 64);
    destructor  Destroy; override;

    procedure Clear;
    procedure Add(ALine: TsgeColorLine);
    procedure Add(AColor: TsgeGraphicColor; Text: String);
    procedure Delete(Index: Integer);
    procedure Insert(Index: Integer; ALine: TsgeColorLine);
    procedure SaveToFile(FileName: String);

    property Count: Integer read GetCount;
    property Line[Index: Integer]: TsgeColorLine read GetLine write SetLine;
    property MaxLines: Word read FMaxLines write SetMaxLines;
  end;


implementation


const
  _UNITNAME = 'sgeColoredLines';



function TsgeColoredLines.GetCount: Integer;
begin
  Result := Length(FLines);
end;


procedure TsgeColoredLines.SetLine(Index: Integer; ALine: TsgeColorLine);
var
  c: Integer;
begin
  c := GetCount - 1;
  if (Index < 0) or (Index > c) then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_IndexOutOfBounds, IntToStr(Index)));

  FLines[Index] := ALine;
end;


function TsgeColoredLines.GetLine(Index: Integer): TsgeColorLine;
var
  c: Integer;
begin
  c := GetCount - 1;
  if (Index < 0) or (Index > c) then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_IndexOutOfBounds, IntToStr(Index)));

  Result := FLines[Index];
end;


procedure TsgeColoredLines.SetMaxLines(ALines: Word);
begin
  FMaxLines := ALines;
  while GetCount > FMaxLines do
    Delete(0);
end;


constructor TsgeColoredLines.Create(MaxLines: Word);
begin
  FMaxLines := MaxLines;
end;


destructor TsgeColoredLines.Destroy;
begin
  Clear;
end;


procedure TsgeColoredLines.Clear;
begin
  SetLength(FLines, 0);
end;


procedure TsgeColoredLines.Add(ALine: TsgeColorLine);
var
  Idx: Integer;
begin
  Idx := GetCount;
  SetLength(FLines, Idx + 1);
  FLines[Idx] := ALine;

  if GetCount > FMaxLines then Delete(0);
end;


procedure TsgeColoredLines.Add(AColor: TsgeGraphicColor; Text: String);
var
  Ln: TsgeColorLine;
begin
  Ln.Color := AColor;
  Ln.Text := Text;
  Add(Ln);
end;


procedure TsgeColoredLines.Delete(Index: Integer);
var
  i, c: Integer;
begin
  c := GetCount - 1;
  if (Index < 0) or (Index > c) then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_IndexOutOfBounds, IntToStr(Index)));

  for i := Index to c - 1 do
    FLines[i] := FLines[i + 1];

  SetLength(FLines, c);
end;


procedure TsgeColoredLines.Insert(Index: Integer; ALine: TsgeColorLine);
var
  i, c: Integer;
begin
  c := GetCount - 1;
  if (Index < 0) or (Index > c) then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_IndexOutOfBounds, IntToStr(Index)));

  SetLength(FLines, c + 1);
  for i := c downto Index + 1 do
    FLines[i] := FLines[i - 1];

  FLines[Index] := ALine;
end;


procedure TsgeColoredLines.SaveToFile(FileName: String);
var
  i, c: Integer;
  sa: TStringArray;
begin
  c := GetCount - 1;
  for i := 0 to c do
    StringArray_Add(@sa, FLines[i].Text);

  if not StringArray_SaveToFile(@sa, FileName) then
    begin
    StringArray_Clear(@sa);
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_FileWriteError, FileName));
    end;

  StringArray_Clear(@sa);
end;



end.

