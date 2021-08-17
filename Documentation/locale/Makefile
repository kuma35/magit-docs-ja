
# SRC_DIR = source/libusb.sourceforge.io/api-1.0
SRC_DIR = ..
PO_DIR = ja/LC_MESSAGES
TARGET_DIR = ja
SRC_TEXINFO = $(wildcard $(SRC_DIR)/*.texi)
PO_PO = $(wildcard $(PO_DIR)/*.texi.po)
TARGET_TEXINFO = $(addprefix $(TARGET_DIR)/,$(notdir $(SRC_TEXINFO)))

# $(warning SRC_TEXINFO = $(SRC_TEXINFO))
# $(warning PO_PO = $(PO_PO))
# $(warning TARGET_TEXINFO = $(TARGET_TEXINFO))

# $1 SRC_DIR, $2 target $3 .texi
a_file = $(addsuffix $(3),$(addprefix $(1)/,$(notdir $(basename $(2)))))

texinfo: $(TARGET_TEXINFO)

updatepo: $(PO_PO)

# static pattern
$(TARGET_TEXINFO): $(TARGET_DIR)/%.texi : $(PO_DIR)/%.texi.po
	po4a-translate -v --format texinfo --master $(call a_file,$(SRC_DIR),$@,.texi) --master-charset UTF-8 --po $? --localized $(call a_file,$(TARGET_DIR),$@,.texi) --localized-charset UTF-8 --keep 0

$(PO_PO): $(PO_DIR)/%.texi.po : $(SRC_DIR)/%.texi
	po4a-updatepo --format texinfo --master $? --master-charset UTF-8 --previous --copyright-holder "magit" --package-name "magit" --package-version "1.0" --po $@

.PHONY: texinfo updatepo
