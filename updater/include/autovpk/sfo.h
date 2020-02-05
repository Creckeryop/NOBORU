/*
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


#ifndef __SFO_H__
#define __SFO_H__

#define SFO_MAGIC 0x46535000


#define PSF_TYPE_BIN 0
#define PSF_TYPE_STR 2
#define PSF_TYPE_VAL 4

typedef struct SfoHeader {
  unsigned int magic;
  unsigned int version;
  unsigned int keyofs;
  unsigned int valofs;
  unsigned int count;
} __attribute__((packed)) SfoHeader;

typedef struct SfoEntry {
  unsigned short nameofs;
  unsigned char  alignment;
  unsigned char  type;
  unsigned int valsize;
  unsigned int totalsize;
  unsigned int dataofs;
} __attribute__((packed)) SfoEntry;

int getSfoValue(void *buffer, const char *name, unsigned int *value);
int getSfoString(void *buffer, const char *name, char *string, int length);
int setSfoValue(void *buffer, const char *name, unsigned int value);
int setSfoString(void *buffer, const char *name, const char *string);


#endif
