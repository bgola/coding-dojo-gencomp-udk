
// 1. type your own user name
~user = \username;


// 2. connect to SyncText
(
~router = OSCRouterClient(~user);
~router.join;
~sync = SyncText(\dojoTest, ~router.userName, ~router);
~sync.showDoc;
)

// 3. check connectivity
~router.peers.postln;

