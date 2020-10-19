import core.thread;
import std.base64;
import std.file;
import std.functional;
import std.json;
import std.stdio;
import std.string;

import accessories;
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

  // lightbulb
  HAPAccessory lightAcc;
  lightAcc.addInfoService("Default-Manufacturer", 
      "Default-Model", "lamp", "Default-SerialNumber", "0.0.1");

  HAPService lservice = HAPS_LightBulb;

  HAPCharacteristic lname = HAPC_Name("lamp");
  lservice.addCharacteristic(lname);

  HAPCharacteristic lon = HAPC_On();
  lon.onSet = (JSONValue value) {
    writeln("light set: ", value);
    lon.value = value;
  };
  lon.onGet = () {
    writeln("light get: ");
    return lon.value;
  };
  lservice.addCharacteristic(lon);

  /* TODO: add support for brightness
  HAPCharacteristic lbr = HAPC_Brightness();
  lbr.onSet = (JSONValue value) {
    writeln("brightness set: ", value);
    lon.value = value;
  };
  lbr.onGet = () {
    writeln("brightness get: ");
    return lbr.value;
  };
  lservice.addCharacteristic(lbr); */

  lightAcc.addService(lservice);
  server.addAccessory(lightAcc);

  // --------------- //
  while(true) {
    server.loop();
    Thread.sleep(1.msecs);
  }
}
