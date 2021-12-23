.PHONY: clean install build all

GIT = git

NGINX_VERSION = 1.21.4
NGINX_MODULE_VTS_VERSION = 0.1.18
NGINX_MODULE_RTMP_VERSION = 1.2.2

NGINX = nginx
NGINX_MODULE_VTS = nginx-module-vts
NGINX_MODULE_RTMP = nginx-module-rtmp

DEPS = ${NGINX} ${NGINX_MODULE_VTS} ${NGINX_MODULE_RTMP}

TARGET_BINARIES = $(NGINX)/objs/nginx

all: build

clean:
	rm -f nginx.tar.gz || true
	rm -f nginx-module-vts.tar.gz || true
	rm -f nginx-module-rtmp.tar.gz || true
	rm -rf "${NGINX}" || true
	rm -rf "${NGINX_MODULE_VTS}" || true
	rm -rf "${NGINX_MODULE_RTMP}" || true

install: build
	$(MAKE) -C "${NGINX}" install

build: $(TARGET_BINARIES)

$(NGINX)/objs/nginx: $(DEPS)
	cd "${NGINX}" && \
		./configure \
		--add-module=../${NGINX_MODULE_VTS} \
		--add-module=../${NGINX_MODULE_RTMP} \
		--conf-path=/etc/nginx/nginx.conf \
		--with-threads \
		--with-file-aio \
		--with-cc-opt="-Wimplicit-fallthrough=0" \
		--with-http_ssl_module && \
		$(MAKE)

$(NGINX):
	wget "https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" \
		-O nginx.tar.gz
	tar xf nginx.tar.gz
	rm nginx.tar.gz
	mv "nginx-${NGINX_VERSION}" "${NGINX}"

$(NGINX_MODULE_VTS):
	wget "https://github.com/vozlt/nginx-module-vts/archive/refs/tags/v${NGINX_MODULE_VTS_VERSION}.tar.gz" \
		-O nginx-module-vts.tar.gz
	tar xf nginx-module-vts.tar.gz
		--directory=nginx-module-vts
	rm nginx-module-vts.tar.gz
	mv "nginx-module-vts-${NGINX_MODULE_VTS_VERSION}" "${NGINX_MODULE_VTS}"

$(NGINX_MODULE_RTMP):
	wget "https://github.com/arut/nginx-rtmp-module/archive/refs/tags/v${NGINX_MODULE_RTMP_VERSION}.tar.gz" \
		-O nginx-module-rtmp.tar.gz
	tar xf nginx-module-rtmp.tar.gz
	rm nginx-module-rtmp.tar.gz
	mv "nginx-rtmp-module-${NGINX_MODULE_RTMP_VERSION}" "${NGINX_MODULE_RTMP}"

