# project name
NAME=ciphers-please
# paths to godot and butler executables
GODOT=$(HOME)/bin/godot
BUTLER=$(HOME)/bin/butler
# paths to project source and project build folder
PROJECT=.
OUT=$(HOME)/bin/ciphers-please
# itch.io URL for publising builds
ITCH_URL=isaacsand/ciphers-please

SCENES=$(shell find -name '*.tscn')

all: html windows linux
html: $(OUT)/$(NAME)_html.zip
windows: $(OUT)/$(NAME)_win.zip
linux: $(OUT)/$(NAME)_linux.zip

$(OUT)/$(NAME)_html.zip: $(SCENES)
	@mkdir -p $(OUT)/html
	$(GODOT) --headless --path $(PROJECT) --export-release "Web" $(OUT)/html/index.html
	zip -jr $@ $(OUT)/html/index.*

$(OUT)/$(NAME)_win.zip: $(SCENES)
	$(GODOT) --headless --path $(PROJECT) --export-release "Windows Desktop" $(OUT)/$(NAME).exe
	zip -jr $@ $(OUT)/$(NAME).exe $(OUT)/$(NAME).pck

$(OUT)/$(NAME)_linux.zip: $(SCENES)
	$(GODOT) --headless --path $(PROJECT) --export-release "Linux" $(OUT)/$(NAME).x86_64
	zip -jr $@ $(OUT)/$(NAME).x86_64 $(OUT)/$(NAME).pck

publish_html: html
	$(BUTLER) push $(OUT)/$(NAME)_html.zip $(ITCH_URL):html
publish_windows: windows
	$(BUTLER) push $(OUT)/$(NAME)_win.zip $(ITCH_URL):windows
publish_linux: linux
	$(BUTLER) push $(OUT)/$(NAME)_linux.zip $(ITCH_URL):linux
publish_all: publish_html publish_windows publish_linux

clean:
	rm $(OUT)/$(NAME)_*.zip
	rm $(OUT)/$(NAME).*
	rm $(OUT)/html/index.*
