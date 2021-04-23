unit Delphi.Mock.Method.Test;

interface

uses DUnitX.TestFramework, System.Rtti, System.SysUtils, Delphi.Mock.Method;

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
    [Test]
    procedure WhenUsingTheCustomExpectationMustReturnTheValeuFromFunctionRegistered;
    [Test]
    procedure WhenExecuteTheCustomExpectationMustPassTheParamsFromCallingProcedure;
    [Test]
    procedure WhenCallAnExceptationMethodMustMarkAsExecuted;
    [Test]
    procedure WhenAExpectationIsRegistredButNotCalledMustReturnError;
    [Test]
    procedure WhenRegisteredAMethodOfExpectationMustReturnTheMessageOfExpectationWhenCalled;
    [Test]
    procedure WhenExistsMoreTheOneExpectationRegisteredMustReturnTheMessageOfAllMethods;
    [Test]
    procedure TheMethodExpectOneMustReturnTrueAlwayWhenCheckingIfWasExecuted;
    [Test]
    procedure WhenRegisteringAMethodAndAnErrorIsRaisedTheGlobalVarOfItsMustBeReseted;
    [Test]
    procedure WhenTheMethodBeingRegisteredCannotBeOverrideItHasToGiveError;
    [Test]
    procedure IfTheNeverCallIsExecutedMustReturnTheExpectationError;
    [Test]
    procedure IfTheNeverCallIsNotExecutedMustReturnTheExpectationEmpty;
    [Test]
    procedure TheNeverCallExpectationMustReturnTrueInTheCheckExecuted;
    [Test]
    procedure WhenRegistredAExpectationAndANormalProcedureMustExecuteBothMethods;
    [Test]
    procedure TheExecutionCountExpectationIsNotEqualToExpectationMustReturnThenDiferencesOfCalls;
    [Test]
    procedure IfTheExecutionCountExpectationIsEqualToExpectationMustReturnAEmptyString;
    [Test]
    procedure IfTheAutoMockIsEnabledCantRaiseAnyErrorInTheExecutionOfAMethod;
  end;

  TMyMethod = class(TMethodInfo, IMethod)
  private
    FCalled: Boolean;
    FParams: TArray<TValue>;

    procedure Execute(const Params: TArray<TValue>; out Result: TValue);
  end;

  TMyExpectMethod = class(TMethodInfo, IMethod, IMethodExpect)
  private
    FMessage: String;
    FExceptation: Boolean;

    function CheckExpectation: String;
    function ExceptationExecuted: Boolean;

    procedure Execute(const Params: TArray<TValue>; out Result: TValue);
  public
    constructor Create(ExpectationMessage: String = '');
  end;

  TMyClass = class
  public
    function MyFunction: Integer; virtual;

    procedure AnyProcedure; virtual;
    procedure AnotherProcedure(Param: String; Param2: Integer); dynamic;
    procedure MyProcedure(Param: String); virtual;
    procedure NonVirtualProcedure;
  end;

implementation

uses Delphi.Mock;

{ TMethodRegisterTest }

procedure TMethodRegisterTest.AfterCallRegisterMethodMustResetTheControlOfRegistering;
begin
  var MethodRegister := TMethodRegister.Create(False);

  Assert.WillRaise(
    procedure
    begin
      var Context := TRttiContext.Create;

      MethodRegister.StartRegister(TMyMethod.Create);

      MethodRegister.RegisterMethod(Context.GetType(TMyClass).GetMethods[0]);

      MethodRegister.RegisterMethod(Context.GetType(TMyClass).GetMethods[0]);
    end, EDidNotCallTheStartRegister);

  MethodRegister.Free;
end;

procedure TMethodRegisterTest.IfDontCallStartRegisterAndTryToRegisterAMethodMustRaiseAException;
begin
  var MethodRegister := TMethodRegister.Create(False);

  Assert.WillRaise(
    procedure
    begin
      MethodRegister.RegisterMethod(nil);
    end, EDidNotCallTheStartRegister);

  MethodRegister.Free;
end;

procedure TMethodRegisterTest.IfTheAutoMockIsEnabledCantRaiseAnyErrorInTheExecutionOfAMethod;
begin
  var Context := TRttiContext.Create;
  var Method := Context.GetType(TMyClass).GetMethod('AnotherProcedure');
  var MethodRegister := TMethodRegister.Create(True);
  var Result: TValue;

  Assert.WillNotRaise(
    procedure
    begin
      MethodRegister.ExecuteMethod(Method, nil, Result);
    end);

  MethodRegister.Free;
end;

procedure TMethodRegisterTest.IfTheExecutionCountExpectationIsEqualToExpectationMustReturnAEmptyString;
begin
  var Method := TMethodInfoExpectExecutionCount.Create(10);
  Method.Method := TRttiContext.Create.GetType(TMyClass).GetMethod('AnyProcedure');
  var Value := TValue.Empty;

  for var A := 1 to 10 do
    Method.Execute(nil, Value);

  Assert.AreEqual(EmptyStr, Method.CheckExpectation);

  Method.Free;
end;

procedure TMethodRegisterTest.IfTheMethodFoundIsAnExpectationCanNotGiveAnException;
begin
  var Context := TRttiContext.Create;
  var Method := Context.GetType(TMyClass).GetMethod('MyProcedure');
  var MethodRegister := TMethodRegister.Create(False);
  var MyExpectMethod := TMyExpectMethod.Create;

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

procedure TMethodRegisterTest.IfTheNeverCallIsExecutedMustReturnTheExpectationError;
begin
  var Method := TMethodInfoExpectNever.Create;
  Method.Method := TRttiContext.Create.GetType(TMyClass).GetMethod('AnyProcedure');
  var Value := TValue.Empty;

  for var A := 1 to 10 do
    Method.Execute(nil, Value);

  Assert.AreEqual('Expected to never be called the procedure "AnyProcedure", but was called 10 times', Method.CheckExpectation);

  Method.Free;
end;

procedure TMethodRegisterTest.IfTheNeverCallIsNotExecutedMustReturnTheExpectationEmpty;
begin
  var Method := TMethodInfoExpectNever.Create;

  Assert.AreEqual(EmptyStr, Method.CheckExpectation);

  Method.Free;
end;

procedure TMethodRegisterTest.TheExecutionCountExpectationIsNotEqualToExpectationMustReturnThenDiferencesOfCalls;
begin
  var Method := TMethodInfoExpectExecutionCount.Create(5);
  Method.Method := TRttiContext.Create.GetType(TMyClass).GetMethod('AnyProcedure');
  var Value := TValue.Empty;

  for var A := 1 to 10 do
    Method.Execute(nil, Value);

  Assert.AreEqual('Expected to call the method "AnyProcedure" 5 times, but was called 10 times', Method.CheckExpectation);

  Method.Free;
end;

procedure TMethodRegisterTest.TheMethodCountMustIncByOneEveryTimeTheProcedureIsCalled;
begin
  var Method := TMethodInfoCounter.Create;
  var Value := TValue.Empty;

  for var A := 1 to 10 do
    Method.Execute(nil, Value);

  Assert.AreEqual(10, Method.ExecutionCount);

  Method.Free;
end;

procedure TMethodRegisterTest.TheMethodExpectOneMustReturnTrueAlwayWhenCheckingIfWasExecuted;
begin
  var Method := TMethodInfoExpectOnce.Create;

  Assert.IsTrue(Method.ExceptationExecuted);

  Method.Free;
end;

procedure TMethodRegisterTest.TheNeverCallExpectationMustReturnTrueInTheCheckExecuted;
begin
  var Method := TMethodInfoExpectNever.Create;

  Assert.IsTrue(Method.ExceptationExecuted);

  Method.Free;
end;

procedure TMethodRegisterTest.TheOneMethodWhenNotExecutedMustReturnMessageInExpectation;
begin
  var Method:= TMethodInfoExpectOnce.Create;
  Method.Method := TRttiContext.Create.GetType(TMyClass).GetMethod('AnyProcedure');

  Assert.AreEqual('Expected to call the method "AnyProcedure" once but never called', Method.CheckExpectation);

  Method.Free;
end;

procedure TMethodRegisterTest.ThePropertyExpectMethodsMustReturnOnlyTheMethodThatImplementsTheExpectedInterface;
begin
  var Context := TRttiContext.Create;
  var Method := Context.GetType(TMyClass).GetMethod('AnyProcedure');
  var MethodRegister := TMethodRegister.Create(False);
  var MyMethod := TMyMethod.Create;
  var MyExpectMethod := TMyExpectMethod.Create;

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

  Assert.AreEqual(2, Length(MethodRegister.ExpectMethods));

  MethodRegister.Free;

  Assert.IsTrue(True);
end;

procedure TMethodRegisterTest.WhenAExpectationIsRegistredButNotCalledMustReturnError;
begin
  var Context := TRttiContext.Create;
  var Method := Context.GetType(TMyClass).GetMethod('AnyProcedure');
  var MethodRegister := TMethodRegister.Create(False);
  var MyMethod := TMyExpectMethod.Create;

  MethodRegister.StartRegister(MyMethod);

  MethodRegister.RegisterMethod(Method);

  Assert.AreEqual('No expectations executed!', MethodRegister.CheckExpectations);

  MethodRegister.Free;
end;

procedure TMethodRegisterTest.WhenAProcedureIsLoggedButNotExecutedByParameterDifferenceHasToGiveAnError;
begin
  var Context := TRttiContext.Create;
  var Method := Context.GetType(TMyClass).GetMethod('MyProcedure');
  var MethodRegister := TMethodRegister.Create(False);
  var MyMethod: IMethod := TMyMethod.Create;
  var Result: TValue;

  MethodRegister.StartRegister(MyMethod);

  MyMethod := nil;

  It.IsEqualTo('abc');

  MethodRegister.RegisterMethod(Method);

  Assert.WillRaise(
    procedure
    begin
      MethodRegister.ExecuteMethod(Method, ['zzz'], Result);
    end, ERegisteredMethodsButDifferentParameters);

  MethodRegister.Free;
end;

procedure TMethodRegisterTest.WhenCallAnExceptationMethodMustMarkAsExecuted;
begin
  var Method := TMethodInfoExcept.Create;
  var Result := TValue.Empty;

  Method.Execute(nil, Result);

  Assert.IsTrue(Method.ExceptationExecuted);

  Method.Free;
end;

procedure TMethodRegisterTest.WhenCallAProcedureMustFindTheCorrectProcedureByValueOfCallingParameters;
begin
  var Context := TRttiContext.Create;
  var Method := Context.GetType(TMyClass).GetMethod('AnotherProcedure');
  var MethodRegister := TMethodRegister.Create(False);
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
  var Method := Context.GetType(TMyClass).GetMethods[0];
  var MethodRegister := TMethodRegister.Create(False);
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
  var MethodRegister := TMethodRegister.Create(False);

  Assert.WillNotRaise(
    procedure
    begin
      var Context := TRttiContext.Create;

      MethodRegister.StartRegister(TMyMethod.Create);

      MethodRegister.RegisterMethod(Context.GetType(TMyClass).GetMethods[0]);
    end);

  MethodRegister.Free;
end;

procedure TMethodRegisterTest.WhenClassExecuteOfAMethodThatIsNotRegisteredMustRaiseAException;
begin
  var MethodRegister := TMethodRegister.Create(False);

  Assert.WillRaise(
    procedure
    begin
      var Context := TRttiContext.Create;
      var MyMethod := TMyMethod.Create;
      var Result: TValue;

      MethodRegister.StartRegister(MyMethod);

      MethodRegister.RegisterMethod(Context.GetType(TMyClass).GetMethods[0]);

      MethodRegister.ExecuteMethod(Context.GetType(TMyClass).GetMethods[1], [], Result);
    end, EMethodNotRegistered);

  MethodRegister.Free;
end;

procedure TMethodRegisterTest.WhenExecuteTheCustomExpectationMustPassTheParamsFromCallingProcedure;
begin
  var Context := TRttiContext.Create;
  var Method := Context.GetType(TMyClass).GetMethod('MyProcedure');
  var MethodRegister := TMethodRegister.Create(False);
  var MyMethod := TMyMethod.Create;
  var Result: TValue;

  MethodRegister.StartRegister(MyMethod);

  It.IsAny<String>;

  MethodRegister.RegisterMethod(Method);

  MethodRegister.ExecuteMethod(Method, ['String'], Result);

  Assert.AreEqual('String', MyMethod.FParams[0].AsString);

  MethodRegister.Free;
end;

procedure TMethodRegisterTest.WhenExistsMoreTheOneExpectationRegisteredMustReturnTheMessageOfAllMethods;
begin
  var Context := TRttiContext.Create;
  var Method := Context.GetType(TMyClass).GetMethod('AnyProcedure');
  var MethodRegister := TMethodRegister.Create(False);
  var MyMethod := TMyExpectMethod.Create('Expectation message');
  var Result: TValue;

  MethodRegister.StartRegister(MyMethod);

  MethodRegister.RegisterMethod(Method);

  MethodRegister.StartRegister(MyMethod);

  MethodRegister.RegisterMethod(Method);

  MethodRegister.ExecuteMethod(Method, nil, Result);

  MethodRegister.ExecuteMethod(Method, nil, Result);

  Assert.AreEqual('Expectation message'#13#10'Expectation message', MethodRegister.CheckExpectations);

  MethodRegister.Free;
end;

procedure TMethodRegisterTest.WhenRegisteredAMethodOfExpectationMustReturnTheMessageOfExpectationWhenCalled;
begin
  var Context := TRttiContext.Create;
  var Method := Context.GetType(TMyClass).GetMethod('AnyProcedure');
  var MethodRegister := TMethodRegister.Create(False);
  var MyMethod := TMyExpectMethod.Create('Expectation message');
  var Result: TValue;

  MethodRegister.StartRegister(MyMethod);

  MethodRegister.RegisterMethod(Method);

  MethodRegister.ExecuteMethod(Method, nil, Result);

  Assert.AreEqual('Expectation message', MethodRegister.CheckExpectations);

  MethodRegister.Free;
end;

procedure TMethodRegisterTest.WhenRegisteringAMethodAndAnErrorIsRaisedTheGlobalVarOfItsMustBeReseted;
begin
  var MethodRegister := TMethodRegister.Create(False);

  It.IsAny<String>;

  It.IsAny<String>;

  var Context := TRttiContext.Create;
  var MyMethod := TMyMethod.Create;

  MethodRegister.StartRegister(MyMethod);

  try
    MethodRegister.RegisterMethod(Context.GetType(TMyClass).GetMethod('MyProcedure'));
  except
  end;

  Assert.AreEqual(0, Length(GItParams));

  MethodRegister.Free;
end;

procedure TMethodRegisterTest.WhenRegisteringAProcedureWithParametersYouHaveToRecordTheParametersWithTheItFunction;
begin
  var MethodRegister := TMethodRegister.Create(False);

  Assert.WillRaise(
    procedure
    begin
      var Context := TRttiContext.Create;
      var MyMethod := TMyMethod.Create;

      MethodRegister.StartRegister(MyMethod);

      MethodRegister.RegisterMethod(Context.GetType(TMyClass).GetMethod('MyProcedure'));
    end, EParamsRegisteredMismatch);

  MethodRegister.Free;
end;

procedure TMethodRegisterTest.WhenRegistredAExpectationAndANormalProcedureMustExecuteBothMethods;
begin
  var MethodRegister := TMethodRegister.Create(False);
  var MyFunction := TRttiContext.Create.GetType(TMyClass).GetMethod('MyFunction');
  var Return := TValue.Empty;

  MethodRegister.StartRegister(TMethodInfoWillReturn.Create(200));

  MethodRegister.RegisterMethod(MyFunction);

  MethodRegister.StartRegister(TMethodInfoExpectOnce.Create);

  MethodRegister.RegisterMethod(MyFunction);

  MethodRegister.ExecuteMethod(MyFunction, nil, Return);

  Assert.AreEqual(200, Return.AsInteger);

  Assert.AreEqual(EmptyStr, MethodRegister.CheckExpectations);

  MethodRegister.Free;
end;

procedure TMethodRegisterTest.WhenTheMethodBeingRegisteredCannotBeOverrideItHasToGiveError;
begin
  var MethodRegister := TMethodRegister.Create(False);

  Assert.WillRaise(
    procedure
    begin
      var Context := TRttiContext.Create;
      var MyMethod := TMyMethod.Create;

      MethodRegister.StartRegister(MyMethod);

      MethodRegister.RegisterMethod(Context.GetType(TMyClass).GetMethod('NonVirtualProcedure'));
    end, ENonVirtualMethod);

  MethodRegister.Free;
end;

procedure TMethodRegisterTest.WhenTheNumberOfParametersRecordedIsDifferentFromTheAmountOfParametersTheProcedureHasToRaiseAnError;
begin
  var MethodRegister := TMethodRegister.Create(False);

  It.IsAny<String>;

  It.IsAny<String>;

  Assert.WillRaise(
    procedure
    begin
      var Context := TRttiContext.Create;
      var MyMethod := TMyMethod.Create;

      MethodRegister.StartRegister(MyMethod);

      MethodRegister.RegisterMethod(Context.GetType(TMyClass).GetMethod('MyProcedure'));
    end, EParamsRegisteredMismatch);

  MethodRegister.Free;
end;

procedure TMethodRegisterTest.WhenTheOnceMethodIsCalledMoreThenOneTimeMustRegisterInTheMessageTheQuantityOsCalls;
begin
  var Method := TMethodInfoExpectOnce.Create;
  Method.Method := TRttiContext.Create.GetType(TMyClass).GetMethod('AnyProcedure');
  var Value := TValue.Empty;

  for var A := 1 to 10 do
    Method.Execute(nil, Value);

  Assert.AreEqual('Expected to call the method "AnyProcedure" once but was called 10 times', Method.CheckExpectation);

  Method.Free;
end;

procedure TMethodRegisterTest.WhenTheOnceMethodIsCalledOnlyOneTimeTheExpcetationMustReturnEmptyString;
begin
  var Method := TMethodInfoExpectOnce.Create;
  var Value := TValue.Empty;

  Method.Execute(nil, Value);

  Assert.AreEqual(EmptyStr, Method.CheckExpectation);

  Method.Free;
end;

procedure TMethodRegisterTest.WhenUsingTheCustomExpectationMustReturnTheValeuFromFunctionRegistered;
begin
  var Method := TMethodInfoCustomExpectation.Create(
    function (Params: TArray<TValue>): String
    begin
      Result := Params[0].AsString;
    end);
  var Return := TValue.Empty;

  Method.Execute(['Return'], Return);

  Assert.AreEqual('Return', Method.CheckExpectation);

  Method.Free;
end;

{ TMyMethod }

procedure TMyMethod.Execute(const Params: TArray<TValue>; out Result: TValue);
begin
  FCalled := True;
  FParams := Params;
end;

{ TMyClass }

procedure TMyClass.AnotherProcedure(Param: String; Param2: Integer);
begin

end;

procedure TMyClass.AnyProcedure;
begin

end;

function TMyClass.MyFunction: Integer;
begin
  Result := 100;
end;

procedure TMyClass.MyProcedure(Param: String);
begin

end;

procedure TMyClass.NonVirtualProcedure;
begin

end;

{ TMyExpectMethod }

function TMyExpectMethod.CheckExpectation: String;
begin
  Result := FMessage;
end;

constructor TMyExpectMethod.Create(ExpectationMessage: String);
begin
  inherited Create;

  FMessage := ExpectationMessage;
end;

function TMyExpectMethod.ExceptationExecuted: Boolean;
begin
  Result := FExceptation;
end;

procedure TMyExpectMethod.Execute(const Params: TArray<TValue>; out Result: TValue);
begin
  FExceptation := True;
end;

initialization
  TDUnitX.RegisterTestFixture(TMethodRegisterTest);

  // Avoiding memory leak register.
  var Context := TRttiContext.Create;
  Context.GetType(TMyClass).GetMethods;

end.

