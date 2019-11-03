{
Пакет             Simple Game Engine 1
Файл              sgeSoundBuffer.pas
Версия            1.1
Создан            09.08.2018
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Набор аудиоданных

Доделать
                  Если создать через конструктор CreateBlank, то после нельзя
                  вызывать функции Reload и LoadFromFile, так как не запрашивался
                  номер для буфера, будет однозначно ошибка.
                  Деструктор может не удалить буфер если он проигрывается, но
                  вызывать исключения в деструкторе страшно, оставлю пока так.
}

unit sgeSoundBuffer;

{$mode objfpc}{$H+}

interface

uses
  sgeConst, sgeTypes,
  OpenAL;


type
  //Битность данных (0, 8, 16)
  TsgeSoundBufferDept = (sbd0Bit, sbd8Bit, sbd16Bit);

  //Количество каналов (0, 1, 2)
  TsgeSoundBufferChannesl = (sbcZero, sbcMono, sbcStereo);


  TsgeSoundBuffer = class
  private
    FHandle: TALuint;
    FFileName: String;

    function GetDept: TsgeSoundBufferDept;
    function GetChannels: TsgeSoundBufferChannesl;
    function GetFrequency: Cardinal;
    function GetSize: Cardinal;
  public
    constructor Create(FileName: String);
    constructor CreateBlank;
    destructor  Destroy; override;

    procedure LoadFromFile(FileName: String);
    procedure Reload;

    property Handle: Cardinal read FHandle;
    property Dept: TsgeSoundBufferDept read GetDept;
    property Channels: TsgeSoundBufferChannesl read GetChannels;
    property Frequency: Cardinal read GetFrequency;
    property Size: Cardinal read GetSize;
  end;



implementation


function TsgeSoundBuffer.GetDept: TsgeSoundBufferDept;
var
  i: TALint;
begin
  alGetBufferi(FHandle, AL_BITS, @i); //Запросить глубину

  case i of
    8 : Result := sbd8Bit;
    16: Result := sbd16Bit;
    else Result := sbd0Bit;
  end;
end;


function TsgeSoundBuffer.GetChannels: TsgeSoundBufferChannesl;
var
  i: TALint;
begin
  alGetBufferi(FHandle, AL_CHANNELS, @i); //Запросить каналы

  case i of
    1: Result := sbcMono;
    2: Result := sbcStereo;
    else Result := sbcZero;
  end;
end;


function TsgeSoundBuffer.GetFrequency: Cardinal;
var
  i: TALint;
begin
  alGetBufferi(FHandle, AL_SIZE, @i);
  Result := i;
end;


function TsgeSoundBuffer.GetSize: Cardinal;
var
  i: TALint;
begin
  alGetBufferi(FHandle, AL_FREQUENCY, @i);
  Result := i;
end;


constructor TsgeSoundBuffer.Create(FileName: String);
begin
  //Проверить указатель на функцию
  if not Assigned(alGenBuffers) then
    raise EsgeException.Create(Err_sgeSoundBuffer + Err_Separator + Err_sgeSoundBuffer_SoundNotInitialized);

  //Обнулить ошибки
  alGetError;

  //Запросить буфер
  alGenBuffers(1, @FHandle);
  case alGetError() of
    AL_INVALID_VALUE: raise EsgeException.Create(Err_sgeSoundBuffer + Err_Separator + Err_sgeSoundBuffer_ReachedTheLimitOfBuffers);
    AL_OUT_OF_MEMORY: raise EsgeException.Create(Err_sgeSoundBuffer + Err_Separator + Err_sgeSoundBuffer_OutOfMemory);
  end;

  //Запомнить путь
  FFileName := FileName;

  //Загрузить из файла
  LoadFromFile(FileName);
end;


constructor TsgeSoundBuffer.CreateBlank;
begin
  FHandle := AL_NONE;
end;


destructor TsgeSoundBuffer.Destroy;
begin
  if not Assigned(alDeleteBuffers) then Exit; //Проверить указатель на функцию

  alDeleteBuffers(1, @FHandle);               //Удалить буфер
end;


procedure TsgeSoundBuffer.LoadFromFile(FileName: String);
var
  aData: TALvoid;
  aFormat: TALenum;
  aSize: TALsizei;
  aFreq: TALsizei;
begin
  //Прочитать данные из файла
  try
    alutLoadWAVFile(FileName, aFormat, aData, aSize, aFreq);
  except
    alutUnloadWAV(aData);
    raise EsgeException.Create(Err_sgeSoundBuffer + Err_Separator + Err_sgeSoundBuffer_CantLoadFromFile);
  end;

  //Залить данные в OpenAL
  alBufferData(FHandle, aFormat, aData, aSize, aFreq);

  //Удалить аудиобуфер буфер
  alutUnloadWAV(aData);

  //Проверить на ошибки
  case alGetError() of
    AL_INVALID_VALUE: raise EsgeException.Create(Err_sgeSoundBuffer + Err_Separator + Err_sgeSoundBuffer_TheSizeDoesNotMatchTheDataOrBufferInUse);
    AL_OUT_OF_MEMORY: raise EsgeException.Create(Err_sgeSoundBuffer + Err_Separator + Err_sgeSoundBuffer_OutOfMemory);
    AL_INVALID_ENUM : raise EsgeException.Create(Err_sgeSoundBuffer + Err_Separator + Err_sgeSoundBuffer_UnsupportedFormat);
  end;

end;


procedure TsgeSoundBuffer.Reload;
begin
  LoadFromFile(FFileName);
end;





end.

