unit Delphi.Mock.Classes.Test;

interface

uses DUnitX.TestFramework;

type
  [TestFixture]
  TMockTest = class
  public
    [Test]
    procedure WhenCreateAMockClassMustReturnAInstance;
    [Test]
    procedure WhenRegisterAWillExecuteMustCallTheProcedureRegistred;
    [Test]
    procedure WhenRegisterAWillReturnMustReturnTheValueRegistred;
  end;

  TMyClass = class
  public
    function MyFunction: Integer; virtual;

    procedure Execute; virtual;
  end;

implementation

uses Delphi.Mock, Delphi.Mock.Classes;

{ TMockTest }

procedure TMockTest.WhenCreateAMockClassMustReturnAInstance;
begin
  var Mock := TMock.CreateClass<TMyClass>;

  Assert.IsNotNull(Mock.Setup.Instance);

  Mock.Free;
end;

procedure TMockTest.WhenRegisterAWillExecuteMustCallTheProcedureRegistred;
begin
  var Executed := False;
  var Mock := TMock.CreateClass<TMyClass>;

  Mock.Setup.WillExecute(
    procedure
    begin
      Executed := True;
    end).When.Execute;

  Mock.Setup.Instance.Execute;

  Assert.IsTrue(Executed);

  Mock.Free;
end;

procedure TMockTest.WhenRegisterAWillReturnMustReturnTheValueRegistred;
begin
  var Mock := TMock.CreateClass<TMyClass>;

  Mock.Setup.WillReturn(123456).When.MyFunction;

  Assert.AreEqual(123456, Mock.Setup.Instance.MyFunction);

  Mock.Free;
end;

{ TMyClass }

procedure TMyClass.Execute;
begin

end;

function TMyClass.MyFunction: Integer;
begin
  Result := 0;
end;

initialization
  TDUnitX.RegisterTestFixture(TMockTest);

end.
