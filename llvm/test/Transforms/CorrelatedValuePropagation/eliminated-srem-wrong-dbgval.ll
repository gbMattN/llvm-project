; RUN: opt < %s -passes=correlated-propagation -S | FileCheck %s

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @srem_elide(i32 noundef %x) #0 !dbg !3 {
; CHECK:      #dbg_value(i32 %x, [[META8:![0-9]+]], !DIExpression(), [[META9:![0-9]+]])
; CHECK-NEXT: #dbg_value(i32 %x, [[META10:![0-9]+]], !DIExpression(DW_OP_constu, 42, DW_OP_mod, DW_OP_stack_value), [[META9]])
; CHECK-NEXT: %0 = add i32 %x, 41
;
entry:
    #dbg_value(i32 %x, !8, !DIExpression(), !9)
  %rem1 = srem i32 %x, 42, !dbg !10
    #dbg_value(i32 %rem1, !11, !DIExpression(), !9)
  %0 = add i32 %x, 41
  %spec.select = icmp ult i32 %0, 83
  %cond = select i1 %spec.select, i32 %rem1, i32 24
  ret i32 %cond
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @main() #0 {
entry:
  %call = call i32 @srem_elide(i32 noundef 42)
  %cmp = icmp ne i32 %call, 0
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

attributes #0 = { noinline nounwind uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!2}

!0 = distinct !DICompileUnit(language: DW_LANG_C11, file: !1, producer: "clang", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, splitDebugInlining: false, nameTableKind: None)
!1 = !DIFile(filename: "case.c", directory: "/")
!2 = !{i32 2, !"Debug Info Version", i32 3}
!3 = distinct !DISubprogram(name: "srem_elide", scope: !1, file: !1, line: 3, type: !4, scopeLine: 3, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !0, retainedNodes: !7)
!4 = !DISubroutineType(types: !5)
!5 = !{!6, !6}
!6 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!7 = !{}
!8 = !DILocalVariable(name: "x", arg: 1, scope: !3, file: !1, line: 3, type: !6)
!9 = !DILocation(line: 0, scope: !3)
!10 = !DILocation(line: 4, column: 15, scope: !3)
!11 = !DILocalVariable(name: "rem", scope: !3, file: !1, line: 4, type: !6)
