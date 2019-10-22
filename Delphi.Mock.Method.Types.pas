unit Delphi.Mock.Method.Types;

interface

uses System.SysUtils, System.Rtti, Delphi.Mock;

type
  IMethodExpect = interface
    ['{01FB3CF2-C990-4078-AF97-C9E3F4CD9B44}']
    function CheckExpectation: String;
  end;

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

  TMethodInfoCounter = class(TMethodInfo, IMethodInfo)
  private
    FExecutionCount: Integer;
  public
    procedure Execute(out Result: TValue);
  end;

  TMethodInfoExpectOnce = class(TMethodInfoCounter, IMethodExpect)
  public
    function CheckExpectation: String;
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

{ TMethodInfoCounter }

procedure TMethodInfoCounter.Execute(out Result: TValue);
begin
  inherited;

  Inc(FExecutionCount);
end;

{ TMethodInfoExpectOnce }

function TMethodInfoExpectOnce.CheckExpectation: String;
begin
  Result := EmptyStr;

  if FExecutionCount = 0 then
    Result := 'Expected to call once the method but never called'
  else if FExecutionCount > 1 then
    Result := 'Expected to call once the method but was called 5 times';
end;

end.
