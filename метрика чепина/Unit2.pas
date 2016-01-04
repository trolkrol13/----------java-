unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TFormChepina = class(TForm)
    lbl1: TLabel;
    lbl2: TLabel;
    lbl3: TLabel;
    lbl4: TLabel;
    lbl5: TLabel;
    lstIO: TListBox;
    lstModifier: TListBox;
    lstControl: TListBox;
    lstParazits: TListBox;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormChepina: TFormChepina;

implementation

{$R *.dfm}

end.
