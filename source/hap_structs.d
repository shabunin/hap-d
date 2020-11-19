module hap_structs;

import std.algorithm;
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

class HAPCharacteristic {
  private uint iid;
  public string type;
  public JSONValue value;
  public bool update_requested;

  public string format;
  public string description;
  public HAPPermission[] perms;
  public string toJSON() {
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
  public void delegate(JSONValue) onSet;
  public JSONValue delegate() onGet;
  public void updateValue(JSONValue newValue) {
    value = newValue;
    update_requested = true;
  }
}

class HAPService {
  private uint iid;
  private string type;
  private HAPCharacteristic[] chars;
  public string[] cRequired; // required characteristics
  public string[] cOptional; // optinal
  public string[] cPresent;  // added by user
  public string toJSON() {
    JSONValue j = parseJSON("{}");
    j["type"] = JSONValue(type);
    j["iid"] = JSONValue(iid);
    j["characteristics"] = parseJSON("[]");
    foreach(c; chars) {
      j["characteristics"].array ~= parseJSON(c.toJSON);
    }
    return j.toJSON;
  }
  public void addCharacteristic(HAPCharacteristic chr) {
    foreach(c; chars) {
      if (!cRequired.canFind(chr.type) 
          && !cOptional.canFind(chr.type)) {
        throw new Exception("Characteristic of given type is not supported by service");
      }
      if (c.type == chr.type) {
        throw new Exception("Characteristic of given type already exist.");
      }
    }
    chars ~= chr;
    cPresent ~= chr.type;
  }
  public void assertCharacteristics() {
    foreach(r; cRequired) {
      if (!cPresent.canFind(r)) {
        throw new Exception("Service should contain all required characteristics");
      }
    }
  }
  this(string type) {
    this.type = type;
  }
}

class HAPAccessory {
  public uint aid;
  private HAPService[] services;
  private uint iid = 1; // last iid
  public string toJSON() {
    JSONValue j = parseJSON("{}");
    j["aid"] = JSONValue(aid);
    j["services"] = parseJSON("[]");
    foreach(s; services) {
      j["services"].array ~= parseJSON(s.toJSON);
    }
    return j.toJSON;
  }
  public HAPService getService(uint iid) {
    foreach(s; services) {
      if (s.iid == iid) return s;
    }
    throw new Exception("Service with given iid not found.");
  }
  public HAPService getService(string type) {
    foreach(s; services) {
      if (s.type == type) return s;
    }
    throw new Exception("Service with given type not found.");
  }
  public HAPCharacteristic findCharacteristic(uint iid) {
    foreach(s; services) {
      foreach(c; s.chars) {
        if (c.iid != iid) continue;
        return c;
      }
    }
    throw new Exception("Characteristic with given iid not found");
  }
  public HAPService createInfoService(string manufacturer, string model,
      string name, string sn) {

    HAPService info = HAPS_Info();

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
  public HAPService createInfoService(string manufacturer, string model,
      string name, string sn, string fw) {

    HAPService info = createInfoService(manufacturer, model, name, sn);

    HAPCharacteristic i6 = HAPC_FirmwareRevision(fw);
    info.addCharacteristic(i6);

    return info;
  }
  public uint addService(HAPService service) {
    service.assertCharacteristics();
    foreach(s; services) {
      if (s.type == service.type) {
        throw new Exception("Service of given type already exists.");
      }
    }
    service.iid = iid; iid += 1;
    for (int i = 0; i < service.chars.length; i += 1) {
      service.chars[i].iid = iid; iid += 1;
    }
    services ~= service;

    return service.iid;
  }
  public uint addInfoService(string manufacturer, string model,
      string name, string sn) {
    HAPService info = createInfoService(manufacturer, model, name, sn);

    return addService(info);
  }
  public uint addInfoService(string manufacturer, string model,
      string name, string sn, string fw) {
    HAPService info = createInfoService(manufacturer, model, name, sn, fw);

    return addService(info);
  }
}

