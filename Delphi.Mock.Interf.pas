unit Delphi.Mock.Interf;

interface

uses System.Rtti, System.Generics.Collections, System.SysUtils, Delphi.Mock, Delphi.Mock.VirtualInterface;

type
  TMockInterface<T: IInterface> = class(TVirtualInterfaceEx, IMock<T>, IMethodRegister)
  private
    FRegistredMethods: TDictionary<TRttiMethod, TArray<IMethodInfo>>;
    FExpectations: IMockExpect;

    function CreateMockSetup(MethodInfo: IMethodInfo): IMockSetup<T>;
    function GetMethods: TArray<IMethodInfo>;
    function FindMethod(Method: TRttiMethod; const Args: TArray<TValue>): IMethodInfo;

    procedure OnInvoke(Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue);
    procedure RegisterMethod(Method: TRttiMethod; Info: IMethodInfo);
  public
    constructor Create; reintroduce;

    destructor Destroy; override;

    function CheckExpectations: String;
    function Expect: IMockExpectSetup<T>;
    function Instance: T;
    function WillExecute(Proc: TProc): IMockSetup<T>;
    function WillReturn(const Value: TValue): IMockSetup<T>;

    property RegistredMethods: TDictionary<TRttiMethod, TArray<IMethodInfo>> read FRegistredMethods write FRegistredMethods;
  end;

implementation

uses System.TypInfo, Delphi.Mock.Interf.Setup, Delphi.Mock.Interf.Expect, Delphi.Mock.Method.Types;

{ TMockInterface<T> }

function TMockInterface<T>.CheckExpectations: String;
begin
  if Assigned(FExpectations) then
  begin
    Result := FExpectations.CheckExpectations;

    FExpectations := nil;
  end
  else
    raise EExpectationsNotConfigured.Create('Expectations not configured');
end;

constructor TMockInterface<T>.Create;
begin
  inherited Create(TypeInfo(T), OnInvoke);

  FRegistredMethods := TDictionary<TRttiMethod, TArray<IMethodInfo>>.Create;
end;

function TMockInterface<T>.CreateMockSetup(MethodInfo: IMethodInfo): IMockSetup<T>;
begin
  Result := TMockSetupInterface<T>.Create(Self, MethodInfo);
end;

destructor TMockInterface<T>.Destroy;
begin
  FRegistredMethods.Free;

  inherited;
end;

function TMockInterface<T>.Expect: IMockExpectSetup<T>;
begin
  Result := TMockExpectInteface<T>.Create(Self);

  FExpectations := Result as IMockExpect;
end;

function TMockInterface<T>.FindMethod(Method: TRttiMethod; const Args: TArray<TValue>): IMethodInfo;
begin
  if not RegistredMethods.ContainsKey(Method) then
    raise EMethodNotRegistred.CreateFmt('The method %s don''t have a registred mock!', [Method.Name]);

  for var RegistredMethod in RegistredMethods[Method] do
  begin
    var ItParams := RegistredMethod.ItParams;
    Result := RegistredMethod;

    if Length(ItParams) > 0 then
      for var A := Low(ItParams) to High(ItParams) do
        if not ItParams[A].Compare(Args[Succ(A)]) then
          Result := nil;

    if Assigned(Result) then
      Exit;
  end;
end;

function TMockInterface<T>.GetMethods: TArray<IMethodInfo>;
begin
  Result := nil;
  for var Methodos in FRegistredMethods.Values do
    Result := Result + Methodos;
end;

function TMockInterface<T>.Instance: T;
begin
  QueryInterface(PTypeInfo(TypeInfo(T)).TypeData.GUID, Result);
end;

procedure TMockInterface<T>.OnInvoke(Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue);
begin
  FindMethod(Method, Args).Execute(Result);
end;

procedure TMockInterface<T>.RegisterMethod(Method: TRttiMethod; Info: IMethodInfo);
begin
  if not RegistredMethods.ContainsKey(Method) then
    RegistredMethods.Add(Method, nil);

  RegistredMethods[Method] := RegistredMethods[Method] + [Info];
end;

function TMockInterface<T>.WillExecute(Proc: TProc): IMockSetup<T>;
begin
  Result := CreateMockSetup(TMethodInfoWillExecute.Create(Proc));
end;

function TMockInterface<T>.WillReturn(const Value: TValue): IMockSetup<T>;
begin
  Result := CreateMockSetup(TMethodInfoWillReturn.Create(Value));
end;

end.
