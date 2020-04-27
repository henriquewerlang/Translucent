unit Delphi.Mock.Method;

interface

uses System.SysUtils, System.Rtti;

type
  IIt = interface
    ['{5B034A6E-3953-4A0A-9A3A-6805210E082E}']
    function Compare(const Value: TValue): Boolean;
  end;

  IMethod = interface
    ['{047238B7-4FEB-4D99-A7B9-108F1627F298}']
    procedure Execute(out Result: TValue);
  end;

  IMethodExpect = interface
    ['{01FB3CF2-C990-4078-AF97-C9E3F4CD9B44}']
    function CheckExpectation: String;
  end;

  IMethodDispatcher = interface
    ['{7F5EAD8F-550C-422F-ACF6-2D3C19097748}']
    procedure Invoke(Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue);
  end;

  IMethodRegister = interface
    ['{1E47BDFD-3EF6-447F-804D-2FA4969AA0F9}']
    function WillExecute(Proc: TProc): IMethod;
  end;

  TMethodDispatcher = class(TInterfacedObject, IMethodDispatcher)
  private
    procedure Invoke(Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue);
  end;

  TMethodRegister = class(TInterfacedObject, IMethodRegister)
  public
    function WillExecute(Proc: TProc): IMethod;
  end;

  TMethodInfo = class(TInterfacedObject)
  private
    FItParams: TArray<IIt>;
  protected
    procedure Execute(out Result: TValue);
  public
    constructor Create;
  end;

  TMethodInfoWillExecute = class(TMethodInfo, IMethod)
  private
    FProc: TProc;
  public
    constructor Create(Proc: TProc);

    procedure Execute(out Result: TValue);
  end;

  TMethodInfoWillReturn = class(TMethodInfo, IMethod)
  private
    FReturnValue: TValue;
  public
    constructor Create(const ReturnValue: TValue);

    procedure Execute(out Result: TValue);
  end;

  TMethodInfoCounter = class(TMethodInfo, IMethod)
  private
    FExecutionCount: Integer;
  public
    procedure Execute(out Result: TValue);
  end;

  TMethodInfoExpectOnce = class(TMethodInfoCounter, IMethodExpect)
  public
    function CheckExpectation: String;
  end;

var
  GItParams: TArray<IIt>;

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

procedure TMethodInfo.Execute(out Result: TValue);
begin
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

{ TMethodDispatcher }

procedure TMethodDispatcher.Invoke(Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue);
begin

end;

{ TMethodRegister }

function TMethodRegister.WillExecute(Proc: TProc): IMethod;
begin
  Result := TMethodInfoWillExecute.Create(Proc);
end;

end.
