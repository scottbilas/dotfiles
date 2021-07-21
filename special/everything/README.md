# Installation

* `scoop install everything`
* `scoop hold everything`
* `everything`
* Select "install the Everything service" and continue
* Ctrl-P to go into options
  * General/UI -> check "Store settings and data in %APPDATA%\Everything"
  * Also check "Start Everything on system startup"
* Exit fully and `sudo stop-service everything`
* `copy ~\dotfiles\special\everything\Everything.ini $env:appdata\Everything\`
* `sudo start-service everything` also start Everything
* Ctrl-P back to options and fix _NTFS_ and _Folders_
