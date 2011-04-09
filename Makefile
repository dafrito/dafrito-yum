include build.config

# Default rule
all: tar rpm
.PHONY: all

FULLNAME=$(NAME)-$(shell git describe --always)

OUTDIR ?= build
RPMDIR ?= $$HOME/rpmbuild
SPECFILE ?= rpm.spec.in

tarfile=$(FULLNAME).tar.gz

tar: $(OUTDIR)/$(tarfile)
.PHONY: tar

clean-repo:
ifndef DIRTY_REPO
	git diff --exit-code || (echo "Error: Repository must not be dirty"; exit 1) # fail if changes exist
else
	true
endif
.PHONY: clean-repo

$(OUTDIR)/$(tarfile): clean-repo .git/refs/heads/master | $(OUTDIR)
	git archive --format=tar --prefix=$(FULLNAME)/ HEAD | gzip >$@

$(OUTDIR):
	mkdir -p $(OUTDIR)

spec: $(OUTDIR)/$(NAME).spec
.PHONY: spec

$(OUTDIR)/$(NAME).spec: $(SPECFILE) | $(OUTDIR)
	echo -n >$@
	echo "Name:	$(NAME)" >>$@
	echo "%define fullname $(FULLNAME)" >>$@
	cat $^ >>$@

RPMFLAGS ?= --ba
rpm: clean-repo $(OUTDIR)/$(tarfile) $(OUTDIR)/$(NAME).spec | $(RPMDIR)
	cp -u $(OUTDIR)/$(tarfile)	$(RPMDIR)/SOURCES
	cp -u $(OUTDIR)/$(NAME).spec	$(RPMDIR)/SPECS
	rpmbuild $(RPMFLAGS) $(RPMDIR)/SPECS/$(NAME).spec
	cd $(OUTDIR); \
	for package in `rpm -q --specfile ./$(NAME).spec`; do \
		arch=`echo $$package | grep -E -o '[^.]+$$'`; \
		filename="$(RPMDIR)/RPMS/$$arch/$$package.rpm"; \
		[ -e `basename $$filename` ] || ln -s $$filename; \
	done
.PHONY: rpm

$(RPMDIR):
	mkdir -p $@
	cd $@ && mkdir -p SOURCES SPECS BUILD RPMS SRPMS

# We do NOT delete RPMDIR during clean, since we don't own it.
clean:
	[ "$(OUTDIR)" != "/" ] && rm -rf $(OUTDIR)
.PHONY: clean
