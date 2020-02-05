/*
  MODIFIED FILE!
  This file was modified by creckeryop, this is not the original file!

  MODIFIED FILE!
  This file was modified by coderx3, this is not the original file!

  VitaShell
  Copyright (C) 2015-2018, TheFloW

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "apptool.h"
#include <vitasdk.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "autovpk/file.h"

static int loadScePaf()
{
  static uint32_t argp[] = {0x180000, -1, -1, 1, -1, -1};

  int result = -1;

  uint32_t buf[4];
  buf[0] = sizeof(buf);
  buf[1] = (uint32_t)&result;
  buf[2] = -1;
  buf[3] = -1;

  return sceSysmoduleLoadModuleInternalWithArg(SCE_SYSMODULE_INTERNAL_PAF, sizeof(argp), argp, buf);
}

static int unloadScePaf()
{
  uint32_t buf = 0;
  return sceSysmoduleUnloadModuleInternalWithArg(SCE_SYSMODULE_INTERNAL_PAF, 0, NULL, &buf);
}

int installPackage(const char *file)
{
  const char *copyFolderRoot = "ux0:data/lppvai/";
  loadScePaf();
  sceSysmoduleLoadModuleInternal(SCE_SYSMODULE_INTERNAL_PROMOTER_UTIL);
  scePromoterUtilityInit();
  sceIoMkdir(copyFolderRoot, 0777);

  char tmpFolder[255];
  snprintf(tmpFolder, 255, "%s%s%s", copyFolderRoot, hasEndSlash(copyFolderRoot) ? "" : "/", "pkg");
  int copyResult = copyPath(file, tmpFolder);
  if (copyResult < 0)
  {
    sceIoRmdir(tmpFolder);
    sceIoRmdir(copyFolderRoot);
    // End promoter stuff
    scePromoterUtilityExit();
    sceSysmoduleUnloadModuleInternal(SCE_SYSMODULE_INTERNAL_PROMOTER_UTIL);
    unloadScePaf();
    return -1;
  }

  generateHeadBin(tmpFolder);
  scePromoterUtilityPromotePkgWithRif(tmpFolder, 1);
  // End promoter stuff
  scePromoterUtilityExit();
  sceSysmoduleUnloadModuleInternal(SCE_SYSMODULE_INTERNAL_PROMOTER_UTIL);
  unloadScePaf();
  sceIoRmdir(copyFolderRoot);
  return 0;
}

int uninstallPackage(const char *titleid)
{
  int res;

  sceAppMgrDestroyOtherApp();

  res = loadScePaf();
  if (res < 0)
    return res;

  res = sceSysmoduleLoadModuleInternal(SCE_SYSMODULE_INTERNAL_PROMOTER_UTIL);
  if (res < 0)
    return res;

  res = scePromoterUtilityInit();
  if (res < 0)
    return res;

  res = scePromoterUtilityDeletePkg(titleid);
  if (res < 0)
    return res;

  res = scePromoterUtilityExit();
  if (res < 0)
    return res;

  res = sceSysmoduleUnloadModuleInternal(SCE_SYSMODULE_INTERNAL_PROMOTER_UTIL);
  if (res < 0)
    return res;

  res = unloadScePaf();
  if (res < 0)
    return res;

  return res;
}

int checkPackage(const char* titleid)
{
  int res;
  int ret;

  res = loadScePaf();
  if (res < 0)
    return res;

  res = sceSysmoduleLoadModuleInternal(SCE_SYSMODULE_INTERNAL_PROMOTER_UTIL);
  if (res < 0)
    return res;

  res = scePromoterUtilityInit();
  if (res < 0)
    return res;

  ret = scePromoterUtilityCheckExist(titleid, &res);
  if (res < 0)
    return res;

  res = scePromoterUtilityExit();
  if (res < 0)
    return res;

  res = sceSysmoduleUnloadModuleInternal(SCE_SYSMODULE_INTERNAL_PROMOTER_UTIL);
  if (res < 0)
    return res;

  res = unloadScePaf();
  if (res < 0)
    return res;

  return ret >= 0;
}