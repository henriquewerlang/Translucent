unit Delphi.Mock.It.Test;

interface

uses DUnitX.TestFramework;

type
  [TestFixture]
  TItTest = class
  public
    [SetupFixture]
    procedure SetupFixture;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure WhenIsAnyIsCreateAlwaysReturnTrue;
    [TestCase('EqualValue', '123,True')]
    [TestCase('DiferentValue', '456,False')]
    procedure ComparingEqualValueOnlyReturnTrueWhenIsEqual(Value: Integer; Comparision: Boolean);
    [TestCase('EqualValue', '123,False')]
    [TestCase('DiferentValue', '456,True')]
    procedure ComparingNotEqualValueOnlyReturnTrueWhenIsNotEqual(Value: Integer; Comparision: Boolean);
    [Test]
    procedure WhenPassTheParamIndexMustFillTheItParamsWithTheSizeExpected;
    [Test]
    procedure WhenPassTheParamIndexMustKeepTheLenghtOfGlobalVarWithTheBiggestValueIndex;
    [Test]
    procedure WhenConfigureTheItParamToCompareTheSameFieldsMustReturnTrueIfTheValuesOfTheFieldsAreTheSame;
    [Test]
    procedure WhenConfigureTheIfParamToCompareTheSamePropertiesMustReturnTrueIfTheValueOfThePropertiesAreTheSame;
    [Test]
    procedure WhenTheTypeOfItValuesAreDifferentTheComparisionMustReturnFalse;
    [TestCase('Integer-Int64', 'tkInteger,tkInt64')]
    [TestCase('Int64-Integer', 'tkInt64,tkInteger')]
    [TestCase('Char-String', 'tkChar,tkString')]
    [TestCase('String-Char', 'tkString,tkChar')]
    [TestCase('WChar-String', 'tkWChar,tkString')]
    [TestCase('String-WChar', 'tkString,tkWChar')]
    procedure WhenTheTypesAreEquivalentMustCompareTheValuesAsExpected(LeftValueKind, RightValueKind: TTypeKind);
    [TestCase('Enum', 'tkEnumeration')]
    [TestCase('Float', 'tkFloat')]
    [TestCase('Integer', 'tkInteger')]
    [TestCase('String', 'tkString')]
    [TestCase('Variant', 'tkVariant')]
    [TestCase('Value', 'tkRecord')]
    [TestCase('Class', 'tkClass')]
    procedure WhenComparingValueMustReturnTrueIfTheValuesIsEqual(ValueKind: TTypeKind);
    [Test]
    procedure WhenTryToCompareARecordDiferentOfTValueMustRaiseAnError;
    [Test]
    procedure WhenCantCompareValuesMustReturnFalseInTheComparision;
    [Test]
    procedure WhenComparinTValuesMustReturnTrueInTheComparisionIfBothIsEmpty;
    [Test]
    procedure WhenComparingArraysAndTheSizeOfBothIsDifferentMustReturnFalseInTheComparision;
    [Test]
    procedure WhenTheArraysHasTheSameLengthMustComparaEveryValueInTheArray;
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

  TMyEnumerator = (Enum1, Enum2, Enum3);

implementation

uses System.SysUtils, System.Rtti, Delphi.Mock, Delphi.Mock.Method;

{ TItTest }

procedure TItTest.ComparingEqualValueOnlyReturnTrueWhenIsEqual(Value: Integer; Comparision: Boolean);
begin
  var ValueIt := It;

  ValueIt.IsEqualTo(123);

  Assert.AreEqual(Comparision, (ValueIt as IIt).Compare(Value));
end;

procedure TItTest.ComparingNotEqualValueOnlyReturnTrueWhenIsNotEqual(Value: Integer; Comparision: Boolean);
begin
  var ValueIt := It;

  ValueIt.IsNotEqualTo(123);

  Assert.AreEqual(Comparision, (ValueIt as IIt).Compare(Value));
end;

procedure TItTest.SetupFixture;
begin
  TRttiContext.Create.GetType(TMyClass).GetFields;
end;

procedure TItTest.TearDown;
begin
  GItParams := nil;
end;

procedure TItTest.WhenCantCompareValuesMustReturnFalseInTheComparision;
begin
  var ItValue := It;

  ItValue.IsEqualTo<TClass>(nil);

  Assert.IsFalse((ItValue as IIt).Compare(TValue.From<TClass>(nil)));
end;

procedure TItTest.WhenComparingArraysAndTheSizeOfBothIsDifferentMustReturnFalseInTheComparision;
begin
  var ItValue := It;

  ItValue.IsEqualTo<TArray<Integer>>([1, 2, 3]);

  Assert.IsFalse((ItValue as IIt).Compare(TValue.From<TArray<Integer>>([1, 2])));
end;

procedure TItTest.WhenComparingValueMustReturnTrueIfTheValuesIsEqual(ValueKind: TTypeKind);
begin
  var AnObject: TObject := nil;
  var ItValue := It;
  var Value: TValue;

  case ValueKind of
    tkEnumeration:
    begin
      Value := TValue.From(Enum2);

      ItValue.IsEqualTo(Enum2);
    end;
    tkInteger:
    begin
      Value := 123;

      ItValue.IsEqualTo(123);
    end;
    tkFloat:
    begin
      Value := 123.456;

      ItValue.IsEqualTo(123.456);
    end;
    tkString:
    begin
      Value := 'abc';

      ItValue.IsEqualTo('abc');
    end;
    tkVariant:
    begin
      Value := TValue.From(Variant(123456));

      ItValue.IsEqualTo(Variant(123456));
    end;
    tkRecord:
    begin
      Value := TValue.From(TValue.From(123456789));

      ItValue.IsEqualTo(TValue.From(123456789));
    end;
    tkClass:
    begin
      AnObject := TObject.Create;
      Value := TValue.From(AnObject);

      ItValue.IsEqualTo(AnObject);
    end;
  end;

  Assert.IsTrue((ItValue as IIt).Compare(Value));

  AnObject.Free;
end;

procedure TItTest.WhenComparinTValuesMustReturnTrueInTheComparisionIfBothIsEmpty;
begin
  var ItValue := It;

  ItValue.IsEqualTo(TValue.Empty);

  Assert.IsTrue((ItValue as IIt).Compare(TValue.From(TValue.Empty)));
end;

procedure TItTest.WhenConfigureTheIfParamToCompareTheSamePropertiesMustReturnTrueIfTheValueOfThePropertiesAreTheSame;
begin
  var MyClass := TMyClass.Create;
  MyClass.MyProperty := 'abc';
  MyClass.MyProperty2 := 1234;
  var ValueIt := It;

  ValueIt.SameProperties(MyClass);

  Assert.IsTrue((ValueIt as IIt).Compare(MyClass));

  MyClass.Free;
end;

procedure TItTest.WhenConfigureTheItParamToCompareTheSameFieldsMustReturnTrueIfTheValuesOfTheFieldsAreTheSame;
begin
  var MyClass := TMyClass.Create;
  MyClass.MyField := 'abc';
  MyClass.MyField2 := 1234;
  var ValueIt := It;

  ValueIt.SameFields(MyClass);

  Assert.IsTrue((ValueIt as IIt).Compare(MyClass));

  MyClass.Free;
end;

procedure TItTest.WhenIsAnyIsCreateAlwaysReturnTrue;
begin
  var ValueIt := It;

  ValueIt.IsAny<String>;

  Assert.IsTrue((ValueIt as IIt).Compare(EmptyStr));
end;

procedure TItTest.WhenPassTheParamIndexMustFillTheItParamsWithTheSizeExpected;
begin
  It(4).IsAny<String>;

  Assert.AreEqual(5, Length(GItParams));
end;

procedure TItTest.WhenPassTheParamIndexMustKeepTheLenghtOfGlobalVarWithTheBiggestValueIndex;
begin
  It(4).IsAny<String>;

  It(1).IsAny<String>;

  Assert.AreEqual(5, Length(GItParams));
end;

procedure TItTest.WhenTheArraysHasTheSameLengthMustComparaEveryValueInTheArray;
begin
  var ItValue := It;

  ItValue.IsEqualTo<TArray<Integer>>([1, 2, 3]);

  Assert.IsTrue((ItValue as IIt).Compare(TValue.From<TArray<Integer>>([1, 2, 3])));
end;

procedure TItTest.WhenTheTypeOfItValuesAreDifferentTheComparisionMustReturnFalse;
begin
  var ValueIt := It;

  ValueIt.IsEqualTo(1234);

  Assert.IsFalse((ValueIt as IIt).Compare('abcde'));
end;

procedure TItTest.WhenTheTypesAreEquivalentMustCompareTheValuesAsExpected(LeftValueKind, RightValueKind: TTypeKind);
begin
  var LeftValue := It;
  var RightValue: TValue;

  case LeftValueKind of
    tkChar: LeftValue.IsEqualTo(AnsiChar('A'));
    tkInt64: LeftValue.IsEqualTo(Int64(1));
    tkInteger: LeftValue.IsEqualTo(1);
    tkString, tkUString: LeftValue.IsEqualTo(String('A'));
    tkWChar: LeftValue.IsEqualTo('A');
  end;

  case RightValueKind of
    tkChar: RightValue := TValue.From(AnsiChar('A'));
    tkInt64: RightValue := Int64(1);
    tkInteger: RightValue := 1;
    tkString, tkUString: RightValue := String('A');
    tkWChar: RightValue := TValue.From('A');
  end;

  Assert.IsTrue((LeftValue as IIt).Compare(RightValue));
end;

procedure TItTest.WhenTryToCompareARecordDiferentOfTValueMustRaiseAnError;
begin
  Assert.WillRaise(
    procedure
    begin
      var ItValue := It;

      ItValue.IsEqualTo(TGUID.NewGuid);

      (ItValue as IIt).Compare(TValue.From(TGUID.NewGuid));
    end, EInvalidTypeForComparision);
end;

end.

