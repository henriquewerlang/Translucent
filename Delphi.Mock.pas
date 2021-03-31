unit Delphi.Mock;

interface

uses System.Rtti, System.SysUtils, Delphi.Mock.Method, Delphi.Mock.Classes, Delphi.Mock.Intf;

type
  TMock = class
  public
    class function CreateClass<T: class>(const ConstructorArgs: TArray<TValue> = nil): TMock<T>;
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

function It: TIt; overload;
function It(ParamIndex: Integer): TIt; overload;

implementation

uses System.Math;

function It: TIt;
begin
  Result := It(Length(GItParams));
end;

function It(ParamIndex: Integer): TIt;
begin
  Result := TIt.Create;

  SetLength(GItParams, Max(Succ(ParamIndex), Length(GItParams)));

  GItParams[ParamIndex] := Result;
end;

{ TMock }

class function TMock.CreateClass<T>(const ConstructorArgs: TArray<TValue>): TMock<T>;
begin
  Result := TMock<T>.Create(ConstructorArgs);
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
  Result := not(FValueToCompare.IsEmpty or Value.IsEmpty) and (FValueToCompare.AsVariant = Value.AsVariant);
end;

function TIt.IsAny<T>: T;
begin
  FItCompare := Any;
  Result := Default (T);
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
