; ModuleID = 'module'
source_filename = "module"

%literal = type { double, double }
%string_literal = type { double, i8* }

@format_number = private unnamed_addr constant [5 x i8] c"%lf\0A\00", align 1
@format_true = private unnamed_addr constant [6 x i8] c"true\0A\00", align 1
@format_false = private unnamed_addr constant [7 x i8] c"false\0A\00", align 1
@format_string = private unnamed_addr constant [6 x i8] c"\22%s\22\0A\00", align 1
@format_function = private unnamed_addr constant [17 x i8] c"function object\0A\00", align 1
@format_undef = private unnamed_addr constant [11 x i8] c"undefined\0A\00", align 1
@format_error = private unnamed_addr constant [13 x i8] c"error: \22%s\22\0A\00", align 1
@0 = private unnamed_addr constant [18 x i8] c"boo type mismatch\00", align 1
@1 = private unnamed_addr constant [18 x i8] c"boo type mismatch\00", align 1
@2 = private unnamed_addr constant [18 x i8] c"boo type mismatch\00", align 1

declare i8* @malloc(i32)

declare i64 @printf(i8*, ...)

declare i8* @strcpy(i8*, i8*)

declare i32 @strlen(i8*)

declare i8* @strcat(i8*, i8*)

declare void @exit(i32)

define void @display(%literal* %0) {
entry:
  %1 = getelementptr inbounds %literal, %literal* %0, i32 0, i32 0
  %2 = getelementptr inbounds %literal, %literal* %0, i32 0, i32 1
  %3 = load double, double* %1
  %4 = load double, double* %2
  %5 = fcmp oeq double %3, 2.000000e+00
  br i1 %5, label %display_boolean, label %tmp

tmp:                                              ; preds = %entry
  %6 = fcmp oeq double %3, 3.000000e+00
  br i1 %6, label %display_string, label %tmp1

tmp1:                                             ; preds = %tmp
  %7 = fcmp oeq double %3, 4.000000e+00
  br i1 %7, label %display_function, label %tmp2

tmp2:                                             ; preds = %tmp1
  %8 = fcmp oeq double %3, 5.000000e+00
  br i1 %8, label %display_undefined, label %display_number

display_number:                                   ; preds = %tmp2
  %9 = call i64 (i8*, ...) @printf(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @format_number, i32 0, i32 0), double %4)
  br label %end

display_boolean:                                  ; preds = %entry
  %10 = fcmp oeq double %4, 1.000000e+00
  br i1 %10, label %print_true, label %print_false

print_true:                                       ; preds = %display_boolean
  %11 = call i64 (i8*, ...) @printf(i8* getelementptr inbounds ([6 x i8], [6 x i8]* @format_true, i32 0, i32 0))
  br label %end

print_false:                                      ; preds = %display_boolean
  %12 = call i64 (i8*, ...) @printf(i8* getelementptr inbounds ([7 x i8], [7 x i8]* @format_false, i32 0, i32 0))
  br label %end

display_string:                                   ; preds = %tmp
  %13 = bitcast double %4 to i64
  %14 = call i64 (i8*, ...) @printf(i8* getelementptr inbounds ([6 x i8], [6 x i8]* @format_string, i32 0, i32 0), i64 %13)
  br label %end

display_function:                                 ; preds = %tmp1
  %15 = call i64 (i8*, ...) @printf(i8* getelementptr inbounds ([17 x i8], [17 x i8]* @format_function, i32 0, i32 0))
  br label %end

display_undefined:                                ; preds = %tmp2
  %16 = call i64 (i8*, ...) @printf(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @format_undef, i32 0, i32 0))
  br label %end

end:                                              ; preds = %display_undefined, %display_function, %display_string, %print_false, %print_true, %display_number
  ret void
}

define void @error(i8* %0) {
entry:
  %1 = call i64 (i8*, ...) @printf(i8* getelementptr inbounds ([13 x i8], [13 x i8]* @format_error, i32 0, i32 0), i8* %0)
  call void @exit(i32 1)
  ret void
}

define i8* @strconcat(i8* %0, i8* %1) {
entry:
  %2 = call i32 @strlen(i8* %0)
  %3 = call i32 @strlen(i8* %1)
  %4 = add i32 %2, %3
  %5 = add i32 %4, 1
  %6 = call i8* @malloc(i32 %5)
  %7 = call i8* @strcpy(i8* %6, i8* %0)
  %8 = call i8* @strcat(i8* %6, i8* %1)
  ret i8* %6
}

define i32 @main() {
entry:
  %env = call i8* @malloc(i32 8)
  %0 = bitcast i8* %env to %literal**
  %1 = call i8* @malloc(i32 16)
  %2 = bitcast i8* %1 to %literal*
  %3 = getelementptr inbounds %literal, %literal* %2, i32 0, i32 0
  %4 = getelementptr inbounds %literal, %literal* %2, i32 0, i32 1
  store double 5.000000e+00, double* %3
  store double 0.000000e+00, double* %4
  %env1 = call i8* @malloc(i32 8)
  %5 = bitcast i8* %env1 to %literal**
  %6 = bitcast %literal** %5 to %literal***
  store %literal** %0, %literal*** %6
  %7 = call i8* @malloc(i32 16)
  %8 = bitcast i8* %7 to %literal*
  %9 = getelementptr inbounds %literal, %literal* %8, i32 0, i32 0
  %10 = getelementptr inbounds %literal, %literal* %8, i32 0, i32 1
  store double 5.000000e+00, double* %9
  store double 0.000000e+00, double* %10
  %11 = call i8* @malloc(i32 16)
  %12 = bitcast i8* %11 to %literal*
  %13 = getelementptr inbounds %literal, %literal* %12, i32 0, i32 0
  %14 = getelementptr inbounds %literal, %literal* %12, i32 0, i32 1
  store double 1.000000e+00, double* %13
  store double 1.000000e+02, double* %14
  %15 = call i8* @malloc(i32 16)
  %16 = bitcast i8* %15 to %literal*
  %17 = getelementptr inbounds %literal, %literal* %16, i32 0, i32 0
  %18 = getelementptr inbounds %literal, %literal* %16, i32 0, i32 1
  store double 1.000000e+00, double* %17
  store double 2.000000e+00, double* %18
  %19 = call i8* @malloc(i32 16)
  %20 = bitcast i8* %19 to %literal*
  %21 = getelementptr inbounds %literal, %literal* %20, i32 0, i32 0
  %22 = getelementptr inbounds %literal, %literal* %20, i32 0, i32 1
  store double 1.000000e+00, double* %21
  store double 3.000000e+00, double* %22
  %23 = getelementptr inbounds %literal, %literal* %16, i32 0, i32 1
  %24 = getelementptr inbounds %literal, %literal* %20, i32 0, i32 1
  %25 = load double, double* %23
  %26 = load double, double* %24
  %27 = getelementptr inbounds %literal, %literal* %16, i32 0, i32 0
  %28 = getelementptr inbounds %literal, %literal* %20, i32 0, i32 0
  %29 = load double, double* %27
  %30 = load double, double* %28
  %31 = fcmp oeq double %29, 1.000000e+00
  br i1 %31, label %tc.next, label %tc.error

tc.next:                                          ; preds = %entry
  %32 = fcmp oeq double %30, 1.000000e+00
  br i1 %32, label %tc.valid, label %tc.error

tc.error:                                         ; preds = %tc.next, %entry
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @0, i32 0, i32 0))
  call void @exit(i32 1)
  br label %tc.valid

tc.valid:                                         ; preds = %tc.error, %tc.next
  %33 = fmul double %25, %26
  %34 = call i8* @malloc(i32 16)
  %35 = bitcast i8* %34 to %literal*
  %36 = getelementptr inbounds %literal, %literal* %35, i32 0, i32 0
  %37 = getelementptr inbounds %literal, %literal* %35, i32 0, i32 1
  store double 1.000000e+00, double* %36
  store double %33, double* %37
  %38 = call i8* @malloc(i32 16)
  %39 = bitcast i8* %38 to %literal*
  %40 = getelementptr inbounds %literal, %literal* %39, i32 0, i32 0
  %41 = getelementptr inbounds %literal, %literal* %39, i32 0, i32 1
  store double 1.000000e+00, double* %40
  store double 2.000000e+00, double* %41
  %42 = getelementptr inbounds %literal, %literal* %35, i32 0, i32 1
  %43 = getelementptr inbounds %literal, %literal* %39, i32 0, i32 1
  %44 = load double, double* %42
  %45 = load double, double* %43
  %46 = getelementptr inbounds %literal, %literal* %35, i32 0, i32 0
  %47 = getelementptr inbounds %literal, %literal* %39, i32 0, i32 0
  %48 = load double, double* %46
  %49 = load double, double* %47
  %50 = fcmp oeq double %48, 1.000000e+00
  br i1 %50, label %tc.next2, label %tc.error3

tc.next2:                                         ; preds = %tc.valid
  %51 = fcmp oeq double %49, 1.000000e+00
  br i1 %51, label %tc.valid4, label %tc.error3

tc.error3:                                        ; preds = %tc.next2, %tc.valid
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @1, i32 0, i32 0))
  call void @exit(i32 1)
  br label %tc.valid4

tc.valid4:                                        ; preds = %tc.error3, %tc.next2
  %52 = fdiv double %44, %45
  %53 = call i8* @malloc(i32 16)
  %54 = bitcast i8* %53 to %literal*
  %55 = getelementptr inbounds %literal, %literal* %54, i32 0, i32 0
  %56 = getelementptr inbounds %literal, %literal* %54, i32 0, i32 1
  store double 1.000000e+00, double* %55
  store double %52, double* %56
  %57 = getelementptr inbounds %literal, %literal* %12, i32 0, i32 1
  %58 = getelementptr inbounds %literal, %literal* %54, i32 0, i32 1
  %59 = load double, double* %57
  %60 = load double, double* %58
  %61 = getelementptr inbounds %literal, %literal* %12, i32 0, i32 0
  %62 = getelementptr inbounds %literal, %literal* %54, i32 0, i32 0
  %63 = load double, double* %61
  %64 = load double, double* %62
  %65 = fcmp oeq double %63, 1.000000e+00
  br i1 %65, label %add.num1, label %add.cstr1

add.num1:                                         ; preds = %tc.valid4
  %66 = fcmp oeq double %64, 1.000000e+00
  br i1 %66, label %add.num, label %add.err

add.cstr1:                                        ; preds = %tc.valid4
  %67 = fcmp oeq double %63, 3.000000e+00
  br i1 %67, label %add.cstr2, label %add.err

add.cstr2:                                        ; preds = %add.cstr1
  %68 = fcmp oeq double %64, 3.000000e+00
  br i1 %68, label %add.str, label %add.err

add.err:                                          ; preds = %add.cstr2, %add.cstr1, %add.num1
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @2, i32 0, i32 0))
  call void @exit(i32 1)
  br label %add.num

add.num:                                          ; preds = %add.err, %add.num1
  %69 = load double, double* %57
  %70 = load double, double* %58
  %71 = fadd double %69, %70
  %72 = call i8* @malloc(i32 16)
  %73 = bitcast i8* %72 to %literal*
  %74 = getelementptr inbounds %literal, %literal* %73, i32 0, i32 0
  %75 = getelementptr inbounds %literal, %literal* %73, i32 0, i32 1
  store double 1.000000e+00, double* %74
  store double %71, double* %75
  br label %add.end

add.str:                                          ; preds = %add.cstr2
  %76 = bitcast %literal* %12 to %string_literal*
  %77 = bitcast %literal* %54 to %string_literal*
  %78 = getelementptr inbounds %string_literal, %string_literal* %76, i32 0, i32 1
  %79 = getelementptr inbounds %string_literal, %string_literal* %77, i32 0, i32 1
  %80 = load i8*, i8** %78
  %81 = load i8*, i8** %79
  %82 = call i8* @strconcat(i8* %80, i8* %81)
  %83 = call i8* @malloc(i32 16)
  %84 = bitcast i8* %83 to %string_literal*
  %85 = getelementptr inbounds %string_literal, %string_literal* %84, i32 0, i32 0
  %86 = getelementptr inbounds %string_literal, %string_literal* %84, i32 0, i32 1
  store double 3.000000e+00, double* %85
  store i8* %82, i8** %86
  %87 = bitcast %string_literal* %84 to %literal*
  br label %add.end

add.end:                                          ; preds = %add.str, %add.num
  %88 = phi %literal* [ %73, %add.num ], [ %87, %add.str ]
  call void @display(%literal* %88)
  ret i32 0
}

