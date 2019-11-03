{
Пакет             Simple Game Engine 1
Файл              sgeSoundSource.pas
Версия            1.1
Создан            12.08.2018
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Источник звука

Доделать
                  При включении RelativePos обрезаются высокие чистоты,
                  возможно ошибка в алгоритме позиционирования.
}

unit sgeSoundSource;

{$mode objfpc}{$H+}

interface

uses
  sgeConst, sgeTypes, sgeSoundBuffer,
  OpenAL;


type
  //Режим работы (Неопределено, Один буфер, Массив буферов)
  TsgeSoundSourceMode = (ssmUnknown, ssmStatic, ssmStream);

  //Состояние источника (Подготовлен, Играет, Приостановлен, Остановлен)
  TsgeSoundSourceState = (sssInitial, sssPlay, sssPause, sssStop);


  TsgeSoundSource = class
  private
    FHandle: TALuint;
    FPosition: array[0..2] of Single;
    FBuffer: TsgeSoundBuffer;

    procedure SetGain(AGain: Single);
    function  GetGain: Single;
    procedure SetMinGain(AGain: Single);
    function  GetMinGain: Single;
    procedure SetMaxGain(AGain: Single);
    function  GetMaxGain: Single;
    procedure SetPosX(X: Single);
    procedure SetPosY(Y: Single);
    procedure SetPosZ(Z: Single);
    procedure SetRelativePos(ARelative: Boolean);
    function  GetRelativePos: Boolean;
    function  GetMode: TsgeSoundSourceMode;
    function  GetState: TsgeSoundSourceState;
    procedure SetLoop(ALoop: Boolean);
    function  GetLoop: Boolean;
    procedure SetPitch(APitch: single);
    function  GetPitch: Single;
    procedure SetMaxDistance(ADistance: Single);
    function  GetMaxDistance: Single;
    procedure SetReferenceDistance(ADistance: Single);
    function  GetReferenceDistance: Single;

    procedure SetRollOffFactor(AFactor: Single);
    function  GetRollOffFactor: Single;

    procedure SetBuffer(ABuffer: TsgeSoundBuffer = nil);
  public
    constructor Create;
    destructor  Destroy; override;

    procedure Play;
    procedure Pause;
    procedure Stop;
    procedure Rewind;

    property Handle: Cardinal read FHandle;
    property Gain: Single read GetGain write SetGain;
    property MinGain: Single read GetMinGain write SetMinGain;
    property MaxGain: Single read GetMaxGain write SetMaxGain;
    property PosX: Single read FPosition[0] write SetPosX;
    property PosY: Single read FPosition[1] write SetPosY;
    property PosZ: Single read FPosition[2] write SetPosZ;
    property RelativePos: Boolean read GetRelativePos write SetRelativePos;
    property Mode: TsgeSoundSourceMode read GetMode;
    property State: TsgeSoundSourceState read GetState;
    property Loop: Boolean read GetLoop write SetLoop;
    property Pitch: Single read GetPitch write SetPitch;
    property MaxDistance: Single read GetMaxDistance write SetMaxDistance;
    property ReferenceDistance: Single read GetReferenceDistance write SetReferenceDistance;
    property RollOffFactor: Single read GetRollOffFactor write SetRollOffFactor;
    property Buffer: TsgeSoundBuffer read FBuffer write SetBuffer;
  end;



implementation


procedure TsgeSoundSource.SetGain(AGain: Single);
begin
  if AGain <= 0 then AGain := 0;
  if AGain >= 1 then AGain := 1;
  alSourcefv(FHandle, AL_GAIN, @AGain);
end;


function TsgeSoundSource.GetGain: Single;
begin
  alGetSourcefv(FHandle, AL_GAIN, @Result);
end;


procedure TsgeSoundSource.SetMinGain(AGain: Single);
begin
  if AGain <= 0 then AGain := 0;
  if AGain >= 1 then AGain := 1;
  alSourcefv(FHandle, AL_MIN_GAIN, @AGain);
end;


function TsgeSoundSource.GetMinGain: Single;
begin
  alGetSourcefv(FHandle, AL_MIN_GAIN, @Result);
end;


procedure TsgeSoundSource.SetMaxGain(AGain: Single);
begin
  if AGain <= 0 then AGain := 0;
  if AGain >= 1 then AGain := 1;
  alSourcefv(FHandle, AL_MAX_GAIN, @AGain);
end;


function TsgeSoundSource.GetMaxGain: Single;
begin
  alGetSourcefv(FHandle, AL_MAX_GAIN, @Result);
end;


procedure TsgeSoundSource.SetPosX(X: Single);
begin
  FPosition[0] := X;
  alSourcefv(FHandle, AL_POSITION, @FPosition);
end;


procedure TsgeSoundSource.SetPosY(Y: Single);
begin
  FPosition[1] := Y;
  alSourcefv(FHandle, AL_POSITION, @FPosition);
end;


procedure TsgeSoundSource.SetPosZ(Z: Single);
begin
  FPosition[2] := Z;
  alSourcefv(FHandle, AL_POSITION, @FPosition);
end;


procedure TsgeSoundSource.SetRelativePos(ARelative: Boolean);
var
  i: TALint;
begin
  if ARelative then i := AL_TRUE else i := AL_FALSE;
  alSourceiv(FHandle, AL_SOURCE_RELATIVE, @i);
end;


function TsgeSoundSource.GetRelativePos: Boolean;
var
  i: TALint;
begin
  alGetSourceiv(FHandle, AL_SOURCE_RELATIVE, @i);
  if i = AL_TRUE then Result := True else Result := False;
end;


function TsgeSoundSource.GetMode: TsgeSoundSourceMode;
var
  i: TALint;
begin
  alGetSourceiv(FHandle, AL_SOURCE_TYPE, @i);

  case i of
    AL_STATIC   : Result := ssmStatic;
    AL_STREAMING: Result := ssmStream;
    else Result := ssmUnknown;
  end;
end;


function TsgeSoundSource.GetState: TsgeSoundSourceState;
var
  i: TALint;
begin
  alGetSourceiv(FHandle, AL_SOURCE_STATE, @i);

  case i of
    AL_INITIAL: Result := sssInitial;
    AL_PLAYING: Result := sssPlay;
    AL_PAUSED : Result := sssPause;
    AL_STOPPED: Result := sssStop;
  end;
end;


procedure TsgeSoundSource.SetLoop(ALoop: Boolean);
var
  i: TALint;
begin
  if ALoop then i := AL_TRUE else i := AL_FALSE;
  alSourceiv(FHandle, AL_LOOPING, @i);
end;


function TsgeSoundSource.GetLoop: Boolean;
var
  i: TALint;
begin
  alGetSourceiv(FHandle, AL_LOOPING, @i);
  if i = AL_TRUE then Result := True else Result := False;
end;


procedure TsgeSoundSource.SetPitch(APitch: single);
begin
  if APitch < 0 then APitch := 0;
  alSourcefv(FHandle, AL_PITCH, @APitch);
end;


function TsgeSoundSource.GetPitch: Single;
begin
  alGetSourcefv(FHandle, AL_PITCH, @Result);
end;


procedure TsgeSoundSource.SetMaxDistance(ADistance: Single);
begin
  if ADistance < 0 then ADistance := 0;
  alSourcefv(FHandle, AL_MAX_DISTANCE, @ADistance);
end;


function TsgeSoundSource.GetMaxDistance: Single;
begin
  alGetSourcefv(FHandle, AL_MAX_DISTANCE, @Result);
end;


procedure TsgeSoundSource.SetReferenceDistance(ADistance: Single);
begin
  if ADistance < 0 then ADistance := 0;
  alSourcefv(FHandle, AL_REFERENCE_DISTANCE, @ADistance);
end;


function TsgeSoundSource.GetReferenceDistance: Single;
begin
  alGetSourcefv(FHandle, AL_REFERENCE_DISTANCE, @Result);
end;


procedure TsgeSoundSource.SetRollOffFactor(AFactor: Single);
begin
  if AFactor < 0 then AFactor := 0;
  alSourcefv(FHandle, AL_ROLLOFF_FACTOR, @AFactor);
end;


function TsgeSoundSource.GetRollOffFactor: Single;
begin
  alGetSourcefv(FHandle, AL_ROLLOFF_FACTOR, @Result);
end;


constructor TsgeSoundSource.Create;
begin
  //Проверить указатель на функцию
  if not Assigned(alGenSources) then
    raise EsgeException.Create(Err_sgeSoundSource + Err_Separator + Err_sgeSoundSource_SoundNotInitialized);

  //Обнулить ошибки
  alGetError;

  //Запросить буфер
  alGenSources(1, @FHandle);
  case alGetError() of
    AL_INVALID_VALUE    : raise EsgeException.Create(Err_sgeSoundSource + Err_Separator + Err_sgeSoundSource_ReachedTheLimitOfSources);
    AL_OUT_OF_MEMORY    : raise EsgeException.Create(Err_sgeSoundSource + Err_Separator + Err_sgeSoundSource_OutOfMemory);
    AL_INVALID_OPERATION: raise EsgeException.Create(Err_sgeSoundSource + Err_Separator + Err_sgeSoundSource_ThereIsNoContextForCreatingTheSource);
  end;

  //Прочитать текущие координаты
  alGetSourcefv(FHandle, AL_POSITION, @FPosition);
end;


destructor TsgeSoundSource.Destroy;
begin
  if not Assigned(alDeleteSources) then Exit; //Проверить указатель на функцию
  Stop;                                       //Остановить проигрывание
  alDeleteSources(1, @FHandle);               //Удалить источник
end;


procedure TsgeSoundSource.SetBuffer(ABuffer: TsgeSoundBuffer);
var
  Idx: TALint;
begin
  Stop;
  FBuffer := ABuffer;

  if FBuffer = nil then Idx := AL_NONE else Idx := FBuffer.Handle;

  alSourcei(FHandle, AL_BUFFER, Idx);
end;


procedure TsgeSoundSource.Play;
begin
  alSourcePlay(FHandle);
end;


procedure TsgeSoundSource.Pause;
begin
  alSourcePause(FHandle);
end;


procedure TsgeSoundSource.Stop;
begin
  alSourceStop(FHandle);
end;


procedure TsgeSoundSource.Rewind;
begin
  alSourceRewind(FHandle);
end;




end.

