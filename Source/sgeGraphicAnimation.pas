{
Пакет             Simple Game Engine 1
Файл              sgeGraphicAnimation.pas
Версия            1.1
Создан            01.11.2018
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Класс анимации
}

unit sgeGraphicAnimation;

{$mode objfpc}{$H+}

interface

uses
  sgeConst, sgeTypes, sgeGraphicFrames, sgeResources,
  Windows, SysUtils;


type
  TsgeGraphicAnimation = class
  private
    FFrames: TsgeGraphicFrames;
    FNeedFreeFrames: Boolean;
    FCurrentFrameIndex: Cardinal;
    FLastChangeTime: Int64;
    FCurrentTime: Int64;
    FTimeOffset: Integer;
    FTimeOffsetFreq: Int64;

    FScale: Single;
    FAngle: Single;
    FWidth: Integer;
    FHeight: Integer;

    procedure PreCreate;
    function  GetCurrentFrame: TsgeGraphicFrame;
    procedure SetTimeOffset(ATime: Integer);
    procedure SetFrames(AFrames: TsgeGraphicFrames);
    procedure SetCurrentFrameIndex(AIndex: Cardinal);
    function  GetFrameCount: Integer;
  public
    constructor Create(AFrames: TsgeGraphicFrames; Width, Height: Integer);
    constructor Create(FileName: String; Width, Height: Integer; Resources: TsgeResources);
    destructor  Destroy; override;

    procedure Reset;
    procedure Process;
    procedure LoadFromFile(FileName: String; Resources: TsgeResources);

    property Width: Integer read FWidth write FWidth;
    property Height: Integer read FHeight write FHeight;
    property Scale: Single read FScale write FScale;
    property Angle: Single read FAngle write FAngle;
    property TimeOffset: Integer read FTimeOffset write SetTimeOffset;
    property CurrentFrame: TsgeGraphicFrame read GetCurrentFrame;
    property CurrentFrameIndex: Cardinal read FCurrentFrameIndex write SetCurrentFrameIndex;
    property FrameCount: Integer read GetFrameCount;
    property Frames: TsgeGraphicFrames read FFrames write SetFrames;
  end;


implementation


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


procedure TsgeGraphicAnimation.SetTimeOffset(ATime: Integer);
var
  OneSecondFreq: Int64;
begin
  if ATime = FTimeOffset then Exit;
  FTimeOffset := ATime;
  QueryPerformanceFrequency(OneSecondFreq);
  FTimeOffsetFreq := Round((OneSecondFreq / 1000) * FTimeOffset);
end;


procedure TsgeGraphicAnimation.SetFrames(AFrames: TsgeGraphicFrames);
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
    raise EsgeException.Create(Err_sgeGraphicAnimation + Err_Separator + Err_sgeGraphicAnimation_IndexOutOfBounds + Err_Separator + IntToStr(AIndex));

  FCurrentFrameIndex := AIndex;
end;


function TsgeGraphicAnimation.GetFrameCount: Integer;
begin
  Result := FFrames.Count;
end;


constructor TsgeGraphicAnimation.Create(AFrames: TsgeGraphicFrames; Width, Height: Integer);
begin
  PreCreate;
  FWidth := Width;
  FHeight := Height;
  FFrames := AFrames;
end;


constructor TsgeGraphicAnimation.Create(FileName: String; Width, Height: Integer; Resources: TsgeResources);
begin
  PreCreate;
  FWidth := Width;
  FHeight := Height;
  LoadFromFile(FileName, Resources);
end;


destructor TsgeGraphicAnimation.Destroy;
begin
  if FNeedFreeFrames then FFrames.Free;
end;


procedure TsgeGraphicAnimation.Reset;
begin
  FCurrentFrameIndex := 0;
  QueryPerformanceCounter(FLastChangeTime);
end;


procedure TsgeGraphicAnimation.Process;
begin
  if FFrames.Count < 1 then Exit;

  QueryPerformanceCounter(FCurrentTime);
  if FCurrentTime - FLastChangeTime - FTimeOffsetFreq >= FFrames.Frame[FCurrentFrameIndex].Time then
    begin
    FLastChangeTime := FCurrentTime;
    Inc(FCurrentFrameIndex);
    if FCurrentFrameIndex >= FFrames.Count then FCurrentFrameIndex := 0;
    end;
end;


procedure TsgeGraphicAnimation.LoadFromFile(FileName: String; Resources: TsgeResources);
begin
  if FNeedFreeFrames then
    begin
    FFrames.LoadFromFile(FileName, Resources);
    Reset;
    end else
    begin
    FNeedFreeFrames := True;
    FFrames := TsgeGraphicFrames.Create(FileName, Resources);
    Reset;
    end;
end;



end.

