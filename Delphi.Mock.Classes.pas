unit Delphi.Mock.Classes;

interface

uses System.SysUtils, System.Rtti, Delphi.Mock.Intf, Delphi.Mock.Method;

type
  TMockSetupWhen<T: class, constructor> = class
  private
    FInstance: T;
    FMethodRegister: IMethodRegister;
    FProxy: TVirtualMethodInterceptor;

    procedure OnInvoke(Instance: TObject; Method: TRttiMethod; const Args: TArray<TValue>; out DoInvoke: Boolean; out Result: TValue);
  public
    constructor Create(MethodRegister: IMethodRegister);

    destructor Destroy; override;

    function When: T;
  end;

  TMockSetup<T: class, constructor> = class
  private
    FInstance: T;
    FMockSetupWhen: TMockSetupWhen<T>;
    FMethodRegister: IMethodRegister;
    FProxy: TVirtualMethodInterceptor;

    procedure OnInvoke(Instance: TObject; Method: TRttiMethod; const Args: TArray<TValue>; out DoInvoke: Boolean; out Result: TValue);
  public
    constructor Create;

    destructor Destroy; override;

    function Instance: T;
    function WillExecute(Proc: TProc): TMockSetupWhen<T>;
    function WillReturn(const Value: TValue): TMockSetupWhen<T>;
  end;

  TMockExpectSetup<T: class, constructor> = class
  public
    function CheckExpectations: String;
    function Once: TMockSetup<T>;
  end;

  TMock<T: class, constructor> = class
  private
    FSetup: TMockSetup<T>;
  public
    constructor Create;

    destructor Destroy; override;

    property Setup: TMockSetup<T> read FSetup;
  end;

implementation

{ TMock<T> }

constructor TMock<T>.Create;
begin
  inherited;

  FSetup := TMockSetup<T>.Create;
end;

destructor TMock<T>.Destroy;
begin
  FSetup.Free;

  inherited;
end;

{ TMockSetup<T> }

constructor TMockSetup<T>.Create;
begin
  inherited;

  FInstance := T.Create;
  FMethodRegister := TMethodRegister.Create;
  FMockSetupWhen := TMockSetupWhen<T>.Create(FMethodRegister);
  FProxy := TVirtualMethodInterceptor.Create(T);
  FProxy.OnBefore := OnInvoke;

  FProxy.Proxify(FInstance);
end;

destructor TMockSetup<T>.Destroy;
begin
  FMockSetupWhen.Free;

  FProxy.Unproxify(FInstance);

  FProxy.Free;

  FInstance.Free;

  inherited;
end;

function TMockSetup<T>.Instance: T;
begin
  Result := FInstance;
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

constructor TMockSetupWhen<T>.Create(MethodRegister: IMethodRegister);
begin
  inherited Create;

  FMethodRegister := MethodRegister;
  FInstance := T.Create;
  FProxy := TVirtualMethodInterceptor.Create(T);
  FProxy.OnBefore := OnInvoke;

  FProxy.Proxify(FInstance);
end;

destructor TMockSetupWhen<T>.Destroy;
begin
  FProxy.Unproxify(FInstance);

  FProxy.Free;

  FInstance.Free;

  inherited;
end;

procedure TMockSetupWhen<T>.OnInvoke(Instance: TObject; Method: TRttiMethod; const Args: TArray<TValue>; out DoInvoke: Boolean; out Result: TValue);
begin
  DoInvoke := False;

  FMethodRegister.RegisterMethod(Method);
end;

function TMockSetupWhen<T>.When: T;
begin
  Result := FInstance;
end;

end.

