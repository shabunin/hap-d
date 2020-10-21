module enum_characteristics;

import std.json;

import hap_structs;

enum HAPCType: string {
  Identify="14",
  Manufacturer="20",
  Model="21",
  Name="23",
  SerialNumber="30",
  Version="37",
  FirmwareRevision="52",
  HardwareRevision="53",
  On="25",
  Brightness="8",
  AccessoryFlags="A6",
  Active="B0",
  ActiveIdentifier="E7",
  AdministratorOnlyAccess="1",
  AudioFeedback="5",
  AirParticulateSize="65",
  AirQuality="95",
  BatteryLevel="68",
  ButtonEvent="126",
  CarbonMonoxideLevel="90",
  CarbonMonoxidePeakLevel="91",
  CarbonMonoxideDetected="69",
  CarbonDioxideLevel="93",
  CarbonDioxidePeakLevel="94",
  CarbonDioxideDetected="92",
  ChargingState="8F",
  CoolingThresholdTemperature="D",
  ColorTemperature="CE",
  ContactSensorState="6A",
  CurrentAmbientLightLevel="6B",
  CurrentHorizontalTiltAngle="6C",
  CurrentAirPurifierState="A9",
  CurrentSlatState="AA",
  CurrentPosition="6D",
  CurrentVerticalTiltAngle="6D",
  CurrentHumidifierDehumidifierState="B3",
  CurrentDoorState="E",
  CurrentFanState="AF",
  CurrentHeatingCoolingState="F",
  CurrentHeaterCoolerState="B1",
  CurrentRelativeHumidity="10",
  CurrentTemperature="11",
  CurrentTiltAngle="C1",
  DigitalZoom="11D",
  FilterLifeLevel="AB",
  FilterChangeIndication="AC",
  HeatingThresholdTemperature="12",
  HoldPosition="6F",
  Hue="13",
  ImageRotation="11E",
  ImageMirroring="11F",
  InUse="D2",
  IsConfigured="D6",
  LeakDetected="70",
  LockControlPoint="19",
  LockCurrentState="1D",
  LockLastKnownAction="1C",
  LockManagementAutoSecurityTimeout="1A",
  LockPhysicalControls="A7",
  LockTargetState="1E",
  Logs="1F",
  MotionDetected="22",
  Mute="11A",
  NightVision="11B",
  NitrogenDioxideDensity="C4",
  ObstructionDetected="24",
  PM25Density="C6",
  OccupancyDetected="71",
  OpticalZoom="11C",
  OutletInUse="26",
  OzoneDensity="C3",
  PM10Density="C7",
  PositionState="72",
  ProgramMode="D1",
  ProgrammableSwitchEvent="73",
  RelativeHumidityDehumidifierThreshold="C9",
  RelativeHumidityHumidifierThreshold="CA",
  RemainingDuration="D4",
  ResetFilterIndication="AD",
  RotationDirection="28",
  RotationSpeed="29",
  Saturation="2F",
  SecuritySystemAlarmType="BE",
  SecuritySystemCurrentState="66",
  SecuritySystemTargetState="67",
  SelectedAudioStreamConfiguration="128",
  ServiceLabelIndex="CB",
  ServiceLabelNamespace="CD",
  SetupDataStreamTransport="131",
  SelectedRTPStreamConfiguration="117",
  SetupEndpoints="118",
  SiriInputType="132",
  SlatType="C0",
  SmokeDetected="76",
  StatusActive="75",
  StatusFault="77",
  StatusJammed="78",
  StatusLowBattery="79",
  StatusTampered="7A",
  StreamingStatus="120",
  SupportedAudioStreamConfiguration="115",
  SupportedDataStreamTransportConfiguration="130",
  SupportedRTPConfiguration="116",
  SupportedVideoStreamConfiguration="114",
  SulphurDioxideDensity="C5",
  SwingMode="B6",
  TargetAirPurifierState="A8",
  TargetFanState="BF",
  TargetTiltAngle="C2",
  TargetHeaterCoolerState="B2",
  SetDuration="D3",
  TargetControlSupportedConfiguration="123",
  TargetControlList="124",
  TargetHorizontalTiltAngle="7B",
  TargetHumidifierDehumidifierState="B4",
  TargetPosition="7C",
  TargetDoorState="32",
  TargetHeatingCoolingState="33",
  TargetRelativeHumidity="34",
  TargetTemperature="35",
  TemperatureDisplayUnits="36",
  TargetVerticalTiltAngle="7D",
  ValveType="D5",
  VOCDensity="C8",
  Volume="119",
  WaterLevel="B5"
}

HAPCharacteristic HAPC_Identify() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.Identify;
  c.value = JSONValue(null);
  c.format = "bool";
  c.perms = [HAPPermission.PAIRED_WRITE];
  c.description = "Identify";

  return c;
}
HAPCharacteristic HAPC_Manufacturer(string value) {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.Manufacturer;
  c.value = JSONValue(value);
  c.format = "string";
  c.perms = [HAPPermission.PAIRED_READ];
  c.description = "Manufacturer";

  return c;
}
HAPCharacteristic HAPC_Model(string value) {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.Model;
  c.value = JSONValue(value);
  c.format = "string";
  c.perms = [HAPPermission.PAIRED_READ];
  c.description = "Model";

  return c;
}
HAPCharacteristic HAPC_Name(string value) {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.Name;
  c.value = JSONValue(value);
  c.format = "string";
  c.perms = [HAPPermission.PAIRED_READ];
  c.description = "Name";

  return c;
}
HAPCharacteristic HAPC_SerialNumber(string value) {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.SerialNumber;
  c.value = JSONValue(value);
  c.format = "string";
  c.perms = [HAPPermission.PAIRED_READ];
  c.description = "SerialNumber";

  return c;
}
HAPCharacteristic HAPC_Version(string value) {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.Version;
  c.value = JSONValue(value);
  c.format = "string";
  c.perms = [HAPPermission.PAIRED_READ, HAPPermission.EVENTS];
  c.description = "Version";

  return c;
}
HAPCharacteristic HAPC_FirmwareRevision(string value) {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.FirmwareRevision;
  c.value = JSONValue(value);
  c.format = "string";
  c.perms = [HAPPermission.PAIRED_READ];
  c.description = "Firmware Revision";

  return c;
}
HAPCharacteristic HAPC_HardwareRevision(string value) {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.HardwareRevision;
  c.format = "string";
  c.value = JSONValue(value);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Hardware Revision";

  return c;
}

HAPCharacteristic HAPC_On() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.On;
  c.format = "bool";
  c.value = JSONValue(false);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "On";

  return c;
}

HAPCharacteristic HAPC_Brightness() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.Brightness;
  c.format = "int";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Brightness";

  return c;
}
HAPCharacteristic HAPC_AccessoryFlags() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.AccessoryFlags;
  c.format = "uint32";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Accessory Flags";

  return c;
}
HAPCharacteristic HAPC_Active() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.Active;
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Active";

  return c;
}
HAPCharacteristic HAPC_ActiveIdentifier() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.ActiveIdentifier;
  c.format = "uint32";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Active Identifier";

  return c;
}
HAPCharacteristic HAPC_AdministratorOnlyAccess() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.AdministratorOnlyAccess;
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Administrator Only Access";

  return c;
}
HAPCharacteristic HAPC_AudioFeedback() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.AudioFeedback;
  c.format = "bool";
  c.value = JSONValue(false);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Audio Feedback";

  return c;
}
HAPCharacteristic HAPC_AirParticulateSize(ubyte value = 0x00) {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.AirParticulateSize;
  c.format = "uint8";
  c.value = JSONValue(value);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Air Particulate Size";

  return c;
}
HAPCharacteristic HAPC_AirQuality() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.AirQuality;
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Air Quality";

  return c;
}
HAPCharacteristic HAPC_BatteryLevel() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.BatteryLevel;
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Battery Level";

  return c;
}
HAPCharacteristic HAPC_ButtonEvent() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.ButtonEvent;
  c.format = "tlv8";
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Button Event";

  return c;
}
HAPCharacteristic HAPC_CarbonMonoxideLevel() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.CarbonMonoxideLevel;
  c.format = "float";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Carbon Monoxide Level";

  return c;
}
HAPCharacteristic HAPC_CarbonMonoxidePeakLevel() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.CarbonMonoxidePeakLevel;
  c.format = "float";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Carbon Monoxide Peak Level";

  return c;
}
HAPCharacteristic HAPC_CarbonMonoxideDetected() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.CarbonMonoxideDetected;
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Carbon Monoxide Detected";

  return c;
}
HAPCharacteristic HAPC_CarbonDioxideLevel() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.CarbonDioxideLevel;
  c.format = "float";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Carbon Dioxide Level";

  return c;
}
HAPCharacteristic HAPC_CarbonDioxidePeakLevel() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.CarbonDioxidePeakLevel;
  c.format = "float";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Carbon Dioxide Peak Level";

  return c;
}
HAPCharacteristic HAPC_CarbonDioxideDetected() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.CarbonDioxideDetected;
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Carbon Dioxide Detected";

  return c;
}
HAPCharacteristic HAPC_ChargingState() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.ChargingState;
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Charging State";

  return c;
}
HAPCharacteristic HAPC_CoolingThresholdTemperature() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.CoolingThresholdTemperature;
  c.format = "float";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Cooling Threshold Temperature";

  return c;
}
HAPCharacteristic HAPC_ColorTemperature() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.ColorTemperature;
  c.format = "uint32";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Color Temperature";

  return c;
}
HAPCharacteristic HAPC_ContactSensorState() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.ContactSensorState;
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Contact Sensor";

  return c;
}
HAPCharacteristic HAPC_CurrentAmbientLightLevel() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.CurrentAmbientLightLevel;
  c.format = "float";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Current Ambient Light Level";

  return c;
}
HAPCharacteristic HAPC_CurrentHorizontalTiltAngle() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.CurrentHorizontalTiltAngle;
  c.format = "int";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Current Horizontal Tilt Angle";

  return c;
}
HAPCharacteristic HAPC_CurrentAirPurifierState() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.CurrentAirPurifierState;
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Current Air Purifier State";

  return c;
}
HAPCharacteristic HAPC_CurrentSlatState() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.CurrentSlatState;
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Current Slat State";

  return c;
}
HAPCharacteristic HAPC_CurrentPosition() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.CurrentPosition;
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Current Position";

  return c;
}
HAPCharacteristic HAPC_CurrentVerticalTiltAngle() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.CurrentVerticalTiltAngle;
  c.format = "int";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Current Vertical Tilt Angle";

  return c;
}
HAPCharacteristic HAPC_CurrentHumidifierDehumidifierState() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.CurrentHumidifierDehumidifierState;
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Current Humidifier Dehumidifier State";

  return c;
}
HAPCharacteristic HAPC_CurrentDoorState() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.CurrentDoorState;
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Current Door State";

  return c;
}
HAPCharacteristic HAPC_CurrentFanState() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.CurrentFanState;
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Current Fan State";

  return c;
}
HAPCharacteristic HAPC_CurrentHeatingCoolingState() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.CurrentHeatingCoolingState;
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Current Heating Current State";

  return c;
}
HAPCharacteristic HAPC_CurrentHeaterCoolerState() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.CurrentHeaterCoolerState;
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Current Heater Cooler State";

  return c;
}
HAPCharacteristic HAPC_CurrentRelativeHumidity() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.CurrentRelativeHumidity;
  c.format = "float";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Current Relative Humidity";

  return c;
}
HAPCharacteristic HAPC_CurrentTemperature() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.CurrentTemperature;
  c.format = "float";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Current Temperature";

  return c;
}
HAPCharacteristic HAPC_CurrentTiltAngle() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.CurrentTiltAngle;
  c.format = "int";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Current Tilt Angle";

  return c;
}
HAPCharacteristic HAPC_DigitalZoom() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.DigitalZoom;
  c.format = "float";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Digital Zoom";

  return c;
}
HAPCharacteristic HAPC_FilterLifeLevel() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.FilterLifeLevel;
  c.format = "float";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Filter Life Level";

  return c;
}
HAPCharacteristic HAPC_FilterChangeIndication() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.FilterChangeIndication;
  c.format = "float";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Filter Life Level";

  return c;
}
HAPCharacteristic HAPC_HeatingThresholdTemperature() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.HeatingThresholdTemperature;
  c.format = "float";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Heating Threshold Temperature";

  return c;
}
HAPCharacteristic HAPC_HoldPosition() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.HoldPosition;
  c.format = "bool";
  c.value = JSONValue(false);
  c.perms = [HAPPermission.PAIRED_WRITE]; 
  c.description = "Hold Position";

  return c;
}
HAPCharacteristic HAPC_Hue() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.Hue;
  c.format = "float";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Hue";

  return c;
}
HAPCharacteristic HAPC_ImageRotation() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.ImageRotation;
  c.format = "float";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Image Rotation";

  return c;
}
HAPCharacteristic HAPC_ImageMirroring() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.ImageMirroring;
  c.format = "bool";
  c.value = JSONValue(false);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Image Mirroring";

  return c;
}
HAPCharacteristic HAPC_InUse() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.InUse;
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "In Use";

  return c;
}
HAPCharacteristic HAPC_IsConfigured() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.IsConfigured;
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Is Configured";

  return c;
}
HAPCharacteristic HAPC_LeakDetected() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.LeakDetected;
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Leak Detected";

  return c;
}
HAPCharacteristic HAPC_LockControlPoint() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.LockControlPoint;
  c.format = "tlv8";
  c.perms = [HAPPermission.PAIRED_WRITE];
  c.description = "Lock Control Point";

  return c;
}
HAPCharacteristic HAPC_LockCurrentState() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.LockCurrentState;
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Lock Current State";

  return c;
}
HAPCharacteristic HAPC_LockLastKnownAction() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.LockLastKnownAction;
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Lock Last Known Action";

  return c;
}
HAPCharacteristic HAPC_LockManagementAutoSecurityTimeout() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.LockManagementAutoSecurityTimeout;
  c.format = "uint32";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE, 
             HAPPermission.EVENTS];
  c.description = "Lock Last Known Action";

  return c;
}
HAPCharacteristic HAPC_LockPhysicalControls() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.LockPhysicalControls;
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE, 
             HAPPermission.EVENTS];
  c.description = "Lock Last Known Action";

  return c;
}
HAPCharacteristic HAPC_LockTargetState() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.LockTargetState;
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE, 
             HAPPermission.EVENTS];
  c.description = "Lock Last Known Action";

  return c;
}
HAPCharacteristic HAPC_Logs() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.Logs;
  c.format = "tlv8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Logs";

  return c;
}
HAPCharacteristic HAPC_MotionDetected() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.MotionDetected;
  c.format = "bool";
  c.value = JSONValue(false);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Motion Detected";

  return c;
}
HAPCharacteristic HAPC_Mute() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.Mute;
  c.format = "bool";
  c.value = JSONValue(false);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Mute";

  return c;
}
HAPCharacteristic HAPC_NightVision() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.NightVision;
  c.format = "bool";
  c.value = JSONValue(false);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Night Vision";

  return c;
}
HAPCharacteristic HAPC_NitrogenDioxideDensity() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.NitrogenDioxideDensity;
  c.format = "float";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Nitrogen Dioxide Density";

  return c;
}
HAPCharacteristic HAPC_ObstructionDetected() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.ObstructionDetected;
  c.format = "bool";
  c.value = JSONValue(false);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Obstruction Detected";

  return c;
}
HAPCharacteristic HAPC_PM25Density() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.PM25Density;
  c.format = "float";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "PM2.5 Density";

  return c;
}
HAPCharacteristic HAPC_OccupancyDetected() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.OccupancyDetected;
  c.format = "uint8";
  c.value = JSONValue(0);
  // TOOD min-max
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Occupancy Detected";

  return c;
}
HAPCharacteristic HAPC_OpticalZoom() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.OpticalZoom;
  c.format = "float";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Optical Zoom";

  return c;
}
HAPCharacteristic HAPC_OutletInUse() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.OutletInUse;
  c.format = "bool";
  c.value = JSONValue(false);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Outlet In Use";

  return c;
}
HAPCharacteristic HAPC_OzoneDensity() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.OzoneDensity;
  c.format = "float";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Outlet In Use";

  return c;
}
HAPCharacteristic HAPC_PM10Density() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.PM10Density;
  c.format = "float";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "PM10 Density";

  return c;
}
HAPCharacteristic HAPC_PositionState() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.PositionState;
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Position State";

  return c;
}
HAPCharacteristic HAPC_ProgramMode() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.ProgramMode;
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Program Mode";

  return c;
}
HAPCharacteristic HAPC_ProgrammableSwitchEvent() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.ProgrammableSwitchEvent;
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Programmable Switch Event";

  return c;
}
HAPCharacteristic HAPC_RelativeHumidityDehumidifierThreshold() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.RelativeHumidityDehumidifierThreshold;
  c.format = "float";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Relative Humidity Dehumidifier Threshold";

  return c;
}
HAPCharacteristic HAPC_RelativeHumidityHumidifierThreshold() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.RelativeHumidityHumidifierThreshold;
  c.format = "float";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Relative Humidity Humidifier Threshold";

  return c;
}
HAPCharacteristic HAPC_RemainingDuration() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.RemainingDuration;
  c.format = "uint32";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Remaining Duration";

  return c;
}
HAPCharacteristic HAPC_ResetFilterIndication() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.ResetFilterIndication;
  c.format = "uint8";
  c.value = JSONValue(1);
  c.perms = [HAPPermission.PAIRED_WRITE];
  c.description = "Reset Filter Indication";

  return c;
}
HAPCharacteristic HAPC_RotationDirection() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.RotationDirection;
  c.format = "int";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ,
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Rotation Direction";

  return c;
}
HAPCharacteristic HAPC_RotationSpeed() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.RotationSpeed;
  c.format = "float";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ,
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Rotation Speed";

  return c;
}
HAPCharacteristic HAPC_Saturation() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.Saturation;
  c.format = "float";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ,
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Saturation";

  return c;
}
HAPCharacteristic HAPC_SecuritySystemAlarmType() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.SecuritySystemAlarmType;
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ,
             HAPPermission.EVENTS];
  c.description = "Security System Alarm Type";

  return c;
}
HAPCharacteristic HAPC_SecuritySystemCurrentState() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.SecuritySystemCurrentState;
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ,
             HAPPermission.EVENTS];
  c.description = "Security System Current State";

  return c;
}
HAPCharacteristic HAPC_SecuritySystemTargetState() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.SecuritySystemTargetState;
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ,
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Security System Target State";

  return c;
}
HAPCharacteristic HAPC_SelectedAudioStreamConfiguration() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.SelectedAudioStreamConfiguration;
  c.format = "tlv8";
  c.perms = [HAPPermission.PAIRED_READ,
             HAPPermission.PAIRED_WRITE];
  c.description = "Selected Audio Steram Configuration";

  return c;
}
HAPCharacteristic HAPC_ServiceLabelIndex() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.ServiceLabelIndex;
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ];
  c.description = "Servoce Label Index";

  return c;
}
HAPCharacteristic HAPC_ServiceLabelNamespace() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.ServiceLabelNamespace;
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ];
  c.description = "Service Label Namespace";

  return c;
}
HAPCharacteristic HAPC_SetupDataStreamTransport() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.SetupDataStreamTransport;
  c.format = "tlv8";
  c.perms = [HAPPermission.PAIRED_READ,
             HAPPermission.PAIRED_WRITE,
             HAPPermission.WRITE_RESPONSE];
  c.description = "Setup Stream Transport";

  return c;
}
HAPCharacteristic HAPC_SelectedRTPStreamConfiguration() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.SelectedRTPStreamConfiguration;
  c.format = "tlv8";
  c.perms = [HAPPermission.PAIRED_READ,
             HAPPermission.PAIRED_WRITE];
  c.description = "Selected RTP Stream Configuration";

  return c;
}
HAPCharacteristic HAPC_SetupEndpoints() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.SetupEndpoints;
  c.format = "tlv8";
  c.perms = [HAPPermission.PAIRED_READ,
             HAPPermission.PAIRED_WRITE];
  c.description = "Setup Endpoints";

  return c;
}
HAPCharacteristic HAPC_SiriInputType() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.SiriInputType;
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ];
  c.description = "Siri Input Type";

  return c;
}
HAPCharacteristic HAPC_SlatType() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.SlatType;
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ];
  c.description = "Slat Type";

  return c;
}
HAPCharacteristic HAPC_SmokeDetected() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.SmokeDetected;
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ,
             HAPPermission.EVENTS];
  c.description = "Smoke Detected";

  return c;
}
HAPCharacteristic HAPC_StatusActive() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.StatusActive;
  c.format = "bool";
  c.value = JSONValue(false);
  c.perms = [HAPPermission.PAIRED_READ,
             HAPPermission.EVENTS];
  c.description = "Status Active";

  return c;
}
HAPCharacteristic HAPC_StatusFault() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.StatusFault;
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ,
             HAPPermission.EVENTS];
  c.description = "Status Fault";

  return c;
}
HAPCharacteristic HAPC_StatusJammed() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.StatusJammed;
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ,
             HAPPermission.EVENTS];
  c.description = "Status Jammed";

  return c;
}
HAPCharacteristic HAPC_StatusLowBattery() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.StatusLowBattery;
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ,
             HAPPermission.EVENTS];
  c.description = "Status Low Battery";

  return c;
}
HAPCharacteristic HAPC_StatusTampered() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.StatusTampered;
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ,
             HAPPermission.EVENTS];
  c.description = "Status Tampered";

  return c;
}
HAPCharacteristic HAPC_StreamingStatus() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.StreamingStatus;
  c.format = "tlv8";
  c.perms = [HAPPermission.PAIRED_READ,
             HAPPermission.EVENTS];
  c.description = "Streaming Status";

  return c;
}
HAPCharacteristic HAPC_SupportedAudioStreamConfiguration() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.SupportedAudioStreamConfiguration;
  c.format = "tlv8";
  c.perms = [HAPPermission.PAIRED_READ];
  c.description = "Supported Audio Stream Configuration";

  return c;
}
HAPCharacteristic HAPC_SupportedDataStreamTransportConfiguration() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.SupportedDataStreamTransportConfiguration;
  c.format = "tlv8";
  c.perms = [HAPPermission.PAIRED_READ];
  c.description = "Supported Data Stream Transport Configuration";

  return c;
}
HAPCharacteristic HAPC_SupportedRTPConfiguration() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.SupportedRTPConfiguration;
  c.format = "tlv8";
  c.perms = [HAPPermission.PAIRED_READ];
  c.description = "Supported RTP Configuration";

  return c;
}
HAPCharacteristic HAPC_SupportedVideoStreamConfiguration() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.SupportedVideoStreamConfiguration;
  c.format = "tlv8";
  c.perms = [HAPPermission.PAIRED_READ];
  c.description = "Supported Video Stream Configuration";

  return c;
}
HAPCharacteristic HAPC_SulphurDioxideDensity() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.SulphurDioxideDensity;
  c.format = "float";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Sulphur Dioxide Density";

  return c;
}
HAPCharacteristic HAPC_SwingMode() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.SwingMode;
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Swing Mode";

  return c;
}
HAPCharacteristic HAPC_TargetAirPurifierState() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.TargetAirPurifierState;
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Target Air Purifier State";

  return c;
}
HAPCharacteristic HAPC_TargetFanState() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.TargetFanState;
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Target Fan State";

  return c;
}
HAPCharacteristic HAPC_TargetTiltAngle() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.TargetTiltAngle;
  c.format = "int";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Target Tilt Angle";

  return c;
}
HAPCharacteristic HAPC_TargetHeaterCoolerState() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.TargetHeaterCoolerState;
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Target Heater Cooler State";

  return c;
}
HAPCharacteristic HAPC_SetDuration() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.SetDuration;
  c.format = "uint32";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Set Duration";

  return c;
}
HAPCharacteristic HAPC_TargetControlSupportedConfiguration() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.TargetControlSupportedConfiguration;
  c.format = "tlv8";
  c.perms = [HAPPermission.PAIRED_READ];
  c.description = "Target Control Supported Configuration";

  return c;
}
HAPCharacteristic HAPC_TargetControlList() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.TargetControlList;
  c.format = "tlv8";
  c.perms = [HAPPermission.PAIRED_READ,
             HAPPermission.PAIRED_WRITE,
             HAPPermission.WRITE_RESPONSE];
  c.description = "Target Control List";

  return c;
}
HAPCharacteristic HAPC_TargetHorizontalTiltAngle() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.TargetHorizontalTiltAngle;
  c.format = "int";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Target Horizontal Tilt Angle";

  return c;
}
HAPCharacteristic HAPC_TargetHumidifierDehumidifierState() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.TargetHumidifierDehumidifierState;
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Target Humidifer Dehumidifier State";

  return c;
}
HAPCharacteristic HAPC_TargetPosition() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.TargetPosition;
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Target Position";

  return c;
}
HAPCharacteristic HAPC_TargetDoorState() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.TargetDoorState;
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Target Door State";

  return c;
}
HAPCharacteristic HAPC_TargetHeatingCoolingState() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.TargetHeatingCoolingState;
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Target Heating Cooling State";

  return c;
}
HAPCharacteristic HAPC_TargetRelativeHumidity() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.TargetRelativeHumidity;
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Target Relative Humidity";

  return c;
}
HAPCharacteristic HAPC_TargetTemperature() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.TargetTemperature;
  c.format = "float";
  c.value = JSONValue(10.0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Target Temperature";

  return c;
}
HAPCharacteristic HAPC_TemperatureDisplayUnits(ubyte value = 0x00) {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.TemperatureDisplayUnits;
  c.format = "uint8";
  c.value = JSONValue(value);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Temperature Display Units";

  return c;
}
HAPCharacteristic HAPC_TargetVerticalTiltAngle() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.TargetVerticalTiltAngle;
  c.format = "int";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Target Vertical Tilt Angle";

  return c;
}
HAPCharacteristic HAPC_ValveType(ubyte value = 0x00) {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.ValveType;
  c.format = "uint8";
  c.value = JSONValue(value);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Valve Type";

  return c;
}
HAPCharacteristic HAPC_VOCDensity() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.VOCDensity;
  c.format = "float";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "VOC Density";

  return c;
}
HAPCharacteristic HAPC_Volume() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.Volume;
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Volume";

  return c;
}
HAPCharacteristic HAPC_WaterLevel() {
  HAPCharacteristic c = new HAPCharacteristic();
  c.type = HAPCType.WaterLevel;
  c.format = "float";
  c.value = JSONValue(0.0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Volume";

  return c;
}
