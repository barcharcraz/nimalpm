#
#  alpm.h
# 
#   Copyright (c) 2006-2014 Pacman Development Team <pacman-dev@archlinux.org>
#   Copyright (c) 2002-2006 by Judd Vinet <jvinet@zeroflux.org>
#   Copyright (c) 2005 by Aurelien Foret <orelien@chez.com>
#   Copyright (c) 2005 by Christian Hamar <krics@linuxforum.hu>
#   Copyright (c) 2005, 2006 by Miklos Vajna <vmiklos@frugalware.org>
# 
#   This program is free software; you can redistribute it and/or depmodify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
# 
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
# 
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
import posix
when defined(windows):
  const dllname = "alpm.dll"
else:
  const dllname = "libalpm.so"
# libarchive 
#
#  Arch Linux Package Management library
# 
#* @addtogroup alpm_api Public API
#  The libalpm Public API
#  @{
# 
type 
  alpm_time_t* = int64
type alpm_list_t = object
type off_t = TOff
type mode_t = TMode
type size_t = csize
type va_list {.importc: "va_list", header:"<stdarg.h>".} = int
type archive = object
type archive_entry = object
#
#  Enumerations
#  These ones are used in multiple contexts, so are forward-declared.
# 
#* Package install reasons. 
type                        #* Explicitly requested by the user. 
  alpm_pkgreason_t* {.size: sizeof(cint).} = enum 
    ALPM_PKG_REASON_EXPLICIT = 0, #* Installed as a dependency for another package. 
    ALPM_PKG_REASON_DEPEND = 1
#* Location a package object was loaded from. 
type 
  alpm_pkgfrom_t* {.size: sizeof(cint).} = enum 
    ALPM_PKG_FROM_FILE = 1, ALPM_PKG_FROM_LOCALDB, ALPM_PKG_FROM_SYNCDB
#* Method used to validate a package. 
type 
  alpm_pkgvalidation_t* {.size: sizeof(cint).} = enum 
    ALPM_PKG_VALIDATION_UNKNOWN = 0, ALPM_PKG_VALIDATION_NONE = (1 shl 0), 
    ALPM_PKG_VALIDATION_MD5SUM = (1 shl 1), 
    ALPM_PKG_VALIDATION_SHA256SUM = (1 shl 2), 
    ALPM_PKG_VALIDATION_SIGNATURE = (1 shl 3)
#* Types of version constraints in dependency specs. 
type                        #* No version constraint 
  alpm_depmod_t* {.size: sizeof(cint).} = enum 
    ALPM_DEP_MOD_ANY = 1,   #* Test version equality (package=x.y.z) 
    ALPM_DEP_MOD_EQ,        #* Test for at least a version (package>=x.y.z) 
    ALPM_DEP_MOD_GE,        #* Test for at most a version (package<=x.y.z) 
    ALPM_DEP_MOD_LE,        #* Test for greater than some version (package>x.y.z) 
    ALPM_DEP_MOD_GT,        #* Test for less than some version (package<x.y.z) 
    ALPM_DEP_MOD_LT
#*
#  File conflict type.
#  Whether the conflict results from a file existing on the filesystem, or with
#  another target in the transaction.
# 
type 
  alpm_fileconflicttype_t* {.size: sizeof(cint).} = enum 
    ALPM_FILECONFLICT_TARGET = 1, ALPM_FILECONFLICT_FILESYSTEM
#* PGP signature verification options 
type 
  alpm_siglevel_t* {.size: sizeof(cint).} = enum 
    ALPM_SIG_PACKAGE = (1 shl 0), ALPM_SIG_PACKAGE_OPTIONAL = (1 shl 1), 
    ALPM_SIG_PACKAGE_MARGINAL_OK = (1 shl 2), 
    ALPM_SIG_PACKAGE_UNKNOWN_OK = (1 shl 3), ALPM_SIG_DATABASE = (1 shl 10), 
    ALPM_SIG_DATABASE_OPTIONAL = (1 shl 11), 
    ALPM_SIG_DATABASE_MARGINAL_OK = (1 shl 12), 
    ALPM_SIG_DATABASE_UNKNOWN_OK = (1 shl 13), 
    ALPM_SIG_PACKAGE_SET = (1 shl 27), 
    ALPM_SIG_PACKAGE_TRUST_SET = (1 shl 28), ALPM_SIG_USE_DEFAULT = (1 shl
        31)
#* PGP signature verification status return codes 
type 
  alpm_sigstatus_t* {.size: sizeof(cint).} = enum 
    ALPM_SIGSTATUS_VALID, ALPM_SIGSTATUS_KEY_EXPIRED, 
    ALPM_SIGSTATUS_SIG_EXPIRED, ALPM_SIGSTATUS_KEY_UNKNOWN, 
    ALPM_SIGSTATUS_KEY_DISABLED, ALPM_SIGSTATUS_INVALID
#* PGP signature verification status return codes 
type 
  alpm_sigvalidity_t* {.size: sizeof(cint).} = enum 
    ALPM_SIGVALIDITY_FULL, ALPM_SIGVALIDITY_MARGINAL, ALPM_SIGVALIDITY_NEVER, 
    ALPM_SIGVALIDITY_UNKNOWN
#
#  Structures
#
type internal_alpm_handle_t = object
type internal_alpm_db_t = object
type internal_alpm_pkg_t = object
type internal_alpm_trans_t = object 
type 
  alpm_handle_t* = internal_alpm_handle_t
  alpm_db_t* = internal_alpm_db_t
  alpm_pkg_t* = internal_alpm_pkg_t
  alpm_trans_t* = internal_alpm_trans_t
#* Dependency 
type 
  alpm_depend_t* {.pure, final.} = object 
    name*: cstring
    version*: cstring
    desc*: cstring
    name_hash*: culong
    depmod*: alpm_depmod_t

#* Missing dependency 
type 
  alpm_depmissing_t* {.pure, final.} = object 
    target*: cstring
    depend*: ptr alpm_depend_t # this is used only in the case of a remove dependency error 
    causingpkg*: cstring

#* Conflict 
type 
  alpm_conflict_t* {.pure, final.} = object 
    package1_hash*: culong
    package2_hash*: culong
    package1*: cstring
    package2*: cstring
    reason*: ptr alpm_depend_t

#* File conflict 
type 
  alpm_fileconflict_t* {.pure, final.} = object 
    target*: cstring
    conflict_type*: alpm_fileconflicttype_t
    file*: cstring
    ctarget*: cstring

#* Package group 
type 
  alpm_group_t* {.pure, final.} = object 
    name*: cstring          #* group name 
    packages*: ptr alpm_list_t #list of alpm packages

#* Package upgrade delta 
type 
  alpm_delta_t* {.pure, final.} = object 
    delta*: cstring         #* filename of the delta patch 
    delta_md5*: cstring     #* filename of the 'before' file 
    fromname*: cstring          #* filename of the 'after' file 
    toname*: cstring            #* filesize of the delta file 
    delta_size*: off_t      #* download filesize of the delta file 
    download_size*: off_t

#* File in a package 
type 
  alpm_file_t* {.pure, final.} = object 
    name*: cstring
    size*: off_t
    depmode*: mode_t

#* Package filelist container 
type 
  alpm_filelist_t* {.pure, final.} = object 
    count*: size_t
    files*: ptr alpm_file_t

#* Local package or package file backup entry 
type 
  alpm_backup_t* {.pure, final.} = object 
    name*: cstring
    hash*: cstring

  alpm_pgpkey_t* {.pure, final.} = object 
    data*: pointer
    fingerprint*: cstring
    uid*: cstring
    name*: cstring
    email*: cstring
    created*: alpm_time_t
    expires*: alpm_time_t
    length*: cuint
    revoked*: cuint
    pubkey_algo*: char

#*
#  Signature result. Contains the key, status, and validity of a given
#  signature.
# 
type 
  alpm_sigresult_t* {.pure, final.} = object 
    key*: alpm_pgpkey_t
    status*: alpm_sigstatus_t
    validity*: alpm_sigvalidity_t

#*
#  Signature list. Contains the number of signatures found and a pointer to an
#  array of results. The array is of size count.
# 
type 
  alpm_siglist_t* {.pure, final.} = object 
    count*: size_t
    results*: ptr alpm_sigresult_t

#
#  Logging facilities
# 
#* Logging Levels 
type 
  alpm_loglevel_t* {.size: sizeof(cint).} = enum 
    ALPM_LOG_ERROR = 1, ALPM_LOG_WARNING = (1 shl 1), 
    ALPM_LOG_DEBUG = (1 shl 2), ALPM_LOG_FUNCTION = (1 shl 3)
  alpm_cb_log* = proc (a2: alpm_loglevel_t; a3: cstring; a4: va_list)
proc alpm_logaction*(handle: ptr alpm_handle_t; prefix: cstring; fmt: cstring): cint {.varargs, cdecl, dynlib:dllname, importc.}
#*
#  Events.
#  NULL parameters are passed to in all events unless specified otherwise.
# 
type                        #* Dependencies will be computed for a package. 
  alpm_event_t* {.size: sizeof(cint).} = enum 
    ALPM_EVENT_CHECKDEPS_START = 1, #* Dependencies were computed for a package. 
    ALPM_EVENT_CHECKDEPS_DONE, #* File conflicts will be computed for a package. 
    ALPM_EVENT_FILECONFLICTS_START, #* File conflicts were computed for a package. 
    ALPM_EVENT_FILECONFLICTS_DONE, #* Dependencies will be resolved for target package. 
    ALPM_EVENT_RESOLVEDEPS_START, #* Dependencies were resolved for target package. 
    ALPM_EVENT_RESOLVEDEPS_DONE, #* Inter-conflicts will be checked for target package. 
    ALPM_EVENT_INTERCONFLICTS_START, #* Inter-conflicts were checked for target package. 
    ALPM_EVENT_INTERCONFLICTS_DONE, #* Package will be installed.
                                    #   A pointer to the target package is passed to the callback.
                                    #  
    ALPM_EVENT_ADD_START, #* Package was installed.
                          #   A pointer to the new package is passed to the callback.
                          #  
    ALPM_EVENT_ADD_DONE, #* Package will be removed.
                         #   A pointer to the target package is passed to the callback.
                         #  
    ALPM_EVENT_REMOVE_START, #* Package was removed.
                             #   A pointer to the removed package is passed to the callback.
                             #  
    ALPM_EVENT_REMOVE_DONE, #* Package will be upgraded.
                            #   A pointer to the upgraded package is passed to the callback.
                            #  
    ALPM_EVENT_UPGRADE_START, #* Package was upgraded.
                              #   A pointer to the new package, and a pointer to the old package is passed
                              #   to the callback, respectively.
                              #  
    ALPM_EVENT_UPGRADE_DONE, #* Package will be downgraded.
                             #   A pointer to the downgraded package is passed to the callback.
                             #  
    ALPM_EVENT_DOWNGRADE_START, #* Package was downgraded.
                                #   A pointer to the new package, and a pointer to the old package is passed
                                #   to the callback, respectively.
                                #  
    ALPM_EVENT_DOWNGRADE_DONE, #* Package will be reinstalled.
                               #   A pointer to the reinstalled package is passed to the callback.
                               #  
    ALPM_EVENT_REINSTALL_START, #* Package was reinstalled.
                                #   A pointer to the new package, and a pointer to the old package is passed
                                #   to the callback, respectively.
                                #  
    ALPM_EVENT_REINSTALL_DONE, #* Target package's integrity will be checked. 
    ALPM_EVENT_INTEGRITY_START, #* Target package's integrity was checked. 
    ALPM_EVENT_INTEGRITY_DONE, #* Target package will be loaded. 
    ALPM_EVENT_LOAD_START,  #* Target package is finished loading. 
    ALPM_EVENT_LOAD_DONE,   #* Target delta's integrity will be checked. 
    ALPM_EVENT_DELTA_INTEGRITY_START, #* Target delta's integrity was checked. 
    ALPM_EVENT_DELTA_INTEGRITY_DONE, #* Deltas will be applied to packages. 
    ALPM_EVENT_DELTA_PATCHES_START, #* Deltas were applied to packages. 
    ALPM_EVENT_DELTA_PATCHES_DONE, #* Delta patch will be applied to target package.
                                   #   The filename of the package and the filename of the patch is passed to the
                                   #   callback.
                                   #  
    ALPM_EVENT_DELTA_PATCH_START, #* Delta patch was applied to target package. 
    ALPM_EVENT_DELTA_PATCH_DONE, #* Delta patch failed to apply to target package. 
    ALPM_EVENT_DELTA_PATCH_FAILED, #* Scriptlet has printed information.
                                   #   A line of text is passed to the callback.
                                   #  
    ALPM_EVENT_SCRIPTLET_INFO, #* Files will be downloaded from a repository.
                               #   The repository's tree name is passed to the callback.
                               #  
    ALPM_EVENT_RETRIEVE_START, #* Disk space usage will be computed for a package 
    ALPM_EVENT_DISKSPACE_START, #* Disk space usage was computed for a package 
    ALPM_EVENT_DISKSPACE_DONE, #* An optdepend for another package is being removed
                               #   The requiring package and its dependency are passed to the callback 
    ALPM_EVENT_OPTDEP_REQUIRED, #* A configured repository database is missing 
    ALPM_EVENT_DATABASE_MISSING, #* Checking keys used to create signatures are in keyring. 
    ALPM_EVENT_KEYRING_START, #* Keyring checking is finished. 
    ALPM_EVENT_KEYRING_DONE, #* Downloading missing keys into keyring. 
    ALPM_EVENT_KEY_DOWNLOAD_START, #* Key downloading is finished. 
    ALPM_EVENT_KEY_DOWNLOAD_DONE
#* Event callback 
type 
  alpm_cb_event* = proc (a2: alpm_event_t; a3: pointer; a4: pointer)
#*
#  Questions.
#  Unlike the events or progress enumerations, this enum has bitmask values
#  so a frontend can use a bitmask map to supply preselected answers to the
#  different types of questions.
# 
type 
  alpm_question_t* {.size: sizeof(cint).} = enum 
    ALPM_QUESTION_INSTALL_IGNOREPKG = 1, 
    ALPM_QUESTION_REPLACE_PKG = (1 shl 1), 
    ALPM_QUESTION_CONFLICT_PKG = (1 shl 2), 
    ALPM_QUESTION_CORRUPTED_PKG = (1 shl 3), 
    ALPM_QUESTION_REMOVE_PKGS = (1 shl 4), 
    ALPM_QUESTION_SELECT_PROVIDER = (1 shl 5), 
    ALPM_QUESTION_IMPORT_KEY = (1 shl 6)
#* Question callback 
type 
  alpm_cb_question* = proc (a2: alpm_question_t; a3: pointer; a4: pointer; 
                            a5: pointer; a6: ptr cint)
#* Progress 
type 
  alpm_progress_t* {.size: sizeof(cint).} = enum 
    ALPM_PROGRESS_ADD_START, ALPM_PROGRESS_UPGRADE_START, 
    ALPM_PROGRESS_DOWNGRADE_START, ALPM_PROGRESS_REINSTALL_START, 
    ALPM_PROGRESS_REMOVE_START, ALPM_PROGRESS_CONFLICTS_START, 
    ALPM_PROGRESS_DISKSPACE_START, ALPM_PROGRESS_INTEGRITY_START, 
    ALPM_PROGRESS_LOAD_START, ALPM_PROGRESS_KEYRING_START
#* Progress callback 
type 
  alpm_cb_progress* = proc (a2: alpm_progress_t; a3: cstring; a4: cint; 
                            a5: size_t; a6: size_t)
#
#  Downloading
# 
#* Type of download progress callbacks.
#  @param filename the name of the file being downloaded
#  @param xfered the number of transferred bytes
#  @param total the total number of bytes to transfer
# 
type 
  alpm_cb_download* = proc (filename: cstring; xfered: off_t; total: off_t)
  alpm_cb_totaldl* = proc (total: off_t)
#* A callback for downloading files
#  @param url the URL of the file to be downloaded
#  @param localpath the directory to which the file should be downloaded
#  @param force whether to force an update, even if the file is the same
#  @return 0 on success, 1 if the file exists and is identical, -1 on
#  error.
# 
type 
  alpm_cb_fetch* = proc (url: cstring; localpath: cstring; force: cint): cint
#* Fetch a remote pkg.
#  @param handle the context handle
#  @param url URL of the package to download
#  @return the downloaded filepath on success, NULL on error
#
proc alpm_fetch_pkgurl*(handle: ptr alpm_handle_t; url: cstring): cstring
   {.cdecl, dynlib:dllname, importc.}
#* @addtogroup alpm_api_options Options
#  Libalpm option getters and setters
#  @{
# 
#* Returns the callback used for logging. 
proc alpm_option_get_logcb*(handle: ptr alpm_handle_t): alpm_cb_log {.cdecl, dynlib:dllname, importc.}
#* Sets the callback used for logging. 
proc alpm_option_set_logcb*(handle: ptr alpm_handle_t; cb: alpm_cb_log): cint {.cdecl, dynlib:dllname, importc.}
#* Returns the callback used to report download progress. 
proc alpm_option_get_dlcb*(handle: ptr alpm_handle_t): alpm_cb_download {.cdecl, dynlib:dllname, importc.}
#* Sets the callback used to report download progress. 
proc alpm_option_set_dlcb*(handle: ptr alpm_handle_t; cb: alpm_cb_download): cint {.cdecl, dynlib:dllname, importc.}
#* Returns the downloading callback. 
proc alpm_option_get_fetchcb*(handle: ptr alpm_handle_t): alpm_cb_fetch {.cdecl, dynlib:dllname, importc.}
#* Sets the downloading callback. 
proc alpm_option_set_fetchcb*(handle: ptr alpm_handle_t; cb: alpm_cb_fetch): cint {.cdecl, dynlib:dllname, importc.}
#* Returns the callback used to report total download size. 
proc alpm_option_get_totaldlcb*(handle: ptr alpm_handle_t): alpm_cb_totaldl {.cdecl, dynlib:dllname, importc.}
#* Sets the callback used to report total download size. 
proc alpm_option_set_totaldlcb*(handle: ptr alpm_handle_t; cb: alpm_cb_totaldl): cint {.cdecl, dynlib:dllname, importc.}
#* Returns the callback used for events. 
proc alpm_option_get_eventcb*(handle: ptr alpm_handle_t): alpm_cb_event {.cdecl, dynlib:dllname, importc.}
#* Sets the callback used for events. 
proc alpm_option_set_eventcb*(handle: ptr alpm_handle_t; cb: alpm_cb_event): cint {.cdecl, dynlib:dllname, importc.}
#* Returns the callback used for questions. 
proc alpm_option_get_questioncb*(handle: ptr alpm_handle_t): alpm_cb_question {.cdecl, dynlib:dllname, importc.}
#* Sets the callback used for questions. 
proc alpm_option_set_questioncb*(handle: ptr alpm_handle_t, cb: alpm_cb_question): cint {.cdecl, dynlib:dllname, importc.}
#* Returns the callback used for operation progress. 
proc alpm_option_get_progresscb*(handle: ptr alpm_handle_t): alpm_cb_progress {.cdecl, dynlib:dllname, importc.}
#* Sets the callback used for operation progress. 
proc alpm_option_set_progresscb*(handle: ptr alpm_handle_t; cb: alpm_cb_progress): cint {.cdecl, dynlib:dllname, importc.}
#* Returns the root of the destination filesystem. Read-only. 
proc alpm_option_get_root*(handle: ptr alpm_handle_t): cstring {.cdecl, dynlib:dllname, importc.}
#* Returns the path to the database directory. Read-only. 
proc alpm_option_get_dbpath*(handle: ptr alpm_handle_t): cstring {.cdecl, dynlib:dllname, importc.}
#* Get the name of the database lock file. Read-only. 
proc alpm_option_get_lockfile*(handle: ptr alpm_handle_t): cstring {.cdecl, dynlib:dllname, importc.}
#* @name Accessors to the list of package cache directories.
#  @{
# 
proc alpm_option_get_cachedirs*(handle: ptr alpm_handle_t): ptr alpm_list_t {.cdecl, dynlib:dllname, importc.}
proc alpm_option_set_cachedirs*(handle: ptr alpm_handle_t, cachedirs: ptr alpm_list_t): cint {.cdecl, dynlib:dllname, importc.}
proc alpm_option_add_cachedir*(handle: ptr alpm_handle_t; cachedir: cstring): cint {.cdecl, dynlib:dllname, importc.}
proc alpm_option_remove_cachedir*(handle: ptr alpm_handle_t; cachedir: cstring): cint {.cdecl, dynlib:dllname, importc.}
#* @} 
#* Returns the logfile name. 
proc alpm_option_get_logfile*(handle: ptr alpm_handle_t): cstring {.cdecl, dynlib:dllname, importc.}
#* Sets the logfile name. 
proc alpm_option_set_logfile*(handle: ptr alpm_handle_t; logfile: cstring): cint {.cdecl, dynlib:dllname, importc.}
#* Returns the path to libalpm's GnuPG home directory. 
proc alpm_option_get_gpgdir*(handle: ptr alpm_handle_t): cstring {.cdecl, dynlib:dllname, importc.}
#* Sets the path to libalpm's GnuPG home directory. 
proc alpm_option_set_gpgdir*(handle: ptr alpm_handle_t; gpgdir: cstring): cint {.cdecl, dynlib:dllname, importc.}
#* Returns whether to use syslog (0 is FALSE, TRUE otherwise). 
proc alpm_option_get_usesyslog*(handle: ptr alpm_handle_t): cint {.cdecl, dynlib:dllname, importc.}
#* Sets whether to use syslog (0 is FALSE, TRUE otherwise). 
proc alpm_option_set_usesyslog*(handle: ptr alpm_handle_t; usesyslog: cint): cint {.cdecl, dynlib:dllname, importc.}
#* @name Accessors to the list of no-upgrade files.
#  These functions depmodify the list of files which should
#  not be updated by package installation.
#  @{
# 
proc alpm_option_get_noupgrades*(handle: ptr alpm_handle_t): ptr alpm_list_t {.cdecl, dynlib:dllname, importc.}
proc alpm_option_add_noupgrade*(handle: ptr alpm_handle_t; pkg: cstring): cint {.cdecl, dynlib:dllname, importc.}
proc alpm_option_set_noupgrades*(handle: ptr alpm_handle_t, noupgrade: ptr alpm_list_t): cint {.cdecl, dynlib:dllname, importc.}
proc alpm_option_remove_noupgrade*(handle: ptr alpm_handle_t; pkg: cstring): cint {.cdecl, dynlib:dllname, importc.}
#* @} 
#* @name Accessors to the list of no-extract files.
#  These functions depmodify the list of filenames which should
#  be skipped packages which should
#  not be upgraded by a sysupgrade operation.
#  @{
# 
proc alpm_option_get_noextracts*(handle: ptr alpm_handle_t): ptr alpm_list_t {.cdecl, dynlib:dllname, importc.}
proc alpm_option_add_noextract*(handle: ptr alpm_handle_t; pkg: cstring): cint {.cdecl, dynlib:dllname, importc.}
proc alpm_option_set_noextracts*(handle: ptr alpm_handle_t, noextract: ptr alpm_list_t): cint {.cdecl, dynlib:dllname, importc.}
proc alpm_option_remove_noextract*(handle: ptr alpm_handle_t; pkg: cstring): cint {.cdecl, dynlib:dllname, importc.}
#* @} 
#* @name Accessors to the list of ignored packages.
#  These functions depmodify the list of packages that
#  should be ignored by a sysupgrade.
#  @{
# 
proc alpm_option_get_ignorepkgs*(handle: ptr alpm_handle_t): ptr alpm_list_t {.cdecl, dynlib:dllname, importc.}
proc alpm_option_add_ignorepkg*(handle: ptr alpm_handle_t; pkg: cstring): cint {.cdecl, dynlib:dllname, importc.}
proc alpm_option_set_ignorepkgs*(handle: ptr alpm_handle_t, ignorepkgs: ptr alpm_list_t): cint {.cdecl, dynlib:dllname, importc.}
proc alpm_option_remove_ignorepkg*(handle: ptr alpm_handle_t; pkg: cstring): cint {.cdecl, dynlib:dllname, importc.}
#* @} 
#* @name Accessors to the list of ignored groups.
#  These functions depmodify the list of groups whose packages
#  should be ignored by a sysupgrade.
#  @{
# 
proc alpm_option_get_ignoregroups*(handle: ptr alpm_handle_t): ptr alpm_list_t {.cdecl, dynlib:dllname, importc.}
proc alpm_option_add_ignoregroup*(handle: ptr alpm_handle_t; grp: cstring): cint {.cdecl, dynlib:dllname, importc.}
proc alpm_option_set_ignoregroups*(handle: ptr alpm_handle_t; ignoregrps: ptr alpm_list_t): cint {.cdecl, dynlib:dllname, importc.}
proc alpm_option_remove_ignoregroup*(handle: ptr alpm_handle_t; grp: cstring): cint {.cdecl, dynlib:dllname, importc.}
#* @} 
#* Returns the targeted architecture. 
proc alpm_option_get_arch*(handle: ptr alpm_handle_t): cstring {.cdecl, dynlib:dllname, importc.}
#* Sets the targeted architecture. 
proc alpm_option_set_arch*(handle: ptr alpm_handle_t; arch: cstring): cint {.cdecl, dynlib:dllname, importc.}
proc alpm_option_get_deltaratio*(handle: ptr alpm_handle_t): cdouble {.cdecl, dynlib:dllname, importc.}
proc alpm_option_set_deltaratio*(handle: ptr alpm_handle_t; ratio: cdouble): cint {.cdecl, dynlib:dllname, importc.}
proc alpm_option_get_checkspace*(handle: ptr alpm_handle_t): cint {.cdecl, dynlib:dllname, importc.}
proc alpm_option_set_checkspace*(handle: ptr alpm_handle_t; checkspace: cint): cint {.cdecl, dynlib:dllname, importc.}
proc alpm_option_get_default_siglevel*(handle: ptr alpm_handle_t): alpm_siglevel_t {.cdecl, dynlib:dllname, importc.}
proc alpm_option_set_default_siglevel*(handle: ptr alpm_handle_t; level: alpm_siglevel_t): cint {.cdecl, dynlib:dllname, importc.}
proc alpm_option_get_local_file_siglevel*(handle: ptr alpm_handle_t): alpm_siglevel_t {.cdecl, dynlib:dllname, importc.}
proc alpm_option_set_local_file_siglevel*(handle: ptr alpm_handle_t; level: alpm_siglevel_t): cint {.cdecl, dynlib:dllname, importc.}
proc alpm_option_get_remote_file_siglevel*(handle: ptr alpm_handle_t): alpm_siglevel_t {.cdecl, dynlib:dllname, importc.}
proc alpm_option_set_remote_file_siglevel*(handle: ptr alpm_handle_t; level: alpm_siglevel_t): cint {.cdecl, dynlib:dllname, importc.}
#* @} 
#* @addtogroup alpm_api_databases Database Functions
#  Functions to query and manipulate the database of libalpm.
#  @{
# 
#* Get the database of locally installed packages.
#  The returned pointer points to an internal structure
#  of libalpm which should only be manipulated through
#  libalpm functions.
#  @return a reference to the local database
# 
proc alpm_get_localdb*(handle: ptr alpm_handle_t): ptr alpm_db_t {.cdecl, dynlib:dllname, importc.}
#* Get the list of sync databases.
#  Returns a list of alpm_db_t structures, one for each registered
#  sync database.
#  @param handle the context handle
#  @return a reference to an internal list of alpm_db_t structures
# 
proc alpm_get_syncdbs*(handle: ptr alpm_handle_t): ptr alpm_list_t {.cdecl, dynlib:dllname, importc.}
#* Register a sync database of packages.
#  @param handle the context handle
#  @param treename the name of the sync repository
#  @param level what level of signature checking to perform on the
#  database; note that this must be a '.sig' file type verification
#  @return an alpm_db_t* on success (the value), NULL on error
# 
proc alpm_register_syncdb*(handle: ptr alpm_handle_t; treename: cstring; level: alpm_siglevel_t): ptr alpm_db_t {.cdecl, dynlib:dllname, importc.}
#* Unregister all package databases.
#  @param handle the context handle
#  @return 0 on success, -1 on error (pm_errno is set accordingly)
# 
proc alpm_unregister_all_syncdbs*(handle: ptr alpm_handle_t): cint {.cdecl, dynlib:dllname, importc.}
#* Unregister a package database.
#  @param db pointer to the package database to unregister
#  @return 0 on success, -1 on error (pm_errno is set accordingly)
# 
proc alpm_db_unregister*(db: ptr alpm_db_t): cint {.cdecl, dynlib:dllname, importc.}
#* Get the name of a package database.
#  @param db pointer to the package database
#  @return the name of the package database, NULL on error
# 
proc alpm_db_get_name*(db: ptr alpm_db_t): cstring {.cdecl, dynlib:dllname, importc.}
#* Get the signature verification level for a database.
#  Will return the default verification level if this database is set up
#  with ALPM_SIG_USE_DEFAULT.
#  @param db pointer to the package database
#  @return the signature verification level
# 
proc alpm_db_get_siglevel*(db: ptr alpm_db_t): alpm_siglevel_t {.cdecl, dynlib:dllname, importc.}
#* Check the validity of a database.
#  This is most useful for sync databases and verifying signature status.
#  If invalid, the handle error code will be set accordingly.
#  @param db pointer to the package database
#  @return 0 if valid, -1 if invalid (pm_errno is set accordingly)
# 
proc alpm_db_get_valid*(db: ptr alpm_db_t): cint {.cdecl, dynlib:dllname, importc.}
#* @name Accessors to the list of servers for a database.
#  @{
# 
proc alpm_db_get_servers*(db: ptr alpm_db_t): ptr alpm_list_t {.cdecl, dynlib:dllname, importc.}
proc alpm_db_set_servers*(db: ptr alpm_db_t; servers: ptr alpm_list_t): cint {.cdecl, dynlib:dllname, importc.}
proc alpm_db_add_server*(db: ptr alpm_db_t; url: cstring): cint {.cdecl, dynlib:dllname, importc.}
proc alpm_db_remove_server*(db: ptr alpm_db_t; url: cstring): cint {.cdecl, dynlib:dllname, importc.}
#* @} 
proc alpm_db_update*(force: cint; db: ptr alpm_db_t): cint {.cdecl, dynlib:dllname, importc.}
#* Get a package entry from a package database.
#  @param db pointer to the package database to get the package from
#  @param name of the package
#  @return the package entry on success, NULL on error
# 
proc alpm_db_get_pkg*(db: ptr alpm_db_t; name: cstring): ptr alpm_pkg_t {.cdecl, dynlib:dllname, importc.}
#* Get the package cache of a package database.
#  @param db pointer to the package database to get the package from
#  @return the list of packages on success, NULL on error
# 
proc alpm_db_get_pkgcache*(db: ptr alpm_db_t): ptr alpm_list_t {.cdecl, dynlib:dllname, importc.}
#* Get a group entry from a package database.
#  @param db pointer to the package database to get the group from
#  @param name of the group
#  @return the groups entry on success, NULL on error
# 
proc alpm_db_get_group*(db: ptr alpm_db_t; name: cstring): ptr alpm_group_t {.cdecl, dynlib:dllname, importc.}
#* Get the group cache of a package database.
#  @param db pointer to the package database to get the group from
#  @return the list of groups on success, NULL on error
# 
proc alpm_db_get_groupcache*(db: ptr alpm_db_t): ptr alpm_list_t {.cdecl, dynlib:dllname, importc.}
#* Searches a database with regular expressions.
#  @param db pointer to the package database to search in
#  @param needles a list of regular expressions to search for
#  @return the list of packages matching all regular expressions on success, NULL on error
# 
proc alpm_db_search*(db: ptr alpm_db_t; needles: ptr alpm_list_t): ptr alpm_list_t {.cdecl, dynlib:dllname, importc.}
discard """
These functions and this data structure are not in the mainline
binary version of libalpm

type 
  alpm_db_usage_t* {.size: sizeof(cint).} = enum 
    ALPM_DB_USAGE_SYNC = 1, ALPM_DB_USAGE_SEARCH = (1 shl 1), 
    ALPM_DB_USAGE_INSTALL = (1 shl 2), ALPM_DB_USAGE_UPGRADE = (1 shl 3), 
    ALPM_DB_USAGE_ALL = (1 shl 4) - 1
#* Sets the usage of a database.
#  @param db pointer to the package database to set the status for
#  @param usage a bitmask of alpm_db_usage_t values
#  @return 0 on success, or -1 on error
# 
proc alpm_db_set_usage*(db: ptr alpm_db_t; usage: alpm_db_usage_t): cint {.cdecl, dynlib:dllname, importc.}
#* Gets the usage of a database.
#  @param db pointer to the package database to get the status of
#  @param usage pointer to an alpm_db_usage_t to store db's status
#  @return 0 on success, or -1 on error
# 
proc alpm_db_get_usage*(db: ptr alpm_db_t; usage: ptr alpm_db_usage_t): cint {.cdecl, dynlib:dllname, importc.}
"""
#* @} 
#* @addtogroup alpm_api_packages Package Functions
#  Functions to manipulate libalpm packages
#  @{
# 
#* Create a package from a file.
#  If full is false, the archive is read only until all necessary
#  metadata is found. If it is true, the entire archive is read, which
#  serves as a verification of integrity and the filelist can be created.
#  The allocated structure should be freed using alpm_pkg_free().
#  @param handle the context handle
#  @param filename location of the package tarball
#  @param full whether to stop the load after metadata is read or continue
#  through the full archive
#  @param level what level of package signature checking to perform on the
#  package; note that this must be a '.sig' file type verification
#  @param pkg address of the package pointer
#  @return 0 on success, -1 on error (pm_errno is set accordingly)
# 
proc alpm_pkg_load*(handle: ptr alpm_handle_t; filename: cstring; full: cint; level: alpm_siglevel_t; pkg: ptr ptr alpm_pkg_t): cint {.cdecl, dynlib:dllname, importc.}
#* Find a package in a list by name.
#  @param haystack a list of alpm_pkg_t
#  @param needle the package name
#  @return a pointer to the package if found or NULL
# 
proc alpm_pkg_find*(haystack: ptr alpm_list_t; needle: cstring): ptr alpm_pkg_t {.cdecl, dynlib:dllname, importc.}
#* Free a package.
#  @param pkg package pointer to free
#  @return 0 on success, -1 on error (pm_errno is set accordingly)
# 
proc alpm_pkg_free*(pkg: ptr alpm_pkg_t): cint {.cdecl, dynlib:dllname, importc.}
#* Check the integrity (with md5) of a package from the sync cache.
#  @param pkg package pointer
#  @return 0 on success, -1 on error (pm_errno is set accordingly)
# 
proc alpm_pkg_checkmd5sum*(pkg: ptr alpm_pkg_t): cint {.cdecl, dynlib:dllname, importc.}
#* Compare two version strings and determine which one is 'newer'. 
proc alpm_pkg_vercmp*(a: cstring; b: cstring): cint {.cdecl, dynlib:dllname, importc.}
#* Computes the list of packages requiring a given package.
#  The return value of this function is a newly allocated
#  list of package names (char*), it should be freed by the caller.
#  @param pkg a package
#  @return the list of packages requiring pkg
# 
proc alpm_pkg_compute_requiredby*(pkg: ptr alpm_pkg_t): ptr alpm_list_t {.cdecl, dynlib:dllname, importc.}
#* Computes the list of packages optionally requiring a given package.
#  The return value of this function is a newly allocated
#  list of package names (char*), it should be freed by the caller.
#  @param pkg a package
#  @return the list of packages optionally requiring pkg
# 
proc alpm_pkg_compute_optionalfor*(pkg: ptr alpm_pkg_t): ptr alpm_list_t {.cdecl, dynlib:dllname, importc.}
discard """
this function is not in the mainline ABS version of libalpm
#* Test if a package should be ignored.
#  Checks if the package is ignored via IgnorePkg, or if the package is
#  in a group ignored via IgnoreGroup.
#  @param handle the context handle
#  @param pkg the package to test
#  @return 1 if the package should be ignored, 0 otherwise
#
proc alpm_pkg_should_ignore*(handle: ptr alpm_handle_t; pkg: ptr alpm_pkg_t): cint {.cdecl, dynlib:dllname, importc.}
"""
#* @name Package Property Accessors
#  Any pointer returned by these functions points to internal structures
#  allocated by libalpm. They should not be freed nor depmodified in any
#  way.
#  @{
# 
#* Gets the name of the file from which the package was loaded.
#  @param pkg a pointer to package
#  @return a reference to an internal string
# 
proc alpm_pkg_get_filename*(pkg: ptr alpm_pkg_t): cstring {.cdecl, dynlib:dllname, importc.}
#* Returns the package name.
#  @param pkg a pointer to package
#  @return a reference to an internal string
# 
proc alpm_pkg_get_name*(pkg: ptr alpm_pkg_t): cstring {.cdecl, dynlib:dllname, importc.}
#* Returns the package version as a string.
#  This includes all available epoch, version, and pkgrel components. Use
#  alpm_pkg_vercmp() to compare version strings if necessary.
#  @param pkg a pointer to package
#  @return a reference to an internal string
# 
proc alpm_pkg_get_version*(pkg: ptr alpm_pkg_t): cstring {.cdecl, dynlib:dllname, importc.}
#* Returns the origin of the package.
#  @return an alpm_pkgfrom_t constant, -1 on error
# 
proc alpm_pkg_get_origin*(pkg: ptr alpm_pkg_t): alpm_pkgfrom_t {.cdecl, dynlib:dllname, importc.}
#* Returns the package description.
#  @param pkg a pointer to package
#  @return a reference to an internal string
# 
proc alpm_pkg_get_desc*(pkg: ptr alpm_pkg_t): cstring {.cdecl, dynlib:dllname, importc.}
#* Returns the package URL.
#  @param pkg a pointer to package
#  @return a reference to an internal string
# 
proc alpm_pkg_get_url*(pkg: ptr alpm_pkg_t): cstring {.cdecl, dynlib:dllname, importc.}
#* Returns the build timestamp of the package.
#  @param pkg a pointer to package
#  @return the timestamp of the build time
# 
proc alpm_pkg_get_builddate*(pkg: ptr alpm_pkg_t): alpm_time_t {.cdecl, dynlib:dllname, importc.}
#* Returns the install timestamp of the package.
#  @param pkg a pointer to package
#  @return the timestamp of the install time
# 
proc alpm_pkg_get_installdate*(pkg: ptr alpm_pkg_t): alpm_time_t {.cdecl, dynlib:dllname, importc.}
#* Returns the packager's name.
#  @param pkg a pointer to package
#  @return a reference to an internal string
# 
proc alpm_pkg_get_packager*(pkg: ptr alpm_pkg_t): cstring {.cdecl, dynlib:dllname, importc.}
#* Returns the package's MD5 checksum as a string.
#  The returned string is a sequence of 32 lowercase hexadecimal digits.
#  @param pkg a pointer to package
#  @return a reference to an internal string
# 
proc alpm_pkg_get_md5sum*(pkg: ptr alpm_pkg_t): cstring {.cdecl, dynlib:dllname, importc.}
#* Returns the package's SHA256 checksum as a string.
#  The returned string is a sequence of 64 lowercase hexadecimal digits.
#  @param pkg a pointer to package
#  @return a reference to an internal string
# 
proc alpm_pkg_get_sha256sum*(pkg: ptr alpm_pkg_t): cstring {.cdecl, dynlib:dllname, importc.}
#* Returns the architecture for which the package was built.
#  @param pkg a pointer to package
#  @return a reference to an internal string
# 
proc alpm_pkg_get_arch*(pkg: ptr alpm_pkg_t): cstring {.cdecl, dynlib:dllname, importc.}
#* Returns the size of the package. This is only available for sync database
#  packages and package files, not those loaded from the local database.
#  @param pkg a pointer to package
#  @return the size of the package in bytes.
# 
proc alpm_pkg_get_size*(pkg: ptr alpm_pkg_t): off_t {.cdecl, dynlib:dllname, importc.}
#* Returns the installed size of the package.
#  @param pkg a pointer to package
#  @return the total size of files installed by the package.
# 
proc alpm_pkg_get_isize*(pkg: ptr alpm_pkg_t): off_t {.cdecl, dynlib:dllname, importc.}
#* Returns the package installation reason.
#  @param pkg a pointer to package
#  @return an enum member giving the install reason.
# 
proc alpm_pkg_get_reason*(pkg: ptr alpm_pkg_t): alpm_pkgreason_t {.cdecl, dynlib:dllname, importc.}
#* Returns the list of package licenses.
#  @param pkg a pointer to package
#  @return a pointer to an internal list of strings.
# 
proc alpm_pkg_get_licenses*(pkg: ptr alpm_pkg_t): ptr alpm_list_t {.cdecl, dynlib:dllname, importc.}
#* Returns the list of package groups.
#  @param pkg a pointer to package
#  @return a pointer to an internal list of strings.
# 
proc alpm_pkg_get_groups*(pkg: ptr alpm_pkg_t): ptr alpm_list_t {.cdecl, dynlib:dllname, importc.}
#* Returns the list of package dependencies as alpm_depend_t.
#  @param pkg a pointer to package
#  @return a reference to an internal list of alpm_depend_t structures.
# 
proc alpm_pkg_get_depends*(pkg: ptr alpm_pkg_t): ptr alpm_list_t {.cdecl, dynlib:dllname, importc.}
#* Returns the list of package optional dependencies.
#  @param pkg a pointer to package
#  @return a reference to an internal list of alpm_depend_t structures.
# 
proc alpm_pkg_get_optdepends*(pkg: ptr alpm_pkg_t): ptr alpm_list_t {.cdecl, dynlib:dllname, importc.}
#* Returns the list of packages conflicting with pkg.
#  @param pkg a pointer to package
#  @return a reference to an internal list of alpm_depend_t structures.
# 
proc alpm_pkg_get_conflicts*(pkg: ptr alpm_pkg_t): ptr alpm_list_t {.cdecl, dynlib:dllname, importc.}
#* Returns the list of packages provided by pkg.
#  @param pkg a pointer to package
#  @return a reference to an internal list of alpm_depend_t structures.
# 
proc alpm_pkg_get_provides*(pkg: ptr alpm_pkg_t): ptr alpm_list_t {.cdecl, dynlib:dllname, importc.}
#* Returns the list of available deltas for pkg.
#  @param pkg a pointer to package
#  @return a reference to an internal list of strings.
# 
proc alpm_pkg_get_deltas*(pkg: ptr alpm_pkg_t): ptr alpm_list_t {.cdecl, dynlib:dllname, importc.}
#* Returns the list of packages to be replaced by pkg.
#  @param pkg a pointer to package
#  @return a reference to an internal list of alpm_depend_t structures.
# 
proc alpm_pkg_get_replaces*(pkg: ptr alpm_pkg_t): ptr alpm_list_t {.cdecl, dynlib:dllname, importc.}
#* Returns the list of files installed by pkg.
#  The filenames are relative to the install root,
#  and do not include leading slashes.
#  @param pkg a pointer to package
#  @return a pointer to a filelist object containing a count and an array of
#  package file objects
# 
proc alpm_pkg_get_files*(pkg: ptr alpm_pkg_t): ptr alpm_filelist_t {.cdecl, dynlib:dllname, importc.}
#* Returns the list of files backed up when installing pkg.
#  The elements of the returned list have the form
#  "<filename>\t<md5sum>", where the given md5sum is that of
#  the file as provided by the package.
#  @param pkg a pointer to package
#  @return a reference to a list of alpm_backup_t objects
# 
proc alpm_pkg_get_backup*(pkg: ptr alpm_pkg_t): ptr alpm_list_t {.cdecl, dynlib:dllname, importc.}
#* Returns the database containing pkg.
#  Returns a pointer to the alpm_db_t structure the package is
#  originating from, or NULL if the package was loaded from a file.
#  @param pkg a pointer to package
#  @return a pointer to the DB containing pkg, or NULL.
# 
proc alpm_pkg_get_db*(pkg: ptr alpm_pkg_t): ptr alpm_db_t {.cdecl, dynlib:dllname, importc.}
#* Returns the base64 encoded package signature.
#  @param pkg a pointer to package
#  @return a reference to an internal string
# 
proc alpm_pkg_get_base64_sig*(pkg: ptr alpm_pkg_t): cstring {.cdecl, dynlib:dllname, importc.}
#* Returns the method used to validate a package during install.
#  @param pkg a pointer to package
#  @return an enum member giving the validation method
# 
proc alpm_pkg_get_validation*(pkg: ptr alpm_pkg_t): alpm_pkgvalidation_t {.cdecl, dynlib:dllname, importc.}
# End of alpm_pkg_t accessors 
# @} 
#* Open a package changelog for reading.
#  Similar to fopen in functionality, except that the returned 'file
#  stream' could really be from an archive as well as from the database.
#  @param pkg the package to read the changelog of (either file or db)
#  @return a 'file stream' to the package changelog
# 
proc alpm_pkg_changelog_open*(pkg: ptr alpm_pkg_t): pointer {.cdecl, dynlib:dllname, importc.}
#* Read data from an open changelog 'file stream'.
#  Similar to fread in functionality, this function takes a buffer and
#  amount of data to read. If an error occurs pm_errno will be set.
#  @param ptr a buffer to fill with raw changelog data
#  @param size the size of the buffer
#  @param pkg the package that the changelog is being read from
#  @param fp a 'file stream' to the package changelog
#  @return the number of characters read, or 0 if there is no more data or an
#  error occurred.
# 
proc alpm_pkg_changelog_read*(pttr: pointer; size: size_t; pkg: ptr alpm_pkg_t; fp: pointer): size_t {.cdecl, dynlib:dllname, importc.}
proc alpm_pkg_changelog_close*(pkg: ptr alpm_pkg_t; fp: pointer): cint {.cdecl, dynlib:dllname, importc.}
#* Open a package mtree file for reading.
#  @param pkg the local package to read the changelog of
#  @return a archive structure for the package mtree file
# 
proc alpm_pkg_mtree_open*(pkg: ptr alpm_pkg_t): ptr archive {.cdecl, dynlib:dllname, importc.}
#* Read next entry from a package mtree file.
#  @param pkg the package that the mtree file is being read from
#  @param archive the archive structure reading from the mtree file
#  @param entry an archive_entry to store the entry header information
#  @return 0 if end of archive is reached, non-zero otherwise.
# 
proc alpm_pkg_mtree_next*(pkg: ptr alpm_pkg_t; archive: ptr archive; entry: ptr ptr archive_entry): cint {.cdecl, dynlib:dllname, importc.}
proc alpm_pkg_mtree_close*(pkg: ptr alpm_pkg_t; archive: ptr archive): cint {.cdecl, dynlib:dllname, importc.}
#* Returns whether the package has an install scriptlet.
#  @return 0 if FALSE, TRUE otherwise
# 
proc alpm_pkg_has_scriptlet*(pkg: ptr alpm_pkg_t): cint {.cdecl, dynlib:dllname, importc.}
#* Returns the size of download.
#  Returns the size of the files that will be downloaded to install a
#  package.
#  @param newpkg the new package to upgrade to
#  @return the size of the download
# 
proc alpm_pkg_download_size*(newpkg: ptr alpm_pkg_t): off_t {.cdecl, dynlib:dllname, importc.}
proc alpm_pkg_unused_deltas*(pkg: ptr alpm_pkg_t): ptr alpm_list_t {.cdecl, dynlib:dllname, importc.}
#* Set install reason for a package in the local database.
#  The provided package object must be from the local database or this method
#  will fail. The write to the local database is performed immediately.
#  @param pkg the package to update
#  @param reason the new install reason
#  @return 0 on success, -1 on error (pm_errno is set accordingly)
# 
proc alpm_pkg_set_reason*(pkg: ptr alpm_pkg_t; reason: alpm_pkgreason_t): cint {.cdecl, dynlib:dllname, importc.}
# End of alpm_pkg 
#* @} 
#
#  Filelists
# 
#* Determines whether a package filelist contains a given path.
#  The provided path should be relative to the install root with no leading
#  slashes, e.g. "etc/localtime". When searching for directories, the path must
#  have a trailing slash.
#  @param filelist a pointer to a package filelist
#  @param path the path to search for in the package
#  @return a pointer to the matching file or NULL if not found
# 
proc alpm_filelist_contains*(filelist: ptr alpm_filelist_t; path: cstring): ptr alpm_file_t {.cdecl, dynlib:dllname, importc.}
#
#  Signatures
# 
proc alpm_pkg_check_pgp_signature*(pkg: ptr alpm_pkg_t; siglist: ptr alpm_siglist_t): cint {.cdecl, dynlib:dllname, importc.}
proc alpm_db_check_pgp_signature*(db: ptr alpm_db_t; siglist: ptr alpm_siglist_t): cint {.cdecl, dynlib:dllname, importc.}
proc alpm_siglist_cleanup*(siglist: ptr alpm_siglist_t): cint {.cdecl, dynlib:dllname, importc.}
#proc alpm_decode_signature*(base64_data: cstring; data: ptr ptr cuchar; data_len: ptr size_t): cint {.cdecl, dynlib:dllname, importc.}
#proc alpm_extract_keyid*(handle: ptr alpm_handle_t; identifier: cstring; sig: ptr cuchar; len: size_t; keys: ptr ptr alpm_list_t): cint {.cdecl, dynlib:dllname, importc.}
#
#  Groups
# 
proc alpm_find_group_pkgs*(dbs: ptr alpm_list_t; name: cstring): ptr alpm_list_t {.cdecl, dynlib:dllname, importc.}
#
#  Sync
# 
proc alpm_sync_newversion*(pkg: ptr alpm_pkg_t; dbs_sync: ptr alpm_list_t): ptr alpm_pkg_t {.cdecl, dynlib:dllname, importc.}
#* @addtogroup alpm_api_trans Transaction Functions
#  Functions to manipulate libalpm transactions
#  @{
# 
#* Transaction flags 
type                        #* Ignore dependency checks. 
  alpm_transflag_t* {.size: sizeof(cint).} = enum 
    ALPM_TRANS_FLAG_NODEPS = 1, #* Ignore file conflicts and overwrite files. 
    ALPM_TRANS_FLAG_FORCE = (1 shl 1), #* Delete files even if they are tagged as backup. 
    ALPM_TRANS_FLAG_NOSAVE = (1 shl 2), #* Ignore version numbers when checking dependencies. 
    ALPM_TRANS_FLAG_NODEPVERSION = (1 shl 3), #* Remove also any packages depending on a package being removed. 
    ALPM_TRANS_FLAG_CASCADE = (1 shl 4), #* Remove packages and their unneeded deps (not explicitly installed). 
    ALPM_TRANS_FLAG_RECURSE = (1 shl 5), #* Modify database but do not commit changes to the filesystem. 
    ALPM_TRANS_FLAG_DBONLY = (1 shl 6), # (1 << 7) flag can go here 
                                        #* Use ALPM_PKG_REASON_DEPEND when installing packages. 
    ALPM_TRANS_FLAG_ALLDEPS = (1 shl 8), #* Only download packages and do not actually install. 
    ALPM_TRANS_FLAG_DOWNLOADONLY = (1 shl 9), #* Do not execute install scriptlets after installing. 
    ALPM_TRANS_FLAG_NOSCRIPTLET = (1 shl 10), #* Ignore dependency conflicts. 
    ALPM_TRANS_FLAG_NOCONFLICTS = (1 shl 11), # (1 << 12) flag can go here 
                                              #* Do not install a package if it is already installed and up to date. 
    ALPM_TRANS_FLAG_NEEDED = (1 shl 13), #* Use ALPM_PKG_REASON_EXPLICIT when installing packages. 
    ALPM_TRANS_FLAG_ALLEXPLICIT = (1 shl 14), #* Do not remove a package if it is needed by another one. 
    ALPM_TRANS_FLAG_UNNEEDED = (1 shl 15), #* Remove also explicitly installed unneeded deps (use with ALPM_TRANS_FLAG_RECURSE). 
    ALPM_TRANS_FLAG_RECURSEALL = (1 shl 16), #* Do not lock the database during the operation. 
    ALPM_TRANS_FLAG_NOLOCK = (1 shl 17)
#* Returns the bitfield of flags for the current transaction.
#  @param handle the context handle
#  @return the bitfield of transaction flags
# 
proc alpm_trans_get_flags*(handle: ptr alpm_handle_t): alpm_transflag_t {.cdecl, dynlib:dllname, importc.}
#* Returns a list of packages added by the transaction.
#  @param handle the context handle
#  @return a list of alpm_pkg_t structures
# 
proc alpm_trans_get_add*(handle: ptr alpm_handle_t): ptr alpm_list_t {.cdecl, dynlib:dllname, importc.}
#* Returns the list of packages removed by the transaction.
#  @param handle the context handle
#  @return a list of alpm_pkg_t structures
# 
proc alpm_trans_get_remove*(handle: ptr alpm_handle_t): ptr alpm_list_t {.cdecl, dynlib:dllname, importc.}
#* Initialize the transaction.
#  @param handle the context handle
#  @param flags flags of the transaction (like nodeps, etc)
#  @return 0 on success, -1 on error (pm_errno is set accordingly)
# 
proc alpm_trans_init*(handle: ptr alpm_handle_t; flags: alpm_transflag_t): cint {.cdecl, dynlib:dllname, importc.}
#* Prepare a transaction.
#  @param handle the context handle
#  @param data the address of an alpm_list where a list
#  of alpm_depmissing_t objects is dumped (conflicting packages)
#  @return 0 on success, -1 on error (pm_errno is set accordingly)
# 
proc alpm_trans_prepare*(handle: ptr alpm_handle_t; data: ptr ptr alpm_list_t): cint {.cdecl, dynlib:dllname, importc.}
#* Commit a transaction.
#  @param handle the context handle
#  @param data the address of an alpm_list where detailed description
#  of an error can be dumped (i.e. list of conflicting files)
#  @return 0 on success, -1 on error (pm_errno is set accordingly)
# 
proc alpm_trans_commit*(handle: ptr alpm_handle_t; data: ptr ptr alpm_list_t): cint {.cdecl, dynlib:dllname, importc.}
#* Interrupt a transaction.
#  @param handle the context handle
#  @return 0 on success, -1 on error (pm_errno is set accordingly)
# 
proc alpm_trans_interrupt*(handle: ptr alpm_handle_t): cint {.cdecl, dynlib:dllname, importc.}
#* Release a transaction.
#  @param handle the context handle
#  @return 0 on success, -1 on error (pm_errno is set accordingly)
# 
proc alpm_trans_release*(handle: ptr alpm_handle_t): cint {.cdecl, dynlib:dllname, importc.}
#* @} 
#* @name Common Transactions 
#* @{ 
#* Search for packages to upgrade and add them to the transaction.
#  @param handle the context handle
#  @param enable_downgrade allow downgrading of packages if the remote version is lower
#  @return 0 on success, -1 on error (pm_errno is set accordingly)
# 
proc alpm_sync_sysupgrade*(handle: ptr alpm_handle_t; enable_downgrade: cint): cint {.cdecl, dynlib:dllname, importc.}
#* Add a package to the transaction.
#  If the package was loaded by alpm_pkg_load(), it will be freed upon
#  alpm_trans_release() invocation.
#  @param handle the context handle
#  @param pkg the package to add
#  @return 0 on success, -1 on error (pm_errno is set accordingly)
# 
proc alpm_add_pkg*(handle: ptr alpm_handle_t; pkg: ptr alpm_pkg_t): cint {.cdecl, dynlib:dllname, importc.}
#* Add a package removal action to the transaction.
#  @param handle the context handle
#  @param pkg the package to uninstall
#  @return 0 on success, -1 on error (pm_errno is set accordingly)
# 
proc alpm_remove_pkg*(handle: ptr alpm_handle_t; pkg: ptr alpm_pkg_t): cint {.cdecl, dynlib:dllname, importc.}
#* @} 
#* @addtogroup alpm_api_depends Dependency Functions
#  Functions dealing with libalpm representation of dependency
#  information.
#  @{
# 
proc alpm_checkdeps*(handle: ptr alpm_handle_t; pkglist: ptr alpm_list_t; remove: ptr alpm_list_t; upgrade: ptr alpm_list_t; reversedeps: cint): ptr alpm_list_t {.cdecl, dynlib:dllname, importc.}
proc alpm_find_satisfier*(pkgs: ptr alpm_list_t; depstring: cstring): ptr alpm_pkg_t {.cdecl, dynlib:dllname, importc.}
proc alpm_find_dbs_satisfier*(handle: ptr alpm_handle_t; dbs: ptr alpm_list_t; depstring: cstring): ptr alpm_pkg_t {.cdecl, dynlib:dllname, importc.}
proc alpm_checkconflicts*(handle: ptr alpm_handle_t; pkglist: ptr alpm_list_t): ptr alpm_list_t {.cdecl, dynlib:dllname, importc.}
#* Returns a newly allocated string representing the dependency information.
#  @param dep a dependency info structure
#  @return a formatted string, e.g. "glibc>=2.12"
# 
proc alpm_dep_compute_string*(dep: ptr alpm_depend_t): cstring {.cdecl, dynlib:dllname, importc.}
#* @} 
#* @} 
#
#  Helpers
# 
# checksums 
proc alpm_compute_md5sum*(filename: cstring): cstring {.cdecl, dynlib:dllname, importc.}
proc alpm_compute_sha256sum*(filename: cstring): cstring {.cdecl, dynlib:dllname, importc.}
#* @addtogroup alpm_api_errors Error Codes
#  @{
# 
type 
  alpm_errno_t* {.size: sizeof(cint).} = enum 
    ALPM_ERR_MEMORY = 1, ALPM_ERR_SYSTEM, ALPM_ERR_BADPERMS, 
    ALPM_ERR_NOT_A_FILE, ALPM_ERR_NOT_A_DIR, ALPM_ERR_WRONG_ARGS, ALPM_ERR_DISK_SPACE, # 
                                                                                       # Interface 
    ALPM_ERR_HANDLE_NULL, ALPM_ERR_HANDLE_NOT_NULL, ALPM_ERR_HANDLE_LOCK, # 
                                                                          # Databases 
    ALPM_ERR_DB_OPEN, ALPM_ERR_DB_CREATE, ALPM_ERR_DB_NULL, 
    ALPM_ERR_DB_NOT_NULL, ALPM_ERR_DB_NOT_FOUND, ALPM_ERR_DB_INVALID, 
    ALPM_ERR_DB_INVALID_SIG, ALPM_ERR_DB_VERSION, ALPM_ERR_DB_WRITE, ALPM_ERR_DB_REMOVE, # 
                                                                                         # Servers 
    ALPM_ERR_SERVER_BAD_URL, ALPM_ERR_SERVER_NONE, # Transactions 
    ALPM_ERR_TRANS_NOT_NULL, ALPM_ERR_TRANS_NULL, ALPM_ERR_TRANS_DUP_TARGET, 
    ALPM_ERR_TRANS_NOT_INITIALIZED, ALPM_ERR_TRANS_NOT_PREPARED, 
    ALPM_ERR_TRANS_ABORT, ALPM_ERR_TRANS_TYPE, ALPM_ERR_TRANS_NOT_LOCKED, # 
                                                                          # Packages 
    ALPM_ERR_PKG_NOT_FOUND, ALPM_ERR_PKG_IGNORED, ALPM_ERR_PKG_INVALID, 
    ALPM_ERR_PKG_INVALID_CHECKSUM, ALPM_ERR_PKG_INVALID_SIG, 
    ALPM_ERR_PKG_MISSING_SIG, ALPM_ERR_PKG_OPEN, ALPM_ERR_PKG_CANT_REMOVE, 
    ALPM_ERR_PKG_INVALID_NAME, ALPM_ERR_PKG_INVALID_ARCH, ALPM_ERR_PKG_REPO_NOT_FOUND, # 
                                                                                       # Signatures 
    ALPM_ERR_SIG_MISSING, ALPM_ERR_SIG_INVALID, # Deltas 
    ALPM_ERR_DLT_INVALID, ALPM_ERR_DLT_PATCHFAILED, # Dependencies 
    ALPM_ERR_UNSATISFIED_DEPS, ALPM_ERR_CONFLICTING_DEPS, ALPM_ERR_FILE_CONFLICTS, # 
                                                                                   # Misc 
    ALPM_ERR_RETRIEVE, ALPM_ERR_INVALID_REGEX, # External library errors 
    ALPM_ERR_LIBARCHIVE, ALPM_ERR_LIBCURL, ALPM_ERR_EXTERNAL_DOWNLOAD, 
    ALPM_ERR_GPGME
#* Returns the current error code from the handle. 
proc alpm_errno*(handle: ptr alpm_handle_t): alpm_errno_t {.cdecl, dynlib:dllname, importc.}
#* Returns the string corresponding to an error number. 
proc alpm_strerror*(err: alpm_errno_t): cstring {.cdecl, dynlib:dllname, importc.}
# End of alpm_api_errors 
#* @} 
proc alpm_initialize*(root: cstring; dbpath: cstring; err: ptr alpm_errno_t): ptr alpm_handle_t {.cdecl, dynlib:dllname, importc.}
proc alpm_release*(handle: ptr alpm_handle_t): cint {.cdecl, dynlib:dllname, importc.}
type 
  alpm_caps* = enum 
    ALPM_CAPABILITY_NLS = (1 shl 0), ALPM_CAPABILITY_DOWNLOADER = (1 shl 1), 
    ALPM_CAPABILITY_SIGNATURES = (1 shl 2)
proc alpm_version*(): cstring {.cdecl, dynlib:dllname, importc.}
proc alpm_capabilities*(): alpm_caps {.cdecl, dynlib:dllname, importc.}
# End of alpm_api 
#* @} 
