unit Delphi.Mock;

interface

uses System.Rtti, System.SysUtils, System.Generics.Collections;

type
  EExpectationsNotConfigured = class(Exception);
  EMethodNotRegistred = class(Exception);

  IIt = interface
    ['{5B034A6E-3953-4A0A-9A3A-6805210E082E}']
    function Compare(const Value: TValue): Boolean;
  end;

  IMethodInfo = interface
    ['{047238B7-4FEB-4D99-A7B9-108F1627F298}']
    function GetItParams: TArray<IIt>;

    procedure Execute(out Result: TValue);
    procedure FillItParams;

    property ItParams: TArray<IIt> read GetItParams;
  end;

  IMethodRegister = interface
    ['{7F5EAD8F-550C-422F-ACF6-2D3C19097748}']
    function GetMethods: TArray<IMethodInfo>;

    procedure RegisterMethod(Method: TRttiMethod; Info: IMethodInfo);
  end;

  IMockSetup<T> = interface
    ['{778531BB-4093-4103-B4BC-72845B78387B}']
    function When: T;
  end;

  IMockExpect = interface
    ['{D8C9262E-8412-4464-97AC-C01ABF3B8991}']
    function CheckExpectations: String;
  end;

  IMockExpectSetup<T> = interface
    ['{3E5A7304-B683-474B-A799-B5BDE281AC22}']
    function Once: IMockSetup<T>;
  end;

  IMock<T> = interface
    ['{C249D074-74A0-4AB9-BA7D-102CA4811019}']
    function CheckExpectations: String;
    function Expect: IMockExpectSetup<T>;
    function Instance: T;
    function WillExecute(Proc: TProc): IMockSetup<T>;
    function WillReturn(const Value: TValue): IMockSetup<T>;
  end;

  TMock = class
    class function CreateClass<T: class>: IMock<T>;
    class function CreateInterface<T: IInterface>: IMock<T>;
  end;

  TIt = class(TInterfacedObject, IIt)
  private type
    TItCompare = (NotDefined, Any, EqualTo, NotEqualTo);
  private
    FItCompare: TItCompare;
    FValueToCompare: TValue;

    function Compare(const Value: TValue): Boolean;
    function CompareEqualValue(const Value: TValue): Boolean;
  public
    function IsAny<T>: T;
    function IsEqualTo<T>(const Value: T): T;
    function IsNotEqualTo<T>(const Value: T): T;
  end;

function It: TIt;

var
  GItParams: TArray<IIt>;

implementation

uses Delphi.Mock.Interf, Delphi.Mock.Classs, Delphi.Mock.Method.Types;

function It: TIt;
begin
  Result := TIt.Create;

  GItParams := GItParams + [Result];
end;

{ TMock }

class function TMock.CreateClass<T>: IMock<T>;
begin
  Result := TMockClass<T>.Create;
end;

class function TMock.CreateInterface<T>: IMock<T>;
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

