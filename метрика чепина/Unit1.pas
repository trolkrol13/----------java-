unit Unit1;

interface

uses
  Forms, Windows, Messages, SysUtils, Variants, Classes, regexpr,
  Dialogs, Controls, StdCtrls, math, Unit2;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    OpenDialog1: TOpenDialog;
    Button2: TButton;
    btn1: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure btn1Click(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
 Form1: TForm1;
 RegExp:TRegExpr;
 source,temp:string;
 OperandsN,ParasiticOperandsN,RuleOperandsN,EnterOperandsN,ModOperandsN:extended;
 Operands,NotParasiticOperands,RuleOperands,EnterOperands,ModOperands,UniqOperatorsValue, UniqOperandsValue:TStringList;

implementation

procedure Preparation;
 Begin
  RegExp.InputString:=source;
  RegExp.Expression:='(<\?(php)?)|(\?>)';
  source:=RegExp.Replace(source,' ');
  RegExp.InputString:=source;
 End;

procedure DeleteSpaces;
 Begin
  //������� ������ �������
  RegExp.Expression:=' +';
  source:=RegExp.Replace(source,' ');
  RegExp.InputString:=source;
 End;

procedure DeleteRubbish(MultiLineOnly:boolean);
 Begin
  if MultiLineOnly then
   Begin
    //������� ������������� �����������
    RegExp.Expression:='\/\*.*?''.*?''|`.*?`\*\/';
    source:=RegExp.Replace(source,' ');
    RegExp.InputString:=source;
   End;
  if not MultiLineOnly then
   Begin
    //������� ������������ �����������
    RegExp.Expression:='#.*?('#$D'|'#$A')|\/\/.*?('#$D'|'#$A')';
    source:=RegExp.Replace(source,' ');
    RegExp.InputString:=source;
   End;
  DeleteSpaces;
 End;

procedure DeleteNewLinesAndTabs;
 Begin
  //������� ��� �������� ����� � ���������
  RegExp.Expression:=#$D'|'#$A'|'#9;
  source:=RegExp.Replace(source,' ');
  RegExp.InputString:=source;
  DeleteSpaces;
 End;

 procedure DeleteStrings;
 begin
  //������� ��������� ��������� '' � ``
  RegExp.Expression:='''.*?''|`.*?`';
  Source:=RegExp.Replace(source,' ');
  RegExp.InputString:=source;
  DeleteSpaces;
 end;

procedure SearchOperands;
 var
  index,i,BracketBalance,EndPos:integer;
  TempSource,TempString:string;
  RegExpTemp:TRegExpr;
 Begin
  temp:=source;
  //������� ���������� ���������
  RegExp.Expression:='\W?(\$\w+?)\W';
  if RegExp.Exec then
   repeat
    if not Operands.Find(RegExp.Match[1],index) then Operands.Add(RegExp.Match[1])
    else if not NotParasiticOperands.Find(RegExp.Match[1],index) then NotParasiticOperands.Add(RegExp.Match[1]);
   until not RegExp.ExecNext;
  ParasiticOperandsN:=Operands.Count-NotParasiticOperands.Count;
  //������� ����������� ���������
  RegExp.Expression:='\W?((if|elseif|switch|foreach|for|while).*?)\(';
  RegExpTemp:=TRegExpr.Create;
  TempSource:=source;
  while RegExp.Exec do
   Begin
    i:=RegExp.MatchPos[1]+RegExp.MatchLen[1];
    BracketBalance:=0;
    repeat
     if TempSource[i]='(' then BracketBalance:=BracketBalance+1
     else if TempSource[i]=')' then BracketBalance:=BracketBalance-1;
     if (i+1)>Length(TempSource) then break;
     i:=i+1;
    until BracketBalance=0;
    EndPos:=i;
    TempString:=Copy(TempSource,RegExp.MatchPos[1],abs(EndPos-(RegExp.MatchPos[1])));
    RegExpTemp.InputString:=TempString;
    RegExpTemp.Expression:='\W?(\$\w+?)\W';
    if RegExpTemp.Exec then
     repeat
      if (NotParasiticOperands.Find(RegExpTemp.Match[1],index)) and (not RuleOperands.Find(RegExpTemp.Match[1],index)) then
       begin
        RuleOperands.Add(RegExpTemp.Match[1]);
        RuleOperandsN:=RuleOperandsN+1;
       end;
     until not RegExpTemp.ExecNext;
    Insert(' ',TempSource,RegExp.MatchPos[1]);
    Delete(TempSource,RegExp.MatchPos[1]+1,abs(EndPos-(RegExp.MatchPos[1])));
    RegExp.InputString:=TempSource;
   End;
  //������� ��������� ���������
  RegExp.Expression:='\W?((echo|print|print_r|var_dump|var_export|printf|fprintf|vfprintf|vprintf).*?;)';
  RegExp.InputString:=source;
  TempSource:=source;
  if RegExp.Exec then
   repeat
    TempString:=RegExp.Match[1];
    RegExpTemp.InputString:=TempString;
    RegExpTemp.Expression:='\W?(\$\w+?)\W';
    if RegExpTemp.Exec then
     repeat
      if (NotParasiticOperands.Find(RegExpTemp.Match[1],index)) and (not EnterOperands.Find(RegExpTemp.Match[1],index)) then
       begin
        EnterOperands.Add(RegExpTemp.Match[1]);
        EnterOperandsN:=EnterOperandsN+1;
       end;
     until not RegExpTemp.ExecNext;
   until not RegExp.ExecNext;
  RegExpTemp.Free;
  RegExp.InputString:=source;
  //������� �������� ���������
  for i:=0 to NotParasiticOperands.Count-1 do
   Begin
    RegExp.Expression:='\W?(\'+NotParasiticOperands[i]+') *?= *?(fgetc|fgetcsv|fgets|fgetss|file_get_contents|file|fread|fscanf)\W';
    if RegExp.Exec then
     repeat
      if not EnterOperands.Find(RegExp.Match[1],index) then
       Begin
        EnterOperands.Add(RegExp.Match[1]);
        EnterOperandsN:=EnterOperandsN+1;
       End;
     until not RegExp.ExecNext;
   End;
  //������� �������������� ����������
  for i:=0 to NotParasiticOperands.Count-1 do
   Begin
    RegExp.Expression:='\W?(\'+NotParasiticOperands[i]+') *?(\+\+|--|\+=|-=|\*=|\/=|\.=|%=|&=|\|=|\^=|=)\W';
    if RegExp.Exec then
     repeat
      if not ModOperands.Find(RegExp.Match[1],index) then
       Begin
        ModOperands.Add(RegExp.Match[1]);
        ModOperandsN:=ModOperandsN+1;
       End;
     until not RegExp.ExecNext;
   End;
 End;

procedure ChepinMetrics;
var i, index: Integer;
 Begin
   FormChepina.lstIO.Clear;
   FormChepina.lstModifier.Clear;
   FormChepina.lstControl.Clear;
   FormChepina.lstParazits.Clear;
   for i:= 0 to ModOperands.Count -1 do
    FormChepina.lstModifier.AddItem(ModOperands[i],FormChepina.lstModifier);
   for i:= 0 to RuleOperands.Count-1 do
    FormChepina.lstControl.AddItem(RuleOperands[i],FormChepina.lstControl);
   for i:= 0 to EnterOperands.Count - 1 do
    FormChepina.lstIO.AddItem(EnterOperands[i],FormChepina.lstIO);
   for i:= 0 to Operands.Count -1 do
    if not NotParasiticOperands.Find(Operands[i],index) then
      FormChepina.lstParazits.AddItem(Operands[i],FormChepina.lstParazits);
  FormChepina.lbl1.Caption:='���������� ��� ����� � ������: '+FloatToStr(EnterOperandsN);
  FormChepina.lbl2.Caption:='�������������� ����������: '+FloatToStr(ModOperandsN);
  FormChepina.lbl3.Caption:='����������� ����������: '+FloatToStr(RuleOperandsN);
  FormChepina.lbl4.Caption:='���������� ����������: '+FloatToStr(ParasiticOperandsN);
  FormChepina.lbl5.Caption:='������� ������: '+FloatToStr(EnterOperandsN+2*ModOperandsN+3*RuleOperandsN+0.5*ParasiticOperandsN);
 End;

procedure Chepin;
 Begin
  ParasiticOperandsN:=0;
  RuleOperandsN:=0;
  EnterOperandsN:=0;
  ModOperandsN:=0;
  RegExp:=TRegExpr.Create;
  Operands:=TStringList.Create;
  UniqOperandsValue:= TStringList.Create;
  UniqOperatorsValue:=TStringList.Create;
  NotParasiticOperands:=TStringList.Create;
  RuleOperands:=TStringList.Create;
  EnterOperands:=TStringList.Create;
  ModOperands:=TStringList.Create;
  Operands.Sorted:=true;
  Operands.Duplicates:=dupIgnore;
  NotParasiticOperands.Sorted:=true;
  NotParasiticOperands.Duplicates:=dupIgnore;
  RuleOperands.Sorted:=true;
  RuleOperands.Duplicates:=dupIgnore;
  EnterOperands.Sorted:=true;
  EnterOperands.Duplicates:=dupIgnore;
  ModOperands.Sorted:=true;
  ModOperands.Duplicates:=dupIgnore;
  source:=Form1.Memo1.Text;
  Preparation;
  DeleteRubbish(true);
  DeleteStrings;
  DeleteRubbish(false);
  DeleteNewLinesAndTabs;
  SearchOperands;
  ChepinMetrics;
  RegExp.Free;
  Operands.Free;
  UniqOperandsValue.Free;
  UniqOperatorsValue.Free;
  NotParasiticOperands.Free;
  RuleOperands.Free;
  EnterOperands.Free;
  ModOperands.Free;
 End;


{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
 if Memo1.Text<>'' then
  Begin
    TStringList.Create;
    Chepin;
  End;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
 if OpenDialog1.Execute then
  with TStringList.Create do
   Begin
    LoadFromFile(OpenDialog1.FileName);
    Memo1.Text:=Utf8Decode(Text);
   End;
end;

procedure TForm1.btn1Click(Sender: TObject);
begin
  FormChepina.Show();
end;

end.
