{
Пакет             Simple Game Engine 1
Файл              sgeViewBox.pas
Версия            1.1
Создан            11.11.2018
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Класс расчёта координат вывода карты с масштабом
}

unit sgeViewBox;

{$mode objfpc}{$H+}

interface

uses
  sgeTypes;


type
  TsgeViewBox = class
  private
    FScale: Single;                         //Масштаб
    FMinScale: Single;                      //Нижняя граница масштаба
    FMaxScale: Single;                      //Верхняя граница масштаба
    FMapWidth: Single;                      //Ширина карты
    FMapHeight: Single;                     //Высота карты
    FScreenWidth: Single;                   //Ширина экрана
    FScreenHeight: Single;                  //Высота экрана
    FScreenOffset: TsgeGraphicPoint;        //Смещение экрана от левого-верхнего угла крты
    FScreenCenter: TsgeGraphicPoint;        //Смещение центра экрана
    FMapBounds: TsgeGraphicRect;            //Координаты видимой части карты

    procedure SetScale(AScale: Single);
    procedure SetMinScale(AMin: Single);
    procedure SetMaxScale(AMax: Single);
    procedure SetMapWidth(AWidth: Single);
    procedure SetMapHeight(AHeight: Single);
    procedure SetScreenWidth(AWidth: Single);
    procedure SetScreenHeight(AHeight: Single);
    procedure SetScreenXOffset(XOffset: Single);
    procedure SetScreenYOffset(YOffset: Single);
    procedure SetScreenOffset(Offset: TsgeGraphicPoint);
    procedure SetScreenXCenter(XOffset: Single);
    procedure SetScreenYCenter(YOffset: Single);
    procedure SetScreenCenter(Offset: TsgeGraphicPoint);
    function  GetMapXPosByScreenPoint(X: Single): Single;
    function  GetMapYPosByScreenPoint(Y: Single): Single;
  public
    constructor Create(MapWidth, MapHeight: Single; ScreenWidth, ScreenHeight: Single; Scale: Single = 1; MinScale: Single = 0; MaxScale: Single = 2);

    function  GetMapPosByScreenPoint(X, Y: Single): TsgeGraphicPoint;

    property Scale: Single read FScale write SetScale;
    property MinScale: Single read FMinScale write SetMinScale;
    property MaxScale: Single read FMaxScale write SetMaxScale;
    property MapWidth: Single read FMapWidth write SetMapWidth;
    property MapHeight: Single read FMapHeight write SetMapHeight;
    property MapBounds: TsgeGraphicRect read FMapBounds;
    property ScreenWidth: Single read FScreenWidth write SetScreenWidth;
    property ScreenHeight: Single read FScreenHeight write SetScreenHeight;
    property ScreenOffset: TsgeGraphicPoint read FScreenOffset write SetScreenOffset;
    property ScreenXOffset: Single read FScreenOffset.X write SetScreenXOffset;
    property ScreenYOffset: Single read FScreenOffset.Y write SetScreenYOffset;
    property ScreenCenter: TsgeGraphicPoint read FScreenCenter write SetScreenCenter;
    property ScreenXCenter: Single read FScreenCenter.X write SetScreenXCenter;
    property ScreenYCenter: Single read FScreenCenter.Y write SetScreenYCenter;
  end;




implementation


procedure TsgeViewBox.SetScale(AScale: Single);
var
  Xc, Yc: Single;
begin
  //Проверить диапазон
  if AScale < FMinScale then AScale := FMinScale;
  if AScale > FMaxScale then AScale := FMaxScale;

  //Высчитать новые координаты ценра через пропроцию
  Xc := (FMapWidth * AScale) * FScreenCenter.X / (FMapWidth * FScale);
  Yc := (FMapHeight * AScale) * FScreenCenter.Y / (FMapHeight * FScale);

  //Изменить масштаб
  FScale := AScale;

  //Изменить центр экрана
  SetScreenXCenter(Xc);
  SetScreenYCenter(Yc);
end;


procedure TsgeViewBox.SetMinScale(AMin: Single);
begin
  FMinScale := AMin;
  SetScale(FScale);
end;


procedure TsgeViewBox.SetMaxScale(AMax: Single);
begin
  FMaxScale := AMax;
  SetScale(FScale);
end;


procedure TsgeViewBox.SetMapWidth(AWidth: Single);
begin
  if AWidth < 1 then AWidth := 1;

  FMapWidth := AWidth;
  SetScreenOffset(FScreenOffset);
end;


procedure TsgeViewBox.SetMapHeight(AHeight: Single);
begin
  if AHeight < 1 then AHeight := 1;

  FMapHeight := AHeight;
  SetScreenOffset(FScreenOffset);
end;


procedure TsgeViewBox.SetScreenWidth(AWidth: Single);
begin
  if AWidth < 1 then AWidth := 1;

  FScreenWidth := AWidth;
  SetScreenOffset(FScreenOffset);
end;


procedure TsgeViewBox.SetScreenHeight(AHeight: Single);
begin
  if AHeight < 1 then AHeight := 1;

  FScreenHeight := AHeight;
  SetScreenOffset(FScreenOffset);
end;


procedure TsgeViewBox.SetScreenXOffset(XOffset: Single);
var
  W: Single;
begin
  //Ширина карты с учётом масштаба
  W := FMapWidth * FScale;

  //Изменить смещение
  if W > FScreenWidth then
    begin
    FScreenOffset.X := XOffset;
    if FScreenOffset.X < 0 then FScreenOffset.X := 0;
    if FScreenOffset.X + FScreenWidth >= W then FScreenOffset.X := W - FScreenWidth;
    end else FScreenOffset.X := -(FScreenWidth / 2 - W / 2);

  //Пересчитать центр экрана
  FScreenCenter.X := FScreenOffset.X + FScreenWidth / 2;

  //Поправить видимую область X
  W := GetMapXPosByScreenPoint(0);
  if W = -1 then FMapBounds.X1 := 0 else FMapBounds.X1 := W;
  W := GetMapXPosByScreenPoint(FScreenWidth);
  if W = -1 then FMapBounds.X2 := FMapWidth else FMapBounds.X2 := W;
end;


procedure TsgeViewBox.SetScreenYOffset(YOffset: Single);
var
  H: Single;
begin
  //Высота карты с учётом масштаба
  H := FMapHeight * FScale;

  //Изменить смещение
  if H > FScreenHeight then
    begin
    FScreenOffset.Y := YOffset;
    if FScreenOffset.Y < 0 then FScreenOffset.Y := 0;
    if FScreenOffset.Y + FScreenHeight >= H then FScreenOffset.Y := H - FScreenHeight;
    end else FScreenOffset.Y := -(FScreenHeight / 2 - H / 2);

  //Пересчитать центр экрана
  FScreenCenter.Y := FScreenOffset.Y + FScreenHeight / 2;

  //Поправить видимую область Y
  H := GetMapYPosByScreenPoint(0);
  if H = -1 then FMapBounds.Y1 := 0 else FMapBounds.Y1 := H;
  H := GetMapYPosByScreenPoint(FScreenHeight);
  if H = -1 then FMapBounds.Y2 := FMapHeight else FMapBounds.Y2 := H;
end;


procedure TsgeViewBox.SetScreenOffset(Offset: TsgeGraphicPoint);
begin
  SetScreenXOffset(Offset.X);
  SetScreenYOffset(Offset.Y);
end;


procedure TsgeViewBox.SetScreenXCenter(XOffset: Single);
begin
  SetScreenXOffset(XOffset - FScreenWidth / 2);
end;


procedure TsgeViewBox.SetScreenYCenter(YOffset: Single);
begin
  SetScreenYOffset(YOffset - FScreenHeight / 2);
end;


procedure TsgeViewBox.SetScreenCenter(Offset: TsgeGraphicPoint);
begin
  SetScreenXCenter(Offset.X);
  SetScreenYCenter(Offset.Y);
end;


function TsgeViewBox.GetMapXPosByScreenPoint(X: Single): Single;
var
  W: Single;
begin
  Result := -1;

  //Ширина карты с учётом масштаба
  W := FMapWidth * FScale;

  //Определить координату X на карте
  if W <= FScreenWidth then
    begin
    X := X - (FScreenWidth - W) / 2;
    if (X >= 0) and (X <= W) then Result := X / FScale;
    end else Result := (FScreenOffset.X + X) / FScale;
end;


function TsgeViewBox.GetMapYPosByScreenPoint(Y: Single): Single;
var
  H: Single;
begin
  Result := -1;

  //Высота карты с учётом масштаба
  H := FMapHeight * FScale;

  //Определить координату Y на карте
  if H <= FScreenHeight then
    begin
    Y := Y - (FScreenHeight - H) / 2;
    if (Y >= 0) and (Y <= H) then Result := Y / FScale;
    end else Result := (FScreenOffset.Y + Y) / FScale;
end;


constructor TsgeViewBox.Create(MapWidth, MapHeight: Single; ScreenWidth, ScreenHeight: Single; Scale: Single; MinScale: Single; MaxScale: Single);
begin
  //Карта
  if MapWidth < 1 then MapWidth := 1;
  if MapHeight < 1 then MapHeight := 1;
  FMapWidth := MapWidth;
  FMapHeight := MapHeight;

  //Экран
  if ScreenWidth < 1 then ScreenWidth := 1;
  if ScreenHeight < 1 then ScreenHeight := 1;
  FScreenWidth := ScreenWidth;
  FScreenHeight := ScreenHeight;

  //Смещение до центра
  FScreenCenter.X := FScreenWidth / 2;
  FScreenCenter.Y := FScreenHeight / 2;

  //Смещение от левого-верхнего угла
  FScreenOffset.X := 0;
  FScreenOffset.Y := 0;

  //Масштаб
  FScale := Scale;
  FMinScale := MinScale;
  FMaxScale := MaxScale;
  SetScale(FScale);
end;


function TsgeViewBox.GetMapPosByScreenPoint(X, Y: Single): TsgeGraphicPoint;
begin
  Result.X := GetMapXPosByScreenPoint(X);
  Result.Y := GetMapYPosByScreenPoint(Y);
end;



end.

