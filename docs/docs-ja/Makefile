-include ../../config.mk
include ../../default.mk

SRC_TEXIS = $(addsuffix .texi,$(filter-out git-commit,$(PACKAGES)))
TEXIPAGES = $(addsuffix .ja.texi,$(filter-out git-commit,$(PACKAGES)))
POFILES = $(addsuffix .ja.po,$(filter-out git-commit,$(PACKAGES)))
INFOPAGES = $(addsuffix .ja.info,$(filter-out git-commit,$(PACKAGES)))
HTMLFILES = $(addsuffix .ja.html,$(filter-out git-commit,$(PACKAGES)))
HTMLDIRS  = $(filter-out git-commit,$(PACKAGES))
PDFFILES  = $(addsuffix .ja.pdf,$(filter-out git-commit,$(PACKAGES)))
EPUBFILES = $(addsuffix .ja.epub,$(filter-out git-commit,$(PACKAGES)))

DOCBOOK_XSL = /usr/share/xml/docbook/stylesheet/docbook-xsl-ns/epub/docbook.xsl

SRC_DIR = ..
SED_OUT_DIR = sed-out
PO_DIR = po
TRANSLATE_RAW_DIR = translate-raw
# TARGET_DIR = .

TARGET_SED_OUT = $(addprefix $(SED_OUT_DIR)/,$(SRC_TEXIS))
TARGET_PO = $(addprefix $(PO_DIR)/,$(POFILES))
TARGET_TEXI = $(TEXIPAGES)
TARGET_TRANSLATE_RAW_TEXI = $(addprefix $(TRANSLATE_RAW_DIR)/,$(TEXIPAGES))

# target_dir/hoge.ja.info -> src_dir/hoge.texi
# $1 SRC_DIR, $2 target $3 .texi
src_file = $(addsuffix $(3),$(addprefix $(1)/,$(notdir $(basename $(basename $(2))))))

## ###################################################################

.PHONY: texi install clean AUTHORS.md stats

all: info

## Build #############################################################

# $(warning INFOPAGES = $(INFOPAGES))

info: $(INFOPAGES) dir
html: $(HTMLFILES)
pdf:  $(PDFFILES)
epub: $(EPUBFILES)

$(TARGET_SED_OUT): $(SED_OUT_DIR)/%.texi : $(SRC_DIR)/%.texi
	sed -f ./html-out.sed < $< > $@

$(TARGET_PO): $(PO_DIR)/%.ja.po : $(SED_OUT_DIR)/%.texi
	po4a-updatepo -M utf8 -f texinfo -m $< -p $@

$(TARGET_TRANSLATE_RAW_TEXI): $(TRANSLATE_RAW_DIR)/%.ja.texi : $(PO_DIR)/%.ja.po
	po4a-translate -f texinfo -keep 0 -M utf8 -m $(call src_file,$(SED_OUT_DIR),$@,.texi) -p $< -l $@

$(TARGET_TEXI): %.ja.texi : $(TRANSLATE_RAW_DIR)/%.ja.texi
	gawk -f fix-menu-wrap.awk $< > $@

$(INFOPAGES): %.ja.info : %.ja.texi
	$(MAKEINFO) --no-split --paragraph-indent=none $< -o $@

dir: $(INFOPAGES)
	rm -f $@
	echo $^ | xargs -n 1 $(INSTALL_INFO) --max-width=80 --dir=$@

HTML_FIXUP_CSS    = '/<link rel="stylesheet" type="text\/css" href="\/assets\/page.css">/a\
<link rel="icon" href="/assets/magit_alt1.ico">\
\n<link class="s-css-s--style" rel="stylesheet"           title="Default"               href="/assets/themes/default.css">\
\n<link class="s-css-s--style" rel="stylesheet alternate" title="Default high contrast" href="/assets/themes/default-high-contrast.css">\
\n<link class="s-css-s--style" rel="stylesheet alternate" title="Solarized dark xterm"  href="/assets/themes/solarized-dark-xterm.css">\
\n<link class="s-css-s--style" rel="stylesheet alternate" title="Black on white"        href="/assets/themes/black-on-white.css">\
\n<script src="/assets/js/simple-css-switch.js"></script>'
HTML_FIXUP_ONLOAD = 's/<body lang="en">/<body lang="en" onload="simpleCssSwitch()">/'
HTML_FIXUP_MENU   = '/<\/body>/i<div id="s-css-s--menu"><\/div>'

%.ja.html: %.ja.texi
	@printf "Generating $@\n"
	@$(MAKEINFO) --html --no-split $(MANUAL_HTML_ARGS) $< -o $@
	@sed -i -e $(HTML_FIXUP_CSS) -e $(HTML_FIXUP_ONLOAD) -e $(HTML_FIXUP_MENU) $@

html-dir: $(TEXIFILES)
	@printf "Generating magit/*.ja.html\n"
	@$(MAKEINFO) --html $(MANUAL_HTML_ARGS) magit.ja.texi
	@for f in $$(find magit -name '*.ja.html') ; do \
	sed -i -e $(HTML_FIXUP_CSS) -e $(HTML_FIXUP_ONLOAD) -e $(HTML_FIXUP_MENU) $$f ; \
	done
	@printf "Generating magit-section/*.ja.html\n"
	@$(MAKEINFO) --html $(MANUAL_HTML_ARGS) magit-section.ja.texi
	@for f in $$(find magit-section -name '*.ja.html') ; do \
	sed -i -e $(HTML_FIXUP_CSS) -e $(HTML_FIXUP_ONLOAD) -e $(HTML_FIXUP_MENU) $$f ; \
	done

%.ja.pdf: %.ja.texi
	@printf "Generating $@\n"
	texi2pdf --clean $< > /dev/null

%.ja.epub: %.ja.texi
	printf "Generating $@\n"
	$(MAKEINFO) --docbook $< -o epub.xml
	xsltproc $(DOCBOOK_XSL) epub.xml 2> /dev/null
	echo "application/epub+zip" > mimetype
	zip -X --quiet --recurse-paths -0 $@ mimetype
	zip -X --quiet --recurse-paths -9 --no-dir-entries $@ META-INF OEBPS
	$(RMDIR) $(EPUBTRASH)

## Install ###########################################################

install: install-info install-docs

install-docs: install-info
	@$(MKDIR) $(DESTDIR)$(docdir)
	$(CP) AUTHORS.md $(DESTDIR)$(docdir)

install-info: info
	@$(MKDIR) $(DESTDIR)$(infodir)
	$(CP) $(INFOPAGES) $(DESTDIR)$(infodir)

## Clean #############################################################

clean:
	@printf "Cleaning Documentation/*...\n"
	@$(RMDIR) dir $(INFOPAGES) $(HTMLFILES) $(HTMLDIRS) $(PDFFILES)
	@$(RMDIR) $(EPUBFILES) $(EPUBTRASH)

## Release management ################################################

ORG_ARGS  = --batch -Q $(ORG_LOAD_PATH)
ORG_ARGS += -l magit-utils.el -l ox-extra -l ox-texinfo+.el
ORG_ARGS += --eval "(or (require 'org-man nil t) (require 'ol-man))"
ORG_EVAL  = --eval "(ox-extras-activate '(ignore-headlines))"
ORG_EVAL += --eval "(setq indent-tabs-mode nil)"
ORG_EVAL += --eval "(setq org-src-preserve-indentation nil)"
ORG_EVAL += --funcall org-texinfo-export-to-texinfo

# This target first bumps version strings in the Org source.  The
# necessary tools might be missing so other targets do not depend
# on this target and it has to be run explicitly when appropriate.
#
#   AMEND=t make texi    Update manual to be amended to HEAD.
#   VERSION=N make texi  Update manual for release.
#
texi:
	@$(EMACSBIN) $(ORG_ARGS) $(PKG).org $(ORG_EVAL)
	@printf "\n" >> $(PKG).texi
	@rm -f $(PKG).texi~
	@$(EMACSBIN) $(ORG_ARGS) magit-section.org $(ORG_EVAL)
	@printf "\n" >> magit-section.texi
	@rm -f magit-section.texi~

stats:
	@printf "Generating statistics\n"
	@gitstats -c style=https://magit.vc/assets/stats.css -c max_authors=999 $(TOP) $(statsdir)

authors: AUTHORS.md

AUTHORS.md:
	@printf "Generating AUTHORS.md..."
	@test -e $(TOP).git \
	&& (printf "$$AUTHORS_HEADER\n" > $@ \
	&& git log --pretty=format:'- %aN <%aE>' | sort -u >> $@ \
	&& printf "done\n" ; ) \
	|| printf "FAILED (non-fatal)\n"

DOMAIN         ?= magit.vc
PUBLISH_PATH   ?= /manual/
RELEASE_PATH   ?= /manual/$(VERSION)/

S3_BUCKET      ?= s3://$(DOMAIN)
PUBLISH_TARGET  = $(S3_BUCKET)$(PUBLISH_PATH)
RELEASE_TARGET  = $(S3_BUCKET)$(RELEASE_PATH)

CFRONT_DIST    ?= E2LUHBKU1FBV02
CFRONT_PATHS    = $(PKG).html $(PKG).pdf $(PKG)/*

comma := ,
empty :=
space := $(empty) $(empty)

publish-stats: stats
	@printf "Uploading statistics...\n"
	@aws s3 sync $(statsdir) $(S3_BUCKET)/stats/
	@printf "Uploaded to $(PUBLISH_URL)/stats/\n"
	@printf "Generating CDN invalidation\n"
	@aws cloudfront create-invalidation \
	--distribution-id $(CFRONT_DIST) --paths "/stats/*" > /dev/null

publish-manuals: $(PUBLISH_TARGETS)
	@printf "Uploading manuals... $(PUBLISH_TARGETS)\n"
	@aws s3 cp $(PKG).html $(PUBLISH_TARGET)
	@aws s3 cp $(PKG).pdf  $(PUBLISH_TARGET)
	@aws s3 cp $(PKG).epub $(PUBLISH_TARGET)
	@printf "upload: ./$(PKG)/* to $(PUBLISH_TARGET)*\n"
	@aws s3 sync --delete $(PKG) $(PUBLISH_TARGET)$(PKG)/ > /dev/null
	@aws s3 cp magit-section.html $(PUBLISH_TARGET)
	@aws s3 cp magit-section.pdf  $(PUBLISH_TARGET)
	@aws s3 cp magit-section.epub $(PUBLISH_TARGET)
	@printf "upload: ./magit-section/* to $(PUBLISH_TARGET)*\n"
	@aws s3 sync --delete magit-section $(PUBLISH_TARGET)magit-section/ > /dev/null
	@printf "Generating CDN invalidation\n"
	@aws cloudfront create-invalidation --distribution-id $(CFRONT_DIST) --paths \
	"$(subst $(space),$(comma),$(addprefix $(PUBLISH_PATH),$(CFRONT_PATHS)))" > /dev/null

release-manuals: $(PUBLISH_TARGETS)
	@printf "Uploading release manuals...\n"
	@aws s3 cp $(PKG).html $(RELEASE_TARGET)
	@aws s3 cp $(PKG).pdf  $(RELEASE_TARGET)
	@aws s3 cp $(PKG).epub $(RELEASE_TARGET)
	@printf "upload: ./$(PKG)/* to $(RELEASE_TARGET)*\n"
	@aws s3 sync --delete $(PKG) $(RELEASE_TARGET)$(PKG)/ > /dev/null
	@aws s3 cp magit-section.html $(RELEASE_TARGET)
	@aws s3 cp magit-section.pdf  $(RELEASE_TARGET)
	@aws s3 cp magit-section.epub $(RELEASE_TARGET)
	@printf "upload: ./magit-section/* to $(RELEASE_TARGET)*\n"
	@aws s3 sync --delete magit-section $(RELEASE_TARGET)magit-section/ > /dev/null
	@aws s3 cp $(PUBLISH_TARGET)dir.html $(RELEASE_TARGET)dir.html
	@aws s3 cp $(PUBLISH_TARGET)dir/index.html $(RELEASE_TARGET)dir/index.html
	@printf "Generating CDN invalidation\n"
	@aws cloudfront create-invalidation --distribution-id $(CFRONT_DIST) --paths \
	"$(subst $(space),$(comma),$(addprefix $(RELEASE_PATH),$(CFRONT_PATHS)))" > /dev/null

# Templates ##########################################################

define AUTHORS_HEADER
Authors
=======

The following people have contributed to Magit, including the
libraries `git-commit.el`, `magit-popup.el`, and `with-editor.el`
which are distributed as separate Elpa packages.

For statistics see https://magit.vc/stats/authors.html.

Names below are sorted alphabetically.

Author
------

- Marius Vollmer <marius.vollmer@gmail.com>

Maintainer
----------

- Jonas Bernoulli <jonas@bernoul.li>

Developers
----------

- Kyle Meyer <kyle@kyleam.com>
- Noam Postavsky <npostavs@users.sourceforge.net>

Retired Maintainers and Developers
----------------------------------

- Nicolas Dudebout <nicolas.dudebout@gatech.edu>
- Peter J. Weisberg <pj@irregularexpressions.net>
- Pieter Praet <pieter@praet.org>
- Phil Jackson <phil@shellarchive.co.uk>
- Rémi Vanicat <vanicat@debian.org>
- Yann Hodique <yann.hodique@gmail.com>

Contributors
------------

endef
export AUTHORS_HEADER
