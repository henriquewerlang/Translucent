unit Delphi.Mock.Intf;

interface

uses System.SysUtils, System.Rtti, Delphi.Mock.VirtualInterface, Delphi.Mock.Method;

type
  IMockSetupWhen<T: IInterface> = interface
    ['{1EE67E5A-C054-4771-842F-3FBCD39BB90B}']
    function When: T;
  end;

  IMockSetup<T: IInterface> = interface
    ['{778531BB-4093-4103-B4BC-72845B78387B}']
    function WillExecute(Proc: TFunc<TValue>): IMockSetupWhen<T>; overload;
    function WillExecute(Proc: TFunc<TArray<TValue>, TValue>): IMockSetupWhen<T>; overload;
    function WillExecute(Proc: TProc): IMockSetupWhen<T>; overload;
    function WillExecute(Proc: TProc<TArray<TValue>>): IMockSetupWhen<T>; overload;
    function WillReturn(const Value: TValue): IMockSetupWhen<T>;
  end;

  IMockExpectSetup<T: IInterface> = interface
    ['{3E5A7304-B683-474B-A799-B5BDE281AC22}']
    function CheckExpectations: String;
    function CustomExpect(Func: TFunc<TArray<TValue>, String>): IMockSetupWhen<T>;
    function ExecutionCount(const ExecutionCountExpected: Integer): IMockSetupWhen<T>;
    function Never: IMockSetupWhen<T>;
    function Once: IMockSetupWhen<T>;
  end;

  IMock<T: IInterface> = interface
    ['{C249D074-74A0-4AB9-BA7D-102CA4811019}']
    function CheckExpectations: String;
    function Expect: IMockExpectSetup<T>;
    function Instance: T;
    function Setup: IMockSetup<T>;
  end;

  TMockSetupWhenInterface<T: IInterface> = class(TVirtualInterfaceEx, IMockSetupWhen<T>)
  private
    FMethodRegister: IMethodRegister;

    function When: T;

    procedure OnInvoke(Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue);
  public
    constructor Create(MethodRegister: IMethodRegister);
  end;

  TMockSetupInterface<T: IInterface> = class(TVirtualInterfaceEx, IMockSetup<T>, IMockExpectSetup<T>)
  private
    FMockSetupWhen: IMockSetupWhen<T>;
    FMethodRegister: IMethodRegister;

    function CheckExpectations: String;
    function CustomExpect(Func: TFunc<TArray<TValue>, String>): IMockSetupWhen<T>;
    function ExecutionCount(const ExecutionCountExpected: Integer): IMockSetupWhen<T>;
    function Never: IMockSetupWhen<T>;
    function Once: IMockSetupWhen<T>;
    function WillExecute(Proc: TFunc<TValue>): IMockSetupWhen<T>; overload;
    function WillExecute(Proc: TFunc<TArray<TValue>, TValue>): IMockSetupWhen<T>; overload;
    function WillExecute(Proc: TProc): IMockSetupWhen<T>; overload;
    function WillExecute(Proc: TProc<TArray<TValue>>): IMockSetupWhen<T>; overload;
    function WillReturn(const Value: TValue): IMockSetupWhen<T>;

    procedure OnInvoke(Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue);
  public
    constructor Create(const AutoMock: Boolean);
  end;

  TMockInterface<T: IInterface> = class(TInterfacedObject, IMock<T>)
  private
    FMockSetup: IMockSetup<T>;
    FMockExpectSetup: IMockExpectSetup<T>;

    function CheckExpectations: String;
    function Expect: IMockExpectSetup<T>;
    function Instance: T;
    function Setup: IMockSetup<T>;
  public
    constructor Create(const AutoMock: Boolean);
  end;

implementation

uses System.TypInfo;

{ TMockInterface<T> }

function TMockInterface<T>.CheckExpectations: String;
begin
  Result := FMockExpectSetup.CheckExpectations;
end;

constructor TMockInterface<T>.Create(const AutoMock: Boolean);
begin
  inherited Create;

  var Setup := TMockSetupInterface<T>.Create(AutoMock);
  FMockSetup := Setup;
  FMockExpectSetup := Setup;
end;

function TMockInterface<T>.Expect: IMockExpectSetup<T>;
begin
  Result := FMockExpectSetup;
end;

function TMockInterface<T>.Instance: T;
begin
  FMockSetup.QueryInterface(PTypeInfo(TypeInfo(T)).TypeData.GUID, Result);
end;

function TMockInterface<T>.Setup: IMockSetup<T>;
begin
  Result := FMockSetup;
end;

{ TMockSetupInterface<T> }

function TMockSetupInterface<T>.CheckExpectations: String;
begin
  Result := FMethodRegister.CheckExpectations;
end;

constructor TMockSetupInterface<T>.Create(const AutoMock: Boolean);
begin
  inherited Create(TypeInfo(T), OnInvoke);

  FMethodRegister := TMethodRegister.Create(AutoMock);
  FMockSetupWhen := TMockSetupWhenInterface<T>.Create(FMethodRegister);
end;

function TMockSetupInterface<T>.CustomExpect(Func: TFunc<TArray<TValue>, String>): IMockSetupWhen<T>;
begin
  Result := FMockSetupWhen;

  FMethodRegister.StartRegister(TMethodInfoCustomExpectation.Create(Func));
end;

function TMockSetupInterface<T>.ExecutionCount(const ExecutionCountExpected: Integer): IMockSetupWhen<T>;
begin
  FMethodRegister.StartRegister(TMethodInfoExpectExecutionCount.Create(ExecutionCountExpected));

  Result := FMockSetupWhen;
end;

function TMockSetupInterface<T>.Never: IMockSetupWhen<T>;
begin
  Result := FMockSetupWhen;

  FMethodRegister.StartRegister(TMethodInfoExpectNever.Create);
end;

function TMockSetupInterface<T>.Once: IMockSetupWhen<T>;
begin
  Result := FMockSetupWhen;

  FMethodRegister.StartRegister(TMethodInfoExpectOnce.Create);
end;

procedure TMockSetupInterface<T>.OnInvoke(Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue);
begin
  var AdjustedArgs: TArray<TValue> := Args;

  Delete(AdjustedArgs, 0, 1);

  FMethodRegister.ExecuteMethod(Method, AdjustedArgs, Result);
end;

function TMockSetupInterface<T>.WillExecute(Proc: TProc): IMockSetupWhen<T>;
begin
  Result := FMockSetupWhen;

  FMethodRegister.StartRegister(TMethodInfoWillExecute.Create(Proc));
end;

function TMockSetupInterface<T>.WillExecute(Proc: TFunc<TArray<TValue>, TValue>): IMockSetupWhen<T>;
begin
  Result := FMockSetupWhen;

  FMethodRegister.StartRegister(TMethodInfoWillExecute.Create(Proc));
end;

function TMockSetupInterface<T>.WillExecute(Proc: TProc<TArray<TValue>>): IMockSetupWhen<T>;
begin
  Result := FMockSetupWhen;

  FMethodRegister.StartRegister(TMethodInfoWillExecute.Create(Proc));
end;

function TMockSetupInterface<T>.WillExecute(Proc: TFunc<TValue>): IMockSetupWhen<T>;
begin
  Result := FMockSetupWhen;

  FMethodRegister.StartRegister(TMethodInfoWillExecute.Create(Proc));
end;

function TMockSetupInterface<T>.WillReturn(const Value: TValue): IMockSetupWhen<T>;
begin
  Result := FMockSetupWhen;

  FMethodRegister.StartRegister(TMethodInfoWillReturn.Create(Value));
end;

{ TMockSetupWhenInterface<T> }

constructor TMockSetupWhenInterface<T>.Create(MethodRegister: IMethodRegister);
begin
  inherited Create(TypeInfo(T), OnInvoke);

  FMethodRegister := MethodRegister;
end;

procedure TMockSetupWhenInterface<T>.OnInvoke(Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue);
begin
  FMethodRegister.RegisterMethod(Method);
end;

function TMockSetupWhenInterface<T>.When: T;
begin
  QueryInterface(PTypeInfo(TypeInfo(T)).TypeData.GUID, Result);
end;

end.

