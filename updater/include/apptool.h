#ifndef UPDATE_H
#define UPDATE_H

int installPackage(const char* file);
int uninstallPackage(const char* titleid);
int checkPackage(const char* titleid);

#endif