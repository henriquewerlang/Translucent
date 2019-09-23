unit Delphi.Mock.VirtualInterface;

interface

uses System.Rtti, System.TypInfo, System.SysUtils;

type
  EInterfaceWithoutGUID = class(Exception);
  EInterfaceWithoutMethodInfo = class(Exception);

  TVirtualInterfaceEx = class(TVirtualInterface)
  public
    constructor Create(PIID: PTypeInfo); overload;
    constructor Create(PIID: PTypeInfo; InvokeEvent: TVirtualInterfaceInvokeEvent); overload;
  end;

implementation

{ TVirtualInterfaceEx }

constructor TVirtualInterfaceEx.Create(PIID: PTypeInfo; InvokeEvent: TVirtualInterfaceInvokeEvent);
begin
  var Context := TRttiContext.Create;
  var InterfaceType := Context.GetType(PIID) as TRttiInterfaceType;

  if InterfaceType.GUID = TGUID.Empty then
    raise EInterfaceWithoutGUID.Create('Interface without a GUID, please check interface declaration!')
  else if Length(InterfaceType.GetMethods) = 0 then
    raise EInterfaceWithoutMethodInfo.Create('You have to enable "Emit runtime type information" or put a {$M+} in the unit of inteface!');

  inherited;
end;

constructor TVirtualInterfaceEx.Create(PIID: PTypeInfo);
begin
  Create(PIID, nil);
end;

end.
