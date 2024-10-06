/* rexx - for use as a shell command */
  /* --------------------  rexx procedure  -------------------- *
  | Name:      CKAMNT                                          |
  |                                                            |
  | Function:  Report all AutoMounted Filesystems              |
  |                                                            |
  | Syntax:    %ckamnt                                         |
  |                                                            |
  | Usage Notes: Requires that automount be active             |
  |                                                            |
  | Dependencies:                                              |
  |                                                            |
  | Author:    Lionel B. Dyck                                  |
  |                                                            |
  | History:  (most recent on top)                             |
  |            2024/10/06 LBD - Report if not automounts       |
  |            2024/10/03 LBD - Creation                       |
  |                                                            |
  * ---------------------------------------------------------- */
  env.1 = 'HOME=$PWD'
  env.2 = 'PATH=/bin:/usr/sbin'
  env.0 = 2
  cmd = 'automount -q | grep /'
  x = bpxwunix(cmd,,s.,e.,env.)
  amt = s.0
  amd = strip(s.amt)'/'
  drop s. e.
  if amd = '' then do
      say 'No automounts detected.'
      exit 0
      end
  call get_mounted
  do i = 1 to s.0
    if wordpos('rw',s.i) = 0 then iterate
    parse value s.i with filesystem mount .
    cmd = 'automount -f' filesystem
    x = bpxwunix(cmd,,as.,ae.,env.)
    do ai = 1 to as.0
      if pos('No information',as.ai) > 0 then iterate
      if pos('STATE:',as.ai) = 0 then iterate
      say 'Filesystem' left(filesystem,44) 'is automounted at' mount
    end
  end
  exit
Get_Mounted:
  x = syscalls('ON')
  s.0 = 0
  c = 0
  address syscall
  numeric digits 12
  'getmntent m.'
  do i=1 to m.0
    'statfs' m.mnte_fsname.i 'st.'
    if left(m.mnte_fsname.i,1) = '/' then iterate
    if left(m.mnte_fsname.i,1) = '*' then iterate
    if st.stfs_rdonly = 0 then ro = 'rw'
    else iterate
    mount = m.mnte_path.i
    if left(mount,length(amd)) /= amd then iterate
    zfs   = m.mnte_fsname.i
    c = c + 1
    s.c = strip(zfs) mount ro
    s.0 = c
  end
  return
