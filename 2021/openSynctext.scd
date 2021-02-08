~user = \fang;

~router = OSCRouterClient(~user);

~router.join

~sync = SyncText(\dojoTest, ~router.userName, ~router)

~sync.showDoc





