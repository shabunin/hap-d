module enum_services;

import hap_structs;
import enum_characteristics;

enum HAPSType: string {
  HapProtocolInfo="A2",
  Info="3E",
  AirPurifier="BB",
  AirQualitySensor="8D",
  AudioStreamManagement="127",
  BatteryService="96",
  CameraRTPStreamManagement="110",
  CarbonDioxideSensor="97",
  CarbonMonoxideSensor="7F",
  ContactSensor="80",
  DataStreamTransportManagement="129",
  Door="81",
  Doorbell="121",
  Fan="B7",
  Faucet="D7",
  FilterMaintenance="BA",
  GarageDoorOpener="41",
  HeaterCooler="BC",
  HumidifierDehumidifier="BD",
  HumiditySensor="82",
  IrrigationSystem="CF",
  LeakSensor="83",
  LightBulb="43",
  LightSensor="84",
  LockManagement="44",
  LockMechanism="45",
  Microphone="112",
  MotionSensor="85",
  OccupancySensor="86",
  Outlet="47",
  SecuritySystem="7E",
  ServiceLabel="CC",
  Siri="133",
  Slat="B9",
  SmokeSensor="87",
  Speaker="113",
  StatelessProgrammableSwitch="89",
  Switch="49",
  TargetControl="125",
  TargetControlManagement="122",
  TemperatureSensor="8A",
  Thermostat="4A",
  Valve="D0",
  Window="8B",
  WindowCovering="8C"
}

HAPService HAPS_HapProtocolInfo() {
  HAPService s = HAPService(HAPSType.HapProtocolInfo);
  return s;
}
HAPService HAPS_Info() {
  HAPService s = HAPService(HAPSType.Info);
  s.cRequired ~= HAPCType.FirmwareRevision;
  s.cRequired ~= HAPCType.Identify;
  s.cRequired ~= HAPCType.Manufacturer;
  s.cRequired ~= HAPCType.Model;
  s.cRequired ~= HAPCType.Name;
  s.cRequired ~= HAPCType.SerialNumber;

  s.cOptional ~= HAPCType.AccessoryFlags;
  s.cOptional ~= HAPCType.HardwareRevision;

  return s;
}
HAPService HAPS_AirPurifier() {
  HAPService s = HAPService(HAPSType.AirPurifier);
  s.cRequired ~= HAPCType.Active;
  s.cRequired ~= HAPCType.CurrentAirPurifierState;
  s.cRequired ~= HAPCType.TargetAirPurifierState;

  s.cOptional ~= HAPCType.Name;
  s.cOptional ~= HAPCType.RotationSpeed;
  s.cOptional ~= HAPCType.SwingMode;
  s.cOptional ~= HAPCType.LockPhysicalControls;

  return s;
}
HAPService HAPS_AirQualitySensor() {
  HAPService s = HAPService(HAPSType.AirQualitySensor);
  s.cRequired ~= HAPCType.AirQuality;

  s.cOptional ~= HAPCType.Name;
  s.cOptional ~= HAPCType.OzoneDensity;
  s.cOptional ~= HAPCType.NitrogenDioxideDensity;
  s.cOptional ~= HAPCType.SulphurDioxideDensity;
  s.cOptional ~= HAPCType.PM25Density;
  s.cOptional ~= HAPCType.PM10Density;
  s.cOptional ~= HAPCType.VOCDensity;

  return s;
}
HAPService HAPS_AudioStreamManagement() {
  HAPService s = HAPService(HAPSType.AudioStreamManagement);
  s.cRequired ~= HAPCType.SupportedAudioStreamConfiguration;
  s.cRequired ~= HAPCType.SelectedAudioStreamConfiguration;

  return s;
}
HAPService HAPS_BatteryService() {
  HAPService s = HAPService(HAPSType.BatteryService);
  s.cRequired ~= HAPCType.BatteryLevel;
  s.cRequired ~= HAPCType.ChargingState;
  s.cRequired ~= HAPCType.StatusLowBattery;

  s.cOptional ~= HAPCType.Name;

  return s;
}
HAPService HAPS_CameraRTPStreamManagement() {
  HAPService s = HAPService(HAPSType.CameraRTPStreamManagement);
  s.cRequired ~= HAPCType.StreamingStatus;
  s.cRequired ~= HAPCType.SelectedRTPStreamConfiguration;
  s.cRequired ~= HAPCType.SetupEndpoints;
  s.cRequired ~= HAPCType.SupportedAudioStreamConfiguration;
  s.cRequired ~= HAPCType.SupportedRTPConfiguration;
  s.cRequired ~= HAPCType.SupportedVideoStreamConfiguration;

  return s;
}
HAPService HAPS_CarbonDioxideSensor() {
  HAPService s = HAPService(HAPSType.CarbonDioxideSensor);
  s.cRequired ~= HAPCType.CarbonDioxideDetected;

  s.cOptional ~= HAPCType.Name;
  s.cOptional ~= HAPCType.StatusActive;
  s.cOptional ~= HAPCType.StatusFault;
  s.cOptional ~= HAPCType.StatusTampered;
  s.cOptional ~= HAPCType.StatusLowBattery;
  s.cOptional ~= HAPCType.CarbonDioxideLevel;
  s.cOptional ~= HAPCType.CarbonDioxidePeakLevel;

  return s;
}
HAPService HAPS_CarbonMonoxideSensor() {
  HAPService s = HAPService(HAPSType.CarbonMonoxideSensor);
  s.cRequired ~= HAPCType.CarbonMonoxideDetected;

  s.cOptional ~= HAPCType.Name;
  s.cOptional ~= HAPCType.StatusActive;
  s.cOptional ~= HAPCType.StatusFault;
  s.cOptional ~= HAPCType.StatusTampered;
  s.cOptional ~= HAPCType.StatusLowBattery;
  s.cOptional ~= HAPCType.CarbonMonoxideLevel;
  s.cOptional ~= HAPCType.CarbonMonoxidePeakLevel;

  return s;
}
HAPService HAPS_ContactSensor() {
  HAPService s = HAPService(HAPSType.ContactSensor);
  s.cRequired ~= HAPCType.ContactSensorState;

  s.cOptional ~= HAPCType.Name;
  s.cOptional ~= HAPCType.StatusActive;
  s.cOptional ~= HAPCType.StatusFault;
  s.cOptional ~= HAPCType.StatusTampered;
  s.cOptional ~= HAPCType.StatusLowBattery;

  return s;
}
HAPService HAPS_DataStreamTransportManagement() {
  HAPService s = HAPService(HAPSType.DataStreamTransportManagement);
  s.cRequired ~= HAPCType.SetupDataStreamTransport;
  s.cRequired ~= HAPCType.SupportedDataStreamTransportConfiguration;
  s.cRequired ~= HAPCType.Version;

  return s;
}
HAPService HAPS_Door() {
  HAPService s = HAPService(HAPSType.Door);
  s.cRequired ~= HAPCType.CurrentPosition;
  s.cRequired ~= HAPCType.TargetPosition;
  s.cRequired ~= HAPCType.PositionState;

  s.cOptional ~= HAPCType.Name;
  s.cOptional ~= HAPCType.HoldPosition;
  s.cOptional ~= HAPCType.ObstructionDetected;

  return s;
}
HAPService HAPS_Doorbell() {
  HAPService s = HAPService(HAPSType.Doorbell);
  s.cRequired ~= HAPCType.ProgrammableSwitchEvent;

  s.cOptional ~= HAPCType.Name;
  s.cOptional ~= HAPCType.Volume;
  s.cOptional ~= HAPCType.Brightness;

  return s;
}
HAPService HAPS_Fan() {
  HAPService s = HAPService(HAPSType.Fan);
  s.cRequired ~= HAPCType.Active;

  s.cOptional ~= HAPCType.Name;
  s.cOptional ~= HAPCType.CurrentFanState;
  s.cOptional ~= HAPCType.TargetFanState;
  s.cOptional ~= HAPCType.RotationDirection;
  s.cOptional ~= HAPCType.RotationSpeed;
  s.cOptional ~= HAPCType.SwingMode;
  s.cOptional ~= HAPCType.LockPhysicalControls;

  return s;
}
HAPService HAPS_Faucet() {
  HAPService s = HAPService(HAPSType.Faucet);
  s.cRequired ~= HAPCType.Active;

  s.cOptional ~= HAPCType.Name;
  s.cOptional ~= HAPCType.StatusFault;

  return s;
}
HAPService HAPS_FilterMaintenance() {
  HAPService s = HAPService(HAPSType.FilterMaintenance);
  s.cRequired ~= HAPCType.FilterChangeIndication;

  s.cOptional ~= HAPCType.Name;
  s.cOptional ~= HAPCType.FilterLifeLevel;
  s.cOptional ~= HAPCType.ResetFilterIndication;

  return s;
}
HAPService HAPS_GarageDoorOpener() {
  HAPService s = HAPService(HAPSType.GarageDoorOpener);
  s.cRequired ~= HAPCType.CurrentDoorState;
  s.cRequired ~= HAPCType.TargetDoorState;
  s.cRequired ~= HAPCType.ObstructionDetected;

  s.cOptional ~= HAPCType.Name;
  s.cOptional ~= HAPCType.LockCurrentState;
  s.cOptional ~= HAPCType.LockTargetState;

  return s;
}
HAPService HAPS_HeaterCooler() {
  HAPService s = HAPService(HAPSType.HeaterCooler);
  s.cRequired ~= HAPCType.Active;
  s.cRequired ~= HAPCType.CurrentTemperature;
  s.cRequired ~= HAPCType.CurrentHeaterCoolerState;
  s.cRequired ~= HAPCType.TargetHeaterCoolerState;

  s.cOptional ~= HAPCType.Name;
  s.cOptional ~= HAPCType.RotationSpeed;
  s.cOptional ~= HAPCType.TemperatureDisplayUnits;
  s.cOptional ~= HAPCType.SwingMode;
  s.cOptional ~= HAPCType.CoolingThresholdTemperature;
  s.cOptional ~= HAPCType.HeatingThresholdTemperature;
  s.cOptional ~= HAPCType.LockPhysicalControls;

  return s;
}
HAPService HAPS_HumidifierDehumidifier() {
  HAPService s = HAPService(HAPSType.HumidifierDehumidifier);
  s.cRequired ~= HAPCType.Active;
  s.cRequired ~= HAPCType.CurrentRelativeHumidity;
  s.cRequired ~= HAPCType.CurrentHumidifierDehumidifierState;
  s.cRequired ~= HAPCType.TargetHumidifierDehumidifierState;

  s.cOptional ~= HAPCType.Name;
  s.cOptional ~= HAPCType.RelativeHumidityDehumidifierThreshold;
  s.cOptional ~= HAPCType.RelativeHumidityHumidifierThreshold;
  s.cOptional ~= HAPCType.RotationSpeed;
  s.cOptional ~= HAPCType.SwingMode;
  s.cOptional ~= HAPCType.WaterLevel;
  s.cOptional ~= HAPCType.LockPhysicalControls;

  return s;
}
HAPService HAPS_HumiditySensor() {
  HAPService s = HAPService(HAPSType.HumiditySensor);
  s.cRequired ~= HAPCType.CurrentRelativeHumidity;

  s.cOptional ~= HAPCType.Name;
  s.cOptional ~= HAPCType.StatusActive;
  s.cOptional ~= HAPCType.StatusFault;
  s.cOptional ~= HAPCType.StatusTampered;
  s.cOptional ~= HAPCType.StatusLowBattery;

  return s;
}
HAPService HAPS_IrrigationSystem() {
  HAPService s = HAPService(HAPSType.IrrigationSystem);
  s.cRequired ~= HAPCType.Active;
  s.cRequired ~= HAPCType.ProgramMode;
  s.cRequired ~= HAPCType.InUse;

  s.cOptional ~= HAPCType.Name;
  s.cOptional ~= HAPCType.RemainingDuration;
  s.cOptional ~= HAPCType.StatusFault;

  return s;
}
HAPService HAPS_LeakSensor() {
  HAPService s = HAPService(HAPSType.LeakSensor);
  s.cRequired ~= HAPCType.LeakDetected;

  s.cOptional ~= HAPCType.Name;
  s.cOptional ~= HAPCType.StatusActive;
  s.cOptional ~= HAPCType.StatusFault;
  s.cOptional ~= HAPCType.StatusTampered;
  s.cOptional ~= HAPCType.StatusLowBattery;

  return s;
}
HAPService HAPS_LightBulb() {
  HAPService s = HAPService(HAPSType.LightBulb);
  s.cRequired ~= HAPCType.On;

  s.cOptional ~= HAPCType.Name;
  s.cOptional ~= HAPCType.Brightness;
  s.cOptional ~= HAPCType.Hue;
  s.cOptional ~= HAPCType.Saturation;
  s.cOptional ~= HAPCType.ColorTemperature;

  return s;
}
HAPService HAPS_LightSensor() {
  HAPService s = HAPService(HAPSType.LightSensor);
  s.cRequired ~= HAPCType.CurrentAmbientLightLevel;

  s.cOptional ~= HAPCType.Name;
  s.cOptional ~= HAPCType.StatusActive;
  s.cOptional ~= HAPCType.StatusFault;
  s.cOptional ~= HAPCType.StatusTampered;
  s.cOptional ~= HAPCType.StatusLowBattery;

  return s;
}
HAPService HAPS_LockManagement() {
  HAPService s = HAPService(HAPSType.LockManagement);
  s.cRequired ~= HAPCType.LockControlPoint;
  s.cRequired ~= HAPCType.Version;

  s.cOptional ~= HAPCType.Logs;
  s.cOptional ~= HAPCType.AudioFeedback;
  s.cOptional ~= HAPCType.LockManagementAutoSecurityTimeout;
  s.cOptional ~= HAPCType.AdministratorOnlyAccess;
  s.cOptional ~= HAPCType.LockLastKnownAction;
  s.cOptional ~= HAPCType.CurrentDoorState;
  s.cOptional ~= HAPCType.MotionDetected;

  return s;
}
HAPService HAPS_LockMechanism() {
  HAPService s = HAPService(HAPSType.LockMechanism);
  s.cRequired ~= HAPCType.LockCurrentState;
  s.cRequired ~= HAPCType.LockTargetState;

  s.cOptional ~= HAPCType.Name;

  return s;
}
HAPService HAPS_Microphone() {
  HAPService s = HAPService(HAPSType.Microphone);
  s.cRequired ~= HAPCType.Mute;

  s.cOptional ~= HAPCType.Name;
  s.cOptional ~= HAPCType.Volume;

  return s;
}
HAPService HAPS_MotionSensor() {
  HAPService s = HAPService(HAPSType.MotionSensor);
  s.cRequired ~= HAPCType.MotionDetected;

  s.cOptional ~= HAPCType.Name;
  s.cOptional ~= HAPCType.StatusActive;
  s.cOptional ~= HAPCType.StatusFault;
  s.cOptional ~= HAPCType.StatusTampered;
  s.cOptional ~= HAPCType.StatusLowBattery;

  return s;
}
HAPService HAPS_OccupancySensor() {
  HAPService s = HAPService(HAPSType.OccupancySensor);
  s.cRequired ~= HAPCType.OccupancyDetected;

  s.cOptional ~= HAPCType.Name;
  s.cOptional ~= HAPCType.StatusActive;
  s.cOptional ~= HAPCType.StatusFault;
  s.cOptional ~= HAPCType.StatusTampered;
  s.cOptional ~= HAPCType.StatusLowBattery;

  return s;
}
HAPService HAPS_Outlet() {
  HAPService s = HAPService(HAPSType.Outlet);
  s.cRequired ~= HAPCType.On;
  s.cRequired ~= HAPCType.OutletInUse;

  s.cOptional ~= HAPCType.Name;

  return s;
}
HAPService HAPS_SecuritySystem() {
  HAPService s = HAPService(HAPSType.SecuritySystem);
  s.cRequired ~= HAPCType.SecuritySystemCurrentState;
  s.cRequired ~= HAPCType.SecuritySystemTargetState;

  s.cOptional ~= HAPCType.Name;
  s.cOptional ~= HAPCType.SecuritySystemAlarmType;
  s.cOptional ~= HAPCType.StatusFault;
  s.cOptional ~= HAPCType.StatusTampered;

  return s;
}
HAPService HAPS_ServiceLabel() {
  HAPService s = HAPService(HAPSType.ServiceLabel);
  s.cRequired ~= HAPCType.ServiceLabelNamespace;

  return s;
}
HAPService HAPS_Siri() {
  HAPService s = HAPService(HAPSType.Siri);
  s.cRequired ~= HAPCType.SiriInputType;

  return s;
}
HAPService HAPS_Slat() {
  HAPService s = HAPService(HAPSType.Slat);
  s.cRequired ~= HAPCType.CurrentSlatState;
  s.cRequired ~= HAPCType.SlatType;

  s.cOptional ~= HAPCType.Name;
  s.cOptional ~= HAPCType.SwingMode;
  s.cOptional ~= HAPCType.CurrentTiltAngle;
  s.cOptional ~= HAPCType.TargetTiltAngle;

  return s;
}
HAPService HAPS_SmokeSensor() {
  HAPService s = HAPService(HAPSType.SmokeSensor);
  s.cRequired ~= HAPCType.SmokeDetected;

  s.cOptional ~= HAPCType.Name;
  s.cOptional ~= HAPCType.StatusActive;
  s.cOptional ~= HAPCType.StatusFault;
  s.cOptional ~= HAPCType.StatusTampered;
  s.cOptional ~= HAPCType.StatusLowBattery;

  return s;
}
HAPService HAPS_Speaker() {
  HAPService s = HAPService(HAPSType.Speaker);
  s.cRequired ~= HAPCType.Mute;

  s.cOptional ~= HAPCType.Name;
  s.cOptional ~= HAPCType.Volume;

  return s;
}
HAPService HAPS_StatelessProgrammableSwitch() {
  HAPService s = HAPService(HAPSType.StatelessProgrammableSwitch);
  s.cRequired ~= HAPCType.ProgrammableSwitchEvent;

  s.cOptional ~= HAPCType.Name;
  s.cOptional ~= HAPCType.ServiceLabelIndex;

  return s;
}
HAPService HAPS_Switch() {
  HAPService s = HAPService(HAPSType.Switch);
  s.cRequired ~= HAPCType.On;

  s.cOptional ~= HAPCType.Name;

  return s;
}
HAPService HAPS_TargetControl() {
  HAPService s = HAPService(HAPSType.TargetControl);
  s.cRequired ~= HAPCType.Active;
  s.cRequired ~= HAPCType.ActiveIdentifier;
  s.cRequired ~= HAPCType.ButtonEvent;

  s.cOptional ~= HAPCType.Name;

  return s;
}
HAPService HAPS_TargetControlManagement() {
  HAPService s = HAPService(HAPSType.TargetControlManagement);
  s.cRequired ~= HAPCType.TargetControlSupportedConfiguration;
  s.cRequired ~= HAPCType.TargetControlList;

  return s;
}
HAPService HAPS_TemperatureSensor() {
  HAPService s = HAPService(HAPSType.TemperatureSensor);
  s.cRequired ~= HAPCType.CurrentTemperature;

  s.cOptional ~= HAPCType.Name;
  s.cOptional ~= HAPCType.StatusActive;
  s.cOptional ~= HAPCType.StatusFault;
  s.cOptional ~= HAPCType.StatusTampered;
  s.cOptional ~= HAPCType.StatusLowBattery;

  return s;
}
HAPService HAPS_Thermostat() {
  HAPService s = HAPService(HAPSType.Thermostat);
  s.cRequired ~= HAPCType.CurrentHeatingCoolingState;
  s.cRequired ~= HAPCType.TargetHeatingCoolingState;
  s.cRequired ~= HAPCType.CurrentTemperature;
  s.cRequired ~= HAPCType.TargetTemperature;
  s.cRequired ~= HAPCType.TemperatureDisplayUnits;

  s.cOptional ~= HAPCType.Name;
  s.cOptional ~= HAPCType.CoolingThresholdTemperature;
  s.cOptional ~= HAPCType.HeatingThresholdTemperature;
  s.cOptional ~= HAPCType.CurrentRelativeHumidity;
  s.cOptional ~= HAPCType.TargetRelativeHumidity;

  return s;
}
HAPService HAPS_Valve() {
  HAPService s = HAPService(HAPSType.Valve);
  s.cRequired ~= HAPCType.Active;
  s.cRequired ~= HAPCType.InUse;
  s.cRequired ~= HAPCType.ValveType;

  s.cOptional ~= HAPCType.Name;
  s.cOptional ~= HAPCType.SetDuration;
  s.cOptional ~= HAPCType.RemainingDuration;
  s.cOptional ~= HAPCType.IsConfigured;
  s.cOptional ~= HAPCType.ServiceLabelIndex;
  s.cOptional ~= HAPCType.StatusFault;

  return s;
}
HAPService HAPS_Window() {
  HAPService s = HAPService(HAPSType.Window);
  s.cRequired ~= HAPCType.CurrentPosition;
  s.cRequired ~= HAPCType.TargetPosition;
  s.cRequired ~= HAPCType.PositionState;

  s.cOptional ~= HAPCType.Name;
  s.cOptional ~= HAPCType.HoldPosition;
  s.cOptional ~= HAPCType.ObstructionDetected;

  return s;
}
HAPService HAPS_WindowCovering() {
  HAPService s = HAPService(HAPSType.WindowCovering);
  s.cRequired ~= HAPCType.CurrentPosition;
  s.cRequired ~= HAPCType.TargetPosition;
  s.cRequired ~= HAPCType.PositionState;

  s.cOptional ~= HAPCType.Name;
  s.cOptional ~= HAPCType.HoldPosition;
  s.cOptional ~= HAPCType.ObstructionDetected;
  s.cOptional ~= HAPCType.CurrentHorizontalTiltAngle;
  s.cOptional ~= HAPCType.TargetHorizontalTiltAngle;
  s.cOptional ~= HAPCType.CurrentVerticalTiltAngle;
  s.cOptional ~= HAPCType.TargetVerticalTiltAngle;

  return s;
}
