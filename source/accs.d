module accessories;

import std.json;

// ------------ //
enum HAPPermission {
  PAIRED_READ,
  PAIRED_WRITE,
  EVENTS,
  ADDITIONAL_AUTHORIZATION,
  TIMED_WRITE,
  HIDDEN,
  NONE
}

struct HAPCharacteristic {
  string type;
  uint iid;
  JSONValue value;
  string format;
  string description;
  HAPPermission[] perms;
  string toJSON() {
    JSONValue j = parseJSON("{}");
    j["type"] = JSONValue(type);
    j["iid"] = JSONValue(iid);
    if (value.type != JSONType.null_) {
      j["value"] = value;
    }
    j["format"] = JSONValue(format);
    j["perms"] = parseJSON("[]");
    if (description.length > 0) {
      j["description"] = JSONValue(description);
    }
    foreach(p; perms) {
      if (p == HAPPermission.PAIRED_READ) {
        j["perms"].array ~= JSONValue("pr");
      } else if (p == HAPPermission.PAIRED_WRITE) {
        j["perms"].array ~= JSONValue("pw");
      } else if (p == HAPPermission.EVENTS) {
        j["perms"].array ~= JSONValue("ev");
      }
    }
    return j.toJSON;
  }
}
struct HAPService {
  string type;
  uint iid;
  HAPCharacteristic[] chars;
  string toJSON() {
    JSONValue j = parseJSON("{}");
    j["type"] = JSONValue(type);
    j["iid"] = JSONValue(iid);
    j["characteristics"] = parseJSON("[]");
    foreach(c; chars) {
      j["characteristics"].array ~= parseJSON(c.toJSON);
    }
    return j.toJSON;
  }
}


struct HAPAccessory {
  uint aid;
  HAPService[] services;
  uint iid = 1; // last iid
  string toJSON() {
    JSONValue j = parseJSON("{}");
    j["aid"] = JSONValue(aid);
    j["services"] = parseJSON("[]");
    foreach(s; services) {
      j["services"].array ~= parseJSON(s.toJSON);
    }
    return j.toJSON;
  }
  void createInfoService(string manufacturer, string model,
      string name, string sn, string fw) {

    HAPService info;
    info.type = "3E";

    HAPCharacteristic i1;
    i1.type = "14";
    i1.value = JSONValue(null);
    i1.format = "bool";
    i1.perms = [HAPPermission.PAIRED_WRITE];
    i1.description = "Identify";
    info.chars ~= i1;

    
    HAPCharacteristic i2;
    i2.type = "20";
    i2.value = JSONValue(manufacturer);
    i2.format = "string";
    i2.perms = [HAPPermission.PAIRED_READ];
    i2.description = "Manufacturer";
    info.chars ~= i2;

    HAPCharacteristic i3;
    i3.type = "21";
    i3.value = JSONValue(model);
    i3.format = "string";
    i3.perms = [HAPPermission.PAIRED_READ];
    i3.description = "Model";
    info.chars ~= i3;

    HAPCharacteristic i4;
    i4.type = "23";
    i4.value = JSONValue(name);
    i4.format = "string";
    i4.perms = [HAPPermission.PAIRED_READ];
    i4.description = "Name";
    info.chars ~= i4;

    HAPCharacteristic i5;
    i5.type = "30";
    i5.value = JSONValue(sn);
    i5.format = "string";
    i5.perms = [HAPPermission.PAIRED_READ];
    i5.description = "Serial Number";
    info.chars ~= i5;

    HAPCharacteristic i6;
    i6.type = "52";
    i6.value = JSONValue(fw);
    i6.format = "string";
    i6.perms = [HAPPermission.PAIRED_READ];
    i6.description = "Firmware Revision";
    info.chars ~= i6; 

    addService(info);
  }
  void createInfoService(string manufacturer, string model,
      string name, string sn) {

    HAPService info;
    info.type = "3E";

    HAPCharacteristic i1;
    i1.type = "14";
    i1.value = JSONValue(null);
    i1.format = "bool";
    i1.perms = [HAPPermission.PAIRED_WRITE];
    i1.description = "Identify";
    info.chars ~= i1;

    
    HAPCharacteristic i2;
    i2.type = "20";
    i2.value = JSONValue(manufacturer);
    i2.format = "string";
    i2.perms = [HAPPermission.PAIRED_READ];
    i2.description = "Manufacturer";
    info.chars ~= i2;

    HAPCharacteristic i3;
    i3.type = "21";
    i3.value = JSONValue(model);
    i3.format = "string";
    i3.perms = [HAPPermission.PAIRED_READ];
    i3.description = "Model";
    info.chars ~= i3;

    HAPCharacteristic i4;
    i4.type = "23";
    i4.value = JSONValue(name);
    i4.format = "string";
    i4.perms = [HAPPermission.PAIRED_READ];
    i4.description = "Name";
    info.chars ~= i4;

    HAPCharacteristic i5;
    i5.type = "30";
    i5.value = JSONValue(sn);
    i5.format = "string";
    i5.perms = [HAPPermission.PAIRED_READ];
    i5.description = "Serial Number";
    info.chars ~= i5;

    addService(info);
  }
  void addService(HAPService service) {
    service.iid = iid; iid += 1;
    for (int i = 0; i < service.chars.length; i += 1) {
      service.chars[i].iid = iid; iid += 1;
    }
    services ~= service;
  }
}

