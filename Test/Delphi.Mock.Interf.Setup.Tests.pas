unit Delphi.Mock.Interf.Setup.Tests;

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
    [Test]
    procedure WhenWillExecuteIsCalledHaveToRegisterTheInterfaceOfExecution;
    [Test]
    procedure WhenTheProcedureHaveParametersHaveToUseDeItOperator;
    [Test]
    procedure WhenRegisterAProcedureHaveDoCleanHaveToCleanTheItList;
    [Test]
    procedure TheLengthOfParamsMustBeTheSameLengthOfItParams;
    [Test]
    procedure MustFillItParamsAfterSetupTheProcedure;
  end;

{$M+}
  ITestInterface = interface
    ['{FFB9C4BB-880F-40F4-8255-14DC4FB8F975}']
    procedure ProcedureWithParam(Param1: Integer; Param2: String);
    procedure ProcedureWithParam2(Param1: Integer; Param2: String);
    procedure Test;
  end;

implementation

uses System.Rtti, System.SysUtils, Delphi.Mock, Delphi.Mock.Interf, Delphi.Mock.Interf.Setup, Delphi.Mock.Method.Types;

{ TMockSetupInterfaceTest }

procedure TMockSetupInterfaceTest.HeveToReturnTheInterfaceWhenTheWhenIsCalled;
begin
  var Setup := TMockSetupInterface<ITestInterface>.Create(nil, nil) as IMockSetup<ITestInterface>;

  Assert.IsNotNull(Setup.When, 'Have to return the interface!');
end;

procedure TMockSetupInterfaceTest.MustFillItParamsAfterSetupTheProcedure;
begin
  var Mock := TMockInterface<ITestInterface>.Create;

  Mock.WillExecute(nil).When.ProcedureWithParam(It.IsAny<Integer>, It.IsAny<String>);

  Assert.AreEqual<Integer>(2, Length(Mock.RegistredMethods.Values.ToArray[0][0].ItParams));
end;

procedure TMockSetupInterfaceTest.TheLengthOfParamsMustBeTheSameLengthOfItParams;
begin
  Assert.WillRaise(
    procedure
    begin
      var Mock := TMock.CreateInterface<ITestInterface>;

      Mock.WillExecute(nil).When.ProcedureWithParam(It.IsAny<Integer>, EmptyStr);
    end, EParamsLengthDiffer);
end;

procedure TMockSetupInterfaceTest.WhenRegisterAProcedureHaveDoCleanHaveToCleanTheItList;
begin
  Assert.WillRaise(
    procedure
    begin
      var Mock := TMock.CreateInterface<ITestInterface>;

      Mock.WillExecute(nil).When.ProcedureWithParam(It.IsAny<Integer>, It.IsAny<String>);

      Mock.WillExecute(nil).When.ProcedureWithParam2(0, EmptyStr);
    end, ENoParamsDefined);
end;

procedure TMockSetupInterfaceTest.WhenRegisterAProcedureHaveToAddItToTheList;
begin
  var Mock := TMockInterface<ITestInterface>.Create;
  var Setup := TMockSetupInterface<ITestInterface>.Create(Mock, TMethodInfoWillExecute.Create(nil));

  Setup.When.Test;

  Assert.AreEqual(1, Mock.RegistredMethods.Count);
end;

procedure TMockSetupInterfaceTest.WhenTheProcedureHaveParametersHaveToUseDeItOperator;
begin
  Assert.WillRaise(
    procedure
    begin
      var Mock := TMock.CreateInterface<ITestInterface>;

      Mock.WillExecute(nil).When.ProcedureWithParam(0, EmptyStr);
    end, ENoParamsDefined);
end;

procedure TMockSetupInterfaceTest.WhenWillExecuteIsCalledHaveToRegisterTheInterfaceOfExecution;
begin
  var Mock := TMockInterface<ITestInterface>.Create;

  Mock.WillExecute(nil).When.Test;

  Assert.AreEqual(1, Mock.RegistredMethods.Count);

  Assert.IsNotNull(Mock.RegistredMethods.Values.ToArray[0]);
end;

initialization
  TDUnitX.RegisterTestFixture(TMockSetupInterfaceTest);

end.

