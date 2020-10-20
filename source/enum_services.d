module enum_services;

import hap_structs;

enum : HAPService {
  HAPS_HapProtocolInfo = HAPService("A2"),
  HAPS_Info = HAPService("3E"),
  HAPS_LightBulb = HAPService("43"),
  HAPS_Fan = HAPService("B7"),
}
