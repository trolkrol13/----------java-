unit MainUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, XPMan;

type
  TMainForm = class(TForm)
    sourceTextMemo: TMemo;
    globalVarsMemo: TMemo;
    countMetricsBtn: TButton;
    rightPnl: TPanel;
    lbl1: TLabel;
    loadFileBtn: TButton;
    fileOpenDlg: TOpenDialog;
    lbl2: TLabel;
    lbl3: TLabel;
    lbl4: TLabel;
    lbl5: TLabel;
    modulesLbl: TLabel;
    variablesLbl: TLabel;
    aupLbl: TLabel;
    pupLbl: TLabel;
    rupLbl: TLabel;
    leftPnl: TPanel;
    lbl6: TLabel;
    lbl7: TLabel;
    globalVarsPnl: TPanel;
    srcPnl: TPanel;
    XPManifest1: TXPManifest;
    procedure countMetricsBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure loadFileBtnClick(Sender: TObject);
    procedure MemoKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
  ClassStoreRecord = record
    className: string;
    bracketsCounter: Integer;
  end;
  ClassStorageArray = array[0..20] of ClassStoreRecord;

var
  MainForm: TMainForm;

const
  // Ключевые слова для поиска глобальных переменных
  GlobalVariableConst = 'public static';
  // Ключевое слово класса
  classConst = ' class ';
  // Константа названия класса при его отсутствии (для сохранения)
  noClassConst = 'NO_CLASS';
  // На что заменяется строковые константы
  replaceStringConst = '%S';

implementation

{$R *.dfm}

// Подготовка текста для обработки
procedure PrepareText;
var
  i, StartStringPosition, EndStringPosition, CommentPosition: integer;
  multilineComment: Boolean;
  CurrentString: string;
begin
  with MainForm do
  begin
    multilineComment := false;
    for i := 0 to sourceTextMemo.Lines.Count - 1 do
    begin
      CurrentString := sourceTextMemo.Lines[i];
      if (not multilineComment) then
      begin
        // Замена всех строковых констант
        while (Pos('"', CurrentString) <> 0) do
        begin
          StartStringPosition := Pos('"', CurrentString);
          EndStringPosition := Pos('"', Copy(CurrentString, StartStringPosition + 1, Length(CurrentString) - StartStringPosition));
          CommentPosition := Pos('/*', currentString);

          if ((EndStringPosition <> 0) and ((StartStringPosition < CommentPosition) or (CommentPosition = 0))) then
          begin
            Delete(CurrentString, StartStringPosition, EndStringPosition + 1);
            Insert(replaceStringConst, CurrentString, StartStringPosition);
          end
          else
            Break;
        end;

        // Удаление однострочных комментариев
        CommentPosition := Pos('//', CurrentString);
        if (CommentPosition <> 0) then
          Delete(CurrentString, CommentPosition, Length(CurrentString) - CommentPosition + 1);

        // Удаление многострочных комментариев
        CommentPosition := Pos('/*', CurrentString);
        if (CommentPosition <> 0) then
        begin
          multilineComment := true;
          if (Pos('*/', CurrentString) <> 0) then
          begin
            Delete(CurrentString, CommentPosition, Pos('*/', CurrentString) - CommentPosition + 2);
            multilineComment := false;
          end
          else
            Delete(CurrentString, CommentPosition, Length(CurrentString) - CommentPosition + 1);
        end;
      end
      else
      begin
        CommentPosition := Pos('*/', CurrentString);
        if (CommentPosition <> 0) then
        begin
          multilineComment := false;
          Delete(CurrentString, 1, CommentPosition + 1);
        end
        else
          CurrentString := '';
      end;
      sourceTextMemo.Lines[i] := CurrentString;
    end;
  end;
end;

// Замена всех табуляций в строке на пробелы
procedure ReplaceTabsInString(var SourceString: string);
begin
  while (Pos(#9, SourceString) <> 0) do
  begin
    SourceString[Pos(#9, SourceString)] := ' ';
  end;
end;

// Поиск глобальных переменных
procedure FindGlobalVariables(var list: TStringList);
  // "Обрезка" строки до имени переменной
  function CutStringToVarName(SourceString: string):string;
  var
    j: Integer;
    TempVariableString: string;
  begin
    if (Pos('=', SourceString) <> 0) then
    begin
      j := Pos('=', SourceString);
      TempVariableString := Trim(Copy(SourceString, 1, j-1));
    end
    else
    begin
      TempVariableString := SourceString;
      Delete(TempVariableString, Pos(';', TempVariableString), 1);
      TempVariableString := Trim(TempVariableString);
    end;
    while (Pos(' ',TempVariableString) <> 0) do
        Delete(TempVariableString, 1, Pos(' ', TempVariableString));
    Result := TempVariableString;
  end;

  // Парсинг переменных в строке
  procedure ParseToVariables(SourceString, className: string);
  begin
    if ((Pos(GlobalVariableConst, SourceString) <> 0) and (Pos('(', SourceString) = 0) and (Pos('class', SourceString) = 0)) then
    begin
      Delete(SourceString, 1, Pos(GlobalVariableConst, SourceString) + Length(GlobalVariableConst));
      while (Pos(',', SourceString) <> 0) do
      begin
        list.Add( className +'.'+ CutStringToVarName( Copy(SourceString, 1, Pos(',', SourceString) - 1) ) );
        Delete(SourceString, 1, Pos(',', SourceString));
      end;
      list.Add(className +'.'+ CutStringToVarName(SourceString));
    end;
  end;

var
  i, j, CurrentClassCounter, StringPosition: Integer;
  sourceString, tempString: string;
  CurrentClass: ClassStorageArray;

begin
  with MainForm do
  begin
    CurrentClassCounter := 0;
    CurrentClass[CurrentClassCounter].className := noClassConst;
    CurrentClass[CurrentClassCounter].bracketsCounter := 1000;
    for i := 0 to sourceTextMemo.Lines.Count - 1 do
    begin
      sourceString := sourceTextMemo.Lines[i];

      // Замена табуляций пробелом
      ReplaceTabsInString(sourceString);

      // Добавление нового класса
      StringPosition := Pos(classConst, ' ' + sourceString);
      if (StringPosition <> 0) then
      begin
        tempString := sourceString;
        Delete(tempString, 1, StringPosition + Length(classConst)-2);
        Trim(tempString);
        if (Pos(' ', tempString) = 0) then
          Insert(' ', tempString, Pos('{', tempString) - 1);
        tempString := tempString + ' ';
        Inc(CurrentClassCounter);
        CurrentClass[CurrentClassCounter].className := Copy(tempString, 1, Pos(' ', tempString) - 1);
        CurrentClass[CurrentClassCounter].bracketsCounter := 0;
      end;

      // Обработка вложенности фигурных скобок и, соответственно, классов
      j := 1;
      while ((Pos('{', sourceString) <> 0) or (Pos('}',sourceString) <> 0)) do
      begin
        if (sourceString[j] = '{') then
        begin
          Inc(CurrentClass[CurrentClassCounter].bracketsCounter);
          sourceString[j] := ' ';
        end
        else
        if (sourceString[j] = '}') then
        begin
          Dec(CurrentClass[CurrentClassCounter].bracketsCounter);
          if (CurrentClass[CurrentClassCounter].bracketsCounter < 1) then
            Dec(CurrentClassCounter);
          sourceString[j] := ' ';
        end;
        Inc(j);
      end;

      ParseToVariables(sourceString, CurrentClass[CurrentClassCounter].className);
    end;
  end;
end;

// Подсчёт количества методов
function CountModules:integer;
  // Проверка на наличие подстроки с учётом предыдущего / следующего символов
  function Check(SubString, SourceString: string):Boolean;
  const
    alphabet = ['a'..'z','A'..'Z','_'];
  var
    i: integer;
  begin
    Result := true;
    if (Pos(SubString, SourceString) <> 0) then
    begin
      i := Pos(SubString, SourceString);
      if (i > 1) then
        if not(SourceString[i-1] in alphabet) then
          Result := false;
      if (i < Length(SourceString)) then
        if not(SourceString[i+1] in alphabet) then
          Result := false;
    end;
  end;

 // Проверка является ли данная строка началом метода
  function IsAModule(SourceString: string):Boolean;
  var
    CurrentString: string;
  begin
    Result := false;
    CurrentString := Trim(SourceString);
    if (Length(CurrentString) > 0) then
      if (CurrentString[Length(CurrentString)] = ')') or
        (
          (Pos(')', CurrentString) > 0) and (Pos('{', CurrentString) > 0) and
          (Pos('{', CurrentString) > Pos(')', CurrentString))
        )
      then
        if ((Check('if', CurrentString)) and (Check('for', CurrentString)) and
          (Check('while', CurrentString)) and (Check('switch', CurrentString)))
        then
          Result := true;
  end;
var
  i, moduleCount: integer;
begin
  with MainForm do
  begin
    moduleCount := 0;
    for i := 0 to sourceTextMemo.Lines.Count - 1 do
    begin
      if (IsAModule(sourceTextMemo.Lines[i])) then
        Inc(moduleCount);
    end;
    Result := moduleCount;
  end;
end;

// Подсчёт использований глобальных переменных
function CountVarUsage(list:TStringList):integer;
var
  varUsageCounter, i, j: integer;
  CurrentString: string;
begin
  with MainForm do
  begin
    varUsageCounter := 0;
    for i := 0 to sourceTextMemo.Lines.Count - 1 do
    begin
      CurrentString := sourceTextMemo.Lines[i];
      if (Pos('.', CurrentString) <> 0) then
      begin
        for j := 0 to list.Count - 1 do
        begin
          while (Pos(list[j], CurrentString) <> 0) do
          begin
            Inc(varUsageCounter);
            Delete(CurrentString, Pos(list[j], CurrentString), Length(list[j]));
          end;
        end;
      end;
    end;
    Result := varUsageCounter;
  end;
end;

// Главная подпрограмма расчёта метрик
procedure CountMetrics;
var
  globalVariablesList: TStringList;
  globalVarsCount, modulesCount, Aup, Pup, i: integer;
  Rup: Real;
begin
  Rup := 0;

  globalVariablesList := TStringList.Create;
  PrepareText;
  FindGlobalVariables(globalVariablesList);
  globalVarsCount := globalVariablesList.Count;
  modulesCount := CountModules;

  Aup := CountVarUsage(globalVariablesList);
  Pup := modulesCount * globalVarsCount;
  if (Pup <> 0) then
    Rup := Aup / Pup;

  with MainForm do
  begin
    for i := 0 to globalVariablesList.Count - 1 do
      globalVarsMemo.Lines.Add(globalVariablesList[i]);
    modulesLbl.Caption := IntToStr(modulesCount);
    variablesLbl.Caption := IntToStr(globalVarsCount);
    aupLbl.Caption := IntToStr(Aup);
    pupLbl.Caption := IntToStr(Pup);
    rupLbl.Caption := FloatToStrF(Rup, ffGeneral, 6, 4);
  end;
end;

procedure TMainForm.countMetricsBtnClick(Sender: TObject);
begin
  globalVarsMemo.Clear;
  CountMetrics;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  sourceTextMemo.Clear;
  globalVarsMemo.Clear;
end;

procedure TMainForm.loadFileBtnClick(Sender: TObject);
begin
  if (fileOpenDlg.Execute) then
    sourceTextMemo.Lines.LoadFromFile(fileOpenDlg.FileName);
end;

procedure TMainForm.MemoKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = ^A then
  begin
    (Sender as TMemo).SelectAll;
    Key := #0;
  end;
end;

end.

