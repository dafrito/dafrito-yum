include config

# Default rule
all: tar rpm
.PHONY: all

FULLNAME=$(shell git describe)

OUTDIR ?= build
RPMDIR ?= ~/rpmbuild

tarfile=$(FULLNAME).tar.gz

tar: $(OUTDIR)/$(tarfile)
.PHONY: tar

clean-repo:
	git diff --exit-code || (echo "Error: Repository must not be dirty"; exit 1) # fail if changes exist
.PHONY: clean-repo

$(OUTDIR)/$(tarfile): clean-repo .git/refs/heads/master | $(OUTDIR)
	git archive --format=tar --prefix=$(FULLNAME)/ HEAD | gzip >$@

$(OUTDIR):
	mkdir -p $(OUTDIR)

spec: $(OUTDIR)/$(NAME).spec
.PHONY: spec

$(OUTDIR)/$(NAME).spec: rpm.spec.in | $(OUTDIR)
	echo -n >$@
	echo "Name:	$(NAME)" >>$@
	echo "%define fullname $(FULLNAME)" >>$@
	cat $^ >>$@

rpm: clean-repo $(OUTDIR)/$(tarfile) $(OUTDIR)/$(NAME).spec | $(RPMDIR)
	cp -u $(OUTDIR)/$(tarfile)	$(RPMDIR)/SOURCES
	cp -u $(OUTDIR)/$(NAME).spec	$(RPMDIR)/SPECS
	rpmbuild --ba $(RPMDIR)/SPECS/$(NAME).spec
.PHONY: rpm

$(RPMDIR):
	mkdir -p $@
	cd $@ && mkdir -p SOURCES SPECS BUILD RPMS SRPMS

# We do NOT delete RPMDIR during clean, since we don't own it.
clean:
	[ "$(OUTDIR)" != "/" ] && rm -rf $(OUTDIR)
.PHONY: clean
