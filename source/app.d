import core.thread;
import std.base64;
import std.file;
import std.functional;
import std.json;
import std.stdio;
import std.string;

import hap_structs;
import enum_characteristics;
import enum_services;
import hap_server;

void main(string[] args) {
  writeln("hello, friend\n", args);
  string iface = "";
  if (args.length > 1) {
    iface = args[1];
  }

  void onPair(ubyte[] ACC_PK, ubyte[] ACC_SK, ubyte[] iOS_PK, ubyte[] iOS_ID) {
    writeln("Bridge was paired. Saving info to file.");
    auto file = File("persist", "w");
    file.writeln(Base64.encode(ACC_PK));
    file.writeln(Base64.encode(ACC_SK));
    file.writeln(Base64.encode(iOS_PK));
    file.writeln(Base64.encode(iOS_ID));
  }

  ushort port = 45001;
  HAPServer server = new HAPServer(iface, "dbridge", "_hap._tcp", "local", port,
      "dbridge", "00:01:02:03:04:05", "111-11-111");

  server.onPair = toDelegate(&onPair);

  // read file
  if (exists("persist")) {
    auto file = File("persist", "r");
    ubyte[] ACC_PK = Base64.decode(strip(file.readln()));
    ubyte[] ACC_SK = Base64.decode(strip(file.readln()));
    ubyte[] iOS_PK = Base64.decode(strip(file.readln()));
    ubyte[] iOS_ID = Base64.decode(strip(file.readln()));
    server.setPairInfo(ACC_PK, ACC_SK, iOS_PK, iOS_ID);
  }

  // ---- LightBulb example 
  HAPAccessory lightAcc;
  lightAcc.addInfoService("Default-Manufacturer", 
      "Default-Model", "lamp+fan", "Default-SerialNumber", "0.0.1");

  // Create lightbulb service 
  HAPService lservice = HAPS_LightBulb();

  HAPCharacteristic lname = HAPC_Name("lamp");

  // On/Off characteristic
  HAPCharacteristic lon = HAPC_On();
  lon.onSet = (JSONValue value) {
    writeln("light set: ", value);
    lon.value = value;
  };
  lon.onGet = () {
    writeln("light get: ");
    return lon.value;
  };

  // Brightness 
  HAPCharacteristic lbr = HAPC_Brightness();
  lbr.onSet = (JSONValue value) {
    writeln("brightness set: ", value);
    lon.value = value;
  };
  lbr.onGet = () {
    writeln("brightness get: ");
    return lbr.value;
  };

  lservice.addCharacteristic(lname);
  lservice.addCharacteristic(lon);
  lservice.addCharacteristic(lbr); 
  lightAcc.addService(lservice);
  // ----------------------------------------

  // Now add fan service to the same accessory
  HAPService fservice = HAPS_Fan();
  HAPCharacteristic fname = HAPC_Name("fan");

  // Active (on/off)
  HAPCharacteristic factive = HAPC_Active();
  factive.onSet = (JSONValue value) {
    writeln("fan.active char set: ", value);
    factive.value = value;
  };
  factive.onGet = () {
    writeln("fan.active char get: ");
    return factive.value;
  };

  // Rotation Speed
  HAPCharacteristic fspeed = HAPC_RotationSpeed();
  fspeed.onSet = (JSONValue value) {
    writeln("fan.speed char set: ", value);
    fspeed.value = value;
  };
  fspeed.onGet = () {
    writeln("fan.speed char get");
    return fspeed.value;
  };
  fservice.addCharacteristic(fname);
  fservice.addCharacteristic(fspeed);
  fservice.addCharacteristic(factive);
  lightAcc.addService(fservice);

  // register accessory on server
  server.addAccessory(lightAcc);
  // ----------------------------------------


  // Thermostat
  HAPAccessory thermo;
  thermo.addInfoService("Default-Manufacturer", 
      "Default-Model", "thermo", "Default-SerialNumber", "0.0.1");
  HAPService tservice = HAPS_Thermostat();
  HAPCharacteristic ct = HAPC_CurrentTemperature();
  ct.value = JSONValue(28);
  ct.onGet = () {
    return ct.value;
  };
  HAPCharacteristic tt = HAPC_TargetTemperature();
  HAPCharacteristic tname = HAPC_Name("thermo");
  tt.onGet = () {
    return tt.value;
  };
  tt.onSet = (JSONValue value) {
    writeln("thermostat target temperature set: ", value);
    tt.value = value;
    if (value.type == JSONType.integer) {
      ct.value = JSONValue(value.integer - 1);
    } else if (value.type == JSONType.float_) {
      ct.value = JSONValue(value.floating - 1);
    }
  };
  HAPCharacteristic chcstate = HAPC_CurrentHeatingCoolingState();
  chcstate.onGet = () {
    return chcstate.value;
  };
  HAPCharacteristic thcstate = HAPC_TargetHeatingCoolingState();
  thcstate.onGet = () {
    return thcstate.value;
  };
  thcstate.onSet = (JSONValue value) {
    writeln("thermostat target heating cooling state set: ", value);
    thcstate.value = value;
    chcstate.value = value;
  };
  HAPCharacteristic tunits = HAPC_TemperatureDisplayUnits();
  tservice.addCharacteristic(tname);
  tservice.addCharacteristic(ct);
  tservice.addCharacteristic(tt);
  tservice.addCharacteristic(chcstate);
  tservice.addCharacteristic(thcstate);
  tservice.addCharacteristic(tunits);
  thermo.addService(tservice);
  server.addAccessory(thermo);

  // ----- main loop -----
  while(true) {
    server.loop();
    Thread.sleep(1.msecs);
  }
}
