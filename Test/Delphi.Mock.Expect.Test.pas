unit Delphi.Mock.Expect.Test;

interface

uses DUnitX.TestFramework;

type
  [TestFixture]
  TMockExpectTest = class
  public
    [Test]
    procedure WhenExecuteAExpectationMustIncreaseTheCounterOfMethod;
  end;

  ITestExpectation = interface
    ['{48BCC9B1-D284-4FEC-831A-D6B0495AC51F}']
    procedure ExpectMethod;
  end;

implementation

{ TMockExpectTest }

uses Delphi.Mock;

procedure TMockExpectTest.WhenExecuteAExpectationMustIncreaseTheCounterOfMethod;
begin
  var Mock := TMock.Create<ITestExpectation>;

  Mock.Expect.Once.When.ExpectMethod;

  Mock.Instance.ExpectMethod;

  Mock.Instance.ExpectMethod;

  Assert.AreEqual(2, 0, 'Have to continue from here, and I don''t know how...');
end;

initialization
  TDUnitX.RegisterTestFixture(TMockExpectTest);

end.
