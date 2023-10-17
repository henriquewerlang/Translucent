unit Translucent.Classes;

interface

uses System.SysUtils, System.Rtti, Translucent.Method;

type
  EConstructorNotFound = class(Exception)
  public
    constructor Create;
  end;

  TClassInterceptor<T: class> = class(TVirtualMethodInterceptor)
  private
    FInstance: T;

    function FindMethodConstructor(const ConstructorArgs: TArray<TValue>): TRttiMethod;
  public
    constructor Create(const ConstructorArgs: TArray<TValue>);

    destructor Destroy; override;
  end;

  TMockSetupWhen<T: class> = class
  private
    FMethodRegister: IMethodRegister;
    FClassInterceptor: TClassInterceptor<T>;

    procedure OnInvoke(Instance: TObject; Method: TRttiMethod; const Args: TArray<TValue>; out DoInvoke: Boolean; out Result: TValue);
  public
    constructor Create(const ConstructorArgs: TArray<TValue>; MethodRegister: IMethodRegister);

    destructor Destroy; override;

    function When: T;
  end;

  TMockSetupCommon<T: class> = class
  private
    FMockSetupWhen: TMockSetupWhen<T>;
    FMethodRegister: IMethodRegister;
    FClassInterceptor: TClassInterceptor<T>;

    procedure OnInvoke(Instance: TObject; Method: TRttiMethod; const Args: TArray<TValue>; out DoInvoke: Boolean; out Result: TValue);
  public
    constructor Create(const ConstructorArgs: TArray<TValue>; MethodRegister: IMethodRegister);

    destructor Destroy; override;
  end;

  TMockSetup<T: class> = class(TMockSetupCommon<T>)
  public
    function WillExecute(const Proc: TProcedureInvoke): TMockSetupWhen<T>;
    function WillReturn(const Value: TValue): TMockSetupWhen<T>;
  end;

  TMockExpectSetup<T: class> = class(TMockSetupCommon<T>)
  public
    function CheckExpectations: String;
    function CustomExpect(Func: TFunc<TArray<TValue>, String>): TMockSetupWhen<T>;
    function Never: TMockSetupWhen<T>;
    function Once: TMockSetupWhen<T>;
  end;

  TMockClass<T: class> = class
  private
    FMethodRegister: IMethodRegister;
    FMockSetup: TMockSetup<T>;
    FMockExpectSetup: TMockExpectSetup<T>;

    function GetInstance: T;
  public
    constructor Create(const ConstructorArgs: TArray<TValue>; const AutoMock: Boolean);

    destructor Destroy; override;

    function CheckExpectations: String;

    property Expect: TMockExpectSetup<T> read FMockExpectSetup;
    property Instance: T read GetInstance;
    property Setup: TMockSetup<T> read FMockSetup;
  end;

implementation

uses System.TypInfo;

{ TMockClass<T> }

function TMockClass<T>.CheckExpectations: String;
begin
  Result := Expect.CheckExpectations;
end;

constructor TMockClass<T>.Create(const ConstructorArgs: TArray<TValue>; const AutoMock: Boolean);
begin
  inherited Create;

  FMethodRegister := TMethodRegister.Create(AutoMock);
  FMockSetup := TMockSetup<T>.Create(ConstructorArgs, FMethodRegister);
  FMockExpectSetup := TMockExpectSetup<T>.Create(ConstructorArgs, FMethodRegister);
end;

destructor TMockClass<T>.Destroy;
begin
  FMockSetup.Free;

  FMockExpectSetup.Free;

  inherited;
end;

function TMockClass<T>.GetInstance: T;
begin
  Result := FMockSetup.FClassInterceptor.FInstance;
end;

{ TMockSetup<T> }

function TMockSetup<T>.WillExecute(const Proc: TProcedureInvoke): TMockSetupWhen<T>;
begin
  Result := FMockSetupWhen;

  FMethodRegister.StartRegister(TMethodInfoWillExecute.Create(Proc));
end;

function TMockSetup<T>.WillReturn(const Value: TValue): TMockSetupWhen<T>;
begin
  Result := FMockSetupWhen;

  FMethodRegister.StartRegister(TMethodInfoWillReturn.Create(Value));
end;

{ TMockExpectSetup<T> }

function TMockExpectSetup<T>.CheckExpectations: String;
begin
  Result := FMethodRegister.CheckExpectations;
end;

function TMockExpectSetup<T>.CustomExpect(Func: TFunc<TArray<TValue>, String>): TMockSetupWhen<T>;
begin
  Result := FMockSetupWhen;

  FMethodRegister.StartRegister(TMethodInfoCustomExpectation.Create(Func));
end;

function TMockExpectSetup<T>.Never: TMockSetupWhen<T>;
begin
  Result := FMockSetupWhen;

  FMethodRegister.StartRegister(TMethodInfoExpectNever.Create);
end;

function TMockExpectSetup<T>.Once: TMockSetupWhen<T>;
begin
  Result := FMockSetupWhen;

  FMethodRegister.StartRegister(TMethodInfoExpectOnce.Create);
end;

{ TMockSetupWhen<T> }

constructor TMockSetupWhen<T>.Create(const ConstructorArgs: TArray<TValue>; MethodRegister: IMethodRegister);
begin
  inherited Create;

  FMethodRegister := MethodRegister;
  FClassInterceptor := TClassInterceptor<T>.Create(ConstructorArgs);
  FClassInterceptor.OnBefore := OnInvoke;
end;

destructor TMockSetupWhen<T>.Destroy;
begin
  FClassInterceptor.Free;

  inherited;
end;

procedure TMockSetupWhen<T>.OnInvoke(Instance: TObject; Method: TRttiMethod; const Args: TArray<TValue>; out DoInvoke: Boolean; out Result: TValue);
begin
  DoInvoke := False;

  FMethodRegister.RegisterMethod(Method);
end;

function TMockSetupWhen<T>.When: T;
begin
  Result := FClassInterceptor.FInstance;
end;

{ TClassInterceptor<T> }

constructor TClassInterceptor<T>.Create(const ConstructorArgs: TArray<TValue>);
begin
  inherited Create(T);

  var ConstructorMethod := FindMethodConstructor(ConstructorArgs);
  FInstance := ConstructorMethod.Invoke(T, ConstructorArgs).AsObject as T;

  Proxify(FInstance);
end;

destructor TClassInterceptor<T>.Destroy;
begin
  if Assigned(FInstance) then
    Unproxify(FInstance);

  FInstance.Free;

  inherited;
end;

function TClassInterceptor<T>.FindMethodConstructor(const ConstructorArgs: TArray<TValue>): TRttiMethod;
begin
  var Context := TRttiContext.Create;

  for var Method in Context.GetType(T).GetMethods('Create') do
  begin
    var MethodParams := Method.GetParameters;

    var Found := Length(MethodParams) = Length(ConstructorArgs);

    if Found then
    begin
      for var A := Low(ConstructorArgs) to High(ConstructorArgs) do
        if MethodParams[A].ParamType.TypeKind <> ConstructorArgs[A].Kind then
          Found := False;

      if Found then
        Exit(Method);
    end;
  end;

  raise EConstructorNotFound.Create;
end;

{ EConstructorNotFound }

constructor EConstructorNotFound.Create;
begin
  inherited Create('Constructor not found with these parameters!');
end;

{ TMockSetupCommon<T> }

constructor TMockSetupCommon<T>.Create(const ConstructorArgs: TArray<TValue>; MethodRegister: IMethodRegister);
begin
  inherited Create;

  FMethodRegister := MethodRegister;
  FMockSetupWhen := TMockSetupWhen<T>.Create(ConstructorArgs, FMethodRegister);
  FClassInterceptor := TClassInterceptor<T>.Create(ConstructorArgs);
  FClassInterceptor.OnBefore := OnInvoke;
end;

destructor TMockSetupCommon<T>.Destroy;
begin
  FMockSetupWhen.Free;

  FClassInterceptor.Free;

  inherited;
end;

procedure TMockSetupCommon<T>.OnInvoke(Instance: TObject; Method: TRttiMethod; const Args: TArray<TValue>; out DoInvoke: Boolean; out Result: TValue);
begin
  DoInvoke := False;

  FMethodRegister.ExecuteMethod(Method, Args, Result);
end;

end.

