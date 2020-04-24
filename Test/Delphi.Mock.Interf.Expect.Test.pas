unit Delphi.Mock.Interf.Expect.Test;

interface

uses DUnitX.TestFramework;

type
  [TestFixture]
  TMockExpectTest = class
  public
    [Test]
    procedure WhenToCallExpectationsAndHasNotBeenInitializedHaveToRaiseAnError;
    [Test]
    procedure WhenTheExpectationsAreSetAndNoneAreCalledHaveToReturnATextWithTheExpectations;
  end;

  [TestFixture]
  TMethodInfoExpectOnceTest = class
  public
    [Test]
    procedure WhenNeverCallTheFunctionHasToReturnTheTextOfNeverHavingCalled;
    [Test]
    procedure WhenCallingMoreThanOnceTheMethodHasToShowTheMessageWithTheAmount;
    [Test]
    procedure WhenCallingOnlyOnceCanNotReturnValue;
  end;

{$M+}
  ITestExpectation = interface
    ['{48BCC9B1-D284-4FEC-831A-D6B0495AC51F}']
    procedure ExpectMethod;
  end;

implementation

uses System.Rtti, Delphi.Mock, Delphi.Mock.Method.Types;

{ TMockExpectTest }

procedure TMockExpectTest.WhenTheExpectationsAreSetAndNoneAreCalledHaveToReturnATextWithTheExpectations;
begin
  var Mock := TMock.CreateInterface<ITestExpectation>;

  Mock.Expect.Once.When.ExpectMethod;

  Assert.IsNotEmpty(Mock.CheckExpectations);
end;

procedure TMockExpectTest.WhenToCallExpectationsAndHasNotBeenInitializedHaveToRaiseAnError;
begin
  Assert.WillRaise(
    procedure
    begin
      var Mock := TMock.CreateInterface<ITestExpectation>;

      Mock.CheckExpectations;
    end, EExpectationsNotConfigured);
end;

{ TMethodInfoExpectOnceTest }

procedure TMethodInfoExpectOnceTest.WhenCallingMoreThanOnceTheMethodHasToShowTheMessageWithTheAmount;
begin
  var Method := TMethodInfoExpectOnce.Create;
  var Value: TValue;

  Method.Execute(Value);

  Method.Execute(Value);

  Method.Execute(Value);

  Method.Execute(Value);

  Method.Execute(Value);

  Assert.AreEqual('Expected to call once the method but was called 5 times', Method.CheckExpectation);

  Method.Free;
end;

procedure TMethodInfoExpectOnceTest.WhenCallingOnlyOnceCanNotReturnValue;
begin
  var Method := TMethodInfoExpectOnce.Create;
  var Value: TValue;

  Method.Execute(Value);

  Assert.IsEmpty(Method.CheckExpectation);

  Method.Free;
end;

procedure TMethodInfoExpectOnceTest.WhenNeverCallTheFunctionHasToReturnTheTextOfNeverHavingCalled;
begin
  var Method := TMethodInfoExpectOnce.Create;

  Assert.AreEqual('Expected to call once the method but never called', Method.CheckExpectation);

  Method.Free;
end;

initialization
  TDUnitX.RegisterTestFixture(TMockExpectTest);

end.

