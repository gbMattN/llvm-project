// RUN: llvm-mc -triple=aarch64 %s | FileCheck %s --check-prefix=ASM
// RUN: llvm-mc -triple=aarch64 -filetype=obj %s | llvm-readelf --hex-dump=.ARM.attributes - | FileCheck %s --check-prefix=ELF

// ASM: .aeabi_subsection aeabi_feature_and_bits, optional, uleb128
// ASM: .aeabi_attribute 0, 1 // Tag_Feature_BTI
// ASM: .aeabi_attribute 1, 0 // Tag_Feature_PAC
// ASM: .aeabi_attribute 2, 0 // Tag_Feature_GCS

// ELF: Hex dump of section '.ARM.attributes':
// ELF-NEXT: 0x00000000 41230000 00616561 62695f66 65617475 A#...aeabi_featu
// ELF-NEXT: 0x00000010 72655f61 6e645f62 69747300 01000001 re_and_bits.....
// ELF-NEXT: 0x00000020 01000200


.aeabi_subsection aeabi_feature_and_bits, optional, uleb128
.aeabi_attribute Tag_Feature_BTI, 1
.aeabi_attribute Tag_Feature_PAC, 0
.aeabi_attribute Tag_Feature_GCS, 0
