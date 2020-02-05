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

#include "headgen.h"
#include "sfo.h"
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <openssl/sha.h>
#include <psp2/io/fcntl.h>
#include <psp2/io/stat.h>
#include "file.h"

#define ntohl __builtin_bswap32

extern void *_binary_source_head_bin_start, *_binary_source_head_bin_end , *_binary_source_head_bin_size;

int checkFileExist(const char *file) {
  SceUID fd = sceIoOpen(file, SCE_O_RDONLY, 0);
  if (fd < 0)
    return 0;

  sceIoClose(fd);
  return 1;
}

int allocateReadFile(const char *file, void **buffer) {
  SceUID fd = sceIoOpen(file, SCE_O_RDONLY, 0);
  if (fd < 0)
    return fd;

  int size = sceIoLseek32(fd, 0, SCE_SEEK_END);
  sceIoLseek32(fd, 0, SCE_SEEK_SET);

  *buffer = malloc(size);
  if (!*buffer) {
    sceIoClose(fd);
    return -1;
  }

  int read = sceIoRead(fd, *buffer, size);
  sceIoClose(fd);

  return read;
}

int WriteFile(const char *file, const void *buf, int size) {
  SceUID fd = sceIoOpen(file, SCE_O_WRONLY | SCE_O_CREAT | SCE_O_TRUNC, 0777);
  if (fd < 0)
    return fd;

  int written = sceIoWrite(fd, buf, size);

  sceIoClose(fd);
  return written;
}



static void fpkg_hmac(const uint8_t *data, unsigned int len, uint8_t hmac[16]) {
  SHA_CTX ctx;
  uint8_t sha1[20];
  uint8_t buf[64];

  SHA1_Init	(&ctx);
  SHA1_Update(&ctx, data, len);
  SHA1_Final( sha1 , &ctx);

  memset(buf, 0, 64);
  memcpy(&buf[0], &sha1[4], 8);
  memcpy(&buf[8], &sha1[4], 8);
  memcpy(&buf[16], &sha1[12], 4);
  buf[20] = sha1[16];
  buf[21] = sha1[1];
  buf[22] = sha1[2];
  buf[23] = sha1[3];
  memcpy(&buf[24], &buf[16], 8);

  SHA1_Init(&ctx);
  SHA1_Update(&ctx, buf, 64);
  SHA1_Final( sha1, &ctx);
  memcpy(hmac, sha1, 16);
}

int generateHeadBin(const char * path){

  uint8_t hmac[16];
  uint32_t off;
  uint32_t len;
  uint32_t out;

  SceIoStat stat;
  memset(&stat, 0, sizeof(SceIoStat));

  char HEAD_BIN[255];
  snprintf(HEAD_BIN , 255 , "%s%s%s" , path , hasEndSlash(path) ? "" : "/", "sce_sys/package/head.bin");
  if (checkFileExist(HEAD_BIN))
    return 0;

  // Read param.sfo
  void *sfo_buffer = NULL;
  char paramFile[255];
  snprintf(paramFile , 255 , "%s%s%s" , path , hasEndSlash(path) ? "" : "/", "sce_sys/param.sfo");
  int res = allocateReadFile(paramFile, &sfo_buffer);
  if (res < 0) {
    if (sfo_buffer)
      free(sfo_buffer);
    return res;
  }

  // Get title id
  char titleid[12];
  memset(titleid, 0, sizeof(titleid));
  getSfoString(sfo_buffer, "TITLE_ID", titleid, sizeof(titleid));

  // Enforce TITLE_ID format
  if (strlen(titleid) != 9)
    return -1;

  // Get content id
  char contentid[48];
  memset(contentid, 0, sizeof(contentid));
  getSfoString(sfo_buffer, "CONTENT_ID", contentid, sizeof(contentid));

  // Free sfo buffer
  free(sfo_buffer);

  // Allocate head.bin buffer
  uint8_t *head_bin = malloc((int)&_binary_source_head_bin_size);
  memcpy(head_bin, (void *)&_binary_source_head_bin_start, (int)&_binary_source_head_bin_size);

  // Write full title id
  char full_title_id[48];
  snprintf(full_title_id, sizeof(full_title_id), "EP9000-%s_00-0000000000000000", titleid);
  strncpy((char *)&head_bin[0x30], strlen(contentid) > 0 ? contentid : full_title_id, 48);

  // hmac of pkg header
  len = ntohl(*(uint32_t *)&head_bin[0xD0]);
  fpkg_hmac(&head_bin[0], len, hmac);
  memcpy(&head_bin[len], hmac, 16);

  // hmac of pkg info
  off = ntohl(*(uint32_t *)&head_bin[0x8]);
  len = ntohl(*(uint32_t *)&head_bin[0x10]);
  out = ntohl(*(uint32_t *)&head_bin[0xD4]);
  fpkg_hmac(&head_bin[off], len-64, hmac);
  memcpy(&head_bin[out], hmac, 16);

  // hmac of everything
  len = ntohl(*(uint32_t *)&head_bin[0xE8]);
  fpkg_hmac(&head_bin[0], len, hmac);
  memcpy(&head_bin[len], hmac, 16);

  // Make dir
  char paramFolder[255];
  snprintf(paramFolder , 255 , "%s%s%s" , path , hasEndSlash(path) ? "" : "/" , "sce_sys/package");
  sceIoMkdir(paramFolder, 0777);

  // Write head.bin
  WriteFile(HEAD_BIN, head_bin, (int)&_binary_source_head_bin_size);

  free(head_bin);

  return 0;


}
