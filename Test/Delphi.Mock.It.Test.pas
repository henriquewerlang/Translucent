unit Delphi.Mock.It.Test;

interface

uses DUnitX.TestFramework;

type
  [TestFixture]
  TItTest = class
  public
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
  end;

implementation

uses System.SysUtils, Delphi.Mock, Delphi.Mock.Method;

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

procedure TItTest.TearDown;
begin
  GItParams := nil;
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
