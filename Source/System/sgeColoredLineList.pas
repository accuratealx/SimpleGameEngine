{
Пакет             Simple Game Engine 1
Файл              sgeColoredLineList.pas
Версия            1.7
Создан            09.12.2018
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Массив цветных линий
}

unit sgeColoredLineList;

{$mode objfpc}{$H+}

interface

uses
  sgeMemoryStream, sgeGraphicColor;


type
  TsgeColorLine = record
    Color: TsgeGraphicColor;
    Text: String;
  end;


  TsgeColorLineArray = array of TsgeColorLine;


  TsgeColoredLineList = class
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

    function  ToString: String; override;
    procedure SaveToFile(FileName: String);
    procedure ToMemoryStream(Stream: TsgeMemoryStream);

    property Count: Integer read GetCount;
    property Line[Index: Integer]: TsgeColorLine read GetLine write SetLine;
    property MaxLines: Word read FMaxLines write SetMaxLines;
  end;


implementation

uses
  sgeConst, sgeTypes, sgeStringList, sgeFile,
  SysUtils;


const
  _UNITNAME = 'sgeColoredLineList';



function TsgeColoredLineList.GetCount: Integer;
begin
  Result := Length(FLines);
end;


procedure TsgeColoredLineList.SetLine(Index: Integer; ALine: TsgeColorLine);
var
  c: Integer;
begin
  c := GetCount - 1;
  if (Index < 0) or (Index > c) then
    raise EsgeException.Create(_UNITNAME, Err_IndexOutOfBounds, IntToStr(Index));

  FLines[Index] := ALine;
end;


function TsgeColoredLineList.GetLine(Index: Integer): TsgeColorLine;
var
  c: Integer;
begin
  c := GetCount - 1;
  if (Index < 0) or (Index > c) then
    raise EsgeException.Create(_UNITNAME, Err_IndexOutOfBounds, IntToStr(Index));

  Result := FLines[Index];
end;


procedure TsgeColoredLineList.SetMaxLines(ALines: Word);
begin
  FMaxLines := ALines;
  while GetCount > FMaxLines do
    Delete(0);
end;


constructor TsgeColoredLineList.Create(MaxLines: Word);
begin
  FMaxLines := MaxLines;
end;


destructor TsgeColoredLineList.Destroy;
begin
  Clear;
end;


procedure TsgeColoredLineList.Clear;
begin
  SetLength(FLines, 0);
end;


procedure TsgeColoredLineList.Add(ALine: TsgeColorLine);
var
  Idx: Integer;
begin
  Idx := GetCount;
  SetLength(FLines, Idx + 1);
  FLines[Idx] := ALine;

  if GetCount > FMaxLines then Delete(0);
end;


procedure TsgeColoredLineList.Add(AColor: TsgeGraphicColor; Text: String);
var
  Ln: TsgeColorLine;
begin
  Ln.Color := AColor;
  Ln.Text := Text;
  Add(Ln);
end;


procedure TsgeColoredLineList.Delete(Index: Integer);
var
  i, c: Integer;
begin
  c := GetCount - 1;
  if (Index < 0) or (Index > c) then
    raise EsgeException.Create(_UNITNAME, Err_IndexOutOfBounds, IntToStr(Index));

  for i := Index to c - 1 do
    FLines[i] := FLines[i + 1];

  SetLength(FLines, c);
end;


procedure TsgeColoredLineList.Insert(Index: Integer; ALine: TsgeColorLine);
var
  i, c: Integer;
begin
  c := GetCount;
  if (Index < 0) or (Index > c) then
    raise EsgeException.Create(_UNITNAME, Err_IndexOutOfBounds, IntToStr(Index));

  SetLength(FLines, c + 1);
  for i := c downto Index + 1 do
    FLines[i] := FLines[i - 1];

  FLines[Index] := ALine;
end;


function TsgeColoredLineList.ToString: String;
var
  i, c: Integer;
  List: TsgeStringList;
begin
  List := TsgeStringList.Create;

  c := GetCount - 1;
  for i := 0 to c do
    List.Add(FLines[i].Text);

  Result := List.ToString;

  List.Free;
end;


procedure TsgeColoredLineList.SaveToFile(FileName: String);
var
  F: TsgeFile;
  s: String;
begin
  try
    F := TsgeFile.Create(FileName, fmWrite);
    s := ToString;

    try
      F.Write(S[1], Length(s));
    except
      raise EsgeException.Create(_UNITNAME, Err_FileWriteError, FileName);
    end;

  finally
    F.Free;
  end;
end;


procedure TsgeColoredLineList.ToMemoryStream(Stream: TsgeMemoryStream);
begin
  Stream.FromString(ToString);
end;



end.

