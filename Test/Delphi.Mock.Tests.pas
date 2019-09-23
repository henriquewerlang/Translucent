unit Delphi.Mock.Tests;

interface

uses DUnitX.TestFramework;

type
  [TestFixture]
  TMockInterfaceTest = class
  public
    [Test]
    procedure WhenRegisterAProcedureHaveToCallTheProcedureRegistred;
  end;

  ITestInterface = interface
    procedure TestProcedute;
  end;

implementation

uses Delphi.Mock;

{ TMockInterfaceTest }

procedure TMockInterfaceTest.WhenRegisterAProcedureHaveToCallTheProcedureRegistred;
begin
  var Executed := False;
  var Mock := TMock.Create<ITestInterface>;

  Mock.WillExecute(
    procedure
    begin
      Executed := True;
    end).When.TestProcedute;

  Assert.IsTrue(Executed, 'The procedure wasn''t called!');
end;

initialization
  TDUnitX.RegisterTestFixture(TMockInterfaceTest);

end.
