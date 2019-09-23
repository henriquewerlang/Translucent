unit Delphi.Mock.Setup.Tests;

interface

uses DUnitX.TestFramework;

type
  [TestFixture]
  TMockSetupInterfaceTest = class
  public
    [Test]
    procedure HeveToReturnTheInterfaceWhenTheWhenIsCalled;
    [Test]
    procedure WhenRegisterAProcedureHaveToAddItToTheList;
  end;

{$M+}
  ITestInterface = interface
    ['{FFB9C4BB-880F-40F4-8255-14DC4FB8F975}']
    procedure Test;
  end;

implementation

uses Delphi.Mock, Delphi.Mock.Setup;

{ TMockSetupInterfaceTest }

procedure TMockSetupInterfaceTest.HeveToReturnTheInterfaceWhenTheWhenIsCalled;
begin
  var Setup := TMockSetupInterface<ITestInterface>.Create(nil, nil) as IMockSetup<ITestInterface>;

  Assert.IsNotNull(Setup.When, 'Have to return the interface!');
end;

procedure TMockSetupInterfaceTest.WhenRegisterAProcedureHaveToAddItToTheList;
begin
  var Mock := TMockInterface<ITestInterface>.Create;
  var Setup := TMockSetupInterface<ITestInterface>.Create(Mock, nil);

  (Setup as IMockSetup<ITestInterface>).When.Test;

  Assert.AreEqual(1, Mock.RegistredMethods.Count);
end;

initialization
  TDUnitX.RegisterTestFixture(TMockSetupInterfaceTest);

end.
