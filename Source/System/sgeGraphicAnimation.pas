{
Пакет             Simple Game Engine 1
Файл              sgeGraphicAnimation.pas
Версия            1.8
Создан            01.11.2018
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Класс анимации
}

unit sgeGraphicAnimation;

{$mode objfpc}{$H+}

interface

uses
  sgeMemoryStream, sgeGraphicFrameList, sgeResourceList;


type
  TsgeGraphicAnimation = class
  private
    FResources: TsgeResourceList;   //Указатель на таблицу ресурсов

    FFileName: String;              //имя файла
    FFrames: TsgeGraphicFrameList;  //Массив кадров
    FNeedFreeFrames: Boolean;       //Флаг освобождения памяти, если загрузка из файла
    FCurrentFrameIndex: Cardinal;   //Текущий индекс кадра
    FLastChangeTime: Int64;         //Время последней смены кадра
    FTimeOffset: Integer;           //Смещение времени для всех кадров

    FScale: Single;
    FAngle: Single;
    FWidth: Integer;
    FHeight: Integer;

    procedure PreCreate;
    function  GetCurrentFrame: TsgeGraphicFrame;
    procedure SetFrames(AFrames: TsgeGraphicFrameList);
    procedure SetCurrentFrameIndex(AIndex: Cardinal);
    function  GetFrameCount: Integer;
  public
    constructor Create(AFrames: TsgeGraphicFrameList; Width, Height: Integer);
    constructor Create(FileName: String; Width, Height: Integer; Resources: TsgeResourceList);
    constructor Create(Stream: TsgeMemoryStream; Width, Height: Integer; Resources: TsgeResourceList);
    destructor  Destroy; override;

    procedure Reload;
    procedure Reset;
    procedure Process;

    procedure FromMemoryStream(Stream: TsgeMemoryStream);
    procedure LoadFromFile(FileName: String);

    property FileName: String read FFileName write FFileName;
    property Width: Integer read FWidth write FWidth;
    property Height: Integer read FHeight write FHeight;
    property Scale: Single read FScale write FScale;
    property Angle: Single read FAngle write FAngle;
    property TimeOffset: Integer read FTimeOffset write FTimeOffset;
    property CurrentFrame: TsgeGraphicFrame read GetCurrentFrame;
    property CurrentFrameIndex: Cardinal read FCurrentFrameIndex write SetCurrentFrameIndex;
    property FrameCount: Integer read GetFrameCount;
    property Frames: TsgeGraphicFrameList read FFrames write SetFrames;
  end;


implementation

uses
  sgeConst, sgeTypes,
  SysUtils;


const
  _UNITNAME = 'sgeGraphicAnimation';



procedure TsgeGraphicAnimation.PreCreate;
begin
  FNeedFreeFrames := False;
  FScale := 1;
  FAngle := 0;
  FTimeOffset := 0;
  Reset;
end;


function TsgeGraphicAnimation.GetCurrentFrame: TsgeGraphicFrame;
begin
  Result := FFrames.Frame[FCurrentFrameIndex];
end;


procedure TsgeGraphicAnimation.SetFrames(AFrames: TsgeGraphicFrameList);
begin
  if FNeedFreeFrames then
    begin
    FNeedFreeFrames := False;
    FFrames.Free;
    end;
  FFrames := AFrames;
  Reset;
end;


procedure TsgeGraphicAnimation.SetCurrentFrameIndex(AIndex: Cardinal);
begin
  if AIndex > FFrames.Count - 1 then
    raise EsgeException.Create(_UNITNAME, Err_IndexOutOfBounds, IntToStr(AIndex));

  FCurrentFrameIndex := AIndex;
end;


function TsgeGraphicAnimation.GetFrameCount: Integer;
begin
  Result := FFrames.Count;
end;


constructor TsgeGraphicAnimation.Create(AFrames: TsgeGraphicFrameList; Width, Height: Integer);
begin
  PreCreate;
  FWidth := Width;
  FHeight := Height;
  FFrames := AFrames;
end;


constructor TsgeGraphicAnimation.Create(FileName: String; Width, Height: Integer; Resources: TsgeResourceList);
begin
  PreCreate;
  FResources := Resources;
  FWidth := Width;
  FHeight := Height;
  FFileName := FileName;

  LoadFromFile(FileName);
end;


constructor TsgeGraphicAnimation.Create(Stream: TsgeMemoryStream; Width, Height: Integer; Resources: TsgeResourceList);
begin
  PreCreate;
  FResources := Resources;
  FWidth := Width;
  FHeight := Height;

  FromMemoryStream(Stream);
end;


destructor TsgeGraphicAnimation.Destroy;
begin
  if FNeedFreeFrames then FFrames.Free;
end;


procedure TsgeGraphicAnimation.Reload;
begin
  LoadFromFile(FFileName);
end;


procedure TsgeGraphicAnimation.Reset;
begin
  FCurrentFrameIndex := 0;
end;


procedure TsgeGraphicAnimation.Process;
var
  CurrentTime: Int64;
begin
  if FFrames.Count < 1 then Exit;

  CurrentTime := sgeGetTickCount;
  if CurrentTime - FLastChangeTime - FTimeOffset >= FFrames.Frame[FCurrentFrameIndex].Time then
    begin
    FLastChangeTime := CurrentTime;
    Inc(FCurrentFrameIndex);
    if FCurrentFrameIndex >= FFrames.Count then FCurrentFrameIndex := 0;
    end;
end;


procedure TsgeGraphicAnimation.FromMemoryStream(Stream: TsgeMemoryStream);
begin
  try

    case FNeedFreeFrames of
      True:
        begin
        FFrames.FromMemoryStream(Stream);
        Reset;
        end;

      False:
        begin
        FNeedFreeFrames := True;
        FFrames := TsgeGraphicFrameList.Create(Stream, FResources);
        Reset;
        end;
    end;

  except
    on E: EsgeException do
      raise EsgeException.Create(_UNITNAME, Err_CantLoadFromStream, '', E.Message);
  end;
end;


procedure TsgeGraphicAnimation.LoadFromFile(FileName: String);
begin
  try

    case FNeedFreeFrames of
      True:
        begin
        FFrames.LoadFromFile(FileName);
        Reset;
        end;

      False:
        begin
        FNeedFreeFrames := True;
        FFrames := TsgeGraphicFrameList.Create(FileName, FResources);
        Reset;
        end;
    end;

  except
    on E: EsgeException do
      raise EsgeException.Create(_UNITNAME, Err_FileReadError, FileName, E.Message);
  end;
end;



end.

