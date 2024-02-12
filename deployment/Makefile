# function to check required arguments
check_defined = \
	$(strip $(foreach 1,$1, \
		$(call __check_defined,$1)))
__check_defined = \
	$(if $(value $1),, \
		$(error Undefined $1))

RUST_LIB_PATH = "../eCTF-2024-lib/"

all:
	echo "#define SECRET 1234" > global_secrets.h
	cd $(RUST_LIB_PATH) && cargo build --release

clean:
	rm -f global_secrets.h
