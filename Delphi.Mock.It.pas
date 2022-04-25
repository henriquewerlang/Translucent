unit Delphi.Mock.It;

interface

uses System.Generics.Collections, System.Rtti, System.SysUtils;

type
  TItComparision = (icAny, icEqualTo, icNotEqualTo, icSameFields, icSameProperties);

  EDifferentTypeInComparision = class(Exception)
  public
    constructor Create;
  end;

  EInvalidTypeToItParam = class(Exception)
  public
    constructor Create;
  end;

  IIt = interface
    ['{5B034A6E-3953-4A0A-9A3A-6805210E082E}']
    function Compare(const Value: TValue): Boolean;
  end;

  TItParam<T> = class(TInterfacedObject, IIt)
  private
    FItComparision: TItComparision;

    function Compare(const ValueToCompare: TValue): Boolean;
    function CompareValues(const CurrentValue, ValueToCompare: TValue): Boolean;
    function CompareEqualValue(const CurrentValue, ValueToCompare: TValue): Boolean;
    function CompareFields(const CurrentValue, ValueToCompare: TValue): Boolean;
    function CompareProperties(const CurrentValue, ValueToCompare: TValue): Boolean;
    function SameTypes(const CurrentValue, ValueToCompare: TValue): Boolean;
  public
    Value: T;

    constructor Create(ItComparision: TItComparision; const Value: T);

    property ItComparision: TItComparision read FItComparision;
  end;

  TItParams = class
  private class var
    FGParams: TList<IIt>;
    FGParamIndex: Integer;
  public
    class constructor Create;

    class destructor Destroy;

    class procedure AddParam(AParam: IIt);
    class procedure ResetParams;

    class property ParamIndex: Integer read FGParamIndex write FGParamIndex;
    class property Params: TList<IIt> read FGParams;
  end;

implementation

uses System.Math, System.TypInfo;

const
  PARAM_INDEX_AT_THE_END = -1;

{ TItParams }

class procedure TItParams.AddParam(AParam: IIt);
begin
  Params.Count := Max(Succ(ParamIndex), Params.Count);

  if ParamIndex = PARAM_INDEX_AT_THE_END then
    Params.Add(AParam)
  else
    Params[ParamIndex] := AParam;

  ParamIndex := PARAM_INDEX_AT_THE_END;
end;

class constructor TItParams.Create;
begin
  FGParamIndex := PARAM_INDEX_AT_THE_END;
  FGParams := TList<IIt>.Create;
end;

class destructor TItParams.Destroy;
begin
  FGParams.Free;
end;

class procedure TItParams.ResetParams;
begin
  Params.Clear;
end;

{ TItParam<T> }

function TItParam<T>.Compare(const ValueToCompare: TValue): Boolean;
begin
  var CurrentValue := TValue.From<T>(Value);
  Result := CompareValues(CurrentValue, ValueToCompare);
end;

function TItParam<T>.CompareEqualValue(const CurrentValue, ValueToCompare: TValue): Boolean;
begin
  if SameTypes(CurrentValue, ValueToCompare) then
    case CurrentValue.Kind of
      tkInteger: Exit(CurrentValue.AsInteger = ValueToCompare.AsInteger);

      tkChar,
      tkWChar,
      tkLString,
      tkString,
      tkUString,
      tkWString: Exit(CurrentValue.AsString = ValueToCompare.AsString);

      tkEnumeration: Exit(CurrentValue.AsOrdinal = ValueToCompare.AsOrdinal);

      tkFloat: Exit(CurrentValue.AsExtended = ValueToCompare.AsExtended);

      tkSet: Exit(CurrentValue.ToString = ValueToCompare.ToString);

      tkClass: Exit(CurrentValue.AsObject = ValueToCompare.AsObject);
      tkVariant: Exit(CurrentValue.AsVariant = ValueToCompare.AsVariant);
      tkInt64: Exit(CurrentValue.AsInt64 = ValueToCompare.AsInt64);
      tkPointer: Exit(CurrentValue.AsType<Pointer> = ValueToCompare.AsType<Pointer>);

      tkArray,
      tkDynArray:
      begin
        Result := CurrentValue.GetArrayLength = ValueToCompare.GetArrayLength;

        if Result then
          for var A := 0 to Pred(CurrentValue.GetArrayLength) do
            if not CompareEqualValue(CurrentValue.GetArrayElement(A), ValueToCompare.GetArrayElement(A)) then
              Exit(False);

        Exit(Result);
      end;

      tkRecord:
      begin
        if CurrentValue.TypeInfo = TypeInfo(TValue) then
        begin
          var CurrentValueIsEmpty := CurrentValue.AsType<TValue>.IsEmpty;
          var ValueToCompareIsEmpty := ValueToCompare.AsType<TValue>.IsEmpty;

          Exit(CurrentValueIsEmpty and ValueToCompareIsEmpty or not (CurrentValueIsEmpty xor ValueToCompareIsEmpty)
            and CompareEqualValue(CurrentValue.AsType<TValue>, ValueToCompare.AsType<TValue>));
        end;
      end;
    end;

  raise EInvalidTypeToItParam.Create;
end;

function TItParam<T>.CompareFields(const CurrentValue, ValueToCompare: TValue): Boolean;
begin
  var Context := TRttiContext.Create;
  Result := not CurrentValue.IsEmpty and not ValueToCompare.IsEmpty;

  if Result then
    for var Field in Context.GetType(CurrentValue.TypeInfo).GetFields do
      if not CompareEqualValue(Field.GetValue(CurrentValue.AsObject), Field.GetValue(ValueToCompare.AsObject)) then
        Exit(False);

  Context.Free;
end;

function TItParam<T>.CompareProperties(const CurrentValue, ValueToCompare: TValue): Boolean;
begin
  var Context := TRttiContext.Create;
  Result := not CurrentValue.IsEmpty and not ValueToCompare.IsEmpty;

  if Result then
    for var AProperty in Context.GetType(CurrentValue.TypeInfo).GetProperties do
      if not CompareEqualValue(AProperty.GetValue(CurrentValue.AsObject), AProperty.GetValue(ValueToCompare.AsObject)) then
        Exit(False);

  Context.Free;
end;

function TItParam<T>.CompareValues(const CurrentValue, ValueToCompare: TValue): Boolean;
begin
  case FItComparision of
    icAny: Exit(SameTypes(CurrentValue, ValueToCompare));
    icEqualTo: Exit(CompareEqualValue(CurrentValue, ValueToCompare));
    icNotEqualTo: Exit(not CompareEqualValue(CurrentValue, ValueToCompare));
    icSameProperties: Exit(CompareProperties(CurrentValue, ValueToCompare));
    icSameFields: Exit(CompareFields(CurrentValue, ValueToCompare));
  end;
end;

constructor TItParam<T>.Create(ItComparision: TItComparision; const Value: T);
begin
  FItComparision := ItComparision;
  Self.Value := Value;
end;

function TItParam<T>.SameTypes(const CurrentValue, ValueToCompare: TValue): Boolean;
begin
  case CurrentValue.Kind of
    tkClass: Result := ValueToCompare.TypeInfo.TypeData.ClassType.InheritsFrom(CurrentValue.TypeInfo.TypeData.ClassType);
    tkRecord: Result := CurrentValue.TypeInfo = ValueToCompare.TypeInfo;
    else Result := CurrentValue.Kind = ValueToCompare.Kind;
  end;

  if not Result then
    raise EDifferentTypeInComparision.Create;
end;

{ EDifferentTypeInComparision }

constructor EDifferentTypeInComparision.Create;
begin
  inherited Create('You can compare only the same types!');
end;

{ EInvalidTypeToItParam }

constructor EInvalidTypeToItParam.Create;
begin
  inherited Create('The type of value for it param is invalid!');
end;

end.

