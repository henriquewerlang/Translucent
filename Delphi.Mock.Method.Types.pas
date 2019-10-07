unit Delphi.Mock.Method.Types;

interface

uses System.SysUtils, System.Rtti, Delphi.Mock;

type
  TMethodInfo = class(TInterfacedObject)
  private
    FItParams: TArray<IIt>;
  public
    constructor Create;

    function GetItParams: TArray<IIt>;

    procedure FillItParams;
  end;

  TMethodInfoWillExecute = class(TMethodInfo, IMethodInfo)
  private
    FProc: TProc;
  public
    constructor Create(Proc: TProc);

    procedure Execute(out Result: TValue);
  end;

  TMethodInfoWillReturn = class(TMethodInfo, IMethodInfo)
  private
    FReturnValue: TValue;
  public
    constructor Create(const ReturnValue: TValue);

    procedure Execute(out Result: TValue);
  end;

  TMethodInfoExpect = class(TMethodInfo, IMethodInfo)
  private
    FCount: Integer;
  public
    constructor Create(MaxCount: Integer);

    procedure Execute(out Result: TValue);
  end;

implementation

{ TMethodInfoWillExecute }

constructor TMethodInfoWillExecute.Create(Proc: TProc);
begin
  inherited Create;

  FProc := Proc;
end;

procedure TMethodInfoWillExecute.Execute(out Result: TValue);
begin
  FProc;
end;

{ TMethodInfo }

constructor TMethodInfo.Create;
begin
  inherited;

  GItParams := nil;
end;

procedure TMethodInfo.FillItParams;
begin
  FItParams := GItParams;
  GItParams := nil;
end;

function TMethodInfo.GetItParams: TArray<IIt>;
begin
  Result := FItParams;
end;

{ TMethodInfoWillReturn }

constructor TMethodInfoWillReturn.Create(const ReturnValue: TValue);
begin
  inherited Create;

  FReturnValue := ReturnValue;
end;

procedure TMethodInfoWillReturn.Execute(out Result: TValue);
begin
  Result := FReturnValue;
end;

{ TMethodInfoExpect }

constructor TMethodInfoExpect.Create(MaxCount: Integer);
begin
  inherited Create;
end;

procedure TMethodInfoExpect.Execute(out Result: TValue);
begin
  Inc(FCount);
end;

end.
