unit Delphi.Mock;

interface

uses System.Rtti, System.SysUtils, Delphi.Mock.Method, Delphi.Mock.Classes, Delphi.Mock.Intf;

type
  TMock = class
  public
    class function CreateClass<T: class, constructor>: TMock<T>;
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

function It: TIt;
begin
  Result := TIt.Create;

  GItParams := GItParams + [Result];
end;

{ TMock }

class function TMock.CreateClass<T>: TMock<T>;
begin
  Result := TMock<T>.Create;
end;

class function TMock.CreateInterface<T>: IMock<T>;
begin
  Result := TMockIntf<T>.Create;
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

