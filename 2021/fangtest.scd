n = NetAddr("127.0.0.1", 57120); // local machine

OSCdef(\test, {|msg, time, addr, recvPort| \unmatching.postln}, '/chat', b); // def style

m = NetAddr("192.168.0.4", 57120); // blablabla

m.sendMsg("/chat", "Hello App 1");
b = NetAddr.new("192.168.0.4", 7771);
b.sendMsg("/chat", "Hello App 1");
OSCFunc.trace(true)

b = NetAddr.new("127.0.0.1", 57120);    // create the NetAddr
b.sendMsg("/filter", "there");
OSCFunc.trace(true);

NetAddr("192.168.0.4",1337) .sendMsg('/filter',120,120)
//this is new

