ml = module is-loaded $1 || module load $1
RVERSION=4.2.2


dockers=$(patsubst %.docker,%.log,$(wildcard *.docker))
docker: $(dockers)
$(dockers): %.log : %-$(RVERSION).docker
	docker build \
	 -f $< \
	 -t $* \
	 . || rm $<
	docker tag $*:latest gavinpaulkelly/verse-boost:$(RVERSION)
	docker push gavinpaulkelly/$*:$(RVERSION)

%-$(RVERSION).docker: %.docker
	sed 's/RVERSION/$(RVERSION)/' $< > $@

.PHONY: singularity

singularity: verse-boost_$(RVERSION).sif emacs-verse_$(RVERSION).sif

%_$(RVERSION).sif: %-$(RVERSION).def
	$(call ml,Singularity/3.4.2) ;\
	singularity build --remote $@ $<
#singularity push $@ library://gavinpaulkelly/rocker/verse-boost:$(RVERSION)

%-$(RVERSION).def: %.def
	sed 's/RVERSION/$(RVERSION)/' $< > $@

clean:
	rm -f verse-boost-$(RVERSION).sif emacs-verse-$(RVERSION).sif
	rm -f verse-boost-$(RVERSION).def emacs-verse-$(RVERSION).def
	rm -f verse-boost-$(RVERSION).docker emacs-verse-$(RVERSION).docker

