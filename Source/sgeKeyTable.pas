{
Пакет             Simple Game Engine 1
Файл              sgeKeyTable.pas
Версия            1.4
Создан            16.12.2018
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Таблица команд привязанных к клавишам
}

unit sgeKeyTable;

{$mode objfpc}{$H+}

interface

uses
  sgeConst, sgeTypes,
  SysUtils;

type
  TsgeCommandKey = record
    Up: ShortString;
    Down: ShortString;
  end;


  TsgeKeyTable = class
  private
    FKeys: array[0..255] of TsgeCommandKey;

    procedure SetKey(Index: Byte; AKey: TsgeCommandKey);
    function  GetKey(Index: Byte): TsgeCommandKey;
    procedure SetNamedKey(Name: ShortString; Akey: TsgeCommandKey);
    function  GetNamedKey(Name: ShortString): TsgeCommandKey;
  public
    function IndexOf(Name: ShortString): Integer;
    function GetNameByIndex(Index: Byte): ShortString;

    procedure Clear;
    procedure Delete(Index: Integer);
    procedure Delete(Name: ShortString);

    property Key[Index: Byte]: TsgeCommandKey read GetKey write SetKey;
    property NamedKey[Name: ShortString]: TsgeCommandKey read GetNamedKey write SetNamedKey;
  end;



function sgeGetCommandKey(Up, Down: String): TsgeCommandKey;


implementation

const
  _UNITNAME = 'sgeKeyTable';

  //Таблица строковых имён клавиш
  TsgeKeyNameTable: array[0..255] of ShortString = (
    'MouseL',           //0
    'MouseM',           //1
    'MouseR',           //2
    'MouseX1',          //3
    'MouseX2',          //4
    'MouseS',           //5
    '', '',
    'Back',             //8
    'Tab',              //9
    '', '', '',
    'Enter',            //13
    '', '',
    'Shift',            //16
    'Ctrl',             //17
    'Alt',              //18
    'Pause',            //19
    'CapsLock',         //20
    '', '', '', '', '',
    '',
    'Esc',              //27
    '', '', '', '',
    'Space',            //32
    'PageUp',           //33
    'PageDown',         //34
    'End',              //35
    'Home',             //36
    'Left',             //38
    'Up',               //39
    'Right',            //40
    'Down',             //41
    '', '', '', '',
    'Insert',           //45
    'Delete',           //46
    '',
    '0',                //48
    '1',                //49
    '2',                //50
    '3',                //51
    '4',                //52
    '5',                //53
    '6',                //54
    '7',                //55
    '8',                //56
    '9',                //57
    '', '', '', '', '',
    '', '',
    'A',                //65
    'B',                //66
    'C',                //67
    'D',                //68
    'E',                //69
    'F',                //70
    'G',                //71
    'H',                //72
    'I',                //73
    'J',                //74
    'K',                //75
    'L',                //76
    'M',                //77
    'N',                //78
    'O',                //79
    'P',                //80
    'Q',                //81
    'R',                //82
    'S',                //83
    'T',                //84
    'U',                //85
    'V',                //86
    'W',                //87
    'X',                //88
    'Y',                //89
    'Z',                //90
    '', '', '', '', '',
    'Num0',             //96
    'Num1',             //97
    'Num2',             //98
    'Num3',             //99
    'Num4',             //100
    'Num5',             //101
    'Num6',             //102
    'Num7',             //103
    'Num8',             //104
    'Num9',             //105
    'NumStar',          //106
    'NumPlus',          //107
    '',
    'NumMinus',         //109
    'NumDelete',        //110
    'NumDivide',        //111
    'F1',               //112
    'F2',               //113
    'F3',               //114
    'F4',               //115
    'F5',               //116
    'F6',               //117
    'F7',               //118
    'F8',               //119
    'F9',               //120
    'F10',              //121
    'F11',              //122
    'F12',              //123
    '', '', '', '', '',
    '', '', '', '', '',
    '', '', '', '', '',
    '', '', '', '', '',
    'NumLock',          //144
    'ScrollLock',       //145
    '', '', '', '', '',
    '', '', '', '', '',
    '', '', '', '', '',
    '', '', '', '', '',
    '', '', '', '', '',
    '', '', '', '', '',
    '', '', '', '', '',
    '', '', '', '', '',
    'Semicolon',        //186 ;
    'Plus',             //187 +
    'Comma',            //188 ,
    'Minus',            //189 -
    'Dot',              //190 .
    'Divide',           //191 /
    'Tilde',            //192 ~
    '', '', '', '', '',
    '', '', '', '', '',
    '', '', '', '', '',
    '', '', '', '', '',
    '', '', '', '', '',
    '',
    '[',                //219 [
    'Slash',            //220 \
    ']',                //221 ]
    'Quote',            //222 "
    '', '', '', '', '',
    '', '', '', '', '',
    '', '', '', '', '',
    '', '', '', '', '',
    '', '', '', '', '',
    '', '', '', '', '',
    '', '', ''
    );





function sgeGetCommandKey(Up, Down: String): TsgeCommandKey;
begin
  Result.Up := Up;
  Result.Down := Down;
end;





procedure TsgeKeyTable.SetKey(Index: Byte; AKey: TsgeCommandKey);
begin
  FKeys[Index] := AKey;
end;


function TsgeKeyTable.GetKey(Index: Byte): TsgeCommandKey;
begin
  Result := FKeys[Index];
end;


procedure TsgeKeyTable.SetNamedKey(Name: ShortString; Akey: TsgeCommandKey);
var
  Idx: Integer;
begin
  Idx := IndexOf(Name);
  if Idx = -1 then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_KeyNameNotFound, Name));

  FKeys[Idx] := Akey;
end;


function TsgeKeyTable.GetNamedKey(Name: ShortString): TsgeCommandKey;
var
  Idx: Integer;
begin
  Idx := IndexOf(Name);
  if Idx = -1 then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_KeyNameNotFound, Name));

  Result := FKeys[Idx];
end;


function TsgeKeyTable.IndexOf(Name: ShortString): Integer;
var
  i: Byte;
begin
  Result := -1;
  Name := LowerCase(Name);
  for i := 0 to 255 do
    if Name = LowerCase(TsgeKeyNameTable[i]) then
      begin
      Result := i;
      Break;
      end;
end;


function TsgeKeyTable.GetNameByIndex(Index: Byte): ShortString;
begin
  Result := TsgeKeyNameTable[Index];
end;


procedure TsgeKeyTable.Clear;
var
  i: Byte;
begin
  for i := 0 to 255 do
    Delete(i);
end;


procedure TsgeKeyTable.Delete(Index: Integer);
begin
  FKeys[Index].Up := '';
  FKeys[Index].Down := '';
end;


procedure TsgeKeyTable.Delete(Name: ShortString);
var
  Idx: Integer;
begin
  Idx := IndexOf(Name);
  if Idx = -1 then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_KeyNameNotFound, Name));

  Delete(Idx);
end;



end.

