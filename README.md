# WindowsShareMigration


Powershell scripts to help move local file shares.

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

