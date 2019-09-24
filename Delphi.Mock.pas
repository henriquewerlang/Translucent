unit Delphi.Mock;

interface

uses System.Rtti, System.SysUtils, System.Generics.Collections, Delphi.Mock.VirtualInterface;

type
  EMethodNotRegistred = class(Exception);

  IIt = interface
    function Compare(const Value: TValue): Boolean;
  end;

  IMethodInfo = interface
    function GetItParams: TArray<IIt>;

    procedure Execute(out Result: TValue);
    procedure FillItParams;

    property ItParams: TArray<IIt> read GetItParams;
  end;

  IMethodRegister = interface
    procedure RegisterMethod(Method: TRttiMethod; Info: IMethodInfo);
  end;

  IMockSetup<T> = interface
    function When: T;
  end;

  IMock<T> = interface
    function Instance: T;
    function WillExecute(Proc: TProc): IMockSetup<T>;
    function WillReturn(const Value: TValue): IMockSetup<T>;
  end;

  TMock = class
    class function Create<T: IInterface>: IMock<T>;
  end;

  TMockInterface<T: IInterface> = class(TVirtualInterfaceEx, IMock<T>, IMethodRegister)
  private
    FRegistredMethods: TDictionary<TRttiMethod, TArray<IMethodInfo>>;

    function CreateMockSetup(MethodInfo: IMethodInfo): IMockSetup<T>;
    function FindMethod(Method: TRttiMethod; const Args: TArray<TValue>): IMethodInfo;

    procedure OnInvoke(Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue);
    procedure RegisterMethod(Method: TRttiMethod; Info: IMethodInfo);
  public
    constructor Create; reintroduce;

    destructor Destroy; override;

    function Instance: T;
    function WillExecute(Proc: TProc): IMockSetup<T>;
    function WillReturn(const Value: TValue): IMockSetup<T>;

    property RegistredMethods: TDictionary<TRttiMethod, TArray<IMethodInfo>> read FRegistredMethods write FRegistredMethods;
  end;

  TIt = class(TInterfacedObject, IIt)
  private type
    TItCompare = (NotDefined, Any, EqualTo, NotEqualTo);
  private
    FItCompare: TItCompare;
    FValueToCompare: TValue;

    function CompareEqualValue(const Value: TValue): Boolean;
  public
    function Compare(const Value: TValue): Boolean;

    function IsAny<T>: T;
    function IsEqualTo<T>(const Value: T): T;
    function IsNotEqualTo<T>(const Value: T): T;
  end;

function It: TIt;

var
  GItParams: TArray<IIt>;

implementation

uses System.TypInfo, Delphi.Mock.Setup, Delphi.Mock.Method.Types;

function It: TIt;
begin
  Result := TIt.Create;

  GItParams := GItParams + [Result];
end;

{ TMockInterface<T> }

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

{ TMock }

class function TMock.Create<T>: IMock<T>;
begin
  Result := TMockInterface<T>.Create;
end;

{ TIt }

function TIt.Compare(const Value: TValue): Boolean;
begin
  Result := False;

  case FItCompare of
    Any: Result := True;
    EqualTo: Result := CompareEqualValue(Value);
    NotEqualTo: Result := not CompareEqualValue(Value);
  end;
end;

function TIt.CompareEqualValue(const Value: TValue): Boolean;
begin
  Result := (FValueToCompare.IsEmpty xor Value.IsEmpty) or (FValueToCompare.AsVariant = Value.AsVariant);
end;

function TIt.IsAny<T>: T;
begin
  FItCompare := Any;
  Result := Default(T);
end;

function TIt.IsEqualTo<T>(const Value: T): T;
begin
  FItCompare := EqualTo;
  FValueToCompare := TValue.From(Value);
  Result := Value;
end;

function TIt.IsNotEqualTo<T>(const Value: T): T;
begin
  FItCompare := NotEqualTo;
  FValueToCompare := TValue.From(Value);
  Result := Value;
end;

end.

