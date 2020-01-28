{
Пакет             Simple Game Engine 1
Файл              sgeSoundBuffer.pas
Версия            1.6
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
  sgeMemoryStream,
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
    constructor Create(Stream: TsgeMemoryStream);
    constructor CreateBlank;
    destructor  Destroy; override;

    procedure FromMemoryStream(Stream: TsgeMemoryStream);
    procedure LoadFromFile(FileName: String);
    procedure Reload;

    property FileName: String read FFileName write FFileName;
    property Handle: Cardinal read FHandle;
    property Dept: TsgeSoundBufferDept read GetDept;
    property Channels: TsgeSoundBufferChannesl read GetChannels;
    property Frequency: Cardinal read GetFrequency;
    property Size: Cardinal read GetSize;
  end;



implementation

uses
  sgeConst, sgeTypes, sgeSoundBufferWavLoader,
  Classes;


const
  _UNITNAME = 'sgeSoundBuffer';


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
    raise EsgeException.Create(_UNITNAME, Err_SoundNotInitialized);

  //Обнулить ошибки
  alGetError;

  //Запросить буфер
  alGenBuffers(1, @FHandle);
  case alGetError() of
    AL_INVALID_VALUE: raise EsgeException.Create(_UNITNAME, Err_ReachedBufferLimit);
    AL_OUT_OF_MEMORY: raise EsgeException.Create(_UNITNAME, Err_OutOfMemory);
  end;

  //Запомнить путь
  FFileName := FileName;

  //Загрузить из файла
  LoadFromFile(FileName);
end;


constructor TsgeSoundBuffer.Create(Stream: TsgeMemoryStream);
begin
  //Обнулить ошибки
  alGetError;

  //Запросить буфер
  alGenBuffers(1, @FHandle);
  case alGetError() of
    AL_INVALID_VALUE: raise EsgeException.Create(_UNITNAME, Err_ReachedBufferLimit);
    AL_OUT_OF_MEMORY: raise EsgeException.Create(_UNITNAME, Err_OutOfMemory);
  end;

  FFileName := '';

  //Загрузить из стрима
  FromMemoryStream(Stream);
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


procedure TsgeSoundBuffer.FromMemoryStream(Stream: TsgeMemoryStream);
var
  Loader: TsgeSoundBufferWavLoader;
begin
  try
    try
      //Грузим данные
      Loader := TsgeSoundBufferWavLoader.Create(Stream);

      //Залить данные в OpenAL
      alBufferData(FHandle, Loader.Format, Loader.Data, Loader.Size, Loader.Frequency);

      //Проверить на ошибки
      case alGetError() of
        AL_INVALID_VALUE: raise EsgeException.Create(_UNITNAME, Err_WrongDataFormat);
        AL_OUT_OF_MEMORY: raise EsgeException.Create(_UNITNAME, Err_OutOfMemory);
        AL_INVALID_ENUM : raise EsgeException.Create(_UNITNAME, Err_UnsupportedFormat);
      end;

    except
      on E: EsgeException do
        raise EsgeException.Create(_UNITNAME, Err_CantLoadFromStream, '', E.Message);
    end;

  finally
    Loader.Free;
  end;
end;


procedure TsgeSoundBuffer.LoadFromFile(FileName: String);
var
  Ms: TsgeMemoryStream;
begin
  try
    Ms := TsgeMemoryStream.Create;

    try
      //Загрузить из файла
      Ms.LoadFromFile(FileName);

      //Загрузить из потока
      FromMemoryStream(Ms);
    except
      on E: EsgeException do
        raise EsgeException.Create(_UNITNAME, Err_FileReadError, FileName, E.Message);
    end;

  finally
    Ms.Free;
  end;
end;


procedure TsgeSoundBuffer.Reload;
begin
  LoadFromFile(FFileName);
end;





end.

