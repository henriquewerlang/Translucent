unit Delphi.Mock;

interface

uses System.Rtti, System.SysUtils, Delphi.Mock.Method, Delphi.Mock.Classes, Delphi.Mock.Intf;

type
  EInvalidTypeForComparision = class(Exception)
  public
    constructor Create;
  end;

  TMock = class
  public
    class function CreateClass<T: class>(const ConstructorArgs: TArray<TValue> = nil; const AutoMock: Boolean = False): TMock<T>;
    class function CreateInterface<T: IInterface>(const AutoMock: Boolean = False): IMock<T>;
  end;

  TIt = class(TInterfacedObject, IIt)
  private type
    TItCompare = (NotDefined, Any, EqualTo, NotEqualTo, HasSameFields, HasSameProperties);
  private
    FItCompare: TItCompare;
    FValueToCompare: TValue;

    function Compare(const Value: TValue): Boolean;
    function CompareEqualValue(const Value: TValue): Boolean;
    function CompareFieldsValues(const Value: TValue): Boolean;
    function ComparePropertiesValues(const Value: TValue): Boolean;
    function CompareEqualValues(const Left, Right: TValue): Boolean;
  public
    function IsAny<T>: T;
    function IsEqualTo<T>(const Value: T): T;
    function IsNotEqualTo<T>(const Value: T): T;
    function SameFields<T>(const Value: T): T;
    function SameProperties<T>(const Value: T): T;
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

class function TMock.CreateClass<T>(const ConstructorArgs: TArray<TValue>; const AutoMock: Boolean): TMock<T>;
begin
  Result := TMock<T>.Create(ConstructorArgs, AutoMock);
end;

class function TMock.CreateInterface<T>(const AutoMock: Boolean): IMock<T>;
begin
  Result := TMockInterface<T>.Create(AutoMock);
end;

{ TIt }

function TIt.Compare(const Value: TValue): Boolean;
begin
  Result := False;

  case FItCompare of
    Any: Result := True;
    EqualTo: Result := CompareEqualValue(Value);
    HasSameFields: Result := CompareFieldsValues(Value);
    HasSameProperties: Result := ComparePropertiesValues(Value);
    NotEqualTo: Result := not CompareEqualValue(Value);
  end;
end;

function TIt.CompareEqualValue(const Value: TValue): Boolean;
begin
  Result := CompareEqualValues(FValueToCompare, Value);
end;

function TIt.CompareFieldsValues(const Value: TValue): Boolean;
begin
  var Context := TRttiContext.Create;

  for var Field in Context.GetType(FValueToCompare.TypeInfo).GetFields do
    if not CompareEqualValues(Field.GetValue(FValueToCompare.AsObject), Field.GetValue(Value.AsObject)) then
      Exit(False);

  Result := True;
end;

function TIt.ComparePropertiesValues(const Value: TValue): Boolean;
begin
  var Context := TRttiContext.Create;

  for var &Property in Context.GetType(FValueToCompare.TypeInfo).GetProperties do
    if not CompareEqualValues(&Property.GetValue(FValueToCompare.AsObject), &Property.GetValue(Value.AsObject)) then
      Exit(False);

  Result := True;
end;

function TIt.CompareEqualValues(const Left, Right: TValue): Boolean;
const
  EQUIVALENT_TYPE: array[TTypeKind] of TTypeKind = (tkUnknown, tkInt64, tkString, tkEnumeration, tkFloat, tkString, tkSet, tkClass, tkUnknown, tkString, tkString, tkString,
    tkVariant, tkArray, tkRecord, tkInterface, tkInt64, tkDynArray, tkString, tkClassRef, tkPointer, tkUnknown, tkMRecord);

begin
  Result := EQUIVALENT_TYPE[Left.Kind] = EQUIVALENT_TYPE[Right.Kind];

  if Result then
    case EQUIVALENT_TYPE[Left.Kind] of
      tkEnumeration: Result := Left.AsOrdinal = Right.AsOrdinal;
      tkInt64: Result := Left.AsInt64 = Right.AsInt64;
      tkFloat: Result := Left.AsExtended = Right.AsExtended;
      tkString: Result := Left.AsString = Right.AsString;
      tkVariant: Result := Left.AsVariant = Right.AsVariant;
      tkRecord:
      begin
        Result := (Left.TypeInfo = TypeInfo(TValue)) and (Right.TypeInfo = TypeInfo(TValue));

        if Result then
          Result := Left.AsType<TValue>.IsEmpty and Right.AsType<TValue>.IsEmpty or CompareEqualValues(Left.AsType<TValue>, Right.AsType<TValue>)
        else
          raise EInvalidTypeForComparision.Create;
      end;
      tkDynArray, tkArray:
      begin
        Result := Left.GetArrayLength = Right.GetArrayLength;

        if Result then
          for var A := 0 to Pred(Left.GetArrayLength) do
            if not CompareEqualValues(Left.GetArrayElement(A), Right.GetArrayElement(A)) then
              Exit(False);
      end;
      else Result := False;
    end;
end;

function TIt.IsAny<T>: T;
begin
  FItCompare := Any;
  Result := Default(T);
end;

function TIt.IsEqualTo<T>(const Value: T): T;
begin
  FItCompare := EqualTo;
  FValueToCompare := TValue.From<T>(Value);
  Result := Value;
end;

function TIt.IsNotEqualTo<T>(const Value: T): T;
begin
  FItCompare := NotEqualTo;
  FValueToCompare := TValue.From(Value);
  Result := Value;
end;

function TIt.SameFields<T>(const Value: T): T;
begin
  FItCompare := HasSameFields;
  FValueToCompare := TValue.From(Value);
  Result := Value;
end;

function TIt.SameProperties<T>(const Value: T): T;
begin
  FItCompare := HasSameProperties;
  FValueToCompare := TValue.From(Value);
  Result := Value;
end;

{ EInvalidTypeForComparision }

constructor EInvalidTypeForComparision.Create;
begin
  inherited Create('The type for comparision is invalid!');
end;

end.

