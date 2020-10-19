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

/*=============================*/

enum : HAPService {
  HAPS_HapProtocolInfo = HAPService("A2"),
  HAPS_Info = HAPService("3E"),
  HAPS_LightBulb = HAPService("43"),
}

/*=============================*/

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
  c.type = "08";
  c.format = "int";
  c.value = JSONValue(0);
  c.perms = [HAPPermission.PAIRED_READ, 
             HAPPermission.PAIRED_WRITE,
             HAPPermission.EVENTS];
  c.description = "Brightness";

  return c;
}

/*=============================*/

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
  void delegate(JSONValue) onSet;
  JSONValue delegate() onGet;
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
  void addCharacteristic(HAPCharacteristic chr) {
    foreach(c; chars) {
      if (c.type == chr.type) 
        throw new Exception("Characteristic of given type already exist.");
    }
    chars ~= chr;
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

