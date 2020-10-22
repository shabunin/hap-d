# hap-d

Working at moment:
 - mdns service advertising
 - pairing procedure
 - saving iOS id and keys
 - GET /accessories
 - GET /characteristics
 - PUT /characteristics
 - events from accessory to iOS
 - service/characteristics enumeration
 - sample lightbulb/fan accessory
 - sample thermostat

A lot of stuff I ported from other open-source projects.

TODO:
- Improve code quality.

# References

Works and specs I was guided by:

## mdns:

1. https://github.com/futomi/node-dns-sd
2. https://github.com/hashicorp/mdns
3. https://tools.ietf.org/html/rfc1035
4. https://tools.ietf.org/html/rfc6763

## HAP

1. https://github.com/homebridge/HAP-NodeJS/blob/master/src/lib/HAPServer.ts
2. https://github.com/ikalchev/HAP-python/blob/dev/pyhap/hap\_server.py

## Dependencies

1. libsodium

