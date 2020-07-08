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
  end;

{$M+}
  IMyInterface = interface
    ['{A2194515-8E18-4EAC-A434-3944B6781D3A}']
    function MyFunction: Integer;

    procedure Execute;
  end;

implementation

uses Delphi.Mock, Delphi.Mock.Intf;

{ IMockTest }

procedure IMockTest.WhenCreateAMockClassMustReturnAInstanceOfInterface;
begin
  var Mock := TMock.CreateInterface<IMyInterface>;

  Assert.IsNotNull(Mock.Setup.Instance);
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

  Mock.Setup.Instance.Execute;

  Assert.IsTrue(Executed);
end;

procedure IMockTest.WhenRegisterAWillReturnMustReturnTheValueRegistred;
begin
  var Mock := TMock.CreateInterface<IMyInterface>;

  Mock.Setup.WillReturn(123456).When.MyFunction;

  Assert.AreEqual(123456, Mock.Setup.Instance.MyFunction);
end;

initialization
  TDUnitX.RegisterTestFixture(IMockTest);

end.
