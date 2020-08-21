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
    [Test]
    procedure TheMethodCountMustIncByOneEveryTimeTheProcedureIsCalled;
    [Test]
    procedure TheOneMethodWhenNotExecutedMustReturnMessageInExpectation;
    [Test]
    procedure WhenTheOnceMethodIsCalledMoreThenOneTimeMustRegisterInTheMessageTheQuantityOsCalls;
    [Test]
    procedure WhenTheOnceMethodIsCalledOnlyOneTimeTheExpcetationMustReturnEmptyString;
    [Test]
    procedure ThePropertyExpectMethodsMustReturnOnlyTheMethodThatImplementsTheExpectedInterface;
    [Test]
    procedure WhenAProcedureIsLoggedButNotExecutedByParameterDifferenceHasToGiveAnError;
    [Test]
    procedure IfTheMethodFoundIsAnExpectationCanNotGiveAnException;
  end;

  TMyMethod = class(TMethodInfo, IMethod)
  private
    FCalled: Boolean;

    procedure Execute(out Result: TValue);
  end;

  TMyExceptMethod = class(TMethodInfo, IMethod, IMethodExpect)
  private
    function CheckExpectation: String;

    procedure Execute(out Result: TValue);
  end;

  TMyClass = class
  public
    procedure AnyProcedure;
    procedure AnotherProcedure(Param: String; Param2: Integer);
    procedure MyProcedure(Param: String);
  end;

implementation

uses System.SysUtils, Delphi.Mock;

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

procedure TMethodRegisterTest.IfTheMethodFoundIsAnExpectationCanNotGiveAnException;
begin
  var Context := TRttiContext.Create;
  var Method := Context.GetType(TMyClass).GetMethod('MyProcedure');
  var MethodRegister := TMethodRegister.Create;
  var MyMethod := TMyMethod.Create;
  var MyExpectMethod := TMyExceptMethod.Create;
  var Result: TValue;

  MethodRegister.StartRegister(MyExpectMethod);

  It.IsEqualTo('abc');

  MethodRegister.RegisterMethod(Method);

  Assert.WillNotRaise(
    procedure
    var
      Result: TValue;

    begin
      MethodRegister.ExecuteMethod(Method, ['xxx'], Result)
    end);

  MethodRegister.Free;
end;

procedure TMethodRegisterTest.TheMethodCountMustIncByOneEveryTimeTheProcedureIsCalled;
begin
  var Method := TMethodInfoCounter.Create;
  var Value := TValue.Empty;

  for var A := 1 to 10 do
    Method.Execute(Value);

  Assert.AreEqual(10, Method.ExecutionCount);

  Method.Free;
end;

procedure TMethodRegisterTest.TheOneMethodWhenNotExecutedMustReturnMessageInExpectation;
begin
  var Method := TMethodInfoExpectOnce.Create;

  Assert.AreEqual('Expected to call once the method but never called', Method.CheckExpectation);

  Method.Free;
end;

procedure TMethodRegisterTest.ThePropertyExpectMethodsMustReturnOnlyTheMethodThatImplementsTheExpectedInterface;
begin
  var Context := TRttiContext.Create;
  var Method := Context.GetType(TMyClass).GetMethod('AnyProcedure');
  var MethodRegister := TMethodRegister.Create;
  var MyMethod := TMyMethod.Create;
  var MyExpectMethod := TMyExceptMethod.Create;
  var Result: TValue;

  MethodRegister.StartRegister(MyMethod);

  MethodRegister.RegisterMethod(Method);

  MethodRegister.StartRegister(MyExpectMethod);

  MethodRegister.RegisterMethod(Method);

  MethodRegister.StartRegister(MyMethod);

  MethodRegister.RegisterMethod(Method);

  MethodRegister.StartRegister(MyMethod);

  MethodRegister.RegisterMethod(Method);

  MethodRegister.StartRegister(MyExpectMethod);

  MethodRegister.RegisterMethod(Method);

  Assert.AreEqual(2, Length(MethodRegister.ExceptMethods));

  MethodRegister.Free;
end;

procedure TMethodRegisterTest.WhenAProcedureIsLoggedButNotExecutedByParameterDifferenceHasToGiveAnError;
begin
  var MethodRegister := TMethodRegister.Create;

  Assert.WillRaise(
    procedure
    begin
      var Context := TRttiContext.Create;
      var Method := Context.GetType(TMyClass).GetMethod('MyProcedure');
      var MyMethod := TMyMethod.Create;
      var Result: TValue;

      MethodRegister.StartRegister(MyMethod);

      It.IsEqualTo('abc');

      MethodRegister.RegisterMethod(Method);

      MethodRegister.ExecuteMethod(Method, ['zzz'], Result);
    end, ERegisteredMethodsButDifferentParameters);

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

procedure TMethodRegisterTest.WhenTheOnceMethodIsCalledMoreThenOneTimeMustRegisterInTheMessageTheQuantityOsCalls;
begin
  var Method := TMethodInfoExpectOnce.Create;
  var Value := TValue.Empty;

  for var A := 1 to 10 do
    Method.Execute(Value);

  Assert.AreEqual('Expected to call once the method but was called 10 times', Method.CheckExpectation);

  Method.Free;
end;

procedure TMethodRegisterTest.WhenTheOnceMethodIsCalledOnlyOneTimeTheExpcetationMustReturnEmptyString;
begin
  var Method := TMethodInfoExpectOnce.Create;
  var Value := TValue.Empty;

  Method.Execute(Value);

  Assert.AreEqual(EmptyStr, Method.CheckExpectation);

  Method.Free;
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

{ TMyExceptMethod }

function TMyExceptMethod.CheckExpectation: String;
begin
  Result := EmptyStr;
end;

procedure TMyExceptMethod.Execute(out Result: TValue);
begin

end;

initialization
  TDUnitX.RegisterTestFixture(TMethodRegisterTest);

end.
