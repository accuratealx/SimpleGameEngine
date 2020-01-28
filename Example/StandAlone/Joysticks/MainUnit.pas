unit MainUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, sgeJoystickList, sgeJoystick, LConvEncoding;

type
  TMainFrm = class(TForm)
    CheckBoxAxisSmooth: TCheckBox;
    CheckBoxHasV: TCheckBox;
    CheckBoxHasU: TCheckBox;
    CheckBoxHasR: TCheckBox;
    CheckBoxHasZ: TCheckBox;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    lblPOV: TLabel;
    lblX: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    lblPovType: TLabel;
    lblAxisCount: TLabel;
    lblBtnCount: TLabel;
    lblR: TLabel;
    lblU: TLabel;
    lblV: TLabel;
    lblZ: TLabel;
    lblY: TLabel;
    ListBox1: TListBox;
    Shape1: TShape;
    Shape10: TShape;
    Shape11: TShape;
    Shape12: TShape;
    Shape2: TShape;
    Shape3: TShape;
    Shape4: TShape;
    Shape5: TShape;
    Shape6: TShape;
    Shape7: TShape;
    Shape8: TShape;
    Shape9: TShape;
    Timer1: TTimer;
    procedure CheckBoxAxisSmoothClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private

  public

  end;

var
  MainFrm: TMainFrm;
  J: TsgeJoystickList;
  JID: Integer = -1;


implementation

{$R *.lfm}


procedure FillJoyList;
var
  i: Integer;
begin
  MainFrm.ListBox1.Clear;

  for i := 0 to J.Count - 1 do
    MainFrm.ListBox1.Items.Add(CP1251ToUTF8(J.Joystick[i].Name));

end;


procedure FillJoyInfo;
begin
  if JID = -1 then Exit;

  with MainFrm do
    begin
    lblAxisCount.Caption := 'Axis count = ' + IntToStr(J.Joystick[JID].AxisCount);
    lblBtnCount.Caption := 'Button count = ' + IntToStr(J.Joystick[JID].ButtonCount);

    case J.Joystick[JID].PovType of
      jptVirtual: lblPovType.Caption := 'POV type = Virtual';
      jptDirection: lblPovType.Caption := 'POV type = Direction';
      jptDegree: lblPovType.Caption := 'POV type = Degree';
    end;

    CheckBoxHasZ.Checked := J.Joystick[JID].ZAxisExist;
    CheckBoxHasR.Checked := J.Joystick[JID].RAxisExist;
    CheckBoxHasU.Checked := J.Joystick[JID].UAxisExist;
    CheckBoxHasV.Checked := J.Joystick[JID].VAxisExist;

    CheckBoxAxisSmooth.Checked := J.Joystick[JID].AxisSmooth;
    end;

end;


procedure TMainFrm.FormCreate(Sender: TObject);
begin
  J := TsgeJoystickList.Create;
  J.Scan;

  FillJoyList;
end;

procedure TMainFrm.CheckBoxAxisSmoothClick(Sender: TObject);
begin
  if JID = -1 then Exit;

  J.Joystick[JID].AxisSmooth := CheckBoxAxisSmooth.Checked;
end;

procedure TMainFrm.FormDestroy(Sender: TObject);
begin
  J.Free;
end;

procedure TMainFrm.ListBox1Click(Sender: TObject);
begin
  JID := ListBox1.ItemIndex;

  FillJoyInfo;
end;


procedure TMainFrm.Timer1Timer(Sender: TObject);
var
  i: Integer;
  c: TComponent;
begin
  if JID = -1 then Exit;
  J.Process;

  //J.Joystick[JID].AxisMin := -100;
  //J.Joystick[JID].AxisMax := 100;


  for i := 0 to J.Joystick[JID].ButtonCount - 1 do
    begin
    c := nil;
    c := FindComponent('Shape' + IntToStr(i + 1));
    if c = nil then Continue;
    if J.Joystick[JID].Button[i].Down then TShape(c).Brush.Color := clRed else TShape(c).Brush.Color := clWhite;

    c := nil;
    c := FindComponent('Label' + IntToStr(i + 1));
    if c = nil then Continue;
    TLabel(c).Caption := IntToStr(J.Joystick[JID].Button[i].RepeatCount);
    end;

  lblX.Caption := 'X axis = ' + IntToStr(J.Joystick[JID].XAxis);
  lblY.Caption := 'Y axis = ' + IntToStr(J.Joystick[JID].YAxis);
  lblZ.Caption := 'Z axis = ' + IntToStr(J.Joystick[JID].ZAxis);
  lblR.Caption := 'R axis = ' + IntToStr(J.Joystick[JID].RAxis);
  lblU.Caption := 'U axis = ' + IntToStr(J.Joystick[JID].UAxis);
  lblV.Caption := 'V axis = ' + IntToStr(J.Joystick[JID].VAxis);

  lblPOV.Caption := 'POV = ' + IntToStr(J.Joystick[JID].POV);

end;

end.



