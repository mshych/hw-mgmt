#!/bin/bash
########################################################################
# Copyright (C) 2021 Nvidia Technologies Ltd. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. Neither the names of the copyright holders nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
#
# Alternatively, this software may be distributed under the terms of the
# GNU General Public License ("GPL") version 2 as published by the Free
# Software Foundation.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#

set -e

MFR_NAME_ADDR=0x99
MFR_MODEL_ADDR=0x9a
MFR_REVISION_ADDR=0x9b
READ_POWER_SUPPLY_STATUS_ADDR=0xE0

VPD_OUTPUT_FILE=${VPD_OUTPUT_FILE:-"/dev/stdout"}

function calc_crc8 ( )
{
# CRC8  = x^8 + x^2 + x^1 + x^0.

	declare -a crc8_table=(
		0x00 0x07 0x0E 0x09 0x1C 0x1B 0x12 0x15
		0x38 0x3F 0x36 0x31 0x24 0x23 0x2A 0x2D
		0x70 0x77 0x7E 0x79 0x6C 0x6B 0x62 0x65
		0x48 0x4F 0x46 0x41 0x54 0x53 0x5A 0x5D
		0xE0 0xE7 0xEE 0xE9 0xFC 0xFB 0xF2 0xF5
		0xD8 0xDF 0xD6 0xD1 0xC4 0xC3 0xCA 0xCD
		0x90 0x97 0x9E 0x99 0x8C 0x8B 0x82 0x85
		0xA8 0xAF 0xA6 0xA1 0xB4 0xB3 0xBA 0xBD
		0xC7 0xC0 0xC9 0xCE 0xDB 0xDC 0xD5 0xD2
		0xFF 0xF8 0xF1 0xF6 0xE3 0xE4 0xED 0xEA
		0xB7 0xB0 0xB9 0xBE 0xAB 0xAC 0xA5 0xA2
		0x8F 0x88 0x81 0x86 0x93 0x94 0x9D 0x9A
		0x27 0x20 0x29 0x2E 0x3B 0x3C 0x35 0x32
		0x1F 0x18 0x11 0x16 0x03 0x04 0x0D 0x0A
		0x57 0x50 0x59 0x5E 0x4B 0x4C 0x45 0x42
		0x6F 0x68 0x61 0x66 0x73 0x74 0x7D 0x7A
		0x89 0x8E 0x87 0x80 0x95 0x92 0x9B 0x9C
		0xB1 0xB6 0xBF 0xB8 0xAD 0xAA 0xA3 0xA4
		0xF9 0xFE 0xF7 0xF0 0xE5 0xE2 0xEB 0xEC
		0xC1 0xC6 0xCF 0xC8 0xDD 0xDA 0xD3 0xD4
		0x69 0x6E 0x67 0x60 0x75 0x72 0x7B 0x7C
		0x51 0x56 0x5F 0x58 0x4D 0x4A 0x43 0x44
		0x19 0x1E 0x17 0x10 0x05 0x02 0x0B 0x0C
		0x21 0x26 0x2F 0x28 0x3D 0x3A 0x33 0x34
		0x4E 0x49 0x40 0x47 0x52 0x55 0x5C 0x5B
		0x76 0x71 0x78 0x7F 0x6A 0x6D 0x64 0x63
		0x3E 0x39 0x30 0x37 0x22 0x25 0x2C 0x2B
		0x06 0x01 0x08 0x0F 0x1A 0x1D 0x14 0x13
		0xAE 0xA9 0xA0 0xA7 0xB2 0xB5 0xBC 0xBB
		0x96 0x91 0x98 0x9F 0x8A 0x8D 0x84 0x83
		0xDE 0xD9 0xD0 0xD7 0xC2 0xC5 0xCC 0xCB
		0xE6 0xE1 0xE8 0xEF 0xFA 0xFD 0xF4 0xF3
	)
	input=("$@")

	for (( j = 0; j<${#input[@]}; j++ ))
	do
		buf=${input[j]}
		crc8=$(( crc8_table[ ( crc8 ^ buf ) & 0xff ] ))
	done

	crc8=$(printf "0x%01x\n" "$crc8")
}


function pmbus_write ( )
{
	# $1 - command ADDR.
	# $@ - data.
	cmd_addr="${1}"
	shift

	crc8=0
	i2c_addr=$((I2C_ADDR << 1))
	calc_crc8 "${i2c_addr}" "${cmd_addr}" "$@"
	# 1))
	wlen=$(($# + 2))
	i2ctransfer -f -y "${BUS_ID}" w"${wlen}"@"${I2C_ADDR}" "${cmd_addr}" "$@" "${crc8}"


	if [ -v "pmbus_delay" ]; then
		sleep "${pmbus_delay}"
	fi
}

function pmbus_write_nopec ( )
{
	# $1 - command ADDR.
	# $@ - data.
	cmd_addr="${1}"
	shift

	wlen=$(($# + 1))
	i2ctransfer -f -y "${BUS_ID}" w"${wlen}"@"${I2C_ADDR}" "${cmd_addr}" "$@"

	if [ -v "pmbus_delay" ]; then
		sleep "${pmbus_delay}"
	fi
}


function pmbus_page ( )
{
	pmbus_write 0x00 "${1}"
}

function pmbus_read ( )
{
	# $1 - command ADDR.
	# $2 - read len.
	local ret_val

	if [ ! -v "BUS_ID" ] || [ ! -v "I2C_ADDR" ]; then
		echo "Error i2c bus or address not specified." >> "$VPD_OUTPUT_FILE"
		exit -1
	fi

	#echo "i2ctransfer -f -y ${BUS_ID} w1@${I2C_ADDR} ${1} r${2}" >&2
	ret_val=$(i2ctransfer -f -y "${BUS_ID}" w1@"${I2C_ADDR}" "${1}" r"${2}")


	if [ -v "pmbus_delay" ]; then
		sleep "${pmbus_delay}"
	fi
	#echo ${ret_val} >&2
	echo "${ret_val}"
}

function pmbus_read_block ( )
{
	# $1 - command ADDR

	local ret_val
	#read block len
	len=$(pmbus_read "${1}" 1)
	len=$((len+1))
	ret_val=$(pmbus_read "${1}" "${len}")
	#echo ${ret_val} >&2
	echo "${ret_val}"
}

function hex_2_ascii ( )
{
	input=("$@")
	for c in "${!input[@]}"
	do
		if [ "${input[$c]}" == 0x00 ] || [ "${input[$c]}" == 0xFF ]; then
			continue
		fi
		echo -ne "\x${input[$c]//0x/}"
	done
}

function ascii_2_hex ( )
{
	input=("$1")
	echo -ne "$1"|od -An -tx1|sed 's/ / 0x/g;s/^ //;s/$//'
}

function print_pmbus_output ()
{
	arr=("$@")
	hex_2_ascii "${arr[@]:1}" >> "$VPD_OUTPUT_FILE"
	echo -ne '\n' >> "$VPD_OUTPUT_FILE"
}

function check_power_supply_status ( )
{
	READ_POWER_SUPPLY_STATUS=( $(pmbus_read $READ_POWER_SUPPLY_STATUS_ADDR 3) )
	echo "${READ_POWER_SUPPLY_STATUS[1]}"  >> "$VPD_OUTPUT_FILE"
	BOOTLOADER_MODE=$((READ_POWER_SUPPLY_STATUS[1] & 1<<2))
	BOOTLOAD_COMPLETTE=$((READ_POWER_SUPPLY_STATUS[1] & 1<<1))
	POWER_DOWN=$((READ_POWER_SUPPLY_STATUS[1] & 1<<0))

	echo BOOTLOADER_MODE: $BOOTLOADER_MODE BOOTLOAD_COMPLETTE: $BOOTLOAD_COMPLETTE POWER_DOWN: $POWER_DOWN  >> "$VPD_OUTPUT_FILE"
}

MICROTYPE=( 0x50 0x53 0x46 )
MICROTYPE_PRIMARY=0
MICROTYPE_SECONDARY=1
MICROTYPE_FLOATING=2

function enter_bootload_mode ()
{
	pmbus_write 0xFA 0x42 "${MICROTYPE[$MICROTYPE_SECONDARY]}" 0x44 0x41 0x54 0x50
}

function two_complement_checksum ( )
{
	checksum=0
	for x in "$@";
	do
		checksum=$((checksum+16#$x))
		checksum=$((checksum&0xff))
	done
	checksum=$((256-checksum))
	checksum=$((checksum&0xff))
	printf "0x%02x" "$checksum"
}

function upgrade_data_command ()
{
	res_chksum=$(two_complement_checksum fa 44 0 0 "$@")
	pmbus_write_nopec 0xFA 0x44 0x00 0x00 "${@/#/0x}" 0x00 "$res_chksum"
}

POLL_STATUS_FAILED=0x18
POLL_STATUS_POWERDOWN=0x33
POLL_STATUS_BUSY=0x55
POLL_STATUS_SUCCSESS=0x81
POLL_STATUS_NOTACTIVE=0xaa

function poll_upgrade_status ( )
{
	POLL_UPGRADE_STATUS=( $(pmbus_read 0xfa 2) )
	case "${POLL_UPGRADE_STATUS[0]}" in
		$POLL_STATUS_FAILED)
			echo POLL_UPGRADE_STATUS: "${POLL_UPGRADE_STATUS[0]}" Failed >> "$VPD_OUTPUT_FILE"
			;;
		$POLL_STATUS_POWERDOWN)
			echo POLL_UPGRADE_STATUS: "${POLL_UPGRADE_STATUS[0]}" Power Down  >> "$VPD_OUTPUT_FILE"
			;;
		$POLL_STATUS_BUSY)
			echo POLL_UPGRADE_STATUS: "${POLL_UPGRADE_STATUS[0]}" Busy  >> "$VPD_OUTPUT_FILE"
			;;
		$POLL_STATUS_SUCCSESS)
			echo POLL_UPGRADE_STATUS: "${POLL_UPGRADE_STATUS[0]}" Success  >> "$VPD_OUTPUT_FILE"
			;;
		$POLL_STATUS_NOTACTIVE)
			echo POLL_UPGRADE_STATUS: "${POLL_UPGRADE_STATUS[0]}" Not Active >> "$VPD_OUTPUT_FILE"
			;;
	esac
	LAST_POLL_UPGRADE_STATUS="${POLL_UPGRADE_STATUS[0]}"
	echo "${POLL_UPGRADE_STATUS[0]}"
}

function end_of_file ( )
{
	zero_32arr=(0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00)
	pmbus_write_nopec 0xFA 0x44 0x01 0x00 "${zero_32arr[@]}" 0x00 0xc1
}

function power_supply_reset ( )
{
	pmbus_write 0xf8 0xaf
}

function bootloader_status ( )
{
	BOOTLOADER_STATUS=( $(pmbus_read 0xfb 2) )

	B0OTLOADING_PRIMARY=$((BOOTLOADER_STATUS[0] & 1<<0))
	BO0TLOADING_FLOATING=$((BOOTLOADER_STATUS[0] & 1<<1))
	BO0TLOADING_SECONDARY=$((BOOTLOADER_STATUS[0] & 1<<2))
	B0OTLOADING_PRIMARY_COMPLETED=$((BOOTLOADER_STATUS[0] & 1<<3))
	BO0TLOADING_FLOATING_COMPLETED=$((BOOTLOADER_STATUS[0] & 1<<4))
	BO0TLOADING_SECONDARY_COMPLETED=$((BOOTLOADER_STATUS[0] & 1<<5))
	RESET_PRIMARY_COMPLETED=$((BOOTLOADER_STATUS[0] & 1<<6))
	RESET_FLOATING_COMPLETED=$((BOOTLOADER_STATUS[0] & 1<<7))

	echo "B0OTLOADING_PRIMARY: $B0OTLOADING_PRIMARY BO0TLOADING_FLOATING: $BO0TLOADING_FLOATING BO0TLOADING_SECONDARY: $BO0TLOADING_SECONDARY" >> "$VPD_OUTPUT_FILE"
	echo "B0OTLOADING_PRIMARY_COMPLETED: $B0OTLOADING_PRIMARY_COMPLETED BO0TLOADING_FLOATING_COMPLETED: $BO0TLOADING_FLOATING_COMPLETED BO0TLOADING_SECONDARY_COMPLETED: $BO0TLOADING_SECONDARY_COMPLETED" >> "$VPD_OUTPUT_FILE"
	echo "RESET_PRIMARY_COMPLETED: $RESET_PRIMARY_COMPLETED RESET_FLOATING_COMPLETED: $RESET_FLOATING_COMPLETED" >> "$VPD_OUTPUT_FILE"

	echo "${BOOTLOADER_STATUS[0]}"
}

I2C_ADDR_BOOTL_MODE=0x60

fw_filepath=/tmp/9157002076-08-01.txt
function burn_fw_file ( )
{
	local data=0
	cat "$fw_filepath" | while read line
	do
		case $line in
			'[data]'*)
				data=1
				continue
				;;
			'[checksum]'*)
				data=0
				;;
			*)
				#echo $line
				;;
		esac
		if [ $data -eq 1 ]; then
			write_arr=( $( echo "$line" | tr -d '\r' | cut -d= -f2 | fold -w2) )
			# 7a. Send the UPGRADE_DATA command.
			upgrade_data_command "${write_arr[@]}"
			# 7b. Send the POLL_UPGRADE_STATUS command for successful transaction.
				# i. Power Supply will respond SUCCESS if data was accepted by the target microcontroller.
				# ii. Power Supply will respond BUSY if data is still be processed by the target microcontroller.
				# iii. Power Supply will respond FAIL if failed checksum or was not processed by the target microcontroller (Read Section: What to do if IN-SYSTEM PROGRAMMING fails).
			# 7c. If BUSY, wait another 300 ms and return to 7b.
			local retry=0
			
			while [ $(poll_upgrade_status) == "$POLL_STATUS_BUSY" ] && [ $retry -lt 3 ]; do sleep 0.3s;((retry=retry+1)); done;
			if [ "$LAST_POLL_UPGRADE_STATUS" != "$POLL_STATUS_SUCCSESS" ]; then
				echo upgrade_data_command failed >> "$VPD_OUTPUT_FILE"
				exit
			fi
		fi
	done

}

function murata_update ( )
{
	local I2C_ADDR_CURR=$I2C_ADDR

	# 1. Read current firmware revision using command the READ_MFG_FW_REVISION.
	pmbus_page 0x01
	MFR_REVISION=$(pmbus_read_block "${MFR_REVISION_ADDR}")
	pmbus_page 0x00
	print_pmbus_output "${MFR_REVISION[@]}"

	check_power_supply_status

	# 2. Send the ENTER_BOOTLOAD_MODE command during Normal Operation.
	enter_bootload_mode

	# 3. When the command is received.
		# a. The Power supply will enter a power down state, shutting down main power conversion.
			# i. Power Supply will respond POWER_DOWN.
		# b. Upon successful power down, the power supply enters Bootload Mode.
		# c. The power supply will change the PMBus address to 0x60 and erase the targeted microcontroller.
			# i. Power Supply will respond BUSY during the erase the process.
		# d. Wait for host to initiate data transfer.
			# i. Power Supply will respond SUCCESS while waiting for data.

	I2C_ADDR=$I2C_ADDR_BOOTL_MODE

	# 4. Wait typically for 1 second to allow the Power Supply to enter Bootload Mode.
	sleep 1s

	# 5. Send the POLL_UPGRADE_STATUS command for successful entry into Bootload Mode.
		# 5a. Send the Host POWER_DOWN, BUSY or SUCCESS.

	if [ $(poll_upgrade_status) != "$POLL_STATUS_SUCCSESS" ]; then
		echo failed to enter boot mode >> "$VPD_OUTPUT_FILE"
		exit
	fi

	# 6. Send the PAGE command to get the microcontroller ready for the data dump.
	pmbus_page 0x01

	# 7. For each line in the app file.
	burn_fw_file

	# 8. Send the END_OF_FILE command to the Power Supply.
	end_of_file

	# 9. Wait typically for 1 second to allow the Power Supply to enter Bootload Mode.
	sleep 1.

	# 10. Send the POLL_UPGRADE_STATUS command for a successful transaction.
		# 10a. The target microcontroller will do a soft reset and conducts a checksum test of the upgraded firmware.
		# 10b. If the checksum test passes, the target microcontroller will leave BOOTLOAD Mode and will respond NOT_ACTIVE.
		# 10c. If the checksum test fails, the target microcontroller remains in BOOTLOAD Mode and will response
		# 	SUCCESS. The SUCCESS response refers to successfully entering BOOTLOAD Mode. (Read Section: What to
		# 	do if IN-SYSTEM PROGRAMMING fails).
	
	poll_upgrade_status
	if [ "$LAST_POLL_UPGRADE_STATUS" -eq "$POLL_STATUS_SUCCSESS" ]; then
		echo  "checksum test fails" >> "$VPD_OUTPUT_FILE"
		exit
	fi
	
	
	# 11. Repeat steps 1-9 to upgrade remaining microcontrollers.
	# Now we updating only secondary, so nothing todo here.
	
	# 12. Upgrading is complete, send the POWER_SUPPLY_RESET command.
	power_supply_reset
		# 12a. The Power Supply will send all microcontrollers a soft reset command. This will allow all the
		#	microcontrollers to restart together.
		# 12b. The Power Supply will leave Bootload Mode and change its PMBus address back to the address for Normal Operation.
		# 12c. After restart, the power supply will begin to deliver power again.
	I2C_ADDR=$I2C_ADDR_CURR
	
	# 13. To confirm the Power Supply is running upgraded firmware, send the READ_MFG_FW_REVISION command.
	pmbus_page 0x01
	MFR_REVISION=$(pmbus_read_block "${MFR_REVISION_ADDR}")
	pmbus_page 0x00
	print_pmbus_output "${MFR_REVISION[@]}"
}

max_psu_num=2
BUS_ID=4
I2C_ADDR=0x60
function do_update ( )
{
	for ((i=1; i<=max_psu_num; i++)); do
		if [ ! $(< /var/run/hw-management/events/pwr"$i") ]; then
			echo redudntant PSU should be available to update PSU FW.
			exit -1
		fi
		bus_p=/var/run/hw-management/config/psu"$i"_i2c_bus
		psu_addr_p=/var/run/hw-management/config/psu"$i"_i2c_addr
		BUS_ID=$(< $bus_p)
		I2C_ADDR=$(< $psu_addr_p)

		MFR_NAME=$(pmbus_read_block "${MFR_NAME_ADDR}")
		print_pmbus_output "${MFR_NAME[@]}"
	done
	
	# Temp for test.
	I2C_ADDR=0x58
	#for ((i=1; i<=max_psu_num; i++)); do
		murata_update
	#done
}

while [ $# -gt 0 ]; do

	if [[ $1 == *"--"* ]]; then
		param="${1/--/}"
		case $param in
			help)
				command=help
				;;
			update)
				command=update
				;;
			power_supply_reset)
				command=power_supply_reset
				;;
			poll_upgrade_status)
				command=poll_upgrade_status
				;;
			check_power_supply_status)
				command=check_power_supply_status
				;;
			bootloader_status)
				command=bootloader_status
				;;
			continue_update)
				command=continue_update
				;;
			end_of_file)
				command=end_of_file
				;;
			enter_bootload_mode)
				command=enter_bootload_mode
				;;
			burn_fw_file)
				command=burn_fw_file
				;;
			pmbus_page)
				command=pmbus_page
				page_val="$2"
				;;
			*)
				declare "$param=$2"
				;;
			esac
	fi

	shift
done

case $command in
	help)
		echo "
MLNX psu fw updating tool.

Usage:
	hw-management-psu-fw-tool.sh --update
Commands:
	--update: update fw
	--psu_type: set psu type (murata, delta, acbel).

	--help: this help.

Usage example: 
	hw-management-psu-fw-tool.sh --update --psu_type murata

"
		exit 0
		;;
	update)
		do_update
		exit 0
		;;
	continue_update)
		murata_update
		exit 0
		;;
	power_supply_reset)
		power_supply_reset
		exit 0
		;;
	poll_upgrade_status)
		poll_upgrade_status
		exit 0
		;;
	check_power_supply_status)
		check_power_supply_status
		exit 0
		;;
	bootloader_status)
		bootloader_status
		exit 0
		;;
	end_of_file)
		end_of_file
		exit 0
		;;
	enter_bootload_mode)
		enter_bootload_mode
		exit 0
		;;
	burn_fw_file)
		burn_fw_file
		exit 0
		;;
	pmbus_page)
		pmbus_page "$page_val"
		exit 0
		;;
	*)
		echo "No command specified, use --help to print usage example."
		;;
esac


