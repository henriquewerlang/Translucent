unit Delphi.Mock.Tests;

interface

uses DUnitX.TestFramework;

type
  [TestFixture]
  TMockInterfaceTest = class
  public
    [Test]
    procedure WhenCallWillExecuteProcedureHaveToReturnASetupInterface;
    [Test]
    procedure TheProcedureRegistredHaveToBeCalled;
    [Test]
    procedure WhenRegisterSameProcedureCantRaiseAnError;
    [Test]
    procedure MoreThenOneRegisteredProcedureMustBeInTheListOfRegistredProcedures;
    [Test]
    procedure WillExecuteTheProcedureFindingByParam;
    [Test]
    procedure ToFindAMethodHaveToTestAllParamsOfProcedure;
    [Test]
    procedure WhenRegisterAFunctionMustReturnTheValueRegistred;
    [Test]
    procedure WhenTheMethodHaveNoRegisterMustRaiseAError;
  end;

  [TestFixture]
  TItTest = class
  public
    [Test]
    procedure WhenIsAnyIsCreateAlwaysReturnTrue;
    [TestCase('EqualValue', '123,True')]
    [TestCase('DiferentValue', '456,False')]
    procedure ComparingEqualValueOnlyReturnTrueWhenIsEqual(Value: Integer; Comparision: Boolean);
    [TestCase('EqualValue', '123,False')]
    [TestCase('DiferentValue', '456,True')]
    procedure ComparingNotEqualValueOnlyReturnTrueWhenIsNotEqual(Value: Integer; Comparision: Boolean);
  end;

{$M+}
  ITestInterface = interface
    ['{AE7C4FC6-1583-4BE4-B00F-E905CA981377}']
    function FunctionTest: Integer;

    procedure ProcedureWithParam(Value: Integer);
    procedure ProcedureWithParam2(Value, Value2: Integer);
    procedure TestProcedute;
  end;

implementation

uses System.SysUtils, Delphi.Mock;

{ TMockInterfaceTest }

procedure TMockInterfaceTest.MoreThenOneRegisteredProcedureMustBeInTheListOfRegistredProcedures;
begin
  var Mock := TMockInterface<ITestInterface>.Create;

  Mock.WillExecute(nil).When.TestProcedute;

  Mock.WillExecute(nil).When.TestProcedute;

  Mock.WillExecute(nil).When.TestProcedute;

  Assert.AreEqual<Integer>(3, Length(Mock.RegistredMethods.Values.ToArray[0]));
end;

procedure TMockInterfaceTest.TheProcedureRegistredHaveToBeCalled;
begin
  var Executed := False;
  var Mock := TMock.Create<ITestInterface>;
  var Instance := Mock as ITestInterface;

  Mock.WillExecute(
    procedure
    begin
      Executed := True;
    end).When.TestProcedute;

  Instance.TestProcedute;

  Assert.IsTrue(Executed, 'Have to execute the procedure registred');
end;

procedure TMockInterfaceTest.ToFindAMethodHaveToTestAllParamsOfProcedure;
begin
  var EmptyProc: TProc :=
    procedure
    begin
    end;
  var Executed := False;
  var Mock := TMockInterface<ITestInterface>.Create;
  var Proc: TProc :=
    procedure
    begin
      Executed := True;
    end;

  Mock.WillExecute(EmptyProc).When.ProcedureWithParam2(It.IsEqualTo(3), It.IsEqualTo(1));

  Mock.WillExecute(Proc).When.ProcedureWithParam2(It.IsEqualTo(3), It.IsEqualTo(2));

  Mock.WillExecute(EmptyProc).When.ProcedureWithParam2(It.IsEqualTo(3), It.IsEqualTo(3));

  Mock.Instance.ProcedureWithParam2(3, 2);

  Assert.IsTrue(Executed, 'Don''t execute the right procedure!');
end;

procedure TMockInterfaceTest.WhenCallWillExecuteProcedureHaveToReturnASetupInterface;
begin
  var Mock := TMock.Create<ITestInterface>;
  var Setup := Mock.WillExecute(nil);

  Assert.IsNotNull(Setup);
end;

procedure TMockInterfaceTest.WhenRegisterAFunctionMustReturnTheValueRegistred;
begin
  var Mock := TMockInterface<ITestInterface>.Create;

  Mock.WillReturn(123).When.FunctionTest;

  Assert.AreEqual(123, Mock.Instance.FunctionTest);
end;

procedure TMockInterfaceTest.WhenRegisterSameProcedureCantRaiseAnError;
begin
  var Mock := TMock.Create<ITestInterface>;

  Mock.WillExecute(nil).When.TestProcedute;

  Assert.WillNotRaise(
    procedure
    begin
      Mock.WillExecute(nil).When.TestProcedute;
    end);
end;

procedure TMockInterfaceTest.WhenTheMethodHaveNoRegisterMustRaiseAError;
begin
  var Mock := TMockInterface<ITestInterface>.Create;

  Assert.WillRaise(
    procedure
    begin
      Mock.Instance.TestProcedute;
    end, EMethodNotRegistred);
end;

procedure TMockInterfaceTest.WillExecuteTheProcedureFindingByParam;
begin
  var EmptyProc: TProc :=
    procedure
    begin
    end;
  var Executed := False;
  var Mock := TMockInterface<ITestInterface>.Create;
  var Proc: TProc :=
    procedure
    begin
      Executed := True;
    end;

  Mock.WillExecute(EmptyProc).When.ProcedureWithParam(It.IsEqualTo(1));

  Mock.WillExecute(EmptyProc).When.ProcedureWithParam(It.IsEqualTo(2));

  Mock.WillExecute(Proc).When.ProcedureWithParam(It.IsEqualTo(3));

  Mock.Instance.ProcedureWithParam(3);

  Assert.IsTrue(Executed, 'Don''t execute the right procedure!');
end;

{ TItTest }

procedure TItTest.ComparingEqualValueOnlyReturnTrueWhenIsEqual(Value: Integer; Comparision: Boolean);
begin
  var ValueIt := It;

  ValueIt.IsEqualTo(123);

  Assert.AreEqual(Comparision, ValueIt.Compare(Value));
end;

procedure TItTest.ComparingNotEqualValueOnlyReturnTrueWhenIsNotEqual(Value: Integer; Comparision: Boolean);
begin
  var ValueIt := It;

  ValueIt.IsNotEqualTo(123);

  Assert.AreEqual(Comparision, ValueIt.Compare(Value));
end;

procedure TItTest.WhenIsAnyIsCreateAlwaysReturnTrue;
begin
  var ValueIt := It;

  ValueIt.IsAny<String>;

  Assert.IsTrue(ValueIt.Compare(EmptyStr));
end;

initialization
  TDUnitX.RegisterTestFixture(TMockInterfaceTest);

end.

