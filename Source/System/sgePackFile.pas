{
Пакет             Simple Game Engine 1
Файл              sgePackFile.pas
Версия            1.0
Создан            18.05.2020
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Заголовки и функции работы с архивами
}

unit sgePackFile;

{$mode objfpc}{$H+}{$Warnings Off}{$Hints Off}

interface



type
  //Заголовок файла
  TsgePackFileHeader = packed record
    hLabel: array[0..6] of Byte;      //7b Метка
    hVersion: Byte;                   //1b Версия архива
  end;


  //Заголовок блока
  TsgePackFileBlock = packed record
    TotalSize: Cardinal;              //4b Размер блока
    NameSize: Word;                   //2b Длина имени файла
  end;



function sgePackFile_GetFileHead: TsgePackFileHeader;


implementation


function sgePackFile_GetFileHead: TsgePackFileHeader;
const
  PackLabel = 'SGEPACK';
begin
  Move(PackLabel, Result.hLabel, SizeOf(PackLabel));
  Result.hVersion := 1;
end;


end.

