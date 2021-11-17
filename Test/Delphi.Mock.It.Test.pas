unit Delphi.Mock.It.Test;

interface

uses DUnitX.TestFramework, Delphi.Mock.It;

type
  [TestFixture]
  TItParamsTest = class
  public
    [Test]
    procedure WhenCallClearParamsMustResetTheGlobalVarOfParams;
    [Test]
    procedure WhenAddAParamMustAddTheItParamInTheListOfParams;
    [Test]
    procedure WhenAddAParamWithAParamIndexFilledMustFillAllThePositionsTheListReachTheValueInParamIndex;
    [Test]
    procedure WhenTheParamIndexIsLowerThenTheCountOfParamsCantChangeTheParamListCount;
    [Test]
    procedure WhenAddAParamWithAParamIndexFilledMustAddTheParamAtThatPosition;
    [Test]
    procedure AfterInsertAParamMustResetTheParamIndexValue;
    [Test]
    procedure IfTheParamIndexNotFilledMustAddTheParamInTheEndOfTheList;
  end;

  [TestFixture]
  TItParamTest = class
  public
    [SetupFixture]
    procedure SetupFixture;
    [Test]
    procedure IfComparingWithAnyAlwaysReturnTrue;
    [TestCase('Equal, same value', '123,True')]
    [TestCase('Equal, different value', '456,False')]
    procedure IfComparingEqualMustReturnTrueOnlyIfIsTheSameValue(const Value: Integer; const ExpectedResult: Boolean);
    [TestCase('Not equal, same value', '123,False')]
    [TestCase('Not equal, different value', '456,True')]
    procedure IfComparingNotEqualMustReturnTrueOnlyIfIsDifferentValue(const Value: Integer; const ExpectedResult: Boolean);
    [Test]
    procedure WhenComparingDifferentTypesOfValuesMustRaiseAnError;
    [TestCase('kInteger', 'tkInteger')]
    [TestCase('tkChar', 'tkChar')]
    [TestCase('tkEnumeration', 'tkEnumeration')]
    [TestCase('tkFloat', 'tkFloat')]
    [TestCase('tkString', 'tkString')]
    [TestCase('tkSet', 'tkSet')]
    [TestCase('tkClass', 'tkClass')]
    [TestCase('tkMethod', 'tkMethod')]
    [TestCase('tkWChar', 'tkWChar')]
    [TestCase('tkLString', 'tkLString')]
    [TestCase('tkWString', 'tkWString')]
    [TestCase('tkVariant', 'tkVariant')]
    [TestCase('tkArray', 'tkArray')]
    [TestCase('tkRecord', 'tkRecord')]
    [TestCase('tkInterface', 'tkInterface')]
    [TestCase('tkInt64', 'tkInt64')]
    [TestCase('tkDynArray', 'tkDynArray')]
    [TestCase('tkUString', 'tkUString')]
    [TestCase('tkClassRef', 'tkClassRef')]
    [TestCase('tkPointer', 'tkPointer')]
    [TestCase('tkProcedure', 'tkProcedure')]
    [TestCase('tkMRecord', 'tkMRecord')]
    procedure TestCompareByType(const TypeKind: TTypeKind);
    [Test]
    procedure WhenCompareArrayWithDifferentLengthMustReturnFalseWhenComparingValues;
    [Test]
    procedure WhenCompareArrayAndAllValuesIsEqualMustReturnTrueInTheComparision;
    [Test]
    procedure WhenCompareArrayAndAValueIsNotEqualMustReturnFalseInTheComparision;
    [Test]
    procedure WhenComparingFieldsMustReturnFalseIfOneFieldHasADifferentValue;
    [Test]
    procedure WhenComparingFieldsMustReturnTrueIfAllFieldsHasASameValue;
    [Test]
    procedure WhenComparingPropertiesMustReturnFalseIfOnePropertyHasADifferentValue;
    [Test]
    procedure WhenComparingPropertiesMustReturnTrueIfAllPropertiesHasASameValue;
    [Test]
    procedure WhenComparingFieldsAndTheComparedValueIsNilMustReturnFalseInTheComparision;
    [Test]
    procedure WhenComparingFieldsAndTheCurrentValueIsNilMustReturnFalseInTheComparision;
    [Test]
    procedure WhenComparingPropertiesAndTheComparedValueIsNilMustReturnFalseInTheComparision;
    [Test]
    procedure WhenComparingPropertiesAndTheCurrentValueIsNilMustReturnFalseInTheComparision;
    [Test]
    procedure WhenComparingAnInvalidTypeMustRaiseAnError;
    [Test]
    procedure WhenComparingTValuesAndBothAreEmptyMustReturnTrueInTheComparision;
    [Test]
    procedure WhenComparingATValueAndTheCurrentValueIsEmptyTheReturnOfTheComparationMustBeFalse;
    [Test]
    procedure WhenComparingATValueAndTheValueToCompareIsEmptyTheReturnOfTheComparationMustBeFalse;
    [Test]
    procedure WhenComparingTwoClassesMustRaiseAnErrorIfTheTypesAreDiffent;
    [Test]
    procedure WhenComparingTwoRecordsMustRaiseAnErrorIfTheTypesAreDiffent;
    [Test]
    procedure WhenTheValueBeenComparedIsInheritedFromTheCurrentValueCantRaiseErrorOfDiffentType;
  end;

  [TestFixture]
  TItTest = class
  private
    procedure MakeTest<T>(const Comparision: TItComparision; const ReturnFunctionValue, ValueToCompare: T);
  public
    [SetupFixture]
    procedure SetupFixture;
    [Test]
    procedure IsAnyAllTests;
    [Test]
    procedure IsEqualToAllTests;
    [Test]
    procedure IsNotEqualToAllTests;
    [Test]
    procedure SameFieldsToAllTests;
    [Test]
    procedure SamePropertiesToAllTests;
    [Test]
    procedure WhenUseTheParamIndexInTheItCallMustLoadTheParamIndexWithThatValue;
  end;

  [TestFixture]
  TItReferenceTest = class
  private
    procedure MakeTest<T>(const Comparision: TItComparision; const ItParam: TItParam<T>; const ValueToCompare: T);
  public
    [SetupFixture]
    procedure SetupFixture;
    [Test]
    procedure IsAnyAllTests;
    [Test]
    procedure IsEqualToAllTests;
    [Test]
    procedure IsNotEqualToAllTests;
    [Test]
    procedure SameFieldsToAllTests;
    [Test]
    procedure SamePropertiesToAllTests;
    [Test]
    procedure WhenUseTheParamIndexInTheItCallMustLoadTheParamIndexWithThatValue;
  end;

  TMyClass = class
  private
    FMyProperty: String;
    FMyProperty2: Integer;
  public
    MyField: String;
    MyField2: Integer;

    property MyProperty: String read FMyProperty write FMyProperty;
    property MyProperty2: Integer read FMyProperty2 write FMyProperty2;
  end;

  TMyClass2 = class(TMyClass)

  end;

  TMyRecord = record
  end;

  TMyEnumerator = (Enum1, Enum2, Enum3);
  TMyEnumerators = set of TMyEnumerator;

implementation

uses System.Rtti, System.SysUtils, Delphi.Mock;

{ TItParamsTest }

procedure TItParamsTest.AfterInsertAParamMustResetTheParamIndexValue;
begin
  TItParams.ParamIndex := 3;

  TItParams.AddParam(TItParam<Integer>.Create(icAny, 0));

  Assert.AreEqual(-1, TItParams.ParamIndex);

  TItParams.ResetParams;
end;

procedure TItParamsTest.IfTheParamIndexNotFilledMustAddTheParamInTheEndOfTheList;
begin
  TItParams.Params.Count := 10;

  TItParams.AddParam(TItParam<Integer>.Create(icAny, 0));

  Assert.IsNotNull(TItParams.Params[10]);

  TItParams.ResetParams;
end;

procedure TItParamsTest.WhenAddAParamMustAddTheItParamInTheListOfParams;
begin
  TItParams.AddParam(TItParam<Integer>.Create(icAny, 0));

  Assert.AreEqual(1, TItParams.Params.Count);

  TItParams.ResetParams;
end;

procedure TItParamsTest.WhenAddAParamWithAParamIndexFilledMustAddTheParamAtThatPosition;
begin
  TItParams.ParamIndex := 3;
  TItParams.Params.Count := 5;

  TItParams.AddParam(TItParam<Integer>.Create(icAny, 0));

  Assert.IsNotNull(TItParams.Params[3]);

  TItParams.ResetParams;
end;

procedure TItParamsTest.WhenAddAParamWithAParamIndexFilledMustFillAllThePositionsTheListReachTheValueInParamIndex;
begin
  TItParams.ParamIndex := 3;

  TItParams.AddParam(TItParam<Integer>.Create(icAny, 0));

  Assert.AreEqual(4, TItParams.Params.Count);

  TItParams.ResetParams;
end;

procedure TItParamsTest.WhenCallClearParamsMustResetTheGlobalVarOfParams;
begin
  TItParams.Params.Count := 20;

  TItParams.ResetParams;

  Assert.AreEqual(0, TItParams.Params.Count);
end;

procedure TItParamsTest.WhenTheParamIndexIsLowerThenTheCountOfParamsCantChangeTheParamListCount;
begin
  TItParams.Params.Count := 10;
  TItParams.ParamIndex := 3;

  TItParams.AddParam(TItParam<Integer>.Create(icAny, 0));

  Assert.AreEqual(10, TItParams.Params.Count);

  TItParams.ResetParams;
end;

{ TItParamTest }

procedure TItParamTest.IfComparingEqualMustReturnTrueOnlyIfIsTheSameValue(const Value: Integer; const ExpectedResult: Boolean);
begin
  var ItParam: IIt := TItParam<Integer>.Create(icEqualTo, 123);

  Assert.AreEqual(ExpectedResult, ItParam.Compare(Value));
end;

procedure TItParamTest.IfComparingNotEqualMustReturnTrueOnlyIfIsDifferentValue(const Value: Integer; const ExpectedResult: Boolean);
begin
  var ItParam: IIt := TItParam<Integer>.Create(icNotEqualTo, 123);

  Assert.AreEqual(ExpectedResult, ItParam.Compare(Value));
end;

procedure TItParamTest.IfComparingWithAnyAlwaysReturnTrue;
begin
  var ItParam: IIt := TItParam<Integer>.Create(icAny, 0);

  Assert.IsTrue(ItParam.Compare(123));
end;

procedure TItParamTest.SetupFixture;
begin
  TRttiContext.Create.GetType(TMyClass).GetFields;
end;

procedure TItParamTest.TestCompareByType(const TypeKind: TTypeKind);
const
  IT_COMPARISION: array[0..2] of TItComparision = (icEqualTo, icNotEqualTo, icAny);
  IT_COMPARISION_MESSAGE: array[0..2] of String = ('equal to', 'not equal to', 'any');
  IT_COMPARISION_RESULT_EXPECTED: array[0..2] of Boolean = (False, True, True);

begin
  var ItParam: IIt;
  var ValueToCompare: TValue;

  for var A := Low(IT_COMPARISION) to High(IT_COMPARISION) do
  begin
    case TypeKind of
      tkInteger:
      begin
        ItParam := TItParam<Integer>.Create(IT_COMPARISION[A], 123);
        ValueToCompare := TValue.From<Integer>(456);
      end;
      tkChar:
      begin
        ItParam := TItParam<AnsiChar>.Create(IT_COMPARISION[A], 'X');
        ValueToCompare := TValue.From<AnsiChar>('Y');
      end;
      tkEnumeration:
      begin
        ItParam := TItParam<TMyEnumerator>.Create(IT_COMPARISION[A], Enum2);
        ValueToCompare := TValue.From<TMyEnumerator>(Enum3);
      end;
      tkFloat:
      begin
        ItParam := TItParam<Double>.Create(IT_COMPARISION[A], 123.456);
        ValueToCompare := TValue.From<Double>(789.012);
      end;
      tkString:
      begin
        ItParam := TItParam<ShortString>.Create(IT_COMPARISION[A], 'ABC');
        ValueToCompare := TValue.From<ShortString>('DEF');
      end;
      tkSet:
      begin
        ItParam := TItParam<TMyEnumerators>.Create(IT_COMPARISION[A], [Enum1, Enum2]);
        ValueToCompare := TValue.From<TMyEnumerators>([Enum2, Enum3]);
      end;
      tkClass:
      begin
        ItParam := TItParam<TItParamTest>.Create(IT_COMPARISION[A], Self);
        ValueToCompare := TValue.From<TItParamTest>(nil);
      end;
      tkWChar:
      begin
        ItParam := TItParam<Char>.Create(IT_COMPARISION[A], 'X');
        ValueToCompare := TValue.From<Char>('Y');
      end;
      tkLString:
      begin
        ItParam := TItParam<AnsiString>.Create(IT_COMPARISION[A], 'ABC');
        ValueToCompare := TValue.From<AnsiString>('DEF');
      end;
      tkWString:
      begin
        ItParam := TItParam<WideString>.Create(IT_COMPARISION[A], 'ABC');
        ValueToCompare := TValue.From<WideString>('DEF');
      end;
      tkVariant:
      begin
        ItParam := TItParam<Variant>.Create(IT_COMPARISION[A], 'ABC');
        ValueToCompare := TValue.From<Variant>('DEF');
      end;
      tkInt64:
      begin
        ItParam := TItParam<Int64>.Create(IT_COMPARISION[A], 123);
        ValueToCompare := TValue.From<Int64>(456);
      end;
      tkUString:
      begin
        ItParam := TItParam<UnicodeString>.Create(IT_COMPARISION[A], 'ABC');
        ValueToCompare := TValue.From<UnicodeString>('DEF');
      end;
      tkPointer:
      begin
        ItParam := TItParam<Pointer>.Create(IT_COMPARISION[A], Pointer(10));
        ValueToCompare := TValue.From<Pointer>(Pointer(20));
      end;
      tkRecord:
      begin
        ItParam := TItParam<TValue>.Create(IT_COMPARISION[A], 123);
        ValueToCompare := TValue.From<TValue>(456);
      end;
      tkArray,
      tkClassRef,
      tkDynArray,
      tkInterface,
      tkMethod,
      tkMRecord,
      tkProcedure,
      tkUnknown:
      begin
        Assert.IsTrue(True);

        Exit;
      end;
    end;

    Assert.AreEqual(IT_COMPARISION_RESULT_EXPECTED[A], ItParam.Compare(ValueToCompare), Format('Comparision fail "%s"', [IT_COMPARISION_MESSAGE[A]]));
  end;
end;

procedure TItParamTest.WhenCompareArrayAndAllValuesIsEqualMustReturnTrueInTheComparision;
begin
  var ItParam: IIt := TItParam<TArray<Integer>>.Create(icEqualTo, [123, 456]);

  Assert.IsTrue(ItParam.Compare(TValue.From<TArray<Integer>>([123, 456])));
end;

procedure TItParamTest.WhenCompareArrayAndAValueIsNotEqualMustReturnFalseInTheComparision;
begin
  var ItParam: IIt := TItParam<TArray<Integer>>.Create(icEqualTo, [123, 456]);

  Assert.IsFalse(ItParam.Compare(TValue.From<TArray<Integer>>([123, 444])));
end;

procedure TItParamTest.WhenCompareArrayWithDifferentLengthMustReturnFalseWhenComparingValues;
begin
  var ItParam: IIt := TItParam<TArray<Integer>>.Create(icEqualTo, [123, 456]);

  Assert.IsFalse(ItParam.Compare(TValue.From<TArray<Integer>>([123])));
end;

procedure TItParamTest.WhenComparingAnInvalidTypeMustRaiseAnError;
begin
  var ItParam: IIt := TItParam<TGUID>.Create(icEqualTo, TGUID.NewGuid);

  Assert.WillRaise(
    procedure
    begin
      ItParam.Compare(TValue.From(TGUID.NewGuid));
    end, EInvalidTypeToItParam)
end;

procedure TItParamTest.WhenComparingATValueAndTheCurrentValueIsEmptyTheReturnOfTheComparationMustBeFalse;
begin
  var ItParam: IIt := TItParam<TValue>.Create(icEqualTo, TValue.Empty);

  Assert.IsFalse(ItParam.Compare(TValue.From(TValue.From(123))));
end;

procedure TItParamTest.WhenComparingATValueAndTheValueToCompareIsEmptyTheReturnOfTheComparationMustBeFalse;
begin
  var ItParam: IIt := TItParam<TValue>.Create(icEqualTo, 123);

  Assert.IsFalse(ItParam.Compare(TValue.From(TValue.Empty)));
end;

procedure TItParamTest.WhenComparingDifferentTypesOfValuesMustRaiseAnError;
begin
  var ItParam: IIt := TItParam<Integer>.Create(icAny, 0);

  Assert.WillRaise(
    procedure
    begin
      ItParam.Compare('abc');
    end, EDifferentTypeInComparision);
end;

procedure TItParamTest.WhenComparingFieldsAndTheComparedValueIsNilMustReturnFalseInTheComparision;
begin
  var CompareValue := TMyClass.Create;
  var ItParam: IIt := TItParam<TMyClass>.Create(icSameFields, CompareValue);

  Assert.IsFalse(ItParam.Compare(TValue.From<TMyClass>(nil)));

  CompareValue.Free;
end;

procedure TItParamTest.WhenComparingFieldsAndTheCurrentValueIsNilMustReturnFalseInTheComparision;
begin
  var CompareValue := TMyClass.Create;
  var ItParam: IIt := TItParam<TMyClass>.Create(icSameFields, nil);

  Assert.IsFalse(ItParam.Compare(TValue.From<TMyClass>(CompareValue)));

  CompareValue.Free;
end;

procedure TItParamTest.WhenComparingFieldsMustReturnFalseIfOneFieldHasADifferentValue;
begin
  var CurrentValue := TMyClass.Create;
  var ItParam: IIt := TItParam<TMyClass>.Create(icSameFields, CurrentValue);
  var ValueToCompare := TMyClass.Create;

  CurrentValue.MyField := 'abc';
  ValueToCompare.MyField := 'def';

  Assert.IsFalse(ItParam.Compare(TValue.From(ValueToCompare)));

  CurrentValue.Free;

  ValueToCompare.Free;
end;

procedure TItParamTest.WhenComparingFieldsMustReturnTrueIfAllFieldsHasASameValue;
begin
  var CurrentValue := TMyClass.Create;
  var ItParam: IIt := TItParam<TMyClass>.Create(icSameFields, CurrentValue);
  var ValueToCompare := TMyClass.Create;

  CurrentValue.MyField := 'abc';
  ValueToCompare.MyField := 'abc';

  Assert.IsTrue(ItParam.Compare(TValue.From(ValueToCompare)));

  CurrentValue.Free;

  ValueToCompare.Free;
end;

procedure TItParamTest.WhenComparingPropertiesAndTheComparedValueIsNilMustReturnFalseInTheComparision;
begin
  var CompareValue := TMyClass.Create;
  var ItParam: IIt := TItParam<TMyClass>.Create(icSameProperties, CompareValue);

  Assert.IsFalse(ItParam.Compare(TValue.From<TMyClass>(nil)));

  CompareValue.Free;
end;

procedure TItParamTest.WhenComparingPropertiesAndTheCurrentValueIsNilMustReturnFalseInTheComparision;
begin
  var CompareValue := TMyClass.Create;
  var ItParam: IIt := TItParam<TMyClass>.Create(icSameProperties, nil);

  Assert.IsFalse(ItParam.Compare(TValue.From<TMyClass>(CompareValue)));

  CompareValue.Free;
end;

procedure TItParamTest.WhenComparingPropertiesMustReturnFalseIfOnePropertyHasADifferentValue;
begin
  var CurrentValue := TMyClass.Create;
  var ItParam: IIt := TItParam<TMyClass>.Create(icSameProperties, CurrentValue);
  var ValueToCompare := TMyClass.Create;

  CurrentValue.MyProperty := 'abc';
  ValueToCompare.MyProperty := 'def';

  Assert.IsFalse(ItParam.Compare(TValue.From(ValueToCompare)));

  CurrentValue.Free;

  ValueToCompare.Free;
end;

procedure TItParamTest.WhenComparingPropertiesMustReturnTrueIfAllPropertiesHasASameValue;
begin
  var CurrentValue := TMyClass.Create;
  var ItParam: IIt := TItParam<TMyClass>.Create(icSameProperties, CurrentValue);
  var ValueToCompare := TMyClass.Create;

  CurrentValue.MyProperty := 'abc';
  ValueToCompare.MyProperty := 'abc';

  Assert.IsTrue(ItParam.Compare(TValue.From(ValueToCompare)));

  CurrentValue.Free;

  ValueToCompare.Free;
end;

procedure TItParamTest.WhenComparingTValuesAndBothAreEmptyMustReturnTrueInTheComparision;
begin
  var ItParam: IIt := TItParam<TValue>.Create(icEqualTo, TValue.Empty);

  Assert.IsTrue(ItParam.Compare(TValue.From(TValue.Empty)));
end;

procedure TItParamTest.WhenComparingTwoClassesMustRaiseAnErrorIfTheTypesAreDiffent;
begin
  var ItParam: IIt := TItParam<TMyClass>.Create(icEqualTo, nil);

  Assert.WillRaise(
    procedure
    begin
      ItParam.Compare(Self);
    end, EDifferentTypeInComparision);
end;

procedure TItParamTest.WhenComparingTwoRecordsMustRaiseAnErrorIfTheTypesAreDiffent;
begin
  var MyRecord: TMyRecord;

  var ItParam: IIt := TItParam<TMyRecord>.Create(icEqualTo, MyRecord);

  Assert.WillRaise(
    procedure
    begin
      ItParam.Compare(TValue.From(TGUID.NewGuid));
    end, EDifferentTypeInComparision);
end;

procedure TItParamTest.WhenTheValueBeenComparedIsInheritedFromTheCurrentValueCantRaiseErrorOfDiffentType;
begin
  var ItParam: IIt := TItParam<TMyClass>.Create(icEqualTo, nil);

  Assert.WillNotRaise(
    procedure
    begin
      ItParam.Compare(TValue.From<TMyClass2>(nil));
    end, EDifferentTypeInComparision);
end;

{ TItTest }

procedure TItTest.IsAnyAllTests;
begin
  MakeTest<Integer>(icAny, It.IsAny<Integer>, 0);
end;

procedure TItTest.IsEqualToAllTests;
begin
  MakeTest<Integer>(icEqualTo, It.IsEqualTo<Integer>(123), 123);
end;

procedure TItTest.IsNotEqualToAllTests;
begin
  MakeTest<Integer>(icNotEqualTo, It.IsNotEqualTo<Integer>(123), 456);
end;

procedure TItTest.MakeTest<T>(const Comparision: TItComparision; const ReturnFunctionValue, ValueToCompare: T);
begin
  Assert.AreEqual(1, TItParams.Params.Count, 'Don''t call the add param');

  Assert.AreEqual(Comparision, TItParam<T>(TItParams.Params.First).ItComparision, 'Not the same comparision');

  Assert.IsTrue(TItParams.Params.First.Compare(TValue.From(ValueToCompare)), 'The value comparision failed');

  TItParams.ResetParams;
end;

procedure TItTest.SameFieldsToAllTests;
begin
  var CurrentValue := TMyClass.Create;
  var ValueToCompare := TMyClass.Create;

  CurrentValue.MyField := 'abc';
  ValueToCompare.MyField := 'abc';

  MakeTest<TMyClass>(icSameFields, It.SameFields(CurrentValue), ValueToCompare);

  CurrentValue.Free;

  ValueToCompare.Free;
end;

procedure TItTest.SamePropertiesToAllTests;
begin
  var CurrentValue := TMyClass.Create;
  var ValueToCompare := TMyClass.Create;

  CurrentValue.MyProperty := 'abc';
  ValueToCompare.MyProperty := 'abc';

  MakeTest<TMyClass>(icSameProperties, It.SameProperties(CurrentValue), ValueToCompare);

  CurrentValue.Free;

  ValueToCompare.Free;
end;

procedure TItTest.SetupFixture;
begin
  TRttiContext.Create.GetType(TMyClass).GetFields;
end;

procedure TItTest.WhenUseTheParamIndexInTheItCallMustLoadTheParamIndexWithThatValue;
begin
  It(10);

  Assert.AreEqual(10, TItParams.ParamIndex);

  TItParams.ParamIndex := -1;
end;

{ TItReferenceTest }

procedure TItReferenceTest.IsAnyAllTests;
begin
  MakeTest<Integer>(icAny, ItReference<Integer>.IsAny, 0);
end;

procedure TItReferenceTest.IsEqualToAllTests;
begin
  MakeTest<Integer>(icEqualTo, ItReference<Integer>.IsEqualTo(123), 123);
end;

procedure TItReferenceTest.IsNotEqualToAllTests;
begin
  MakeTest<Integer>(icNotEqualTo, ItReference<Integer>.IsNotEqualTo(123), 456);
end;

procedure TItReferenceTest.SameFieldsToAllTests;
begin
  var CurrentValue := TMyClass.Create;
  var ValueToCompare := TMyClass.Create;

  CurrentValue.MyField := 'abc';
  ValueToCompare.MyField := 'abc';

  MakeTest<TMyClass>(icSameFields, ItReference<TMyClass>.SameFields(CurrentValue), ValueToCompare);

  CurrentValue.Free;

  ValueToCompare.Free;
end;

procedure TItReferenceTest.SamePropertiesToAllTests;
begin
  var CurrentValue := TMyClass.Create;
  var ValueToCompare := TMyClass.Create;

  CurrentValue.MyProperty := 'abc';
  ValueToCompare.MyProperty := 'abc';

  MakeTest<TMyClass>(icSameProperties, ItReference<TMyClass>.SameProperties(CurrentValue), ValueToCompare);

  CurrentValue.Free;

  ValueToCompare.Free;
end;

procedure TItReferenceTest.SetupFixture;
begin
  TRttiContext.Create.GetType(TMyClass).GetFields;
end;

procedure TItReferenceTest.WhenUseTheParamIndexInTheItCallMustLoadTheParamIndexWithThatValue;
begin
  ItReference<Integer>(10);

  Assert.AreEqual(10, TItParams.ParamIndex);

  TItParams.ParamIndex := -1;
end;

procedure TItReferenceTest.MakeTest<T>(const Comparision: TItComparision; const ItParam: TItParam<T>; const ValueToCompare: T);
begin
  Assert.IsNotNull(ItParam, 'Must create the object');

  Assert.AreEqual(1, TItParams.Params.Count, 'Don''t call the add param');

  Assert.AreEqual(Comparision, ItParam.ItComparision, 'Not the same comparision');

  Assert.IsTrue((ItParam as IIt).Compare(TValue.From<T>(ValueToCompare)), 'The value comparision failed');

  TItParams.ResetParams;
end;

end.

