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
