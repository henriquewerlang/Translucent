﻿unit Translucent.Intf.Test;

interface

uses DUnitX.TestFramework;

type
  [TestFixture]
  IMockTest = class
  public
    [SetupFixture]
    procedure SetupFixture;
    [Test]
    procedure WhenCreateAMockClassMustReturnAInstanceOfInterface;
    [Test]
    procedure WhenRegisterAWillExecuteMustCallTheProcedureRegistred;
    [Test]
    procedure WhenRegisterAWillReturnMustReturnTheValueRegistred;
    [Test]
    procedure WhenRegisterExpectationsAndNoOneIsCalledMustReturnAMessage;
    [Test]
    procedure WhenMoreThenOneExpectationFailMustReturnMessageOfAllExpectations;
    [Test]
    procedure WhenRegisterACustomExpectationMustCallThisExpectation;
    [Test]
    procedure WhenRegisterTheNeverCallExpectationAnCallTheProcedureMustReturnAExpectation;
    [Test]
    procedure WhenRegisterTheNeverCallExpectationAndTheExpectationIsValidMustReturnAEmptyValue;
    [Test]
    procedure WhenRegisterTheExecutionCallExpectationMustReturnTheExpectation;
    [Test]
    procedure WhenRegisterAWillExecuteMustCallTheProcedureRegistredWithParams;
    [Test]
    procedure WhenRegisterAWillExecuteMustCallTheFunctionRegistredWithParams;
  end;

{$M+}
  IMyInterface = interface
    ['{A2194515-8E18-4EAC-A434-3944B6781D3A}']
    function MyFunction: Integer;

    procedure Execute;
  end;

implementation

uses System.SysUtils, System.Rtti, Translucent, Translucent.Intf;

{ IMockTest }

procedure IMockTest.SetupFixture;
begin
  // Avoid memory leak register in tests.
  TMock.CreateInterface<IMyInterface>;
end;

procedure IMockTest.WhenCreateAMockClassMustReturnAInstanceOfInterface;
begin
  var Mock := TMock.CreateInterface<IMyInterface>;

  Assert.IsNotNull(Mock.Instance);
end;

procedure IMockTest.WhenMoreThenOneExpectationFailMustReturnMessageOfAllExpectations;
begin
  var Mock := TMock.CreateInterface<IMyInterface>;

  Mock.Expect.Once.When.Execute;

  Mock.Expect.Once.When.MyFunction;

  Assert.AreEqual('Expected to call the method "Execute" once but never called'#13#10'Expected to call the method "MyFunction" once but never called', Mock.CheckExpectations);
end;

procedure IMockTest.WhenRegisterACustomExpectationMustCallThisExpectation;
begin
  var Executed := False;
  var Mock := TMock.CreateInterface<IMyInterface>;

  Mock.Expect.CustomExpect(
    function (Params: TArray<TValue>): String
    begin
      Executed := True;
    end).When.Execute;

  Mock.Instance.Execute;

  Assert.IsTrue(Executed);
end;

procedure IMockTest.WhenRegisterAWillExecuteMustCallTheFunctionRegistredWithParams;
begin
  var Executed := False;
  var Mock := TMock.CreateInterface<IMyInterface>;

  Mock.Setup.WillExecute(
    function(const Params: TArray<TValue>): TValue
    begin
      Executed := True;
    end).When.Execute;

  Mock.Instance.Execute;

  Assert.IsTrue(Executed);
end;

procedure IMockTest.WhenRegisterAWillExecuteMustCallTheProcedureRegistred;
begin
  var Executed := False;
  var Mock := TMock.CreateInterface<IMyInterface>;

  Mock.Setup.WillExecute(
    procedure
    begin
      Executed := True;
    end).When.Execute;

  Mock.Instance.Execute;

  Assert.IsTrue(Executed);
end;

procedure IMockTest.WhenRegisterAWillExecuteMustCallTheProcedureRegistredWithParams;
begin
  var Executed := False;
  var Mock := TMock.CreateInterface<IMyInterface>;

  Mock.Setup.WillExecute(
    procedure(const Params: TArray<TValue>)
    begin
      Executed := True;
    end).When.Execute;

  Mock.Instance.Execute;

  Assert.IsTrue(Executed);
end;

procedure IMockTest.WhenRegisterAWillReturnMustReturnTheValueRegistred;
begin
  var Mock := TMock.CreateInterface<IMyInterface>;

  Mock.Setup.WillReturn(123456).When.MyFunction;

  Assert.AreEqual(123456, Mock.Instance.MyFunction);
end;

procedure IMockTest.WhenRegisterExpectationsAndNoOneIsCalledMustReturnAMessage;
begin
  var Mock := TMock.CreateInterface<IMyInterface>;

  Mock.Expect.Once.When.Execute;

  Assert.AreEqual('Expected to call the method "Execute" once but never called', Mock.CheckExpectations);
end;

procedure IMockTest.WhenRegisterTheExecutionCallExpectationMustReturnTheExpectation;
begin
  var Mock := TMock.CreateInterface<IMyInterface>;

  Mock.Expect.ExecutionCount(5).When.Execute;

  Mock.Instance.Execute;

  Assert.AreEqual('Expected to call the method "Execute" 5 times, but was called 1 times', Mock.CheckExpectations);
end;

procedure IMockTest.WhenRegisterTheNeverCallExpectationAnCallTheProcedureMustReturnAExpectation;
begin
  var Mock := TMock.CreateInterface<IMyInterface>;

  Mock.Expect.Never.When.Execute;

  Mock.Instance.Execute;

  Assert.AreEqual('Expected to never be called the procedure "Execute", but was called 1 times', Mock.CheckExpectations);
end;

procedure IMockTest.WhenRegisterTheNeverCallExpectationAndTheExpectationIsValidMustReturnAEmptyValue;
begin
  var Mock := TMock.CreateInterface<IMyInterface>;

  Mock.Expect.Never.When.Execute;

  Assert.AreEqual(EmptyStr, Mock.CheckExpectations);
end;

end.

