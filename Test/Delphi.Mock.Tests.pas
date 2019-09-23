unit Delphi.Mock.Tests;

interface

uses DUnitX.TestFramework;

type
  [TestFixture]
  TMockInterfaceTest = class
  public
    [Test]
    procedure WhenCallWillExecuteProcedureHaveToReturnASetupInterface;
  end;

{$M+}
  ITestInterface = interface
    ['{AE7C4FC6-1583-4BE4-B00F-E905CA981377}']
    procedure TestProcedute;
  end;

implementation

uses Delphi.Mock;

{ TMockInterfaceTest }

procedure TMockInterfaceTest.WhenCallWillExecuteProcedureHaveToReturnASetupInterface;
begin
  var Mock := TMock.Create<ITestInterface>;
  var Setup := Mock.WillExecute(nil);

  Assert.IsNotNull(Setup);
end;

initialization
  TDUnitX.RegisterTestFixture(TMockInterfaceTest);

end.
