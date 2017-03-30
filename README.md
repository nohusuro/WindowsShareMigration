# WindowsShareMigration


Powershell scripts to help move local file shares.

I wrote this script to aid in moving file data, security permissions and file share configuration between two drives on the same file server where DFS was not configured.

When migrating, 3 of 25 shares did not successfully migrate the share configuration. I can only assume this was due to file locks on the original share causing the original share not to be deleted before trying to create it. To reduce possible failures, make sure no one is using the share when you move it.

This script is provided as is, without warranty, I accept no liability if it goes wrong.

## Installation


The module needs to be added to one of the directories in your PSModulePath Environment Variable.

It is recommended to create a separate module path and add that to your environment variable, then place the module here.

## Examples

### Moving a single none-nested share


ShareName | OriginalSharePath | NewSharePath
---|---|---
SourceCode | D:\Shares\SourceCode | E:\Shares\SourceCode

1. ```Import-Module MoveLocalShare```
2. ```MoveLocalShare -SourceShareName "SourceCode" -DestSharePath "E:\Shares\SourceCode"```


### Moving a nested share (share within a share)


ShareName | OriginalSharePath | NewSharePath
---|---|---
Documents | D:\Shares\Documents | E:\Shares\Documents
AccountsDocuments | D:\Shares\Documents\Accounts | E:\Shares\Documents\Accounts

1. ```Import-Module MoveLocalShare```
2. ```MoveLocalShare -SourceShareName "Documents" -DestSharePath "E:\Shares\Documents"```
3. ```MoveLocalShare -SourceShareName "AccountsDocuments" -DestSharePath "E:\Shares\Documents\Accounts"```

