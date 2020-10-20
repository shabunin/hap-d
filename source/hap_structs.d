module hap_structs;

import std.json;

import enum_characteristics;
import enum_services;

enum HAPPermission : string {
  PAIRED_READ = "pr",
  PAIRED_WRITE = "pw",
  EVENTS = "ev",
  ADDITIONAL_AUTHORIZATION = "aa",
  TIMED_WRITE = "tw",
  HIDDEN = "hd",
  WRITE_RESPONSE = "wr",
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
    if (onGet !is null) {
      j["value"] = onGet();
    } else if (value.type != JSONType.null_) {
      j["value"] = value;
    }
    j["format"] = JSONValue(format);
    if (description.length > 0) {
      j["description"] = JSONValue(description);
    }
    j["perms"] = JSONValue(perms);

    return j.toJSON;
  }
  void delegate(JSONValue) onSet;
  JSONValue delegate() onGet;
}

struct HAPService {
  string type;
  uint iid;
  HAPCharacteristic[] chars;
  HAPCharacteristic[] required;
  HAPCharacteristic[] optional;
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
  void addCharacteristic(HAPCharacteristic chr) {
    foreach(c; chars) {
      if (c.type == chr.type) 
        throw new Exception("Characteristic of given type already exist.");
    }
    chars ~= chr;
  }
  void assertCharacteristics() {
    // TODO check required and optional characteristics
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
  HAPService getService(uint iid) {
    foreach(s; services) {
      if (s.iid == iid) return s;
    }
    throw new Exception("Service with given iid not found.");
  }
  HAPService getService(string type) {
    foreach(s; services) {
      if (s.type == type) return s;
    }
    throw new Exception("Service with given type not found.");
  }
  HAPCharacteristic findCharacteristic(uint iid) {
    foreach(s; services) {
      foreach(c; s.chars) {
        if (c.iid != iid) continue;
        return c;
      }
    }
    throw new Exception("Characteristic with given iid not found");
  }
  HAPService createInfoService(string manufacturer, string model,
      string name, string sn) {

    HAPService info = HAPS_Info;

    HAPCharacteristic i1 = HAPC_Identify();
    info.addCharacteristic(i1);

    HAPCharacteristic i2 = HAPC_Manufacturer(manufacturer);
    info.addCharacteristic(i2);

    HAPCharacteristic i3 = HAPC_Model(model);
    info.addCharacteristic(i3);

    HAPCharacteristic i4 = HAPC_Name(name);
    info.addCharacteristic(i4);

    HAPCharacteristic i5 = HAPC_SerialNumber(sn);
    info.addCharacteristic(i5);

    return info;
  }
  HAPService createInfoService(string manufacturer, string model,
      string name, string sn, string fw) {

    HAPService info = createInfoService(manufacturer, model, name, sn);

    HAPCharacteristic i6 = HAPC_FirmwareRevision(fw);
    info.addCharacteristic(i6);

    return info;
  }
  uint addService(HAPService service) {
    foreach(s; services) {
      if (s.type == service.type) 
        throw new Exception("Service of given type already exists.");
    }
    service.iid = iid; iid += 1;
    for (int i = 0; i < service.chars.length; i += 1) {
      service.chars[i].iid = iid; iid += 1;
    }
    services ~= service;

    return service.iid;
  }
  uint addInfoService(string manufacturer, string model,
      string name, string sn) {
    HAPService info = createInfoService(manufacturer, model, name, sn);

    return addService(info);
  }
  uint addInfoService(string manufacturer, string model,
      string name, string sn, string fw) {
    HAPService info = createInfoService(manufacturer, model, name, sn, fw);

    return addService(info);
  }
}

