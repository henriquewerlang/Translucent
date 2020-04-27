unit Delphi.Mock;

interface

uses System.Rtti, System.SysUtils, Delphi.Mock.Method;

type
  IMockSetupWhen<T> = interface
    ['{1EE67E5A-C054-4771-842F-3FBCD39BB90B}']
    function When: T;
  end;

  IMockSetup<T> = interface
    ['{778531BB-4093-4103-B4BC-72845B78387B}']
    function Instance: T;
    function WillExecute(Proc: TProc): IMockSetupWhen<T>;
    function WillReturn(const Value: TValue): IMockSetupWhen<T>;
  end;

  IMockExpectSetup<T> = interface
    ['{3E5A7304-B683-474B-A799-B5BDE281AC22}']
    function CheckExpectations: String;
    function Once: IMockSetup<T>;
  end;

  IMock<T> = interface
    ['{C249D074-74A0-4AB9-BA7D-102CA4811019}']
    function Expect: IMockExpectSetup<T>;
    function Setup: IMockSetup<T>;
  end;

  TMock = class
  public
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

implementation

uses Delphi.Mock.Interf;

function It: TIt;
begin
  Result := TIt.Create;

  GItParams := GItParams + [Result];
end;

{ TMock }

class function TMock.CreateClass<T>: IMock<T>;
begin
//  Result := TMock<T>.Create;
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

