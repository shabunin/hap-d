module enum_characteristics;

import std.json;

import hap_structs;

HAPCharacteristic HAPC_Identify() {
  HAPCharacteristic c;
  c.type = "14";
  c.value = JSONValue(null);
  c.format = "bool";
  c.perms = [HAPPermission.PAIRED_WRITE];
  c.description = "Identify";

  return c;
}
HAPCharacteristic HAPC_Manufacturer(string value) {
  HAPCharacteristic c;
  c.type = "20";
  c.value = JSONValue(value);
  c.format = "string";
  c.perms = [HAPPermission.PAIRED_READ];
  c.description = "Manufacturer";

  return c;
}
HAPCharacteristic HAPC_Model(string value) {
  HAPCharacteristic c;
  c.type = "21";
  c.value = JSONValue(value);
  c.format = "string";
  c.perms = [HAPPermission.PAIRED_READ];
  c.description = "Model";

  return c;
}
HAPCharacteristic HAPC_Name(string value) {
  HAPCharacteristic c;
  c.type = "23";
  c.value = JSONValue(value);
  c.format = "string";
  c.perms = [HAPPermission.PAIRED_READ];
  c.description = "Name";

  return c;
}
HAPCharacteristic HAPC_SerialNumber(string value) {
  HAPCharacteristic c;
  c.type = "30";
  c.value = JSONValue(value);
  c.format = "string";
  c.perms = [HAPPermission.PAIRED_READ];
  c.description = "SerialNumber";

  return c;
}
HAPCharacteristic HAPC_Version(string value) {
  HAPCharacteristic c;
  c.type = "37";
  c.value = JSONValue(value);
  c.format = "string";
  c.perms = [HAPPermission.PAIRED_READ, HAPPermission.EVENTS];
  c.description = "Version";

  return c;
}
HAPCharacteristic HAPC_FirmwareRevision(string value) {
  HAPCharacteristic c;
  c.type = "52";
  c.value = JSONValue(value);
  c.format = "string";
  c.perms = [HAPPermission.PAIRED_READ];
  c.description = "FirmwareRevision";

  return c;
}
HAPCharacteristic HAPC_HardwareRevision(string value) {
  HAPCharacteristic c;
  c.type = "53";
  c.format = "string";
  c.value = JSONValue(value);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Hardware Revision";

  return c;
}

HAPCharacteristic HAPC_On() {
  HAPCharacteristic c;
  c.type = "25";
  c.format = "bool";
  c.value = JSONValue(false);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "On";

  return c;
}

HAPCharacteristic HAPC_Brightness() {
  HAPCharacteristic c;
  c.type = "8";
  c.format = "int";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Brightness";

  return c;
}
HAPCharacteristic HAPC_Active() {
  HAPCharacteristic c;
  c.type = "B0";
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Active";

  return c;
}
HAPCharacteristic HAPC_ActiveIdentifier() {
  HAPCharacteristic c;
  c.type = "E7";
  c.format = "uint32";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Active Identifier";

  return c;
}
HAPCharacteristic HAPC_AdministratorOnlyAccess() {
  HAPCharacteristic c;
  c.type = "1";
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Administrator Only Access";

  return c;
}
HAPCharacteristic HAPC_AudioFeedback() {
  HAPCharacteristic c;
  c.type = "5";
  c.format = "bool";
  c.value = JSONValue(false);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Audio Feedback";

  return c;
}
HAPCharacteristic HAPC_AirParticulateSize(ubyte value = 0x00) {
  HAPCharacteristic c;
  c.type = "65";
  c.format = "uint8";
  c.value = JSONValue(value);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Air Particulate Size";

  return c;
}
HAPCharacteristic HAPC_AirQuality() {
  HAPCharacteristic c;
  c.type = "95";
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Air Quality";

  return c;
}
HAPCharacteristic HAPC_BatteryLevel() {
  HAPCharacteristic c;
  c.type = "68";
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Battery Level";

  return c;
}
HAPCharacteristic HAPC_ButtonEvent() {
  HAPCharacteristic c;
  c.type = "126";
  c.format = "tlv8";
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Button Event";

  return c;
}
HAPCharacteristic HAPC_CarbonMonoxideLevel() {
  HAPCharacteristic c;
  c.type = "90";
  c.format = "float";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Carbon Monoxide Level";

  return c;
}
HAPCharacteristic HAPC_CarbonMonoxidePeakLevel() {
  HAPCharacteristic c;
  c.type = "91";
  c.format = "float";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Carbon Monoxide Peak Level";

  return c;
}
HAPCharacteristic HAPC_CarbonMonoxideDetected() {
  HAPCharacteristic c;
  c.type = "69";
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Carbon Monoxide Detected";

  return c;
}
HAPCharacteristic HAPC_CarbonDioxideLevel() {
  HAPCharacteristic c;
  c.type = "93";
  c.format = "float";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Carbon Dioxide Level";

  return c;
}
HAPCharacteristic HAPC_CarbonDioxidePeakLevel() {
  HAPCharacteristic c;
  c.type = "94";
  c.format = "float";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Carbon Dioxide Peak Level";

  return c;
}
HAPCharacteristic HAPC_CarbonDioxideDetected() {
  HAPCharacteristic c;
  c.type = "92";
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Carbon Dioxide Detected";

  return c;
}
HAPCharacteristic HAPC_ChargingState() {
  HAPCharacteristic c;
  c.type = "8F";
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Charging State";

  return c;
}
HAPCharacteristic HAPC_CoolingThreshholdTemperature() {
  HAPCharacteristic c;
  c.type = "0D";
  c.format = "float";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Cooling Threshold Temperature";

  return c;
}
HAPCharacteristic HAPC_ColorTemperature() {
  HAPCharacteristic c;
  c.type = "CE";
  c.format = "uint32";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Color Temperature";

  return c;
}
HAPCharacteristic HAPC_ContactSensor() {
  HAPCharacteristic c;
  c.type = "6A";
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Contact Sensor";

  return c;
}
HAPCharacteristic HAPC_CurrentAmbientLightLevel() {
  HAPCharacteristic c;
  c.type = "6B";
  c.format = "float";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Current Ambient Light Level";

  return c;
}
HAPCharacteristic HAPC_CurrentHorizontalTiltLevel() {
  HAPCharacteristic c;
  c.type = "6C";
  c.format = "int";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Current Horizontal Tilt Level";

  return c;
}
HAPCharacteristic HAPC_CurrentAirPurifierState() {
  HAPCharacteristic c;
  c.type = "A9";
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Current Air Purifier State";

  return c;
}
HAPCharacteristic HAPC_CurrentSlatState() {
  HAPCharacteristic c;
  c.type = "AA";
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Current Slat State";

  return c;
}
HAPCharacteristic HAPC_CurrentPosition() {
  HAPCharacteristic c;
  c.type = "6D";
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Current Position";

  return c;
}
HAPCharacteristic HAPC_CurrentVerticalTiltAngle() {
  HAPCharacteristic c;
  c.type = "6D";
  c.format = "int";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Current Vertical Tilt Angle";

  return c;
}
HAPCharacteristic HAPC_CurrentHumidifierDehumidifierState() {
  HAPCharacteristic c;
  c.type = "B3";
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Current Humidifier Dehumidifier State";

  return c;
}
HAPCharacteristic HAPC_CurrentDoorState() {
  HAPCharacteristic c;
  c.type = "E";
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Current Door State";

  return c;
}
HAPCharacteristic HAPC_CurrentFanState() {
  HAPCharacteristic c;
  c.type = "AF";
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Current Fan State";

  return c;
}
HAPCharacteristic HAPC_CurrentHeatingCoolingState() {
  HAPCharacteristic c;
  c.type = "F";
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Current Heating Current State";

  return c;
}
HAPCharacteristic HAPC_CurrentHeaterCoolerState() {
  HAPCharacteristic c;
  c.type = "B1";
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Current Heater Cooler State";

  return c;
}
HAPCharacteristic HAPC_CurrentRelativeHumidity() {
  HAPCharacteristic c;
  c.type = "10";
  c.format = "float";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Current Relative Humidity";

  return c;
}
HAPCharacteristic HAPC_CurrentTemperature() {
  HAPCharacteristic c;
  c.type = "11";
  c.format = "float";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Current Temperature";

  return c;
}
HAPCharacteristic HAPC_CurrentTiltAngle() {
  HAPCharacteristic c;
  c.type = "C1";
  c.format = "int";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Current Tilt Angle";

  return c;
}
HAPCharacteristic HAPC_DigitalZoom() {
  HAPCharacteristic c;
  c.type = "11D";
  c.format = "float";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Digital Zoom";

  return c;
}
HAPCharacteristic HAPC_FilterLifeLevel() {
  HAPCharacteristic c;
  c.type = "AB";
  c.format = "float";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Filter Life Level";

  return c;
}
HAPCharacteristic HAPC_FilterChangeIndicator() {
  HAPCharacteristic c;
  c.type = "AB";
  c.format = "float";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Filter Life Level";

  return c;
}
HAPCharacteristic HAPC_HeatingThreshholdTemperature() {
  HAPCharacteristic c;
  c.type = "12";
  c.format = "float";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Heating Threshold Temperature";

  return c;
}
HAPCharacteristic HAPC_HoldPosition() {
  HAPCharacteristic c;
  c.type = "6F";
  c.format = "bool";
  c.value = JSONValue(false);
  c.perms = [HAPPermission.PAIRED_WRITE]; 
  c.description = "Hold Position";

  return c;
}
HAPCharacteristic HAPC_Hue() {
  HAPCharacteristic c;
  c.type = "13";
  c.format = "float";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Hue";

  return c;
}
HAPCharacteristic HAPC_ImageRotation() {
  HAPCharacteristic c;
  c.type = "11E";
  c.format = "float";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Image Rotation";

  return c;
}
HAPCharacteristic HAPC_ImageMirroring() {
  HAPCharacteristic c;
  c.type = "11F";
  c.format = "bool";
  c.value = JSONValue(false);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Image Mirroring";

  return c;
}
HAPCharacteristic HAPC_InUse() {
  HAPCharacteristic c;
  c.type = "D2";
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "In Use";

  return c;
}
HAPCharacteristic HAPC_IsConfigured() {
  HAPCharacteristic c;
  c.type = "D6";
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Is Configured";

  return c;
}
HAPCharacteristic HAPC_LeakDetected() {
  HAPCharacteristic c;
  c.type = "70";
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Leak Detected";

  return c;
}
HAPCharacteristic HAPC_LockControlPoint() {
  HAPCharacteristic c;
  c.type = "19";
  c.format = "tlv8";
  c.perms = [HAPPermission.PAIRED_WRITE];
  c.description = "Lock Control Point";

  return c;
}
HAPCharacteristic HAPC_LockCurrentState() {
  HAPCharacteristic c;
  c.type = "1D";
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Lock Current State";

  return c;
}
HAPCharacteristic HAPC_LockLastKnownAction() {
  HAPCharacteristic c;
  c.type = "1C";
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Lock Last Known Action";

  return c;
}
HAPCharacteristic HAPC_LockManagementAutoSecurityTimeout() {
  HAPCharacteristic c;
  c.type = "1A";
  c.format = "uint32";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE, 
             HAPPermission.EVENTS];
  c.description = "Lock Last Known Action";

  return c;
}
HAPCharacteristic HAPC_LockPhysicalControls() {
  HAPCharacteristic c;
  c.type = "A7";
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE, 
             HAPPermission.EVENTS];
  c.description = "Lock Last Known Action";

  return c;
}
HAPCharacteristic HAPC_LockTargetState() {
  HAPCharacteristic c;
  c.type = "1E";
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE, 
             HAPPermission.EVENTS];
  c.description = "Lock Last Known Action";

  return c;
}
HAPCharacteristic HAPC_Logs() {
  HAPCharacteristic c;
  c.type = "1F";
  c.format = "tlv8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Logs";

  return c;
}
HAPCharacteristic HAPC_MotionDetected() {
  HAPCharacteristic c;
  c.type = "22";
  c.format = "bool";
  c.value = JSONValue(false);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Motion Detected";

  return c;
}
HAPCharacteristic HAPC_Mute() {
  HAPCharacteristic c;
  c.type = "11A";
  c.format = "bool";
  c.value = JSONValue(false);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Mute";

  return c;
}
HAPCharacteristic HAPC_NightVision() {
  HAPCharacteristic c;
  c.type = "11B";
  c.format = "bool";
  c.value = JSONValue(false);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Night Vision";

  return c;
}
HAPCharacteristic HAPC_NitrogenDioxideDensity() {
  HAPCharacteristic c;
  c.type = "C4";
  c.format = "float";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Nitrogen Dioxide Density";

  return c;
}
HAPCharacteristic HAPC_ObstructionDetected() {
  HAPCharacteristic c;
  c.type = "24";
  c.format = "bool";
  c.value = JSONValue(false);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Obstruction Detected";

  return c;
}
HAPCharacteristic HAPC_PM25Density() {
  HAPCharacteristic c;
  c.type = "C6";
  c.format = "float";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "PM2.5 Density";

  return c;
}
HAPCharacteristic HAPC_OccupancyDetected() {
  HAPCharacteristic c;
  c.type = "71";
  c.format = "uint8";
  c.value = JSONValue(0);
  // TOOD min-max
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Occupancy Detected";

  return c;
}
HAPCharacteristic HAPC_OpticalZoom() {
  HAPCharacteristic c;
  c.type = "11C";
  c.format = "float";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Optical Zoom";

  return c;
}
HAPCharacteristic HAPC_OutletInUse() {
  HAPCharacteristic c;
  c.type = "26";
  c.format = "bool";
  c.value = JSONValue(false);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Outlet In Use";

  return c;
}
HAPCharacteristic HAPC_OzoneDensity() {
  HAPCharacteristic c;
  c.type = "C3";
  c.format = "float";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Outlet In Use";

  return c;
}
HAPCharacteristic HAPC_PM10Density() {
  HAPCharacteristic c;
  c.type = "C7";
  c.format = "float";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "PM10 Density";

  return c;
}
HAPCharacteristic HAPC_PositionState() {
  HAPCharacteristic c;
  c.type = "72";
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Position State";

  return c;
}
HAPCharacteristic HAPC_ProgramMode() {
  HAPCharacteristic c;
  c.type = "D1";
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Program Mode";

  return c;
}
HAPCharacteristic HAPC_ProgrammableSwitchEvent() {
  HAPCharacteristic c;
  c.type = "73";
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Programmable Switch Event";

  return c;
}
HAPCharacteristic HAPC_RelativeHumidityDehumidifierThreshold() {
  HAPCharacteristic c;
  c.type = "C9";
  c.format = "float";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Relative Humidity Dehumidifier Threshold";

  return c;
}
HAPCharacteristic HAPC_RelativeHumidityHumidifierThreshold() {
  HAPCharacteristic c;
  c.type = "CA";
  c.format = "float";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Relative Humidity Humidifier Threshold";

  return c;
}
HAPCharacteristic HAPC_RemainingDuration() {
  HAPCharacteristic c;
  c.type = "D4";
  c.format = "uint32";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Remaining Duration";

  return c;
}
HAPCharacteristic HAPC_ResetFilterIndication() {
  HAPCharacteristic c;
  c.type = "AD";
  c.format = "uint8";
  c.value = JSONValue(1);
  c.perms = [HAPPermission.PAIRED_WRITE];
  c.description = "Reset Filter Indication";

  return c;
}
HAPCharacteristic HAPC_RotationDirection() {
  HAPCharacteristic c;
  c.type = "28";
  c.format = "int";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ,
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Rotation Direction";

  return c;
}
HAPCharacteristic HAPC_RotationSpeed() {
  HAPCharacteristic c;
  c.type = "29";
  c.format = "float";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ,
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Rotation Speed";

  return c;
}
HAPCharacteristic HAPC_Saturation() {
  HAPCharacteristic c;
  c.type = "2F";
  c.format = "float";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ,
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Saturation";

  return c;
}
HAPCharacteristic HAPC_SecuritySystemAlarmType() {
  HAPCharacteristic c;
  c.type = "BE";
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ,
             HAPPermission.EVENTS];
  c.description = "Security System Alarm Type";

  return c;
}
HAPCharacteristic HAPC_SecuritySystemCurrentState() {
  HAPCharacteristic c;
  c.type = "66";
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ,
             HAPPermission.EVENTS];
  c.description = "Security System Current State";

  return c;
}
HAPCharacteristic HAPC_SelectedAudioStreamConfiguration() {
  HAPCharacteristic c;
  c.type = "128";
  c.format = "tlv8";
  c.perms = [HAPPermission.PAIRED_READ,
             HAPPermission.PAIRED_WRITE];
  c.description = "Selected Audio Steram Configuration";

  return c;
}
HAPCharacteristic HAPC_ServiceLabelIndex() {
  HAPCharacteristic c;
  c.type = "CB";
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ];
  c.description = "Servoce Label Index";

  return c;
}
HAPCharacteristic HAPC_ServiceLabelNamespace() {
  HAPCharacteristic c;
  c.type = "CD";
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ];
  c.description = "Service Label Namespace";

  return c;
}
HAPCharacteristic HAPC_SetupDataStreamTransport() {
  HAPCharacteristic c;
  c.type = "131";
  c.format = "tlv8";
  c.perms = [HAPPermission.PAIRED_READ,
             HAPPermission.PAIRED_WRITE,
             HAPPermission.WRITE_RESPONSE];
  c.description = "Setup Stream Transport";

  return c;
}
HAPCharacteristic HAPC_SelectedRTPStreamConfiguration() {
  HAPCharacteristic c;
  c.type = "117";
  c.format = "tlv8";
  c.perms = [HAPPermission.PAIRED_READ,
             HAPPermission.PAIRED_WRITE];
  c.description = "Selected RTP Stream Configuration";

  return c;
}
HAPCharacteristic HAPC_SetupEndpoints() {
  HAPCharacteristic c;
  c.type = "118";
  c.format = "tlv8";
  c.perms = [HAPPermission.PAIRED_READ,
             HAPPermission.PAIRED_WRITE];
  c.description = "Setup Endpoints";

  return c;
}
HAPCharacteristic HAPC_SiriInputType() {
  HAPCharacteristic c;
  c.type = "132";
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ];
  c.description = "Siri Input Type";

  return c;
}
HAPCharacteristic HAPC_SlatType() {
  HAPCharacteristic c;
  c.type = "C0";
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ];
  c.description = "Slat Type";

  return c;
}
HAPCharacteristic HAPC_SmokeDetected() {
  HAPCharacteristic c;
  c.type = "76";
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ,
             HAPPermission.EVENTS];
  c.description = "Smoke Detected";

  return c;
}
HAPCharacteristic HAPC_StatusActive() {
  HAPCharacteristic c;
  c.type = "75";
  c.format = "bool";
  c.value = JSONValue(false);
  c.perms = [HAPPermission.PAIRED_READ,
             HAPPermission.EVENTS];
  c.description = "Status Active";

  return c;
}
HAPCharacteristic HAPC_StatusFault() {
  HAPCharacteristic c;
  c.type = "77";
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ,
             HAPPermission.EVENTS];
  c.description = "Status Fault";

  return c;
}
HAPCharacteristic HAPC_StatusJammed() {
  HAPCharacteristic c;
  c.type = "78";
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ,
             HAPPermission.EVENTS];
  c.description = "Status Jammed";

  return c;
}
HAPCharacteristic HAPC_StatusLowBattery() {
  HAPCharacteristic c;
  c.type = "79";
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ,
             HAPPermission.EVENTS];
  c.description = "Status Low Battery";

  return c;
}
HAPCharacteristic HAPC_StatusTampered() {
  HAPCharacteristic c;
  c.type = "7A";
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ,
             HAPPermission.EVENTS];
  c.description = "Status Tampered";

  return c;
}
HAPCharacteristic HAPC_StreamingStatus() {
  HAPCharacteristic c;
  c.type = "120";
  c.format = "tlv8";
  c.perms = [HAPPermission.PAIRED_READ,
             HAPPermission.EVENTS];
  c.description = "Streaming Status";

  return c;
}
HAPCharacteristic HAPC_SupportedAudioStreamConfiguration() {
  HAPCharacteristic c;
  c.type = "115";
  c.format = "tlv8";
  c.perms = [HAPPermission.PAIRED_READ];
  c.description = "Supported Audio Stream Configuration";

  return c;
}
HAPCharacteristic HAPC_SupportedDataStreamTransportConfiguration() {
  HAPCharacteristic c;
  c.type = "130";
  c.format = "tlv8";
  c.perms = [HAPPermission.PAIRED_READ];
  c.description = "Supported Data Stream Transport Configuration";

  return c;
}
HAPCharacteristic HAPC_SupportedRTPConfiguration() {
  HAPCharacteristic c;
  c.type = "116";
  c.format = "tlv8";
  c.perms = [HAPPermission.PAIRED_READ];
  c.description = "Supported RTP Configuration";

  return c;
}
HAPCharacteristic HAPC_SupportedVideoStreamConfiguration() {
  HAPCharacteristic c;
  c.type = "114";
  c.format = "tlv8";
  c.perms = [HAPPermission.PAIRED_READ];
  c.description = "Supported Video Stream Configuration";

  return c;
}
HAPCharacteristic HAPC_SulphurDioxideDensity() {
  HAPCharacteristic c;
  c.type = "C5";
  c.format = "float";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Sulphur Dioxide Density";

  return c;
}
HAPCharacteristic HAPC_SwingMode() {
  HAPCharacteristic c;
  c.type = "B6";
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Swing Mode";

  return c;
}
HAPCharacteristic HAPC_TargetAirPurifierState() {
  HAPCharacteristic c;
  c.type = "A8";
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Target Air Purifier State";

  return c;
}
HAPCharacteristic HAPC_TargetFanState() {
  HAPCharacteristic c;
  c.type = "BF";
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Target Fan State";

  return c;
}
HAPCharacteristic HAPC_TargetTiltAngle() {
  HAPCharacteristic c;
  c.type = "C2";
  c.format = "int";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Target Tilt Angle";

  return c;
}
HAPCharacteristic HAPC_TargetHeaterCoolerState() {
  HAPCharacteristic c;
  c.type = "B2";
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Target Heater Cooler State";

  return c;
}
HAPCharacteristic HAPC_SetDuration() {
  HAPCharacteristic c;
  c.type = "D3";
  c.format = "uint32";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Set Duration";

  return c;
}
HAPCharacteristic HAPC_TargetControlSupportedConfiguration() {
  HAPCharacteristic c;
  c.type = "123";
  c.format = "tlv8";
  c.perms = [HAPPermission.PAIRED_READ];
  c.description = "Target Control Supported Configuration";

  return c;
}
HAPCharacteristic HAPC_TargetControlList() {
  HAPCharacteristic c;
  c.type = "124";
  c.format = "tlv8";
  c.perms = [HAPPermission.PAIRED_READ,
             HAPPermission.PAIRED_WRITE,
             HAPPermission.WRITE_RESPONSE];
  c.description = "Target Control List";

  return c;
}
HAPCharacteristic HAPC_TargetHorizontalTiltAngle() {
  HAPCharacteristic c;
  c.type = "7B";
  c.format = "int";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Target Horizontal Tilt Angle";

  return c;
}
HAPCharacteristic HAPC_TargetHumidierDehumidierState() {
  HAPCharacteristic c;
  c.type = "B4";
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Target Humidier Dehumidier State";

  return c;
}
HAPCharacteristic HAPC_TargetPosition() {
  HAPCharacteristic c;
  c.type = "7C";
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Target Position";

  return c;
}
HAPCharacteristic HAPC_TargetDoorState() {
  HAPCharacteristic c;
  c.type = "32";
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Target Door State";

  return c;
}
HAPCharacteristic HAPC_TargetHeatingCoolingState() {
  HAPCharacteristic c;
  c.type = "33";
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Target Heating Cooling State";

  return c;
}
HAPCharacteristic HAPC_TargetRelativeHumidity() {
  HAPCharacteristic c;
  c.type = "34";
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Target Relative Humidity";

  return c;
}
HAPCharacteristic HAPC_TargetTemperature() {
  HAPCharacteristic c;
  c.type = "35";
  c.format = "float";
  c.value = JSONValue(10.0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Target Temperature";

  return c;
}
HAPCharacteristic HAPC_TemperatureDisplayUnits(ubyte value = 0x00) {
  HAPCharacteristic c;
  c.type = "36";
  c.format = "uint8";
  c.value = JSONValue(value);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Temperature Display Units";

  return c;
}
HAPCharacteristic HAPC_TargetVerticalTiltAngle() {
  HAPCharacteristic c;
  c.type = "";
  c.format = "int";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Target Vertical Tilt Angle";

  return c;
}
HAPCharacteristic HAPC_ValveType(ubyte value = 0x00) {
  HAPCharacteristic c;
  c.type = "D5";
  c.format = "uint8";
  c.value = JSONValue(value);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Valve Type";

  return c;
}
HAPCharacteristic HAPC_VOCDensity() {
  HAPCharacteristic c;
  c.type = "C8";
  c.format = "float";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "VOC Density";

  return c;
}
HAPCharacteristic HAPC_Volume() {
  HAPCharacteristic c;
  c.type = "119";
  c.format = "uint8";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Volume";

  return c;
}
HAPCharacteristic HAPC_WaterLevel() {
  HAPCharacteristic c;
  c.type = "B5";
  c.format = "float";
  c.value = JSONValue(0.0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.EVENTS];
  c.description = "Volume";

  return c;
}
