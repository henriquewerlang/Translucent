unit Delphi.Mock.Intf.Test;

interface

uses DUnitX.TestFramework;

type
  [TestFixture]
  IMockTest = class
  public
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
  end;

{$M+}
  IMyInterface = interface
    ['{A2194515-8E18-4EAC-A434-3944B6781D3A}']
    function MyFunction: Integer;

    procedure Execute;
  end;

implementation

uses System.SysUtils, System.Rtti, Delphi.Mock, Delphi.Mock.Intf;

{ IMockTest }

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

  Assert.AreEqual('Expected to call once the method but never called'#13#10'Expected to call once the method but never called', Mock.CheckExpectations);
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

  Assert.AreEqual('Expected to call once the method but never called', Mock.CheckExpectations);
end;

initialization
  TDUnitX.RegisterTestFixture(IMockTest);

end.
