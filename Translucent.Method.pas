unit Translucent.Method;

interface

uses System.SysUtils, System.Rtti, System.Generics.Collections, Translucent.It;

type
  TFunctionInvoke = reference to function: TValue;
  TFunctionInvokeParams = reference to function (const Args: TArray<TValue>): TValue;
  TProcedureInvoke = reference to procedure;
  TProcedureInvokeParams = reference to procedure(const Args: TArray<TValue>);

  EDidNotCallTheStartRegister = class(Exception)
  public
    constructor Create(Method: TRttiMethod);
  end;

  EMethodNotRegistered = class(Exception)
  public
    constructor Create(Method: TRttiMethod);
  end;

  EParamsRegisteredMismatch = class(Exception)
  public
    constructor Create(Method: TRttiMethod);
  end;

  ENonVirtualMethod = class(Exception)
  public
    constructor Create(Method: TRttiMethod);
  end;

  ERegisteredMethodsButDifferentParameters = class(Exception)
  public
    constructor Create(Method: TRttiMethod);
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

  TExecuteProcedure = reference to procedure(const Args: TArray<TValue>; out Result: TValue);

  TMethodInfoWillExecute = class(TMethodInfo, IMethod)
  private
    FExecuteProcedure: TExecuteProcedure;
  public
    constructor Create(const Execute: TExecuteProcedure); overload;
    constructor Create(const Func: TFunctionInvoke); overload;
    constructor Create(const Func: TFunctionInvokeParams); overload;
    constructor Create(const Proc: TProcedureInvoke); overload;
    constructor Create(const Proc: TProcedureInvokeParams); overload;

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

implementation

{ TMethodInfoWillExecute }

constructor TMethodInfoWillExecute.Create(const Execute: TExecuteProcedure);
begin
  inherited Create;

  FExecuteProcedure := Execute;
end;

constructor TMethodInfoWillExecute.Create(const Func: TFunctionInvoke);
begin
  Create(
    procedure(const Args: TArray<TValue>; out Result: TValue)
    begin
      Result := Func;
    end);
end;

constructor TMethodInfoWillExecute.Create(const Func: TFunctionInvokeParams);
begin
  Create(
    procedure(const Args: TArray<TValue>; out Result: TValue)
    begin
      Result := Func(Args);
    end);
end;

constructor TMethodInfoWillExecute.Create(const Proc: TProcedureInvoke);
begin
  Create(
    procedure(const Args: TArray<TValue>; out Result: TValue)
    begin
      Proc;
    end);
end;

constructor TMethodInfoWillExecute.Create(const Proc: TProcedureInvokeParams);
begin
  Create(
    procedure(const Args: TArray<TValue>; out Result: TValue)
    begin
      Proc(Args);
    end);
end;

procedure TMethodInfoWillExecute.Execute(const Params: TArray<TValue>; out Result: TValue);
begin
  FExecuteProcedure(Params, Result);
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
    var Fixup := High(Args) - High(ItParams);
    Result := True;

    for var A := Low(ItParams) to High(ItParams) do
      if not ItParams[A].Compare(Args[A + Fixup]) then
        Exit(False);
  end;

  function FindMethod(List: TDictionary<TRttiMethod, TList<IMethod>>; var MethodRegistered: IMethod): Boolean;
  begin
    Result := List.ContainsKey(Method);

    if Result then
      for var Method in List[Method] do
        if SameParams(Method.ItParams) then
          MethodRegistered := Method;
  end;

begin
  var MethodExecute, MethodExpectation: IMethod;
  var MethodFound := FindMethod(FMethodExecute, MethodExecute);

  MethodFound := FindMethod(FMethodExpect, MethodExpectation) or MethodFound;

  if MethodFound then
  begin
    if Assigned(MethodExpectation) then
      MethodExpectation.Execute(Args, Result);

    if Assigned(MethodExecute) then
      MethodExecute.Execute(Args, Result)
    else if not FMethodExpect.ContainsKey(Method) then
      raise ERegisteredMethodsButDifferentParameters.Create(Method);
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

  procedure AddMethod(List: TDictionary<TRttiMethod, TList<IMethod>>);
  begin
    if not List.ContainsKey(Method) then
      List.Add(Method, TList<IMethod>.Create);

    List[Method].Add(FMethodRegistering);
  end;

begin
  try
    if not Assigned(FMethodRegistering) then
      raise EDidNotCallTheStartRegister.Create(Method);

    if not (Method.DispatchKind in [dkVtable, dkDynamic, dkInterface]) then
      raise ENonVirtualMethod.Create(Method);

    if TItParams.Params.Count <> Length(Method.GetParameters) then
      raise EParamsRegisteredMismatch.Create(Method);

    FMethodRegistering.ItParams := TItParams.Params.ToArray;
    FMethodRegistering.Method := Method;

    if Supports(FMethodRegistering, IMethodExpect) then
      AddMethod(FMethodExpect)
    else
      AddMethod(FMethodExecute);

    FMethodRegistering := nil;
  finally
    TItParams.ResetParams;
  end;
end;

procedure TMethodRegister.StartRegister(Method: IMethod);
begin
  FMethodRegistering := Method;
end;

{ EDidNotCallTheStartRegister }

constructor EDidNotCallTheStartRegister.Create(Method: TRttiMethod);
begin
  inherited CreateFmt('You must call StartRegister before call RegisterMethod for the method %s', [Method.Name]);
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
  inherited CreateFmt('The called method %s and the number of parameters registered is different!', [Method.Name]);
end;

{ ERegisteredMethodsButDifferentParameters }

constructor ERegisteredMethodsButDifferentParameters.Create(Method: TRttiMethod);
begin
  inherited CreateFmt('The called method %s is registered, but was not executed by parameter difference!', [Method.Name]);
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

