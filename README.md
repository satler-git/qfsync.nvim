# qfsync.nvim

```lua
local qfsync = require("qfsync")

qfsync.add_marks() -- 要素に対応するextmarkを作成
qfsync.sync() -- extmarkから位置を復元

qfsync.sync_all() -- 上記の両方を実行
```
