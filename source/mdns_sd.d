module mdns_sd;

import std.algorithm: canFind, remove;
import std.bitmanip;
import std.conv;
import std.stdio;
import std.socket;

import std.datetime.stopwatch : StopWatch;

import core.thread;
import core.sys.linux.ifaddrs;
import core.sys.linux.sys.socket;
import core.sys.linux.netinet.in_ : IP_ADD_MEMBERSHIP, IP_MULTICAST_LOOP;
import core.sys.posix.netdb;
import core.sys.posix.netinet.in_;

import dns;

struct MdnsService {
  string instance;
  string service;
  string domain;
  string hostname;
  ushort port;
  string[string] txt;

  string instanceAddr; // "Lightbulb 1._hap._tcp.local"
  string serviceAddr; // "_hap._tcp.local"
  string enumAddr; // "_services._dns-sd._udp.local"
}

class DnsSD {
  Socket sock;
  Address[] addrs;
  Address addr;
  string[] ip_v4;


  this(string iface, string multicastGroupIP = "224.0.0.251", ushort port = 5353) {
    sock = new UdpSocket(AddressFamily.INET);
    sock.blocking = false;
    // detect ip address of iface
    string localHost = "";

    ifaddrs *ifaddr;
    ifaddrs *ifa;
    int family, s;

    if (getifaddrs(&ifaddr) == -1) {
      writeln("getifaddrs");
    }
    for (ifa = ifaddr; ifa != null; ifa = ifa.ifa_next) {
      if (ifa.ifa_addr == null) {
        continue;
      }
      auto host = new char[NI_MAXHOST];
      s=getnameinfo(ifa.ifa_addr,
          sockaddr_in.sizeof,
          host.ptr,
          NI_MAXHOST,
          null,
          0,
          NI_NUMERICHOST);
      if (s == 0) {
        string ifaceStr = "";
        auto i = ifa.ifa_name;
        while(*i) {
          ifaceStr ~= *i;
          i+= 1;
        }
        int hlen;
        for (int ci = 0; ci < host.length; ci += 1) {
          if (host[ci] != cast(char) 0x00) continue;
          hlen = ci; break;
        }
        string hostStr = cast(string) host;
        hostStr.length = hlen;
        writeln("host: ", hostStr);
        if (iface == "" && hostStr != "127.0.0.1") {
          ip_v4 ~= hostStr;
        }
        writeln("iface: ", ifaceStr);
        if (ifaceStr == iface) {
          localHost = hostStr;
          ip_v4 ~= localHost;
        }
      }
    }

    InternetAddress localAddress;
    if (localHost != "") {
      localAddress = new InternetAddress(localHost, port);

    } else {
      localAddress = new InternetAddress(port);
    }
    writeln("local host: ", localHost);
    InternetAddress multicastGroupAddr = new InternetAddress(multicastGroupIP, port);

    struct ip_mreq {
      in_addr imr_multiaddr;   /* IP multicast address of group */
      in_addr imr_interface;   /* local IP address of interface */
    }
    ip_mreq addRequest;
    sockaddr_in local_sockaddr_in = cast(sockaddr_in)(*localAddress.name);
    sockaddr_in multi_sockaddr_in = cast(sockaddr_in)(*multicastGroupAddr.name);

    addRequest.imr_multiaddr = multi_sockaddr_in.sin_addr;
    addRequest.imr_interface = local_sockaddr_in.sin_addr;

    auto optionValue = (cast(char*)&addRequest)[0.. ip_mreq.sizeof];
    sock.setOption(SocketOptionLevel.IP,
        cast(SocketOption)IP_ADD_MEMBERSHIP, optionValue);
    addrs = getAddress(multicastGroupIP, port);
    addr = addrs[0];
    if (iface != "") {
      sock.setOption(SocketOptionLevel.SOCKET,
          cast(SocketOption)SO_BINDTODEVICE, cast(void[])iface);
      auto anyAddrs = getAddress("0.0.0.0", port);
      auto anyAddr = anyAddrs[0];
      sock.bind(anyAddr);
    } else {
      sock.bind(addr);
    }
  }

  // =========== //
  MdnsService[] services;
  public ushort ttl = 120;
  public ushort priority = 10;
  public ushort weight = 10;
  // =========== //

  private void sendRecord(Record record) {
    ubyte[] result = serializeRR(record);

    sock.sendTo(result, addr);
  }
  private Record processQuestions(Record record) {
    Record response;
    response.header.response = true;
    response.header.authoritative = true;

    for(int qi = 0; qi < record.questions.length; qi += 1) {
      RecordQuestion q = record.questions[qi];
      // find registered service 
      string ql = q.label;
      int[] idx;
      for(int i = 0; i < services.length; i += 1) {
        MdnsService ms = services[i];
        if (ms.instanceAddr == ql ||
            ms.serviceAddr == ql ||
            ms.enumAddr == ql) {
          // what if there is multiple services?
          idx ~= i;
        }
      }
      // found nothing - break
      if (idx.length == 0) break;

      MdnsService ms = services[idx[0]];

      // for each query type return correct result
      if (ms.instanceAddr == ql) {
        // "light bulb._hap._tcp.local"
        RecordResponse rr;
        switch(q.record_type) {
          case RecordTypes.any:
            // return SRV
            RecordResponse rs;
            rs.label = ql;
            rs.record_type = RecordTypes.srv;
            rs.record_class = RecordClasses.int_;
            rs.ttl = ttl;
            rs.rdata.priority = priority;
            rs.rdata.weight = weight;
            rs.rdata.port = ms.port;
            rs.rdata.data = ms.hostname;
            response.answers ~= rs;
            // and A record
            for (int i = 0; i < ip_v4.length; i += 1) {
              RecordResponse ra;
              ra.label = ms.hostname;
              ra.record_type = RecordTypes.a;
              ra.record_class = RecordClasses.int_;
              ra.ttl = ttl;
              ra.rdata.data = ip_v4[i];
              response.answers ~= ra;
            }
            break;
          case RecordTypes.srv:
            // srv record with hostname as a target
            rr.label = ql;
            rr.record_type = RecordTypes.srv;
            rr.record_class = RecordClasses.int_;
            rr.ttl = ttl;
            rr.rdata.priority = priority;
            rr.rdata.weight = weight;
            rr.rdata.port = ms.port;
            rr.rdata.data = ms.hostname;
            response.answers ~= rr;
            break;
          case RecordTypes.a:
            // return ip addr
            for (int i = 0; i < ip_v4.length; i += 1) {
              RecordResponse ra;
              ra.label = ql;
              ra.record_type = RecordTypes.a;
              ra.record_class = RecordClasses.int_;
              ra.ttl = ttl;
              ra.rdata.data = ip_v4[i];
              response.answers ~= ra;
            }
            break;
          case RecordTypes.txt:
            // return txt record
            rr.label = ql;
            rr.record_type = RecordTypes.txt;
            rr.record_class = RecordClasses.int_;
            rr.ttl = ttl;
            foreach (t; ms.txt.keys) {
              rr.rdata.data ~= t ~ "="~ ms.txt[t] ~ "\n";
            }
            response.answers ~= rr;
            break;
          default:
            break;
        }
      } else if (ms.serviceAddr == ql) {
        // "_hap._tcp.local"
        if (q.record_type != RecordTypes.any &&
            q.record_type != RecordTypes.ptr) {
          continue;
        }
        // find all services and return PTR records
        for (int i = 0; i < idx.length; i += 1) {
          int j = idx[i];
          ms = services[j];
          if (ms.serviceAddr != ql) {
            continue;
          }
          RecordResponse rp;
          rp.label = ql;
          rp.record_type = RecordTypes.ptr;
          rp.record_class = RecordClasses.int_;
          rp.ttl = ttl;
          rp.rdata.data = ms.instanceAddr;
          response.answers ~= rp;
          // return SRV
          RecordResponse rs;
          rs.label = ms.instanceAddr;
          rs.record_type = RecordTypes.srv;
          rs.record_class = RecordClasses.int_;
          rs.ttl = ttl;
          rs.rdata.priority = priority;
          rs.rdata.weight = weight;
          rs.rdata.port = ms.port;
          rs.rdata.data = ms.hostname;
          response.answers ~= rs;
          // and A record
          for (int k = 0; k < ip_v4.length; k += 1) {
            RecordResponse ra;
            ra.label = ms.hostname;
            ra.record_type = RecordTypes.a;
            ra.record_class = RecordClasses.int_;
            ra.ttl = ttl;
            ra.rdata.data = ip_v4[k];
            response.answers ~= ra;
          }
        }
      } else if (ms.enumAddr == ql) {
        // "_services._dns-sd._udp.local"
        if (q.record_type != RecordTypes.any &&
            q.record_type != RecordTypes.ptr) {
          continue;
        }
        string[] servicesUniq;
        for(int i = 0; i < services.length; i += 1) {
          string sn = services[i].serviceAddr;
          if (servicesUniq.canFind(sn)) {
            continue;
          }

          servicesUniq ~= sn;
        }
        // return PTR records for all found services
        foreach(sn; servicesUniq) {
          RecordResponse rr;
          rr.label = ql;
          rr.record_type = RecordTypes.ptr;
          rr.record_class = RecordClasses.int_;
          rr.ttl = ttl;
          rr.rdata.data = sn;
          response.answers ~= rr;
        }
      }
    }

    response.header.answers = to!ushort(response.answers.length);
    if (response.header.answers > 0) {
      response.valid = true;
    }

    return response;
  }
  public void processMessages() {
    ubyte[] buf;
    buf.length = 1024;
    auto receivedLen = sock.receive(buf);
    if(receivedLen > 0) {
      buf.length = receivedLen;

      Record msg;
      // sometimes parsing record goes wrong
      // and it throws out of range errors
      // in this case just ignore it and work next
      try {
        msg = parseRR(buf);
      } catch(Exception e) {
        return;
      } catch (Error e) {
        return;
      }

      if (msg.questions.length > 0) {
        Record res = processQuestions(msg);
        if (res.valid) {
          sendRecord(res);
        }
      }
    }
  }
  public int registerService(
      string instance, string service, string domain,
      string hostname, ushort port, string[string] txt) {

    writeln("registering service advertising: ");
    writeln(instance ~ "." ~ service ~ "." ~ domain);
    MdnsService ms;
    ms.instance = instance;
    ms.service = service;
    ms.domain = domain;
    ms.hostname = hostname;
    ms.port = port;
    //ms.ip_v4 = ip_v4[0];
    ms.txt = txt;

    // "Lightbulb 1._hap._tcp.local"
    ms.instanceAddr = instance ~ "." ~ service ~ "." ~ domain; 
    // "_hap._tcp.local"
    ms.serviceAddr = service ~ "." ~ domain; 
    // "_services._dns-sd._udp.local"
    ms.enumAddr = "_services._dns-sd._udp." ~ domain; 

    services ~= ms;

    return to!int(services.length - 1);
  }
  public void unregisterService(int index) {
    services = services.remove(index);
  };
  public void setTxtRecord(int index, string[string] txt) {
    services[index].txt = txt;
  }
  public void publish(int idx) {
    Record rr;

    RecordQuestion rqp;
    rqp.record_type = RecordTypes.ptr;
    rqp.label = services[idx].serviceAddr;
    rr.questions ~= rqp;

    RecordQuestion rqt;
    rqt.record_type = RecordTypes.txt;
    rqt.label = services[idx].instanceAddr;
    rr.questions ~= rqt;

    rr.header.questions = to!ushort(rr.questions.length);

    Record res = processQuestions(rr);
    if (res.valid) {
      sendRecord(res);
    }
  }
}
