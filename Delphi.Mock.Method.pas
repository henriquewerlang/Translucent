unit Delphi.Mock.Method;

interface

uses System.SysUtils, System.Rtti, System.Generics.Collections;

type
  EDidNotCallTheStartRegister = class(Exception)
  public
    constructor Create;
  end;

  EMethodNotRegistered = class(Exception)
  public
    constructor Create(Method: TRttiMethod);
  end;

  EParamsRegisteredMismatch = class(Exception)
  public
    constructor Create;
  end;

  ENonVirtualMethod = class(Exception)
  public
    constructor Create(Method: TRttiMethod);
  end;

  ERegisteredMethodsButDifferentParameters = class(Exception)
  public
    constructor Create;
  end;

  IIt = interface
    ['{5B034A6E-3953-4A0A-9A3A-6805210E082E}']
    function Compare(const Value: TValue): Boolean;
  end;

  IMethod = interface
    ['{047238B7-4FEB-4D99-A7B9-108F1627F298}']
    function GetItParams: TArray<IIt>;
    function GetMethod: TRttiMethod;

    procedure Execute(const Params: TArray<TValue>; out Result: TValue);
    procedure SetItParams(const Value: TArray<IIt>);
    procedure SetMethod(const Value: TRttiMethod);

    property ItParams: TArray<IIt> read GetItParams write SetItParams;
    property Method: TRttiMethod read GetMethod write SetMethod;
  end;

  IMethodExpect = interface
    ['{01FB3CF2-C990-4078-AF97-C9E3F4CD9B44}']
    function CheckExpectation: String;
    function ExceptationExecuted: Boolean;
  end;

  IMethodRegister = interface
    ['{A3AD240A-0365-40D2-801E-E094BFB1BA9C}']
    function CheckExpectations: String;
    function GetExpectMethods: TArray<IMethodExpect>;

    procedure ExecuteMethod(Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue);
    procedure RegisterMethod(Method: TRttiMethod);
    procedure StartRegister(Method: IMethod);

    property ExpectMethods: TArray<IMethodExpect> read GetExpectMethods;
  end;

  TMethodRegister = class(TInterfacedObject, IMethodRegister)
  private
    FMethodRegistering: IMethod;
    FMethodExecute: TDictionary<TRttiMethod, TList<IMethod>>;
    FMethodExpect: TDictionary<TRttiMethod, TList<IMethod>>;
    FAutoMock: Boolean;

    function GetExpectMethods: TArray<IMethodExpect>;
  public
    constructor Create(const AutoMock: Boolean);

    destructor Destroy; override;

    function CheckExpectations: String;

    procedure ExecuteMethod(Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue);
    procedure RegisterMethod(Method: TRttiMethod);
    procedure StartRegister(Method: IMethod);

    property ExpectMethods: TArray<IMethodExpect> read GetExpectMethods;
  end;

  TMethodInfo = class(TInterfacedObject)
  private
    FMethod: TRttiMethod;

    FItParams: TArray<IIt>;
  protected
    function GetItParams: TArray<IIt>;
    function GetMethod: TRttiMethod;

    procedure SetItParams(const Value: TArray<IIt>);
    procedure SetMethod(const Value: TRttiMethod);
  public
    property Method: TRttiMethod read GetMethod write SetMethod;
  end;

  TMethodInfoWillExecute = class(TMethodInfo, IMethod)
  private
    FProc: TFunc<TArray<TValue>, TValue>;
  public
    constructor Create(Proc: TFunc<TValue>); overload;
    constructor Create(Proc: TFunc<TArray<TValue>, TValue>); overload;
    constructor Create(Proc: TProc); overload;
    constructor Create(Proc: TProc<TArray<TValue>>); overload;

    procedure Execute(const Params: TArray<TValue>; out Result: TValue);
  end;

  TMethodInfoWillReturn = class(TMethodInfo, IMethod)
  private
    FReturnValue: TValue;
  public
    constructor Create(const ReturnValue: TValue);

    procedure Execute(const Params: TArray<TValue>; out Result: TValue);
  end;

  TMethodInfoExcept = class(TMethodInfo)
  private
    FExceptationExecuted: Boolean;
  public
    function ExceptationExecuted: Boolean;

    procedure Execute(const Params: TArray<TValue>; out Result: TValue);
  end;

  TMethodInfoCounter = class(TMethodInfoExcept, IMethod)
  private
    FExecutionCount: Integer;
  public
    procedure Execute(const Params: TArray<TValue>; out Result: TValue);

    property ExecutionCount: Integer read FExecutionCount write FExecutionCount;
  end;

  TMethodInfoExpectOnce = class(TMethodInfoCounter, IMethodExpect)
  public
    function CheckExpectation: String;
    function ExceptationExecuted: Boolean;
  end;

  TMethodInfoExpectNever = class(TMethodInfoCounter, IMethodExpect)
  public
    function CheckExpectation: String;
    function ExceptationExecuted: Boolean;
  end;

  TMethodInfoExpectExecutionCount = class(TMethodInfoCounter, IMethodExpect)
  private
    FExpectedExecutionCount: Integer;
  public
    constructor Create(ExpectedExecutionCount: Integer);

    function CheckExpectation: String;
    function ExceptationExecuted: Boolean;
  end;

  TMethodInfoCustomExpectation = class(TMethodInfoExcept, IMethod, IMethodExpect)
  private
    FFunc: TFunc<TArray<TValue>, String>;
    FExpectation: String;
  public
    constructor Create(Func: TFunc<TArray<TValue>, String>);

    function CheckExpectation: String;

    procedure Execute(const Params: TArray<TValue>; out Result: TValue);
  end;

var
  GItParams: TArray<IIt> = nil;

implementation

procedure ResetGlobalItParams;
begin
  GItParams := nil;
end;

{ TMethodInfoWillExecute }

constructor TMethodInfoWillExecute.Create(Proc: TProc);
begin
  Create(
    function(Params: TArray<TValue>): TValue
    begin
      Proc;
    end);
end;

constructor TMethodInfoWillExecute.Create(Proc: TFunc<TArray<TValue>, TValue>);
begin
  inherited Create;

  FProc := Proc;
end;

constructor TMethodInfoWillExecute.Create(Proc: TProc<TArray<TValue>>);
begin
  Create(
    function(Params: TArray<TValue>): TValue
    begin
      Proc(Params);
    end);
end;

constructor TMethodInfoWillExecute.Create(Proc: TFunc<TValue>);
begin
  Create(
    function(Params: TArray<TValue>): TValue
    begin
      Result := Proc;
    end);
end;

procedure TMethodInfoWillExecute.Execute(const Params: TArray<TValue>; out Result: TValue);
begin
  Result := FProc(Params);
end;

{ TMethodInfoWillReturn }

constructor TMethodInfoWillReturn.Create(const ReturnValue: TValue);
begin
  inherited Create;

  FReturnValue := ReturnValue;
end;

procedure TMethodInfoWillReturn.Execute(const Params: TArray<TValue>; out Result: TValue);
begin
  Result := FReturnValue;
end;

{ TMethodInfoCounter }

procedure TMethodInfoCounter.Execute(const Params: TArray<TValue>; out Result: TValue);
begin
  inherited;

  Inc(FExecutionCount);
end;

{ TMethodInfoExpectOnce }

function TMethodInfoExpectOnce.CheckExpectation: String;
const
  EXPECT_MESSAGE = 'Expected to call the method "%s" once but %s';

begin
  if FExecutionCount = 1 then
    Result := EmptyStr
  else
  begin
    if FExecutionCount = 0 then
      Result := 'never called'
    else
      Result := Format('was called %d times', [FExecutionCount]);

    Result := Format(EXPECT_MESSAGE, [Method.Name, Result]);
  end;
end;

function TMethodInfoExpectOnce.ExceptationExecuted: Boolean;
begin
  Result := True;
end;

{ TMethodRegister }

function TMethodRegister.CheckExpectations: String;
begin
  var MethodExecuted := False;
  Result := EmptyStr;

  for var Method in ExpectMethods do
  begin
    MethodExecuted := MethodExecuted or Method.ExceptationExecuted;

    if not Result.IsEmpty then
      Result := Result + #13#10;

    Result := Result + Method.CheckExpectation;
  end;

  if not MethodExecuted then
    Result := 'No expectations executed!';
end;

constructor TMethodRegister.Create(const AutoMock: Boolean);
begin
  inherited Create;

  FAutoMock := AutoMock;
  FMethodExecute := TObjectDictionary<TRttiMethod, TList<IMethod>>.Create([doOwnsValues]);
  FMethodExpect := TObjectDictionary<TRttiMethod, TList<IMethod>>.Create([doOwnsValues]);
end;

destructor TMethodRegister.Destroy;
begin
  FMethodExecute.Free;

  FMethodExpect.Free;

  inherited;
end;

procedure TMethodRegister.ExecuteMethod(Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue);

  function SameParams(const ItParams: TArray<IIt>): Boolean;
  begin
    Result := True;

    for var A := Low(Args) to High(Args) do
      if not ItParams[A].Compare(Args[A]) then
        Exit(False);
  end;

  function FindMethod(List: TDictionary<TRttiMethod, TList<IMethod>>): IMethod;
  begin
    Result := nil;

    if List.ContainsKey(Method) then
      for var MethodRegistered in List[Method] do
        if SameParams(MethodRegistered.ItParams) then
          Exit(MethodRegistered);
  end;

begin
  if FMethodExecute.ContainsKey(Method) then
  begin
    var MethodExecute := FindMethod(FMethodExecute);
    var MethodExpectation := FindMethod(FMethodExpect);

    if Assigned(MethodExpectation) and (MethodExpectation <> MethodExecute) then
      MethodExpectation.Execute(Args, Result);

    if Assigned(MethodExecute) then
      MethodExecute.Execute(Args, Result)
    else if not FMethodExpect.ContainsKey(Method) then
      raise ERegisteredMethodsButDifferentParameters.Create
  end
  else if not FAutoMock then
    raise EMethodNotRegistered.Create(Method);
end;

function TMethodRegister.GetExpectMethods: TArray<IMethodExpect>;
begin
  Result := nil;

  for var Method in FMethodExpect.Values do
    for var Expect in Method.ToArray do
      Result := Result + [Expect as IMethodExpect];
end;

procedure TMethodRegister.RegisterMethod(Method: TRttiMethod);
begin
  try
    if not Assigned(FMethodRegistering) then
      raise EDidNotCallTheStartRegister.Create;

    if not (Method.DispatchKind in [dkVtable, dkDynamic, dkInterface]) then
      raise ENonVirtualMethod.Create(Method);

    if Length(GItParams) <> Length(Method.GetParameters) then
      raise EParamsRegisteredMismatch.Create;

    FMethodRegistering.ItParams := GItParams;
    FMethodRegistering.Method := Method;

    if Supports(FMethodRegistering, IMethodExpect) then
    begin
      if not FMethodExpect.ContainsKey(Method) then
        FMethodExpect.Add(Method, TList<IMethod>.Create);

      FMethodExpect[Method].Add(FMethodRegistering);
    end;

    if not FMethodExecute.ContainsKey(Method) then
      FMethodExecute.Add(Method, TList<IMethod>.Create);

    FMethodExecute[Method].Add(FMethodRegistering);

    FMethodRegistering := nil;
  finally
    ResetGlobalItParams;
  end;
end;

procedure TMethodRegister.StartRegister(Method: IMethod);
begin
  FMethodRegistering := Method;
end;

{ EDidNotCallTheStartRegister }

constructor EDidNotCallTheStartRegister.Create;
begin
  inherited Create('You must call StartRegister before call RegisterMethod');
end;

{ TMethodInfo }

function TMethodInfo.GetItParams: TArray<IIt>;
begin
  Result := FItParams;
end;

function TMethodInfo.GetMethod: TRttiMethod;
begin
  Result := FMethod;
end;

procedure TMethodInfo.SetItParams(const Value: TArray<IIt>);
begin
  FItParams := Value;
end;

procedure TMethodInfo.SetMethod(const Value: TRttiMethod);
begin
  FMethod := Value;
end;

{ EMethodNotRegistered }

constructor EMethodNotRegistered.Create(Method: TRttiMethod);
begin
  inherited CreateFmt('The calling method %s is not registered!', [Method.Name]);
end;

{ EParamsRegisteredMismatch }

constructor EParamsRegisteredMismatch.Create;
begin
  inherited Create('The procedure being called and the number of parameters registered is different!');
end;

{ ERegisteredMethodsButDifferentParameters }

constructor ERegisteredMethodsButDifferentParameters.Create;
begin
  inherited Create('The called method is registered, but was not executed by parameter difference!');
end;

{ TMethodInfoCustomExpectation }

function TMethodInfoCustomExpectation.CheckExpectation: String;
begin
  Result := FExpectation;
end;

constructor TMethodInfoCustomExpectation.Create(Func: TFunc<TArray<TValue>, String>);
begin
  inherited Create;

  FFunc := Func;
end;

procedure TMethodInfoCustomExpectation.Execute(const Params: TArray<TValue>; out Result: TValue);
begin
  inherited;

  FExpectation := FFunc(Params);
end;

{ TMethodInfoExcept }

function TMethodInfoExcept.ExceptationExecuted: Boolean;
begin
  Result := FExceptationExecuted;
end;

procedure TMethodInfoExcept.Execute(const Params: TArray<TValue>; out Result: TValue);
begin
  FExceptationExecuted := True;
end;

{ ENonVirtualMethod }

constructor ENonVirtualMethod.Create(Method: TRttiMethod);
begin
  inherited CreateFmt('The method "%s" can''t be static!', [Method.Name]);
end;

{ TMethodInfoExpectNever }

function TMethodInfoExpectNever.CheckExpectation: String;
begin
  if FExecutionCount = 0 then
    Result := EmptyStr
  else
    Result := Format('Expected to never be called the procedure "%s", but was called %d times', [Method.Name, FExecutionCount]);
end;

function TMethodInfoExpectNever.ExceptationExecuted: Boolean;
begin
  Result := True;
end;

{ TMethodInfoExpectExecutionCount }

function TMethodInfoExpectExecutionCount.CheckExpectation: String;
begin
  if FExpectedExecutionCount = FExecutionCount then
    Result := EmptyStr
  else
    Result := Format('Expected to call the method "%s" %d times, but was called %d times', [Method.Name, FExpectedExecutionCount, FExecutionCount]);
end;

constructor TMethodInfoExpectExecutionCount.Create(ExpectedExecutionCount: Integer);
begin
  inherited Create;

  FExpectedExecutionCount := ExpectedExecutionCount;
end;

function TMethodInfoExpectExecutionCount.ExceptationExecuted: Boolean;
begin
  Result := True;
end;

end.

