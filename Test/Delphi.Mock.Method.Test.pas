unit Delphi.Mock.Method.Test;

interface

uses DUnitX.TestFramework, System.Rtti, Delphi.Mock.Method;

type
  [TestFixture]
  TMethodRegisterTest = class
  public
    [Test]
    procedure IfDontCallStartRegisterAndTryToRegisterAMethodMustRaiseAException;
    [Test]
    procedure WhenCallStartRegisterCantRaiseAExpcetionWhenCallRegisterMethod;
    [Test]
    procedure AfterCallRegisterMethodMustResetTheControlOfRegistering;
    [Test]
    procedure WhenCallStartRegisterMustSetNilToItGlobalVariable;
    [Test]
    procedure WhenCallExecuteMustCallExecuteFromInterfaceMethod;
    [Test]
    procedure WhenClassExecuteOfAMethodThatIsNotRegisteredMustRaiseAException;
    [Test]
    procedure WhenRegisteringAProcedureWithParametersYouHaveToRecordTheParametersWithTheItFunction;
    [Test]
    procedure WhenTheNumberOfParametersRecordedIsDifferentFromTheAmountOfParametersTheProcedureHasToRaiseAnError;
    [Test]
    procedure WhenCallAProcedureMustFindTheCorrectProcedureByValueOfCallingParameters;
  end;

  TMyMethod = class(TMethodInfo, IMethod)
  private
    FCalled: Boolean;

    procedure Execute(out Result: TValue);
  end;

  TMyClass = class
  public
    procedure AnyProcedure;
    procedure AnotherProcedure(Param: String; Param2: Integer);
    procedure MyProcedure(Param: String);
  end;

implementation

uses Delphi.Mock;

{ TMethodRegisterTest }

procedure TMethodRegisterTest.AfterCallRegisterMethodMustResetTheControlOfRegistering;
begin
  var MethodRegister := TMethodRegister.Create;

  Assert.WillRaise(
    procedure
    begin
      var Context := TRttiContext.Create;
      var Result: TValue;

      MethodRegister.StartRegister(TMyMethod.Create);

      MethodRegister.RegisterMethod(Context.GetType(ClassType).GetMethods[0]);

      MethodRegister.RegisterMethod(Context.GetType(ClassType).GetMethods[0]);
    end, EDidNotCallTheStartRegister);

  MethodRegister.Free;
end;

procedure TMethodRegisterTest.IfDontCallStartRegisterAndTryToRegisterAMethodMustRaiseAException;
begin
  var MethodRegister := TMethodRegister.Create;

  Assert.WillRaise(
    procedure
    begin
      var Result: TValue;

      MethodRegister.RegisterMethod(nil);
    end, EDidNotCallTheStartRegister);

  MethodRegister.Free;
end;

procedure TMethodRegisterTest.WhenCallAProcedureMustFindTheCorrectProcedureByValueOfCallingParameters;
begin
  var Context := TRttiContext.Create;
  var Method := Context.GetType(TMyClass).GetMethod('AnotherProcedure');
  var MethodRegister := TMethodRegister.Create;
  var MyMethod := TMyMethod.Create;
  var MyMethodCorrect := TMyMethod.Create;
  var Result: TValue;

  MethodRegister.StartRegister(MyMethod);

  It.IsEqualTo('abc');
  It.IsEqualTo(1234);

  MethodRegister.RegisterMethod(Method);

  MethodRegister.StartRegister(MyMethod);

  It.IsEqualTo('abc');
  It.IsEqualTo(5555);

  MethodRegister.RegisterMethod(Method);

  MethodRegister.StartRegister(MyMethodCorrect);

  It.IsEqualTo('abc');
  It.IsEqualTo(789);

  MethodRegister.RegisterMethod(Method);

  MethodRegister.ExecuteMethod(Method, ['abc', 789], Result);

  Assert.IsTrue(MyMethodCorrect.FCalled);

  MethodRegister.Free;
end;

procedure TMethodRegisterTest.WhenCallExecuteMustCallExecuteFromInterfaceMethod;
begin
  var Context := TRttiContext.Create;
  var Method := Context.GetType(ClassType).GetMethods[0];
  var MethodRegister := TMethodRegister.Create;
  var MyMethod := TMyMethod.Create;
  var Result: TValue;

  MethodRegister.StartRegister(MyMethod);

  MethodRegister.RegisterMethod(Method);

  MethodRegister.ExecuteMethod(Method, [], Result);

  Assert.IsTrue(MyMethod.FCalled);

  MethodRegister.Free;
end;

procedure TMethodRegisterTest.WhenCallStartRegisterCantRaiseAExpcetionWhenCallRegisterMethod;
begin
  var MethodRegister := TMethodRegister.Create;

  Assert.WillNotRaise(
    procedure
    begin
      var Context := TRttiContext.Create;
      var Result: TValue;

      MethodRegister.StartRegister(TMyMethod.Create);

      MethodRegister.RegisterMethod(Context.GetType(ClassType).GetMethods[0]);
    end);

  MethodRegister.Free;
end;

procedure TMethodRegisterTest.WhenCallStartRegisterMustSetNilToItGlobalVariable;
begin
  GItParams := [TIt.Create];
  var MethodRegister := TMethodRegister.Create;

  MethodRegister.StartRegister(TMyMethod.Create);

  Assert.IsNull(GItParams);

  MethodRegister.Free;
end;

procedure TMethodRegisterTest.WhenClassExecuteOfAMethodThatIsNotRegisteredMustRaiseAException;
begin
  var MethodRegister := TMethodRegister.Create;

  Assert.WillRaise(
    procedure
    begin
      var Context := TRttiContext.Create;
      var MyMethod := TMyMethod.Create;
      var Result: TValue;

      MethodRegister.StartRegister(MyMethod);

      MethodRegister.RegisterMethod(Context.GetType(ClassType).GetMethods[0]);

      MethodRegister.ExecuteMethod(Context.GetType(ClassType).GetMethods[1], [], Result);
    end, EMethodNotRegistered);

  MethodRegister.Free;
end;

procedure TMethodRegisterTest.WhenRegisteringAProcedureWithParametersYouHaveToRecordTheParametersWithTheItFunction;
begin
  var MethodRegister := TMethodRegister.Create;

  Assert.WillRaise(
    procedure
    begin
      var Context := TRttiContext.Create;
      var MyMethod := TMyMethod.Create;
      var Result: TValue;

      MethodRegister.StartRegister(MyMethod);

      MethodRegister.RegisterMethod(Context.GetType(TMyClass).GetMethod('MyProcedure'));
    end, EParamsRegisteredMismatch);

  MethodRegister.Free;
end;

procedure TMethodRegisterTest.WhenTheNumberOfParametersRecordedIsDifferentFromTheAmountOfParametersTheProcedureHasToRaiseAnError;
begin
  var MethodRegister := TMethodRegister.Create;

  It.IsAny<String>;

  It.IsAny<String>;

  Assert.WillRaise(
    procedure
    begin
      var Context := TRttiContext.Create;
      var MyMethod := TMyMethod.Create;
      var Result: TValue;

      MethodRegister.StartRegister(MyMethod);

      MethodRegister.RegisterMethod(Context.GetType(TMyClass).GetMethod('MyProcedure'));
    end, EParamsRegisteredMismatch);

  MethodRegister.Free;
end;

{ TMyMethod }

procedure TMyMethod.Execute(out Result: TValue);
begin
  FCalled := True;
end;

{ TMyClass }

procedure TMyClass.AnotherProcedure(Param: String; Param2: Integer);
begin

end;

procedure TMyClass.AnyProcedure;
begin

end;

procedure TMyClass.MyProcedure(Param: String);
begin

end;

initialization
  TDUnitX.RegisterTestFixture(TMethodRegisterTest);

end.
