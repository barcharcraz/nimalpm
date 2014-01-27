import calpm
import os
var fakeroot = JoinPath(getCurrentDir(), "fakeroot")
var fakedb = JoinPath(fakeroot, "db")
createDir(fakeroot)
createDir(fakedb)
var errors: alpm_errno_t = ALPM_ERR_MEMORY
var handle = alpm_initialize(fakeroot, fakedb, addr errors)
if handle == nil:
  echo alpm_strerror(errors)
echo alpm_version()
var releaseval = alpm_release(handle)
if(releaseval == -1):
 echo "there was an error"
