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

{$M+}
  ITestInterface = interface
    ['{AE7C4FC6-1583-4BE4-B00F-E905CA981377}']
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
