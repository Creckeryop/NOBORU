TITLE_ID = NOBORUPDT
TARGET   = updater
OBJS     = main.o include/head.o include/apptool.o include/autovpk/file.o include/autovpk/headgen.o include/autovpk/sfo.o 

LIBS     = -lssl -lcrypto -lSceAppMgr_stub -lScePromoterUtil_stub -lSceSysmodule_stub -lSceDisplay_stub

PREFIX   = arm-vita-eabi
CC       = $(PREFIX)-gcc
CFLAGS   = -Wl,-q -Wall -O3 -marm -Iinclude/font
ASFLAGS  = $(CFLAGS)

all: $(TARGET).vpk

%.vpk: eboot.bin
	vita-mksfoex -s TITLE_ID=$(TITLE_ID) "Noboru Updater" param.sfo
	vita-pack-vpk -s param.sfo -b eboot.bin $@

eboot.bin: $(TARGET).velf
	vita-make-fself $< $@

%.velf: %.elf
	vita-elf-create $< $@

$(TARGET).elf: $(OBJS)
	$(CC) $(CFLAGS) $^ $(LIBS) -o $@

%.o: %.bin
	$(PREFIX)-ld -r -b binary -o $@ $^

clean:
	@rm -rf $(TARGET).vpk $(TARGET).velf $(TARGET).elf $(OBJS) \
		eboot.bin param.sfo