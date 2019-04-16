unit uViewFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.Buttons, Vcl.Grids, Vcl.ComCtrls, System.ImageList,
  Vcl.ImgList, StrUtils, System.UITypes;

const
  slash = '////////';

type
  TfViewMain = class(TFrame)
    pnlLeft: TPanel;
    pnlField1: TPanel;
    Panel6: TPanel;
    pnlOnOff1: TPanel;
    redtField1BC: TBitBtn;
    redtField1BP: TBitBtn;
    Panel7: TPanel;
    redtField1: TRichEdit;
    Panel8: TPanel;
    Label3: TLabel;
    Label4: TLabel;
    btnEdtDel11: TButtonedEdit;
    btnEdtN11: TButtonedEdit;
    pnlResultT1: TPanel;
    pnlBtnRes: TPanel;
    btnRep1: TSpeedButton;
    btnRep2: TSpeedButton;
    btnRep3: TSpeedButton;
    edtStrRepL1: TButtonedEdit;
    edtStrRepR1: TButtonedEdit;
    edtStrRepL2: TButtonedEdit;
    edtStrRepR2: TButtonedEdit;
    edtStrRepL3: TButtonedEdit;
    edtStrRepR3: TButtonedEdit;
    btnParsing: TBitBtn;
    btnReplace: TBitBtn;
    Splitter2: TSplitter;
    ImageList1: TImageList;
    Splitter1: TSplitter;
    pnlField2: TPanel;
    Panel10: TPanel;
    pnlOnOff2: TPanel;
    redtField2BC: TBitBtn;
    redtField2BP: TBitBtn;
    Panel13: TPanel;
    redtField2: TRichEdit;
    Panel14: TPanel;
    Label5: TLabel;
    Label6: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    btnEdtDel21: TButtonedEdit;
    btnEdtN21: TButtonedEdit;
    btnEdtN22: TButtonedEdit;
    btnEdtDel22: TButtonedEdit;
    Splitter3: TSplitter;
    pnlField3: TPanel;
    Panel11: TPanel;
    pnlOnOff3: TPanel;
    redtField3BC: TBitBtn;
    redtField3BP: TBitBtn;
    Panel16: TPanel;
    redtField3: TRichEdit;
    Panel17: TPanel;
    Label8: TLabel;
    Label9: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    btnEdtDel32: TButtonedEdit;
    btnEdtN33: TButtonedEdit;
    btnEdtN32: TButtonedEdit;
    btnEdtN31: TButtonedEdit;
    btnEdtDel33: TButtonedEdit;
    btnEdtDel31: TButtonedEdit;
    sgChange: TStringGrid;
    pnlbtnChange: TPanel;
    Panel1: TPanel;
    cbFiles: TListBox;
    btnWrite: TBitBtn;
    Splitter4: TSplitter;
    Panel9: TPanel;
    Panel15: TPanel;
    redtResultBC: TBitBtn;
    redtResultBCp: TBitBtn;
    Panel18: TPanel;
    redtTemp: TRichEdit;
    redtResult: TRichEdit;
    procedure btnedtRightButtonClick(Sender: TObject);
    procedure pnlBtnClick(Sender: TObject);
    procedure BCClick(Sender: TObject);
    procedure BPClick(Sender: TObject);
    procedure BCpClick(Sender: TObject);
    procedure btnReplaceClick(Sender: TObject);
    procedure btnWriteClick(Sender: TObject);
    procedure btnParsingClick(Sender: TObject);
    procedure redtFieldMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure redtFieldMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure redtFieldMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure redtFieldMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    procedure SearchAndReplace(RichEdit: TRichEdit; SearchText, ReplaceText: string);
    procedure ParsingText;
    function OutLine(sl: TstringList; SI,FI: integer): TstringList;
    procedure SaveLog;
  public

  end;

implementation

{$R *.dfm}

uses
  uMain;

procedure TfViewMain.SearchAndReplace(RichEdit: TRichEdit; SearchText, ReplaceText: string);
var
  StartPos, Position, Endpos: Integer;
begin
  startpos := 0;
  with RichEdit do
  begin
    endpos := Length(RichEdit.Text);
    Lines.BeginUpdate;
    while FindText(SearchText, startpos, endpos, [stMatchCase])<>-1 do
    begin
      endpos   := Length(RichEdit.Text) - startpos;
      Position := FindText(SearchText, startpos, endpos, [stMatchCase]);
      Inc(startpos, Length(SearchText));
      SetFocus;
      SelStart  := Position;
      SelLength := Length(SearchText);
      richedit.clearselection;
      if ReplaceText='/n' then SelText:=#13#10
      else
        if ReplaceText<>'' then SelText := ReplaceText

    end;
    Lines.EndUpdate;
  end;
end;

procedure TfViewMain.SaveLog;
var
  fl: TextFile;
  LogFile: string;
begin
  LogFile:=ExtractFilePath(Application.ExeName) + 'Log.txt';
  try
    AssignFile(fl,LogFile);
    if FileExists(LogFile)  then
      Append(fl)
    else
      Rewrite(fl);
    WriteLn(fl,TimeToStr(Time)+' '''+fMain.pc.Pages[fMain.pc.TabIndex].Caption+''' file '''+cbFiles.Items[cbFiles.ItemIndex]+''' rewrite');
  finally
    CloseFile(fl);
  end;
end;


procedure TfViewMain.ParsingText;
var
  i,j, SI: integer;
  btn: TButtonedEdit;
  StrList,StrResult: TStringList;
begin
  StrList:=TStringList.Create;
  StrResult:=TStringList.Create;
  try
    for i := 1 to 3 do
    begin
      redtTemp.Clear;
      SI:=0;
      if ((FindComponent('pnlOnOff'+IntToStr(i)) as TPanel).Color=clGreen) and ((FindComponent('redtField'+IntToStr(i)) as TRichEdit).Text<>'') then
      begin
        redtTemp.Lines.AddStrings((FindComponent('redtField'+IntToStr(i)) as TRichEdit).Lines);
        for j := 1 to i do
        begin
          btn:=(FindComponent('btnEdtN'+IntToStr(i)+IntToStr(j)) as TButtonedEdit);
          if (btn.RightButton.ImageIndex=0) and (btn.Text<>'') then
            SearchAndReplace(redtTemp,btn.Text,'/n');
          btn:=(FindComponent('btnEdtDel'+IntToStr(i)+IntToStr(j)) as TButtonedEdit);
          if (btn.RightButton.ImageIndex=0) and (btn.Text<>'') then
            SearchAndReplace(redtTemp,btn.Text,'');
        end;

        if (i=3) and (pnlbtnChange.Color=clGreen) then
          for j := 0 to 1 do
            if (sgChange.Cells[0,j]<>'') and (sgChange.Cells[1,j]<>'') then
              SearchAndReplace(redtTemp,sgChange.Cells[0,j],sgChange.Cells[1,j]);
        SI:=0;
      end
      else
        if redtResult.Text<>'' then
        begin
          case i of
          1: SI:=0;
          2: SI:=2;
          3: SI:=8;
          end;
          redtTemp.Lines.AddStrings(redtResult.Lines);
        end
        else
        begin
          SI:=0;
          redtTemp.Lines.Add(slash);
        end;
      StrList.Clear;
      StrList.AddStrings(redtTemp.Lines);
      StrResult.AddStrings(OutLine(StrList,SI,i));
    end;
    redtResult.Clear;
    redtResult.Lines.AddStrings(StrResult);
  finally
    StrList.Free;
    StrResult.Free;
    redtTemp.Clear;
  end;

end;

function TfViewMain.OutLine(sl: TstringList; SI,FI: integer): TstringList;
var
  i, tp: integer;
begin
  Result:=TStringList.Create;

  tp:=0;
  case FI of
  1: tp:=2;
  2: tp:=6;
  3: tp:=sl.Count;
  end;

  for i := 0 to (tp-1) do
    if (SI+i)>(sl.Count-1) then
      Result.Add(slash)
    else
      Result.Add(sl.Strings[SI+i]);
end;

procedure TfViewMain.btnedtRightButtonClick(Sender: TObject);
begin
  (Sender as TButtonedEdit).RightButton.ImageIndex:=Integer(not ((Sender as TButtonedEdit).RightButton.ImageIndex=1));
end;

procedure TfViewMain.btnParsingClick(Sender: TObject);
begin
  ParsingText;
end;

procedure TfViewMain.btnReplaceClick(Sender: TObject);
var
  nLeft, nRight, sTemp: string;
  i: integer;
begin
  for i := 1 to 3 do
  begin
    sTemp:='';
    nLeft:=(FindComponent('edtStrRepL'+IntToStr(i)) as TButtonedEdit).Text;
    nRight:=(FindComponent('edtStrRepR'+IntToStr(i)) as TButtonedEdit).Text;

    if ((FindComponent('btnRep'+IntToStr(i)) as TSpeedButton).Down) and (nLeft<>'') and (nRight<>'') then
    begin
      sTemp:=redtResult.Lines[StrToInt(nLeft)-1];
      redtResult.Lines[StrToInt(nLeft)-1]:=redtResult.Lines[StrToInt(nRight)-1];
      redtResult.Lines[StrToInt(nRight)-1]:=sTemp;
    end;
  end;
end;

procedure TfViewMain.btnWriteClick(Sender: TObject);
begin
  if cbFiles.Items[cbFiles.ItemIndex]<>'' then
    try
      redtResult.PlainText:=true;
      redtResult.Lines.SaveToFile(cbFiles.Items[cbFiles.ItemIndex]);
      redtResult.PlainText:=false;
      MessageDlg('The result is stored in the file.',mtCustom, [mbOK], 0);
    except
      MessageDlg('Error writing to file!',mtError, [mbOK], 0);
    end
  else
    MessageDlg('No file chosen!',mtWarning, [mbOK], 0);
  SaveLog;
end;

procedure TfViewMain.pnlBtnClick(Sender: TObject);
begin
  if (Sender as TPanel).BevelKind=bkSoft then
  begin
    (Sender as TPanel).BevelKind:=bkNone;
    (Sender as TPanel).Caption:='Off';
//    (Sender as TPanel).Caption:=ifThen((Sender as TPanel).Tag=0,'Off','===');
    (Sender as TPanel).Color:=clRed;
  end
  else
  begin
    (Sender as TPanel).BevelKind:=bkSoft;
    (Sender as TPanel).Caption:='On';
//    (Sender as TPanel).Caption:=ifThen((Sender as TPanel).Tag=0,'On','===');
    (Sender as TPanel).Color:=clGreen;
  end;
end;

procedure TfViewMain.redtFieldMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button=mbLeft then (Sender as TRichEdit).Tag:=10;
end;

procedure TfViewMain.redtFieldMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button=mbLeft then (Sender as TRichEdit).Tag:=0;
end;

procedure TfViewMain.redtFieldMouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  if ((Sender as TRichEdit).Tag=10) and ((Sender as TRichEdit).Font.Size>0) then
    (Sender as TRichEdit).Font.Size:=(Sender as TRichEdit).Font.Size-1;
  Handled:=true;
end;

procedure TfViewMain.redtFieldMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  if (Sender as TRichEdit).Tag=10 then
    (Sender as TRichEdit).Font.Size:=(Sender as TRichEdit).Font.Size+1;
  Handled:=true;
end;

procedure TfViewMain.BCpClick(Sender: TObject);
begin
  (FindComponent((Copy((Sender as TBitBtn).Name,1,Length((Sender as TBitBtn).Name)-3))) as TRichEdit).SelectAll;
  (FindComponent((Copy((Sender as TBitBtn).Name,1,Length((Sender as TBitBtn).Name)-3))) as TRichEdit).CopyToClipboard;
end;

procedure TfViewMain.BPClick(Sender: TObject);
begin
  (FindComponent((Copy((Sender as TBitBtn).Name,1,Length((Sender as TBitBtn).Name)-2))) as TRichEdit).PasteFromClipboard;
end;

procedure TfViewMain.BCClick(Sender: TObject);
begin
  (FindComponent((Copy((Sender as TBitBtn).Name,1,Length((Sender as TBitBtn).Name)-2))) as TRichEdit).Clear;
end;

end.
