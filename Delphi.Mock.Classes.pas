unit Delphi.Mock.Classes;

interface

uses System.SysUtils, System.Rtti, Delphi.Mock.Intf, Delphi.Mock.Method;

type
  EConstructorNotFound = class(Exception)
  public
    constructor Create;
  end;

  TProxyClass<T: class> = class(TVirtualMethodInterceptor)
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
    FProxy: TProxyClass<T>;

    procedure OnInvoke(Instance: TObject; Method: TRttiMethod; const Args: TArray<TValue>; out DoInvoke: Boolean; out Result: TValue);
  public
    constructor Create(const ConstructorArgs: TArray<TValue>; MethodRegister: IMethodRegister);

    destructor Destroy; override;

    function When: T;
  end;

  TMockSetup<T: class> = class
  private
    FMockSetupWhen: TMockSetupWhen<T>;
    FMethodRegister: IMethodRegister;
    FProxy: TProxyClass<T>;

    procedure OnInvoke(Instance: TObject; Method: TRttiMethod; const Args: TArray<TValue>; out DoInvoke: Boolean; out Result: TValue);
  public
    constructor Create(const ConstructorArgs: TArray<TValue>);

    destructor Destroy; override;

    function Instance: T;
    function WillExecute(Proc: TProc): TMockSetupWhen<T>;
    function WillReturn(const Value: TValue): TMockSetupWhen<T>;
  end;

  TMockExpectSetup<T: class> = class
  public
    function CheckExpectations: String;
    function Once: TMockSetup<T>;
  end;

  TMock<T: class> = class
  private
    FSetup: TMockSetup<T>;
  public
    constructor Create(const ConstructorArgs: TArray<TValue>);

    destructor Destroy; override;

    property Setup: TMockSetup<T> read FSetup;
  end;

implementation

{ TMock<T> }

constructor TMock<T>.Create(const ConstructorArgs: TArray<TValue>);
begin
  inherited Create;

  FSetup := TMockSetup<T>.Create(ConstructorArgs);
end;

destructor TMock<T>.Destroy;
begin
  FSetup.Free;

  inherited;
end;

{ TMockSetup<T> }

constructor TMockSetup<T>.Create(const ConstructorArgs: TArray<TValue>);
begin
  inherited Create;

  FMethodRegister := TMethodRegister.Create;
  FMockSetupWhen := TMockSetupWhen<T>.Create(ConstructorArgs, FMethodRegister);
  FProxy := TProxyClass<T>.Create(ConstructorArgs);
  FProxy.OnBefore := OnInvoke;
end;

destructor TMockSetup<T>.Destroy;
begin
  FMockSetupWhen.Free;

  FProxy.Free;

  inherited;
end;

function TMockSetup<T>.Instance: T;
begin
  Result := FProxy.FInstance;
end;

procedure TMockSetup<T>.OnInvoke(Instance: TObject; Method: TRttiMethod; const Args: TArray<TValue>; out DoInvoke: Boolean; out Result: TValue);
begin
  DoInvoke := False;

  FMethodRegister.ExecuteMethod(Method, Args, Result);
end;

function TMockSetup<T>.WillExecute(Proc: TProc): TMockSetupWhen<T>;
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

end;

function TMockExpectSetup<T>.Once: TMockSetup<T>;
begin

end;

{ TMockSetupWhen<T> }

constructor TMockSetupWhen<T>.Create(const ConstructorArgs: TArray<TValue>; MethodRegister: IMethodRegister);
begin
  inherited Create;

  FMethodRegister := MethodRegister;
  FProxy := TProxyClass<T>.Create(ConstructorArgs);
  FProxy.OnBefore := OnInvoke;
end;

destructor TMockSetupWhen<T>.Destroy;
begin
  FProxy.Free;

  inherited;
end;

procedure TMockSetupWhen<T>.OnInvoke(Instance: TObject; Method: TRttiMethod; const Args: TArray<TValue>; out DoInvoke: Boolean; out Result: TValue);
begin
  DoInvoke := False;

  FMethodRegister.RegisterMethod(Method);
end;

function TMockSetupWhen<T>.When: T;
begin
  Result := FProxy.FInstance;
end;

{ TProxyClass<T> }

constructor TProxyClass<T>.Create(const ConstructorArgs: TArray<TValue>);
begin
  inherited Create(T);

  var ConstructorMethod := FindMethodConstructor(ConstructorArgs);
  var Context := TRttiContext.Create;
  FInstance := ConstructorMethod.Invoke(T, ConstructorArgs).AsObject as T;

  Proxify(FInstance);
end;

destructor TProxyClass<T>.Destroy;
begin
  if Assigned(FInstance) then
    Unproxify(FInstance);

  FInstance.Free;

  inherited;
end;

function TProxyClass<T>.FindMethodConstructor(const ConstructorArgs: TArray<TValue>): TRttiMethod;
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

end.

