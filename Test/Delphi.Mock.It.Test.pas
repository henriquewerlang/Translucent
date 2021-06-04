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

end.

