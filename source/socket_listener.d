module custom_http;

import core.time;

import std.algorithm : remove;
import std.conv : to;
import std.digest : toHexString;
import std.socket : InternetAddress, Socket, SocketException, SocketSet, TcpSocket;
import std.stdio : writeln, writefln;

import http_util;

enum BUFF_SIZE=2048;

class ListenerSocket {
  ushort max_connections;
  TcpSocket listener;
  SocketSet socketSet;
  Socket[] reads;
  string[] addrs;

  this(ushort port, ushort max_connections = 50) {
    listener = new TcpSocket();
    assert(listener.isAlive);
    listener.blocking(false);
    listener.bind(new InternetAddress(port));
    listener.listen(10);
    // Room for listener.
    this.max_connections = max_connections;
    socketSet = new SocketSet(max_connections + 1);
  }

  void onMessage(Socket sock, string addr, char[] data) {
    // empty, should be overrided
    // sock.send("hello, whats ur name?\n");
  }
  void onConnectionClose(Socket sock, string addr) {
    // should be overrided
    writeln(addr, ": closed");
  }
  void onConnectionOpen(Socket sock, string addr) {
    // should be overrided
    writeln(addr, ": new connection");
  }

  void broadcast(char[] data) {
    foreach(sock; reads) {
      sock.send(data);
    }
  }

  void processSocket() {
    socketSet.add(listener);
    foreach (sock; reads) {
      socketSet.add(sock);
    }

    // with timeout, so, won't block
    Socket.select(socketSet, null, null, 10.msecs);

    for (size_t i = 0; i < reads.length; i++) {
      if (socketSet.isSet(reads[i])) {
        char[BUFF_SIZE] buf;
        auto datLength = reads[i].receive(buf[]);

        if (datLength == Socket.ERROR) {
          onConnectionClose(reads[i], addrs[i]);
        } else if (datLength != 0) {
          onMessage(reads[i], addrs[i], buf[0..datLength]);
          continue;
        } else {
          onConnectionClose(reads[i], addrs[i]);
        }

        // release socket resources now
        reads[i].close();

        reads = reads.remove(i);
        addrs = addrs.remove(i);
        // i will be incremented by the for, we don't want it to be.
        i--;
      }
    }

    // connection request
    if (socketSet.isSet(listener)) {
      Socket sn = null;
      scope (failure) {
        if (sn) {
          sn.close();
        }
      }
      sn = listener.accept();
      assert(sn.isAlive);
      assert(listener.isAlive);

      if (reads.length < max_connections) {
        reads ~= sn;
        auto addr = sn.remoteAddress().toString();
        addrs ~= addr;
        onConnectionOpen(sn, addr);
      } else {
        sn.close();
        assert(!sn.isAlive);
        assert(listener.isAlive);
      }
    }

    socketSet.reset();
  }
}

class CustomHTTP: ListenerSocket {
  bool[string] encMode;
  // simple constructor
  this(ushort port) {
    super(port);
  }
  public void switchToEncryptedMode(string addr) {
    encMode[addr] = true;
  }
  override void onConnectionOpen(Socket sock, string addr) {
    writeln("conn opened: ", addr);
    encMode[addr] = false;
  }
  override void onConnectionClose(Socket sock, string addr) {
    writeln("conn closed: ", addr);
    encMode.remove(addr);
  }

  // should be assigned
  public void delegate (string client_addr, 
      string status, string[string] headers, string content) onHttpRequest = null;

  public void delegate (string client_addr, ubyte[] content) onByteRequest = null;

  override void onMessage(Socket sock, string addr, char[] data) {
    writeln("message: ", data);
    if (!encMode[addr]) {
      writeln("pure http request");
      // pure http
      try {
        string status;
        string[string] headers;
        string content;

        bool decoded = decodeHTTP(cast(string)data, status, headers, content);
        if (decoded) {
          onHttpRequest(addr, status, headers, content);
        }
      } catch(Exception e) {
        // encode/decode?
      }
    } else {
      writeln("encrypted request");
      onByteRequest(addr, cast(ubyte[])data);
    }
  }

  public void sendHttpResponse(string addr, string content, string ctype) {
    string status = "HTTP/1.1 200 OK";
    string[string] headers;
    headers["Content-Type"] = ctype;
    headers["Content-Length"] = to!string(content.length);
    string message = encodeHTTP(status, headers, content);
    for (int i = 0; i < addrs.length; i += 1) {
      if (addrs[i] == addr) {
        reads[i].send(message);
        break;
      }
    }
  };
  public void sendHttpResponse(string addr, ubyte[] content, string ctype) {
    return sendHttpResponse(addr, cast(string)content, ctype);
  };
  public void sendByteResponse(string addr, ubyte[] message) {
    for (int i = 0; i < addrs.length; i += 1) {
      if (addrs[i] == addr) {
        reads[i].send(message);
        break;
      }
    }
  };
}

