/*
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
#include <stdio.h>
#include <vitasdk.h>
#include "include/apptool.h"


int launchAppByUriExit(const char *titleid) {
	char uri[32];
	sprintf(uri, "psgm:play?titleid=%s", titleid);
	sceKernelDelayThread(10000);
	sceAppMgrLaunchAppByUri(0xFFFFF, uri);
	sceKernelDelayThread(10000);
	sceAppMgrLaunchAppByUri(0xFFFFF, uri);
	sceKernelDelayThread(100);
	sceKernelExitProcess(0);
	return 0;
}

int main(int argc, const char *argv[]) {
	// Destroy other apps
	sceAppMgrDestroyOtherApp();
	installPackage("ux0:data/noboru/NOBORU");
	launchAppByUriExit("NOBOR0001");
	return 0;
}
