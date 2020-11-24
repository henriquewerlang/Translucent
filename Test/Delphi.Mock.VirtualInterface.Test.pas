unit Delphi.Mock.VirtualInterface.Test;

interface

uses DUnitX.TestFramework;

type
  [TestFixture]
  TVirtualInterfaceExTest = class
  public
    [Test]
    procedure WhenTheInterfaceDontHaveAGUIDWillRaiseAException;
    [Test]
    procedure IfTheInterfaceDontHaveMethodInfoActiveWillRaiseAException;
  end;

  IInterfaceWithoutGUI = interface

  end;

  IInterfaceWithoutMethodInfo = interface
    ['{A514CB4D-326C-4266-BF8C-29DBBBDA08E0}']
    procedure Method;
  end;

implementation

uses Delphi.Mock.VirtualInterface;

{ TVirtualInterfaceExTest }

procedure TVirtualInterfaceExTest.IfTheInterfaceDontHaveMethodInfoActiveWillRaiseAException;
begin
  Assert.WillRaise(
    procedure
    begin
      TVirtualInterfaceEx.Create(TypeInfo(IInterfaceWithoutMethodInfo), nil);
    end, EInterfaceWithoutMethodInfo);
end;

procedure TVirtualInterfaceExTest.WhenTheInterfaceDontHaveAGUIDWillRaiseAException;
begin
  Assert.WillRaise(
    procedure
    begin
      TVirtualInterfaceEx.Create(TypeInfo(IInterfaceWithoutGUI), nil);
    end, EInterfaceWithoutGUID);
end;

initialization
  TDUnitX.RegisterTestFixture(TVirtualInterfaceExTest);

end.
