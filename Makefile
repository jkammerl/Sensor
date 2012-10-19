BUILD_NUMBER=1
OPENNI_VERSION=1.5.4.0
PSENGINE_VERSION=5.1.0.41

ARCHITECTURE=$(shell uname -m)

ifeq (${ARCHITECTURE},x86_64)
        ARCH=amd64
        OPENNI_ARCH=x64
else 
        ARCH=i386
        OPENNI_ARCH=xx
endif

DISTRO=$(shell lsb_release -sc)

OPENNI_PACKAGE_NAME=ros-openni-dev-${OPENNI_VERSION}~${DISTRO}_$(ARCH)${BUILD_NUMBER}
ENGINE_PACKAGE_NAME=ros-ps_engine-dev-${PSENGINE_VERSION}~${DISTRO}_$(ARCH)${BUILD_NUMBER}
PSENGINE_REDISTNAME=Sensor-Bin-Linux-${OPENNI_ARCH}-v${PSENGINE_VERSION}

all: debian

debian: debian_engine 

debian_engine : $(ENGINE_PACKAGE_NAME).deb

$(ENGINE_PACKAGE_NAME).deb: ps_engine_lib
	mkdir -p $(ENGINE_PACKAGE_NAME)/DEBIAN \
					 $(ENGINE_PACKAGE_NAME)/usr/bin \
					 $(ENGINE_PACKAGE_NAME)/usr/lib \
					 $(ENGINE_PACKAGE_NAME)/etc/openni \
					 $(ENGINE_PACKAGE_NAME)/etc/udev/rules.d \
					 $(ENGINE_PACKAGE_NAME)/etc/modprobe.d \
					 $(OPENNI_PACKAGE_NAME)/usr/lib/pkgconfig
	cp -f ./CONTROL/engine_postinst $(ENGINE_PACKAGE_NAME)/DEBIAN/postinst
	cp -f ./CONTROL/engine_prerm $(ENGINE_PACKAGE_NAME)/DEBIAN/prerm
	cp -f ./Platform/Linux/Bin/${OPENNI_ARCH}-Release/*.so $(ENGINE_PACKAGE_NAME)/usr/lib/
	cp -f ./Platform/Linux/Redist/${PSENGINE_REDISTNAME}/Config/*.ini $(ENGINE_PACKAGE_NAME)/etc/openni/
	cp -f ./Platform/Linux/Bin/${OPENNI_ARCH}-Release/XnSensorServer $(ENGINE_PACKAGE_NAME)/usr/bin/
	cp -f ./CONTROL/55-primesense-usb.rules $(ENGINE_PACKAGE_NAME)/etc/udev/rules.d/
	cp -f ./CONTROL/blacklist-psengine.conf $(ENGINE_PACKAGE_NAME)/etc/modprobe.d/
	@sed s/__VERSION__/${PSENGINE_VERSION}~${DISTRO}/ ./CONTROL/engine_control | sed s/__ARCHITECTURE__/$(ARCH)/ > $(ENGINE_PACKAGE_NAME)/DEBIAN/control
	@sed -i s/__OPENNI_VERSION__/${OPENNI_VERSION}~${DISTRO}/ $(ENGINE_PACKAGE_NAME)/DEBIAN/control
	@sed s/__VERSION__/${PSENGINE_VERSION}~${DISTRO}/ ./CONTROL/ps_engine.pc > $(OPENNI_PACKAGE_NAME)/usr/lib/pkgconfig/ps-engine.pc
	@dpkg-deb -b $(ENGINE_PACKAGE_NAME)

ps_engine_lib:
	cd Platform/Linux/CreateRedist && bash RedistMaker && cd -

clean:
	rm -rf $(ENGINE_PACKAGE_NAME)
	rm -f $(ENGINE_PACKAGE_NAME).deb

