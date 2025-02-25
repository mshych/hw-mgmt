Name: hw-management
Version: %{version}
Release: 1
Summary: Thermal control and chassis management for Mellanox systems
License: see /usr/share/doc/hw-management/copyright
Distribution: Centos
Group: Converted/utils
BuildArch: x86_64
AutoReq: no

Provides:      config(hw-management) = %{version}
Provides:      hw-management = %{version}
Provides:      hw-management(x86-64) = %{version}

%define _builddir ../
%define _rpmdir .
#%define _rpmfilename %%{NAME}-%%{VERSION}-%%{RELEASE}.%%{ARCH}.rpm
%define _rpmfilename %%{NAME}-%%{VERSION}.%%{ARCH}.rpm
%define _unpackaged_files_terminate_build 0

%post
%systemd_post %{name}.service
%systemd_post %{name}-tc.service
systemctl enable %{name}.service
systemctl enable %{name}-tc.service
systemctl start %{name}.service
systemctl start %{name}-tc.service

%preun
systemctl stop %{name}.service
systemctl disable %{name}.service
systemctl stop %{name}-tc.service
systemctl disable %{name}-tc.service
%systemd_preun %{name}.service
%systemd_preun %{name}-tc.service

%postun
%systemd_postun_with_restart %{name}.service
%systemd_postun_with_restart %{name}-tc.service


%description
This package supports Mellanox switches family for chassis
management and thermal control.

%install
rm -rf $RPM_BUILD_ROOT

mkdir -p $RPM_BUILD_ROOT/etc/hw-management-sensors
mkdir -p $RPM_BUILD_ROOT/usr/share/doc/hw-management
mkdir -p $RPM_BUILD_ROOT/etc/modules.d
mkdir -p $RPM_BUILD_ROOT/etc/modules-load.d
mkdir -p $RPM_BUILD_ROOT/etc/modprobe.d
mkdir -p $RPM_BUILD_ROOT/usr/bin
mkdir -p $RPM_BUILD_ROOT/lib/udev/rules.d
mkdir -p $RPM_BUILD_ROOT/lib/systemd/system
mkdir -p $RPM_BUILD_ROOT/usr/share/doc/hw-management
mkdir -p $RPM_BUILD_ROOT/usr/share/man/man1
mkdir -p $RPM_BUILD_ROOT/usr/share/man/man8

install -m 0644 usr/etc/hw-management-sensors/e3597_sensors.conf  $RPM_BUILD_ROOT/etc/hw-management-sensors/e3597_sensors.conf
install -m 0644 usr/etc/hw-management-sensors/mqm9700_rev1_sensors.conf  $RPM_BUILD_ROOT/etc/hw-management-sensors/mqm9700_rev1_sensors.conf
install -m 0644 usr/etc/hw-management-sensors/mqm9700_sensors.conf  $RPM_BUILD_ROOT/etc/hw-management-sensors/mqm9700_sensors.conf
install -m 0644 usr/etc/hw-management-sensors/msn2010_sensors.conf  $RPM_BUILD_ROOT/etc/hw-management-sensors/msn2010_sensors.conf
install -m 0644 usr/etc/hw-management-sensors/msn2100_sensors.conf  $RPM_BUILD_ROOT/etc/hw-management-sensors/msn2100_sensors.conf
install -m 0644 usr/etc/hw-management-sensors/msn2410_sensors.conf  $RPM_BUILD_ROOT/etc/hw-management-sensors/msn2410_sensors.conf
install -m 0644 usr/etc/hw-management-sensors/msn2700_sensors.conf  $RPM_BUILD_ROOT/etc/hw-management-sensors/msn2700_sensors.conf
install -m 0644 usr/etc/hw-management-sensors/msn2740_sensors.conf  $RPM_BUILD_ROOT/etc/hw-management-sensors/msn2740_sensors.conf
install -m 0644 usr/etc/hw-management-sensors/msn3420_sensors.conf  $RPM_BUILD_ROOT/etc/hw-management-sensors/msn3420_sensors.conf
install -m 0644 usr/etc/hw-management-sensors/msn3700_sensors.conf  $RPM_BUILD_ROOT/etc/hw-management-sensors/msn3700_sensors.conf
install -m 0644 usr/etc/hw-management-sensors/msn3800_sensors.conf  $RPM_BUILD_ROOT/etc/hw-management-sensors/msn3800_sensors.conf
install -m 0644 usr/etc/hw-management-sensors/msn4700_respin_sensors.conf  $RPM_BUILD_ROOT/etc/hw-management-sensors/msn4700_respin_sensors.conf
install -m 0644 usr/etc/hw-management-sensors/msn4700_sensors.conf  $RPM_BUILD_ROOT/etc/hw-management-sensors/msn4700_sensors.conf
install -m 0644 usr/etc/hw-management-sensors/msn4800_sensors.conf  $RPM_BUILD_ROOT/etc/hw-management-sensors/msn4800_sensors.conf
install -m 0644 usr/etc/hw-management-sensors/p2317_sensors.conf  $RPM_BUILD_ROOT/etc/hw-management-sensors/p2317_sensors.conf
install -m 0644 usr/etc/hw-management-sensors/p4697_sensors.conf  $RPM_BUILD_ROOT/etc/hw-management-sensors/p4697_sensors.conf
install -m 0644 usr/etc/hw-management-sensors/sn2201_sensors.conf  $RPM_BUILD_ROOT/etc/hw-management-sensors/sn2201_sensors.conf

install -m 0644 usr/etc/modprobe.d/hw-management.conf $RPM_BUILD_ROOT/etc/modprobe.d/hw-management.conf
install -m 0644 usr/etc/modules-load.d/05-hw-management-modules.conf $RPM_BUILD_ROOT/etc/modules-load.d/05-hw-management-modules.conf

install -m 0644 usr/lib/udev/rules.d/50-hw-management-events.rules $RPM_BUILD_ROOT/lib/udev/rules.d/50-hw-management-events.rules
install -m 0644 usr/lib/udev/rules.d/51-hw-management-events-modular.rules $RPM_BUILD_ROOT/lib/udev/rules.d/51-hw-management-events-modular.rules

install -m 0755 usr/usr/bin/hw-management-chassis-events.sh $RPM_BUILD_ROOT/usr/bin/hw-management-chassis-events.sh
install -m 0755 usr/usr/bin/hw-management-generate-dump.sh $RPM_BUILD_ROOT/usr/bin/hw-management-generate-dump.sh
install -m 0755 usr/usr/bin/hw-management-global-wp.sh $RPM_BUILD_ROOT/usr/bin/hw-management-global-wp.sh
install -m 0755 usr/usr/bin/hw-management-helpers.sh $RPM_BUILD_ROOT/usr/bin/hw-management-helpers.sh
install -m 0755 usr/usr/bin/hw-management-i2c-gpio-expander.sh $RPM_BUILD_ROOT/usr/bin/hw-management-i2c-gpio-expander.sh
install -m 0755 usr/usr/bin/hw-management-lc-fru-parser.py $RPM_BUILD_ROOT/usr/bin/hw-management-lc-fru-parser.py
install -m 0755 usr/usr/bin/hw-management-led-state-conversion.sh $RPM_BUILD_ROOT/usr/bin/hw-management-led-state-conversion.sh
install -m 0755 usr/usr/bin/hw-management-parse-eeprom.sh $RPM_BUILD_ROOT/usr/bin/hw-management-parse-eeprom.sh
install -m 0755 usr/usr/bin/hw-management-power-helper.sh $RPM_BUILD_ROOT/usr/bin/hw-management-power-helper.sh
install -m 0755 usr/usr/bin/hw-management-ps-vpd.sh $RPM_BUILD_ROOT/usr/bin/hw-management-ps-vpd.sh
install -m 0755 usr/usr/bin/hw-management-ready.sh $RPM_BUILD_ROOT/usr/bin/hw-management-ready.sh
install -m 0755 usr/usr/bin/hw-management-sfp-helper.sh $RPM_BUILD_ROOT/usr/bin/hw-management-sfp-helper.sh
install -m 0755 usr/usr/bin/hw-management-start-post.sh $RPM_BUILD_ROOT/usr/bin/hw-management-start-post.sh
install -m 0755 usr/usr/bin/hw-management-thermal-control.sh $RPM_BUILD_ROOT/usr/bin/hw-management-thermal-control.sh
install -m 0755 usr/usr/bin/hw-management-thermal-events.sh $RPM_BUILD_ROOT/usr/bin/hw-management-thermal-events.sh
install -m 0755 usr/usr/bin/hw-management-wd.sh $RPM_BUILD_ROOT/usr/bin/hw-management-wd.sh
install -m 0755 usr/usr/bin/hw-management.sh $RPM_BUILD_ROOT/usr/bin/hw-management.sh
install -m 0755 usr/usr/bin/hw_management_cpu_thermal.py $RPM_BUILD_ROOT/usr/bin/hw_management_cpu_thermal.py
install -m 0755 usr/usr/bin/hw_management_nvl_temperature_get.py $RPM_BUILD_ROOT/usr/bin/hw_management_nvl_temperature_get.py
install -m 0755 usr/usr/bin/hw_management_psu_fw_update_common.py $RPM_BUILD_ROOT/usr/bin/hw_management_psu_fw_update_common.py
install -m 0755 usr/usr/bin/hw_management_psu_fw_update_delta.py $RPM_BUILD_ROOT/usr/bin/hw_management_psu_fw_update_delta.py
install -m 0755 usr/usr/bin/hw_management_psu_fw_update_murata.py $RPM_BUILD_ROOT/usr/bin/hw_management_psu_fw_update_murata.py
install -m 0755 usr/usr/bin/iorw $RPM_BUILD_ROOT/usr/bin/iorw
install -m 0755 usr/usr/bin/sxd_read_cpld_ver.py $RPM_BUILD_ROOT/usr/bin/sxd_read_cpld_ver.py
install -m 0755 debian/hw-management.hw-management.service $RPM_BUILD_ROOT/lib/systemd/system/hw-management.service
install -m 0755 debian/hw-management.hw-management-tc.service $RPM_BUILD_ROOT/lib/systemd/system/hw-management-tc.service

install -m 0644 debian/copyright $RPM_BUILD_ROOT/usr/share/doc/hw-management/copyright
cp doc/man/hw-management.1 $RPM_BUILD_ROOT/usr/share/man/man1/hw-management.1
gzip $RPM_BUILD_ROOT/usr/share/man/man1/hw-management.1
chmod 0644 $RPM_BUILD_ROOT/usr/share/man/man1/hw-management.1.gz
cp doc/man/hw-management-tc.service.8 $RPM_BUILD_ROOT/usr/share/man/man8/hw-management-tc.service.8
gzip $RPM_BUILD_ROOT/usr/share/man/man8/hw-management-tc.service.8
chmod 0644 $RPM_BUILD_ROOT/usr/share/man/man8/hw-management-tc.service.8.gz
cp doc/man/hw-management.service.8 $RPM_BUILD_ROOT/usr/share/man/man8/hw-management.service.8
gzip $RPM_BUILD_ROOT/usr/share/man/man8/hw-management.service.8
chmod 0644 $RPM_BUILD_ROOT/usr/share/man/man8/hw-management.service.8.gz

%files
%dir "/etc/hw-management-sensors/"
%config "/etc/hw-management-sensors/mqm9700_sensors.conf"
#%dir %attr(0755, root, root) "/"
#%dir %attr(0755, root, root) "/etc"
%dir %attr(0755, root, root) "/etc/hw-management-sensors"
%config %attr(0644, root, root) "/etc/hw-management-sensors/e3597_sensors.conf"
%config %attr(0644, root, root) "/etc/hw-management-sensors/mqm9700_rev1_sensors.conf"
%config %attr(0644, root, root) "/etc/hw-management-sensors/mqm9700_sensors.conf"
%config %attr(0644, root, root) "/etc/hw-management-sensors/msn2010_sensors.conf"
%config %attr(0644, root, root) "/etc/hw-management-sensors/msn2100_sensors.conf"
%config %attr(0644, root, root) "/etc/hw-management-sensors/msn2410_sensors.conf"
%config %attr(0644, root, root) "/etc/hw-management-sensors/msn2700_sensors.conf"
%config %attr(0644, root, root) "/etc/hw-management-sensors/msn2740_sensors.conf"
%config %attr(0644, root, root) "/etc/hw-management-sensors/msn3420_sensors.conf"
%config %attr(0644, root, root) "/etc/hw-management-sensors/msn3700_sensors.conf"
%config %attr(0644, root, root) "/etc/hw-management-sensors/msn3800_sensors.conf"
%config %attr(0644, root, root) "/etc/hw-management-sensors/msn4700_respin_sensors.conf"
%config %attr(0644, root, root) "/etc/hw-management-sensors/msn4700_sensors.conf"
%config %attr(0755, root, root) "/etc/hw-management-sensors/msn4800_sensors.conf"
%config %attr(0644, root, root) "/etc/hw-management-sensors/p2317_sensors.conf"
%config %attr(0644, root, root) "/etc/hw-management-sensors/p4697_sensors.conf"
%config %attr(0755, root, root) "/etc/hw-management-sensors/sn2201_sensors.conf"
#%dir %attr(0755, root, root) "/etc/modprobe.d"
%config %attr(0644, root, root) "/etc/modprobe.d/hw-management.conf"
#%dir %attr(0755, root, root) "/etc/modules-load.d"
%config %attr(0644, root, root) "/etc/modules-load.d/05-hw-management-modules.conf"
#%dir %attr(0755, root, root) "/lib"
#%dir %attr(0755, root, root) "/lib/udev"
#%dir %attr(0755, root, root) "/lib/udev/rules.d"
#%dir %attr(0755, root, root) "/lib/systemd"
#%dir %attr(0755, root, root) "/lib/systemd/system"
%attr(0644, root, root) "/lib/udev/rules.d/50-hw-management-events.rules"
%attr(0644, root, root) "/lib/udev/rules.d/51-hw-management-events-modular.rules"
#%dir %attr(0755, root, root) "/usr"
#%dir %attr(0755, root, root) "/usr/bin"
%attr(0755, root, root) "/usr/bin/hw-management-chassis-events.sh"
%attr(0755, root, root) "/usr/bin/hw-management-generate-dump.sh"
%attr(0755, root, root) "/usr/bin/hw-management-global-wp.sh"
%attr(0755, root, root) "/usr/bin/hw-management-helpers.sh"
%attr(0755, root, root) "/usr/bin/hw-management-i2c-gpio-expander.sh"
%attr(0755, root, root) "/usr/bin/hw-management-lc-fru-parser.py"
%attr(0755, root, root) "/usr/bin/hw-management-led-state-conversion.sh"
%attr(0755, root, root) "/usr/bin/hw-management-parse-eeprom.sh"
%attr(0755, root, root) "/usr/bin/hw-management-power-helper.sh"
%attr(0755, root, root) "/usr/bin/hw-management-ps-vpd.sh"
%attr(0755, root, root) "/usr/bin/hw-management-ready.sh"
%attr(0755, root, root) "/usr/bin/hw-management-sfp-helper.sh"
%attr(0755, root, root) "/usr/bin/hw-management-start-post.sh"
%attr(0755, root, root) "/usr/bin/hw-management-thermal-control.sh"
%attr(0755, root, root) "/usr/bin/hw-management-thermal-events.sh"
%attr(0755, root, root) "/usr/bin/hw-management-wd.sh"
%attr(0755, root, root) "/usr/bin/hw-management.sh"
%attr(0755, root, root) "/usr/bin/hw_management_cpu_thermal.py"
%attr(0755, root, root) "/usr/bin/hw_management_nvl_temperature_get.py"
%attr(0755, root, root) "/usr/bin/hw_management_psu_fw_update_common.py"
%attr(0755, root, root) "/usr/bin/hw_management_psu_fw_update_delta.py"
%attr(0755, root, root) "/usr/bin/hw_management_psu_fw_update_murata.py"
%attr(0755, root, root) "/usr/bin/iorw"
%attr(0755, root, root) "/usr/bin/sxd_read_cpld_ver.py"
%attr(0755, root, root) "/lib/systemd/system/hw-management.service"
%attr(0755, root, root) "/lib/systemd/system/hw-management-tc.service"
#%dir %attr(0755, root, root) "/usr/share"
#%dir %attr(0755, root, root) "/usr/share/doc"
%dir %attr(0755, root, root) "/usr/share/doc/hw-management"
%doc %attr(0644, root, root) "/usr/share/doc/hw-management/copyright"
#%dir %attr(0755, root, root) "/usr/share/man"
#%dir %attr(0755, root, root) "/usr/share/man/man1"
%doc %attr(0644, root, root) "/usr/share/man/man1/hw-management.1.gz"
#%dir %attr(0755, root, root) "/usr/share/man/man8"
%doc %attr(0644, root, root) "/usr/share/man/man8/hw-management-tc.service.8.gz"
%doc %attr(0644, root, root) "/usr/share/man/man8/hw-management.service.8.gz"
