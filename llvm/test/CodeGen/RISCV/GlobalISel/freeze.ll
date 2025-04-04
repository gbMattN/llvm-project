; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py UTC_ARGS: --version 5
; RUN: llc -mtriple=riscv32 -mattr=+f,+d,+zfh,+m,+v -global-isel -global-isel-abort=1 -verify-machineinstrs < %s | FileCheck %s --check-prefixes=CHECK,RV32
; RUN: llc -mtriple=riscv64 -mattr=+f,+d,+zfh,+m,+v -global-isel -global-isel-abort=1 -verify-machineinstrs < %s | FileCheck %s --check-prefixes=CHECK,RV64

define i32 @freeze_int(i32 %x) {
; CHECK-LABEL: freeze_int:
; CHECK:       # %bb.0:
; CHECK-NEXT:    mul a0, a0, a0
; CHECK-NEXT:    ret
  %y1 = freeze i32 %x
  %t1 = mul i32 %y1, %y1
  ret i32 %t1
}

define i5 @freeze_int2(i5 %x) {
; CHECK-LABEL: freeze_int2:
; CHECK:       # %bb.0:
; CHECK-NEXT:    mul a0, a0, a0
; CHECK-NEXT:    ret
  %y1 = freeze i5 %x
  %t1 = mul i5 %y1, %y1
  ret i5 %t1
}

define float @freeze_float(float %x) {
; CHECK-LABEL: freeze_float:
; CHECK:       # %bb.0:
; CHECK-NEXT:    fadd.s fa0, fa0, fa0
; CHECK-NEXT:    ret
  %y1 = freeze float %x
  %t1 = fadd float %y1, %y1
  ret float %t1
}

define double @freeze_double(double %x) nounwind {
; RV32-LABEL: freeze_double:
; RV32:       # %bb.0:
; RV32-NEXT:    addi sp, sp, -16
; RV32-NEXT:    fsd fa0, 8(sp)
; RV32-NEXT:    lw a0, 8(sp)
; RV32-NEXT:    lw a1, 12(sp)
; RV32-NEXT:    sw a0, 8(sp)
; RV32-NEXT:    sw a1, 12(sp)
; RV32-NEXT:    fld fa5, 8(sp)
; RV32-NEXT:    fadd.d fa0, fa5, fa5
; RV32-NEXT:    addi sp, sp, 16
; RV32-NEXT:    ret
;
; RV64-LABEL: freeze_double:
; RV64:       # %bb.0:
; RV64-NEXT:    fadd.d fa0, fa0, fa0
; RV64-NEXT:    ret
  %y1 = freeze double %x
  %t1 = fadd double %y1, %y1
  ret double %t1
}

define void @freeze_half(ptr %p) {
; CHECK-LABEL: freeze_half:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lh a1, 0(a0)
; CHECK-NEXT:    sh a1, 0(a0)
; CHECK-NEXT:    ret
  %x = load half, ptr %p
  %y1 = freeze half %x
  store half %y1, ptr %p
  ret void
}

define <vscale x 2 x i32> @freeze_ivec(<vscale x 2 x i32> %x) {
; CHECK-LABEL: freeze_ivec:
; CHECK:       # %bb.0:
; CHECK-NEXT:    ret
  %y = freeze <vscale x 2 x i32> %x
  ret <vscale x 2 x i32> %y
}

define <vscale x 2 x float> @freeze_fvec(<vscale x 2 x float> %x) {
; CHECK-LABEL: freeze_fvec:
; CHECK:       # %bb.0:
; CHECK-NEXT:    ret
  %y = freeze <vscale x 2 x float> %x
  ret <vscale x 2 x float> %y
}

define ptr @freeze_ptr(ptr %x) {
; CHECK-LABEL: freeze_ptr:
; CHECK:       # %bb.0:
; CHECK-NEXT:    addi a0, a0, 4
; CHECK-NEXT:    ret
  %y1 = freeze ptr %x
  %t1 = getelementptr i8, ptr %y1, i64 4
  ret ptr %t1
}

%struct.T = type { i32, i32 }

define i32 @freeze_struct(ptr %p) {
; RV32-LABEL: freeze_struct:
; RV32:       # %bb.0:
; RV32-NEXT:    lw a1, 0(a0)
; RV32-NEXT:    lw a0, 4(a0)
; RV32-NEXT:    add a0, a1, a0
; RV32-NEXT:    ret
;
; RV64-LABEL: freeze_struct:
; RV64:       # %bb.0:
; RV64-NEXT:    lw a1, 0(a0)
; RV64-NEXT:    lw a0, 4(a0)
; RV64-NEXT:    addw a0, a1, a0
; RV64-NEXT:    ret
  %s = load %struct.T, ptr %p
  %y1 = freeze %struct.T %s
  %v1 = extractvalue %struct.T %y1, 0
  %v2 = extractvalue %struct.T %y1, 1
  %t1 = add i32 %v1, %v2
  ret i32 %t1
}

define i32 @freeze_anonstruct(ptr %p) {
; RV32-LABEL: freeze_anonstruct:
; RV32:       # %bb.0:
; RV32-NEXT:    lw a1, 0(a0)
; RV32-NEXT:    lw a0, 4(a0)
; RV32-NEXT:    add a0, a1, a0
; RV32-NEXT:    ret
;
; RV64-LABEL: freeze_anonstruct:
; RV64:       # %bb.0:
; RV64-NEXT:    lw a1, 0(a0)
; RV64-NEXT:    lw a0, 4(a0)
; RV64-NEXT:    addw a0, a1, a0
; RV64-NEXT:    ret
  %s = load {i32, i32}, ptr %p
  %y1 = freeze {i32, i32} %s
  %v1 = extractvalue {i32, i32} %y1, 0
  %v2 = extractvalue {i32, i32} %y1, 1
  %t1 = add i32 %v1, %v2
  ret i32 %t1
}

define i32 @freeze_anonstruct2(ptr %p) {
; RV32-LABEL: freeze_anonstruct2:
; RV32:       # %bb.0:
; RV32-NEXT:    lh a1, 4(a0)
; RV32-NEXT:    lw a0, 0(a0)
; RV32-NEXT:    slli a1, a1, 16
; RV32-NEXT:    srli a1, a1, 16
; RV32-NEXT:    add a0, a0, a1
; RV32-NEXT:    ret
;
; RV64-LABEL: freeze_anonstruct2:
; RV64:       # %bb.0:
; RV64-NEXT:    lh a1, 4(a0)
; RV64-NEXT:    lw a0, 0(a0)
; RV64-NEXT:    slli a1, a1, 48
; RV64-NEXT:    srli a1, a1, 48
; RV64-NEXT:    addw a0, a0, a1
; RV64-NEXT:    ret
  %s = load {i32, i16}, ptr %p
  %y1 = freeze {i32, i16} %s
  %v1 = extractvalue {i32, i16} %y1, 0
  %v2 = extractvalue {i32, i16} %y1, 1
  %z2 = zext i16 %v2 to i32
  %t1 = add i32 %v1, %z2
  ret i32 %t1
}

define i32 @freeze_anonstruct2_sext(ptr %p) {
; RV32-LABEL: freeze_anonstruct2_sext:
; RV32:       # %bb.0:
; RV32-NEXT:    lh a1, 4(a0)
; RV32-NEXT:    lw a0, 0(a0)
; RV32-NEXT:    slli a1, a1, 16
; RV32-NEXT:    srai a1, a1, 16
; RV32-NEXT:    add a0, a0, a1
; RV32-NEXT:    ret
;
; RV64-LABEL: freeze_anonstruct2_sext:
; RV64:       # %bb.0:
; RV64-NEXT:    lh a1, 4(a0)
; RV64-NEXT:    lw a0, 0(a0)
; RV64-NEXT:    slli a1, a1, 48
; RV64-NEXT:    srai a1, a1, 48
; RV64-NEXT:    addw a0, a0, a1
; RV64-NEXT:    ret
  %s = load {i32, i16}, ptr %p
  %y1 = freeze {i32, i16} %s
  %v1 = extractvalue {i32, i16} %y1, 0
  %v2 = extractvalue {i32, i16} %y1, 1
  %z2 = sext i16 %v2 to i32
  %t1 = add i32 %v1, %z2
  ret i32 %t1
}

define i32 @freeze_array(ptr %p) nounwind {
; RV32-LABEL: freeze_array:
; RV32:       # %bb.0:
; RV32-NEXT:    lw a1, 0(a0)
; RV32-NEXT:    lw a0, 4(a0)
; RV32-NEXT:    add a0, a1, a0
; RV32-NEXT:    ret
;
; RV64-LABEL: freeze_array:
; RV64:       # %bb.0:
; RV64-NEXT:    lw a1, 0(a0)
; RV64-NEXT:    lw a0, 4(a0)
; RV64-NEXT:    addw a0, a1, a0
; RV64-NEXT:    ret
  %s = load [2 x i32], ptr %p
  %y1 = freeze [2 x i32] %s
  %v1 = extractvalue [2 x i32] %y1, 0
  %v2 = extractvalue [2 x i32] %y1, 1
  %t1 = add i32 %v1, %v2
  ret i32 %t1
}
